import aoc2024/shared
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

pub fn main() {
  "inputs/day1.txt"
  |> shared.read
  |> part1
  |> io.debug

  "inputs/day1.txt"
  |> shared.read
  |> part2
  |> io.debug
}

pub fn part1(input: String) -> Int {
  let #(one, two) =
    input
    |> string.trim
    |> parse

  let one = list.sort(one, by: int.compare)
  let two = list.sort(two, by: int.compare)

  list.zip(one, two)
  |> list.map(fn(pair) {
    let #(one, two) = pair
    int.absolute_value(one - two)
  })
  |> int.sum
}

pub fn part2(input: String) {
  let #(one, two) =
    input
    |> string.trim
    |> parse

  let counts = count(two)

  one
  |> list.map(fn(one) {
    let two = dict.get(counts, one)
    let two = result.unwrap(two, 0)

    one * two
  })
  |> int.sum
}

fn count(list: List(Int)) -> Dict(Int, Int) {
  let increment = fn(x) {
    case x {
      Some(i) -> i + 1
      None -> 1
    }
  }

  list.fold(list, dict.new(), fn(acc, x) {
    dict.upsert(acc, x, with: increment)
  })
}

fn parse(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split(on: "\n")
  |> list.map(fn(line: String) {
    let assert Ok(#(one, two)) = string.split_once(line, on: "   ")
    let assert Ok(one) = int.parse(one)
    let assert Ok(two) = int.parse(two)

    #(one, two)
  })
  |> list.unzip
}
