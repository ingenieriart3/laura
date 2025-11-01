defmodule Laura.Accounts.StaffRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Laura.Accounts.Staff

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staff_roles" do
    field :name, :string
    field :permissions, :map, default: %{}
    field :role_type, :string, default: "clinical"
    field :is_system_role, :boolean, default: false

    has_many :staffs, Staff

    timestamps(type: :naive_datetime)

  end

  @doc false
  def changeset(staff_role, attrs) do
    staff_role
    |> cast(attrs, [:name, :permissions, :role_type, :is_system_role])
    |> validate_required([:name, :permissions])
    |> unique_constraint(:name)
  end
end
