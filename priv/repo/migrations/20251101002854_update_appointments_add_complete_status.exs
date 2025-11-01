defmodule Laura.Repo.Migrations.UpdateAppointmentsAddCompleteStatus do
  use Ecto.Migration

  def change do
    alter table(:appointments) do
      # Agregar campos para flujo completo
      add :current_status, :string, default: "scheduled"
      add :checked_in_at, :naive_datetime
      add :consultation_started_at, :naive_datetime
      add :consultation_ended_at, :naive_datetime
      add :room_assignment, :string

      # Mejorar tipos de cita
      modify :appointment_type, :string, null: false, default: "general"

      # Campos para no-shows y cancelaciones
      add :cancellation_reason, :text
      add :cancelled_by_staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all)
      add :cancelled_at, :naive_datetime
    end

    create index(:appointments, [:current_status])
    create index(:appointments, [:checked_in_at])
    create index(:appointments, [:cancelled_at])
  end
end
