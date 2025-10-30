# lib/laura/application.ex - VERSIÓN CORREGIDA
defmodule Laura.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Laura.Repo,
      # LauraWeb.Telemetry,
      # {Phoenix.PubSub, name: Laura.PubSub},
      # LauraWeb.Endpoint,
      # ✅ SOLO módulos que existen actualmente
      # {Laura.Platform, []},
      # {Laura.Accounts, []},
      # {Laura.Billing, []},
      # {Laura.Security.RateLimiter, []},
      # {Laura.Scheduling, []},
      # {Laura.MedicalRecord, []},
      # {Laura.Messaging, []}
      # Start the Ecto repository
      Laura.Repo,

      # Start the Telemetry supervisor
      LauraWeb.Telemetry,

      # Start the PubSub system
      {Phoenix.PubSub, name: Laura.PubSub},

      # Start the Endpoint (http/https)
      LauraWeb.Endpoint,

      # Start Finch for HTTP requests
      {Finch, name: Laura.Finch},

      # Start Mailer
      # Laura.Mailer
    ]

    opts = [strategy: :one_for_one, name: Laura.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    LauraWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def start(_type, _args) do
    children = [
      # ... otros children ...
      {Finch, name: Laura.Finch},
      Laura.Mailer
    ]

    opts = [strategy: :one_for_one, name: Laura.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
