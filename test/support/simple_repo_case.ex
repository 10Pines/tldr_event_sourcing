defmodule TldrEventSourcing.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias TldrEventSourcing.Repo

      import Ecto
      import Ecto.Query
      import TldrEventSourcing.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TldrEventSourcing.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(TldrEventSourcing.Repo, {:shared, self()})
    end

    :ok
  end
end
