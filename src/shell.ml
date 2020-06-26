open Main

let main () =
  let rec loop r =
    let _ = print_string "scheme # " in
    let str = read_line () in
    let result = 
      match List.map (eval initial_env) (Parser.parse str) with
      | exception (Failure s) -> s ^ "\n"
      | es -> 
        let s = String.concat "; " (List.map Parser.string_of_sexpr es) in
        "=> " ^ s ^ "\n" in
    let _ = print_string(result) in 
    loop (r + 1) in
  loop 0 

let () = main ()
