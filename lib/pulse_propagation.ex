defmodule PulsePropagation do
  @moduledoc """
  Documentation for `PulsePropagation`.
  """

  def init_system(module_spec_file) do
    conn_map = InputParser.get_connections_map(module_spec_file)

    mod_types = InputParser.get_module_types_map(conn_map)
    mod_outputs = InputParser.get_module_outputs(conn_map, mod_types)
    conj_inputs = InputParser.get_conj_inputs_map(conn_map)

    Module.System.initialize(mod_types, mod_outputs, conj_inputs)

    mod_types
  end

  def activate(count \\ 1) do
    1..count |> Enum.each(fn _i -> Module.System.activate_once end)
  end

  def get_pulses_sent(mod_types) do
    Module.System.count_pulses(mod_types)
  end
end
