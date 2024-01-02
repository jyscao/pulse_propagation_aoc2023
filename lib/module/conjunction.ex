defmodule Module.Conjunction do
  use GenServer
  defstruct [:outputs, :n_outs, :memory, low_sent: 0, high_sent: 0]


  # client API

  def start(name, outputs, inputs) do
    GenServer.start_link(__MODULE__, {outputs, inputs}, name: name)
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def receive_pulse(name, src, pulse) do
    GenServer.call(name, {:receive, src, pulse})
  end

  def send_pulse(name) do
    GenServer.cast(name, :send)
  end


  # callbacks

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
    {:registered_name, src_mod} = Process.info(self(), :registered_name)
    pulse_to_send = if Enum.all?(module_state.memory |> Map.values(), fn pv -> pv == :pulse_high end) do :pulse_low else :pulse_high end

    send_status_all = Map.get(module_state, :outputs)
      |> Enum.map(fn {mod_name, mod_type} -> apply(mod_type, :receive_pulse, [mod_name, src_mod, pulse_to_send]) end)
      |> Enum.all?(fn reply -> reply == :pulse_received end)

    if send_status_all do
      Map.get(module_state, :outputs)
      |> Enum.each(fn {mod_name, mod_type} -> apply(mod_type, :send_pulse, [mod_name]) end)

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
