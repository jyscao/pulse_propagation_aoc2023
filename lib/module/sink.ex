defmodule Module.Sink do
  use GenServer
  defstruct [low_sent: 0, high_sent: 0, low_received: 0, high_received: 0]


  @impl true
  def init({nil, nil}) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:get_state, _from, module_state) do
    {:reply, module_state, module_state}
  end

  @impl true
  def handle_call({:receive, _src, pulse}, _, module_state) do
    new_state = case pulse do
      :pulse_low  -> %{module_state | low_received: module_state.low_received + 1}
      :pulse_high -> %{module_state | high_received: module_state.high_received + 1}
    end
    {:reply, :pulse_received, new_state}
  end

  @impl true
  def handle_cast(:send, module_state) do
    {:noreply, module_state}
  end
end
