defmodule Laura.Repo.Migrations.CreateTreatmentProtocols do
  use Ecto.Migration

  def change do
    create table(:treatment_protocols, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :diagnostic_catalog_id, references(:diagnostic_catalogs, type: :binary_id, on_delete: :nilify_all)
      add :name, :string, null: false
      add :description, :text
      add :expected_sessions, :integer
      add :session_duration, :integer  # in minutes
      add :frequency, :string  # "weekly", "twice_weekly", "daily"
      add :protocol_steps, :map, default: %{}  # Structured treatment steps
      add :medication_recommendations, :map, default: %{}  # Suggested medications
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:treatment_protocols, [:health_brand_id])
    create index(:treatment_protocols, [:diagnostic_catalog_id])
    create index(:treatment_protocols, [:is_active])
  end
end
