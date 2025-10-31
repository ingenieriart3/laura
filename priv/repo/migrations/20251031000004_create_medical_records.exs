defmodule Laura.Repo.Migrations.CreateMedicalRecords do
  use Ecto.Migration

  def change do
    create table(:medical_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :patient_id, :binary_id, null: false
      add :appointment_id, :binary_id
      add :staff_id, :binary_id, null: false

      # Datos clínicos (estructura flexible)
      add :vital_signs, :map, default: %{}
      add :subjective, :text  # Lo que el paciente cuenta
      add :objective, :text   # Lo que el médico observa
      add :assessment, :text  # Diagnóstico/Evaluación
      add :plan, :text        # Plan de tratamiento

      # Metadata
      add :record_type, :string, null: false # consultation, follow_up, emergency, etc.
      add :is_confidential, :boolean, default: false

      timestamps(type: :naive_datetime)
    end

    create index(:medical_records, [:health_brand_id])
    create index(:medical_records, [:patient_id])
    create index(:medical_records, [:appointment_id])
    create index(:medical_records, [:staff_id])
    create index(:medical_records, [:record_type])
  end
end
