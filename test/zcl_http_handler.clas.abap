CLASS zcl_http_handler DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_http_handler IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

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
