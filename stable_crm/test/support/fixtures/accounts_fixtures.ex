defmodule StableCrm.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StableCrm.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        role: "some role"
      })
      |> StableCrm.Accounts.create_user()

    user
  end
end
