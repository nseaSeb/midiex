defmodule Midiex.Voice do
  @moduledoc """
  The Voice context.
  """

  import Ecto.Query, warn: false
  alias Midiex.Repo

  alias Midiex.Voice.Voices

  @doc """
  Returns the list of voice.

  ## Examples

      iex> list_voice()
      [%Voices{}, ...]

  """
  def list_voice do
    Repo.all(Voices)
  end

  def all_voices(id) do
    query =
      from(d in Voices,
        where: d.user_id == ^id,
        or_where: d.is_shared == true
      )

    Repo.all(query)
  end

  @doc """
  Gets a single voices.

  Raises `Ecto.NoResultsError` if the Voices does not exist.

  ## Examples

      iex> get_voices!(123)
      %Voices{}

      iex> get_voices!(456)
      ** (Ecto.NoResultsError)

  """
  def get_voices!(id), do: Repo.get!(Voices, id)

  @doc """
  Creates a voices.

  ## Examples

      iex> create_voices(%{field: value})
      {:ok, %Voices{}}

      iex> create_voices(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_voices(attrs \\ %{}) do
    %Voices{}
    |> Voices.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a voices.

  ## Examples

      iex> update_voices(voices, %{field: new_value})
      {:ok, %Voices{}}

      iex> update_voices(voices, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_voices(%Voices{} = voices, attrs) do
    voices
    |> Voices.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a voices.

  ## Examples

      iex> delete_voices(voices)
      {:ok, %Voices{}}

      iex> delete_voices(voices)
      {:error, %Ecto.Changeset{}}

  """
  def delete_voices(%Voices{} = voices) do
    Repo.delete(voices)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking voices changes.

  ## Examples

      iex> change_voices(voices)
      %Ecto.Changeset{data: %Voices{}}

  """
  def change_voices(%Voices{} = voices, attrs \\ %{}) do
    Voices.changeset(voices, attrs)
  end
end
