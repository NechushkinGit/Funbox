defmodule FunboxWeb.DBRequestsTest do
  use Funbox.DataCase

  test "inserting  and deleting in database" do
    Funbox.Repositories.delete_libs()
    libs = Funbox.Repositories.get_all_libs()
    assert length(libs) == 0
    {:ok, newlibs} = Funbox.Repositories.GitReqs.get_libs(10)
    Funbox.Repositories.insert_libs(newlibs)
    libs = Funbox.Repositories.get_all_libs()
    assert length(libs) == 10
  end
end
