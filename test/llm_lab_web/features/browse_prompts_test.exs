defmodule LlmLabWeb.Features.BrowsePromptsTest do
  use LlmLabWeb.FeatureCase, async: true

  alias LlmLab.Repo
  alias LlmLab.Catalog.Category
  alias LlmLab.Catalog.Prompt

  setup do
    # Create categories
    {:ok, writing} = Repo.insert(%Category{name: "Writing", slug: "writing"})
    {:ok, code} = Repo.insert(%Category{name: "Code", slug: "code"})

    # Create prompts in different categories
    {:ok, _} =
      Repo.insert(%Prompt{
        title: "Blog Post Helper",
        content: "Help me write a blog post about...",
        category_id: writing.id
      })

    {:ok, _} =
      Repo.insert(%Prompt{
        title: "Function Generator",
        content: "Generate a function that...",
        category_id: code.id
      })

    {:ok, _} =
      Repo.insert(%Prompt{
        title: "Essay Writer",
        content: "Write an essay about...",
        category_id: writing.id
      })

    :ok
  end

  test "user can view all prompts grouped by category", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> assert_has("h1", text: "Browse Prompts")
    |> assert_has("h2", text: "Writing")
    |> assert_has("h2", text: "Code")
    |> assert_has("a", text: "Blog Post Helper")
    |> assert_has("a", text: "Function Generator")
    |> assert_has("a", text: "Essay Writer")
  end
end
