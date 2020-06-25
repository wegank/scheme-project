let try_to_match_var (var : string) : sexpr =
  let ft = Str.first_chars var 1
  and lt = Str.last_chars var 1
  in if ft = "\"" && lt = "\"" then
    TokenString (String.sub var 1 @@ String.length var - 2)
  else try
    TokenNumber (int_of_string var)
  with Failure _ ->
    TokenIdentifier var
