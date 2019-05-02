type severity_level = Info | Warn | Error

type incident_code =
  | Blacklisted_filename
  | Blacklisted_string
  | Entropy_string
  | Missing_ignore_pattern of string

type incident =
  {filename: string; code: incident_code; severity_level: severity_level}

let int_of_severity_level = function Info -> 0 | Warn -> 1 | Error -> 2

let short_string_of_severity_level = function
  | Info ->
      "I"
  | Warn ->
      "W"
  | Error ->
      "E"

let long_string_of_severity_level = function
  | Info ->
      "INFO"
  | Warn ->
      "WARN"
  | Error ->
      "ERROR"

let code_of_incident_code = function
  | Blacklisted_filename ->
      "B001"
  | Blacklisted_string ->
      "E001"
  | Entropy_string ->
      "E002"
  | Missing_ignore_pattern _ ->
      "E003"

let message_of_incident_code = function
  | Blacklisted_filename ->
      "Blacklisted filename"
  | Blacklisted_string ->
      "Blacklisted string"
  | Entropy_string ->
      "High entropy string"
  | Missing_ignore_pattern s ->
      "Missing ignore pattern `" ^ s ^ "'"

let pp_incident ppf incident =
  let open Format in
  fprintf ppf "@[<v>@[<h>- [%a:%a] %a@]@,           File  : %a@]"
    pp_print_string
    (short_string_of_severity_level incident.severity_level)
    pp_print_string
    (code_of_incident_code incident.code)
    pp_print_string
    (message_of_incident_code incident.code)
    pp_print_string incident.filename

let pp_incidents ppf incidents = Format.pp_print_list pp_incident ppf incidents
