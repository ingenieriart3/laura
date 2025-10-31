defmodule Laura.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :staff_id, :binary_id, null: false

      # Información de la API Key
      add :name, :string, null: false
      add :key_prefix, :string, null: false
      add :key_hash, :string, null: false
      add :scopes, :map, default: %{} # Permisos: {read_patients: true, write_appointments: false}

      # Estado y seguridad
      add :is_active, :boolean, default: true
      add :last_used_at, :naive_datetime
      add :expires_at, :naive_datetime
      add :revoked_at, :naive_datetime

      # Límites y uso
      add :rate_limit, :integer, default: 1000 # requests per hour
      add :usage_count, :integer, default: 0

      timestamps(type: :naive_datetime)
    end

    create index(:api_keys, [:health_brand_id])
    create index(:api_keys, [:staff_id])
    create index(:api_keys, [:key_prefix])
    create index(:api_keys, [:key_hash])
    create index(:api_keys, [:is_active])
  end
end
