import Config

if config_env() == :test do
  config :tesla, adapter: Tesla.Adapter.Hackney
end
