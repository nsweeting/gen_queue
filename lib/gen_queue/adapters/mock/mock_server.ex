defmodule GenQueue.MockServer do
  use GenServer

  def start_link(caller, _opts) do
    GenServer.start_link(__MODULE__, %{}, name: caller)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:push, job}, _from, queues) do
    queue_name = Keyword.get(job.opts, :queue)
    {_, queues} = Map.get_and_update(queues, queue_name, fn(queue) ->
      case queue do
        nil -> {queue, [job]}
        job_list -> {job_list, [job] ++ job_list}
      end
    end)
  
    {:reply, {:ok, job}, queues}
  end

  def handle_call({:flush, _opts}, _from, _queues) do
    {:reply, :ok, []}
  end

  def handle_call({:pop, opts}, _from, queues) do
    job = case Map.get(queues, Keyword.get(opts, :queue), []) do
      [] -> nil
      [hd | _tl] -> hd
    end

    {:reply, {:ok, job}, queues}
  end
end
