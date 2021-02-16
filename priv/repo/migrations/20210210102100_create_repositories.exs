defmodule Funbox.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :name, :string
      add :ref, :string
      add :stars, :integer
      add :days, :integer

      timestamps()
    end
  end
end
