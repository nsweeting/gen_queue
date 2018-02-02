defmodule GenQueue do
  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @callback push(GenQueue.Job.t()) :: {:ok, GenQueue.Job.t()} | {:error, any}

  @callback push(atom, list, list) :: {:ok, GenQueue.Job.t()} | {:error, any}

  @callback push!(GenQueue.Job.t()) :: GenQueue.Job.t() | no_return

  @callback push!(atom, list, list) :: GenQueue.Job.t() | no_return

  @callback pop(list) :: {:ok, GenQueue.Job.t()} | {:error, any}

  @callback pop!(list) :: GenQueue.Job.t() | no_return

  @callback __adapter__ :: atom

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenQueue

      @otp_app Keyword.get(opts, :otp_app)
      @adapter GenQueue.Config.adapter(@otp_app, __MODULE__)

      def start_link(opts \\ []) do
        apply(@adapter, :start_link, [__MODULE__, opts])
      end

      def push(%GenQueue.Job{} = job) do
        job = GenQueue.Job.put_enqueuer(job, __MODULE__)
        apply(@adapter, :handle_push, [__MODULE__, job])
      end

      def push(module, args \\ [], opts \\ []) do
        push(GenQueue.Job.new(module, args, opts))
      end

      def push!(%GenQueue.Job{} = job) do
        case push(job) do
          {:ok, job} -> job
          _ -> raise GenQueue.Error, "Failed to push job."
        end
      end

      def push!(module, args \\ [], opts \\ []) do
        push!(GenQueue.Job.new(module, args, opts))
      end

      def flush(opts \\ []) do
        apply(@adapter, :handle_flush, [__MODULE__, opts])
      end

      def pop(opts \\ []) do
        apply(@adapter, :handle_pop, [__MODULE__, opts])
      end

      def pop!(opts \\ []) do
        case pop(opts) do
          {:ok, job} -> job
          _ -> raise GenQueue.Error, "Failed to pop job."
        end
      end

      def __adapter__ do
        @adapter
      end
    end
  end
end
