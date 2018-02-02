defmodule GenQueueTest do
  use ExUnit.Case

  alias GenQueue.Job

  setup do
    TestEnqueuer.start_link()
    :ok
  end

  test "wip test" do
    TestEnqueuer.push(Test, [], [queue: "test"])
    assert {:ok, %Job{module: Test, args: [], opts: [queue: "test"]}} = TestEnqueuer.pop(queue: "test")
  end
end

Application.put_env(:gen_queue, TestEnqueuer, adapter: GenQueue.MockAdapter)

defmodule TestEnqueuer do
  use GenQueue, otp_app: :gen_queue
end
