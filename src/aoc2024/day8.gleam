import aoc2024/shared
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  "inputs/day8.txt"
  |> shared.read
  |> part1
  |> io.debug

  "inputs/day8.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

type Roof =
  Dict(String, List(Position))

type Position =
  #(Int, Int)

fn part1(input: String) {
  input
  |> string.trim
  |> parse
  |> process(get_antinodes, _)
}

fn part2(input: String) {
  let #(roof, row_max, col_max) =
    input
    |> string.trim
    |> parse

  let process_part2 = process(
    fn(node1, node2) {
      get_antinodes_with_resonant_harmonics(row_max, col_max, node1, node2)
    },
    _,
  )

  process_part2(#(roof, row_max, col_max))
}

fn parse(input: String) -> #(Roof, Int, Int) {
  let lines = input |> string.split("\n")
  let roof =
    lines
    |> list.index_fold(dict.new(), fn(acc: Roof, line: String, row: Int) {
      dict.combine(acc, roof_line(line, row), fn(list1, list2) {
        list.flatten([list1, list2])
      })
    })

  let row_max = lines |> list.length
  let assert [line, ..] = lines
  let col_max = line |> string.length

  #(roof, row_max, col_max)
}

fn roof_line(line: String, row: Int) -> Dict(String, List(Position)) {
  line
  |> string.to_graphemes
  |> list.index_fold(dict.new(), fn(acc: Roof, char: String, col: Int) {
    case char {
      "." -> acc
      _ -> {
        let entry = dict.new() |> dict.insert(char, [#(row, col)])

        dict.combine(acc, entry, fn(list1, list2) {
          list.flatten([list1, list2])
        })
      }
    }
  })
}

fn process(
  get_antinodes: fn(Position, Position) -> Set(Position),
  data: #(Roof, Int, Int),
) {
  let #(roof, row_max, col_max) = data
  let #(_, antinodes) =
    process_antinodes(get_antinodes, dict.to_list(roof), set.new())

  antinodes
  |> set.filter(fn(pos) { in_bounds(pos, #(row_max, col_max)) })
  |> set.size
}

type RoofList =
  List(#(String, List(Position)))

fn process_antinodes(
  get_antinodes: fn(Position, Position) -> Set(Position),
  roof: RoofList,
  antinodes: Set(Position),
) {
  case roof {
    [] -> #(roof, antinodes)
    [#(_, nodes), ..roof] -> {
      let new_antinodes =
        list.combination_pairs(nodes)
        |> list.fold(antinodes, fn(acc, pair) {
          let #(node1, node2) = pair
          set.union(acc, get_antinodes(node1, node2))
        })

      process_antinodes(get_antinodes, roof, new_antinodes)
    }
  }
}

fn get_antinodes(node1: Position, node2: Position) -> Set(Position) {
  let #(row1, col1) = node1
  let #(row2, col2) = node2

  let row_diff = row2 - row1
  let col_diff = col2 - col1

  set.new()
  |> set.insert(#(row1 - row_diff, col1 - col_diff))
  |> set.insert(#(row2 + row_diff, col2 + col_diff))
}

fn get_antinodes_with_resonant_harmonics(
  row_max: Int,
  col_max: Int,
  node1: Position,
  node2: Position,
) -> Set(Position) {
  do_resonant_harmonics(set.new(), #(row_max, col_max), #(node1, node2), 0)
}

fn do_resonant_harmonics(
  antinodes: Set(Position),
  bounds: #(Int, Int),
  nodes: #(Position, Position),
  mul: Int,
) {
  let #(#(row1, col1), #(row2, col2)) = nodes

  let row_diff = row2 - row1
  let col_diff = col2 - col1

  let antinode1 = #(row1 - row_diff * mul, col1 - col_diff * mul)
  let antinode2 = #(row2 + row_diff * mul, col2 + col_diff * mul)

  case in_bounds(antinode1, bounds), in_bounds(antinode2, bounds) {
    False, False -> antinodes
    _, _ -> {
      let acc =
        antinodes
        |> set.insert(antinode1)
        |> set.insert(antinode2)

      do_resonant_harmonics(acc, bounds, nodes, mul + 1)
    }
  }
}

fn in_bounds(pos: Position, bounds: #(Int, Int)) -> Bool {
  let #(row, col) = pos
  let #(row_max, col_max) = bounds

  row >= 0 && row < row_max && col >= 0 && col < col_max
}
