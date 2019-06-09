defmodule TldrEventSourcingTest.UserTest do
  use ExUnit.Case
  use TldrEventSourcing.RepoCase

  alias TldrEventSourcing.{SystemSpeaker, User, Repo, Event, UserSpeaker}

  test "create_user from system" do
    user_id = SystemSpeaker.create_user("sarasa")

    g = Repo.get(User, user_id)
    assert g.username == "sarasa"

    inserted = Repo.get_by(Event, aggregate_id: user_id)

    assert inserted.speaker_type == "SYSTEM"
    assert inserted.aggregate_type == "Elixir.TldrEventSourcing.User"
    assert inserted.event_type == "user_created"
    assert inserted.data == %{"username" => "sarasa"}
    assert inserted.timestamp != nil
  end

  test "create_user from user" do
    root_id = SystemSpeaker.create_user("root")
    user_id = UserSpeaker.create_user(UserSpeaker.speaker(root_id, %{sample_metadata: true}), "padawan")

    g = Repo.get(User, user_id)
    assert g.username == "padawan"

    inserted = Repo.get_by(Event, aggregate_id: user_id)

    assert inserted.speaker_type == "Elixir.TldrEventSourcing.UserSpeaker"
    assert inserted.speaker_id == root_id
    assert inserted.aggregate_type == "Elixir.TldrEventSourcing.User"
    assert inserted.event_type == "user_created"
    assert inserted.data == %{"username" => "padawan"}
    assert inserted.speaker_metadata == %{"sample_metadata" => true}
  end


end
