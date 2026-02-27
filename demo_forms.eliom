(* Demo page for Ot_form reactive widgets *)

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
  (* -- reactive_input -- *)
  let ri_input, (ri_signal, _ri_set) = Ot_form.reactive_input ~value:"hello" () in
  let ri_section =
    section "reactive_input"
      [ p [txt "A reactive text input. The value is displayed below in real time."]
      ; ri_input
      ; output_line "Value" ri_signal ]
  in
  (* -- reactive_textarea -- *)
  let rt_elt, (rt_signal, _rt_set) =
    Ot_form.reactive_textarea ~resize:true ~a_rows:3
      ~a_placeholder:"Type here..." ()
  in
  let rt_section =
    section "reactive_textarea"
      [ p [txt "A textarea with auto-resize. Try typing multiple lines."]
      ; rt_elt
      ; output_line "Value" rt_signal ]
  in
  (* -- debounced_input -- *)
  let db_input, (db_raw, db_debounced, _db_set) =
    Ot_form.debounced_input ~delay:0.5 ~value:"" ()
  in
  let db_output_span = D.span [txt ""] in
  let db_section =
    section "debounced_input"
      [ p [txt "The raw signal updates on every keystroke. \
                The debounced signal updates after 0.5s of inactivity."]
      ; db_input
      ; output_line "Raw" db_raw
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Debounced: "]
          ; db_output_span ] ]
  in
  let (_ : unit Eliom_client_value.t) =
    [%client
      let span = To_dom.of_element ~%db_output_span in
      ignore
        (React.S.map
           (fun v -> span##.textContent := Js.some (Js.string v))
           ~%db_debounced)]
  in
  (* -- password_input -- *)
  let pw_container, _pw_input, (pw_visible_s, _pw_set_visible) =
    Ot_form.password_input ~placeholder:"Enter password" ()
  in
  let pw_section =
    section "password_input"
      [ p [txt "A password input with a visibility toggle button."]
      ; pw_container
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Visible: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> string_of_bool v]
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
    section "reactive_select"
      [ p [txt "A select element with reactive tracking."]
      ; sel_elt
      ; output_line "Selected" sel_signal ]
  in
  (* -- reactive_toggle_button -- *)
  let toggle_btn, (toggle_s, _toggle_set) =
    Ot_form.reactive_toggle_button [txt "Toggle me"]
  in
  let toggle_section =
    section "reactive_toggle_button"
      [ p [txt "A button that alternates between on/off states."]
      ; toggle_btn
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "State: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> if v then "ON" else "OFF"]
                 toggle_s) ] ]
  in
  (* -- checkbox -- *)
  let cb_label, _cb_input = Ot_form.checkbox ~style:`Box [txt "Box style"] in
  let cb_label2, _cb_input2 =
    Ot_form.checkbox ~style:`Toggle [txt "Toggle style"]
  in
  let cb_label3, _cb_input3 =
    Ot_form.checkbox ~style:`Bullet [txt "Bullet style"]
  in
  let cb_section =
    section "checkbox"
      [ p [txt "Checkboxes with different styles."]
      ; div [cb_label]
      ; div [cb_label2]
      ; div [cb_label3] ]
  in
  (* -- reactive_checkbox -- *)
  let rcb = Ot_form.reactive_checkbox ~style:`Box [txt "Check me"] in
  let rcb_section =
    section "reactive_checkbox"
      [ p [txt "A reactive checkbox. The state is tracked via a signal."]
      ; div [rcb#label]
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Checked: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> string_of_bool v]
                 rcb#value) ]
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Manually changed: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared fun v -> string_of_bool v]
                 rcb#manually_changed) ] ]
  in
  (* -- radio_buttons -- *)
  let radio_react = Eliom_shared.React.S.create (Some 0) in
  let radio_labels =
    Ot_form.radio_buttons
      ~selection_react:radio_react ~name:"demo-radio"
      [[txt "Red"]; [txt "Green"]; [txt "Blue"]]
  in
  let radio_section =
    section "radio_buttons"
      [ p [txt "A group of radio buttons with reactive selection."]
      ; div radio_labels
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Selection: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | None -> "none"
                     | Some i -> string_of_int i]
                 (fst radio_react)) ] ]
  in
  (* -- int_input / optional_int_input -- *)
  let int_div, int_signal = Ot_form.int_input ~min:0 ~max:100 42 in
  let oint_div, oint_signal = Ot_form.optional_int_input ~min:0 ~max:50 (Some 10) in
  let int_section =
    section "int_input / optional_int_input"
      [ p [txt "Integer inputs with +/- buttons."]
      ; div
          [ strong [txt "int_input: "]; int_div
          ; p
              ~a:[a_class ["demo-forms-output"]]
              [ strong [txt "Value: "]
              ; R.txt
                  (Eliom_shared.React.S.map
                     [%shared
                       fun v ->
                         match v with
                         | Ok n -> string_of_int n
                         | Error () -> "invalid"]
                     int_signal) ] ]
      ; div
          [ strong [txt "optional_int_input: "]; oint_div
          ; p
              ~a:[a_class ["demo-forms-output"]]
              [ strong [txt "Value: "]
              ; R.txt
                  (Eliom_shared.React.S.map
                     [%shared
                       fun v ->
                         match v with
                         | Ok (Some n) -> string_of_int n
                         | Ok None -> "none"
                         | Error () -> "invalid"]
                     oint_signal) ] ] ]
  in
  (* -- reactive_date_input -- *)
  let date_input, (date_signal, _date_set) =
    Ot_form.reactive_date_input ~value:(2025, 6, 15) ()
  in
  let date_section =
    section "reactive_date_input"
      [ p [txt "An HTML5 date input with reactive signal."]
      ; date_input
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Date: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | Some (y, m, d) ->
                         Printf.sprintf "%04d-%02d-%02d" y m d
                     | None -> "none"]
                 date_signal) ] ]
  in
  (* -- reactive_time_input -- *)
  let time_input, (time_signal, _time_set) =
    Ot_form.reactive_time_input ~value:(14, 30) ()
  in
  let time_section =
    section "reactive_time_input"
      [ p [txt "An HTML5 time input with reactive signal."]
      ; time_input
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Time: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | Some (h, m) -> Printf.sprintf "%02d:%02d" h m
                     | None -> "none"]
                 time_signal) ] ]
  in
  (* -- disableable_button -- *)
  let dis_toggle_btn, (dis_s, _dis_set) =
    Ot_form.reactive_toggle_button ~init:false
      [txt "Disable button below"]
  in
  let dis_button =
    Ot_form.disableable_button ~disabled:dis_s
      [txt "I can be disabled"]
  in
  let dis_section =
    section "disableable_button"
      [ p [txt "A button that can be reactively disabled. \
                Use the toggle above to control it."]
      ; div [dis_toggle_btn]
      ; div [dis_button] ]
  in
  (* -- prevent_double_submit -- *)
  let pds_button =
    Ot_form.prevent_double_submit
      ~f:[%client fun () -> Lwt_js.sleep 2.0]
      [txt "Click me (2s action)"]
  in
  let pds_section =
    section "prevent_double_submit"
      [ p [txt "This button disables itself while the action runs (2 seconds). \
                Try clicking it rapidly."]
      ; pds_button ]
  in
  (* -- input_validation_tools -- *)
  let val_attrs, val_class, val_result =
    Ot_form.input_validation_tools
      ~init:""
      [%shared
        fun s ->
          if String.length s = 0 then Ok ""
          else
            match int_of_string_opt s with
            | Some n when n mod 2 = 0 -> Ok s
            | _ -> Error "Please enter an even number"]
  in
  let val_input =
    D.Raw.input ~a:(a_input_type `Text :: a_placeholder "Even number" :: val_class :: val_attrs) ()
  in
  let () = Ot_form.graceful_invalid_style val_input in
  let val_section =
    section "input_validation_tools"
      [ p [txt "Type a number. Validation error (shown after blur) if not even."]
      ; val_input
      ; p
          ~a:[a_class ["demo-forms-output"]]
          [ strong [txt "Result: "]
          ; R.txt
              (Eliom_shared.React.S.map
                 [%shared
                   fun v ->
                     match v with
                     | Ok s -> "Ok: " ^ s
                     | Error e -> "Error: " ^ e]
                 val_result) ] ]
  in
  (* -- reactive_fieldset -- *)
  let fs_toggle, (fs_disabled_s, _fs_set) =
    Ot_form.reactive_toggle_button ~init:false
      [txt "Disable fieldset"]
  in
  let fs_input1, _ = Ot_form.reactive_input ~value:"Field 1" () in
  let fs_input2, _ = Ot_form.reactive_input ~value:"Field 2" () in
  let fs =
    Ot_form.reactive_fieldset ~disabled:fs_disabled_s
      [ div [strong [txt "Fieldset content:"]]
      ; div [fs_input1]
      ; div [fs_input2]
      ; Ot_form.disableable_button
          ~disabled:(Eliom_shared.React.S.const false)
          [txt "A button inside"] ]
  in
  let fs_section =
    section "reactive_fieldset"
      [ p [txt "A fieldset that can be reactively disabled. \
                All elements inside become disabled."]
      ; div [fs_toggle]
      ; fs ]
  in
  (* -- lwt_bound_input_enter -- *)
  let enter_output = Eliom_shared.React.S.create "" in
  let enter_input =
    Ot_form.lwt_bound_input_enter
      ~a:[a_placeholder "Press Enter"]
      [%client
        fun v ->
          ~%(snd enter_output) ("[" ^ v ^ "]");
          Lwt.return_unit]
  in
  let enter_section =
    section "lwt_bound_input_enter"
      [ p [txt "Press Enter to trigger the action. The submitted value is shown below."]
      ; enter_input
      ; output_line "Submitted" (fst enter_output) ]
  in
  Lwt.return
    [ h1 [txt "Ot_form widgets"]
    ; p [txt "This page demonstrates all the reactive form widgets from \
              the Ot_form module."]
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
