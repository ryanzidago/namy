defmodule NamyTest do
  use ExUnit.Case
  doctest Namy

  test "greets the world" do
    assert Namy.hello() == :world
  end
end
