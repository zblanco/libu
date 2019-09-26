defmodule Libu.Analysis.Job do
  @moduledoc """
  A job represents a recipe of nested calculations to make for a given input.

  A notification to follow up with results can be published in another job or in the work function.

  Dependent jobs can be added using the `add_dependent_job/2` function.

  ```elixir
    jobs: %{
      tokenization: %Job{
        name: :tokenization,
        work: &TextProcessing.tokenize/1,
        jobs: %{ # child/dependent jobs are run upon completion of parent
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
  Say the above `pipeline_example` is only one of many pipelines to run on a given stream of data.

  Any given job unrelated to the pipeline can be run concurrently, however dependent jobs within a pipline must consume the result of another.

  For example say we have some text like follows:

  ```elixir
  raw_text_1 = "hey this is some text to process"

  raw_text_2 = "some more text"
  ```

  We want to process and gain insights to the text as it changes over time.

  At any given moment a session of some kind will be streaming in new versions of text. The session will want to maintain a `%Pipeline{}` so it can invoke
    a concurrent job processor that knows how to run the pipeline recipe on the raw text.

  The processing might get `raw_text_1` and `raw_text_2` in the demand batch.

  {"some text" = initial_input, %Pipeline{stages: 3}}

  When running a pipeline for a given input we need to maintain the state of stages processed, then enqueue the next stage of jobs.

  We could either maintain state, or in job processing pass in the next state and enqueue the next job with the results in the processing.

  So for each pass of running a job it should have an input (provided from parent job or root input) and it's job map/spec
    - first it runs the `work/1`
    - then it runs the callback with the result
    - then it enqueues any additional dependent jobs with the result as the input
      - if this is the default behaviour than maybe the callback function can just be another job?
    > how does a job know how to enqueue back into the infrastructure?
      - we'd need a behaviour or an enqueuer passed into the job.
  """
  defstruct name: nil,
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
    do: %__MODULE__{job | queue: queue} |> evaluate_runnability()

  def set_result(%__MODULE__{} = job, result),
    do: %__MODULE__{job | result: result} |> evaluate_runnability()

  def set_input(%__MODULE__{} = job, input),
    do: %__MODULE__{job | runnable?: true, input: input} |> evaluate_runnability()

  def evaluate_runnability(%__MODULE__{
    name: name,
    work: work,
    input: input,
    result: nil,
    queue: queue,
  } = job)
    when is_function(work, 1)
    and not is_nil(name)
    and not is_nil(input)
    and not is_nil(queue)
  do
    %__MODULE__{job | runnable?: true}
  end
  def evaluate_runnability(%__MODULE__{} = job), do:
    %__MODULE__{job | runnable?: false}

  def add_dependent_job(%__MODULE__{jobs: nil} = parent_job, child_job) do
    add_dependent_job(%__MODULE__{parent_job | jobs: %{}}, child_job)
  end
  def add_dependent_job(
    %__MODULE__{jobs: %{} = jobs} = parent_job,
    %__MODULE__{name: name} = child_job)
  do
    %__MODULE__{parent_job | jobs: Map.put_new(jobs, name, child_job)}
  end

  def run(%__MODULE__{runnable?: false}), do: {:error, "Job not runnable"}
  def run(%__MODULE__{work: work, input: input} = job) # consider mfa
  when is_function(work) do
    with {:ok, result} <- work.(input) do
      updated_job =
        job
        |> set_result(result)
        |> enqueue_next_jobs()

      {:ok, updated_job}
    else
      {:error, _} = error -> error
      error -> error
    end
  end

  def enqueue_next_jobs(%__MODULE__{jobs: nil} = job),
    do: %__MODULE__{job | runnable?: false}
  def enqueue_next_jobs(%__MODULE__{jobs: jobs, runnable?: true, queue: queue}) do
    Enum.each(jobs, fn {_name, job} -> queue.enqueue(job) end)
  end

  defmodule Queue do
    @callback enqueue(jobs :: map()) :: :ok | :error

    @callback ack(job :: Job.t) :: :ok | :error

    # @callback remove_jobs(job_ids :: list(String.t())) :: :ok | any()
  end
end
