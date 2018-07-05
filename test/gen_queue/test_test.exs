defmodule GenQueue.TestTest do
  use ExUnit.Case

  import GenQueue.Test

  defmodule Adapter do
    use GenQueue.Adapter

    def handle_push(gen_queue, item, _opts) do
      GenQueue.Test.send_item(gen_queue, item)
    end
  end

  defmodule AppQueue do
    Application.put_env(:gen_queue, __MODULE__, adapter: GenQueue.TestTest.Adapter)

    use GenQueue, otp_app: :gen_queue
  end

  defmodule ModQueue do
    Application.put_env(:gen_queue, __MODULE__, adapter: GenQueue.TestTest.Adapter)

    use GenQueue, adapter: GenQueue.TestTest.Adapter
  end

  describe "app_config: setup_test_queue/1" do
    test "will return the item back to the current process" do
      setup_test_queue(AppQueue)
      AppQueue.push(:foo)
      assert_receive(:foo)
    end
  end

  describe "app_config: setup_global_test_queue/2" do
    test "will name the current process" do
      setup_global_test_queue(AppQueue, :test)
      assert self() == Process.whereis(:test)
    end

    test "will return the item back to the named process" do
      setup_global_test_queue(AppQueue, :test)
      AppQueue.push(:foo)
      assert_receive(:foo)
    end
  end

  describe "app_config: reset_test_queue/1" do
    test "will remove any current return processes" do
      setup_test_queue(AppQueue)
      AppQueue.push(:foo)
      assert_receive(:foo)

      reset_test_queue(AppQueue)
      AppQueue.push(:foo)

      assert {:message_queue_len, 0} = Process.info(self(), :message_queue_len)
    end
  end

  describe "mod_config: setup_test_queue/1" do
    test "will return the item back to the current process" do
      setup_test_queue(ModQueue)
      ModQueue.push(:foo)
      assert_receive(:foo)
    end
  end

  describe "mod_config: setup_global_test_queue/2" do
    test "will name the current process" do
      setup_global_test_queue(ModQueue, :test)
      assert self() == Process.whereis(:test)
    end

    test "will return the item back to the named process" do
      setup_global_test_queue(ModQueue, :test)
      ModQueue.push(:foo)
      assert_receive(:foo)
    end
  end

  describe "mod_config: reset_test_queue/1" do
    test "will remove any current return processes" do
      setup_test_queue(ModQueue)
      ModQueue.push(:foo)
      assert_receive(:foo)

      reset_test_queue(ModQueue)
      ModQueue.push(:foo)

      assert {:message_queue_len, 0} = Process.info(self(), :message_queue_len)
    end
  end
end
