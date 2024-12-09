import aoc2024/shared
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
import gleam/string

const example = "
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"

const example2 = "
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"

pub fn main() {
  example
  |> part1
  |> io.debug

  "inputs/day3.txt"
  |> shared.read
  |> part1
  |> io.debug

  example2
  |> part2
  |> io.debug

  "inputs/day3.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

fn result(mul: Mul) -> Int {
  case mul {
    Mul(a, b) -> a * b
  }
}

fn part1(input: String) {
  input
  |> string.trim
  |> parse
  |> list.map(result)
  |> int.sum
}

fn part2(input: String) {
  let ops =
    input
    |> string.trim
    |> parse2

  let #(_, result) = do_ops(ops, #(Enabled, 0))

  result
}

type MulEnabled {
  Enabled
  Disabled
}

type Mul {
  Mul(Int, Int)
}

type Op {
  MulOp(Mul)
  Do
  Dont
}

fn do_ops(ops: List(Op), acc) {
  let #(is_enabled, result) = acc

  case ops {
    [] -> acc
    [op, ..rest] -> {
      case op {
        MulOp(Mul(a, b)) -> {
          case is_enabled {
            Enabled -> {
              let new_value = result + a * b
              do_ops(rest, #(Enabled, new_value))
            }
            Disabled -> do_ops(rest, #(Disabled, result))
          }
        }
        Do -> do_ops(rest, #(Enabled, result))
        Dont -> do_ops(rest, #(Disabled, result))
      }
    }
  }
}

fn parse(input: String) -> List(Mul) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  let assert Some(muls) =
    input
    |> regexp.scan(re, _)
    |> list.map(fn(match) {
      case match {
        regexp.Match(_, [Some(a), Some(b)]) -> {
          let assert Ok(a) = int.parse(a)
          let assert Ok(b) = int.parse(b)

          Some(Mul(a, b))
        }

        _ -> None
      }
    })
    |> option.all

  muls
}

fn parse2(input: String) -> List(Op) {
  let mul_re = "mul\\((\\d+),(\\d+)\\)"
  let do_re = "do\\(\\)"
  let dont_re = "don't\\(\\)"

  let combined = mul_re <> "|" <> do_re <> "|" <> dont_re
  let assert Ok(combined_re) = regexp.from_string(combined)

  let assert Ok(result) =
    input
    |> regexp.scan(combined_re, _)
    |> list.map(fn(match) {
      case match {
        regexp.Match("mul" <> _, [Some(a), Some(b)]) -> {
          let assert Ok(a) = int.parse(a)
          let assert Ok(b) = int.parse(b)
          Ok(MulOp(Mul(a, b)))
        }
        regexp.Match("do()", _) -> Ok(Do)
        regexp.Match("don't()", _) -> Ok(Dont)
        _ -> Error("Invalid match")
      }
    })
    |> result.all

  result
}
