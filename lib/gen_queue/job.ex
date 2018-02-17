defmodule GenQueue.Job do
  @type t :: %__MODULE__{
          module: module,
          args: list,
          queue: binary | atom,
          delay: integer | DateTime.t()
        }

  defstruct [
    :module,
    :args,
    :queue,
    :delay
  ]

  alias GenQueue.Job

  def new(module, opts) when is_atom(module) do
    new(module, [], opts)
  end

  def new({module}, opts) when is_atom(module) do
    new(module, [], opts)
  end

  def new({module, args}, opts) when is_atom(module) and is_list(args) do
    new(module, args, opts)
  end

  def new({module, arg}, opts) when is_atom(module) do
    new(module, [arg], opts)
  end

  def new(module, args, opts) do
    {queue, delay} = parse_options(opts)
    %Job{module: module, args: args, queue: queue, delay: delay}
  end

  defp parse_options(opts) do
    queue = Keyword.get(opts, :queue)
    delay = Keyword.get(opts, :delay)
    {queue, delay}
  end
end
