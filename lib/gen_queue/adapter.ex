defmodule GenQueue.Adapter do
  @moduledoc """
  A behaviour module for implementing queue adapters.
  """

  @callback start_link(gen_queue :: GenQueue.t(), opts :: Keyword.t()) :: GenServer.on_start()

  @doc """
  Pushes an item to a queue
  """
  @callback handle_push(gen_queue :: GenQueue.t(), item :: any, opts :: Keyword.t()) ::
              {:ok, any} | {:error, any}

  @doc """
  Pops an item from a queue
  """
  @callback handle_pop(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, any} | {:error, any}

  @doc """
  Removes all items from a queue
  """
  @callback handle_flush(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, integer} | {:error, any}

  @doc """
  Gets the number of items in a queue
  """
  @callback handle_length(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, integer} | {:error, any}

  @type t :: module

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      @doc false
      def start_link(_gen_queue, _opts) do
        :ignore
      end

      @doc false
      def handle_push(_gen_queue, _item, _opts) do
        {:error, :not_implemented}
      end

      @doc false
      def handle_pop(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      @doc false
      def handle_flush(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      @doc false
      def handle_length(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
