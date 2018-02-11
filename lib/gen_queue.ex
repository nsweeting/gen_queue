defmodule GenQueue do
  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @callback push(atom, list, map) :: {:ok, GenQueue.Job.t()} | {:error, any}

  @callback push!(atom, list, list) :: GenQueue.Job.t() | no_return

  @callback pop(binary) :: {:ok, GenQueue.Job.t()} | {:ok, nil} | {:error, any}

  @callback pop!(binary) :: GenQueue.Job.t() | no_return

  @callback flush(binary) :: {:ok, integer} | {:error, any}

  @callback flush!(binary) :: integer | no_return

  @callback __adapter__ :: atom

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenQueue

      @otp_app Keyword.get(opts, :otp_app)
      @adapter GenQueue.Config.adapter(@otp_app, __MODULE__)

      def start_link(opts \\ []) do
        apply(@adapter, :start_link, [__MODULE__, opts])
      end

      def push(module, args \\ [], opts \\ %{}) do
        GenQueue.push(__MODULE__, module, args, opts)
      end

      def push!(module, args \\ [], opts \\ %{}) do
        case push(module, args, opts) do
          {:ok, job} -> job
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

      def flush!(queue) do
        case flush(queue) do
          {:ok, count} -> count
          _ -> raise GenQueue.Error, "Failed to flush jobs."
        end
      end

      def __adapter__ do
        @adapter
      end
    end
  end

  @spec push(atom, atom, list, map) :: {:ok, GenQueue.Job.t()} | {:error, any}
  def push(enqueuer, module, args \\ [], opts \\ %{}) do
    job = GenQueue.Job.new(module, args, opts)
    apply(enqueuer.__adapter__, :handle_push, [enqueuer, job])
  end

  @spec pop(atom, binary) :: {:ok, GenQueue.Job.t()} | {:ok, nil} | {:error, any}
  def pop(enqueuer, queue) do
    apply(enqueuer.__adapter__, :handle_pop, [enqueuer, queue])
  end

  @spec flush(atom, binary) :: {:ok, integer} | {:error, any}
  def flush(enqueuer, queue) do
    apply(enqueuer.__adapter__, :handle_flush, [enqueuer, queue])
  end
end
