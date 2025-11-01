defmodule Laura.Repo.Migrations.CreateInsuranceProviders do
  use Ecto.Migration

  def change do
    create table(:insurance_providers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :contact_info, :map, default: %{}
      add :coverage_details, :map, default: %{}
      add :authorization_required, :boolean, default: false, null: false
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:insurance_providers, [:health_brand_id])
    create unique_index(:insurance_providers, [:health_brand_id, :name])
    create index(:insurance_providers, [:is_active])
  end
end
