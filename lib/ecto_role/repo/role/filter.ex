defmodule EctoRole.Filter do
  @moduledoc """
    filter: Represents the filters on a schema
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias EctoRole.Filter, as: FILTER
  alias EctoRole.Role, as: ROLE
  alias EctoRole.Schema, as: SCHEMA
  alias EctoRole.Filter.Role, as: FR

  alias EctoRole.Repo, as: Repo

  schema "er_filter" do
    field(:name, :string)
    field(:read, :string)
    field(:write, :string)
    field(:create, :boolean)
    field(:delete, :boolean)
    field(:key, :string)

    belongs_to(:schema, SCHEMA)

    many_to_many(
      :roles,
      ROLE,
      join_through: FR,
      join_keys: [filter_key: :key, role_key: :key]
    )

    timestamps()
  end

  @params ~w(name read write create delete key schema_id)a
  @required_fields ~w(name)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required_fields)
    |> generate_uuid()
  end

  @doc """
  Fetch the Complete Permsission set by schema
  """
  @spec get_filters(Map.t()) :: Map.t()
  def get_filters(%{key: value}) do
    record = Repo.get_by!(FILTER, key: value) |> Repo.preload(:schema)
    record
  end

  @doc """
  Fetch the Complete Permsission set by schema
  """
  @spec get_filters(Map.t()) :: Map.t()
  def get_filters(%{name: value}) do
    record = Repo.get_by!(FILTER, name: value) |> Repo.preload(:schema)
    record
  end

  @doc """
  delete filter from the list of filters
  """
  def delete(filter) when is_map(filter), do: delete(filter)

  def delete(filter) do
    from(x in FILTER, where: x.key == ^filter) |> Repo.delete_all()
  end

  @doc """
  delete all from the list of filters
  """
  def delete_all(filters) when is_list(filters), do: delete_all(filters)

  def delete_all(filters) do
    Enum.each(filters, fn p ->
      from(x in FILTER, where: x.key == ^p) |> Repo.delete_all()
    end)
  end

  @doc """
  create a new filter
  """
  def new(attrs \\ %{}) do
    FILTER
    |> FILTER.changeset(attrs)
    |> Repo.insert()
  end

  defp generate_uuid(changeset) do
    uuid = Ecto.UUID.generate()

    changeset
    |> put_change(:key, uuid)
  end
end