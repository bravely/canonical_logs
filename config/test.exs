import Config

config :logger, :console,
  metadata: :all,
  format: {CanonicalLogs.Support.RecursiveFormatter, :format}
