defmodule Laura.Messaging.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "conversations" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :patient, Laura.Accounts.Patient

    # Participantes
    field :staff_ids, :map, default: %{}

    # Metadata de la conversación
    field :title, :string
    field :conversation_type, :string
    field :last_message_at, :naive_datetime
    field :last_message_preview, :string

    # Estado
    field :is_archived, :boolean, default: false
    field :is_resolved, :boolean, default: false
    field :priority, :string, default: "normal"

    # Etiquetas y categorización
    field :tags, :map, default: %{}
    field :category, :string

    # Relaciones
    has_many :messages, Laura.Messaging.Message

    timestamps(type: :naive_datetime)
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [
      :health_brand_id, :patient_id, :staff_ids, :title, :conversation_type,
      :last_message_at, :last_message_preview, :is_archived, :is_resolved,
      :priority, :tags, :category
    ])
    |> validate_required([:health_brand_id, :patient_id, :conversation_type])
    |> validate_inclusion(:conversation_type, ["patient_staff", "internal", "broadcast"])
    |> validate_inclusion(:priority, ["low", "normal", "high", "urgent"])
  end
end
