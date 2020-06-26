open Main

let main () =
  let rec loop r =
    let _ = print_string "scheme # " in
    let str = read_line () in
    let es = List.map (eval initial_env) (Parser.parse str) in
    try (
      let _ = print_string ("=> " ^String.concat "; " (List.map Parser.string_of_sexpr es) ^ "\n") in 
      loop (r + 1)) with Invalid_argument _ -> 
      let _ = print_string ("Expression not simplifiable\n") in loop (r + 1) in 
  loop 0 

let () = main ()
