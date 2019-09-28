defmodule Libu.JobTest do
  use ExUnit.Case
  alias Libu.Analysis.{Job, JobSupport}

  describe "new/1" do
    test "we can create a job with a map of params" do
      job = Job.new(%{name: "test_job", work: &JobSupport.squareaplier/1})

      assert match?(%Job{}, job)
    end

    test "we can create a job with a keyword list of params" do
      job = Job.new(name: "test_job", work: &JobSupport.squareaplier/1)

      assert match?(%Job{}, job)
    end

    test "without required params a job isn't runnable" do
      job = Job.new(name: "test_job", work: &JobSupport.squareaplier/1)

      assert Job.can_run?(job) == :error
    end
  end

  describe "evaluate_runnability/1" do
    test "a valid job has a name, work, input, no result, and a queue" do
      job = Job.new(
        name: "test_job",
        work: &JobSupport.squareaplier/1,
        input: 2,
        queue: JobSupport.TestQueue
      ) |> Job.evaluate_runnability()

      assert Job.can_run?(job) == :ok
    end

    test "setting the last required value will make a job runnable" do
      invalid_job = Job.new(
        name: "test_job",
        work: &JobSupport.squareaplier/1,
        queue: JobSupport.TestQueue
      ) |> Job.evaluate_runnability()

      assert Job.can_run?(invalid_job) == :error

      valid_job = Job.set_input(invalid_job, 2)
      assert Job.can_run?(valid_job) == :ok
    end
  end

  describe "add_dependent_job/2" do
    test "we can add a dependent job to a parent" do
      parent_job = Job.new(
        name: "parent_test_job",
        work: &JobSupport.squareaplier/1,
        input: 2,
        queue: JobSupport.TestQueue
      ) |> Job.evaluate_runnability()

      child_job = Job.new(
        name: "child_test_job",
        work: &JobSupport.squareaplier/1,
        input: nil,
        queue: JobSupport.TestQueue
      ) |> Job.evaluate_runnability()

      parent_with_dependent_job = Job.add_dependent_job(parent_job, child_job)

      assert match?(parent_with_dependent_job, %Job{jobs: %{child_job.name => child_job}})
    end
  end

  describe "run/1" do
    test "if the job isn't runnable, we return an error" do
      invalid_job = Job.new(
        name: "test_job",
        work: &JobSupport.squareaplier/1,
        queue: JobSupport.TestQueue
      )

      assert match?({:error, "Job not runnable"}, Job.run(invalid_job))
    end

    test "a runnable job runs the work and puts the return into the result" do
      job = Job.new(
        name: "test_job",
        work: &JobSupport.squareaplier/1,
        input: 2,
        queue: JobSupport.TestQueue
      ) |> Job.evaluate_runnability()

      {:ok, ran_job} = Job.run(job)

      assert match?(%Job{result: 4}, ran_job)
    end

    test "dependent jobs are evaluated when parent is ran" do
      assert false
    end

    test "dependent jobs are enqueued with the result of the parent job" do
      # modify the test queue to hold state
    end
  end
end
