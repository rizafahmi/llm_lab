defmodule LlmLabWeb.PageController do
  use LlmLabWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
