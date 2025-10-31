defmodule Laura.Inventory do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Inventory.{Inventory, InventoryTransaction}

  # Inventory Items
  def list_inventory(health_brand_id, filters \\ %{}) do
    query = from i in Inventory,
            where: i.health_brand_id == ^health_brand_id

    query = Enum.reduce(filters, query, fn
      {:category, category}, q -> where(q, [i], i.category == ^category)
      {:item_type, item_type}, q -> where(q, [i], i.item_type == ^item_type)
      {:is_active, is_active}, q -> where(q, [i], i.is_active == ^is_active)
      {:reorder_needed, reorder_needed}, q -> where(q, [i], i.reorder_needed == ^reorder_needed)
      _, q -> q
    end)

    Repo.all(query)
  end

  def get_inventory!(id), do: Repo.get!(Inventory, id)

  def create_inventory(attrs \\ %{}) do
    %Inventory{}
    |> Inventory.changeset(attrs)
    |> Repo.insert()
  end

  def update_inventory(%Inventory{} = inventory, attrs) do
    inventory
    |> Inventory.changeset(attrs)
    |> Repo.update()
  end

    # En lib/laura/inventory.ex - corregir esta función:
  def update_stock(%Inventory{} = inventory, quantity_change, transaction_type) do
    new_stock = inventory.current_stock + quantity_change

    changeset = inventory
    |> Inventory.changeset(%{
      current_stock: new_stock,
      reorder_needed: new_stock <= inventory.min_stock
    })

    case Repo.update(changeset) do
      {:ok, updated_inventory} ->
        # Crear transacción de inventario
        create_inventory_transaction(%{
          health_brand_id: inventory.health_brand_id,
          inventory_id: inventory.id,
          transaction_type: transaction_type,
          quantity: abs(quantity_change),
          unit_cost: inventory.unit_cost,
          total_cost: if inventory.unit_cost do
            # Convertir a Decimal y multiplicar
            Decimal.mult(inventory.unit_cost, Decimal.new(abs(quantity_change)))
          else
            Decimal.new(0)
          end,
          transaction_date: NaiveDateTime.utc_now()
        })
        {:ok, updated_inventory}
      error -> error
    end
  end

  # Inventory Transactions
  def list_inventory_transactions(health_brand_id, inventory_id \\ nil) do
    query = from it in InventoryTransaction,
            where: it.health_brand_id == ^health_brand_id,
            order_by: [desc: it.transaction_date],
            preload: [:inventory, :staff, :treatment_session]

    query = if inventory_id, do: where(query, [it], it.inventory_id == ^inventory_id), else: query

    Repo.all(query)
  end

  def create_inventory_transaction(attrs \\ %{}) do
    %InventoryTransaction{}
    |> InventoryTransaction.changeset(attrs)
    |> Repo.insert()
  end

  # Business logic
  def get_low_stock_items(health_brand_id) do
    query = from i in Inventory,
            where: i.health_brand_id == ^health_brand_id and i.is_active == true,
            where: i.current_stock <= i.min_stock

    Repo.all(query)
  end

  def get_inventory_summary(health_brand_id) do
    query = from i in Inventory,
            where: i.health_brand_id == ^health_brand_id and i.is_active == true,
            select: %{
              total_items: count(i.id),
              low_stock_count: fragment("COUNT(CASE WHEN current_stock <= min_stock THEN 1 END)"),
              total_inventory_value: fragment("SUM(COALESCE(current_stock * unit_cost, 0))")
            }

    Repo.one(query)
  end
end
