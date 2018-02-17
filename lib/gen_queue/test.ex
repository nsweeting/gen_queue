defmodule GenQueue.Test do
  @moduledoc """
  Conveniences for testing queues.

  This module allows us to create or use existing adapter "mock" libraries.
  A mock adapter is an adapter that mirrors the functionality of an exisiting
  adapter, but instead sends the item to the mailbox of a specified process.

      defmodule Adapter do
        use GenQueue.Adapter

        def handle_push(gen_queue, item, _opts) do
          GenQueue.Test.send_item(gen_queue, item)
        end
      end

  We can then test that our items are being pushed correctly.

      use ExUnit.Case, async: true

      import GenQueue.Test

      # This test assumes we have a GenQueue named Queue

      setup do
        setup_test_queue(Queue)
      end

      test "that our queue works" do
        Queue.start_link()
        Queue.push(:foo)
        assert_recieve(:foo)
      end

  Most adapters will provide a mirrored "mock" adapter to use with your tests.
  """

  @doc """
  Sets the queue reciever as the current process for a GenQueue.

  Parameters:
    * `gen_queue` - GenQueue module to use
  """
  @spec setup_test_queue(GenQueue.t()) :: :ok
  def setup_test_queue(gen_queue) do
    set_queue_receiver(gen_queue, :self)
  end

  @doc """
  Removes any current queue receiver for a GenQueue.

  Parameters:
    * `gen_queue` - GenQueue module to use
  """
  @spec reset_test_queue(GenQueue.t()) :: :ok
  def reset_test_queue(gen_queue) do
    set_queue_receiver(gen_queue, nil)
  end

  @doc """
  Sets the queue reciever as the current process for a GenQueue. The current
  process is also given a name. This ensures queues that run outside of the
  current process are able to send items to the correct mailbox.

  Parameters:
    * `gen_queue` - GenQueue module to use
    * `process_name` - A name for the current process.
  """
  @spec setup_global_test_queue(GenQueue.t(), atom) :: :ok
  def setup_global_test_queue(gen_queue, process_name) when is_atom(process_name) do
    Process.register(self(), process_name)
    set_queue_receiver(gen_queue, process_name)
  end

  @doc """
  Sends an item to the mailbox of a process set for a GenQueue.

  Parameters:
    * `gen_queue` - GenQueue module to use
    * `item` - Any valid term.
  """
  @spec send_item(GenQueue.t(), any) :: any
  def send_item(gen_queue, item) do
    case get_queue_receiver(gen_queue) do
      nil -> nil
      :self -> send(self(), item)
      process_name when is_atom(process_name) -> send(process_name, item)
    end
  end

  defp set_queue_receiver(gen_queue, process_name) when is_atom(process_name) do
    Application.put_env(:gen_queue, gen_queue, process_name)
  end

  defp get_queue_receiver(gen_queue) do
    Application.get_env(:gen_queue, gen_queue)
  end
end
