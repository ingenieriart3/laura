defmodule Laura.Repo.Migrations.CreateMedicalRecordAttachments do
  use Ecto.Migration

  def change do
    create table(:medical_record_attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :medical_record_id, references(:medical_records, type: :binary_id, on_delete: :delete_all), null: false
      add :patient_id, references(:patients, type: :binary_id, on_delete: :delete_all), null: false
      add :staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all), null: false

      add :filename, :string, null: false
      add :file_type, :string, null: false  # "pdf", "image", "lab_result"
      add :file_size, :integer  # in bytes
      add :description, :text
      add :s3_key, :string  # or similar storage reference
      add :is_archived, :boolean, default: false, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:medical_record_attachments, [:health_brand_id])
    create index(:medical_record_attachments, [:medical_record_id])
    create index(:medical_record_attachments, [:patient_id])
    create index(:medical_record_attachments, [:staff_id])
    create index(:medical_record_attachments, [:file_type])
    create index(:medical_record_attachments, [:is_archived])
  end
end
