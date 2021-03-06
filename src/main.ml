open Types

let string_of_symbol : sexpr -> string = function
  | Symbol name -> name
  | _ -> failwith "not a symbol"

let initial_env : env = []

let rec eval (env : env) (e : sexpr) : sexpr =
  match e with
  | Atom (_) | Special (_) -> e
  | Symbol (s) -> (fun s -> try List.assoc s env with Not_found -> Symbol (s)) s
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
  | [Special If; e; e'; e''] ->
    begin match eval env e with
    | Atom (Bool b) -> if b then (eval env e') else (eval env e'')
    | _ -> failwith "Syntax error :: If :: condition must be a boolean"
    end
  | [Special Lambda; Call es; es'] -> 
    let xs = List.map string_of_symbol es in Atom (Fun (env, (xs, es')))

  | Special Lambda :: Call es :: e :: es'
  | Call ([Special Lambda; Call es; e]) :: es' ->
    apply env ((eval_special env ([Special Lambda; Call es; e])) :: es')
  | [Special Let; Call([Symbol s; e]); e'] ->
    eval_special env [Special Lambda; Call ([Symbol s]); e'; e]
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
  | _ -> apply env es

and apply (env : env) (es : sexpr list) : sexpr =
  match List.map (eval env) es with
  | Atom (Primitive p) :: es -> apply_primitive p es
  | Atom (Fun (_, (xs, e))) :: es -> apply_function (env, (xs, e)) es 
  | [Atom (a)] -> Atom (a)
  | _ -> Call es

and apply_function (env, (xs, e)) (args : sexpr list) : sexpr =
  eval (extend_env env xs args) e

and extend_env (env : env) (xs : string list) (args : sexpr list) : env = 
  match xs, args with
  | x :: xs, arg :: args -> 
    if arg = Symbol x then extend_env env xs args else 
    (x, arg) :: extend_env env xs args
  | _, [] -> env
  | [], _ -> 
    failwith "Syntax error :: Special :: 
              expression evaluated with too many arguments"

and apply_primitive (p : primitive) (args : sexpr list) : sexpr =
  match args with
  | [_; _] ->
    begin match p, args with
    | (Add | Sub | Mul | Div | Eq | Lt), [Atom (Int (i)); Atom (Int (i'))] ->
      begin match p with
      | Add -> Atom (Int (i + i'))
      | Sub -> Atom (Int (i - i'))
      | Mul -> Atom (Int (i * i'))
      | Div -> Atom (Int (i / i'))
      | Eq -> Atom (Bool (i = i'))
      | Lt -> Atom (Bool (i < i'))
      | _ -> failwith "Syntax error :: Primitive :: unreachable error"
      end
    | (Add | Sub | Mul | Div | Eq | Lt), _ -> Call (Atom (Primitive p) :: args)
    | Cons, [e; e'] ->
      begin match e, e' with
      | Call [], Call [] -> Atom (List [])
      | e, Call [] -> Atom (List [e])
      | e, Atom (List es) -> Atom (List (e :: es))
      | _, _ -> Atom (List [e; e'])
      end
    | _, _ -> failwith "Syntax error :: Primitive :: wrong primitive"
    end
  | [_] ->
    begin match p, args with
    | Car, [e] ->
      begin match e with
      | Atom (List (e :: _)) -> e
      | Atom (List []) -> Atom (List [])
      | _ -> failwith "Syntax error :: Car :: parameter must be a list"
      end
    | Cdr, [e] ->
      begin match e with
      | Atom (List (_ :: es)) -> Atom (List es)
      | Atom (List []) -> Atom (List [])
      | _ -> failwith "Syntax error :: Cdr :: parameter must be a list"
      end
    | Cons, [e] -> Atom (List [e])
    | _, _ -> failwith "Syntax error :: Primitive :: wrong primitive"
    end
  | _ ->
    begin match p, args with
    | Add, Atom (Int i) :: Atom (Int i') :: es ->
      apply_primitive Add ((Atom (Int (i + i'))) :: es)
    | Mul, Atom (Int i) :: Atom (Int i') :: es ->
      apply_primitive Mul ((Atom (Int (i * i'))) :: es)
    | _ -> failwith "Syntax error :: Primitive :: wrong number of arguments"
    end

let example_1 : string = "(+ 1 2)"
let example_2 : string = "(let (y (lambda (x) (+ x 10))) (y 2))"
let example_3 : string = "((lambda (x) (let (a 10) (let (x 20) (+ x 1)))) 20000)"

let main () =
  let evaluate ex = List.map (eval initial_env) (Parser.parse ex) in
  let _ = assert(evaluate example_1 = [Atom (Int 3)]) in
  let _ = assert(evaluate example_2 = [Atom (Int 12)]) in
  let _ = assert(evaluate example_3 = [Atom (Int 21)]) in
  ()

let () = main ()
