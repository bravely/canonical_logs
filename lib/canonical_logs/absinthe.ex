defmodule CanonicalLogs.Absinthe do
  @handler_id "canonical-logs-absinthe-execute-operation-stop"

  alias Absinthe.Blueprint

  @doc """
  Attaches CanonicalLogs handlers to Absinthe.Telemetry events to gather metadata at the end of each operation.
  """
  def attach(options \\ []) do
    :telemetry.attach(
      @handler_id,
      [:absinthe, :execute, :operation, :stop],
      &__MODULE__.handle_absinthe_stop/4,
      options
    )
  end

  def handle_absinthe_stop(
        _event_name,
        _measurements,
        metadata,
        _config
      ) do
    graphql_errored =
      case metadata.blueprint.result do
        %{errors: errors} when errors != [] ->
          true

        _ ->
          false
      end

    Logger.metadata(
      graphql_operation_name: Blueprint.current_operation(metadata.blueprint).name,
      graphql_variables: Keyword.get(metadata.options, :variables),
      graphql_errored: graphql_errored
    )
  end
end
