defmodule Module.Registry do
  # use GenServer
  # # TODO: implement using the Registry module
  #
  #
  # # client API
  #
  # def start(name, outputs) do
  #   GenServer.start(__MODULE__, {name, outputs})
  # end
  #
  # def get_module_pid(module_name) do
  #   GenServer.call(__MODULE__, {:get_module_pid, module_name})
  # end
  #
  #
  # # callbacks
  #
  # @impl true
  # def init({module_types_map, mods_conn_map, conj_inputs_map}) do
  #   names_to_pids = for {mod_name, {:ok, mod_pid}} <- module_types_map
  #     |> Enum.map(fn {mod_name, type} -> 
  #       case {mod_name, type} do
  #         {"broadcaster", :broadcaster} -> {mod_name, Module.Broadcaster.start("broadcaster", mods_conn_map["broadcaster"])}
  #         {mod_name, :flip_flop}        -> {mod_name, Module.FlipFlop.start(mod_name, mods_conn_map[mod_name])}
  #         {mod_name, :conjunction}      -> {mod_name, Module.Conjunction.start(mod_name, mods_conn_map[mod_name], conj_inputs_map[mod_name])}
  #         {mod_name, :sink}             -> {mod_name, Module.Sink.start(mod_name)}
  #       end
  #     end),
  #     into: %{}, do: {mod_name, mod_pid}
  #
  #   {:ok, names_to_pids}
  # end
  #
  # @impl true
  # def handle_call({:get_module_pid, module_name}, _from, names_to_pids) do
  #   {:reply, names_to_pids[module_name], names_to_pids}
  # end
end
