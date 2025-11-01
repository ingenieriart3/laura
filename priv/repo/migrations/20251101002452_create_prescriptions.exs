defmodule Laura.Repo.Migrations.CreatePrescriptions do
  use Ecto.Migration

  def change do
    create table(:prescriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :medical_record_id, references(:medical_records, type: :binary_id, on_delete: :delete_all)
      add :patient_id, references(:patients, type: :binary_id, on_delete: :delete_all), null: false
      add :staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all), null: false
      add :medication_catalog_id, references(:medication_catalogs, type: :binary_id, on_delete: :nilify_all)

      # Custom medication if not in catalog
      add :medication_name, :string
      add :medication_description, :text

      # Prescription details
      add :dosage, :string, null: false  # "500mg", "10ml"
      add :frequency, :string, null: false  # "every 8 hours", "twice daily"
      add :duration, :string, null: false  # "7 days", "until finished"
      add :instructions, :text  # "Take with food", etc.

      # Status tracking
      add :status, :string, null: false, default: "prescribed"  # prescribed, dispensed, completed, cancelled
      add :prescribed_at, :naive_datetime, null: false
      add :dispensed_at, :naive_datetime
      add :completed_at, :naive_datetime

      add :metadata, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create index(:prescriptions, [:health_brand_id])
    create index(:prescriptions, [:medical_record_id])
    create index(:prescriptions, [:patient_id])
    create index(:prescriptions, [:staff_id])
    create index(:prescriptions, [:medication_catalog_id])
    create index(:prescriptions, [:status])
    create index(:prescriptions, [:prescribed_at])
  end
end
