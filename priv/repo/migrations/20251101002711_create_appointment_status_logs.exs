defmodule Laura.Repo.Migrations.CreateAppointmentStatusLogs do
  use Ecto.Migration

  def change do
    create table(:appointment_status_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :appointment_id, references(:appointments, type: :binary_id, on_delete: :delete_all), null: false
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :from_status, :string
      add :to_status, :string, null: false
      add :changed_by_staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all)
      add :notes, :text
      add :metadata, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create index(:appointment_status_logs, [:appointment_id])
    create index(:appointment_status_logs, [:health_brand_id])
    create index(:appointment_status_logs, [:changed_by_staff_id])
    create index(:appointment_status_logs, [:to_status])
    create index(:appointment_status_logs, [:inserted_at])
  end
end
