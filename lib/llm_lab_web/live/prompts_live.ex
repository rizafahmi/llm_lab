defmodule LlmLabWeb.PromptsLive do
  use LlmLabWeb, :live_view

  alias LlmLab.Catalog

  @impl true
  def mount(_params, _session, socket) do
    categories = Catalog.list_prompts_by_category()

    {:ok, assign(socket, categories: categories)}
  end

  @impl true
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
