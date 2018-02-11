defmodule GenQueue.Adapters.Mock do
  use GenQueue.Adapter

  @default_opts %{
    queue: "default"
  }

  def start_link(caller, opts) do
    GenQueue.Adapters.MockServer.start_link(caller, opts)
  end

  def handle_push(caller, job) do
    job = GenQueue.Job.put_opts(job, @default_opts)
    GenServer.call(caller, {:push, job})
  end

  def handle_pop(caller, queue) do
    GenServer.call(caller, {:pop, queue})
  end

  def handle_flush(caller, queue) do
    GenServer.call(caller, {:flush, queue})
  end
end
