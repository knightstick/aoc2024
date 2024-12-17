import aoc2024/shared
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub fn main() {
  "inputs/day11.txt"
  |> shared.read
  |> part1
  |> io.debug

  "inputs/day11.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

fn part1(input: String) {
  input
  |> string.trim
  |> shared.numbers
  |> process(25)
}

fn part2(input: String) {
  input
  |> string.trim
  |> shared.numbers
  |> process_fast(75)
  |> dict.values
  |> int.sum
}

fn process(data, n) {
  let assert [head, ..tail] =
    data
    |> list.map(fn(stone) { #(stone, n) })

  blink(head, tail, 0)
}

fn process_fast(data, blinks) {
  data
  |> list.fold(dict.new(), fn(acc, stone) { dict.insert(acc, stone, 1) })
  |> blink_fast(blinks)
}

fn blink(data: #(Int, Int), queue: List(#(Int, Int)), acc: Int) {
  let #(stone, n) = data

  case n, queue {
    0, [] -> acc + 1
    0, [head, ..tail] -> blink(head, tail, acc + 1)
    n, _ -> {
      case blink_stone(stone) {
        [stone] -> blink(#(stone, n - 1), queue, acc)
        [stone1, stone2] ->
          blink(#(stone1, n - 1), [#(stone2, n - 1), ..queue], acc)
        _ -> panic
      }
    }
  }
}

fn blink_fast(stones: Dict(Int, Int), blinks: Int) {
  let dict_update = fn(dict: Dict(k, Int), key: k, count: Int) {
    let increment = fn(x: Option(Int)) -> Int {
      case x {
        Some(i) -> i + count
        None -> count
      }
    }
    dict.upsert(dict, key, increment)
  }

  case blinks {
    0 -> stones
    _ -> {
      let new_stones =
        dict.fold(stones, dict.new(), fn(acc, stone, count) {
          case blink_stone(stone) {
            [stone] -> dict_update(acc, stone, count)
            [stone1, stone2] ->
              dict_update(acc, stone1, count)
              |> dict_update(stone2, count)
            _ -> panic
          }
        })

      blink_fast(new_stones, blinks - 1)
    }
  }
}

fn blink_stone(stone: Int) {
  let stone_str = int.to_string(stone)
  let char_len = string.length(stone_str)

  case stone_str, char_len {
    "0", _ -> [1]
    _, char_len if char_len % 2 == 0 -> {
      let half = char_len / 2
      let left = string.slice(from: stone_str, at_index: 0, length: half)
      let right =
        string.slice(from: stone_str, at_index: half, length: char_len)

      let assert Ok(left) = int.parse(left)
      let assert Ok(right) = int.parse(right)

      [left, right]
    }
    _, _ -> [stone * 2024]
  }
}
