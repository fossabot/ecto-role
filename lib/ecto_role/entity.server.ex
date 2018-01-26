defmodule EctoRole.Entity.Server do

  use GenServer

  require Logger


  @moduledoc false

  alias EctoRole.Entity, as: ENTITY


  @registry_name :ecto_role_entity_registry


  defstruct key: nil,
            roles: [ ],
            permissions: [ ]


  def start_link(id) do

    name = via_tuple(id)

    GenServer.start_link(__MODULE__, [id], name: name)
  end

  defp via_tuple(id) do

    {:via, Registry, {@registry_name, id}}
  end

  def get_roles(id) do

    try do
      GenServer.call(via_tuple(id), :get_roles)
    catch
      :exit, _ -> {:error, 'invalid_entity'}
    end
  end

  def get_permissions(id) do

    try do
      GenServer.call(via_tuple(id), :get_permissions)
    catch
      :exit, _ -> {:error, 'invalid_entity'}
    end

  end

  def has_permission(key, params) do

    try do
      GenServer.call(via_tuple(key), { :has_permission,  params })
    catch
      :exit, _ -> {:error, 'invalid_entity'}
    end

  end

  def init([id]) do

    send(self(), { :setup, id })

    state = %__MODULE__{}
    {:ok, state }
  end

  def handle_info( { :setup, id }, state) do

    updated_state = case is_nil id do
      true -> state
      false -> params = %{key: id}
               record = ENTITY.get_entity(params)
               permissions = Enum.map(record.roles, fn(x) ->
                 Enum.map(x.permissions, fn(y) ->
                   y.key
                 end)
                end)

               %__MODULE__{  state |  key: id, roles: record.roles, permissions: permissions }
    end


    {:noreply, updated_state}
  end



def handle_call( { :has_permission, permission_key }, _from, %__MODULE__{ permissions: permissions } = state) do

    result = Enum.find(permissions, fn(element) -> match?(%{name: _, read: _, write: _, create: _, delete: _, key: ^permission_key}, element) end)

    reply = case result do
            nil ->  false
            _->  true
            end
    {:reply, reply, state}
  end

  @doc "queries the server for permissions"
  def handle_call(:get_permissions, _from, %__MODULE__{ permissions: permissions } = state) do


    {:reply, permissions, state}
  end

end
