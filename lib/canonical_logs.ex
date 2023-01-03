defmodule CanonicalLogs do
  @moduledoc """
    Top-level API for CanonicalLogs.
  """
  require Logger

  @handler_id "canonical-logs-request-stop"

  @doc """
  Attaches CanonicalLogs handlers to `Plug.Telemetry` events to gather and log metadata at the end of each request.

  ## Options

    * `:event_prefix` - The event prefix for `Plug.Telemetry` events. Defaults to `[:phoenix, :endpoint]`.
    * `:filter_metadata_recursively` - A list of strings to filter out of the metadata. Defaults to `[]`. Any atoms passed to this option will be converted to strings.

  ## Examples

      iex> CanonicalLogs.attach()
      :ok

  """
  @spec attach(
          event_prefix: [atom(), ...],
          conn_metadata: [atom()],
          absinthe_metadata: [atom()],
          filter_metadata_recursively: [String.t()]
        ) :: :ok
  def attach(options \\ []) do
    {event_prefix, opts} =
      options
      |> Keyword.update(:filter_metadata_recursively, [], fn filtered_keys ->
        Enum.map(filtered_keys, &to_string/1)
      end)
      |> Keyword.pop(:event_prefix, [:phoenix, :endpoint])

    # We don't care if it is already attached, so we ignore the return value.
    :telemetry.attach(
      @handler_id,
      event_prefix ++ [:stop],
      &__MODULE__.handle_plug_stop/4,
      opts
    )
  end

  def detach do
    :telemetry.detach(@handler_id)
  end

  def handle_plug_stop(
        _event_name,
        %{duration: duration},
        %{conn: conn} = event_metadata,
        options
      ) do
    log_metadata =
      %{duration: System.convert_time_unit(duration, :native, :millisecond)}
      |> Map.merge(
        get_conn_metadata(
          event_metadata.conn,
          Keyword.get(options, :conn_metadata, [:request_path, :method, :status])
        )
      )
      |> Map.merge(get_logger_metadata())
      |> filter_metadata(Keyword.fetch!(options, :filter_metadata_recursively))

    Logger.info([conn.method, ?\s, conn.request_path], log_metadata)
  end

  defp get_conn_metadata(%Plug.Conn{} = conn, retrieveFields) do
    conn
    |> Map.take(retrieveFields)
    |> Map.new(fn {key, value} -> {to_string(key), value} end)
  end

  defp get_logger_metadata do
    Logger.metadata()
    |> Map.new(fn {key, value} -> {to_string(key), value} end)
  end

  @doc """
  Filters metadata recursively by replacing values of keys that contain any of the given strings.

  ## Examples

      iex> CanonicalLogs.filter_metadata(%{foo: "bar", baz: %{qux: "quux"}}, ["qux"])
      %{baz: %{qux: "[FILTERED]"}, foo: "bar"}
  """
  def filter_metadata(%{} = metadata, filtered_keys) do
    Map.new(metadata, &filter_metadata(&1, filtered_keys))
  end

  def filter_metadata(metadata, filtered_keys) when is_list(metadata) do
    if Keyword.keyword?(metadata) do
      metadata
      |> Map.new(&filter_metadata(&1, filtered_keys))
    else
      Enum.map(metadata, &filter_metadata(&1, filtered_keys))
    end
  end

  def filter_metadata({key, value}, filtered_keys) do
    string_key = to_string(key)

    if Enum.any?(filtered_keys, &String.contains?(string_key, &1)) do
      {key, "[FILTERED]"}
    else
      {key, filter_metadata(value, filtered_keys)}
    end
  end

  def filter_metadata(metadata, _filtered_keys), do: metadata
end
