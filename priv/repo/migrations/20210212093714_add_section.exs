defmodule Funbox.Repo.Migrations.AddSection do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :section, :string
    end
  end
end
