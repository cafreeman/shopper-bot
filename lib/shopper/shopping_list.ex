defmodule Shopper.ShoppingList do
  alias Shopper.ShoppingList
  @moduledoc """
  The data structure for our shopping list
  """
  defstruct [count: 0, items: %MapSet{}]

  def new(items) when is_list(items) do
    %ShoppingList{items: MapSet.new(items), count: length(items)}
  end

  def new(item) when is_binary(item) do
    %ShoppingList{items: MapSet.new([item]), count: 1}
  end

  def new() do
    %ShoppingList{}
  end

  def add(list = %ShoppingList{items: items}, new_item) when is_binary(new_item) do
    new_list = items
    |> MapSet.put(new_item)

    %{list | items: new_list, count: MapSet.size(new_list)}
  end

  def add(list = %ShoppingList{items: items}, new_items) when is_list(new_items) do
    new_list = items
    |> MapSet.union(MapSet.new(new_items))

    %{list | items: new_list, count: MapSet.size(new_list)}
  end

  def info(list = %ShoppingList{items: items}) do
    list
    |> print
  end

  defp print(%ShoppingList{items: items}) do
    items
    |> Enum.map_join("\n", fn(item) -> "- #{item}" end)
  end
end
