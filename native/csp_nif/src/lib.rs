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

// @type variable :: atom
// @type value :: any
// @type domain :: [value]
// @type constraint :: (value -> boolean) | (value, value -> boolean)
// @type assignment :: %{variable => value}

// @type solver_status :: :solved | :reduced | :no_solution
// @type solver_result :: {solver_status, t()}

// @type t :: %__MODULE__{
//         variables: [atom],
//         domains: %{variable => domain},
//         constraints: [Constraint.t()]
//       }

use std::collections::HashMap;

type Variable = String;

pub struct Csp<D, C>
where
  D: Domain,
  C: Constraint<D::Value>,
{
  pub variables: Vec<Variable>,
  pub domains: HashMap<Variable, D>,
  pub constraints: Vec<C>,
}

pub trait Domain {
  type Value;
}

impl Domain for std::ops::Range<i32> {
  type Value = i32;
}

impl Domain for std::ops::Range<f32> {
  type Value = i32;
}

impl Domain for std::ops::Range<f64> {
  type Value = i64;
}

pub trait Constraint<Value> {}

pub struct UnaryConstraint<Value>(pub Vec<Variable>, pub Box<dyn Fn(Value) -> bool>);
pub struct BinaryConstraint<Value>(pub Vec<Variable>, pub Box<dyn Fn(Value, Value) -> bool>);
pub struct EqualityConstraint<Value>(pub Vec<Variable>, pub Value);
pub struct InequalityConstraint<Value>(pub Vec<Variable>, pub Value);

// TODO: implement
impl<Value> Constraint<Value> for UnaryConstraint<Value> {}
impl<Value> Constraint<Value> for BinaryConstraint<Value> {}
impl<Value> Constraint<Value> for EqualityConstraint<Value> {}
impl<Value> Constraint<Value> for InequalityConstraint<Value> {}

pub type Assignment<D> = HashMap<Variable, <D as Domain>::Value>;

pub fn backtrack<D, C>(csp: Csp<D, C>) -> Assignment<D>
where
  C: Constraint<D::Value>,
  D: Domain,
{
  HashMap::new()
}
