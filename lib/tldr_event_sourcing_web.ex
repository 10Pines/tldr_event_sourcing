defmodule TldrEventSourcingWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use TldrEventSourcingWeb, :controller
      use TldrEventSourcingWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: TldrEventSourcingWeb

      import Plug.Conn
      import TldrEventSourcingWeb.Gettext
      alias TldrEventSourcingWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/tldr_event_sourcing_web/templates",
        namespace: TldrEventSourcingWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import TldrEventSourcingWeb.ErrorHelpers
      import TldrEventSourcingWeb.Gettext
      alias TldrEventSourcingWeb.Router.Helpers, as: Routes

      def current_user(conn) do
        TldrEventSourcingWeb.Auth.current_user_or_guest(conn)
      end

      def is_guest(conn) do
        current_user(conn).username == "guest"
      end

      def only_if_logged_in(conn, action_description, fun) do
        if is_guest(conn) do
          {:safe, "To #{action_description} please <a href=\"/sessions/new\">log in</a>"}
        else
          fun.()
        end
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import TldrEventSourcingWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
