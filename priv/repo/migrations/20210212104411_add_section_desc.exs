defmodule Funbox.Repo.Migrations.AddSectionDesc do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :section_desc, :string
    end
  end
end
