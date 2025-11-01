defmodule Laura.Repo.Migrations.CreatePatientInsurances do
  use Ecto.Migration

  def change do
    create table(:patient_insurances, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :patient_id, references(:patients, type: :binary_id, on_delete: :delete_all), null: false
      add :insurance_provider_id, references(:insurance_providers, type: :binary_id, on_delete: :nilify_all), null: false

      add :policy_number, :string, null: false
      add :policy_holder_name, :string
      add :coverage_limits, :map, default: %{}
      add :copayment_amount, :decimal, precision: 10, scale: 2
      add :is_primary, :boolean, default: true, null: false
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:patient_insurances, [:health_brand_id])
    create index(:patient_insurances, [:patient_id])
    create index(:patient_insurances, [:insurance_provider_id])
    create unique_index(:patient_insurances, [:patient_id, :insurance_provider_id, :policy_number])
    create index(:patient_insurances, [:is_active])
  end
end
