defmodule TldrEventSourcingWeb.Router do
  use TldrEventSourcingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authorized do
    plug TldrEventSourcingWeb.Auth.Pipeline
  end

  scope "/", TldrEventSourcingWeb do
    pipe_through :browser

    scope "/" do
      pipe_through :authorized
      get "/", TicketsController, :index
      resources "/tickets", TicketsController
      post "/tickets/:ticket_id/comment", TicketsController, :add_comment
      
      get "/tickets/:ticket_id/comment/:comment_id", TicketsController, :edit_comment
      put "/tickets/:ticket_id/comment/:comment_id", TicketsController, :save_comment
      #TODO: this should NOT be a get, but a delete!
      get "/tickets/:ticket_id/comment/:comment_id/delete", TicketsController, :delete_comment

      resources "/events", EventsController
      get "/events.json", EventsController, :index_json

      resources "/tables", TablesController

      resources "/blockchain", BlockchainController
      post "/blockchain/post_transaction", BlockchainController, :post_transaction
      post "/blockchain/update_transaction_status", BlockchainController, :update_transaction_status

    end

    get "/sessions/new", SessionsController, :new
    post "/sessions/", SessionsController, :create
    get "/sessions/logout", SessionsController, :logout

  end

end
