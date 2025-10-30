defmodule Laura.Accounts.StaffRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staff_roles" do
    field :name, :string
    field :permissions, :map

    timestamps(type: :naive_datetime)
  end

  def changeset(staff_role, attrs) do
    staff_role
    |> cast(attrs, [:name, :permissions])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
