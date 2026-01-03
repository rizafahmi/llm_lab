defmodule LlmLabWeb.PromptsLive do
  use LlmLabWeb, :live_view

  alias LlmLab.Catalog

  @impl true
  def mount(_params, _session, socket) do
    categories = Catalog.list_prompts_by_category()

    {:ok, assign(socket, categories: categories)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    prompt = Catalog.get_prompt!(id)
    # Sort notes chronologically (oldest first)
    notes = Enum.sort_by(prompt.notes, & &1.inserted_at, DateTime)

    {:noreply, assign(socket, prompt: prompt, notes: notes)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(%{prompt: _prompt, notes: _notes} = assigns) do
    ~H"""
    <div>
      <h1>{@prompt.title}</h1>
      <p>{@prompt.content}</p>
      <h2>Field Notes</h2>
      <div>
        <%= for note <- @notes do %>
          <div>
            {note.content}
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Browse Prompts</h1>
      <%= for category <- @categories do %>
        <div>
          <h2>{category.name}</h2>
          <div>
            <%= for prompt <- category.prompts do %>
              <a href={~p"/prompts/#{prompt.id}"}>
                {prompt.title}
              </a>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
