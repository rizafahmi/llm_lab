defmodule LlmLab.Catalog.Note do
  @moduledoc """
  The Note schema represents a field note associated with a prompt.
  Field notes capture qualitative observations and learnings about a prompt.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :content, :string
    field :author, :string
    field :models_tested, :string
    field :reference_url, :string

    belongs_to :prompt, LlmLab.Catalog.Prompt

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:content, :author, :models_tested, :reference_url, :prompt_id])
    |> validate_required([:content, :prompt_id])
    |> assoc_constraint(:prompt)
  end
end
