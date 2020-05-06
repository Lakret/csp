use std::error::Error;

use std::collections::HashMap;

// extern crate csp_nif;
use csp_nif::csp::*;

fn main() -> Result<(), Box<dyn Error>> {
  let mut input = String::new();
  std::io::stdin().read_line(&mut input).unwrap();

  println!("Input = {}", input);

  let variables = vec!["x".to_string(), "y".to_string()];
  let mut domains = HashMap::new();
  domains.insert("x".to_string(), 0..10);
  domains.insert("y".to_string(), 0..10);
  let constraint = BinaryConstraint(vec!["x".to_string(), "y".to_string()], Box::new(|x, y| y == x * x));

  let csp = Csp {
    variables,
    domains,
    constraints: vec![constraint],
  };
  Ok(())
}
