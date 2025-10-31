defmodule Laura.Scheduling.StaffAvailability do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staff_availability" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :staff, Laura.Accounts.Staff

    # Configuración de disponibilidad
    field :availability_type, :string
    field :day_of_week, :integer
    field :specific_date, :date

    # Horarios
    field :start_time, :time
    field :end_time, :time
    field :slot_duration, :integer, default: 30

    # Configuraciones adicionales
    field :appointment_types, :map, default: %{}
    field :max_patients_per_slot, :integer, default: 1
    field :is_active, :boolean, default: true

    # Para tiempo libre/vacaciones
    field :is_time_off, :boolean, default: false
    field :time_off_reason, :string
    field :recurring, :boolean, default: false

    timestamps(type: :naive_datetime)
  end

  def changeset(staff_availability, attrs) do
    staff_availability
    |> cast(attrs, [
      :health_brand_id, :staff_id, :availability_type, :day_of_week,
      :specific_date, :start_time, :end_time, :slot_duration,
      :appointment_types, :max_patients_per_slot, :is_active,
      :is_time_off, :time_off_reason, :recurring
    ])
    |> validate_required([:health_brand_id, :staff_id, :availability_type, :start_time, :end_time])
    |> validate_inclusion(:availability_type, ["regular", "exception", "time_off"])
    |> validate_number(:day_of_week, greater_than_or_equal_to: 1, less_than_or_equal_to: 7)
  end
end
