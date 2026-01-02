defmodule LlmLabWeb.Features.HomeTest do
  use LlmLabWeb.FeatureCase, async: true

  test "visiting the home page", %{conn: conn} do
    conn
    |> visit("/")
    |> assert_has("h1", text: "LLM Lab Notes")
  end
end
