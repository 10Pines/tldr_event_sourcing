defmodule TldrEventSourcing.Ticket do
  use TldrEventSourcing.Schema

  import Ecto.Changeset
  alias TldrEventSourcing.{Event, Repo, Ticket, User}
  import Ecto.Query, only: [from: 2]

  @max_tickets_per_user 3

  defmodule Comment do
    use TldrEventSourcing.Schema

    schema "comments" do
      field :text, :string
      field :timestamp, :utc_datetime_usec
      belongs_to :author, User
      belongs_to :ticket, Ticket
    end
  end

  schema "tickets" do
    field :title, :string
    field :body, :string
    field :assigned_to, :binary_id
    field :is_solved, :boolean
    field :timestamp, :utc_datetime_usec
    belongs_to :author, User
    has_many :comments, Comment
  end

  def create_ticket(speaker, title, body \\ "") do
    id = Ecto.UUID.generate
    Event.emit_event(speaker, __MODULE__, :ticket_created, id, %{title: title, body: body})
    id
  end

  def assign_ticket(speaker, ticket_id, assigned_to) do
    result = Repo.transaction(fn ->
      Repo.lock_entity(User, assigned_to)

      if open_assigned_ticket_count(assigned_to) == @max_tickets_per_user do
        {:error, "too many tickets"}
      else
        Event.emit_event(speaker, __MODULE__, :ticket_assigned, ticket_id, %{assigned_to: assigned_to})
        {:ok, nil}
      end
    end)

    #Transaction wrappea
    case result do
      {:ok, value} -> value
      err -> err
    end
  end

  def solve_ticket(speaker, ticket_id) do
    Event.emit_event(speaker, __MODULE__, :ticket_solved, ticket_id, %{})
  end

  def add_comment(speaker, ticket_id, comment_text) do
    id = Ecto.UUID.generate
    Event.emit_event(speaker, __MODULE__, :comment_added, ticket_id, %{comment_id: id, text: comment_text})
    id
  end

  def edit_comment(speaker = %TldrEventSourcing.Speaker{
                      speaker_type: TldrEventSourcing.UserSpeaker,
                      speaker_id: user_id,
                    }, ticket_id, comment_id, comment_text) do
    if Repo.get_by(Comment, id: comment_id, ticket_id: ticket_id, author_id: user_id) do
      Event.emit_event(speaker, __MODULE__, :comment_edited, ticket_id, %{comment_id: comment_id, text: comment_text})
      {:ok, nil}
    else
      {:error, "no comment found"}
    end
  end

  def delete_comment(speaker = %TldrEventSourcing.Speaker{
      speaker_type: TldrEventSourcing.UserSpeaker,
      speaker_id: user_id,
    }, ticket_id, comment_id) do
    if Repo.get_by(Comment, id: comment_id, ticket_id: ticket_id, author_id: user_id) do
      Event.emit_event(speaker, __MODULE__, :comment_deleted, ticket_id, %{comment_id: comment_id})
      {:ok, nil}
    else
      {:error, "no comment found"}
    end
  end

  #Eventos
  def ticket_created(%{title: title, body: body}, %{aggregate_id: ticket_id, speaker_id: speaker_id, timestamp: timestamp}) do
    u = %Ticket{title: title, body: body, id: ticket_id, is_solved: false, author_id: speaker_id, timestamp: timestamp}
    Repo.insert(u)
  end

  def ticket_assigned(params, %{aggregate_id: ticket_id}) do
    ticket = Repo.get_by(Ticket, id: ticket_id)
    change = ticket |> cast(params, [:assigned_to])
    Repo.update(change)
  end

  def ticket_solved(%{}, %{aggregate_id: ticket_id}) do
    ticket = Repo.get_by(Ticket, id: ticket_id)
    change = change(ticket, is_solved: true)
    Repo.update(change)
  end

  def comment_added(%{comment_id: id, text: comment_text}, %{speaker_id: speaker_id, aggregate_id: ticket_id, timestamp: timestamp}) do
    comment = %Comment{id: id, ticket_id: ticket_id, text: comment_text, author_id: speaker_id, timestamp: timestamp}
    Repo.insert(comment)
  end

  def comment_edited(%{comment_id: id, text: comment_text}, %{}) do
    comment = Repo.get_by(Comment, id: id)
    change = change(comment, text: comment_text)
    Repo.update(change)
  end

  def comment_deleted(%{comment_id: id}, %{}) do
    comment = Repo.get_by(Comment, id: id)
    Repo.delete(comment)
  end

  defp open_assigned_ticket_count(assigned_to) do
    query = from t in Ticket, where: t.assigned_to == ^assigned_to and not t.is_solved
    Repo.aggregate(query, :count, :assigned_to)
  end

end
