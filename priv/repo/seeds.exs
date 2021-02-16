# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Funbox.Repo.insert!(%Funbox.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# alias Funbox.Repo
# alias Funbox.Repository

Funbox.Repo.insert(%Funbox.Repository{
  days: 100,
  ref: "https://hexdocs.pm/phoenix/1.3.0-rc.2/seeding_data.html",
  name: "testname",
  stars: 50
})
