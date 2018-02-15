defmodule GenQueue.TestTest do
  use ExUnit.Case

  import GenQueue.Test

  defmodule Adapter do
    use GenQueue.Adapter

    def handle_push(gen_queue, item, _opts) do
      GenQueue.Test.send_item(gen_queue, item)
    end
  end

  defmodule Queue do
    Application.put_env(:gen_queue, __MODULE__, adapter: GenQueue.TestTest.Adapter)

    use GenQueue, otp_app: :gen_queue
  end

  describe "setup_test_queue/1" do
    test "will return the item back to the current process" do
      setup_test_queue(Queue)
      Queue.push(:foo)
      assert_receive(:foo)
    end
  end

  describe "setup_global_test_queue/2" do
    test "will name the current process" do
      setup_global_test_queue(Queue, :test)
      assert self() == Process.whereis(:test)
    end

    test "will return the item back to the named process" do
      setup_global_test_queue(Queue, :test)
      Queue.push(:foo)
      assert_receive(:foo)
    end
  end

  describe "reset_test_queue/1" do
    test "will remove any current return processes" do
      setup_test_queue(Queue)
      Queue.push(:foo)
      assert_receive(:foo)

      reset_test_queue(Queue)
      Queue.push(:foo)

      assert {:message_queue_len, 0} = Process.info(self(), :message_queue_len)
    end
  end
end
