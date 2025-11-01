# # lib/laura/medical_record/treatment_protocol.ex
# defmodule Laura.MedicalRecord.TreatmentProtocol do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "treatment_protocols" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand
#     belongs_to :diagnostic_catalog, Laura.MedicalRecord.DiagnosticCatalog

#     field :name, :string
#     field :description, :string
#     field :expected_sessions, :integer
#     field :session_duration, :integer
#     field :frequency, :string
#     field :protocol_steps, :map, default: %{}
#     field :medication_recommendations, :map, default: %{}
#     field :is_active, :boolean, default: true

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(treatment_protocol, attrs) do
#     treatment_protocol
#     |> cast(attrs, [
#       :health_brand_id,
#       :diagnostic_catalog_id,
#       :name,
#       :description,
#       :expected_sessions,
#       :session_duration,
#       :frequency,
#       :protocol_steps,
#       :medication_recommendations,
#       :is_active
#     ])
#     |> validate_required([:health_brand_id, :name, :expected_sessions])
#     |> validate_number(:expected_sessions, greater_than: 0)
#     |> validate_number(:session_duration, greater_than: 0)
#     |> validate_inclusion(:frequency, ["daily", "twice_weekly", "weekly", "biweekly", "monthly"])
#   end
# end

defmodule Laura.MedicalRecord.TreatmentProtocol do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "treatment_protocols" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :diagnostic_catalog, Laura.MedicalRecord.DiagnosticCatalog

    field :name, :string
    field :description, :string
    field :expected_sessions, :integer
    field :session_duration, :integer
    field :frequency, :string
    field :protocol_steps, :map, default: %{}
    field :medication_recommendations, :map, default: %{}
    field :is_active, :boolean, default: true

    timestamps(type: :naive_datetime)
  end

  def changeset(treatment_protocol, attrs) do
    treatment_protocol
    |> cast(attrs, [
      :health_brand_id,
      :diagnostic_catalog_id,
      :name,
      :description,
      :expected_sessions,
      :session_duration,
      :frequency,
      :protocol_steps,
      :medication_recommendations,
      :is_active
    ])
    |> validate_required([:health_brand_id, :name, :expected_sessions])
  end
end
