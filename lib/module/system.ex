defmodule Module.System do
  use GenServer


  # client API

  def start(parsed_input_maps) do
    GenServer.start(__MODULE__, parsed_input_maps, name: __MODULE__)
  end

  def activate(run_count) do
    GenServer.call(__MODULE__, {:activate, run_count}, 120000)
  end

  def get_pulses_sent(run_count) do
    GenServer.call(__MODULE__, {:count_pulses, run_count})
  end


  # callbacks

  @impl true
  def init({module_types, module_outputs, conj_inputs}) do
    atomize  = fn mods_ls -> mods_ls |> Enum.map(fn mn -> String.to_atom(mn) end) end

    module_types
    |> Enum.each(fn {mod_name, mod_type} -> 
      case {mod_name, mod_type} do
        {"broadcaster", Module.Broadcaster} -> Module.Client.start(:broadcaster, mod_type, atomize.(module_outputs["broadcaster"]))
        {mod_name, Module.FlipFlop}         -> Module.Client.start(String.to_atom(mod_name), mod_type, atomize.(module_outputs[mod_name]))
        {mod_name, Module.Conjunction}      -> Module.Client.start(String.to_atom(mod_name), mod_type, atomize.(module_outputs[mod_name]), atomize.(conj_inputs[mod_name]))
        {mod_name, Module.Sink}             -> Module.Client.start(String.to_atom(mod_name), mod_type)
      end
    end) |> IO.inspect

    {:ok, module_types}
  end

  @impl true
  def handle_call({:activate, run_count}, _from, module_types_map) do
    1..run_count
    |> Enum.each(fn _i -> activate_once() ; wait_till_system_is_stable(module_types_map) end)

    {:reply, :ok, module_types_map}
  end

  @impl true
  def handle_call({:count_pulses, run_count}, _from, module_types_map) do
    pulses_sent = module_types_map
    |> Enum.map(fn {mod_name, _mod_type} ->
      mod_state = Module.Client.get_state(String.to_atom(mod_name))
      {mod_state.low_sent, mod_state.high_sent}
    end)
    |> Enum.reduce({run_count, 0}, fn {low_curr, high_curr}, {low_tot, high_tot} -> {low_tot + low_curr, high_tot + high_curr} end)

    {:reply, pulses_sent, module_types_map}
  end

  def activate_once do
    :pulse_received = Module.Client.receive_pulse(:broadcaster, :button, :pulse_low)
    Module.Client.send_pulse(:broadcaster)
  end

  defp wait_till_system_is_stable(mod_types) do
    wait_factor = map_size(mod_types)
    if system_is_stable?(mod_types) do
      true
    else
      Process.sleep(2 * wait_factor)
      wait_till_system_is_stable(mod_types)
    end
  end

  defp system_is_stable?(mod_types) do
    mod_types
    |> Enum.map(fn {mod_name, _t} -> 
      {:message_queue_len, msgq_len} = Process.info(Process.whereis(String.to_atom(mod_name)), :message_queue_len)
      msgq_len
    end)
    |> Enum.all?(fn msgq_len -> msgq_len === 0 end)
  end
end
