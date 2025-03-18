defmodule Midiex.Voice.Voices do
  use Ecto.Schema
  import Ecto.Changeset

  schema "voice" do
    field(:data, :string)
    field(:name, :string)
    field(:is_deleted, :boolean, default: false)
    field(:is_shared, :boolean, default: false)
    field(:user_id, :string)
    field(:ex_type, :string, default: "Voices")
    field(:url_demo, :string)
    field(:url_source, :string)

    timestamps()
  end

  @doc false
  def changeset(voices, attrs) do
    voices
    |> cast(attrs, [
      :is_deleted,
      :is_shared,
      :name,
      :data,
      :user_id,
      :ex_type,
      :url_demo,
      :url_source
    ])
    |> validate_required([:is_deleted, :is_shared, :name, :data, :user_id, :ex_type])
  end
end
