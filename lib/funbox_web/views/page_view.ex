defmodule FunboxWeb.PageView do
  use FunboxWeb, :view

  def show_section_link(section) do
    raw("<a href=\"##{section}\">#{section}</a>")
  end

  def show_section_name(section) do
    name = List.first(section).section
    raw("<h1 id=\"#{name}\">#{name}</h1>")
  end

  def show_section_desc(section) do
    desc = List.first(section).section_desc
    raw("<h4><i>#{desc}</i></h4>")
  end
end
