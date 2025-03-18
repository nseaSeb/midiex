defmodule Midiex.VoiceTest do
  use Midiex.DataCase

  alias Midiex.Voice

  describe "voice" do
    alias Midiex.Voice.Voices

    import Midiex.VoiceFixtures

    @invalid_attrs %{data: nil, name: nil, is_deleted: nil, is_shared: nil, user_id: nil, ex_type: nil, url_demo: nil, url_source: nil}

    test "list_voice/0 returns all voice" do
      voices = voices_fixture()
      assert Voice.list_voice() == [voices]
    end

    test "get_voices!/1 returns the voices with given id" do
      voices = voices_fixture()
      assert Voice.get_voices!(voices.id) == voices
    end

    test "create_voices/1 with valid data creates a voices" do
      valid_attrs = %{data: "some data", name: "some name", is_deleted: true, is_shared: true, user_id: "some user_id", ex_type: "some ex_type", url_demo: "some url_demo", url_source: "some url_source"}

      assert {:ok, %Voices{} = voices} = Voice.create_voices(valid_attrs)
      assert voices.data == "some data"
      assert voices.name == "some name"
      assert voices.is_deleted == true
      assert voices.is_shared == true
      assert voices.user_id == "some user_id"
      assert voices.ex_type == "some ex_type"
      assert voices.url_demo == "some url_demo"
      assert voices.url_source == "some url_source"
    end

    test "create_voices/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Voice.create_voices(@invalid_attrs)
    end

    test "update_voices/2 with valid data updates the voices" do
      voices = voices_fixture()
      update_attrs = %{data: "some updated data", name: "some updated name", is_deleted: false, is_shared: false, user_id: "some updated user_id", ex_type: "some updated ex_type", url_demo: "some updated url_demo", url_source: "some updated url_source"}

      assert {:ok, %Voices{} = voices} = Voice.update_voices(voices, update_attrs)
      assert voices.data == "some updated data"
      assert voices.name == "some updated name"
      assert voices.is_deleted == false
      assert voices.is_shared == false
      assert voices.user_id == "some updated user_id"
      assert voices.ex_type == "some updated ex_type"
      assert voices.url_demo == "some updated url_demo"
      assert voices.url_source == "some updated url_source"
    end

    test "update_voices/2 with invalid data returns error changeset" do
      voices = voices_fixture()
      assert {:error, %Ecto.Changeset{}} = Voice.update_voices(voices, @invalid_attrs)
      assert voices == Voice.get_voices!(voices.id)
    end

    test "delete_voices/1 deletes the voices" do
      voices = voices_fixture()
      assert {:ok, %Voices{}} = Voice.delete_voices(voices)
      assert_raise Ecto.NoResultsError, fn -> Voice.get_voices!(voices.id) end
    end

    test "change_voices/1 returns a voices changeset" do
      voices = voices_fixture()
      assert %Ecto.Changeset{} = Voice.change_voices(voices)
    end
  end
end
