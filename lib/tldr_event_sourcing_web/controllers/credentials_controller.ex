defmodule TldrEventSourcingWeb.CredentialsController do
  use TldrEventSourcingWeb, :controller

  alias TldrEventSourcing.Accounts
  alias TldrEventSourcing.Accounts.Credentials

  def index(conn, _params) do
    credentials = Accounts.list_credentials()
    render(conn, "index.html", credentials: credentials)
  end

  def new(conn, _params) do
    changeset = Accounts.change_credentials(%Credentials{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"credentials" => credentials_params}) do
    case Accounts.create_credentials(credentials_params) do
      {:ok, credentials} ->
        conn
        |> put_flash(:info, "Credentials created successfully.")
        |> redirect(to: Routes.credentials_path(conn, :show, credentials))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    credentials = Accounts.get_credentials!(id)
    render(conn, "show.html", credentials: credentials)
  end

  def edit(conn, %{"id" => id}) do
    credentials = Accounts.get_credentials!(id)
    changeset = Accounts.change_credentials(credentials)
    render(conn, "edit.html", credentials: credentials, changeset: changeset)
  end

  def update(conn, %{"id" => id, "credentials" => credentials_params}) do
    credentials = Accounts.get_credentials!(id)

    case Accounts.update_credentials(credentials, credentials_params) do
      {:ok, credentials} ->
        conn
        |> put_flash(:info, "Credentials updated successfully.")
        |> redirect(to: Routes.credentials_path(conn, :show, credentials))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", credentials: credentials, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    credentials = Accounts.get_credentials!(id)
    {:ok, _credentials} = Accounts.delete_credentials(credentials)

    conn
    |> put_flash(:info, "Credentials deleted successfully.")
    |> redirect(to: Routes.credentials_path(conn, :index))
  end
end
