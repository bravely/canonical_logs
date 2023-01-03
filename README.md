# Canonical Logs

Inspired by the [legendary Stripe blog post](https://stripe.com/blog/canonical-log-lines), this library consolidates your Plug/Phoenix/Absinthe request logs into a single log line with all of their relevant information for easier querying.

<!-- ## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `canonical_logs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:canonical_logs, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/canonical_logs>.
 -->
## Installation

Add `canonical_logs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:canonical_logs, "~> 0.1.0"}
  ]
end
```

## Usage

In your `application.ex`, add the following to the top of your `start/2` function:

```elixir
  CanonicalLogs.attach()
```

Canonical Logs is built off of `Plug.Telemetry` events. If you use Phoenix, you'll find it called in your `<APP_NAME>Web.Endpoint` module.

Wherever the plug is used, modify the line to add the option `log: false`, like so:

```elixir
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint], log: false)
```

That's it! There's configuration options and more in [the docs](https://hexdocs.pm/canonical_logs).

### Absinthe

An Absinthe Middleware is included to allow providing the GraphQL operation name and accepted arguments as metadata, while recursively filtering variables by your Absinthe `:filter_variables` [config option](https://hexdocs.pm/absinthe/Absinthe.Logger.html#module-variable-filtering).

To use it, define or update your schema's `middleware/3` function to include the middleware:

```elixir
# lib/app_web/schema.ex
  def middleware(middleware, _field, _object) do
    middleware ++ [CanonicalLogs.AbsintheMiddleware]
  end
```

Additionally, it would make sense to add `exclude: ["params"]` to your configuration.

## Configuration

Available options, with their defaults:
```elixir
  config :canonical_logs,
    conn_metadata: [:request_path, :method, :status, :params]
    absinthe_metadata: [:graphql_operation_name, :arguments],
    filter_metadata_recursively: []
```

* `:conn_metadata`: Metadata to be pulled from the [`Plug.Conn`](https://hexdocs.pm/plug/Plug.Conn.html) during a `Plug.Telemetry` `:stop` event.
* `:absinthe_metadata`: Metadata to be pulled from the `Absinthe.Resolution` during the middleware call. Some special metadata is made available as well:
  * `:graphql_operation_name`: The top-level operation name of the GraphQL call. Defaults to "#NULL" if not found.
* `filter_metadata_recursively`: Metadata that if if the key includes this string at any depth will have its value replaced with `"[FILTERED]"`.
