module StringSet = Set.Make (String)

let required_lines =
  [ ".git"
  ; ".svn"
  ; "*.gpg"
  ; "*.pfx"
  ; "*.pem"
  ; "*.cer"
  ; "*.cert"
  ; "*.p12"
  ; "*.p8"
  ; "*.key"
  ; ".env"
  ; ".env.*"
  ; "docker-compose.override.yml" ]

let comment s = String.length s > 0 && s.[0] = '#'

let empty_line s = String.trim s = ""

let comment_or_empty_line s = comment s || empty_line s

let negate pred a = not (pred a)

let check ?(filename = "<stdin>") s =
  let lines = String.split_on_char '\n' s in
  let lines = List.filter (negate comment_or_empty_line) lines in
  let required_set = StringSet.of_list required_lines in
  let input_set = StringSet.of_list lines in
  let set_diff = StringSet.diff required_set input_set in
  StringSet.to_seq set_diff
  |> Seq.map (fun pattern ->
         { Report.filename
         ; code= Report.Missing_ignore_pattern pattern
         ; severity_level= Report.Error } )
  |> List.of_seq
