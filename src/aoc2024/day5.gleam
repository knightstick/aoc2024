import aoc2024/shared
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string

const example = "
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"

pub fn main() {
  example
  |> part1
  |> io.debug

  "inputs/day5.txt"
  |> shared.read
  |> part1
  |> io.debug

  example
  |> part2
  |> io.debug

  "inputs/day5.txt"
  |> shared.read
  |> part2
  |> io.debug

  0
}

fn part1(input: String) {
  let #(rules, updates) =
    input
    |> string.trim
    |> parse

  updates
  |> list.filter(correct_order(_, rules))
  |> list.map(middle_value)
  |> int.sum
}

fn part2(input: String) {
  let #(rules, updates) =
    input
    |> string.trim
    |> parse

  updates
  |> list.filter(incorrect_order(_, rules))
  |> list.map(rule_sort(_, rules))
  |> list.map(middle_value)
  |> int.sum
}

fn parse(input: String) {
  let assert Ok(#(rules, updates)) =
    input
    |> string.split_once("\n\n")

  let rules = parse_rules(rules)
  let updates = parse_updates(updates)

  #(rules, updates)
}

fn parse_rules(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_rule)
}

fn parse_updates(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_update)
}

fn parse_rule(input: String) {
  let assert Ok(#(left, right)) =
    input
    |> string.split_once("|")

  let assert Ok(left) = int.parse(left)
  let assert Ok(right) = int.parse(right)

  #(left, right)
}

fn parse_update(input: String) {
  input
  |> string.split(",")
  |> list.map(fn(num) {
    let assert Ok(num) = int.parse(num)
    num
  })
}

fn correct_order(update, rules) {
  rules
  |> list.all(passes_rule(update, _))
}

fn incorrect_order(update, rules) {
  bool.negate(correct_order(update, rules))
}

fn passes_rule(update, rule) {
  let #(left, right) = rule

  update
  |> list.drop_while(fn(elem) { elem != right })
  |> list.contains(left)
  |> bool.negate
}

fn middle_value(values: List(Int)) {
  let length = list.length(values)

  let assert [mid, ..] =
    values
    |> list.drop(length / 2)

  mid
}

fn rule_sort(update, rules) {
  case rules_sort_pass(update, rules) {
    #(_, False) -> update
    #(update, True) -> rule_sort(update, rules)
  }
}

fn rules_sort_pass(update, rules) {
  rules
  |> list.fold(#(update, False), fn(acc, rule) {
    let #(update, swapped) = acc
    let #(update, this_swapped) = rule_sort_pass(update, rule)

    #(update, swapped || this_swapped)
  })
}

fn rule_sort_pass(update, rule) {
  let #(left, right) = rule

  case list.split_while(update, fn(elem) { elem != right }) {
    // Right isn't in the list
    #(_, []) -> #(update, False)
    #(before, [_, ..after]) -> {
      // Need to check if left is in after
      case list.split_while(after, fn(elem) { elem != left }) {
        // // Left isn't in the list
        #(_, []) -> #(update, False)
        #(before_left, [_, ..after_left]) -> {
          // Need to swap
          let new_update =
            list.flatten([before, [left], before_left, [right], after_left])

          #(new_update, True)
        }
      }
    }
  }
}
