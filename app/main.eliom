(* Entry module of the application on both sides. The code of the
   application is in the library Project_name (lib/); this module only links
   it. The server part is loaded by the ocsigenserver command from
   project_name.conf, or linked into your own executable (app/main/).
   The client part is the main module of the client program. *)

module%shared Project_name = Project_name
