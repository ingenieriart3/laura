defmodule Laura.MedicalRecord.Treatment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "treatments" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :medical_record, Laura.MedicalRecord.MedicalRecord
    belongs_to :staff, Laura.Accounts.Staff

    # Configuración del tratamiento
    field :name, :string
    field :description, :string
    field :treatment_plan, :map, default: %{}
    field :diagnosis_codes, :map, default: %{}

    # Estado y progreso
    field :status, :string, default: "active"
    field :start_date, :date
    field :end_date, :date
    field :expected_sessions, :integer
    field :completed_sessions, :integer, default: 0

    # Metadata
    field :is_template, :boolean, default: false
    field :template_data, :map, default: %{}

    # Relaciones
    has_many :treatment_sessions, Laura.MedicalRecord.TreatmentSession

    timestamps(type: :naive_datetime)
  end

  def changeset(treatment, attrs) do
    treatment
    |> cast(attrs, [
      :health_brand_id, :patient_id, :medical_record_id, :staff_id,
      :name, :description, :treatment_plan, :diagnosis_codes,
      :status, :start_date, :end_date, :expected_sessions, :completed_sessions,
      :is_template, :template_data
    ])
    |> validate_required([:health_brand_id, :patient_id, :staff_id, :name, :start_date])
    |> validate_inclusion(:status, ["active", "completed", "cancelled", "paused"])
  end
end
