defmodule LlmLabWeb.Features.SearchPromptsTest do
  use LlmLabWeb.FeatureCase, async: true

  alias LlmLab.Repo
  alias LlmLab.Catalog.Category
  alias LlmLab.Catalog.Prompt

  setup do
    # Create categories
    {:ok, writing} = Repo.insert(%Category{name: "Writing", slug: "writing"})
    {:ok, code} = Repo.insert(%Category{name: "Code", slug: "code"})

    # Create prompts with different titles
    {:ok, _} =
      Repo.insert(%Prompt{
        title: "Blog Post Helper",
        content: "Help me write a blog post...",
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

  test "user can search prompts by title", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> fill_in("Search", with: "Blog")
    |> assert_has("a", text: "Blog Post Helper")
    |> refute_has("a", text: "Essay Writer")
    |> refute_has("a", text: "Function Generator")
  end

  test "user can search prompts by category", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> fill_in("Search", with: "Code")
    |> assert_has("a", text: "Function Generator")
    |> refute_has("a", text: "Blog Post Helper")
    |> refute_has("a", text: "Essay Writer")
  end

  test "search is case-insensitive", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> fill_in("Search", with: "blog")
    |> assert_has("a", text: "Blog Post Helper")
  end

  test "clearing search shows all prompts", %{conn: conn} do
    conn
    |> visit("/prompts")
    |> fill_in("Search", with: "Blog")
    |> refute_has("a", text: "Essay Writer")
    |> fill_in("Search", with: "")
    |> assert_has("a", text: "Blog Post Helper")
    |> assert_has("a", text: "Essay Writer")
    |> assert_has("a", text: "Function Generator")
  end
end
