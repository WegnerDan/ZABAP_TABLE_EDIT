CLASS zcl_zabap_table_edit_messages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      show_duplicates IMPORTING table_name TYPE string duplicates TYPE REF TO data mandant_col_name TYPE string DEFAULT '',
      confirm_save RETURNING VALUE(continue) TYPE abap_bool,
      confirm_data_loss IMPORTING was_data_changed TYPE abap_bool DEFAULT abap_true RETURNING VALUE(continue) TYPE abap_bool,
      validation_ok,
      save_ok,
      save_error IMPORTING error TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
         yes_no IMPORTING title TYPE string DEFAULT space question TYPE string start_col TYPE i DEFAULT 25 start_row TYPE i DEFAULT 6
                               RETURNING VALUE(confirmed) TYPE abap_bool ,
       "! @parameter result | Y - Yes, N - No, C - Cancel
       yes_no_cancel IMPORTING title TYPE string DEFAULT space question TYPE string start_col TYPE i DEFAULT 25 start_row TYPE i DEFAULT 6
                               RETURNING VALUE(result) TYPE string .
ENDCLASS.

CLASS zcl_zabap_table_edit_messages IMPLEMENTATION.
  METHOD confirm_data_loss.
    continue = abap_true.
    IF was_data_changed = abap_true.
      continue = yes_no( CONV #( TEXT-001 ) ).
    ENDIF.
  ENDMETHOD.

  METHOD confirm_save.
    continue = yes_no( CONV #( TEXT-002 ) ).
  ENDMETHOD.

  METHOD show_duplicates.
    FIELD-SYMBOLS <duplicates> TYPE table.
    ASSIGN duplicates->* TO <duplicates>.

    DATA(popup_table) = NEW zcl_zabap_salv_report(  report_id = CONV #( table_name ) handle = 'DUPL' ).
    popup_table->alv_table->set_screen_popup( start_column = 1  end_column = 100  start_line = 1 end_line = 15 ).
    popup_table->set_header( CONV #( TEXT-003 ) ).
    popup_table->set_data( exporting create_table_copy = abap_false CHANGING data_table = <duplicates> ).
    IF strlen( mandant_col_name ) > 0.
      popup_table->hide_column( CONV #( mandant_col_name ) ).
    ENDIF.

    popup_table->display_data( ).
  ENDMETHOD.

  METHOD validation_ok.
    MESSAGE TEXT-004 TYPE 'S'.
  ENDMETHOD.

  METHOD save_ok.
    MESSAGE TEXT-005 TYPE 'S'.
  ENDMETHOD.

  METHOD save_error.
    MESSAGE replace( val = TEXT-006 sub = '&1' with = error ) TYPE 'E'.
  ENDMETHOD.

  METHOD yes_no.
    DATA answer TYPE c LENGTH 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = title
        text_question         = question
        text_button_1         = TEXT-Q01
        icon_button_1         = '@0V@'  " Okay icon
        text_button_2         = TEXT-Q02
        icon_button_2         = '@0W@' " No icon
        default_button        = '1'
        display_cancel_button = ||
        start_column          = start_col
        start_row             = start_row
        popup_type            = 'ICON_MESSAGE_QUESTION' " check ICON_MESSAGE_ in TYPE_POOL Icon
      IMPORTING
        answer                = answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.


    confirmed = COND #( WHEN answer = '1' THEN abap_true ELSE abap_false ).
  ENDMETHOD.

  METHOD yes_no_cancel.
    DATA answer TYPE c LENGTH 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = title
        text_question         = question
        text_button_1         = TEXT-Q01
        icon_button_1         = '@0V@'  " Okay icon
        text_button_2         = TEXT-Q02
        icon_button_2         = '@2O@' " Cancel icon
        default_button        = '1'
        display_cancel_button = |X|
        start_column          = start_col
        start_row             = start_row
        popup_type            = 'ICON_MESSAGE_QUESTION' " check ICON_MESSAGE_ in TYPE_POOL Icon
      IMPORTING
        answer                = answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.


    result = COND #( WHEN answer = '1' THEN 'Y' WHEN answer = '2' THEN 'N' ELSE 'C' ).
  ENDMETHOD.
ENDCLASS.
