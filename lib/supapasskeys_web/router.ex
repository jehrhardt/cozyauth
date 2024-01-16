defmodule SupapasskeysWeb.Router do
  use SupapasskeysWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SupapasskeysWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug SupapasskeysWeb.ApiAuth
  end

  scope "/", SupapasskeysWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/servers", ServerLive.Index, :index
    live "/servers/new", ServerLive.Index, :new
    live "/servers/:id/edit", ServerLive.Index, :edit

    live "/servers/:id", ServerLive.Show, :show
    live "/servers/:id/show/edit", ServerLive.Show, :edit
  end

  scope "/passkeys", SupapasskeysWeb do
    pipe_through :api

    post "/", RegistrationController, :create
    patch "/registrations/:id", RegistrationController, :update
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:supapasskeys, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SupapasskeysWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
