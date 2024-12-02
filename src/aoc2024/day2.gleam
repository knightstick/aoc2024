import aoc2024/shared
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string

const example = "
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"

pub fn main() {
  example
  |> part1
  |> io.debug

  "inputs/day2.txt"
  |> shared.read
  |> part1
  |> io.debug

  example
  |> part2
  |> io.debug

  "inputs/day2.txt"
  |> shared.read
  |> part2
  |> io.debug
}

pub fn part1(input: String) {
  input
  |> string.trim
  |> parse
  |> list.filter(report_is_safe)
  |> list.length
}

pub fn part2(input: String) {
  input
  |> string.trim
  |> parse
  |> list.filter(report_is_safeish)
  |> list.length
}

fn parse(input: String) -> List(List(Int)) {
  input
  |> string.split(on: "\n")
  |> list.map(shared.numbers)
}

fn report_is_safe(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [one, two, ..] -> {
      case int.compare(one, two) {
        order.Gt -> report_is_safe_desc(report)
        order.Lt -> report_is_safe_asc(report)
        order.Eq -> False
      }
    }
  }
}

fn report_is_safe_desc(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [one, two, ..rest] if one > two && one - two >= 1 && one - two <= 3 ->
      report_is_safe_desc([two, ..rest])
    _ -> False
  }
}

fn report_is_safe_asc(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [one, two, ..rest] if one < two && two - one >= 1 && two - one <= 3 ->
      report_is_safe_asc([two, ..rest])
    _ -> False
  }
}

fn report_is_safeish(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [one, two, ..rest] -> {
      case int.compare(one, two) {
        order.Gt -> report_is_safeish_desc(report)
        order.Lt -> report_is_safeish_asc(report)
        order.Eq -> False
      }
      || report_is_safe([one, ..rest])
      || report_is_safe([two, ..rest])
    }
  }
}

fn report_is_safeish_desc(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [one, two, ..rest] if one > two && one - two >= 1 && one - two <= 3 ->
      report_is_safeish_desc([two, ..rest])
    [one, _two, ..rest] -> report_is_safe_desc([one, ..rest])
  }
}

fn report_is_safeish_asc(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [one, two, ..rest] if one < two && two - one >= 1 && two - one <= 3 ->
      report_is_safeish_asc([two, ..rest])
    [one, _two, ..rest] -> report_is_safe_asc([one, ..rest])
  }
}
