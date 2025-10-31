defmodule Laura.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Datos personales
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string
      add :phone, :string
      add :birth_date, :date
      add :gender, :string
      add :national_id, :string

      # Dirección
      add :address, :text
      add :city, :string
      add :state, :string
      add :zip_code, :string

      # Contacto de emergencia
      add :emergency_contact_name, :string
      add :emergency_contact_phone, :string
      add :emergency_contact_relation, :string

      # Información médica base
      add :blood_type, :string
      add :allergies, :text
      add :current_medications, :text
      add :medical_conditions, :text

      # Metadata
      add :is_active, :boolean, default: true
      add :notes, :text

      timestamps(type: :naive_datetime)
    end

    create index(:patients, [:health_brand_id])
    create index(:patients, [:email, :health_brand_id])
    create index(:patients, [:phone, :health_brand_id])
    create unique_index(:patients, [:national_id, :health_brand_id])
  end
end
