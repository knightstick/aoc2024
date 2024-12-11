import aoc2024/shared
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main() {
  "inputs/day7.txt"
  |> shared.read
  |> part2
  |> io.debug
}

fn part2(input: String) {
  input
  |> string.trim
  |> parse
  |> process_part2
}

fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
}

fn parse_line(line: String) {
  let assert Ok(#(test_value, equation)) = string.split_once(line, ": ")
  let assert Ok(test_value) = int.parse(test_value)
  let equation = shared.numbers(equation)

  #(test_value, equation)
}

fn process_part2(data: List(#(Int, List(Int)))) {
  data
  |> list.filter(could_possibly_be_true)
  |> list.map(fn(pair) { pair.0 })
  |> int.sum
}

fn could_possibly_be_true(pair: #(Int, List(Int))) -> Bool {
  let #(test_value, equation) = pair
  let operations = list.length(equation) - 1
  let operation_combinations = product(operations)

  operation_combinations
  |> list.any(fn(operations) { test_value == calculate(equation, operations) })
}

type Operation {
  Add
  Multiply
  Concatenate
}

fn calculate(equation: List(Int), operations: List(Operation)) -> Int {
  let assert [first, ..rest] = equation

  list.zip(operations, rest)
  |> list.fold(first, fn(acc, pair) {
    let #(operation, num) = pair
    case operation {
      Add -> acc + num
      Multiply -> acc * num
      Concatenate -> {
        let left = int.to_string(acc)
        let right = int.to_string(num)
        let assert Ok(res) = int.parse(left <> right)
        res
      }
    }
  })
}

fn product(n: Int) -> List(List(Operation)) {
  case n {
    0 -> [[]]
    n -> {
      let n_minus_1 = product(n - 1)
      [
        Add,
        Multiply,
        // Comment out Concatenate for part 1
        Concatenate,
      ]
      |> list.flat_map(fn(operation) {
        n_minus_1
        |> list.map(fn(sublist) { [operation, ..sublist] })
      })
    }
  }
}
