import aoc2024/shared
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

fn part1(input: String) {
  let grid =
    input
    |> parse

  [
    count_l_to_r(grid),
    count_t_to_b(grid),
    count_tl_to_br(grid),
    count_bl_to_tr(grid),
  ]
  |> int.sum
}

fn part2(input: String) {
  let grid =
    input
    |> parse

  let Grid(dict: dict, width: _, height: _) = grid

  dict
  |> dict.keys
  |> list.map(get_nine(grid, _))
  |> list.map(score_nine)
  |> int.sum
}

pub fn main() {
  "inputs/day4.txt"
  |> shared.read
  |> part1
  |> io.debug

  "inputs/day4.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

type Coord {
  Coord(Int, Int)
}

type Grid {
  Grid(dict: Dict(Coord, String), width: Int, height: Int)
}

fn parse(input: String) -> Grid {
  let chars: List(List(String)) =
    input
    |> string.trim
    |> string.split(on: "\n")
    |> list.map(string.to_graphemes)

  let height = list.length(chars)
  let assert [first_line, ..] = chars
  let width = list.length(first_line)

  chars
  |> list.index_fold(dict.new(), fn(acc, line, row) {
    line
    |> list.index_fold(acc, fn(acc, char, col) {
      dict.insert(acc, Coord(row, col), char)
    })
  })
  |> Grid(dict: _, width: width, height: height)
}

fn grid_get(grid: Grid, coord: Coord) {
  let Grid(dict: dict, width: _, height: _) = grid

  dict.get(dict, coord)
}

fn count_l_to_r(grid: Grid) {
  let Grid(dict: _, width: _, height: height) = grid

  list.range(0, height - 1)
  |> list.map(count_l_to_r_row(grid, _))
  |> int.sum
}

fn count_t_to_b(grid: Grid) {
  let Grid(dict: _, width: width, height: _) = grid

  list.range(0, width - 1)
  |> list.map(count_t_to_b_col(grid, _))
  |> int.sum
}

fn count_tl_to_br(grid: Grid) {
  let Grid(dict: _, width: _, height: height) = grid

  list.range(0, height - 1)
  |> list.map(count_tl_to_br_row(grid, _))
  |> int.sum
}

fn count_bl_to_tr(grid: Grid) {
  let Grid(dict: _, width: _, height: height) = grid

  list.range(0, height - 1)
  |> list.map(count_bl_to_tr_row(grid, _))
  |> int.sum
}

fn count_l_to_r_row(grid: Grid, row: Int) {
  let Grid(dict: _, width: width, height: _) = grid

  list.range(0, width - 1)
  |> list.map(get_four_forwards(grid, row, _))
  |> list.map(score_four)
  |> int.sum
}

fn count_tl_to_br_row(grid: Grid, row: Int) {
  let Grid(dict: _, width: width, height: _) = grid

  list.range(0, width - 1)
  |> list.map(get_four_down_right(grid, row, _))
  |> list.map(score_four)
  |> int.sum
}

fn count_bl_to_tr_row(grid: Grid, row: Int) {
  let Grid(dict: _, width: width, height: _) = grid

  list.range(0, width - 1)
  |> list.map(get_four_up_right(grid, row, _))
  |> list.map(score_four)
  |> int.sum
}

fn count_t_to_b_col(grid: Grid, col: Int) {
  let Grid(dict: _, width: _, height: height) = grid

  list.range(0, height - 1)
  |> list.map(get_four_downwards(grid, _, col))
  |> list.map(score_four)
  |> int.sum
}

fn get_four_forwards(grid: Grid, row: Int, col: Int) {
  list.range(col, col + 3)
  |> list.map(fn(col) { Coord(row, col) })
  |> list.map(fn(coord) { grid_get(grid, coord) })
  |> result.all
}

fn get_four_downwards(grid: Grid, row: Int, col: Int) {
  list.range(row, row + 3)
  |> list.map(fn(row) { Coord(row, col) })
  |> list.map(fn(coord) { grid_get(grid, coord) })
  |> result.all
}

fn get_four_down_right(grid: Grid, row: Int, col: Int) {
  list.range(row, row + 3)
  |> list.index_map(fn(row, i) { Coord(row, col + i) })
  |> list.map(fn(coord) { grid_get(grid, coord) })
  |> result.all
}

fn get_four_up_right(grid: Grid, row: Int, col: Int) {
  list.range(row, row - 3)
  |> list.index_map(fn(row, i) { Coord(row, col + i) })
  |> list.map(fn(coord) { grid_get(grid, coord) })
  |> result.all
}

fn score_four(result: Result(List(String), _)) {
  case result {
    Ok(["X", "M", "A", "S"]) -> 1
    Ok(["S", "A", "M", "X"]) -> 1
    _ -> 0
  }
}

fn get_nine(grid: Grid, coord: Coord) {
  let Grid(dict: _, width: _, height: _) = grid
  let Coord(row, col) = coord

  list.range(row - 1, row + 1)
  |> list.map(fn(row) {
    list.range(col - 1, col + 1)
    |> list.map(fn(col) { Coord(row, col) })
  })
  |> list.flatten
  |> list.map(fn(coord) { grid_get(grid, coord) })
  |> result.all
}

fn score_nine(result) {
  case result {
    Ok(["M", _, "M", _, "A", _, "S", _, "S"]) -> 1
    Ok(["S", _, "M", _, "A", _, "S", _, "M"]) -> 1
    Ok(["S", _, "S", _, "A", _, "M", _, "M"]) -> 1
    Ok(["M", _, "S", _, "A", _, "M", _, "S"]) -> 1
    _ -> 0
  }
}
