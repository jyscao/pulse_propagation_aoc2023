defmodule Module.FlipFlop do
  use GenServer
  defstruct [:outputs, :n_outs, :last_received, is_on: false, low_sent: 0, high_sent: 0]


  @impl true
  def init({outputs, nil}) do
    {:ok, %__MODULE__{outputs: outputs, n_outs: length(outputs)}}
  end

  @impl true
  def handle_call(:get_state, _from, module_state) do
    {:reply, module_state, module_state}
  end

  @impl true
  def handle_call({:receive, _src, pulse}, _, module_state) do
    new_state = case pulse do
      :pulse_low  -> Map.merge(module_state, %{is_on: not module_state.is_on, last_received: :pulse_low})
      :pulse_high -> %{module_state | last_received: :pulse_high}
    end
    {:reply, :pulse_received, new_state}
  end

  @impl true
  def handle_cast(:send, module_state) do
    if module_state.last_received == :pulse_high do
      {:noreply, module_state}
    else
      pulse_to_send = if module_state.is_on do :pulse_high else :pulse_low end
      Module.CallbackHelpers.send_pulse(module_state, pulse_to_send)
    end
  end
end
