open Types

let string_of_symbol : sexpr -> string = function
  | Symbol name -> name
  | _ -> failwith "not a symbol"

let initial_env : env = []

let rec eval (env : env) (e : sexpr) : sexpr =
  let search s = 
    let rec loop s env =
      match env with
      | (s', e') :: env -> if s = s' then e' else loop s env
      | [] -> e in 
    loop s env in
  match e with
  | Atom (_) | Special (_) -> e
  | Symbol (s) -> search s
  | Call (es) -> eval_call env es

and is_special (es : sexpr list) : bool =
  let rec loop es =
    match es with
    | [] -> false
    | Special _ :: _ | Atom (Fun _) :: _ -> true
    | Call es :: es' -> loop es || loop es'
    | _ :: es -> loop es in 
  loop es

and eval_call (env : env) (es : sexpr list) : sexpr =
  match es with
  | [Call (es)] -> eval_call env es
  | _ -> if is_special es then eval_special env es else apply env es

and eval_special (env : env) (es : sexpr list) : sexpr =
  match es with
  | [Special If; Atom (Bool b); e; e'] -> 
    if b then e else e'
  | [Special Lambda; Call es; es'] -> 
    let env' = (List.map (fun e -> string_of_symbol e, e) es) in
    let xs = List.map string_of_symbol es in 
    Atom (Fun (env', (xs, eval env es')))
  | Special Lambda :: Call es :: e :: es'
  | Call ([Special Lambda; Call es; e]) :: es' ->
    apply env ((eval_special env ([Special Lambda; Call es; e])) :: es')
  | [Special Let; Call([Symbol s; e]); e'] ->
    eval_special env [Special Lambda; Call ([Symbol s]); e'; e]
  
  | [Special If; _; _; _] ->
    failwith "Syntax error :: If :: condition must be a boolean"
  | [Special Lambda; _; _] ->
    failwith "Syntax error :: Lambda :: poorly wrapped symbols"
  | [Special Let; _; _] -> 
    failwith "Syntax error :: Let :: poorly wrapped symbols"
  | Special If :: _ ->
    failwith "Syntax error :: If :: wrong number of arguments, expected 3"
  | Special Lambda :: _ ->
    failwith "Syntax error :: Lambda :: wrong number of arguments, expected 2"
  | Special Let :: _ ->
    failwith "Syntax error :: Let :: wrong number of arguments, expected 2"
  | _ -> Call (es)

and apply (env : env) (es : sexpr list) : sexpr =
  match es with
  | Atom (Primitive p) :: es -> apply_primitive p es
  | Atom (Fun (env', (xs, e))) :: es -> apply_function (env' @ env) (xs, e) es 
  | [Atom (a)] -> Atom (a)
  | _ -> Call (es)

and apply_function (env : env) (_xs, e) (args : sexpr list) : sexpr =
  (* an evil yet working hack *)
  if args = [] then e else
  let rec loop env args =
    match env, args with
    | (x, _) :: env, arg :: args -> (x, arg) :: loop env args
    | (x, e) :: env, [] -> (x, e) :: env
    | [], _ :: _ -> 
      failwith "Syntax error :: Special :: 
                expression evaluated with too many arguments"
    | [], [] -> [] in 
  let env' = loop env args in
  let search s = 
    let rec loop s env =
      match env with
      | (s', e') :: env -> if s = s' then e' else loop s env
      | [] -> e in 
    loop s env' in
  let rec replace e = 
    match e with
    | Symbol s -> search s
    | Call es -> Call (List.map replace es)
    | _ -> e in
  eval env' (replace e)


and apply_primitive (p : primitive) (args : sexpr list) : sexpr =
  match args with
  | [_; _] ->
    begin match List.map (eval initial_env) args with
    | [Atom (Int (i)); Atom (Int (i'))] ->
      begin match p with
      | Add -> Atom (Int (i + i'))
      | Sub -> Atom (Int (i - i'))
      | Mul -> Atom (Int (i * i'))
      | Div -> Atom (Int (i * i'))
      | Eq -> Atom (Bool (i = i'))
      | Lt -> Atom (Bool (i < i'))
      | _ -> failwith "Syntax error :: primitive :: wrong primitive"
      end
    | [e; Atom (List es)] ->
      begin match p with
      | Cons -> Atom (List (e :: es))
      | _ -> failwith "Syntax error :: primitive :: wrong primitive"
      end
    | [e; Call []] ->
      begin match p with
      | Cons -> Atom (List [e])
      | _ -> failwith "Syntax error :: primitive :: wrong primitive"
      end
    | _ -> Call (Atom (Primitive p) :: args)
    end
  | [_] ->
    begin match List.map (eval initial_env) args with
    | [Atom (List (e :: es))] ->
      begin match p with
      | Car -> e
      | Cdr -> Atom (List es)
      | _ -> failwith "Syntax error :: primitive :: wrong primitive"
      end
    | [e] ->
      begin match p with
      | Cons -> Atom (List [e])
      | _ -> failwith "Syntax error :: primitive :: wrong primitive"
      end
    | _ -> failwith "Syntax error :: primitive :: wrong primitive"
    end
  | _ -> failwith "Syntax error :: Primitive :: too few arguments, expected 2"

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
