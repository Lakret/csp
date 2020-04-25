use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
  let mut input = String::new();
  std::io::stdin().read_line(&mut input).unwrap();

  println!("Input = {}", input);
  Ok(())
}
