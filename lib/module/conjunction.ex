defmodule Module.Conjunction do
  use GenServer
  defstruct [:outputs, :n_outs, :memory, low_sent: 0, high_sent: 0]


  @impl true
  def init({outputs, inputs}) do
    memory = for input <- inputs, into: %{}, do: {input, :pulse_low}
    {:ok, %__MODULE__{outputs: outputs, n_outs: length(outputs), memory: memory}}
  end

  @impl true
  def handle_call(:get_state, _from, module_state) do
    {:reply, module_state, module_state}
  end

  @impl true
  def handle_call({:receive, src, pulse}, _, module_state) do
    new_state = %{module_state | memory: Map.replace(module_state.memory, src, pulse)}
    {:reply, :pulse_received, new_state}
  end

  @impl true
  def handle_cast(:send, module_state) do
    pulse_to_send = if Enum.all?(module_state.memory |> Map.values(), fn pv -> pv == :pulse_high end) do :pulse_low else :pulse_high end
    Module.CallbackHelpers.send_pulse(module_state, pulse_to_send)
  end
end
