CLASS ltcl_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.

  PRIVATE SECTION.
    METHODS list_key_fields FOR TESTING RAISING cx_static_check.
    METHODS build_metadata FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD list_key_fields.

    DATA(fields) = NEW zcl_otm_table_maintenance( 'ZOPENTEST' )->list_key_fields( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( fields )
      exp = 1 ).

  ENDMETHOD.

  METHOD build_metadata.

    DATA(fields) = NEW zcl_otm_table_maintenance( 'ZOPENTEST' )->build_metadata( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( fields )
      exp = 3 ).

  ENDMETHOD.

ENDCLASS.
