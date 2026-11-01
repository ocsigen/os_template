(* Entry point of your own executable, which links Ocsigen Server as a
   library and runs the application without a configuration file: the
   configuration is then the static one of Project_name_static_config. It is
   not used when the ocsigenserver command loads the application from
   project_name.conf. *)

let () =
  Ocsigen.Server.start
    [ Ocsigen.Server.host
        [Staticmod.run ~dir:"local/var/www/project_name" (); Eliom.App.run ()] ]
