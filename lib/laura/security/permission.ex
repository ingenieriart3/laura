defmodule Laura.Security.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    belongs_to :staff_role, Laura.Accounts.StaffRole

    field :module, :string
    field :action, :string
    field :scope, :string

    timestamps(type: :naive_datetime)
  end

  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [
      :staff_role_id,
      :module,
      :action,
      :scope
    ])
    |> validate_required([:staff_role_id, :module, :action])
  end
end
