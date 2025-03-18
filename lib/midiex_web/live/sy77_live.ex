defmodule MidiexWeb.Sy77Live do
  use MidiexWeb, :live_view
  alias Midiex.Sy77Library
  require Logger

  @impl true
  def mount(params, _session, socket) do
    # Initialisation des assigns
    socket =
      socket
      |> assign(:active_tab, :midi)
      |> assign(:interfaces, %{inputs: [], outputs: []})
      |> assign(:selected_output, nil)
      |> assign(:disable_open, true)
      |> assign(:file, nil)
      |> assign(:file_data, nil)
      |> assign(:voice_data, nil)
      |> open_file(params)
      |> assign(:received_messages, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("upload_file", %{"data" => syx_data, "filename" => filename}, socket) do
    Logger.info("upload file")
    Logger.info(filename)
    # Mettre à jour le socket avec le fichier téléversé
    case Sy77Library.validate_syx_data(syx_data) do
      :ok ->
        Logger.info("ok")

        case Sy77Library.extract_all_voices(syx_data) do
          {:ok, voice_data} ->
            # base64_data = Sy77Library.encode_base64(syx_data)
            base64_data = Jason.encode!(syx_data)

            {:noreply,
             socket
             |> assign(:disable_open, true)
             |> assign(:file, filename)
             |> assign(:file_data, base64_data)
             |> assign(:voice_data, voice_data)}

          {:error, _} ->
            Logger.error("error decoding voice data")

            {:noreply,
             socket
             |> assign(:disable_open, true)
             |> assign(:file, "")
             |> assign(:voice_data, nil)
             |> assign(:file_data, nil)}
        end

      {:error, _} ->
        Logger.info("error")

        {:noreply,
         socket
         |> assign(:disable_open, true)
         |> assign(:file, "")
         |> assign(:voice_data, nil)
         |> assign(:file_data, nil)}
    end
  end

  # Gestion des événements LiveView
  @impl true
  def handle_event("add_to_library", _, socket) do
    user_id = Integer.to_string(socket.assigns.current_user.id)

    param = %{
      "data" => socket.assigns.file_data,
      "name" => socket.assigns.file,
      "user_id" => user_id
    }

    case(Midiex.Voice.create_voices(param)) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Banque ajoutée avec succès !")}

      {:error, _message} ->
        {:noreply,
         socket
         |> put_flash(:error, "Une erreur est survenue !")}
    end
  end

  @impl true
  def handle_event("midi-access-granted", %{"sysexEnabled" => sysex_enabled}, socket) do
    Logger.info("SysEx enabled: #{sysex_enabled}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("file_change", _, socket) do
    {:noreply, assign(socket, :disable_open, false)}
  end

  @impl true
  def handle_event("select_output", %{"output_id" => output_id}, socket) do
    Logger.info("Selected output: #{output_id}")
    {:noreply, assign(socket, :selected_output, output_id)}
  end

  @impl true
  def handle_event("send_sysex", %{"select_output" => output_id}, socket) do
    sysex_data = socket.assigns.file_data
    Logger.info("Sending SysEx to output #{output_id}: #{inspect(sysex_data)}")
    {:noreply, push_event(socket, "send-sysex", %{outputId: output_id, data: sysex_data})}
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

  def extract_voice_name(voice_data) when is_list(voice_data) do
    # Extraire les bytes 6 à 15 (index 5 à 14)
    name_bytes = Enum.slice(voice_data, 34..45)

    # Convertir les bytes en une chaîne ASCII
    name = List.to_string(name_bytes)

    # Supprimer les caractères non imprimables (optionnel)
    String.trim(name)
  end

  def extract_voice_mem(voice_data) when is_list(voice_data) do
    # Extraire le byte à l'index 32
    byte = Enum.at(voice_data, 32)

    # Retourner le byte extrait
    index_to_grid(byte)
  end

  def extract_voice_type(voice_data) when is_list(voice_data) do
    # Extraire le byte à l'index 32
    case Enum.at(voice_data, 33) do
      0 -> "1 AFM Mono"
      1 -> "2 AFM Mono"
      2 -> "4 AFM Mono"
      3 -> "1 AFM Poly"
      4 -> "2 AFM Poly"
      5 -> "1 AWM"
      6 -> "2 AWM"
      7 -> "4 AWM"
      8 -> "1 AFM & 1 AWM"
      9 -> "2 AFM & 2 AWM"
      10 -> "DRUM SET"
      _ -> "_"
    end
  end

  def index_to_grid(index) when index >= 0 and index <= 64 do
    # Calculer la colonne (A, B, C, D)
    # 65 est le code ASCII pour 'A'
    column = <<65 + div(index, 16)>>

    # Calculer la ligne (1 à 16)
    row = rem(index, 16) + 1

    # Retourner la notation de grille
    "#{column}#{row}"
  end

  def open_file(socket, %{"id" => id}) do
    case Midiex.Voice.get_voices!(id) do
      item ->
        {:ok, voice_data} = Sy77Library.extract_all_voices(Jason.decode!(item.data))

        socket
        |> assign(:file, item.name)
        |> assign(:file_data, item.data)
        |> assign(:voice_data, voice_data)

      _ ->
        socket
    end
  end

  def open_file(socket, _) do
    socket
  end
end
