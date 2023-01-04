defmodule CanonicalLogs.AbsintheTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog
  doctest CanonicalLogs.Absinthe

  alias CanonicalLogs.Support.TestRouter

  @opts TestRouter.init([])

  setup do
    on_exit(fn ->
      CanonicalLogs.detach()
    end)
  end

  test "logs the expected information for a GraphQL request by default" do
    CanonicalLogs.attach(
      filter_metadata_recursively: ["password"],
      conn_metadata: [:request_path, :method, :status]
    )

    CanonicalLogs.Absinthe.attach()

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
      end)

    assert logs =~ "[info] GET /graphql"
    assert logs =~ "email=test@example.com"
    assert logs =~ "password=[FILTERED]"
    assert logs =~ "password_confirmation=[FILTERED]"
    assert logs =~ "graphql_variables="

    [
      ~r/request_id=/,
      ~r/duration=/,
      ~r/status=/,
      ~r/method=/,
      ~r/request_path=/,
      ~r/graphql_operation_name/
    ]
    |> Enum.each(fn regex ->
      matches = Regex.scan(regex, logs)
      assert length(matches) == 1
    end)
  end
end
