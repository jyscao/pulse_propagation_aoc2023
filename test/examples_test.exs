defmodule ExamplesTest do
  use ExUnit.Case, async: true

  @tag t1: true
  test "example_1 - 1x" do
    {lows, highs} = PulsePropagation.run_system_and_report("data/example_1.txt") |> IO.inspect
    assert lows == 8 and highs == 4
  end

  @tag t2: true
  test "example_2 - 1x" do
    {lows, highs} = PulsePropagation.run_system_and_report("data/example_2.txt") |> IO.inspect
    assert lows == 4 and highs == 4
  end

  @tag t3: true
  @tag timeout: 20000
  test "example_1 - 1000x" do
    {lows, highs} = PulsePropagation.run_system_and_report("data/example_1.txt", 1000) |> IO.inspect
    assert lows == 8000 and highs == 4000
  end

  @tag t4: true
  @tag timeout: 20000
  test "example_2 - 1000x" do
    {lows, highs} = PulsePropagation.run_system_and_report("data/example_2.txt", 1000) |> IO.inspect
    assert lows == 4250 and highs == 2750
  end

  @tag real: true
  @tag timeout: :infinity
  test "real - 1000x" do
    # {lows, highs} = PulsePropagation.run_system_and_report("data/circuits.txt", 1) |> IO.inspect

    {lows, highs} = PulsePropagation.run_system_and_report("data/circuits.txt", 100) |> IO.inspect
    # assert lows * highs == 825167435
    # # assert lows == 4250 and highs == 2750
  end
end
