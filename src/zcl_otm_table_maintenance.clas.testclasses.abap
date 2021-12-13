CLASS ltcl_test DEFINITION DEFERRED.
CLASS zcl_otm_table_maintenance DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS read_table FOR TESTING.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD read_table.

    DATA(json) = NEW zcl_otm_table_maintenance( 'ZDEMO_SOH' )->read_table( ).

    BREAK-POINT.

  ENDMETHOD.

ENDCLASS.
