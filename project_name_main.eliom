(** This is the main file if you are using static linking without config file.
    It is not used if you are using a config file ans ocsigenserver *)

module%shared Project_name= Project_name

let%server _ =
  Ocsigen_config.set_ports [`All, 8080];
  Ocsigen_config.set_veryverbose ();
  Ocsigen_config.set_logdir "local/var/log/project_name";
  Ocsigen_config.set_datadir "local/var/data/project_name";
  Ocsigen_config.set_uploaddir (Some "/tmp");
  Ocsigen_config.set_usedefaulthostname true;
  Ocsigen_config.set_debugmode true;
  Ocsigen_config.set_command_pipe "local/var/run/project_name-cmd";
  Ocsigen_server.start
    [ Ocsigen_server.host
        [Staticmod.run ~dir:"local/var/www/project_name" (); Eliom.run ()] ]
