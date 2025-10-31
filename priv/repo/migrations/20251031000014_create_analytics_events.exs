defmodule Laura.Repo.Migrations.CreateAnalyticsEvents do
  use Ecto.Migration

  def change do
    create table(:analytics_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Datos del evento
      add :event_type, :string, null: false # appointment_scheduled, invoice_created, patient_registered, etc.
      add :event_name, :string, null: false
      add :event_data, :map, default: %{}

      # Contexto del evento
      add :staff_id, :binary_id
      add :patient_id, :binary_id
      add :appointment_id, :binary_id
      add :invoice_id, :binary_id

      # Metadata
      add :session_id, :string
      add :ip_address, :string
      add :user_agent, :text
      add :url_path, :string

      timestamps(type: :naive_datetime)
    end

    create index(:analytics_events, [:health_brand_id])
    create index(:analytics_events, [:event_type])
    create index(:analytics_events, [:event_name])
    create index(:analytics_events, [:staff_id])
    create index(:analytics_events, [:patient_id])
    create index(:analytics_events, [:inserted_at])
  end
end
