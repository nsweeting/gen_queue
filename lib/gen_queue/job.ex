defmodule GenQueue.Job do
  defstruct [
    :module,
    :args,
    :queue,
    :delay
  ]

  @typedoc "Details on how and what to enqueue a job with"
  @type job :: module | {module} | {module, list} | {module, any}

  @typedoc "The name of a queue to place the job under"
  @type queue :: binary | atom

  @typedoc "A delay to schedule the job with"
  @type delay :: integer | DateTime.t()

  @typedoc "Options for enqueuing jobs"
  @type options :: [{:delay, delay}, {:queue, queue}]

  @type t :: %GenQueue.Job{
          module: module,
          args: list,
          queue: queue,
          delay: delay
        }

  @spec new(job, options) :: GenQueue.Job.t()
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

  @spec new(module, list, options) :: GenQueue.Job.t()
  def new(module, args, opts) when is_list(args) do
    {queue, delay} = parse_options(opts)
    %GenQueue.Job{module: module, args: args, queue: queue, delay: delay}
  end

  defp parse_options(opts) do
    queue = Keyword.get(opts, :queue)
    delay = Keyword.get(opts, :delay)
    {queue, delay}
  end
end
