defmodule Shopper.Store do
  use GenServer

  @db_file :shopping_list_db

  def start_link(shopping_list), do: GenServer.start_link(__MODULE__, shopping_list, name: __MODULE__)

  def get, do: GenServer.call(__MODULE__, :get)

  def set(new_shopping_list), do: GenServer.cast(__MODULE__, {:set, new_shopping_list})

  def init(initial_shopping_list) do
    {:ok, table} = :dets.open_file(@db_file, [type: :set])
    shopping_list = case :dets.lookup(table, :shopping_list) do
      [shopping_list: found_shopping_list] -> found_shopping_list
      [] -> initial_shopping_list
    end

    {:ok, shopping_list}
  end

  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_cast({:set, new_shopping_list}, _current_shopping_list) do
    :dets.insert(@db_file, {:shopping_list, new_shopping_list})
    :dets.sync(@db_file)
    {:noreply, new_shopping_list}
  end

  def terminate(_reason, _state) do
    :dets.close(@db_file)
  end
end
