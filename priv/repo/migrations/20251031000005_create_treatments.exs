defmodule Laura.Repo.Migrations.CreateTreatments do
  use Ecto.Migration

  def change do
    create table(:treatments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :patient_id, :binary_id, null: false
      add :medical_record_id, :binary_id
      add :staff_id, :binary_id, null: false

      # Configuración del tratamiento
      add :name, :string, null: false
      add :description, :text
      add :treatment_plan, :map, default: %{} # Estructura JSON flexible
      add :diagnosis_codes, :map, default: %{}

      # Estado y progreso
      add :status, :string, default: "active" # active, completed, cancelled, paused
      add :start_date, :date, null: false
      add :end_date, :date
      add :expected_sessions, :integer
      add :completed_sessions, :integer, default: 0

      # Metadata
      add :is_template, :boolean, default: false
      add :template_data, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create index(:treatments, [:health_brand_id])
    create index(:treatments, [:patient_id])
    create index(:treatments, [:medical_record_id])
    create index(:treatments, [:staff_id])
    create index(:treatments, [:status])
  end
end
