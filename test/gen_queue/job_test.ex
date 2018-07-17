defmodule GenQueue.JobTest do
  use ExUnit.Case

  alias GenQueue.Job

  describe "new/2" do
    test "will create a job struct" do
      assert %Job{module: Test, args: []} = Job.new(Test)
      assert %Job{module: Test, args: []} = Job.new({Test})
      assert %Job{module: Test, args: ["foo"]} = Job.new({Test, "foo"})
      assert %Job{module: Test, queue: "foo"} = Job.new(Test, queue: "foo")
      assert %Job{module: Test, delay: 100} = Job.new(Test, delay: 100)
      assert %Job{module: Test, config: [:foo]} = Job.new(Test, config: [:foo])
    end
  end
end

