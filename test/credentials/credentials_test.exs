defmodule TldrEventSourcing.CredentialsTest do
  use ExUnit.Case
  use TldrEventSourcing.RepoCase

  alias TldrEventSourcing.Accounts
  alias TldrEventSourcing.Accounts.Credentials
  alias TldrEventSourcing.Repo
  alias TldrEventSourcing.User
  alias TldrEventSourcing.SystemSpeaker

  test "credentials create_credential creates a credential with a hashed password" do
    user_id = SystemSpeaker.create_user("kylo")
    Credentials.create_credential(user_id, "a_password")
    inserted = Repo.all(Credentials) |> Enum.at(0)
    inserted.user_id == user_id
    inserted.encrypted_password != "a_password"
    assert Credentials.verify_password(inserted, "a_password")
  end

  test "credentials update_credential updates a credential with a hashed password" do
    user_id = SystemSpeaker.create_user("kylo")
    {:ok, c} = Credentials.create_credential(user_id, "a_password")
    Credentials.update_credential(c, "another_password")
    updated = Repo.all(Credentials) |> Enum.at(0)
    assert !Credentials.verify_password(updated, "a_password")
    assert Credentials.verify_password(updated, "another_password")
  end

  test "credentials maybe_login returns error if username does not exist" do
    assert Credentials.maybe_login("kylo", "password") == {:error, "invalid credentials"}
  end

  test "credentials maybe_login returns error if there is no credential for user" do
    user_id = SystemSpeaker.create_user("kylo")
    unrelated_credential = Credentials.create_credential(Ecto.UUID.generate, "password")
    assert Credentials.maybe_login("kylo", "password") == {:error, "invalid credentials"}
  end

  test "credentials maybe_login returns error if password does not match" do
    user_id = SystemSpeaker.create_user("kylo")
    credential = Credentials.create_credential(user_id, "different_password")
    assert Credentials.maybe_login("kylo", "password") == {:error, "invalid credentials"}
  end

  test "credentials maybe_login returns ok and user if password does match" do
    user_id = SystemSpeaker.create_user("kylo")
    credential = Credentials.create_credential(user_id, "password")
    {:ok, user} = Credentials.maybe_login("kylo", "password")
    assert user.id == user_id
  end
end
