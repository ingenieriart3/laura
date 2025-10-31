defmodule Laura.Analytics do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Analytics.AnalyticsEvent

  def track_event(health_brand_id, event_type, event_name, event_data \\ %{}, context \\ %{}) do
    %AnalyticsEvent{}
    |> AnalyticsEvent.changeset(%{
      health_brand_id: health_brand_id,
      event_type: event_type,
      event_name: event_name,
      event_data: event_data,
      staff_id: context[:staff_id],
      patient_id: context[:patient_id],
      appointment_id: context[:appointment_id],
      invoice_id: context[:invoice_id],
      session_id: context[:session_id],
      ip_address: context[:ip_address],
      user_agent: context[:user_agent],
      url_path: context[:url_path]
    })
    |> Repo.insert()
  end

  def get_events(health_brand_id, filters \\ %{}) do
    query = from ae in AnalyticsEvent,
            where: ae.health_brand_id == ^health_brand_id,
            order_by: [desc: ae.inserted_at]

    query = Enum.reduce(filters, query, fn
      {:event_type, event_type}, q -> where(q, [ae], ae.event_type == ^event_type)
      {:start_date, start_date}, q -> where(q, [ae], ae.inserted_at >= ^start_date)
      {:end_date, end_date}, q -> where(q, [ae], ae.inserted_at <= ^end_date)
      _, q -> q
    end)

    Repo.all(query)
  end

  # Dashboard metrics
  def get_dashboard_metrics(health_brand_id, period \\ "30d") do
    # Calcular fechas según el período
    {start_date, end_date} = calculate_date_range(period)

    # Métricas básicas para el dashboard
    %{
      total_patients: count_patients(health_brand_id),
      total_appointments: count_appointments(health_brand_id, start_date, end_date),
      revenue: calculate_revenue(health_brand_id, start_date, end_date),
      appointment_conversion: calculate_appointment_conversion(health_brand_id, start_date, end_date)
    }
  end

  defp calculate_date_range("7d"), do: {NaiveDateTime.add(NaiveDateTime.utc_now(), -7 * 24 * 60 * 60), NaiveDateTime.utc_now()}
  defp calculate_date_range("30d"), do: {NaiveDateTime.add(NaiveDateTime.utc_now(), -30 * 24 * 60 * 60), NaiveDateTime.utc_now()}
  defp calculate_date_range("90d"), do: {NaiveDateTime.add(NaiveDateTime.utc_now(), -90 * 24 * 60 * 60), NaiveDateTime.utc_now()}

  defp count_patients(health_brand_id) do
    query = from p in "patients",
            where: p.health_brand_id == ^health_brand_id and p.is_active == true,
            select: count(p.id)
    Repo.one(query)
  end

  defp count_appointments(health_brand_id, start_date, end_date) do
    query = from a in "appointments",
            where: a.health_brand_id == ^health_brand_id and a.inserted_at >= ^start_date and a.inserted_at <= ^end_date,
            select: count(a.id)
    Repo.one(query)
  end

  defp calculate_revenue(health_brand_id, start_date, end_date) do
    query = from i in "invoices",
            where: i.health_brand_id == ^health_brand_id and i.status == "paid" and i.paid_at >= ^start_date and i.paid_at <= ^end_date,
            select: sum(i.total_amount)
    Repo.one(query) || Decimal.new(0)
  end

  defp calculate_appointment_conversion(health_brand_id, start_date, end_date) do
    # Lógica para calcular tasa de conversión de citas
    # Placeholder por ahora
    Decimal.new("0.75")
  end
end
