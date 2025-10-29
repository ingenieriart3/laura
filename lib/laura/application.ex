# defmodule Laura.Application do
#   # See https://hexdocs.pm/elixir/Application.html
#   # for more information on OTP Applications
#   @moduledoc false

#   use Application

#   @impl true
#   def start(_type, _args) do
#     children = [
#       LauraWeb.Telemetry,
#       Laura.Repo,
#       {DNSCluster, query: Application.get_env(:laura, :dns_cluster_query) || :ignore},
#       {Phoenix.PubSub, name: Laura.PubSub},
#       # Start a worker by calling: Laura.Worker.start_link(arg)
#       # {Laura.Worker, arg},
#       # Start to serve requests, typically the last entry
#       LauraWeb.Endpoint,
#       # Nuestros contextos personalizados
#       {Laura.Platform, []},
#       {Laura.Accounts, []},
#       {Laura.Billing, []},
#       {Laura.Scheduling, []},
#       {Laura.MedicalRecord, []},
#       # {Laura.Security.RateLimiter, []}
#     ]

#     # See https://hexdocs.pm/elixir/Supervisor.html
#     # for other strategies and supported options
#     opts = [strategy: :one_for_one, name: Laura.Supervisor]
#     Supervisor.start_link(children, opts)
#   end

#   # Tell Phoenix to update the endpoint configuration
#   # whenever the application is updated.
#   @impl true
#   def config_change(changed, _new, removed) do
#     LauraWeb.Endpoint.config_change(changed, removed)
#     :ok
#   end
# end

# lib/laura/application.ex - VERSIÓN CORREGIDA
defmodule Laura.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Laura.Repo,
      LauraWeb.Telemetry,
      {Phoenix.PubSub, name: Laura.PubSub},
      LauraWeb.Endpoint,
      # ✅ SOLO módulos que existen actualmente
      {Laura.Platform, []},
      {Laura.Accounts, []},
      {Laura.Billing, []},
      {Laura.Security.RateLimiter, []},
      {Laura.Scheduling, []},
      {Laura.MedicalRecord, []},
      {Laura.Messaging, []}
    ]

    opts = [strategy: :one_for_one, name: Laura.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    LauraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
