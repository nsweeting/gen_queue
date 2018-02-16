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

      defmodule Queue do
        use GenQueue
      end
      
       # Start the queue
      Queue.start_link()

      # Push items into the :foo queue
      Queue.push(:hello)
      #=> {:ok, :hello}
      Queue.push(:world)
      #=> {:ok, :world}
      
      # Pop items from the :foo queue
      Queue.pop()
      #=> {:ok, :hello}
      Queue.pop()
      #=> {:ok, :world}

  We start our enqueuer by calling `start_link/1`. This call is then
  forwarded to our adapter. In this case, we dont specify an adapter
  anywhere, so it defaults to the simple FIFO queue implemented with
  the included `GenQueue.Adapters.Simple`.

  We can then add items into our simple FIFO queues with `push/2`, as
  well as remove them with `pop/1`.

  ## use GenQueue and adapters

  As we can see from above - implementing a simple queue is easy. But
  we can further extend our queues by creating our own adapters or by using
  external libraries. Simply specify the adapter name in your config.

      config :my_app, MyApp.Enqueuer, [
        adapter: GenQueue.MyAdapter
      ]

      defmodule MyApp.Enqueuer do
        use GenQueue, otp_app: :my_app
      end

  We can then create our own adapter by creating an adapter module that handles
  the callbacks specified by `GenQueue.Adapter`.

      defmodule MyApp.MyAdapter do
        use GenQueue.Adapter

        def handle_push(gen_queue, item) do
          IO.inspect(item)
          {:ok, item}
        end
      end

  ## Current adapters

  Currently, the following adapters are available:

  * [GenQueue Exq](https://github.com/nsweeting/gen_queue_exq) - Redis-backed job queue.
  * [GenQueue TaskBunny](https://github.com/nsweeting/gen_queue_task_bunny) - RabbitMQ-backed job queue.
  * [GenQueue Verk](https://github.com/nsweeting/gen_queue_verk) - Redis-backed job queue.
  * [GenQueue OPQ](https://github.com/nsweeting/gen_queue_opq) - GenStage-backed job queue.

  ## Job queues

  One of the benefits of using `GenQueue` is that it can abstract common tasks
  like job enqueueing. We can then provide a common API for the various forms
  of job enqueing we would like to implement, as well as easily swap
  implementations.

  Please refer to the documentation for each adapter for more details.
  """

  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @doc """
  Invoked to push an item to a queue

  ## Parameters:
    * `item` - Any valid term
    * `opts` - Any options that may be valid to an adapter

  ## Returns:
    * `{:ok, item}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback push(any, list) :: {:ok, any} | {:error, any}

  @doc """
  Same as `push/2` but returns the item or raises if an error occurs.
  """
  @callback push!(any, list) :: any | no_return

  @doc """
  Invoked to pop an item from a queue

  Parameters:
    * `opts` - Any options that may be valid to an adapter

  ## Returns:
    * `{:ok, item}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback pop(list) :: {:ok, any} | {:error, any}

  @doc """
  Same as `pop/1` but returns the item or raises if an error occurs.
  """
  @callback pop!(list) :: any | no_return

  @doc """
  Invoked to remove all items from a queue

  Parameters:
    * `opts` - Any options that may be valid to an adapter

  ## Returns:
    * `{:ok, number_of_items_removed}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback flush(list) :: {:ok, integer} | {:error, any}

  @doc """
  Invoked to get the number of items in a queue

  Parameters:
    * `opts` - Any options that may be valid to an adapter

  ## Returns:
    * `{:ok, number_of_items}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback length(list) :: {:ok, integer} | {:error, any}

  @doc """
  Invoked to return the adapter for a queue
  """
  @callback adapter :: module

  @type t :: module

  @default_adapter GenQueue.Adapters.Simple

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenQueue

      @adapter GenQueue.config_adapter(__MODULE__, opts)

      def child_spec(arg) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [arg]}
        }
      end

      defoverridable [child_spec: 1]

      def start_link(opts \\ []) do
        apply(@adapter, :start_link, [__MODULE__, opts])
      end

      def push(item, opts \\ []) do
        apply(@adapter, :handle_push, [__MODULE__, item, opts])
      end

      def push!(item, opts \\ []) do
        case push(item, opts) do
          {:ok, item} -> item
          _ -> raise GenQueue.Error, "Failed to push item."
        end
      end

      def pop(opts \\ []) do
        apply(@adapter, :handle_pop, [__MODULE__, opts])
      end

      def pop!(opts \\ []) do
        case pop(opts) do
          {:ok, item} -> item
          _ -> raise GenQueue.Error, "Failed to pop item."
        end
      end

      def flush(opts \\ []) do
        apply(@adapter, :handle_flush, [__MODULE__, opts])
      end

      def length(opts \\ []) do
        apply(@adapter, :handle_length, [__MODULE__, opts])
      end

      def adapter do
        @adapter
      end
    end
  end

  @doc """
  Get the adapter for a GenQueue module based on the options provided. If
  no adapter if specified, the default `GenQueue.Adapters.Simple` is returned.

  Parameters:
    * `gen_queue` - GenQueue module to use
  """
  @spec config_adapter(GenQueue.t(), list) :: GenQueue.Adapter.t()
  def config_adapter(gen_queue, opts \\ []) do
    opts
    |> Keyword.get(:otp_app)
    |> Application.get_env(gen_queue, [])
    |> Keyword.get(:adapter, @default_adapter)
  end
end
