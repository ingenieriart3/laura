# lib/laura/medical_record/medication_catalog.ex
defmodule Laura.MedicalRecord.MedicationCatalog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Laura.Platform.HealthBrand

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "medication_catalogs" do
    field :name, :string
    field :generic_name, :string
    field :description, :string
    field :presentation, :string
    field :standard_dosage, :string
    field :contraindications, :string
    field :interactions, :string
    field :is_active, :boolean, default: true
    field :medication_data, :map, default: %{}

    belongs_to :health_brand, HealthBrand

    timestamps(type: :naive_datetime)
  end

  def changeset(medication_catalog, attrs) do
    medication_catalog
    |> cast(attrs, [
      :health_brand_id, :name, :generic_name, :description, :presentation,
      :standard_dosage, :contraindications, :interactions, :is_active, :medication_data
    ])
    |> validate_required([:health_brand_id, :name])
    |> unique_constraint([:name, :health_brand_id])
  end
end
