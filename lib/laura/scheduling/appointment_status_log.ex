defmodule Laura.Scheduling.AppointmentStatusLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "appointment_status_logs" do
    belongs_to :appointment, Laura.Scheduling.Appointment
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :changed_by_staff, Laura.Accounts.Staff

    field :from_status, :string
    field :to_status, :string
    field :notes, :string

    timestamps(type: :naive_datetime)
  end

  def changeset(appointment_status_log, attrs) do
    appointment_status_log
    |> cast(attrs, [
      :appointment_id,
      :health_brand_id,
      :changed_by_staff_id,
      :from_status,
      :to_status,
      :notes
    ])
    |> validate_required([:appointment_id, :from_status, :to_status])
  end
end
