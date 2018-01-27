defmodule EctoRole.Filter.Supervisor do
  use Supervisor

  require Logger

  @moduledoc false

  @registry_name :ecto_role_filter_registry

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Start a filter server.
  ## Examples
      iex> EctoRole.filter.Supervisor.start("xxx")
      "%{}"
  """
  def start(id) do
    Supervisor.start_child(__MODULE__, [id])
  end

  @doc """
  Stop the EctoRole server.
  ## Examples
      iex> EctoRole.filter.Supervisor.stop("xxx")
      ":ok"
  """
  def stop(id) do
    case Registry.lookup(@registry_name, id) do
      [] ->
        :ok

      [{pid, _}] ->
        Process.exit(pid, :shutdown)
        :ok
    end
  end

  def init(_) do
    children = [worker(EctoRole.filter().Server, [], restart: :transient)]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Create a new process if it doesnt exist else return the process.
  ## Examples
      iex> EctoRole.filter.Supervisor.find_or_create_process("xxx")
      "{}"
  """
  def find_or_create_process(id) do
    if process_exists?(id) do
      {:ok, id}
    else
      id |> start
    end
  end

  @doc """
  Check if process exists.
  ## Examples
      iex> EctoRole.filter.Supervisor.process_exists("xxx")
      "true"
  """
  def process_exists?(id) do
    case Registry.lookup(@registry_name, id) do
      [] -> false
      _ -> true
    end
  end

  @doc """
  Get the ids of all processes in the registry.
  ## Examples
      iex> EctoRole.filter.Supervisor.key_ids("xxx")
      "[]"
  """
  def key_ids do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, account_proc_pid, _, _} ->
      Registry.keys(@registry_name, account_proc_pid)
      |> List.first()
    end)
    |> Enum.sort()
  end
end