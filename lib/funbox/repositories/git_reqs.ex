defmodule Funbox.Repositories.GitReqs do
  @hackney [
    basic_auth:
      with {:ok, var} <- Application.fetch_env(:funbox, :git) do
        {var[:username], var[:token]}
      end
  ]

  def get_libs(limit \\ -1) do
    case HTTPoison.get("https://api.github.com/repos/h4cc/awesome-elixir/readme", [],
           hackney: @hackney
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, map} = body |> Jason.decode()

        readme_content =
          map["content"]
          |> String.split("\n")
          |> Enum.map(&Base.decode64!(&1))
          |> Enum.join("")

        urls =
          readme_content
          |> parse_readme()
          |> Enum.slice(0..limit)
          |> Enum.map(&path_with_params(&1))

        {:ok, urls}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found :("}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def parse_readme(text) do
    newlines_replaced = Regex.replace(~r/\n/, text, "---")

    blocks =
      Regex.scan(~r/#\s(.*?)------#/, newlines_replaced)
      |> Enum.map(&List.first(&1))
      |> Enum.map(&parse_readme_block(&1))
      |> Enum.concat()

    blocks
  end

  @spec parse_readme_block(binary) :: list
  def parse_readme_block(block) do
    case Regex.run(~r/^#\s(.*?)---\*(.*?)\*------/, block) do
      [_, topic, topic_desc] ->
        list =
          Regex.scan(
            ~r/(https:\/\/github\.com\/[\w\-_]+\/[\w\-_]+)\)\s-\s([\w\s,\(\)!\/\d\-\[\]\.:\\\~_\""]+)---/,
            block
          )
          |> Enum.map(&extract_repo_info(&1, topic, topic_desc))

        list

      _ ->
        []
    end

    # [_, topic] = Regex.run(~r/^#\s(.*?)\n/, block)
  end

  def extract_repo_info(repo, section, section_desc) do
    [_, link, desc] = repo

    desc =
      case Regex.run(~r/\[(.*?)\]\((.*?)\)/, desc) do
        [_, name, href] ->
          Regex.replace(~r/\[(.*?)\]\((.*?)\)/, desc, "<a href=\"#{href}\">#{name}</a>")
          |> String.trim("-")

        _ ->
          String.trim(desc, "-")
      end

    section_desc =
      case Regex.run(~r/\[(.*?)\]\((.*?)\)/, section_desc) do
        [_, sname, sref] ->
          Regex.replace(~r/\[(.*?)\]\((.*?)\)/, section_desc, "<a href=\"#{sref}\">#{sname}</a>")

        _ ->
          section_desc
      end

    [link, section, section_desc, desc]
  end

  def extract_name(path) do
    [_, name] = Regex.run(~r/github\.com\/[\w_\-]+\/([\w_\-]+)/, path)
    name
  end

  def path_with_params(path_section) do
    [path, section, section_desc, desc] = path_section
    parts = extract_params(path)

    if length(parts) == 2 do
      [a, b] = parts
      stars = get_stars_count(a, b)
      days = get_days_since_last_commit(a, b)
      name = extract_name(path)
      [name, path, stars, days, section, section_desc, desc]
    else
      []
    end
  end

  def extract_params(path) do
    parts =
      Regex.run(~r/github\.com\/[\w_\-]+\/[\w_\-]+/, path)
      |> List.first()
      |> String.slice(11..-1)
      |> String.split("/")

    if length(parts) == 2 do
      [a, b] = parts
      [a, b]
    else
      []
    end
  end

  def get_stars_count(username, repo) do
    case HTTPoison.get("https://api.github.com/repos/#{username}/#{repo}", [], hackney: @hackney) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        stars = Jason.decode!(body)["stargazers_count"]
        stars

      {_, %HTTPoison.Response{status_code: 301, body: body}} ->
        url =
          Regex.run(~r/https:\/\/api\.github\.com\/repositories\/[0-9]+/, body)
          |> List.first()

        case HTTPoison.get(url, [], hackney: @hackney) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            stars = Jason.decode!(body)["stargazers_count"]
            stars

          {_, _} ->
            -1
        end

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        -1

      {_, _} ->
        -1
    end
  end

  def extract_date(map) do
    {:ok, date} = map["commit"]["author"]["date"] |> String.slice(0..9) |> Date.from_iso8601()
    date
  end

  def get_days_since_last_commit(username, repo) do
    case HTTPoison.get("https://api.github.com/repos/#{username}/#{repo}/commits", [],
           hackney: @hackney
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        cur_date = Date.utc_today()

        days =
          Jason.decode!(body)
          |> Enum.map(&extract_date(&1))
          |> Enum.map(&Date.diff(cur_date, &1))
          |> Enum.min()

        days

      {_, %HTTPoison.Response{status_code: 301, body: body}} ->
        url =
          Regex.run(~r/https:\/\/api\.github\.com\/repositories\/[0-9]+/, body)
          |> List.first()

        case HTTPoison.get(url <> "/commits", [], hackney: @hackney) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            cur_date = Date.utc_today()

            days =
              Jason.decode!(body)
              |> Enum.map(&extract_date(&1))
              |> Enum.map(&Date.diff(cur_date, &1))
              |> Enum.min()

            days

          {_, _} ->
            -1
        end

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        -1

      {_, _} ->
        -1
    end
  end
end
