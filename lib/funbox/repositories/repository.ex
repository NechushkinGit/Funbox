defmodule Funbox.Repositories.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query

  schema "repositories" do
    field :days, :integer
    field :name, :string
    field :ref, :string
    field :stars, :integer
    field :section, :string
    field :section_desc, :string
    field :desc, :string

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:name, :ref, :stars, :days, :section, :section_desc, :desc])
    |> validate_required([:name, :ref, :stars, :days, :section, :section_desc, :desc])
  end
end
