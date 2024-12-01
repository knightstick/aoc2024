import simplifile

pub fn read(path: String) -> String {
  let assert Ok(input) = simplifile.read(path)

  input
}
