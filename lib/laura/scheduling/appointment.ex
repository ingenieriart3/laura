defmodule Laura.Scheduling.Appointment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "appointments" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :staff, Laura.Accounts.Staff

    # Datos de la cita
    field :scheduled_for, :naive_datetime
    field :duration, :integer
    field :appointment_type, :string
    field :status, :string, default: "scheduled"

    # Información de la consulta
    field :reason_for_visit, :string
    field :notes, :string

    # Recordatorios
    field :reminder_sent_at, :naive_datetime
    field :confirmation_sent_at, :naive_datetime

    # Relaciones
    has_one :medical_record, Laura.MedicalRecord.MedicalRecord
    has_one :invoice, Laura.Billing.Invoice
    has_many :messages, Laura.Messaging.Message

    timestamps(type: :naive_datetime)
  end

  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, [
      :health_brand_id, :patient_id, :staff_id, :scheduled_for, :duration,
      :appointment_type, :status, :reason_for_visit, :notes,
      :reminder_sent_at, :confirmation_sent_at
    ])
    |> validate_required([:health_brand_id, :patient_id, :staff_id, :scheduled_for, :duration, :appointment_type])
    |> validate_inclusion(:status, ["scheduled", "confirmed", "cancelled", "completed", "no_show"])
  end
end
