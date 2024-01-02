defmodule Module.CallbackHelpers do

  def send_pulse(module_state, pulse_to_send) do
    {:registered_name, src_mod} = Process.info(self(), :registered_name)

    send_status_all = Map.get(module_state, :outputs)
      |> Enum.map(fn mod_name -> Module.Client.receive_pulse(mod_name, src_mod, pulse_to_send) end)
      |> Enum.all?(fn reply -> reply == :pulse_received end)

    if send_status_all do
      Map.get(module_state, :outputs)
      |> Enum.each(fn mod_name -> Module.Client.send_pulse(mod_name) end)

      {:noreply, increment_pulse_count(pulse_to_send, module_state)}
    else
      raise("one or more pulse sends failed")
    end
  end

  defp increment_pulse_count(pulse, module_state) do
    if pulse == :pulse_low do
      Map.replace(module_state, :low_sent, module_state.low_sent + module_state.n_outs)
    else
      Map.replace(module_state, :high_sent, module_state.high_sent + module_state.n_outs)
    end
  end

end
