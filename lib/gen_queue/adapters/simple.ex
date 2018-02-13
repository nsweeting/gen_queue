defmodule GenQueue.Adapters.Simple do
  use GenQueue.Adapter

  def start_link(gen_queue, _opts) do
    GenServer.start_link(__MODULE__, %{}, name: gen_queue)
  end

  def init(queues) do
    {:ok, queues}
  end

  def handle_call({:push, queue, item}, _from, queues) do
    {_, queues} =
      Map.get_and_update(queues, queue, fn
        nil -> {nil, :queue.in(item, :queue.new())}
        current_queue -> {nil, :queue.in(item, current_queue)}
      end)

    {:reply, {:ok, item}, queues}
  end

  def handle_call({:flush, queue}, _from, queues) do
    queue_size =
      case Map.get(queues, queue) do
        nil -> 0
        current_queue -> :queue.len(current_queue)
      end

    queues = Map.put(queues, queue, :queue.new())
    {:reply, {:ok, queue_size}, queues}
  end

  def handle_call({:pop, queue}, _from, queues) do
    {item, queues} =
      Map.get_and_update(queues, queue, fn
        nil ->
          {nil, :queue.new()}

        current_queue ->
          case :queue.out(current_queue) do
            {{:value, item}, new_queue} -> {item, new_queue}
            {:empty, new_queue} -> {nil, new_queue}
          end
      end)

    {:reply, {:ok, item}, queues}
  end

  def handle_call({:length, queue}, _from, queues) do
    queue_size =
      case Map.get(queues, queue) do
        nil -> 0
        current_queue -> :queue.len(current_queue)
      end

    {:reply, {:ok, queue_size}, queues}
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
  
  def handle_length(gen_queue, queue) do
    GenServer.call(gen_queue, {:length, queue})
  end
end
