defmodule GenQueue do
  @moduledoc """
  A behaviour module for implementing queues.

  GenQueue relies on adapters to handle the specifics of how the queues
  are run. At its most simple, this can mean simple FIFO queues. At its
  most advanced, this can mean full async job queues with retries and
  backoffs. By providing a standard interface for such tools - ease in
  switching between different implementations is assured.

  ## Example

  The GenQueue behaviour abstracts the common queue interactions. 
  Developers are only required to implement the callbacks and functionality
  they are interested in via adapters.

  Let's start with a simple FIFO queue:

      defmodule Enqueuer do
        use GenQueue
      end
      
       # Start the queue
      Enqueuer.start_link()

      # Push items into the :foo queue
      Enqueuer.push(:foo, :hello)
      #=> {:ok, :hello}
      Enqueuer.push(:foo, :world)
      #=> {:ok, :world}
      
      # Pop items from the :foo queue
      Enqueuer.pop(:foo)
      #=> {:ok, :hello}
      Enqueuer.pop(:foo)
      #=> {:ok, :world}

  We start our enqueuer by calling `start_link\1`. This call is then
  forwarded to our adapter. In this case, we dont specify an adapter
  anywhere, so it defaults to the simple FIFO queue implemented with
  the included `GenQueue.SimpleAdapter`.

  We can then add items into our simple FIFO queues with `push/2`, as
  well as remove them with `pop/1`.

  ## use GenQueue and adapters

  As we can see from above - implementing a simple queue is easy. But
  we can further extend our queues with more advanced adapters.

  """
  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @callback push(queue, any) :: {:ok, any} | {:error, any}

  @callback push!(queue, any) :: any | no_return

  @callback pop(queue) :: {:ok, any} | {:error, any}

  @callback pop!(queue) :: any | no_return

  @callback flush(queue) :: {:ok, integer} | {:error, any}

  @callback length(queue) :: {:ok, integer} | {:error, any}

  @callback adapter :: module

  @type t :: module

  @type queue :: binary | atom

  @default_adapter GenQueue.SimpleAdapter

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenQueue

      @adapter GenQueue.config_adapter(__MODULE__, opts)

      def start_link(opts \\ []) do
        apply(@adapter, :start_link, [__MODULE__, opts])
      end

      def push(queue, item) do
        GenQueue.push(__MODULE__, queue, item)
      end

      def push!(queue, item) do
        case push(queue, item) do
          {:ok, item} -> item
          _ -> raise GenQueue.Error, "Failed to push job."
        end
      end

      def pop(queue) do
        GenQueue.pop(__MODULE__, queue)
      end

      def pop!(queue) do
        case pop(queue) do
          {:ok, job} -> job
          _ -> raise GenQueue.Error, "Failed to pop job."
        end
      end

      def flush(queue) do
        GenQueue.flush(__MODULE__, queue)
      end

      def length(queue) do
        GenQueue.length(__MODULE__, queue)
      end

      def adapter do
        @adapter
      end
    end
  end

  @spec push(GenQueue.t(), queue, any) :: {:ok, any} | {:error, any}
  def push(gen_queue, queue, item) do
    apply(gen_queue.adapter(), :handle_push, [gen_queue, queue, item])
  end

  @spec pop(GenQueue.t(), queue) :: {:ok, any} | {:error, any}
  def pop(gen_queue, queue) do
    apply(gen_queue.adapter(), :handle_pop, [gen_queue, queue])
  end

  @spec flush(GenQueue.t(), queue) :: {:ok, integer} | {:error, any}
  def flush(gen_queue, queue) do
    apply(gen_queue.adapter(), :handle_flush, [gen_queue, queue])
  end

  @spec length(GenQueue.t(), queue) :: {:ok, integer} | {:error, any}
  def length(gen_queue, queue) do
    apply(gen_queue.adapter(), :handle_length, [gen_queue, queue])
  end

  @spec config_adapter(GenQueue.t(), list) :: GenQueue.Adapter.t()
  def config_adapter(gen_queue, opts \\ []) do
    opts
    |> Keyword.get(:otp_app)
    |> Application.get_env(gen_queue, [])
    |> Keyword.get(:adapter, @default_adapter)
  end
end
