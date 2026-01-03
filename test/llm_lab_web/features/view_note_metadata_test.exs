defmodule LlmLabWeb.Features.ViewNoteMetadataTest do
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

    # Create a note with metadata
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    {:ok, note} =
      Repo.insert(%Note{
        prompt_id: prompt.id,
        content: "This is a note about the prompt.",
        author: "Alice",
        models_tested: "GPT-4, Claude",
        reference_url: "https://example.com/ref",
        inserted_at: now
      })

    {:ok, prompt: prompt, note: note, note_inserted_at: now}
  end

  test "user can see note metadata on prompt detail page", %{
    conn: conn,
    prompt: prompt
  } do
    conn
    |> visit("/prompts/#{prompt.id}")
    |> assert_has("h1", text: "Blog Post Helper")
    |> assert_has("h2", text: "Field Notes")
    |> assert_has("div", text: "Alice")
    |> assert_has("div", text: "GPT-4, Claude")
    |> assert_has("a", text: "https://example.com/ref")
  end
end
