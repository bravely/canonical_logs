defmodule CanonicalLogs.Support.TestRouter do
  use Plug.Router
  require Logger

  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint], log: false)
  plug(Plug.RequestId)
  plug(:match)
  plug(:dispatch)
  # Ho ho ho we're lying

  get "/hello" do
    send_resp(conn, 200, "Hello World!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
