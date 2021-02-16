defmodule Funbox.Repositories do
  import Ecto.Query, only: [from: 2]

  def get_libs_by_sections(min_stars \\ 0) do
    sections =
      get_sections(min_stars)
      |> Enum.map(&get_section(&1, min_stars))

    sections
  end

  def get_all_libs(min_stars \\ 0) do
    query =
      from u in Funbox.Repositories.Repository,
        where: u.stars >= ^min_stars,
        order_by: u.name,
        select: u

    Funbox.Repo.all(query)
  end

  def get_sections(min_stars \\ 0) do
    sections_query =
      from u in Funbox.Repositories.Repository,
        where: u.stars >= ^min_stars,
        group_by: u.section,
        order_by: u.section,
        select: u.section

    Funbox.Repo.all(sections_query)
  end

  defp get_section(section, min_stars) do
    query =
      from u in Funbox.Repositories.Repository,
        where: u.stars >= ^min_stars and u.section == ^section,
        order_by: u.name,
        select: u

    Funbox.Repo.all(query)
  end

  def insert_lib(lib) do
    [name, link, stars, days, section, section_desc, desc] = lib

    Funbox.Repo.insert(%Funbox.Repositories.Repository{
      days: days,
      ref: link,
      name: name,
      stars: stars,
      section: section,
      section_desc: section_desc,
      desc: desc
    })
  end

  def insert_libs(libs) do
    for lib <- libs do
      insert_lib(lib)
    end
  end

  def delete_libs do
    Funbox.Repo.delete_all(Funbox.Repositories.Repository)
  end

  def update_libs(limit \\ -1) do
    case Funbox.Repositories.GitReqs.get_libs(limit) do
      {:ok, libs} ->
        delete_libs()
        insert_libs(libs)

      {:error, reason} ->
        IO.inspect(reason)
    end
  end
end
