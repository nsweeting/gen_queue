defmodule GenQueue do
  @moduledoc """
  A behaviour module for implementing queues.

  GenQueue relies on adapters to handle the specifics of how the queues
  are run. At its most simple, this can mean basic memory FIFO queues. At its
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

      # Push items into the queue
      Queue.push(:hello)
      #=> {:ok, :hello}
      Queue.push(:world)
      #=> {:ok, :world}

      # Pop items from the queue
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
        adapter: MyApp.MyAdapter
      ]

      defmodule MyApp.Enqueuer do
        use GenQueue, otp_app: :my_app
      end

  The adapter can also be specified for the module in line:

      defmodule MyApp.Enqueuer do
        use GenQueue, adapter: MyApp.MyAdapter
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

  @callback start_link(opts :: Keyword.t()) :: GenServer.on_start()

  @doc """
  Pushes an item to a queue

  ## Example

      case MyQueue.push(value) do
        {:ok, value} -> # Pushed with success
        {:error, _}  -> # Something went wrong
      end
  """
  @callback push(item :: any, opts :: Keyword.t()) :: {:ok, any} | {:error, any}

  @doc """
  Same as `push/2` but returns the item or raises if an error occurs.
  """
  @callback push!(item :: any, opts :: Keyword.t()) :: any | no_return

  @doc """
  Pops an item from a queue

  ## Example

      case MyQueue.pop() do
        {:ok, value} -> # Popped with success
        {:error, _}  -> # Something went wrong
      end
  """
  @callback pop(opts :: Keyword.t()) :: {:ok, any} | {:error, any}

  @doc """
  Same as `pop/1` but returns the item or raises if an error occurs.
  """
  @callback pop!(opts :: Keyword.t()) :: any | no_return

  @doc """
  Removes all items from a queue

  ## Example

      case MyQueue.flush() do
        {:ok, number_of_items} -> # Flushed with success
        {:error, _}  -> # Something went wrong
      end
  """
  @callback flush(opts :: Keyword.t()) :: {:ok, integer} | {:error, any}

  @doc """
  Gets the number of items in a queue

  ## Example

      case MyQueue.length() do
        {:ok, number_of_items} -> # Counted with success
        {:error, _}  -> # Something went wrong
      end
  """
  @callback length(opts :: Keyword.t()) :: {:ok, integer} | {:error, any}

  @doc """
  Returns the application config for a queue
  """
  @callback config :: Keyword.t()

  @doc """
  Returns the adapter for a queue
  """
  @callback adapter :: GenQueue.Adapter.t()

  @type t :: module

  @default_adapter GenQueue.Adapters.Simple

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenQueue

      @adapter GenQueue.adapter(__MODULE__, opts)
      @config GenQueue.config(__MODULE__, opts)

      def child_spec(arg) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [arg]}
        }
      end

      defoverridable child_spec: 1

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

      def config do
        @config
      end

      def adapter do
        @adapter
      end
    end
  end

  @doc false
  @deprecated "Use adapter/2 instead"
  @spec config_adapter(GenQueue.t(), opts :: Keyword.t()) :: GenQueue.Adapter.t()
  def config_adapter(gen_queue, opts \\ [])

  def config_adapter(_gen_queue, adapter: adapter) when is_atom(adapter), do: adapter

  def config_adapter(gen_queue, otp_app: app) when is_atom(app) do
    app
    |> Application.get_env(gen_queue, [])
    |> Keyword.get(:adapter, @default_adapter)
  end

  def config_adapter(_gen_queue, _opts), do: @default_adapter

  @doc """
  Get the adapter for a GenQueue module based on the options provided.

  If no adapter if specified, the default `GenQueue.Adapters.Simple` is returned.

  ## Options:

    * `:adapter` - The adapter to be returned.
    * `:otp_app` - An OTP application that has your GenQueue adapter configuration.

  ## Example

      GenQueue.adapter(MyQueue, [otp_app: :my_app])
  """
  @since "0.1.7"
  @spec adapter(GenQueue.t(), opts :: Keyword.t()) :: GenQueue.Adapter.t()
  def adapter(gen_queue, opts \\ [])

  def adapter(_gen_queue, adapter: adapter) when is_atom(adapter), do: adapter

  def adapter(gen_queue, otp_app: app) when is_atom(app) do
    app
    |> Application.get_env(gen_queue, [])
    |> Keyword.get(:adapter, @default_adapter)
  end

  def adapter(_gen_queue, _opts), do: @default_adapter

  @doc """
  Get the config for a GenQueue module based on the options provided.

  If an `:otp_app` option is provided, this will return the application config.
  Otherwise, it will return the options given.

  ## Options

    * `:otp_app` - An OTP application that has your GenQueue configuration.

  ## Example

      # Get the application config
      GenQueue.config(MyQueue, [otp_app: :my_app])

      # Returns the provided options
      GenQueue.config(MyQueue, [adapter: MyAdapter])
  """
  @since "0.1.7"
  @spec config(GenQueue.t(), opts :: Keyword.t()) :: GenQueue.Adapter.t()
  def config(gen_queue, opts \\ [])

  def config(gen_queue, otp_app: app) when is_atom(app) do
    Application.get_env(app, gen_queue, [])
  end

  def config(_gen_queue, opts) when is_list(opts), do: opts
end
