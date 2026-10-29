(* Entry point of the standalone executable, which runs the application
   without a configuration file: the configuration is then the static one
   of Project_name_static_config. It is not used when the application is
   loaded by ocsigenserver from project_name.conf. *)

let () =
  Ocsigen.Server.start
    [ Ocsigen.Server.host
        [Staticmod.run ~dir:"local/var/www/project_name" (); Eliom.App.run ()] ]
