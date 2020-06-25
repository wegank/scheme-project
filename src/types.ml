type sexpr
  = Atom of atom
  | Special of special
  | Symbol of string
  | Call of sexpr list

and atom
  = Int of int
  | Bool of bool
  | Str_ of string
  | Primitive of primitive
  | Fun of env * code

and special
  = If
  | Lambda
  | Let

and primitive
  = Add
  | Sub
  | Mul
  | Div
  | Eq
  | Lt

and env = (string * sexpr) list

and code = (string list * sexpr)
