defmodule ExamplesTest do
  use ExUnit.Case, async: true

  test "example_1 - 1x" do
    mod_types = PulsePropagation.init_system("data/example_1.txt")
    PulsePropagation.activate
    Process.sleep(10)

    {lows, highs} = PulsePropagation.get_pulses_sent(mod_types)
    assert lows == 8 and highs == 4
  end

  test "example_2 - 1x" do
    mod_types = PulsePropagation.init_system("data/example_2.txt")
    PulsePropagation.activate
    Process.sleep(10)

    {lows, highs} = PulsePropagation.get_pulses_sent(mod_types)
    assert lows == 4 and highs == 4
  end
end
