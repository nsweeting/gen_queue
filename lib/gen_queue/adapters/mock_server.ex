defmodule GenQueue.Adapters.MockServer do
  use GenServer

  def start_link(caller, _opts) do
    GenServer.start_link(__MODULE__, %{}, name: caller)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:push, job}, _from, queues) do
    queue_name = GenQueue.Job.get_opt(job, :queue)

    {_, queues} =
      Map.get_and_update(queues, queue_name, fn
        nil -> {nil, :queue.in(job, :queue.new())}
        queue -> {nil, :queue.in(job, queue)}
      end)

    {:reply, {:ok, job}, queues}
  end

  def handle_call({:flush, queue_name}, _from, queues) do
    queue_size =
      case Map.get(queues, queue_name) do
        nil -> 0
        queue -> :queue.len(queue)
      end

    queues = Map.put(queues, queue_name, :queue.new())
    {:reply, {:ok, queue_size}, queues}
  end

  def handle_call({:pop, queue_name}, _from, queues) do
    {job, queues} =
      Map.get_and_update(queues, queue_name, fn
        nil ->
          {nil, :queue.new()}

        queue ->
          case :queue.out(queue) do
            {{:value, job}, new_queue} -> {job, new_queue}
            {:empty, new_queue} -> {nil, new_queue}
          end
      end)

    {:reply, {:ok, job}, queues}
  end
end
