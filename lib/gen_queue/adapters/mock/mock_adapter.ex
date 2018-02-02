defmodule GenQueue.MockAdapter do
  use GenQueue.Adapter

  def start_link(caller, opts) do
    GenQueue.MockServer.start_link(caller, opts)
  end

  def handle_push(caller, job) do
    GenServer.call(caller, {:push, job})
  end

  def handle_flush(caller, opts) do
    GenServer.call(caller, {:flush, opts})
  end

  def handle_pop(caller, opts) do
    GenServer.call(caller, {:pop, opts})
  end
end
