defmodule GenQueue.Adapters.MockTest do
  use ExUnit.Case

  setup do
    GenQueue.MockTest.start_link()
    :ok
  end

  describe "push/3" do
    test "responds with a module" do
      {:ok, job} = GenQueue.MockTest.push(Foo)
      assert job.module == Foo
    end

    test "responds with a module and args" do
      {:ok, job} = GenQueue.MockTest.push(Foo, ["bar"])
      assert job.args == ["bar"]
    end

    test "responds with a module, args, and opts" do
      {:ok, job} = GenQueue.MockTest.push(Foo, ["bar"], %{queue: "baz"})
      assert job.opts == %{queue: "baz"}
    end

    test "assigns a default queue if none is given" do
      {:ok, job} = GenQueue.MockTest.push(Foo)
      assert job.opts == %{queue: "default"}
    end

    test "stores a job under a default queue" do
      args = random_args()
      GenQueue.MockTest.push(Foo, args)
      assert {:ok, job} = GenQueue.MockTest.pop("default")
      assert job.args == args
    end

    test "stores a job under a given queue" do
      args = random_args()
      GenQueue.MockTest.push(Foo, args, %{queue: "baz"})
      assert {:ok, job} = GenQueue.MockTest.pop("baz")
      assert job.args == args
    end
  end

  describe "pop/1" do
    test "returns jobs in the order they were pushed" do
      args1 = random_args()
      args2 = random_args()
      GenQueue.MockTest.push(Foo, args1, %{queue: "baz"})
      GenQueue.MockTest.push(Foo, args2, %{queue: "baz"})
      assert {:ok, job1} = GenQueue.MockTest.pop("baz")
      assert {:ok, job2} = GenQueue.MockTest.pop("baz")
      assert job1.args == args1
      assert job2.args == args2
    end
  end

  describe "flush/1" do
    test "removes all jobs from a queue" do
      GenQueue.MockTest.push(Foo, random_args(), %{queue: "baz"})
      GenQueue.MockTest.push(Foo, random_args(), %{queue: "baz"})
      assert {:ok, _} = GenQueue.MockTest.flush("baz")
      assert {:ok, nil} = GenQueue.MockTest.pop("baz")
    end

    test "returns the number of jobs removed from a queue" do
      GenQueue.MockTest.push(Foo, random_args(), %{queue: "baz"})
      GenQueue.MockTest.push(Foo, random_args(), %{queue: "baz"})
      assert {:ok, 2} = GenQueue.MockTest.flush("baz")
      assert {:ok, 0} = GenQueue.MockTest.flush("baz")
    end
  end

  def random_args do
    [:rand.normal() * :os.system_time(:millisecond)]
  end
end

Application.put_env(:gen_queue, GenQueue.MockTest, adapter: GenQueue.Adapters.Mock)

defmodule GenQueue.MockTest do
  use GenQueue, otp_app: :gen_queue
end
