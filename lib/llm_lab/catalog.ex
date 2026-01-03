defmodule LlmLab.Catalog do
  @moduledoc """
  The Catalog context provides functions for managing prompts and categories.
  """

  alias LlmLab.Repo
  alias LlmLab.Catalog.Category
  alias LlmLab.Catalog.Prompt

  @doc """
  Returns all prompts grouped by category.
  """
  def list_prompts_by_category do
    Category
    |> Repo.all()
    |> Repo.preload(prompts: [:category])
  end

  @doc """
  Gets a single prompt by ID with its category and notes.
  """
  def get_prompt!(id) do
    Prompt
    |> Repo.get!(id)
    |> Repo.preload([:category, notes: []])
  end
end
