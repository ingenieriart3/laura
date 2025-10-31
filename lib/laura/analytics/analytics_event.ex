defmodule Laura.Analytics.AnalyticsEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "analytics_events" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :staff, Laura.Accounts.Staff
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :appointment, Laura.Scheduling.Appointment
    belongs_to :invoice, Laura.Billing.Invoice

    # Datos del evento
    field :event_type, :string
    field :event_name, :string
    field :event_data, :map, default: %{}

    # Contexto del evento
    field :session_id, :string
    field :ip_address, :string
    field :user_agent, :string
    field :url_path, :string

    timestamps(type: :naive_datetime)
  end

  def changeset(analytics_event, attrs) do
    analytics_event
    |> cast(attrs, [
      :health_brand_id, :staff_id, :patient_id, :appointment_id, :invoice_id,
      :event_type, :event_name, :event_data, :session_id, :ip_address, :user_agent, :url_path
    ])
    |> validate_required([:health_brand_id, :event_type, :event_name])
  end
end
