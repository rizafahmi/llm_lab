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

  @doc """
  Searches prompts by title or category name.
  Returns all prompts grouped by category.
  """
  def search_prompts(query) do
    if String.trim(query) == "" do
      list_prompts_by_category()
    else
      # Get all categories and their prompts
      categories = list_prompts_by_category()

      # Filter categories and prompts based on search query
      search_lower = String.downcase(query)

      categories
      |> Enum.map(fn category ->
        category_matches = String.contains?(String.downcase(category.name), search_lower)

        filtered_prompts =
          if category_matches do
            # If category matches, show all prompts in that category
            category.prompts
          else
            # Otherwise, only show prompts that match the search query
            Enum.filter(category.prompts, fn prompt ->
              String.contains?(String.downcase(prompt.title), search_lower)
            end)
          end

        Map.put(category, :prompts, filtered_prompts)
      end)
      |> Enum.filter(fn category ->
        Enum.any?(category.prompts)
      end)
    end
  end
end
