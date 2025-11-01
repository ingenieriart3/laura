defmodule Laura.Repo.Migrations.CreateDiagnosticCatalogs do
  use Ecto.Migration

  def change do
    create table(:diagnostic_catalogs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :code, :string, null: false  # CIE-10 code like "M54.5"
      add :description, :text, null: false
      add :category, :string  # "musculoskeletal", "neurological", etc.
      add :is_active, :boolean, default: true, null: false
      add :metadata, :map, default: %{}  # Severity, common treatments, etc.

      timestamps(type: :naive_datetime)
    end

    create index(:diagnostic_catalogs, [:health_brand_id])
    create unique_index(:diagnostic_catalogs, [:health_brand_id, :code])
    create index(:diagnostic_catalogs, [:category])
    create index(:diagnostic_catalogs, [:is_active])
  end
end
