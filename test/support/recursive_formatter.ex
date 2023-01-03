defmodule CanonicalLogs.Support.RecursiveFormatter do
  def format(level, message, timestamp, metadata) do
    beginning = "#{format_value(timestamp)} [#{level}] #{message}"

    top_level_meta =
      metadata
      |> Enum.map(fn {key, value} ->
        "#{key}=#{format_value(value)}"
      end)
      |> Enum.filter(&(!String.ends_with?(&1, "=")))
      |> Enum.join(" ")

    "#{beginning} #{top_level_meta}\n"
  rescue
    error ->
      inspect(error)
      # error -> "could not format: #{inspect({level, message, metadata})}"
  end

  defp format_value(map) when is_map(map) do
    inner =
      map
      |> Enum.map(fn {key, value} ->
        "#{key}=#{format_value(value)}"
      end)
      |> Enum.filter(&(!String.ends_with?(&1, "=")))
      |> Enum.join(", ")

    "{#{inner}}"
  end

  defp format_value(list) when is_list(list) do
    if Keyword.keyword?(list) do
      inner =
        list
        |> Enum.map(fn {key, value} ->
          "#{key}=#{format_value(value)}"
        end)
        |> Enum.filter(&(!String.ends_with?(&1, "=")))
        |> Enum.join(", ")

      "[#{inner}]"
    else
      inner =
        list
        |> Enum.map(&format_value/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.join(", ")

      "[#{inner}]"
    end
  end

  defp format_value({{year, month, day}, {hour, minute, second, millisecond}}) do
    "#{year}-#{lpad(month)}-#{lpad(day)} #{lpad(hour)}:#{lpad(minute)}:#{lpad(second)}.#{lpad(millisecond, 3)}"
  end

  defp format_value(value) do
    to_string(value)
  rescue
    error -> nil
  end

  defp lpad(num, length \\ 2) do
    num
    |> to_string()
    |> String.pad_leading(length, "0")
  end
end
