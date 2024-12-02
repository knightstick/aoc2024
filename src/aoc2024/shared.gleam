import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn read(path: String) -> String {
  let assert Ok(input) = simplifile.read(path)

  input
}

pub fn numbers(line: String) -> List(Int) {
  line
  |> string.split(on: " ")
  |> list.map(fn(num) {
    let assert Ok(num) = int.parse(num)
    num
  })
}
