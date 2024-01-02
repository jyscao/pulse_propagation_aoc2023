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
    Module.CallbackHelpers.send_pulse(module_state, :pulse_low)
  end
end
