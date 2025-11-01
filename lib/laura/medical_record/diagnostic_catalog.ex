# lib/laura/medical_record/diagnostic_catalog.ex
defmodule Laura.MedicalRecord.DiagnosticCatalog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Laura.Platform.HealthBrand

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "diagnostic_catalogs" do
    field :code, :string
    field :description, :string
    field :category, :string
    field :is_active, :boolean, default: true
    field :metadata, :map, default: %{}

    belongs_to :health_brand, HealthBrand

    timestamps(type: :naive_datetime)
  end

  def changeset(diagnostic_catalog, attrs) do
    diagnostic_catalog
    |> cast(attrs, [:health_brand_id, :code, :description, :category, :is_active, :metadata])
    |> validate_required([:health_brand_id, :code, :description])
    |> unique_constraint([:code, :health_brand_id])
  end
end
