open Types

let string_of_symbol : sexpr -> string = function
  | Symbol name -> name
  | _ -> failwith "not a symbol"

let initial_env : env = []

let eval (_env : env) (_e : sexpr) : sexpr =
  failwith "Not implemented"

and is_special (_es : sexpr list) : bool =
  failwith "Not implemented"

and eval_call (_env : env) (_es : sexpr list) : sexpr =
  failwith "Not implemented"

and eval_special (_env : env) (_es : sexpr list) : sexpr =
  failwith "Not implemented"

and apply (_env : env) (_es : sexpr) : sexpr =
  failwith "Not implemented"

and apply_function (_env : env) (_xs, _e) (_args : sexpr) : sexpr =
  failwith "Not implemented"

and apply_primitive (_p : primitive) (_args : sexpr list) : sexpr =
  failwith "Not implemented"

let example_1 : string = "(+ 1 2)"

let sexpr_example_1 : sexpr =
  Call
    [ Atom (Primitive Add)
    ; Atom (Int 1)
    ; Atom (Int 2)
    ]

let example_2 : string = "(let (y (lambda (x) (+ x 10))) (y 2))"

let sexpr_example_2 : sexpr =
  Call
    [ Special Let
    ; Call
      [ Symbol "y"
      ; Call
        [ Special Lambda
        ; Call [ Symbol "x" ]
        ; Call
          [ Atom (Primitive Add)
          ; Symbol "x"
          ; Atom (Int 10)
          ]
        ]
      ]
    ; Call [ Symbol "y"; Atom (Int 2) ]
    ]

let example_3 : string = "((lambda (x) (let (a 10) (let (x 20) (+ x 1)))) 20000)"

let sexpr_example_3 : sexpr =
  Call
    [ Call
      [ Special Lambda
      ; Call [ Symbol "x" ]
      ; Call
        [ Special Let
        ; Call [ Symbol "a"; Atom (Int 10) ]
        ; Call
          [ Special Let
          ; Call [ Symbol "x"; Atom (Int 20) ]
          ; Call
            [ Atom (Primitive Add)
            ; Symbol "x"
            ; Atom (Int 1)
            ]
          ]
        ]
      ]
    ]

let main () =
  let prog = Parser.parse example_1 in
  let _ = List.map (eval initial_env) prog in
  ()

let () = main ()
