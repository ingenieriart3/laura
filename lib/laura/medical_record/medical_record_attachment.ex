defmodule Laura.MedicalRecord.MedicalRecordAttachment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "medical_record_attachments" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :medical_record, Laura.MedicalRecord.MedicalRecord
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :staff, Laura.Accounts.Staff

    field :filename, :string
    field :file_type, :string
    field :file_size, :integer
    field :description, :string
    field :s3_key, :string
    field :is_archived, :boolean, default: false

    timestamps(type: :naive_datetime)
  end

  def changeset(medical_record_attachment, attrs) do
    medical_record_attachment
    |> cast(attrs, [
      :health_brand_id,
      :medical_record_id,
      :patient_id,
      :staff_id,
      :filename,
      :file_type,
      :file_size,
      :description,
      :s3_key,
      :is_archived
    ])
    |> validate_required([:health_brand_id, :patient_id, :filename, :file_type])
  end
end
