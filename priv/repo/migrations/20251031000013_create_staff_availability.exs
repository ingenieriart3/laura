defmodule Laura.Repo.Migrations.CreateStaffAvailability do
  use Ecto.Migration

  def change do
    create table(:staff_availability, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :staff_id, :binary_id, null: false

      # Configuración de disponibilidad
      add :availability_type, :string, null: false # regular, exception, time_off
      add :day_of_week, :integer # 1-7 (lunes-domingo)
      add :specific_date, :date # Para excepciones específicas

      # Horarios
      add :start_time, :time, null: false
      add :end_time, :time, null: false
      add :slot_duration, :integer, default: 30 # duración de cada slot en minutos

      # Configuraciones adicionales
      add :appointment_types, :map, default: %{} # Tipos de cita permitidos
      add :max_patients_per_slot, :integer, default: 1
      add :is_active, :boolean, default: true

      # Para tiempo libre/vacaciones
      add :is_time_off, :boolean, default: false
      add :time_off_reason, :string
      add :recurring, :boolean, default: false # Para disponibilidad recurrente semanal

      timestamps(type: :naive_datetime)
    end

    create index(:staff_availability, [:health_brand_id])
    create index(:staff_availability, [:staff_id])
    create index(:staff_availability, [:availability_type])
    create index(:staff_availability, [:day_of_week])
    create index(:staff_availability, [:specific_date])
    create index(:staff_availability, [:is_active])
  end
end
