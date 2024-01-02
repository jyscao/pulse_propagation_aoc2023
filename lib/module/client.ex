defmodule Module.Client do

  def start(mod_name, mod_type, outputs \\ nil, inputs \\ nil) do
    GenServer.start_link(mod_type, {outputs, inputs}, name: mod_name)
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def receive_pulse(name, src, pulse) do
    GenServer.call(name, {:receive, src, pulse}, 120000)
  end

  def send_pulse(name) do
    GenServer.cast(name, :send)
  end

end
