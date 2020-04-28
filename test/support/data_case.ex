defmodule Libu.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Libu.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Libu.DataCase
      import Commanded.Assertions.EventAssertions
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Libu.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Libu.Repo, {:shared, self()})
    end

    :ok
  end

  setup do
    {:ok, _} = Application.ensure_all_started(:libu)

    on_exit(fn ->
      :ok = Application.stop(:libu)

      Libu.Storage.reset!()
    end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Identity.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
