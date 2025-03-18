defmodule Midiex.VoiceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Midiex.Voice` context.
  """

  @doc """
  Generate a voices.
  """
  def voices_fixture(attrs \\ %{}) do
    {:ok, voices} =
      attrs
      |> Enum.into(%{
        data: "some data",
        ex_type: "some ex_type",
        is_deleted: true,
        is_shared: true,
        name: "some name",
        url_demo: "some url_demo",
        url_source: "some url_source",
        user_id: "some user_id"
      })
      |> Midiex.Voice.create_voices()

    voices
  end
end
