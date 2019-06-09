defmodule TldrEventSourcingTest.HashBraidTest do
  use ExUnit.Case
  use TldrEventSourcing.RepoCase
  require Logger
  alias TldrEventSourcing.{SystemSpeaker, User, Repo, Event, UserSpeaker, HashBraid}

  test "first event ever hash and has no parent hash, creates hash braid single record" do
    user_id = SystemSpeaker.create_user("sarasa")

    inserted = Repo.get_by(Event, aggregate_id: user_id)
    assert inserted.parent_hash == nil
    timestamp_as_json = Jason.encode! inserted.timestamp
    hash_base = "{\"speaker_id\":null,\"speaker_type\":\"SYSTEM\",\"speaker_metadata\":{},\"aggregate_id\":\"#{user_id}\",\"aggregate_type\":\"Elixir.TldrEventSourcing.User\",\"event_type\":\"user_created\",\"parent_hash\":null,\"hash\":null,\"data\":{\"username\":\"sarasa\"},\"timestamp\":#{timestamp_as_json}}"
    Logger.info hash_base
    derived = :crypto.hash(:sha256, hash_base) |> Base.encode16 |> String.downcase
    assert inserted.hash == derived

    [hash_braid] = Repo.all(HashBraid)
    assert hash_braid.latest_event == inserted.id
    assert hash_braid.latest_hash == inserted.hash
  end

  test "second event ever has hash braided with parent, updates hash braid single record" do
    first_id = SystemSpeaker.create_user("root")
    second_id = UserSpeaker.create_user(UserSpeaker.speaker(first_id, %{sample_metadata: true}), "padawan")

    inserted_first = Repo.get_by(Event, aggregate_id: first_id)
    inserted_second = Repo.get_by(Event, aggregate_id: second_id)
    assert inserted_second.parent_hash == inserted_first.hash

    [hash_braid] = Repo.all(HashBraid)
    assert hash_braid.latest_event == inserted_second.id
    assert hash_braid.latest_hash == inserted_second.hash
  end

  test "when there are three events they're all braided" do
    first_id = SystemSpeaker.create_user("root")
    second_id = UserSpeaker.create_user(UserSpeaker.speaker(first_id, %{sample_metadata: true}), "padawan")
    third_id = UserSpeaker.create_user(UserSpeaker.speaker(first_id, %{sample_metadata: true}), "thirdy")

    inserted_first = Repo.get_by(Event, aggregate_id: first_id)
    inserted_second = Repo.get_by(Event, aggregate_id: second_id)
    inserted_third = Repo.get_by(Event, aggregate_id: third_id)

    assert inserted_second.parent_hash == inserted_first.hash
    assert inserted_third.parent_hash == inserted_second.hash

    [hash_braid] = Repo.all(HashBraid)
    assert hash_braid.latest_event == inserted_third.id
    assert hash_braid.latest_hash == inserted_third.hash
  end

end
