defmodule FunboxWeb.DBRequestsTest do
  use Funbox.DataCase
  alias Funbox.Repositories.GitReqs

  test "inserting and deleting in database" do
    Funbox.Repositories.delete_all_repos()
    libs = Funbox.Repositories.get_all_repos()
    assert length(libs) == 0

    {:ok, newlibs} = GitReqs.get_libs(10)
    Funbox.Repositories.create_repos(newlibs)
    libs = Funbox.Repositories.get_all_repos()
    assert length(libs) == 10
  end
end
