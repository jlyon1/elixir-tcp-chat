defmodule ElixirchatTest do
  use ExUnit.Case
  doctest Elixirchat

  test "greets the world" do
    assert Elixirchat.hello() == :world
  end
end
