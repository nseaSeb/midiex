defmodule Midiex.Repo do
  use Ecto.Repo,
    otp_app: :midiex,
    adapter: Ecto.Adapters.Postgres
end
