defmodule Namy.EntryTest do
  use ExUnit.Case

  alias Namy.Entry

  @entries [{:se, :"se@123.456.789"}, {:kth, :"kth@123.456.789"}]

  describe "lookup/2" do
    test "given a list of entries, finds the entry by its name" do
      assert {:se, :"se@123.456.789"} = Entry.lookup(:se, @entries)
    end

    test "returns unknown if there is no corresponding entries" do
      assert :unknown = Entry.lookup(:se, [])
    end
  end

  describe "add/3" do
    test "adds an entry to a list of entries" do
      updated_entries = Entry.add(:com, :"com@123.456.789", @entries)

      assert ^updated_entries = [
               {:com, :"com@123.456.789"},
               {:se, :"se@123.456.789"},
               {:kth, :"kth@123.456.789"}
             ]
    end
  end

  describe "remove/2" do
    test "removes an entry by its name from the list of entries" do
      updated_entries = Entry.remove(:se, @entries)

      assert ^updated_entries = [{:kth, :"kth@123.456.789"}]
    end
  end
end
