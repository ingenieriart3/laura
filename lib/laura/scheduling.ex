# # lib/laura/scheduling.ex
# defmodule Laura.Scheduling do
#   def child_spec(_opts) do
#     %{
#       id: __MODULE__,
#       start: {__MODULE__, :start_link, []},
#       type: :worker,
#       restart: :permanent,
#       shutdown: 500
#     }
#   end

#   def start_link, do: :ignore
# end

defmodule Laura.Scheduling do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Scheduling.{Appointment, StaffAvailability, CheckInLog, AppointmentStatusLog}

  # Appointments
  def list_appointments(health_brand_id, filters \\ %{}) do
    query = from a in Appointment,
            where: a.health_brand_id == ^health_brand_id,
            preload: [:patient, :staff]

    query = Enum.reduce(filters, query, fn
      {:status, status}, q -> where(q, [a], a.status == ^status)
      {:date, date}, q -> where(q, [a], fragment("DATE(?) = ?", a.scheduled_for, ^date))
      {:staff_id, staff_id}, q -> where(q, [a], a.staff_id == ^staff_id)
      {:patient_id, patient_id}, q -> where(q, [a], a.patient_id == ^patient_id)
      _, q -> q
    end)

    Repo.all(query)
  end

  def get_appointment!(id), do: Repo.get!(Appointment, id)

  def create_appointment(attrs \\ %{}) do
    %Appointment{}
    |> Appointment.changeset(attrs)
    |> Repo.insert()
  end

  def update_appointment(%Appointment{} = appointment, attrs) do
    appointment
    |> Appointment.changeset(attrs)
    |> Repo.update()
  end

  def cancel_appointment(%Appointment{} = appointment) do
    appointment
    |> Appointment.changeset(%{status: "cancelled"})
    |> Repo.update()
  end

  # Staff Availability
  def list_staff_availability(health_brand_id, staff_id \\ nil) do
    query = from sa in StaffAvailability,
            where: sa.health_brand_id == ^health_brand_id and sa.is_active == true

    query = if staff_id, do: where(query, [sa], sa.staff_id == ^staff_id), else: query

    Repo.all(query)
  end

  def get_staff_availability!(id), do: Repo.get!(StaffAvailability, id)

  def create_staff_availability(attrs \\ %{}) do
    %StaffAvailability{}
    |> StaffAvailability.changeset(attrs)
    |> Repo.insert()
  end

  def update_staff_availability(%StaffAvailability{} = staff_availability, attrs) do
    staff_availability
    |> StaffAvailability.changeset(attrs)
    |> Repo.update()
  end

  # Business logic
  def get_available_slots(health_brand_id, staff_id, date) do
    # Implementar lógica de slots disponibles basada en staff_availability y appointments existentes
    # Esto es un placeholder - implementar lógica real después
    []
  end

  def has_conflicting_appointment?(health_brand_id, staff_id, scheduled_for, duration) do
    end_time = NaiveDateTime.add(scheduled_for, duration * 60)

    query = from a in Appointment,
            where: a.health_brand_id == ^health_brand_id and a.staff_id == ^staff_id,
            where: a.status in ["scheduled", "confirmed"],
            where: fragment(
              "(? <= ? AND ? > ?) OR (? < ? AND ? >= ?)",
              a.scheduled_for, ^end_time,
              a.scheduled_for, ^scheduled_for,
              fragment("? + INTERVAL '1 minute' * ?", a.scheduled_for, a.duration), ^scheduled_for,
              fragment("? + INTERVAL '1 minute' * ?", a.scheduled_for, a.duration), ^scheduled_for
            )

    Repo.exists?(query)
  end
end
