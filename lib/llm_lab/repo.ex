defmodule LlmLab.Repo do
  use Ecto.Repo,
    otp_app: :llm_lab,
    adapter: Ecto.Adapters.Postgres
end
