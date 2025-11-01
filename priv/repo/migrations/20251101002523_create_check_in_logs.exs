defmodule Laura.Repo.Migrations.CreateCheckInLogs do
  use Ecto.Migration

  def change do
    create table(:check_in_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :appointment_id, references(:appointments, type: :binary_id, on_delete: :delete_all), null: false
      add :patient_id, references(:patients, type: :binary_id, on_delete: :delete_all), null: false

      # Status tracking
      add :check_in_time, :naive_datetime
      add :check_out_time, :naive_datetime
      add :initial_status, :string  # "scheduled", "confirmed"
      add :final_status, :string    # "completed", "no_show", "cancelled"

      # Staff interactions
      add :checked_in_by_staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all)
      add :checked_out_by_staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all)

      add :notes, :text
      add :metadata, :map, default: %{}  # Wait time, room assignment, etc.

      timestamps(type: :naive_datetime)
    end

    create index(:check_in_logs, [:health_brand_id])
    create index(:check_in_logs, [:appointment_id])
    create index(:check_in_logs, [:patient_id])
    create index(:check_in_logs, [:checked_in_by_staff_id])
    create index(:check_in_logs, [:checked_out_by_staff_id])
    create index(:check_in_logs, [:check_in_time])
    create index(:check_in_logs, [:final_status])
  end
end
