defmodule MidiexWeb.LibraryLive do
  use MidiexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       active_tab: :library
     )}
  end
end
