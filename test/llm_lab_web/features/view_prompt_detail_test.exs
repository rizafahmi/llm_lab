defmodule LlmLabWeb.Features.ViewPromptDetailTest do
  use LlmLabWeb.FeatureCase, async: true

  alias LlmLab.Repo
  alias LlmLab.Catalog.Category
  alias LlmLab.Catalog.Prompt
  alias LlmLab.Catalog.Note

  setup do
    # Create a category
    {:ok, category} = Repo.insert(%Category{name: "Writing", slug: "writing"})

    # Create a prompt
    {:ok, prompt} =
      Repo.insert(%Prompt{
        title: "Blog Post Helper",
        content: "Help me write a blog post about...",
        category_id: category.id
      })

    # Create some field notes in chronological order
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    one_hour_ago = now |> DateTime.add(-3600)

    {:ok, note1} =
      Repo.insert(%Note{
        prompt_id: prompt.id,
        content: "First note about this prompt",
        inserted_at: one_hour_ago
      })

    {:ok, note2} =
      Repo.insert(%Note{
        prompt_id: prompt.id,
        content: "Second note with **markdown**",
        inserted_at: now
      })

    {:ok, prompt: prompt, notes: [note1, note2]}
  end

  test "user can view prompt detail with field notes", %{conn: conn, prompt: prompt} do
    conn
    |> visit("/prompts/#{prompt.id}")
    |> assert_has("h1", text: "Blog Post Helper")
    |> assert_has("p", text: "Help me write a blog post about...")
    |> assert_has("h2", text: "Field Notes")
    |> assert_has("div", text: "First note about this prompt")
    |> assert_has("div", text: "Second note with **markdown**", exact: true)
  end
end
