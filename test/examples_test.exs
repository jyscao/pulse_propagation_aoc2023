defmodule ExamplesTest do
  use ExUnit.Case, async: true

  @tag ex1: true
  test "example_1 - 1x" do
    {lows, highs} = PulsePropagation.run_system_and_report("data/example_1.txt") |> IO.inspect
    assert lows == 8 and highs == 4
  end

  @tag ex2: true
  test "example_2 - 1x" do
    {lows, highs} = PulsePropagation.run_system_and_report("data/example_2.txt") |> IO.inspect
    assert lows == 4 and highs == 4
  end
end
