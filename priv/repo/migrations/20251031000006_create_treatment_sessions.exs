defmodule Laura.Repo.Migrations.CreateTreatmentSessions do
  use Ecto.Migration

  def change do
    create table(:treatment_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :treatment_id, :binary_id, null: false
      add :patient_id, :binary_id, null: false
      add :staff_id, :binary_id, null: false

      # Datos de la sesión
      add :session_date, :naive_datetime, null: false
      add :session_type, :string, null: false
      add :session_number, :integer, null: false
      add :duration, :integer, null: false

      # Procedimientos realizados (JSON flexible)
      add :procedures_performed, :map, default: %{}
      add :medications_administered, :map, default: %{}
      add :equipment_used, :map, default: %{}

      # Evaluación de la sesión
      add :subjective_feedback, :text
      add :objective_measures, :map, default: %{}
      add :therapist_notes, :text
      add :patient_progress, :string # excellent, good, fair, poor

      # Estado
      add :status, :string, default: "completed" # scheduled, in_progress, completed, cancelled

      timestamps(type: :naive_datetime)
    end

    create index(:treatment_sessions, [:health_brand_id])
    create index(:treatment_sessions, [:treatment_id])
    create index(:treatment_sessions, [:patient_id])
    create index(:treatment_sessions, [:staff_id])
    create index(:treatment_sessions, [:session_date])
  end
end
