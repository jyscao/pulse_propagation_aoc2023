defmodule Module.System do

  def initialize(module_types, module_outputs, conj_inputs) do
    atomize_outputs = fn mods_ls -> mods_ls |> Enum.map(fn {mn, mt} -> {String.to_atom(mn), mt} end) end
    atomize_inputs  = fn mods_ls -> mods_ls |> Enum.map(fn mn -> String.to_atom(mn) end) end

    module_types
    |> Enum.each(fn {mod_name, mod_type} -> 
      case {mod_name, mod_type} do
        {"broadcaster", Module.Broadcaster} -> apply(mod_type, :start, [:broadcaster, atomize_outputs.(module_outputs["broadcaster"])])
        {mod_name, Module.FlipFlop}         -> apply(mod_type, :start, [String.to_atom(mod_name), atomize_outputs.(module_outputs[mod_name])])
        {mod_name, Module.Conjunction}      -> apply(mod_type, :start, [String.to_atom(mod_name), atomize_outputs.(module_outputs[mod_name]), atomize_inputs.(conj_inputs[mod_name])])
        {mod_name, Module.Sink}             -> apply(mod_type, :start, [String.to_atom(mod_name)])
      end
    end)
  end

  def activate_once do
    :pulse_received = Module.Broadcaster.receive_pulse(:broadcaster, :button, :pulse_low)
    Module.Broadcaster.send_pulse(:broadcaster)
  end

  def count_pulses(mod_types) do
    mod_types
    |> Enum.map(fn {mod_name, mod_type} ->
      mod_state = apply(mod_type, :get_state, [String.to_atom(mod_name)])
      {mod_state.low_sent, mod_state.high_sent}
    end)
    |> Enum.reduce({1, 0}, fn {low_curr, high_curr}, {low_tot, high_tot} -> {low_tot + low_curr, high_tot + high_curr} end)
  end
end
