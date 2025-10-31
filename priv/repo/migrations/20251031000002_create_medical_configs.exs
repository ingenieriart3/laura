defmodule Laura.Repo.Migrations.CreateMedicalConfigs do
  use Ecto.Migration

  def change do
    create table(:medical_configs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Configuraciones flexibles por tenant (JSON)
      add :treatment_categories, :map, default: %{}
      add :procedure_templates, :map, default: %{}
      add :medication_categories, :map, default: %{}
      add :diagnosis_codes, :map, default: %{}
      add :session_types, :map, default: %{}

      # Configuraciones generales
      add :appointment_duration, :integer, default: 30
      add :business_hours, :map, default: %{}
      add :reminder_settings, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create unique_index(:medical_configs, [:health_brand_id])
  end
end
