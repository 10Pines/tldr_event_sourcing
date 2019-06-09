defmodule Mix.Tasks.ReplayEvents do
    use Mix.Task

    alias TldrEventSourcing.{SystemSpeaker, User, Ticket, Repo, Event, UserSpeaker}

    @impl Mix.Task
    def run(args) do
        [:postgrex, :ecto]
            |> Enum.each(&Application.ensure_all_started/1)
        Repo.start_link
        Repo.query("TRUNCATE users", [])
        Repo.query("TRUNCATE tickets", [])
        Repo.query("TRUNCATE comments", [])
        Repo.query("TRUNCATE blockchain_transaction", [])

        Event.replay_all
    end
  end
