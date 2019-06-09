defmodule TldrEventSourcing.Accounts.Credentials do
  use Ecto.Schema
  import Ecto.Changeset

  alias TldrEventSourcing.{Repo, User}

  schema "credentials" do
    field :encrypted_password, :string
    field :user_id, Ecto.UUID

    timestamps()
  end

  def find_credential_for_user_id user_id do
    Repo.get_by(__MODULE__, user_id: user_id)
  end

  def create_credential(user_id, password) do
    %__MODULE__{user_id: user_id, encrypted_password: encrypt_password(password)}
    |> Repo.insert()
  end

  def update_credential(credential, password) do
    credential
    |> change(%{encrypted_password: encrypt_password(password)})
    |> Repo.update()
  end

  def maybe_login(username, password) do
    with user when user != nil <- Repo.get_by(User, username: username),
         credential when credential != nil <- find_credential_for_user_id(user.id),
         true <- verify_password(credential,password)
    do
      {:ok, user}
    else
      _ -> {:error, "invalid credentials"}
    end
  end

  def verify_password(credential, password) do
    Bcrypt.verify_pass(password, credential.encrypted_password)
  end

  defp encrypt_password(password) do
    Bcrypt.hash_pwd_salt(password)
  end
end

