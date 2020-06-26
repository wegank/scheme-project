open Types

let split_expressions (chars : string) : string list =
  let open_matcher = Str.regexp "("
  and close_matcher = Str.regexp ")"
  and newline_matcher = Str.regexp "\n"
  in
    chars
    |> Str.global_replace newline_matcher " "
    |> Str.global_replace open_matcher " ( "
    |> Str.global_replace close_matcher " ) "
    |> Str.split @@ Str.regexp " "
    |> List.filter @@ fun x -> x <> ""

let match_atom (atom : string) : atom =
  let ft = Str.first_chars atom 1
  and lt = Str.last_chars atom 1
  in if ft = "\"" && lt = "\"" then
    Str_ (String.sub atom 1 @@ String.length atom - 2)
  else if atom = "true" then
    Bool true
  else if atom = "false" then
    Bool false
  else
    Int (int_of_string atom)

let try_to_match_atom (atom : string) : sexpr =
  try
    Atom (match_atom atom)
  with Failure _ ->
    Symbol atom

let sexpr_of_string x : sexpr =
  match x with
  | "+"      -> Atom (Primitive Add)
  | "-"      -> Atom (Primitive Sub)
  | "*"      -> Atom (Primitive Mul)
  | "/"      -> Atom (Primitive Div)
  | "="      -> Atom (Primitive Eq)
  | "<"      -> Atom (Primitive Lt)
  | "if"     -> Special If
  | "lambda" -> Special Lambda
  | "let"    -> Special Let
  | "cons"   -> Atom (Primitive Cons)
  | "car"    -> Atom (Primitive Car)
  | "cdr"    -> Atom (Primitive Cdr)
  | others   -> try_to_match_atom others

let rec group_expressions (acc : sexpr list) (chars : string list) =
  match chars with
  | [] -> (acc, [])
  | hd :: tl ->
    if hd = "(" then
      let (expr, next) = group_expressions [] tl in
      group_expressions (expr @ acc) next
    else if hd = ")" then
      ([ Call (List.rev acc) ], tl)
    else
      group_expressions (sexpr_of_string hd :: acc) tl

let parse (program : string) : sexpr list =
  program
  |> split_expressions
  |> group_expressions []
  |> fst
  |> List.rev
