defmodule Shopper.ShoppingListTest do
  # use ExUnit.Case, async: true
  use ExUnit.Case
  alias Shopper.ShoppingList

  @single_item "coffee"
  @list_of_items ["chips", "coffee", "topo chico"]

  test "ShoppingList.new with no arguments" do
    list = ShoppingList.new()
    assert list.items == %MapSet{}, "should return an empty MapSet"
    assert list.count == 0, "count should be 0"
  end

  test "ShoppingList.new with a single item" do
    list = ShoppingList.new(@single_item)
    assert list.items == MapSet.new([@single_item]), "should be a MapSet with 1 item"
    assert list.count == 1, "count should be 1"
  end

  test "ShoppingList.new with a list of items" do
    list = ShoppingList.new(@list_of_items)
    assert list.items == MapSet.new(@list_of_items), "should be a MapSet with 3 items"
    assert list.count == 3, "count should be 3"
  end

  test "add an item to a list" do
    list = ShoppingList.new()
    new_list = ShoppingList.add(list, @single_item)
    assert new_list.count == 1
    assert MapSet.size(new_list.items) == 1
  end

  test "add multiple items to a list" do
    list = ShoppingList.new()
    new_list = ShoppingList.add(list, @list_of_items)
    assert new_list.count == 3
    assert MapSet.size(new_list.items) == 3
  end

  test "adding duplicate items to a list" do
    list = ShoppingList.new(@list_of_items)
    assert list.count == 3, "list should start with 3 items"
    new_list = ShoppingList.add(list, @single_item)
    assert new_list.count == 3, "adding a duplicate item to a list should not increase the count"
  end

  test "get info on a list" do
    list = ShoppingList.new(@list_of_items)
    info = ShoppingList.info(list)
    assert info == "- chips\n- coffee\n- topo chico"
  end
end
