defmodule GenQueue.Adapters.Simple do
  use GenQueue.Adapter

  def start_link(gen_queue, opts) do
    GenQueue.Adapters.SimpleServer.start_link(gen_queue, opts)
  end

  def handle_push(gen_queue, queue, item) do
    GenServer.call(gen_queue, {:push, queue, item})
  end

  def handle_pop(gen_queue, queue) do
    GenServer.call(gen_queue, {:pop, queue})
  end

  def handle_flush(gen_queue, queue) do
    GenServer.call(gen_queue, {:flush, queue})
  end
  
  def handle_size(gen_queue, queue) do
    GenServer.call(gen_queue, {:size, queue})
  end
end
