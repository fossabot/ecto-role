defmodule EctoRole.Schema.Server do

  use GenServer

  require Logger

  @moduledoc "A Simple Server to Store Your Schemas."

  alias EctoRole.Schema


  @registry_name :ecto_schema_registry
  @name __MODULE__

  defstruct fields: [ ]


  def start_link(id) do

    name = via_tuple(id)

    GenServer.start_link(__MODULE__, [id], name: name)
  end

  defp via_tuple(id) do

    {:via, Registry, {@registry_name, id}}
  end


  def init([id]) do

    send(self(), { :setup, id })

    state = %__MODULE__{}
    {:ok, state }
  end

  def get_schema(id) do

    try do
      GenServer.call(via_tuple(id), :get_schema)
    catch
      :exit, msg -> {:error, 'invalid_schema'}
    end
  end

  def handle_info( { :setup, id }, state) do

    updated_state = case is_nil id do
      true -> state
      false -> params = %{key: id}
               record = Schema.get_schema(params)

               fields = []

               %__MODULE__{  state | fields: fields}
    end


    {:noreply, updated_state}
  end


  @doc "queries the server for permissions"
  def handle_call(:get_schema, _from, %__MODULE__{ fields: fields } = state) do


    {:reply, fields, state}
  end

end