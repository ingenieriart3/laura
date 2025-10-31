defmodule Laura.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table(:appointments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :patient_id, :binary_id, null: false
      add :staff_id, :binary_id, null: false

      # Datos de la cita
      add :scheduled_for, :naive_datetime, null: false
      add :duration, :integer, null: false
      add :appointment_type, :string, null: false
      add :status, :string, default: "scheduled" # scheduled, confirmed, cancelled, completed, no_show

      # Información de la consulta
      add :reason_for_visit, :text
      add :notes, :text

      # Recordatorios
      add :reminder_sent_at, :naive_datetime
      add :confirmation_sent_at, :naive_datetime

      timestamps(type: :naive_datetime)
    end

    create index(:appointments, [:health_brand_id])
    create index(:appointments, [:patient_id])
    create index(:appointments, [:staff_id])
    create index(:appointments, [:scheduled_for])
    create index(:appointments, [:status])
  end
end
