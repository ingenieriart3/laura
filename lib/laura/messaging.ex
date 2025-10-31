# # lib/laura/messaging.ex
# defmodule Laura.Messaging do
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
defmodule Laura.Messaging do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Messaging.{Message, Conversation, MessageTemplate}

  # Messages
  def list_messages(health_brand_id, filters \\ %{}) do
    query = from m in Message,
            where: m.health_brand_id == ^health_brand_id,
            order_by: [desc: m.inserted_at],
            preload: [:from_staff, :to_staff, :to_patient, :conversation]

    query = Enum.reduce(filters, query, fn
      {:conversation_id, conversation_id}, q -> where(q, [m], m.conversation_id == ^conversation_id)
      {:message_type, message_type}, q -> where(q, [m], m.message_type == ^message_type)
      {:status, status}, q -> where(q, [m], m.status == ^status)
      {:is_reminder, is_reminder}, q -> where(q, [m], m.is_reminder == ^is_reminder)
      _, q -> q
    end)

    Repo.all(query)
  end

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def send_message(%Message{} = message) do
    # Aquí iría la lógica real de envío (WhatsApp, Email, SMS)
    # Por ahora solo marcamos como enviado
    message
    |> Message.changeset(%{
      status: "sent",
      sent_at: NaiveDateTime.utc_now()
    })
    |> Repo.update()
  end

  # Conversations
  def list_conversations(health_brand_id, filters \\ %{}) do
    query = from c in Conversation,
            where: c.health_brand_id == ^health_brand_id,
            order_by: [desc: c.last_message_at],
            preload: [:patient]

    query = Enum.reduce(filters, query, fn
      {:patient_id, patient_id}, q -> where(q, [c], c.patient_id == ^patient_id)
      {:conversation_type, conversation_type}, q -> where(q, [c], c.conversation_type == ^conversation_type)
      {:is_archived, is_archived}, q -> where(q, [c], c.is_archived == ^is_archived)
      {:is_resolved, is_resolved}, q -> where(q, [c], c.is_resolved == ^is_resolved)
      _, q -> q
    end)

    Repo.all(query)
  end

  def get_conversation!(id), do: Repo.get!(Conversation, id)

  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  def get_or_create_patient_conversation(health_brand_id, patient_id, staff_ids) do
    case Repo.get_by(Conversation, health_brand_id: health_brand_id, patient_id: patient_id, conversation_type: "patient_staff") do
      nil ->
        create_conversation(%{
          health_brand_id: health_brand_id,
          patient_id: patient_id,
          staff_ids: Enum.into(staff_ids, %{}, &{&1, true}),
          conversation_type: "patient_staff",
          title: "Conversación con paciente"
        })
      conversation ->
        {:ok, conversation}
    end
  end

  # Message Templates
  def list_message_templates(health_brand_id, filters \\ %{}) do
    query = from mt in MessageTemplate,
            where: mt.health_brand_id == ^health_brand_id and mt.is_active == true

    query = Enum.reduce(filters, query, fn
      {:template_type, template_type}, q -> where(q, [mt], mt.template_type == ^template_type)
      {:channel, channel}, q -> where(q, [mt], mt.channel == ^channel)
      _, q -> q
    end)

    Repo.all(query)
  end

  def get_message_template!(id), do: Repo.get!(MessageTemplate, id)

  def create_message_template(attrs \\ %{}) do
    %MessageTemplate{}
    |> MessageTemplate.changeset(attrs)
    |> Repo.insert()
  end

  def update_message_template(%MessageTemplate{} = message_template, attrs) do
    message_template
    |> MessageTemplate.changeset(attrs)
    |> Repo.update()
  end

  # Business logic
  def send_appointment_reminder(appointment_id) do
    # Lógica para enviar recordatorios de citas
    # Esto se integraría con un job scheduler en producción
    {:ok, :reminder_scheduled}
  end
end
