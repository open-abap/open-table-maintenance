CLASS zcl_http_handler DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
    METHODS add_row_if_empty.
ENDCLASS.

CLASS zcl_http_handler IMPLEMENTATION.

  METHOD add_row_if_empty.
    DATA ls_row TYPE zopentest.

    SELECT SINGLE * FROM zopentest INTO @ls_row.
    IF sy-subrc <> 0.
      ls_row-keyfield = 'hihi'.
      ls_row-valuefield = 'world'.
      INSERT INTO zopentest VALUES ls_row.
      ASSERT sy-subrc = 0.
    ENDIF.

  ENDMETHOD.

  METHOD if_http_extension~handle_request.

    add_row_if_empty( ).

    DATA(result) = NEW zcl_otm_table_maintenance( 'ZOPENTEST' )->serve( VALUE #(
      method = server->request->get_method( )
      path   = server->request->get_header_field( '~path' )
      body   = server->request->get_data( ) ) ).

    server->response->set_data( result-body ).
    server->response->set_content_type( result-content_type ).
    server->response->set_status(
      code   = result-status
      reason = CONV #( result-status ) ).

  ENDMETHOD.

ENDCLASS.