defmodule InputParser do

  def get_connections_map(file) do
    for {name, outputs} <- File.read!(file)
      |> String.split("\n", trim: true)
      |> Stream.map(fn conn_str -> conn_str |> String.trim |> String.split("->", trim: true) end)
      |> Stream.map(fn [name | outputs] -> { name |> String.trim, hd(outputs) |> String.trim |> String.split(", ", trim: true) } end),
      into: %{}, do: {name, outputs}
  end

  def get_module_types_map(conn_map) do
    for {mod_name, type} <- conn_map
      |> Stream.map(fn {name, outputs} ->
        cond do
          name == "broadcaster"          -> [name | outputs]
          String.starts_with?(name, "%") -> [String.trim_leading(name, "%") | outputs]
          String.starts_with?(name, "&") -> [String.trim_leading(name, "&") | outputs]
          true                           -> raise("this should not be reached")
        end
      end)
      |> Enum.reduce([], fn mods_subls, full_ls -> mods_subls ++ full_ls end)
      |> MapSet.new()
      |> Stream.map(fn name ->
        cond do
          name == "broadcaster"               -> {name, Module.Broadcaster}
          Map.has_key?(conn_map, "%" <> name) -> {name, Module.FlipFlop}
          Map.has_key?(conn_map, "&" <> name) -> {name, Module.Conjunction}
          true                                -> {name, Module.Sink}
        end
      end),
      into: %{}, do: {mod_name, type}
  end

  def get_module_outputs(conn_map) do
    for {mod_name, outputs_info} <- conn_map
      |> Stream.map(fn {name, outputs} ->
        case name do
          "broadcaster"             -> {"broadcaster", outputs}
          <<"%", mod_name::binary>> -> {mod_name, outputs}
          <<"&", mod_name::binary>> -> {mod_name, outputs}
          _                         -> raise("this should not be reached")
        end
      end),
      into: %{}, do: {mod_name, outputs_info}
  end

  def get_conj_inputs_map(conn_map) do
    for {conj_name, conj_inputs} <- conn_map
      |> Stream.filter(fn {conj_name, _outputs} -> String.starts_with?(conj_name, "&") end)
      |> Stream.map(fn {conj_name, _outputs} -> conj_name |> String.slice(1..-1) end)
      |> Stream.map(fn conj_name -> {
        conj_name, (for {in_mod, outputs} <- conn_map, conj_name in outputs, do: in_mod |> String.slice(1..-1))}
      end),
      into: %{}, do: {conj_name, conj_inputs}
  end

end


# conn_map = InputParser.get_connections_map("data/circuits.txt")

# conn_map = InputParser.get_connections_map("data/example_1.txt")
# mod_types = InputParser.get_module_types_map(conn_map)
# mod_outputs = InputParser.get_module_outputs(conn_map, mod_types)
# conj_inputs = InputParser.get_conj_inputs_map(conn_map)


### TODO: review this guy's elixir AoC code to learn elixir better
# https://github.com/mathsaey/advent_of_code_utils
# https://github.com/mathsaey/adventofcode



### TODO: also write blog post about day 24 part 2, and use manim to illustrate
### maybe use Julia to do the calculations?
