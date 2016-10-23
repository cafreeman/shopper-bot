defmodule Shopper.ParserTest do
  use ExUnit.Case, async: true
  alias Shopper.Parser, as: Parser

  @my_id "U2QD099HS"

  test "info" do
    assert Parser.parse("<@#{@my_id}>", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>:", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>: ", @my_id) == :info
    assert Parser.parse("<@#{@my_id}> info", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>:info", @my_id) == :info
    assert Parser.parse("<@#{@my_id}>: info", @my_id) == :info
  end

  test "add" do
    assert Parser.parse("<@#{@my_id}> add", @my_id) == :add
    assert Parser.parse("<@#{@my_id}>:add", @my_id) == :add
    assert Parser.parse("<@#{@my_id}>: add", @my_id) == :add
  end

  test "add w/ items" do
    result = {:add, ["stuff", "things"]}
    assert Parser.parse("<@#{@my_id}> add stuff things", @my_id) == result
    assert Parser.parse("<@#{@my_id}>:add stuff things", @my_id) == result
    assert Parser.parse("<@#{@my_id}>: add stuff things", @my_id) == result
  end

  test "clear" do
    assert Parser.parse("<@#{@my_id}> clear", @my_id) == :clear
    assert Parser.parse("<@#{@my_id}>:clear", @my_id) == :clear
    assert Parser.parse("<@#{@my_id}>: clear", @my_id) == :clear
  end

  test "any other messages" do
    assert Parser.parse("<@#{@my_id}> rando", @my_id) == nil
    assert Parser.parse("<@#{@my_id}>: blah", @my_id) == nil
    assert Parser.parse("<@#{@my_id}>: hello!!!!!", @my_id) == nil
    assert Parser.parse("<@#{@my_id}> kjfldajflkdjaljrela", @my_id) == nil
  end
end
