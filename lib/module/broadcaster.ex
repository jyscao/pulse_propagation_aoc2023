defmodule Module.Broadcaster do
  use GenServer
  defstruct [:outputs, :n_outs, low_sent: 0, high_sent: 0]


  @impl true
  def init({outputs, nil}) do
    {:ok, %__MODULE__{outputs: outputs, n_outs: length(outputs)}}
  end

  @impl true
  def handle_call(:get_state, _from, module_state) do
    {:reply, module_state, module_state}
  end

  @impl true
  def handle_call({:receive, :button, :pulse_low}, _, module_state) do
    {:reply, :pulse_received, module_state}
  end

  @impl true
  def handle_cast(:send, module_state) do
    {:registered_name, src_mod} = Process.info(self(), :registered_name)

    send_status_all = Map.get(module_state, :outputs)
      |> Enum.map(fn {mod_name, mod_type} -> Module.Client.receive_pulse(mod_name, src_mod, :pulse_low) end)
      |> Enum.all?(fn reply -> reply == :pulse_received end)

    if send_status_all do
      Map.get(module_state, :outputs)
      |> Enum.each(fn {mod_name, mod_type} -> Module.Client.send_pulse(mod_name) end)

      {:noreply, increment_pulse_low_count(module_state)}
    else
      raise("one or more pulse sends failed")
    end
  end

  defp increment_pulse_low_count(module_state) do
    low_sent = module_state.low_sent + module_state.n_outs
    %{module_state | low_sent: low_sent}
  end
end
