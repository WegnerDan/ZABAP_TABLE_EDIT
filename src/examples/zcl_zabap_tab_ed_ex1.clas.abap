CLASS zcl_zabap_tab_ed_ex1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_zabap_table_edit .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_zabap_tab_ed_ex1 IMPLEMENTATION.


  METHOD zif_zabap_table_edit~additional_fields.
    "Display additional field with material description
    APPEND VALUE #( name = 'MAKTX' type = CAST #( cl_abap_typedescr=>describe_by_name( 'MAKTX' ) ) ) TO additional_fields.
  ENDMETHOD.


  METHOD zif_zabap_table_edit~additional_validation.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~after_command.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~after_save.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~before_command.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~before_save.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~change_commands.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~grid_setup.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~initial_data.

  ENDMETHOD.


  METHOD zif_zabap_table_edit~on_data_changed.
    LOOP AT er_data_changed->mt_inserted_rows REFERENCE INTO DATA(inserted_row).
      "Update creation date of inserted rows
      er_data_changed->modify_cell( i_row_id = inserted_row->row_id i_fieldname =  'CREATION_DATE' i_value = sy-datum ).
    ENDLOOP.

    LOOP AT er_data_changed->mt_mod_cells REFERENCE INTO DATA(modified_cell).
      "Update modified time of modified rows
      er_data_changed->modify_cell( i_row_id = modified_cell->row_id i_fieldname =  'LAST_CHANGED_TIME' i_value = sy-uzeit ).

      IF modified_cell->fieldname = 'MATNR'.
        "MATNR changed, update material description
        SELECT SINGLE maktx FROM makt WHERE spras = @sy-langu AND matnr = @modified_cell->value INTO @DATA(maktx).
        er_data_changed->modify_cell( i_row_id = modified_cell->row_id i_fieldname =  'MAKTX' i_value = maktx ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_zabap_table_edit~on_data_changed_finished.
  ENDMETHOD.


  METHOD zif_zabap_table_edit~refresh_grid.
    "Fill additional field with material description based on MATNR
    FIELD-SYMBOLS <modified_data_ext> TYPE ANY TABLE.
    ASSIGN modified_data_ext->* TO <modified_data_ext>.
    LOOP AT <modified_data_ext> ASSIGNING FIELD-SYMBOL(<row_ext>).
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <row_ext> TO FIELD-SYMBOL(<maktx>).
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <row_ext> TO FIELD-SYMBOL(<matnr>).
      SELECT SINGLE maktx FROM makt WHERE spras = @sy-langu AND matnr = @<matnr> INTO @<maktx>.
    ENDLOOP.

    "Change field catalogue before displaying to user - e.g. make existing / added fields non-editable
    field_catalogue[ KEY name fieldname = 'MAKTX' ]-edit = abap_false.
    field_catalogue[ KEY name fieldname = 'CREATION_DATE' ]-edit = abap_false.
    field_catalogue[ KEY name fieldname = 'LAST_CHANGED_TIME' ]-edit = abap_false.
    "Move material description next to MATNR
    field_catalogue[ KEY name fieldname = 'MAKTX' ]-col_pos = field_catalogue[ KEY name fieldname = 'MATNR' ]-col_pos.
  ENDMETHOD.


  METHOD zif_zabap_table_edit~set_edit_mode.

  ENDMETHOD.
ENDCLASS.