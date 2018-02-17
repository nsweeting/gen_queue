defmodule GenQueue.Adapter do
  @moduledoc """
  A behaviour module for implementing queue adapters.
  """

  @callback start_link(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @doc """
  Push an item to a queue

  ## Parameters:
    * `gen_queue` - A `GenQueue` module
    * `item` - Any valid term
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, item}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_push(gen_queue :: GenQueue.t(), item :: any, opts :: Keyword.t()) ::
              {:ok, any} | {:error, any}

  @doc """
  Pop an item from a queue

  Parameters:
    * `gen_queue` - A `GenQueue` module
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, item}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_pop(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, any} | {:error, any}

  @doc """
  Remove all items from a queue

  Parameters:
    * `gen_queue` - A `GenQueue` module
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, number_of_items_removed}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_flush(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, integer} | {:error, any}

  @doc """
  Get the number of items in a queue

  Parameters:
    * `gen_queue` - A `GenQueue` module
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, number_of_items}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_length(gen_queue :: GenQueue.t(), opts :: Keyword.t()) ::
              {:ok, integer} | {:error, any}

  @type t :: module

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      @doc false
      def start_link(_gen_queue, _opts) do
        {:error, :not_implemented}
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
