defmodule GenQueue.Adapters.JobMock do
  use GenQueue.Adapter

  def start_link(caller, opts) do
    GenQueue.Adapters.SimpleServer.start_link(caller, opts)
  end

  def handle_push(caller, queue, {module}) do
    GenServer.call(caller, {:push, queue, {module, [], %{}}})
  end

  def handle_push(caller, queue, {module, args}) do
    GenServer.call(caller, {:push, queue, {module, args, %{}}})
  end

  def handle_push(caller, queue, {module, args, opts}) do
    GenServer.call(caller, {:push, queue, {module, args, opts}})
  end

  def handle_pop(caller, queue) do
    GenServer.call(caller, {:pop, queue})
  end

  def handle_flush(caller, queue) do
    GenServer.call(caller, {:flush, queue})
  end
end
