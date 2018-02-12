defmodule GenQueue.Adapters.Simple do
  use GenQueue.Adapter

  def start_link(caller, opts) do
    GenQueue.Adapters.SimpleServer.start_link(caller, opts)
  end

  def handle_push(caller, queue, item) do
    GenServer.call(caller, {:push, queue, item})
  end

  def handle_pop(caller, queue) do
    GenServer.call(caller, {:pop, queue})
  end

  def handle_flush(caller, queue) do
    GenServer.call(caller, {:flush, queue})
  end
end
