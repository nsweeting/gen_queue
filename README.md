# GenQueue
[![Build Status](https://travis-ci.org/nsweeting/gen_queue.svg?branch=master)](https://travis-ci.org/nsweeting/gen_queue)
[![GenQueue Exq Version](https://img.shields.io/hexpm/v/gen_queue.svg)](https://hex.pm/packages/gen_queue)

GenQueue is a specification for queues.

This project currently provides the following functionality:

  * `GenQueue` ([docs](https://hexdocs.pm/gen_queue/GenQueue.html)) - a behaviour for queues

  * `GenQueue.Adapter` ([docs](https://hexdocs.pm/gen_queue/GenQueue.Adapter.html)) - a behaviour for implementing adapters for a `GenQueue`

  * `GenQueue.JobAdapter` ([docs](https://hexdocs.pm/gen_queue/GenQueue.JobAdapter.html)) - a behaviour for implementing job-based adapters for a `GenQueue`

  * `GenQueue.Job` ([docs](https://hexdocs.pm/gen_queue/GenQueue.Job.html)) - a struct for containing job-enqueing instructions


## Installation

The package can be installed by adding `gen_queue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_queue, "~> 0.1.5"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/gen_queue) for additional documentation.

## Adapters

The true functionality of `GenQueue` comes with use of its adapters. Currently, the following
adapters are supported.

  * [GenQueue Exq](https://github.com/nsweeting/gen_queue_exq) - Redis-backed job queue.
  * [GenQueue TaskBunny](https://github.com/nsweeting/gen_queue_task_bunny) - RabbitMQ-backed job queue.
  * [GenQueue Verk](https://github.com/nsweeting/gen_queue_verk) - Redis-backed job queue.
  * [GenQueue OPQ](https://github.com/nsweeting/gen_queue_opq) - GenStage-backed job queue.

More adapters are always welcome!
