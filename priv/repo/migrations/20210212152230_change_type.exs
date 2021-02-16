defmodule Funbox.Repo.Migrations.ChangeType do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      modify :section, :text
      modify :section_desc, :text
      modify :desc, :text
    end
  end
end
