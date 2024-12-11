import aoc2024/shared
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  "inputs/day6.txt"
  |> shared.read
  |> part1
  |> io.debug

  "inputs/day6.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

fn part1(input: String) {
  input
  |> string.trim
  |> parse
  |> process_part1
}

fn part2(input: String) {
  input
  |> string.trim
  |> parse
  |> process_part2
}

type Guard {
  Guard(
    orientation: Orientation,
    position: Position,
    path: List(Position),
    directed_path: Set(#(Position, Orientation)),
  )
}

type LabMap =
  Dict(Position, LabTile)

type Position =
  #(Int, Int)

type LabTile {
  Obstruction
  Floor
}

type Orientation {
  Up
  Right
  Down
  Left
}

fn parse(input: String) -> #(Guard, LabMap) {
  let lines =
    input
    |> string.split("\n")

  let assert #(Some(guard), map) =
    list.index_fold(lines, #(None, dict.new()), parse_line)

  #(guard, map)
}

fn parse_line(
  acc: #(Option(Guard), LabMap),
  line: String,
  row: Int,
) -> #(Option(Guard), LabMap) {
  let #(guard, map) = acc

  line
  |> string.to_graphemes
  |> list.index_fold(#(guard, map), fn(acc, char, col) {
    let #(guard, map) = acc
    let position = #(row, col)
    let tile = parse_tile(char)

    case tile {
      GuardTile(orientation) -> {
        let guard = Guard(orientation, position, [], set.new())
        let map = dict.insert(map, position, Floor)

        #(Some(guard), map)
      }
      Tile(tile_type) -> {
        let map = dict.insert(map, position, tile_type)

        #(guard, map)
      }
    }
  })
}

type TileRead {
  Tile(LabTile)
  GuardTile(Orientation)
}

fn parse_tile(char: String) -> TileRead {
  case char {
    "." -> Tile(Floor)
    "#" -> Tile(Obstruction)
    "^" -> GuardTile(Up)
    ">" -> GuardTile(Right)
    "v" -> GuardTile(Down)
    "<" -> GuardTile(Left)
    _ -> panic
  }
}

fn process_part1(acc) -> Int {
  let #(guard, map) = acc
  let assert NoLoop(guard) = loop(map, guard)

  guard.path
  |> set.from_list
  |> set.size
}

fn process_part2(acc) -> Int {
  let #(guard, map) = acc
  map
  |> dict.keys
  |> list.filter(fn(position) {
    let updated_map = dict.insert(map, position, Obstruction)
    is_loop(updated_map, guard)
  })
  |> list.length
}

type LoopResult {
  Loop(Guard)
  NoLoop(Guard)
}

type StepResult {
  StepAgain(Guard)
  StopSteppingLoop(Guard)
  StopSteppingVoid(Guard)
}

fn loop(map, guard) -> LoopResult {
  case step(map, guard) {
    StepAgain(new_guard) -> loop(map, new_guard)
    StopSteppingLoop(new_guard) -> Loop(new_guard)
    StopSteppingVoid(new_guard) -> NoLoop(new_guard)
  }
}

fn is_loop(map: LabMap, guard: Guard) -> Bool {
  case loop(map, guard) {
    Loop(_) -> True
    NoLoop(_) -> False
  }
}

fn step(map: LabMap, guard: Guard) -> StepResult {
  case next_tile(guard, map) {
    Some(Floor) -> {
      let old_path = guard.directed_path
      let next_guard = advance_guard(guard)

      case
        set.contains(old_path, #(next_guard.position, next_guard.orientation))
      {
        True -> StopSteppingLoop(guard)
        False -> StepAgain(next_guard)
      }
    }
    Some(Obstruction) -> rotate_guard(guard) |> StepAgain
    None -> StopSteppingVoid(guard)
  }
}

fn next_tile(guard: Guard, map: LabMap) -> Option(LabTile) {
  guard
  |> next_position
  |> map_get_tile(map, _)
}

fn next_position(guard: Guard) -> Position {
  let Guard(
    orientation: orientation,
    position: position,
    path: _,
    directed_path: _,
  ) = guard
  let #(row, col) = position

  case orientation {
    Up -> #(row - 1, col)
    Right -> #(row, col + 1)
    Down -> #(row + 1, col)
    Left -> #(row, col - 1)
  }
}

fn map_get_tile(map: LabMap, position: Position) -> Option(LabTile) {
  case dict.get(map, position) {
    Ok(tile) -> Some(tile)
    Error(_) -> None
  }
}

fn advance_guard(guard: Guard) -> Guard {
  let next_position = next_position(guard)
  let path = [next_position, ..guard.path]
  let directed_path =
    set.insert(guard.directed_path, #(next_position, guard.orientation))

  Guard(
    ..guard,
    position: next_position,
    path: path,
    directed_path: directed_path,
  )
}

fn rotate_guard(guard: Guard) -> Guard {
  let next_orientation = case guard.orientation {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }

  Guard(..guard, orientation: next_orientation)
}
