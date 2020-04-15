(**************************************************************************)
(*                                                                        *)
(*    Copyright 2019 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(* basic ops *)

type t = string

let of_string s = s
let to_string s = s
let compare s s' =
  let open OpamCompat in
  match compare (String.lowercase_ascii s) (String.lowercase_ascii s') with
  | 0 -> compare s s'
  | i -> i
let to_json s =
  `O [ ("sys_package", `String s) ]
let of_json = function
  | `O dict ->
    (match List.assoc "sys_package" dict with
     | `String s -> Some (of_string s)
     | _ -> None
     | exception Not_found -> None)
  | _ -> None

module O = struct
  type tmp = t
  type t = tmp
  let compare = compare
  let to_string = to_string
  let to_json = to_json
  let of_json = of_json
end

module Set = OpamStd.Set.Make(O)

module Map = OpamStd.Map.Make(O)

let raw_set set =
  OpamStd.String.Set.fold (fun spkg set-> Set.add (of_string spkg) set)
    set Set.empty

type status =
  {
    s_available : Set.t;
    (** Package available but not installed *)

    s_not_found : Set.t;
    (** Package unavailable on this system *)
  }


let status_empty =
  {
    s_available  = Set.empty;
    s_not_found  = Set.empty;
  }

let string_of_status sp =
  Printf.sprintf "available: %s; not_found: %s"
    (Set.to_string sp.s_available)
    (Set.to_string sp.s_not_found)
