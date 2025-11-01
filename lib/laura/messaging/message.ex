# defmodule Laura.Messaging.Message do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "messages" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand
#     belongs_to :from_staff, Laura.Accounts.Staff
#     belongs_to :to_staff, Laura.Accounts.Staff
#     belongs_to :to_patient, Laura.Accounts.Patient
#     belongs_to :conversation, Laura.Messaging.Conversation
#     belongs_to :appointment, Laura.Scheduling.Appointment

#     # Contenido del mensaje
#     field :message_type, :string
#     field :subject, :string
#     field :body, :string
#     field :attachments, :map, default: %{}

#     # Estado y entrega
#     field :status, :string, default: "draft"
#     field :sent_at, :naive_datetime
#     field :delivered_at, :naive_datetime
#     field :read_at, :naive_datetime

#     # Metadata para mensajes externos
#     field :external_message_id, :string
#     field :delivery_status, :map, default: %{}
#     field :error_message, :string

#     # Para recordatorios automáticos
#     field :is_reminder, :boolean, default: false
#     field :reminder_template, :string

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(message, attrs) do
#     message
#     |> cast(attrs, [
#       :health_brand_id, :from_staff_id, :to_staff_id, :to_patient_id, :conversation_id, :appointment_id,
#       :message_type, :subject, :body, :attachments, :status, :sent_at, :delivered_at, :read_at,
#       :external_message_id, :delivery_status, :error_message, :is_reminder, :reminder_template
#     ])
#     |> validate_required([:health_brand_id, :message_type, :body])
#     |> validate_inclusion(:message_type, ["email", "sms", "whatsapp", "internal", "system"])
#     |> validate_inclusion(:status, ["draft", "sent", "delivered", "read", "failed"])
#   end
# end
defmodule Laura.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "messages" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :conversation, Laura.Messaging.Conversation
    belongs_to :sender, Laura.Accounts.Staff
    belongs_to :patient, Laura.Accounts.Patient

    field :content, :string
    field :message_type, :string
    field :status, :string, default: "sent"
    field :read_at, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [
      :health_brand_id,
      :conversation_id,
      :sender_id,
      :patient_id,
      :content,
      :message_type,
      :status,
      :read_at
    ])
    |> validate_required([:health_brand_id, :content, :message_type])
  end
end
