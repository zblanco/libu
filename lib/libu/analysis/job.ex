defmodule Libu.Analysis.Job do
  @moduledoc """
  A job represents a recipe of nested calculations to make for a given input.

  A top level job can be run when given the required parameters such as a `queue`, an `input`, a `name`, and a `work` function.

  Once a job has been run, dependent jobs under the `jobs` key are enqueued to be run with the parent job as input.

  The `Job` was modeled to support run-time modification of these dependent calculations.

  A datastructure of these nested jobs can be constructed without root inputs, injected with inputs at runtime,
    then dispatched to a queue for processing. The job processor only has to execute `Job.run/1` to start the pipeline of dependent jobs.

  Assuming the Queue passed into the job is valid and feeds into more job processors the whole pipeline will run.

  For example once a job to run a calculation has been run,
    a notification to follow up with results can be published via a dependent job.

  However in most cases you would use this module when you want both `concurrent` execution along side step-by-step dependent execution.

  Dependent jobs can be added using the `add_dependent_job/2` function.

  ```elixir
    example_job_pipeline = %{
      tokenization: %Job{
        name: :tokenization,
        work: &TextProcessing.tokenize/1,
        jobs: %{ # jobs here will be enqueued to run upon `:tokenization`'s completion
          down_case: %Job{
            name: :down_case,
            work: &TextProcessing.downcase/1,
            jobs: %{
              word_counts: %Job{
                name: :word_counts,
                work: &TextProcessing.word_counts/1,
              },
              basic_sentiment: %Job{
                name: :basic_sentiment,
                work: &SentimentAnalysis.basic_sentiment/1,
              }
            }
          },
          total_count_of_words: %Job{
            name: :total_count_of_words,
            work: &TextProcessing.count_of_words/1
          },
        }
      },
      # Root jobs can run concurrently from other jobs.
      google_nlp: %Job{
        name: :google_nlp,
        work: &GoogleNLP.analyze_text/1,
      },
      dalle_challe_readability: %Job{
        name: :dalle_challe_readability,
        work: &Readbility.dalle_chall_readability/1,
      },
    }
  ```

  TODO:

  - [x] Implement `run_id` to keep track of active jobs this will let us handle retries and prune deactivated jobs from session terminations
  - [] Job retry counts?
  * Maybe context is an anti-pattern?
  """
  defstruct name: nil,
            run_id: nil,
            work: nil,
            jobs: nil,
            input: nil,
            result: nil,
            queue: nil,
            runnable?: false,
            context: %{}

  def new(params) do
    struct!(__MODULE__, params)
  end

  def can_run?(%__MODULE__{runnable?: true}), do: :ok
  def can_run?(%__MODULE__{}), do: :error

  def set_queue(%__MODULE__{} = job, queue),
    do: set_job_value(job, :queue, queue)

  def set_work(%__MODULE__{} = job, work)
  when is_function(work), do: set_job_value(job, :work, work)

  def set_result(%__MODULE__{} = job, result),
    do: set_job_value(job, :result, result)

  def set_input(%__MODULE__{} = job, input),
    do: set_job_value(job, :input, input)

  def assign_run_id(%__MODULE__{} = job),
    do: set_job_value(job, :run_id, UUID.uuid4())

  def add_context(%__MODULE__{context: existing_context} = job, key, context) do
    %__MODULE__{job | context: Map.put(existing_context, key, context)}
  end

  defp set_job_value(%__MODULE__{} = job, key, value)
  when key in [:work, :input, :result, :queue, :run_id] do
    Map.put(job, key, value) |> evaluate_runnability()
  end

  @doc """
  Checks if a given job is runnable.

  This is chained automatically within `set_queue/2`, `set_result/2`, `set_input/2`, and `new/1`.

  `can_run?/1` can be used at run time to ensure a job is runnable before allocating resources and executing side effects.
  """
  def evaluate_runnability(%__MODULE__{
    name: name,
    work: work,
    input: input,
    result: nil,
    queue: queue,
    run_id: run_id,
  } = job)
    when is_function(work, 1)
    and not is_nil(name)
    and not is_nil(input)
    and not is_nil(queue)
    and not is_nil(run_id)
  do
    %__MODULE__{job | runnable?: true}
  end
  def evaluate_runnability(%__MODULE__{} = job), do:
    %__MODULE__{job | runnable?: false}

  @doc """
  Adds a child job to be enqueued with the result of the previous upon running.

  ### Usage

  ```elixir
  parent_job = %Job{name: "parent job"}
  child_job = %Job{name: "child job"}
  parent_with_child = Job.add_dependent_job(parent_job, child_job)
  ```
  """
  def add_dependent_job(%__MODULE__{jobs: nil} = parent_job, child_job) do
    add_dependent_job(%__MODULE__{parent_job | jobs: %{}}, child_job)
  end
  def add_dependent_job(
    %__MODULE__{jobs: %{} = jobs} = parent_job,
    %__MODULE__{name: name} = child_job)
  do
    %__MODULE__{parent_job | jobs: Map.put_new(jobs, name, child_job)}
  end

  @doc """
  Assuming a runnable job, `run/1` executes the function contained in `work`,
    sets the `result` with the return and enqueues dependent jobs with the result as the input for the children.
  """
  def run(%__MODULE__{runnable?: false}), do: {:error, "Job not runnable"}
  def run(%__MODULE__{work: work, input: input} = job) # consider mfa
  when is_function(work) do
    with {:ok, result} <- work.(input) do # we're assuming that the work function follows {:ok, _} | {:error, _} conventions - better way?
      updated_job =
        job
        |> set_result(result)
        |> set_parent_as_result_for_children()
        |> assign_run_id_for_children()
        |> enqueue_next_jobs()

      {:ok, updated_job}
    else
      {:error, _} = error -> error
      error -> error
    end
  end

  def set_parent_as_result_for_children(%__MODULE__{jobs: nil} = parent_job),   do: parent_job
  def set_parent_as_result_for_children(%__MODULE__{result: nil} = parent_job), do: parent_job
  def set_parent_as_result_for_children(%__MODULE__{jobs: jobs} = parent_job) do
    child_jobs = Enum.map(jobs, fn {name, job} ->
      {name, set_input(job, parent_job)}
    end)
    %__MODULE__{parent_job | jobs: child_jobs}
  end

  def assign_run_id_for_children(%__MODULE__{jobs: nil} = parent_job), do: parent_job
  def assign_run_id_for_children(%__MODULE__{jobs: jobs} = parent_job) do
    child_jobs = Enum.map(jobs, fn {name, job} ->
      {name, assign_run_id(job)}
    end)
    %__MODULE__{parent_job | jobs: child_jobs}
  end

  def enqueue_next_jobs(%__MODULE__{jobs: nil} = job),
    do: evaluate_runnability(job)
  def enqueue_next_jobs(%__MODULE__{jobs: jobs, queue: queue} = job) do
    Enum.each(jobs, fn {_name, job} -> queue.enqueue(job) end) # consider how to handle errors
    job
  end

  defmodule Queue do
    @moduledoc """
    Behaviour definition that a valid Job Queue set in a Job's `:queue` key must implement to prevent runtime issues.
    """
    @callback enqueue(job_pipeline :: map() | Job.t) :: :ok | :error

    @callback ack(job :: Job.t) :: :ok | :error

    # @callback remove_jobs(job_ids :: list(String.t())) :: :ok | any()
  end
end
