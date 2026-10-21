(** This is the main file if you are using static linking without config file.
    It is not used if you are using a config file and ocsigenserver *)

let%server _ =
  Ocsigen.Server.start
    [ Ocsigen.Server.host
        [Staticmod.run ~dir:"local/var/www/project_name" (); Eliom.App.run ()] ]
