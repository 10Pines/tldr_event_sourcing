defmodule TldrEventSourcing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    children = [
      # Start the Ecto repository
      TldrEventSourcing.Repo,
      # Start the endpoint when the application starts
      TldrEventSourcingWeb.Endpoint
      # Starts a worker by calling: Handsapp.Worker.start_link(arg)
      # {Handsapp.Worker, arg},
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TldrEventSourcing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
