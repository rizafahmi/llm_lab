defmodule LlmLab.Catalog do
  @moduledoc """
  The Catalog context provides functions for managing prompts and categories.
  """

  alias LlmLab.Repo
  alias LlmLab.Catalog.Category

  @doc """
  Returns all prompts grouped by category.
  """
  def list_prompts_by_category do
    Category
    |> Repo.all()
    |> Repo.preload(prompts: [:category])
  end
end
