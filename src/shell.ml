open Main
open Types

let main () =
  let rec tostring e =
    match e with
    | Atom (Int i) -> string_of_int i
    | Atom (Bool b) -> string_of_bool b
    | Atom (Str_ s) -> s
    | Atom (List es) -> "[" ^ (String.concat "; " (List.map tostring es)) ^ "]"
    | _ -> raise (Invalid_argument "Not simplifiable") in
  let rec loop r =
    let _ = print_string "scheme # " in
    let str = read_line () in
    let es = List.map (eval initial_env) (Parser.parse str) in
    try (
      let _ = print_string ("=> " ^String.concat "; " (List.map tostring es) ^ "\n") in 
      loop (r + 1)) with Invalid_argument _ -> 
      let _ = print_string ("Expression not simplifiable\n") in loop (r + 1) in 
  loop 0 

let () = main ()
