defmodule GenQueue do
  @moduledoc """
  A behaviour module for implementing queue wrappers.
  
  GenQueue relies on adapters to handle the specifics of how j

  """
  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @callback push(binary, any) :: {:ok, any} | {:error, any}

  @callback push!(binary, any) :: any | no_return

  @callback pop(binary) :: {:ok, any} | {:error, any}

  @callback pop!(binary) :: any | no_return

  @callback flush(binary) :: {:ok, integer} | {:error, any}

  @callback flush!(binary) :: integer | no_return

  @callback __adapter__ :: atom

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GenQueue

      @otp_app Keyword.get(opts, :otp_app)
      @adapter GenQueue.Config.adapter(@otp_app, __MODULE__)

      def start_link(opts \\ []) do
        apply(__adapter__, :start_link, [__MODULE__, opts])
      end

      def push(queue_name, item) do
        GenQueue.push(__MODULE__, queue_name, item)
      end

      def push!(queue_name, item) do
        case push(queue_name, item) do
          {:ok, item} -> item
          _ -> raise GenQueue.Error, "Failed to push job."
        end
      end

      def pop(queue_name) do
        GenQueue.pop(__MODULE__, queue_name)
      end

      def pop!(queue_name) do
        case pop(queue_name) do
          {:ok, job} -> job
          _ -> raise GenQueue.Error, "Failed to pop job."
        end
      end

      def flush(queue_name) do
        GenQueue.flush(__MODULE__, queue_name)
      end

      def flush!(queue_name) do
        case flush(queue_name) do
          {:ok, count} -> count
          _ -> raise GenQueue.Error, "Failed to flush jobs."
        end
      end

      def __adapter__ do
        @adapter
      end
    end
  end

  @spec push(atom, binary, any) :: {:ok, any} | {:error, any}
  def push(enqueuer, queue_name, item) do
    apply(enqueuer.__adapter__, :handle_push, [enqueuer, queue_name, item])
  end

  @spec pop(atom, binary) :: {:ok, any} | {:error, any}
  def pop(enqueuer, queue_name) do
    apply(enqueuer.__adapter__, :handle_pop, [enqueuer, queue_name])
  end

  @spec flush(atom, binary) :: {:ok, integer} | {:error, any}
  def flush(enqueuer, queue_name) do
    apply(enqueuer.__adapter__, :handle_flush, [enqueuer, queue_name])
  end
end
