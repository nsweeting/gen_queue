defmodule GenQueue.Job do
  defstruct [
    :module,
    :args,
    :queue,
    :delay,
    :config
  ]

  @typedoc "Details on how and what to enqueue a job with"
  @type job :: module | {module} | {module, list} | {module, any}

  @typedoc "The name of a queue to place the job under"
  @type queue :: binary | atom | nil

  @typedoc "A delay to schedule the job with"
  @type delay :: integer | DateTime.t() | nil

  @typedoc "Any additional configuration that is adapter-specific"
  @type config :: list | nil

  @typedoc "Options for enqueuing jobs"
  @type options :: [{:delay, delay}, {:queue, queue}, {:config, config}]

  @type t :: %GenQueue.Job{
          module: module,
          args: list,
          queue: queue,
          delay: delay,
          config: config
        }

  @spec new(job, options) :: GenQueue.Job.t()
  def new(module, opts \\ [])

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
    job = Keyword.merge(opts, [module: module, args: args])
    struct(__MODULE__, job)
  end
end
