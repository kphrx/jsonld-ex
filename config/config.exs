import Config

if Mix.env() == :test do
  config :tesla, adapter: Tesla.Adapter.Hackney
end
