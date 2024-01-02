defmodule ExamplesTest do
  use ExUnit.Case, async: true

  test "example_1 - 1x" do
    PulsePropagation.run_system("data/example_1.txt")
    {lows, highs} = PulsePropagation.get_pulses_sent() |> IO.inspect
    assert lows == 8 and highs == 4
  end

  test "example_2 - 1x" do
    PulsePropagation.run_system("data/example_2.txt")
    {lows, highs} = PulsePropagation.get_pulses_sent() |> IO.inspect
    assert lows == 4 and highs == 4
  end
end
