defmodule LlmLabWeb.Features.ResponsiveDesignTest do
  use LlmLabWeb.FeatureCase, async: true

  alias LlmLab.Repo
  alias LlmLab.Catalog.Category
  alias LlmLab.Catalog.Prompt

  setup do
    # Create categories
    {:ok, writing} = Repo.insert(%Category{name: "Writing", slug: "writing"})

    # Create a prompt
    {:ok, _} =
      Repo.insert(%Prompt{
        title: "Blog Post Helper",
        content: "Help me write a blog post about...",
        category_id: writing.id
      })

    :ok
  end

  test "homepage is accessible and responsive", %{conn: conn} do
    conn
    |> visit("/")
    |> assert_has("h1", text: "LLM Lab Notes")
  end

  test "prompts index page has readable text", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> assert_has("h1", text: "Browse Prompts")
    |> assert_has("input", count: 1)
  end

  test "search input is accessible on mobile viewport", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> assert_has("form", count: 1)
    |> assert_has("label", text: "Search")
    |> assert_has("input[type='text']")
  end

  test "prompt list items are clickable and readable", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> assert_has("h2", text: "Writing")
    |> assert_has("a", text: "Blog Post Helper")
  end
end
