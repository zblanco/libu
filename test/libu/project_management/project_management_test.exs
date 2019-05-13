defmodule Libu.ProjectManagementTest do
  use Libu.DataCase

  alias Libu.ProjectManagement

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
