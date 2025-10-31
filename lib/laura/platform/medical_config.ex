defmodule Laura.Platform.MedicalConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "medical_configs" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    # Configuraciones flexibles por tenant (JSON)
    field :treatment_categories, :map, default: %{}
    field :procedure_templates, :map, default: %{}
    field :medication_categories, :map, default: %{}
    field :diagnosis_codes, :map, default: %{}
    field :session_types, :map, default: %{}

    # Configuraciones generales
    field :appointment_duration, :integer, default: 30
    field :business_hours, :map, default: %{}
    field :reminder_settings, :map, default: %{}

    timestamps(type: :naive_datetime)
  end

  def changeset(medical_config, attrs) do
    medical_config
    |> cast(attrs, [
      :health_brand_id, :treatment_categories, :procedure_templates,
      :medication_categories, :diagnosis_codes, :session_types,
      :appointment_duration, :business_hours, :reminder_settings
    ])
    |> validate_required([:health_brand_id])
    |> unique_constraint(:health_brand_id)
  end
end
