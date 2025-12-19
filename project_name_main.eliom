(** This is the main file if you are using static linking without config file.
    It is not used if you are using a config file and ocsigenserver *)

module%shared Project_name = Project_name

let%server _ =
  Ocsigen_server.start
    [
      Ocsigen_server.host
        [ Staticmod.run ~dir:"local/var/www/project_name" (); Eliom.run () ];
    ]
