defmodule GenQueue.Adapters.SimpleTest do
  use ExUnit.Case, async: true

  defmodule Queue do
    use GenQueue
  end  

  setup do
    Queue.start_link()
    :ok
  end

  describe "push/3" do
    test "responds with the item" do
      assert {:ok, "foo"} = Queue.push("foo")
    end

    test "stores an item under a default queue" do
      Queue.push("foo")
      assert {:ok, "foo"} = Queue.pop()
    end

    test "stores an item under a given queue" do
      Queue.push("foo", [queue: :bar])
      assert {:ok, "foo"} = Queue.pop(queue: :bar)
    end
  end

  describe "pop/1" do
    test "returns items in the order they were pushed for default queues" do
      Queue.push("foo")
      Queue.push("bar")
      assert {:ok, "foo"} = Queue.pop()
      assert {:ok, "bar"} = Queue.pop()
    end

    test "returns items in the order they were pushed for provided queues" do
      Queue.push("foo", [queue: :baz])
      Queue.push("bar", [queue: :baz])
      assert {:ok, "foo"} = Queue.pop(queue: :baz)
      assert {:ok, "bar"} = Queue.pop(queue: :baz)
    end
  end

  describe "flush/1" do
    test "removes all jobs from the default queue" do
      Queue.push("foo")
      Queue.push("bar")
      assert {:ok, _} = Queue.flush()
      assert {:ok, nil} = Queue.pop()
    end

    test "removes all jobs from the provided queue" do
      Queue.push("foo", [queue: :baz])
      Queue.push("bar", [queue: :baz])
      assert {:ok, _} = Queue.flush(queue: :baz)
      assert {:ok, nil} = Queue.pop(queue: :baz)
    end

    test "returns the number of jobs removed from the default queue" do
      Queue.push("foo")
      Queue.push("bar")
      assert {:ok, 2} = Queue.flush()
      assert {:ok, 0} = Queue.flush()
    end

    test "returns the number of jobs removed from a provided queue" do
      Queue.push("foo", [queue: :baz])
      Queue.push("bar", [queue: :baz])
      assert {:ok, 2} = Queue.flush(queue: :baz)
      assert {:ok, 0} = Queue.flush(queue: :baz)
    end
  end
end
