defmodule LlmLabWeb.PromptsLive do
  use LlmLabWeb, :live_view

  alias LlmLab.Catalog

  @impl true
  def mount(_params, _session, socket) do
    categories = Catalog.list_prompts_by_category()

    {:ok, assign(socket, categories: categories, search_query: "")}
  end

  @impl true
  def handle_event("search", %{"search" => query}, socket) do
    categories = Catalog.search_prompts(query)
    {:noreply, assign(socket, categories: categories, search_query: query)}
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
    <div class="space-y-6 max-w-3xl">
      <div class="space-y-3">
        <h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900">
          {@prompt.title}
        </h1>
        <p class="text-base sm:text-lg text-gray-700 leading-relaxed">
          {@prompt.content}
        </p>
      </div>

      <div class="space-y-4 border-t border-gray-200 pt-6">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-900">Field Notes</h2>
        <div class="space-y-4">
          <%= for note <- @notes do %>
            <div class="p-4 sm:p-6 bg-gray-50 rounded-lg border border-gray-200 space-y-3">
              <p class="text-base text-gray-800 leading-relaxed">
                {note.content}
              </p>
              <div class="text-xs sm:text-sm text-gray-600 space-y-1 border-t border-gray-200 pt-3">
                <%= if note.author do %>
                  <div>
                    <span class="font-medium">Author:</span> {note.author}
                  </div>
                <% end %>
                <%= if note.models_tested do %>
                  <div>
                    <span class="font-medium">Models tested:</span> {note.models_tested}
                  </div>
                <% end %>
                <%= if note.reference_url do %>
                  <div>
                    <span class="font-medium">Reference:</span>
                    <a
                      href={note.reference_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-blue-600 hover:text-blue-700 underline break-all"
                    >
                      {note.reference_url}
                    </a>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl sm:text-3xl font-bold">Browse Prompts</h1>

      <form phx-change="search" id="search-form" class="mb-6">
        <label for="search" class="block text-sm font-medium mb-2">Search</label>
        <input
          type="text"
          name="search"
          id="search"
          value={@search_query}
          placeholder="Search by title or category..."
          class="w-full px-4 py-2 rounded border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </form>

      <%= for category <- @categories do %>
        <div class="space-y-3">
          <h2 class="text-xl sm:text-2xl font-semibold text-gray-900">{category.name}</h2>
          <div class="space-y-2">
            <%= for prompt <- category.prompts do %>
              <a
                href={~p"/prompts/#{prompt.id}"}
                class="block p-3 sm:p-4 rounded border border-gray-200 hover:border-blue-400 hover:bg-blue-50 transition-colors"
              >
                <span class="text-base sm:text-lg font-medium text-blue-600 hover:text-blue-700">
                  {prompt.title}
                </span>
              </a>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
