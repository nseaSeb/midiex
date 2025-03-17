defmodule MidiexWeb.MonitorLive do
  alias Midiex.Sy77Library
  use MidiexWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # Initialisation des assigns
    socket =
      socket
      |> assign(:active_tab, :monitor)
      |> assign(:interfaces, %{inputs: [], outputs: []})
      |> assign(:selected_output, nil)
      |> assign(:file, nil)
      |> assign(:message, "")
      |> assign(:file_data, nil)
      |> assign(:received_messages, [])

    {:ok, socket}
  end

  # Gestion des événements LiveView
  @impl true
  def handle_event("midi-access-granted", %{"sysexEnabled" => sysex_enabled}, socket) do
    Logger.info("SysEx enabled: #{sysex_enabled}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_output", %{"output_id" => output_id}, socket) do
    Logger.info("Selected output: #{output_id}")
    {:noreply, assign(socket, :selected_output, output_id)}
  end

  @impl true
  def handle_event("send_sysex", %{"data" => data, "select_output" => output_id}, socket) do
    # sysex_data =
    #   data
    #   |> String.split(",")
    #   |> Enum.map(&String.trim/1)
    #   |> Enum.filter(&(&1 != ""))
    #   |> Enum.map(&String.to_integer/1)

    # IO.inspect(sysex_data, label: "data")

    # Logger.info("Sending SysEx to output #{output_id}: #{inspect(sysex_data)}")
    # {:noreply, push_event(socket, "send-sysex", %{outputId: output_id, data: sysex_data})}
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_hexa", %{"hexa" => hexa}, socket) do
    value = Sy77Library.hex_string_to_bytes(hexa)

    {:noreply, assign(socket, :message, Jason.encode!(value))}
  end

  @impl true
  def handle_event("midi-message-received", %{"data" => message}, socket) do
    Logger.info("MIDI message received: #{inspect(message)}")
    received_messages = [message | socket.assigns.received_messages]
    {:noreply, assign(socket, :received_messages, received_messages)}
  end

  @impl true
  def handle_event("midi-message-sent", %{"outputId" => output_id, "data" => data}, socket) do
    Logger.info("MIDI message sent to #{output_id}: #{inspect(data)}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("midi-error", %{"message" => message}, socket) do
    Logger.error("MIDI error: #{message}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("midi-interfaces", %{"inputs" => inputs, "outputs" => outputs}, socket) do
    # Convertir les clés en atomes
    inputs =
      Enum.map(inputs, fn input -> Map.new(input, fn {k, v} -> {String.to_atom(k), v} end) end)

    outputs =
      Enum.map(outputs, fn output -> Map.new(output, fn {k, v} -> {String.to_atom(k), v} end) end)

    Logger.info(
      "MIDI interfaces received - Inputs: #{inspect(inputs)}, Outputs: #{inspect(outputs)}"
    )

    # Mettre à jour les interfaces dans les assigns
    socket = assign(socket, :interfaces, %{inputs: inputs, outputs: outputs})
    {:noreply, socket}
  end

  # Gestion des messages LiveView (handle_info)
  @impl true
  def handle_info({:midi_interfaces, interfaces}, socket) do
    Logger.info("MIDI interfaces updated: #{inspect(interfaces)}")
    {:noreply, assign(socket, :interfaces, interfaces)}
  end
end
