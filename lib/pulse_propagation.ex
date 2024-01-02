defmodule PulsePropagation do
  @moduledoc """
  Documentation for `PulsePropagation`.
  """

  defp parse_input(module_spec_file) do
    conn_map = InputParser.get_connections_map(module_spec_file)

    mod_types = InputParser.get_module_types_map(conn_map)
    mod_outputs = InputParser.get_module_outputs(conn_map, mod_types)
    conj_inputs = InputParser.get_conj_inputs_map(conn_map)

    {mod_types, mod_outputs, conj_inputs}
  end

  def run_system_and_report(module_spec_file) do
    parsed_input_maps = parse_input(module_spec_file)
    Module.System.start(parsed_input_maps)
    Module.System.activate_once()
    Module.System.get_pulses_sent
  end
end
