defmodule LlmLabWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use LlmLabWeb, :verified_routes

      import LlmLabWeb.FeatureCase

      import PhoenixTest
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(LlmLab.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
