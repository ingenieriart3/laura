defmodule Laura.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Configuración del webhook
      add :name, :string, null: false
      add :url, :string, null: false
      add :secret_key, :string, null: false
      add :events, :map, default: %{} # Eventos a escuchar: {appointment_created: true, invoice_paid: true}

      # Estado y configuración
      add :is_active, :boolean, default: true
      add :retry_count, :integer, default: 3
      add :timeout_ms, :integer, default: 5000

      # Estadísticas
      add :last_triggered_at, :naive_datetime
      add :success_count, :integer, default: 0
      add :failure_count, :integer, default: 0

      timestamps(type: :naive_datetime)
    end

    create index(:webhooks, [:health_brand_id])
    create index(:webhooks, [:is_active])
    create index(:webhooks, [:last_triggered_at])
  end
end
