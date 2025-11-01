defmodule Laura.Repo.Migrations.CreateMedicationCatalogs do
  use Ecto.Migration

  def change do
    create table(:medication_catalogs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :generic_name, :string
      add :description, :text
      add :presentation, :string  # "tablets", "injection", "cream"
      add :standard_dosage, :string
      add :contraindications, :text
      add :interactions, :text
      add :is_active, :boolean, default: true, null: false
      add :medication_data, :map, default: %{}  # Lab, concentration, etc.

      timestamps(type: :naive_datetime)
    end

    create index(:medication_catalogs, [:health_brand_id])
    create unique_index(:medication_catalogs, [:health_brand_id, :name])
    create index(:medication_catalogs, [:generic_name])
    create index(:medication_catalogs, [:is_active])
  end
end
