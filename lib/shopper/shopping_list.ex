defmodule Shopper.ShoppingList do
  alias Shopper.ShoppingList
  @moduledoc """
  The data structure for our shopping list
  """
  @type t :: %ShoppingList{count: integer, items: MapSet.t}
  defstruct count: 0, items: %MapSet{}

  ##### Constructor #####

  @spec new([String.t]) :: ShoppingList.t
  def new(items) when is_list(items) do
    %ShoppingList{items: MapSet.new(items), count: length(items)}
  end

  @spec new(String.t) :: ShoppingList.t
  def new(item) when is_binary(item) do
    %ShoppingList{items: MapSet.new([item]), count: 1}
  end

  @spec new() :: ShoppingList.t
  def new() do
    %ShoppingList{}
  end

  ##### ADD #####

  @spec add(ShoppingList.t, String.t) :: ShoppingList.t
  def add(list = %ShoppingList{items: items}, new_item) when is_binary(new_item) do
    new_list = items
    |> MapSet.put(new_item)

    %{list | items: new_list, count: MapSet.size(new_list)}
  end

  @spec add(ShoppingList.t, [String.t]) :: ShoppingList.t
  def add(list = %ShoppingList{items: items}, new_items) when is_list(new_items) do
    new_list = items
    |> MapSet.union(MapSet.new(new_items))

    %{list | items: new_list, count: MapSet.size(new_list)}
  end

  ##### INFO #####

  @spec info(ShoppingList.t) :: String.t
  def info(list = %ShoppingList{}) do
    list
    |> print
  end

  @spec print(ShoppingList.t) :: String.t
  defp print(%ShoppingList{items: items}) do
    case Enum.empty?(items) do
      true -> "There are no items in your shopping list!"
      false -> items |> Enum.map_join("\n", fn(item) -> "- #{item}" end)
    end
  end
end
