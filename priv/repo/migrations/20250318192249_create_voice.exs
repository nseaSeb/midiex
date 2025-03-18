defmodule Midiex.Repo.Migrations.CreateVoice do
  use Ecto.Migration

  def change do
    create table(:voice) do
      add :is_deleted, :boolean, default: false, null: false
      add :is_shared, :boolean, default: false, null: false
      add :name, :string
      add :data, :text
      add :user_id, :string
      add :ex_type, :string
      add :url_demo, :text
      add :url_source, :text

      timestamps()
    end
  end
end
