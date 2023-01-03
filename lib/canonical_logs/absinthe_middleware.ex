defmodule CanonicalLogs.AbsintheMiddleware do
  @moduledoc """
    Absinthe middleware to add the graphql operation name and arguments to Logger metadata.
  """
  @behaviour Absinthe.Middleware
  require Logger

  alias Absinthe.Blueprint.Document.Operation

  @doc """
  Adds the graphql operation name and arguments to Logger metadata.

  It will still use Absinthe's `:filter_variables` [config option](https://hexdocs.pm/absinthe/Absinthe.Logger.html#module-variable-filtering), but additionally uses it recursively.
  """
  def call(resolution, _opts) do
    graphql_operation_name =
      case Enum.find(resolution.path, &current_operation?/1) do
        %Operation{name: name} when not is_nil(name) -> name
        _ -> "#NULL"
      end

    Logger.metadata(graphql_operation_name: graphql_operation_name)

    if resolution.arguments != %{} do
      Logger.metadata(graphql_arguments: resolution.arguments)
    end

    resolution
  end

  defp current_operation?(%Operation{current: true}), do: true
  defp current_operation?(_), do: false

  @doc """
  Uses Absinthe's `:filter_variables` [config option](https://hexdocs.pm/absinthe/Absinthe.Logger.html#module-variable-filtering) to recursively filter variables by key.
  """
  def filter_arguments(arguments) do
    arguments
    |> Map.new(fn {key, value} ->
      case value do
        # This filters recursively.
        %{} -> {Atom.to_string(key), filter_arguments(value)}
        _ -> {Atom.to_string(key), value}
      end
    end)
    |> Absinthe.Logger.filter_variables()
  end
end
