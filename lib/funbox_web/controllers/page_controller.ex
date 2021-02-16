defmodule FunboxWeb.PageController do
  use FunboxWeb, :controller

  def index(conn, info) do
    stars_text = info["min_stars"]
    min_stars =
    case Integer.parse(to_string(stars_text)) do
      {val, _} -> val
      _ -> 0
    end
    libs = Funbox.Repositories.DBRequests.get_libs(min_stars)
    sections = Funbox.Repositories.DBRequests.get_sections(min_stars)
    render(conn, "index.html", libs: libs, sections: sections)
  end
end
