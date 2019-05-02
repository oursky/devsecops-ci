open Cmdliner

let string_of_in_channel ch =
  let buf = Buffer.create 1024 in
  let rec loop () =
    try
      Buffer.add_channel buf ch 1024 ;
      loop ()
    with End_of_file -> ()
  in
  loop () ; close_in_noerr ch ; Buffer.contents buf

let string_of_file filename =
  let ch = open_in_bin filename in
  string_of_in_channel ch

let file =
  let doc = "The ignore file to check. Default to stdin if not provided" in
  Arg.(value & pos 0 (some non_dir_file) None & info [] ~docv:"FILE" ~doc)

let check filename =
  let filename, s =
    match filename with
    | None ->
        ("<stdin>", string_of_in_channel stdin)
    | Some filename ->
        (filename, string_of_file filename)
  in
  let incidents = Ignorefilelib.check ~filename s in
  match incidents with
  | [] ->
      ()
  | incidents ->
      Format.fprintf Format.err_formatter "%a@." Report.pp_incidents incidents ;
      exit 1

let exits =
  Term.exit_info ~doc:"No incidents were found" 0
  :: Term.exit_info ~doc:"Some incidents were found" 1
  :: Term.default_error_exits

let cmd =
  let doc = "Enforce ignore patterns in ignore files" in
  (Term.(const check $ file), Term.info "ignorefile" ~doc ~exits)

let () = Term.(exit @@ eval ~catch:false cmd)
