defmodule GenQueue.SimpleAdapterTest do
  use ExUnit.Case

  alias GenQueue.SimpleTest

  setup do
    SimpleTest.start_link()
    :ok
  end

  describe "push/3" do
    test "responds with the item" do
      assert {:ok, :bar} = SimpleTest.push("foo", :bar)
    end

    test "stores an item under a given queue" do
      SimpleTest.push("foo", :bar)
      assert {:ok, :bar} = SimpleTest.pop("foo")
    end
  end

  describe "pop/1" do
    test "returns items in the order they were pushed" do
      SimpleTest.push("foo", :bar)
      SimpleTest.push("foo", :baz)
      assert {:ok, :bar} = SimpleTest.pop("foo")
      assert {:ok, :baz} = SimpleTest.pop("foo")
    end
  end

  describe "flush/1" do
    test "removes all jobs from a queue" do
      SimpleTest.push("foo", :bar)
      SimpleTest.push("foo", :bar)
      assert {:ok, _} = SimpleTest.flush("foo")
      assert {:ok, nil} = SimpleTest.pop("foo")
    end

    test "returns the number of jobs removed from a queue" do
      SimpleTest.push("foo", :bar)
      SimpleTest.push("foo", :bar)
      assert {:ok, 2} = SimpleTest.flush("foo")
      assert {:ok, 0} = SimpleTest.flush("foo")
    end
  end
end

defmodule GenQueue.SimpleTest do
  use GenQueue
end
