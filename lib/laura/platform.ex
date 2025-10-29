# lib/laura/platform.ex
defmodule Laura.Platform do
  import Ecto.Query, warn: false
  alias Laura.Repo

  alias Laura.Platform.HealthBrand
  alias Laura.Billing.SubscriptionPlan
  alias Laura.Accounts

  def list_health_brands, do: Repo.all(HealthBrand)

  def get_health_brand!(id), do: Repo.get!(HealthBrand, id)

  def get_health_brand_by_subdomain(subdomain) do
    Repo.get_by(HealthBrand, subdomain: subdomain)
  end

  def create_health_brand(attrs \\ %{}) do
    %HealthBrand{}
    |> HealthBrand.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_health_brand(%HealthBrand{} = health_brand, attrs) do
    health_brand
    |> HealthBrand.update_subscription_changeset(attrs)
    |> Repo.update()
  end

  # Función para el onboarding completo con rate limiting
  def register_new_health_brand(owner_email, brand_attrs, plan_code, remote_ip) do
    # Verificar rate limiting primero
    case Laura.Security.RateLimiter.check_rate_limit(remote_ip, :tenant_registration) do
      {:ok, _remaining} ->
        do_register_new_health_brand(owner_email, brand_attrs, plan_code)

      {:error, :rate_limited} ->
        {:error, :rate_limited}
    end
  end

  # defp do_register_new_health_brand(owner_email, brand_attrs, plan_code) do
  #   plan = get_subscription_plan_by_code(plan_code)

  #   Ecto.Multi.new()
  #   |> Ecto.Multi.insert(:health_brand, HealthBrand.registration_changeset(brand_attrs))
  #   |> Ecto.Multi.run(:subscription_plan, fn _repo, %{health_brand: health_brand} ->
  #     update_health_brand(health_brand, %{subscription_plan_id: plan.id})
  #   end)
  #   |> Ecto.Multi.run(:owner, fn _repo, %{health_brand: health_brand} ->
  #     Accounts.create_staff(%{
  #       email: owner_email,
  #       health_brand_id: health_brand.id,
  #       staff_role_id: Accounts.get_admin_role().id
  #     })
  #   end)
  #   |> Ecto.Multi.run(:send_welcome, fn _repo, %{owner: owner, health_brand: health_brand} ->
  #     # Enviar email de bienvenida con magic link
  #     Accounts.deliver_staff_magic_link(owner, health_brand)
  #   end)
  #   |> Repo.transaction()
  # end

  defp get_subscription_plan_by_code(code) do
    Repo.get_by(SubscriptionPlan, code: code)
  end

  defp do_register_new_health_brand(owner_email, brand_attrs, plan_code) do
    plan = get_subscription_plan_by_code(plan_code)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:health_brand, HealthBrand.registration_changeset(%HealthBrand{}, brand_attrs))
    |> Ecto.Multi.run(:subscription_plan, fn _repo, %{health_brand: health_brand} ->
      update_health_brand(health_brand, %{subscription_plan_id: plan.id})
    end)
    |> Ecto.Multi.run(:owner, fn _repo, %{health_brand: health_brand} ->
      Accounts.create_staff(%{
        email: owner_email,
        health_brand_id: health_brand.id,
        staff_role_id: Accounts.get_admin_role().id
      })
    end)
    |> Ecto.Multi.run(:send_welcome, fn _repo, %{owner: owner, health_brand: health_brand} ->
      Accounts.deliver_staff_magic_link(owner, health_brand)
    end)
    |> Repo.transaction()
  end

  # ✅ CORREGIDO: Agregar child_spec
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link do
    :ignore
  end
end
