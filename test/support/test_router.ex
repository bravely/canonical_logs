defmodule CanonicalLogs.Support.TestRouter do
  use Plug.Router
  require Logger

  # Ho ho ho we're lying
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint], log: false)
  plug(Plug.RequestId)
  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  get "/hello" do
    send_resp(conn, 200, "Hello World!")
  end

  forward("/graphql", to: Absinthe.Plug, init_opts: [schema: CanonicalLogs.Support.TestSchema])

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
