# defmodule Laura.Platform do
#   import Ecto.Query, warn: false
#   alias Laura.Repo
#   alias Laura.Platform.HealthBrand

#   def list_health_brands, do: Repo.all(HealthBrand)
#   def get_health_brand!(id), do: Repo.get!(HealthBrand, id)
#   def get_health_brand_by_subdomain(subdomain), do: Repo.get_by(HealthBrand, subdomain: subdomain)

#   def create_health_brand(attrs \\ %{}) do
#     %HealthBrand{}
#     |> HealthBrand.trial_changeset(attrs)
#     |> Repo.insert()
#   end

#   def change_health_brand(%HealthBrand{} = health_brand, attrs \\ %{}) do
#     HealthBrand.changeset(health_brand, attrs)
#   end

#   def update_health_brand(%HealthBrand{} = health_brand, attrs) do
#     health_brand
#     |> HealthBrand.changeset(attrs)
#     |> Repo.update()
#   end

#   def activate_subscription(health_brand, plan_id) do
#     health_brand
#     |> HealthBrand.changeset(%{
#       subscription_plan_id: plan_id,
#       subscription_status: "active",
#       current_period_end: NaiveDateTime.add(NaiveDateTime.utc_now(), 30 * 24 * 60 * 60)
#     })
#     |> Repo.update()
#   end

#   # Nueva función para verificar si un email ya existe globalmente
#   def email_exists?(email) do
#     query = from s in "staffs",
#             where: s.email == ^email,
#             select: fragment("1")

#     case Repo.one(query) do
#       nil -> false
#       _ -> true
#     end
#   end
# end

defmodule Laura.Platform do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Platform.{HealthBrand, MedicalConfig}

  # HealthBrand (existente + nuevas relaciones)
  def list_health_brands, do: Repo.all(HealthBrand)
  def get_health_brand!(id), do: Repo.get!(HealthBrand, id)
  def get_health_brand_by_subdomain(subdomain), do: Repo.get_by(HealthBrand, subdomain: subdomain)

  def create_health_brand(attrs \\ %{}) do
    %HealthBrand{}
    |> HealthBrand.trial_changeset(attrs)
    |> Repo.insert()
  end

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

  # MedicalConfig (NUEVO)
  def get_medical_config!(id), do: Repo.get!(MedicalConfig, id)

  def get_medical_config_by_health_brand(health_brand_id) do
    case Repo.get_by(MedicalConfig, health_brand_id: health_brand_id) do
      nil ->
        # Crear configuración por defecto si no existe
        create_default_medical_config(health_brand_id)
      config ->
        {:ok, config}
    end
  end

  defp create_default_medical_config(health_brand_id) do
    default_config = %{
      treatment_categories: %{
        "fisioterapia" => "Fisioterapia",
        "kinesiologia" => "Kinesiología",
        "rehabilitacion" => "Rehabilitación",
        "masajes" => "Masajes Terapéuticos"
      },
      procedure_templates: %{
        "evaluacion_inicial" => "Evaluación Inicial",
        "sesion_terapeutica" => "Sesión Terapéutica",
        "control_seguimiento" => "Control de Seguimiento"
      },
      appointment_duration: 30,
      business_hours: %{
        "monday" => %{start: "09:00", end: "18:00"},
        "tuesday" => %{start: "09:00", end: "18:00"},
        "wednesday" => %{start: "09:00", end: "18:00"},
        "thursday" => %{start: "09:00", end: "18:00"},
        "friday" => %{start: "09:00", end: "17:00"}
      }
    }

    create_medical_config(Map.merge(default_config, %{health_brand_id: health_brand_id}))
  end

  def create_medical_config(attrs \\ %{}) do
    %MedicalConfig{}
    |> MedicalConfig.changeset(attrs)
    |> Repo.insert()
  end

  def update_medical_config(%MedicalConfig{} = medical_config, attrs) do
    medical_config
    |> MedicalConfig.changeset(attrs)
    |> Repo.update()
  end

  # Nueva función para verificar si un email ya existe globalmente
  def email_exists?(email) do
    query = from s in "staffs",
            where: s.email == ^email,
            select: fragment("1")

    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end
end
