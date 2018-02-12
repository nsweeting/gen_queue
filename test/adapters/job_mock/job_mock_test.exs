defmodule GenQueue.Adapters.JobMockTest do
  use ExUnit.Case

  alias GenQueue.JobMockTest

  setup do
    JobMockTest.start_link()
    :ok
  end

  describe "push/3" do
    test "responds with a module" do
      {:ok, job} = JobMockTest.push("foo", {Bar})
      assert job == {Bar, [], %{}}
    end

    test "responds with a module and args" do
      {:ok, job} = JobMockTest.push("foo", {Bar, ["baz"]})
      assert job == {Bar, ["baz"], %{}}
    end

    test "responds with a module, args, and opts" do
      job = {Bar, ["baz"], %{delay: 10}}
      {:ok, response} = JobMockTest.push("foo", job)
      assert job == response
    end

    test "stores a job under a given queue" do
      job = {Bar, random_args(), %{delay: 10}}
      JobMockTest.push("foo", job)
      assert {:ok, response} = JobMockTest.pop("foo")
      assert job == response
    end
  end

  describe "pop/1" do
    test "returns jobs in the order they were pushed" do
      job1 = {Bar, random_args(), %{delay: 10}}
      job2 = {Bar, random_args(), %{delay: 10}}
      JobMockTest.push("foo", job1)
      JobMockTest.push("foo", job2)
      assert {:ok, response1} = JobMockTest.pop("foo")
      assert {:ok, response2} = JobMockTest.pop("foo")
      assert job1 == response1
      assert job2 == response2
    end
  end

  describe "flush/1" do
    test "removes all jobs from a queue" do
      JobMockTest.push("foo", {Bar})
      JobMockTest.push("foo", {Bar})
      assert {:ok, _} = JobMockTest.flush("foo")
      assert {:ok, nil} = JobMockTest.pop("foo")
    end

    test "returns the number of jobs removed from a queue" do
      JobMockTest.push("foo", {Bar})
      JobMockTest.push("foo", {Bar})
      assert {:ok, 2} = JobMockTest.flush("foo")
      assert {:ok, 0} = JobMockTest.flush("foo")
    end
  end

  def random_args do
    [:rand.normal() * :os.system_time(:millisecond)]
  end
end

Application.put_env(:gen_queue, Test, adapter: GenQueue.Adapters.JobMock)

defmodule GenQueue.JobMockTest do
  use GenQueue, otp_app: :gen_queue
end
