defmodule LlmLab.Catalog.Prompt do
  @moduledoc """
  The Prompt schema represents a prompt in the LLM Lab notebook.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "prompts" do
    field :title, :string
    field :content, :string

    belongs_to :category, LlmLab.Catalog.Category
    has_many :notes, LlmLab.Catalog.Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:title, :content, :category_id])
    |> validate_required([:title, :content, :category_id])
    |> assoc_constraint(:category)
  end
end
