defmodule Libu.ProjectManagementTest do
  use Libu.DataCase

  alias Libu.ProjectManagement

  describe "boards" do
    alias Libu.ProjectManagement.Board

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def board_fixture(attrs \\ %{}) do
      {:ok, board} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ProjectManagement.create_board()

      board
    end

    test "list_boards/0 returns all boards" do
      board = board_fixture()
      assert ProjectManagement.list_boards() == [board]
    end

    test "get_board!/1 returns the board with given id" do
      board = board_fixture()
      assert ProjectManagement.get_board!(board.id) == board
    end

    test "create_board/1 with valid data creates a board" do
      assert {:ok, %Board{} = board} = ProjectManagement.create_board(@valid_attrs)
      assert board.name == "some name"
    end

    test "create_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProjectManagement.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      assert {:ok, %Board{} = board} = ProjectManagement.update_board(board, @update_attrs)
      assert board.name == "some updated name"
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = ProjectManagement.update_board(board, @invalid_attrs)
      assert board == ProjectManagement.get_board!(board.id)
    end

    test "delete_board/1 deletes the board" do
      board = board_fixture()
      assert {:ok, %Board{}} = ProjectManagement.delete_board(board)
      assert_raise Ecto.NoResultsError, fn -> ProjectManagement.get_board!(board.id) end
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = ProjectManagement.change_board(board)
    end
  end

  describe "projects" do
    alias Libu.ProjectManagement.Project

    @valid_attrs %{description: "some description", status: "some status"}
    @update_attrs %{description: "some updated description", status: "some updated status"}
    @invalid_attrs %{description: nil, status: nil}

    def project_fixture(attrs \\ %{}) do
      {:ok, project} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ProjectManagement.create_project()

      project
    end

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert ProjectManagement.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert ProjectManagement.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      assert {:ok, %Project{} = project} = ProjectManagement.create_project(@valid_attrs)
      assert project.description == "some description"
      assert project.status == "some status"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProjectManagement.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      assert {:ok, %Project{} = project} = ProjectManagement.update_project(project, @update_attrs)
      assert project.description == "some updated description"
      assert project.status == "some updated status"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = ProjectManagement.update_project(project, @invalid_attrs)
      assert project == ProjectManagement.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = ProjectManagement.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> ProjectManagement.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = ProjectManagement.change_project(project)
    end
  end
end
