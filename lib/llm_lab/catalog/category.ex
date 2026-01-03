defmodule LlmLab.Catalog.Category do
  @moduledoc """
  The Category schema represents a category for organizing prompts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :slug, :string

    has_many :prompts, LlmLab.Catalog.Prompt

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
