# # lib/laura/medical_record/prescription.ex
# defmodule Laura.MedicalRecord.Prescription do
#   use Ecto.Schema
#   import Ecto.Changeset
#   alias Laura.{Platform.HealthBrand, Accounts.Patient, Accounts.Staff, MedicalRecord.MedicalRecord, MedicalRecord.MedicationCatalog}

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "prescriptions" do
#     field :medication_name, :string
#     field :medication_description, :string
#     field :dosage, :string
#     field :frequency, :string
#     field :duration, :string
#     field :instructions, :string
#     field :status, :string, default: "prescribed"
#     field :prescribed_at, :naive_datetime
#     field :dispensed_at, :naive_datetime
#     field :completed_at, :naive_datetime
#     field :metadata, :map, default: %{}

#     belongs_to :health_brand, HealthBrand
#     belongs_to :medical_record, MedicalRecord
#     belongs_to :patient, Patient
#     belongs_to :staff, Staff
#     belongs_to :medication_catalog, MedicationCatalog

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(prescription, attrs) do
#     prescription
#     |> cast(attrs, [
#       :health_brand_id, :medical_record_id, :patient_id, :staff_id, :medication_catalog_id,
#       :medication_name, :medication_description, :dosage, :frequency, :duration, :instructions,
#       :status, :prescribed_at, :dispensed_at, :completed_at, :metadata
#     ])
#     |> validate_required([:health_brand_id, :patient_id, :staff_id, :dosage, :frequency, :duration, :prescribed_at])
#     |> validate_inclusion(:status, ~w(prescribed dispensed completed cancelled))
#     |> assoc_constraint(:health_brand)
#     |> assoc_constraint(:patient)
#     |> assoc_constraint(:staff)
#   end
# end

defmodule Laura.MedicalRecord.Prescription do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prescriptions" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :medical_record, Laura.MedicalRecord.MedicalRecord
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :staff, Laura.Accounts.Staff
    belongs_to :medication_catalog, Laura.MedicalRecord.MedicationCatalog

    field :dosage, :string
    field :frequency, :string
    field :duration, :string
    field :instructions, :string
    field :status, :string, default: "prescribed"
    field :prescribed_at, :naive_datetime
    field :dispensed_at, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(prescription, attrs) do
    prescription
    |> cast(attrs, [
      :health_brand_id,
      :medical_record_id,
      :patient_id,
      :staff_id,
      :medication_catalog_id,
      :dosage,
      :frequency,
      :duration,
      :instructions,
      :status,
      :prescribed_at,
      :dispensed_at
    ])
    |> validate_required([:health_brand_id, :patient_id, :staff_id, :medication_catalog_id, :dosage])
  end
end
