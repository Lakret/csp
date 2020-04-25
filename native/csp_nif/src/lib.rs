extern crate rustler;

use rustler::{Encoder, Env, Error, Term};

mod atoms {
  rustler::rustler_atoms! {
      atom ok;
  }
}

rustler::rustler_export_nifs!("Elixir.CSP.NIF", [("add", 2, add)], None);

fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
  let a: i64 = args[0].decode()?;
  let b: i64 = args[1].decode()?;

  Ok((atoms::ok(), a + b).encode(env))
}

// TODO: backtracking in Rust?
