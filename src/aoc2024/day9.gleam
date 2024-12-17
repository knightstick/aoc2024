import gleam/int
import gleam/io
import gleam/list
import gleam/string

const example = "
2333133121414131402
"

pub fn main() {
  example
  |> part1
  |> io.debug

  // "inputs/day9.txt"
  // |> shared.read
  // |> part1
  // |> io.debug

  example
  |> part2
  |> io.debug

  0
}

fn part1(input: String) {
  input
  |> string.trim
  |> parse
  |> process_disk([], _)
  |> list.reverse
  |> checksum
}

fn part2(input: String) {
  input
  |> string.trim
  |> parse
  |> process_disk_with_full_files
  |> io.debug
  |> checksum_from_files(0, 0, _)
}

fn parse(input: String) -> List(File) {
  input
  |> string.split(on: "")
  |> list.map(fn(num) {
    let assert Ok(num) = int.parse(num)
    num
  })
  |> list.sized_chunk(2)
  |> list.index_map(fn(pair, index) {
    case pair {
      [size, margin] -> File(index, size, margin)
      [size] -> File(index, size, 0)
      _ -> panic
    }
  })
}

type File {
  File(id: Int, size: Int, margin: Int)
}

fn process_disk(acc: List(Int), files: List(File)) {
  case files {
    [] -> acc
    // First file has gone all into the acc, and no free space, can drop it
    [File(_, 0, 0), ..rest] -> process_disk(acc, rest)
    // All data gone in, start packing in data from the end
    [File(first_id, 0, margin), ..rest] -> {
      // this is n^2 hope that's ok - is this is what a deque is for?
      case list.reverse(rest) {
        // All data gone in, drop last file
        [File(_, 0, _), ..rest_rev] -> {
          process_disk(
            acc,
            list.flatten([[File(first_id, 0, margin)], list.reverse(rest_rev)]),
          )
        }
        // There's still data in the last file, pack it in
        [File(last_id, last_size, last_margin), ..rest_rev] -> {
          process_disk(
            [last_id, ..acc],
            list.flatten([
              [File(first_id, 0, margin - 1)],
              list.reverse(rest_rev),
              [File(last_id, last_size - 1, last_margin)],
            ]),
          )
        }
        [] -> acc
      }
    }
    // Start packing data in from the first file
    [File(id, size, margin), ..rest] ->
      process_disk([id, ..acc], [File(id, size - 1, margin), ..rest])
  }
}

fn process_disk_with_full_files(files: List(File)) {
  do_disk_process([], files)
}

fn do_disk_process(acc: List(File), files: List(File)) {
  io.debug("do_disk_process")
  io.debug(acc)
  io.debug(files)

  case list.reverse(files) {
    [] -> acc
    [move_me, extend_me, ..rest_rev] -> {
      let rest = list.reverse(rest_rev)

      let #(no_gaps, others) =
        rest
        |> list.split_while(fn(file) { file.margin < move_me.size })

      case no_gaps, others, extend_me {
        _, [], extend_me if extend_me.margin > move_me.size -> {
          panic as "extend_me.margin > move_me.size"
        }
        // All in no_gaps -> no space
        _, [], _ -> {
          do_disk_process([move_me, ..acc], others)
        }
        no_gaps, [squash_me, ..rest], _ -> {
          let new_files =
            list.flatten([
              no_gaps,
              [File(..squash_me, margin: 0)],
              [File(..move_me, margin: squash_me.margin - move_me.size)],
              [File(..extend_me, margin: extend_me.margin + move_me.size)],
              rest,
            ])

          do_disk_process(acc, new_files)
        }
      }
    }
    [move_me] -> [move_me, ..acc]
  }
}

fn checksum(list) {
  list
  |> list.index_map(fn(id, index) { id * index })
  |> int.sum
}

fn checksum_from_files(acc: Int, index: Int, files: List(File)) {
  case files {
    [] -> acc
    [File(_, 0, 0), ..rest] -> checksum_from_files(acc, index, rest)
    [File(id, 0, margin), ..rest] -> {
      let new_files = [File(id, 0, margin - 1), ..rest]
      checksum_from_files(acc, index + 1, new_files)
    }
    [File(id, size, margin), ..rest] -> {
      let new_acc = acc + index * id
      let new_files = [File(id, size - 1, margin), ..rest]
      checksum_from_files(new_acc, index + 1, new_files)
    }
  }
}
