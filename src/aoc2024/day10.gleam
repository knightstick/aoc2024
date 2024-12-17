import aoc2024/shared
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

type Grid =
  dict.Dict(#(Int, Int), Int)

pub fn main() {
  "inputs/day10.txt"
  |> shared.read
  |> part1
  |> io.debug

  "inputs/day10.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

fn part1(input: String) {
  input
  |> string.trim
  |> parse
  |> process1
}

fn part2(input: String) {
  input
  |> string.trim
  |> parse
  |> process2
}

fn parse(input: String) -> #(Grid, List(#(Int, Int))) {
  let grid =
    input
    |> string.split("\n")
    |> list.index_fold(dict.new(), fn(acc, line, row) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc, char, col) {
        let key = #(row, col)
        let assert Ok(value) = char |> int.parse

        dict.insert(acc, key, value)
      })
    })

  let trail_heads =
    dict.filter(grid, fn(_key, value) { value == 0 }) |> dict.keys

  #(grid, trail_heads)
}

fn process1(data: #(Grid, List(#(Int, Int)))) {
  let #(grid, trail_heads) = data
  let process = process_trail_head(grid, _)

  trail_heads
  |> list.map(process)
  |> int.sum
}

fn process_trail_head(grid: Grid, trail_head: #(Int, Int)) {
  let queue = [trail_head]
  let explored = set.new() |> set.insert(trail_head)

  bfs(grid, queue, explored, 0)
}

fn bfs(
  grid: Grid,
  queue: List(#(Int, Int)),
  explored: Set(#(Int, Int)),
  acc: Int,
) {
  case queue {
    [] -> acc
    [node, ..rest] -> {
      let candidates =
        grid_adjacents(grid, node)
        |> list.filter(fn(adjacent) {
          set.contains(explored, adjacent) == False
        })

      let new_explored =
        candidates
        |> list.fold(explored, fn(explored, candidate) {
          set.insert(explored, candidate)
        })

      let new_queue = list.flatten([rest, candidates])

      let new_acc = case dict.get(grid, node) {
        Ok(9) -> acc + 1
        _ -> acc
      }

      bfs(grid, new_queue, new_explored, new_acc)
    }
  }
}

fn grid_adjacents(grid, node) {
  let #(row, col) = node

  let up = #(row - 1, col)
  let down = #(row + 1, col)
  let left = #(row, col - 1)
  let right = #(row, col + 1)

  [up, down, left, right]
  |> list.filter(fn(adjacent) {
    case dict.get(grid, adjacent) {
      Ok(_) -> True
      _ -> False
    }
  })
  |> list.filter(fn(adjacent) { is_reachable(grid, node, adjacent) })
}

fn is_reachable(grid: Grid, node: #(Int, Int), adjacent: #(Int, Int)) {
  let assert Ok(node_value) = dict.get(grid, node)
  let assert Ok(adjacent_value) = dict.get(grid, adjacent)

  adjacent_value == node_value + 1
}

fn process2(data) {
  let #(grid, trail_heads) = data
  let process = hiking_trails(grid, _)

  trail_heads
  |> list.map(process)
  |> int.sum
}

fn hiking_trails(grid: Grid, node: #(Int, Int)) {
  let candidates = grid_adjacents(grid, node)
  let assert Ok(elevation) = dict.get(grid, node)

  case candidates {
    [] -> {
      case elevation {
        9 -> 1
        _ -> 0
      }
    }
    _ -> {
      candidates
      |> list.map(fn(candidate) { hiking_trails(grid, candidate) })
      |> int.sum
    }
  }
}
