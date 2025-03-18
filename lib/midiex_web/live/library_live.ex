defmodule MidiexWeb.LibraryLive do
  use MidiexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(active_tab: :library)
     |> assign(items: [])
     |> get_items()}
  end

  @impl true
  def handle_event("share", %{"id" => id}, socket) do
    item = Midiex.Voice.get_voices!(id)
    Midiex.Voice.update_voices(item, %{"is_shared" => true})
    get_items(socket)
  end

  @impl true
  def handle_event("unshare", %{"id" => id}, socket) do
    item = Midiex.Voice.get_voices!(id)
    Midiex.Voice.update_voices(item, %{"is_shared" => false})
    get_items(socket)
  end

  defp get_items(socket) do
    user_id = Integer.to_string(socket.assigns.current_user.id)
    items = Midiex.Voice.all_voices(user_id)
    socket |> assign(items: items)
  end
end
