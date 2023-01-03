defmodule CanonicalLogsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import ExUnit.CaptureLog
  doctest CanonicalLogs

  alias CanonicalLogs.Support.TestRouter

  @opts TestRouter.init([])

  setup do
    on_exit(fn ->
      CanonicalLogs.detach()
    end)
  end

  test "logs the expected information for a request by default" do
    CanonicalLogs.attach()

    logs =
      capture_log(fn ->
        %{state: :sent} = TestRouter.call(conn(:get, "/hello"), @opts)
      end)

    assert logs =~ "[info] GET /hello"
    assert logs =~ "status=200"
    assert logs =~ ~r/request_id=\S{20}/
    assert logs =~ "request_path=/hello"
    assert logs =~ "method=GET"
    assert logs =~ ~r/duration=\d/
  end

  test "logs the configured conn_metadata" do
    CanonicalLogs.attach(conn_metadata: [:host, :scheme])

    logs =
      capture_log(fn ->
        %{state: :sent} = TestRouter.call(conn(:get, "/hello"), @opts)
      end)

    assert logs =~ "[info] GET /hello"
    assert logs =~ "host=www.example.com"
    assert logs =~ "scheme=http"
  end

  @tag :focus
  test "filters metadata keys recursively" do
    CanonicalLogs.attach(
      conn_metadata: [:params],
      filter_metadata_recursively: ["password"]
    )

    logs =
      capture_log(fn ->
        %{state: :sent} =
          conn(:get, "/hello", %{foo: %{password: "hunter2"}})
          |> TestRouter.call(@opts)
      end)

    assert logs =~ "[info] GET /hello"
    assert logs =~ "password=[FILTERED]"
  end
end
