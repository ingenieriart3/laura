defmodule Laura.Scheduling.CheckInLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "check_in_logs" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :appointment, Laura.Scheduling.Appointment
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :checked_in_by_staff, Laura.Accounts.Staff

    field :check_in_time, :naive_datetime
    field :initial_status, :string
    field :final_status, :string
    field :notes, :string

    timestamps(type: :naive_datetime)
  end

  def changeset(check_in_log, attrs) do
    check_in_log
    |> cast(attrs, [
      :health_brand_id,
      :appointment_id,
      :patient_id,
      :checked_in_by_staff_id,
      :check_in_time,
      :initial_status,
      :final_status,
      :notes
    ])
    |> validate_required([:health_brand_id, :appointment_id, :patient_id, :check_in_time])
  end
end
