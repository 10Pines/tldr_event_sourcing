# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :tldr_event_sourcing,
  ecto_repos: [TldrEventSourcing.Repo]

  # Configures the endpoint
config :tldr_event_sourcing, TldrEventSourcingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hl4sU1Rn2Bvxn/jBdg+4KpaEV/mDtHlZQEkDxyPEFlAA6tJaPJbHjxyg4JMV3+Rh",
  render_errors: [view: TldrEventSourcingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TldrEventSourcing.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :tldr_event_sourcing, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:tldr_event_sourcing, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}*.exs"
