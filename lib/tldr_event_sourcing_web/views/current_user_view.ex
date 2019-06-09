defmodule TldrEventSourcingWeb.CurrentUserView do
  use TldrEventSourcingWeb, :view
  alias TldrEventSourcingWeb.CurrentUserView

  def render("current_user.json", %{user: user, token: token}) do
    %{id: user.id,
      username: user.username,
      token: token
    }
  end
end
