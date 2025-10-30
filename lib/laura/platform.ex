defmodule Laura.Platform do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Platform.HealthBrand

  def list_health_brands, do: Repo.all(HealthBrand)
  def get_health_brand!(id), do: Repo.get!(HealthBrand, id)
  def get_health_brand_by_subdomain(subdomain), do: Repo.get_by(HealthBrand, subdomain: subdomain)

  def create_health_brand(attrs \\ %{}) do
    %HealthBrand{}
    |> HealthBrand.trial_changeset(attrs)
    |> Repo.insert()
  end

  # def change_health_brand(%HealthBrand{} = health_brand, attrs \\ %{}) do
  #   HealthBrand.registration_changeset(health_brand, attrs)
  # end

  def change_health_brand(%HealthBrand{} = health_brand, attrs \\ %{}) do
    HealthBrand.changeset(health_brand, attrs)
  end

  def update_health_brand(%HealthBrand{} = health_brand, attrs) do
    health_brand
    |> HealthBrand.changeset(attrs)
    |> Repo.update()
  end

  def activate_subscription(health_brand, plan_id) do
    health_brand
    |> HealthBrand.changeset(%{
      subscription_plan_id: plan_id,
      subscription_status: "active",
      current_period_end: NaiveDateTime.add(NaiveDateTime.utc_now(), 30 * 24 * 60 * 60)
    })
    |> Repo.update()
  end
end
