defmodule Midiex.Sy77Library do
  @moduledoc """
  Module pour gérer les fichiers .syx pour Yamaha SY77.
  """

  @syx_header [0xF0, 0x43, 0x00, 0x7A]

  @doc """
  Valide si les données SysEx sont valides pour Yamaha SY77.
  """
  def validate_syx_data(syx_data) when is_list(syx_data) do
    case Enum.take(syx_data, length(@syx_header)) do
      @syx_header -> :ok
      _ -> {:error, "Invalid SY77 SysEx header"}
    end
  end

  def extract_all_voices(syx_data) when is_list(syx_data) do
    case validate_syx_data(syx_data) do
      :ok ->
        # Extraire toutes les voix
        voices = extract_voices(syx_data, [])
        {:ok, voices}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Fonction récursive pour extraire les voix
  defp extract_voices([], acc), do: Enum.reverse(acc)

  defp extract_voices(data, acc) do
    # Trouver le prochain marqueur de début (0xF0)
    case Enum.split_while(data, fn byte -> byte != 0xF0 end) do
      {_, []} ->
        # Aucun autre marqueur de début trouvé
        Enum.reverse(acc)

      {_prefix, rest} ->
        # Trouver le marqueur de fin (0xF7) après le début
        case Enum.split_while(rest, fn byte -> byte != 0xF7 end) do
          {_voice_data, []} ->
            # Aucun marqueur de fin trouvé, la voix est incomplète
            Enum.reverse(acc)

          {voice_data, [0xF7 | remaining_data]} ->
            # Extraire la voix (en incluant 0xF0 et 0xF7)
            voice = [0xF0 | voice_data] ++ [0xF7]
            # Continuer à extraire les voix restantes
            extract_voices(remaining_data, [voice | acc])
        end
    end
  end

  @doc """
  Crée un message SysEx à partir de données de son.
  """
  def create_syx_message(voice_data) when is_list(voice_data) do
    syx_data = @syx_header ++ voice_data ++ [0xF7]
    {:ok, syx_data}
  end

  def hex_string_to_bytes(hex_string) do
    hex_string
    # Diviser la chaîne en segments
    |> String.split(" ", trim: true)
    # Convertir chaque segment en entier
    |> Enum.map(&hex_to_integer/1)
  end

  @doc """
  Convertit un segment hexadécimal (ex: "F0") en un entier (ex: 240).
  """
  def hex_to_integer(hex) do
    # Convertir en base 16
    {int, _} = Integer.parse(hex, 16)
    int
  end
end
