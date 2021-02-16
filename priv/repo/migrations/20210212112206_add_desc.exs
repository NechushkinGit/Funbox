defmodule Funbox.Repo.Migrations.AddDesc do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :desc, :string
    end
  end
end
