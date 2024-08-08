import Config

config :todo, :db_path, "./persist"

if config_env() == :test do
  import_config("test.exs")
end
