defmodule CanonicalLogs.AbsintheMiddlewareTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog
  doctest CanonicalLogs.AbsintheMiddleware

  alias CanonicalLogs.Support.TestRouter

  @opts TestRouter.init([])

  setup do
    on_exit(fn ->
      CanonicalLogs.detach()
    end)
  end

  test "logs the expected information for a GraphQL request by default" do
    CanonicalLogs.attach(filter_metadata_recursively: ["password"])

    logs =
      capture_log(fn ->
        %{state: :sent} =
          conn(:get, "/graphql", %{
            query: """
              query CreateUser($name: String!, $signupInput: SignupInput!) {
                createUser(name: $name, signupInput: $signupInput) {
                  id
                  name
                  email
                }
              }
            """,
            variables: %{
              name: "Jake",
              signupInput: %{
                email: "test@example.com",
                password: "hunter2",
                password_confirmation: "hunter2"
              }
            }
          })
          |> TestRouter.call(@opts)
          |> IO.inspect(label: "conn")
      end)

    assert logs =~ "[info] GET /graphql"
    assert logs =~ "email=test@example.com"
    assert logs =~ "password=[FILTERED]"
    assert logs =~ "password_confirmation=[FILTERED]"
    refute logs =~ "variables="
  end
end
