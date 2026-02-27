(* Demo page for Ot_form widgets *)

open%shared Eliom_content.Html
open%shared Eliom_content.Html.F
open%client Js_of_ocaml
open%client Js_of_ocaml_lwt

let%shared section title content =
  div
    ~a:[a_class ["demo-forms-section"]]
    (h3 [txt title] :: content)

let%shared output_line label signal =
  p
    ~a:[a_class ["demo-forms-output"]]
    [ strong [txt (label ^ ": ")]
    ; R.txt (Eliom_shared.React.S.map [%shared fun v -> v] signal) ]

let%shared page () =
  (* -- standard form -- *)
  let name_inp =
    D.Raw.input
      ~a:[ a_input_type `Text
         ; a_placeholder [%i18n Demo.S.form_standard_name] ]
      ()
  in
  let email_inp =
    D.Raw.input
      ~a:[ a_input_type `Email
         ; a_placeholder [%i18n Demo.S.form_standard_email] ]
      ()
  in
  let msg_inp =
    D.Raw.textarea
      ~a:[a_placeholder [%i18n Demo.S.form_standard_message]]
      (txt "")
  in
  let submit_btn =
    D.button
      ~a:[a_button_type `Button; a_class ["button"]]
      [txt [%i18n Demo.S.form_standard_submit]]
  in
  let result_span = D.span [] in
  let name_l = [%i18n Demo.S.form_standard_name] in
  let email_l = [%i18n Demo.S.form_standard_email] in
  let msg_l = [%i18n Demo.S.form_standard_message] in
  let (_ : unit Eliom_client_value.t) =
    [%client
      let btn_el = To_dom.of_element ~%submit_btn in
      let name_el = To_dom.of_input ~%name_inp in
      let email_el = To_dom.of_input ~%email_inp in
      let msg_el = To_dom.of_textarea ~%msg_inp in
      let result_el = To_dom.of_element ~%result_span in
      Lwt.async (fun () ->
          Lwt_js_events.clicks btn_el (fun _ _ ->
              let name = Js.to_string name_el##.value in
              let email = Js.to_string email_el##.value in
              let msg = Js.to_string msg_el##.value in
              result_el##.textContent :=
                Js.some
                  (Js.string
                     (Printf.sprintf "%s: %s, %s: %s, %s: %s"
                        ~%name_l name ~%email_l email ~%msg_l msg));
              Lwt.return_unit))]
  in
  let std_section =
    section [%i18n Demo.S.form_standard_title]
      [ p [txt [%i18n Demo.S.form_standard_desc]]
      ; div [name_inp]
      ; div [email_inp]
      ; div [msg_inp]
      ; div [submit_btn]
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_standard_result] ^ ": ")]
          ; result_span ] ]
  in
  (* -- reactive_input -- *)
  let ri_input, (ri_signal, _ri_set) = Ot_form.reactive_input ~value:"hello" () in
  let ri_section =
    section [%i18n Demo.S.form_reactive_input_title]
      [ p [txt [%i18n Demo.S.form_reactive_input_desc]]
      ; ri_input
      ; output_line [%i18n Demo.S.form_label_value] ri_signal ]
  in
  (* -- reactive_textarea -- *)
  let rt_elt, (rt_signal, _rt_set) =
    Ot_form.reactive_textarea ~resize:true ~a_rows:3
      ~a_placeholder:[%i18n Demo.S.form_placeholder_type_here] ()
  in
  let rt_section =
    section [%i18n Demo.S.form_reactive_textarea_title]
      [ p [txt [%i18n Demo.S.form_reactive_textarea_desc]]
      ; rt_elt
      ; output_line [%i18n Demo.S.form_label_value] rt_signal ]
  in
  (* -- debounced_input -- *)
  let db_input, (db_raw, db_debounced, _db_set) =
    Ot_form.debounced_input ~delay:0.5 ~value:"" ()
  in
  let db_section =
    section [%i18n Demo.S.form_debounced_title]
      [ p [txt [%i18n Demo.S.form_debounced_desc]]
      ; db_input
      ; output_line [%i18n Demo.S.form_label_raw] db_raw
      ; output_line [%i18n Demo.S.form_label_debounced] db_debounced ]
  in
  (* -- password_input -- *)
  let pw_container, _pw_input, (pw_visible_s, _pw_set_visible) =
    Ot_form.password_input ~placeholder:[%i18n Demo.S.form_placeholder_password] ()
  in
  let true_s = [%i18n Demo.S.form_true] in
  let false_s = [%i18n Demo.S.form_false] in
  let pw_section =
    section [%i18n Demo.S.form_password_title]
      [ p [txt [%i18n Demo.S.form_password_desc]]
      ; pw_container
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_visible] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> if v then ~%true_s else ~%false_s]
                 pw_visible_s) ] ]
  in
  (* -- reactive_select -- *)
  let sel_elt, (sel_signal, _sel_set) =
    Ot_form.reactive_select
      ~options:
        [ "fr", "France"
        ; "de", "Germany"
        ; "it", "Italy"
        ; "es", "Spain" ]
      ~selected:"fr" ()
  in
  let sel_section =
    section [%i18n Demo.S.form_select_title]
      [ p [txt [%i18n Demo.S.form_select_desc]]
      ; sel_elt
      ; output_line [%i18n Demo.S.form_label_selected] sel_signal ]
  in
  (* -- reactive_toggle_button -- *)
  let toggle_btn, (toggle_s, _toggle_set) =
    Ot_form.reactive_toggle_button [txt [%i18n Demo.S.form_toggle_label]]
  in
  let on_s = [%i18n Demo.S.form_on] in
  let off_s = [%i18n Demo.S.form_off] in
  let toggle_section =
    section [%i18n Demo.S.form_toggle_title]
      [ p [txt [%i18n Demo.S.form_toggle_desc]]
      ; toggle_btn
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_state] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> if v then ~%on_s else ~%off_s]
                 toggle_s) ] ]
  in
  (* -- checkbox -- *)
  let cb_label, _cb_input =
    Ot_form.checkbox ~style:`Box [txt [%i18n Demo.S.form_checkbox_box]]
  in
  let cb_label2, _cb_input2 =
    Ot_form.checkbox ~style:`Toggle [txt [%i18n Demo.S.form_checkbox_toggle]]
  in
  let cb_label3, _cb_input3 =
    Ot_form.checkbox ~style:`Bullet [txt [%i18n Demo.S.form_checkbox_bullet]]
  in
  let cb_section =
    section [%i18n Demo.S.form_checkbox_title]
      [ p [txt [%i18n Demo.S.form_checkbox_desc]]
      ; div [cb_label]
      ; div [cb_label2]
      ; div [cb_label3] ]
  in
  (* -- reactive_checkbox -- *)
  let rcb =
    Ot_form.reactive_checkbox ~style:`Box [txt [%i18n Demo.S.form_check_me]]
  in
  let rcb_section =
    section [%i18n Demo.S.form_reactive_checkbox_title]
      [ p [txt [%i18n Demo.S.form_reactive_checkbox_desc]]
      ; div [rcb#label]
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_checked] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> if v then ~%true_s else ~%false_s]
                 rcb#value) ]
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_manually_changed] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> if v then ~%true_s else ~%false_s]
                 rcb#manually_changed) ] ]
  in
  (* -- radio_buttons -- *)
  let radio_react = Eliom_shared.React.S.create (Some 0) in
  let radio_labels =
    Ot_form.radio_buttons
      ~selection_react:radio_react ~name:"demo-radio"
      [ [txt [%i18n Demo.S.form_radio_red]]
      ; [txt [%i18n Demo.S.form_radio_green]]
      ; [txt [%i18n Demo.S.form_radio_blue]] ]
  in
  let none_s = [%i18n Demo.S.form_none] in
  let radio_section =
    section [%i18n Demo.S.form_radio_title]
      [ p [txt [%i18n Demo.S.form_radio_desc]]
      ; div radio_labels
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_selection] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | None -> ~%none_s
                     | Some i -> string_of_int i]
                 (fst radio_react)) ] ]
  in
  (* -- int_input / optional_int_input -- *)
  let int_div, int_signal = Ot_form.int_input ~min:0 ~max:100 42 in
  let oint_div, oint_signal = Ot_form.optional_int_input ~min:0 ~max:50 (Some 10) in
  let invalid_s = [%i18n Demo.S.form_invalid] in
  let int_section =
    section [%i18n Demo.S.form_int_input_title]
      [ p [txt [%i18n Demo.S.form_int_input_desc]]
      ; div
          [ strong [txt "int_input: "]; int_div
          ; p
              ~a:[a_class ["demo-forms-output"]]
              [ strong [txt ([%i18n Demo.S.form_label_value] ^ ": ")]
              ; R.txt
                  (Eliom_shared.React.S.map
                     [%shared
                       fun v ->
                         match v with
                         | Ok n -> string_of_int n
                         | Error () -> ~%invalid_s]
                     int_signal) ] ]
      ; div
          [ strong [txt "optional_int_input: "]; oint_div
          ; p
              ~a:[a_class ["demo-forms-output"]]
              [ strong [txt ([%i18n Demo.S.form_label_value] ^ ": ")]
              ; R.txt
                  (Eliom_shared.React.S.map
                     [%shared
                       fun v ->
                         match v with
                         | Ok (Some n) -> string_of_int n
                         | Ok None -> ~%none_s
                         | Error () -> ~%invalid_s]
                     oint_signal) ] ] ]
  in
  (* -- reactive_date_input -- *)
  let date_input, (date_signal, _date_set) =
    Ot_form.reactive_date_input ~value:(2025, 6, 15) ()
  in
  let date_section =
    section [%i18n Demo.S.form_date_title]
      [ p [txt [%i18n Demo.S.form_date_desc]]
      ; date_input
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_date] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | Some (y, m, d) ->
                         Printf.sprintf "%04d-%02d-%02d" y m d
                     | None -> ~%none_s]
                 date_signal) ] ]
  in
  (* -- reactive_time_input -- *)
  let time_input, (time_signal, _time_set) =
    Ot_form.reactive_time_input ~value:(14, 30) ()
  in
  let time_section =
    section [%i18n Demo.S.form_time_title]
      [ p [txt [%i18n Demo.S.form_time_desc]]
      ; time_input
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_time] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | Some (h, m) -> Printf.sprintf "%02d:%02d" h m
                     | None -> ~%none_s]
                 time_signal) ] ]
  in
  (* -- disableable_button -- *)
  let dis_toggle_btn, (dis_s, _dis_set) =
    Ot_form.reactive_toggle_button ~init:false
      [txt [%i18n Demo.S.form_disable_below]]
  in
  let dis_button =
    Ot_form.disableable_button ~disabled:dis_s
      [txt [%i18n Demo.S.form_can_be_disabled]]
  in
  let dis_section =
    section [%i18n Demo.S.form_disableable_title]
      [ p [txt [%i18n Demo.S.form_disableable_desc]]
      ; div [dis_toggle_btn]
      ; div [dis_button] ]
  in
  (* -- prevent_double_submit -- *)
  let pds_button =
    Ot_form.prevent_double_submit
      ~f:[%client fun () -> Lwt_js.sleep 2.0]
      [txt [%i18n Demo.S.form_click_2s]]
  in
  let pds_section =
    section [%i18n Demo.S.form_prevent_double_title]
      [ p [txt [%i18n Demo.S.form_prevent_double_desc]]
      ; pds_button ]
  in
  (* -- input_validation_tools -- *)
  let even_error = [%i18n Demo.S.form_even_error] in
  let val_attrs, val_class, val_result =
    Ot_form.input_validation_tools
      ~init:""
      [%shared
        fun s ->
          if String.length s = 0 then Ok ""
          else
            match int_of_string_opt s with
            | Some n when n mod 2 = 0 -> Ok s
            | _ -> Error ~%even_error]
  in
  let val_input =
    D.Raw.input
      ~a:(a_input_type `Text
         :: a_placeholder [%i18n Demo.S.form_placeholder_even]
         :: val_class :: val_attrs)
      ()
  in
  let () = Ot_form.graceful_invalid_style val_input in
  let ok_prefix = [%i18n Demo.S.form_ok_prefix] in
  let error_prefix = [%i18n Demo.S.form_error_prefix] in
  let val_section =
    section [%i18n Demo.S.form_validation_title]
      [ p [txt [%i18n Demo.S.form_validation_desc]]
      ; val_input
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt ([%i18n Demo.S.form_label_result] ^ ": ")]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | Ok s -> ~%ok_prefix ^ s
                     | Error e -> ~%error_prefix ^ e]
                 val_result) ] ]
  in
  (* -- reactive_fieldset -- *)
  let fs_toggle, (fs_disabled_s, _fs_set) =
    Ot_form.reactive_toggle_button ~init:false
      [txt [%i18n Demo.S.form_disable_fieldset]]
  in
  let fs_input1, _ =
    Ot_form.reactive_input ~value:[%i18n Demo.S.form_field_1] ()
  in
  let fs_input2, _ =
    Ot_form.reactive_input ~value:[%i18n Demo.S.form_field_2] ()
  in
  let fs =
    Ot_form.reactive_fieldset ~disabled:fs_disabled_s
      [ div [strong [txt [%i18n Demo.S.form_fieldset_content]]]
      ; div [fs_input1]
      ; div [fs_input2]
      ; Ot_form.disableable_button
          ~disabled:(Eliom_shared.React.S.const false)
          [txt [%i18n Demo.S.form_button_inside]] ]
  in
  let fs_section =
    section [%i18n Demo.S.form_fieldset_title]
      [ p [txt [%i18n Demo.S.form_fieldset_desc]]
      ; div [fs_toggle]
      ; fs ]
  in
  (* -- lwt_bound_input_enter -- *)
  let enter_output = Eliom_shared.React.S.create "" in
  let enter_input =
    Ot_form.lwt_bound_input_enter
      ~a:[a_placeholder [%i18n Demo.S.form_placeholder_enter]]
      [%client
        fun v ->
          ~%(snd enter_output) ("[" ^ v ^ "]");
          Lwt.return_unit]
  in
  let enter_section =
    section [%i18n Demo.S.form_enter_title]
      [ p [txt [%i18n Demo.S.form_enter_desc]]
      ; enter_input
      ; output_line [%i18n Demo.S.form_label_submitted] (fst enter_output) ]
  in
  Lwt.return
    [ h1 [txt [%i18n Demo.S.form_widgets]]
    ; p [txt [%i18n Demo.S.form_intro]]
    ; std_section
    ; ri_section
    ; rt_section
    ; db_section
    ; pw_section
    ; sel_section
    ; toggle_section
    ; cb_section
    ; rcb_section
    ; radio_section
    ; int_section
    ; date_section
    ; time_section
    ; dis_section
    ; pds_section
    ; val_section
    ; fs_section
    ; enter_section ]

let%shared () =
  Project_name_base.App.register ~service:Demo_services.demo_forms
    ( Project_name_page.Opt.connected_page @@ fun myid_o () () ->
      let%lwt p = page () in
      Project_name_container.page ~a:[a_class ["os-page-demo-forms"]] myid_o p )
