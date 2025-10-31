defmodule Laura.MedicalRecord.MedicalRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "medical_records" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :appointment, Laura.Scheduling.Appointment
    belongs_to :staff, Laura.Accounts.Staff

    # Datos clínicos (estructura flexible)
    field :vital_signs, :map, default: %{}
    field :subjective, :string
    field :objective, :string
    field :assessment, :string
    field :plan, :string

    # Metadata
    field :record_type, :string
    field :is_confidential, :boolean, default: false

    # Relaciones
    has_many :treatments, Laura.MedicalRecord.Treatment

    timestamps(type: :naive_datetime)
  end

  def changeset(medical_record, attrs) do
    medical_record
    |> cast(attrs, [
      :health_brand_id, :patient_id, :appointment_id, :staff_id,
      :vital_signs, :subjective, :objective, :assessment, :plan,
      :record_type, :is_confidential
    ])
    |> validate_required([:health_brand_id, :patient_id, :staff_id, :record_type])
    |> validate_inclusion(:record_type, ["consultation", "follow_up", "emergency", "procedure", "lab_result"])
  end
end
