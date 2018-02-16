defmodule GenQueue.Adapter do
  @doc """
  Push an item to a GenQueue queue

  ## Parameters:
    * `gen_queue` - Any GenQueue module
    * `item` - Any valid term
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, item}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_push(GenQueue.t(), any, list) :: {:ok, any} | {:error, any}

  @doc """
  Pop an item from a GenQueue queue

  Parameters:
    * `gen_queue` - Any GenQueue module
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, item}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_pop(GenQueue.t(), list) :: {:ok, any} | {:error, any}

  @doc """
  Remove all items from a GenQueue queue

  Parameters:
    * `gen_queue` - Any GenQueue module
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, number_of_items_removed}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_flush(GenQueue.t(), list) :: {:ok, integer} | {:error, any}
  
  @doc """
  Get the number of items in a GenQueue queue

  Parameters:
    * `gen_queue` - Any GenQueue module
    * `opts` - Any adapter options

  ## Returns:
    * `{:ok, number_of_items}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @callback handle_length(GenQueue.t(), list) :: {:ok, integer} | {:error, any}

  @type t :: module

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      def handle_push(_gen_queue, _item, _opts) do
        {:error, :not_implemented}
      end

      def handle_pop(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      def handle_flush(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      def handle_length(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
