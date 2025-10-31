defmodule Laura.Messaging.MessageTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "message_templates" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :approved_by_staff, Laura.Accounts.Staff

    # Configuración de la plantilla
    field :name, :string
    field :description, :string
    field :template_type, :string
    field :channel, :string

    # Contenido de la plantilla
    field :subject, :string
    field :body, :string
    field :variables, :map, default: %{}

    # Configuración de automatización
    field :is_auto_send, :boolean, default: false
    field :trigger_event, :string
    field :send_delay_hours, :integer, default: 0

    # Aprobación y estado
    field :is_active, :boolean, default: true
    field :requires_approval, :boolean, default: false
    field :approved_at, :naive_datetime

    # Estadísticas
    field :usage_count, :integer, default: 0
    field :last_used_at, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(message_template, attrs) do
    message_template
    |> cast(attrs, [
      :health_brand_id, :approved_by_staff_id, :name, :description, :template_type, :channel,
      :subject, :body, :variables, :is_auto_send, :trigger_event, :send_delay_hours,
      :is_active, :requires_approval, :approved_at, :usage_count, :last_used_at
    ])
    |> validate_required([:health_brand_id, :name, :template_type, :channel, :body])
    |> validate_inclusion(:template_type, ["appointment_reminder", "follow_up", "marketing", "internal", "notification"])
    |> validate_inclusion(:channel, ["whatsapp", "email", "sms", "all"])
  end
end
