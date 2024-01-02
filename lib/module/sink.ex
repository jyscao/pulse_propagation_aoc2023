defmodule Module.Sink do
  use GenServer
  defstruct [low_sent: 0, high_sent: 0, low_received: 0, high_received: 0]


  # client API

  def start(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def receive_pulse(name, _src, pulse) do
    GenServer.call(name, {:receive, pulse})
  end

  def send_pulse(_name) do
    :pass
  end


  # callbacks

  @impl true
  def init(_) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:get_state, _from, module_state) do
    {:reply, module_state, module_state}
  end

  @impl true
  def handle_call({:receive, pulse}, _, module_state) do
    new_state = case pulse do
      :pulse_low  -> %{module_state | low_received: module_state.low_received + 1}
      :pulse_high -> %{module_state | high_received: module_state.high_received + 1}
    end
    {:reply, :pulse_received, new_state}
  end

end
