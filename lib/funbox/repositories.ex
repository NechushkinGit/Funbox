defmodule Funbox.Repositories do
  import Ecto.Query
  alias Funbox.Repositories.Repository
  alias Funbox.Repo

  def get_libs_by_sections(min_stars \\ 0) do
    min_stars
    |> get_sections()
    |> Enum.map(&get_section(&1, min_stars))
  end

  def get_all_repos(min_stars \\ 0) do
    Repository
    |> where([a], a.stars >= ^min_stars)
    |> order_by([a], asc: a.name)
    |> Repo.all()
  end

  def get_sections(min_stars \\ 0) do
    Repository
    |> where([a], a.stars >= ^min_stars)
    |> group_by([a], a.section)
    |> order_by([a], asc: a.section)
    |> select([a], a.section)
    |> Repo.all()
  end

  defp get_section(section, min_stars) do
    Repository
    |> where([a], a.stars >= ^min_stars and a.section == ^section)
    |> order_by([a], asc: a.name)
    |> Repo.all()
  end

  def create_repo(attrs) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  def create_repos(attrs_list) do
    Enum.map(attrs_list, &create_repo(&1))
  end

  def delete_all_repos do
    Repo.delete_all(Repository)
  end

  def delete_repo(name) do
    Repository
    |> where([r], r.name == ^name)
    |> Repo.delete_all()
  end

  def delete_repos(names) do
    Repository
    |> where([r], r.name in ^names)
    |> Repo.delete_all()
  end

  def update_repos(limit \\ -1) do
    case Funbox.Repositories.GitReqs.get_libs(limit) do
      {:ok, new_repos} ->
        existing_repos_names =
          get_all_repos()
          |> Enum.map(& &1.name)

        new_repos_names =
          new_repos
          |> Enum.map(& &1.name)

        new_repos
        |> Enum.filter(&(&1.name not in existing_repos_names))
        |> create_repos()

        existing_repos_names
        |> Enum.filter(&(&1 not in new_repos_names))
        |> delete_repos()

      {:error, reason} ->
        IO.inspect(reason)
    end
  end
end
