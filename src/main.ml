open Types

let string_of_symbol : sexpr -> string = function
  | Symbol name -> name
  | _ -> failwith "not a symbol"

let initial_env : env = []

let rec eval (env : env) (e : sexpr) : sexpr =
  failwith "Not implemented"

and is_special (es : sexpr list) : bool =
  failwith "Not implemented"

and eval_call (env : env) (es : sexpr lit) : sexpr =
  failwith "Not implemented"

and eval_special (env : env) (es : sexpr list) : sexpr =
  failwith "Not implemented"

and apply (env : env) (es : sexpr) =
  failwith "Not implemented"

and apply_function env (xs, e) args =
  failwith "Not implemented"

and apply_primitive (p : primitive) (args : sexpr list) : sexpr =
  failwith "Not implemented"

let example_1 = "(+ 1 2)"
let sexpr_example_1 =
  Call
    [ Atom (Primitive Add)
    ; Atom (Int 1)
    ; Atom (Int 2)
    ]
    
let example_2 = "(let (y (lambda (x) (+ x 10))) (y 2))"
let example_3 = "((lambda (x) (let (a 10) (let (x 20) (+ x 1)))) 20000)"

let main () =
  let prog = Parser.parse example_1 in
  let _ List.map (eval initial_env) prog in
  ()

let () = main ()
