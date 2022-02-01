# open-table-maintenance

Works with:
* [open-abap](https://github.com/open-abap/open-abap)
* [Steampunk](https://blogs.sap.com/2019/08/20/its-steampunk-now/)
* [Embedded Steampunk](https://blogs.sap.com/2021/09/30/steampunk-is-going-all-in/)
* On-Premise v740sp05 and up
* (Code is automatically downported on build, so it should also work with 702)

Install with [abapGit](https://abapgit.org), or copy paste into a system

Warning: only hardcode the table name, don't use with important tables, use at own risk!

## Use-case: On-prem shim

```abap
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
```

## Use-case: Steampunk shim

```abap
  METHOD if_http_service_extension~handle_request.

    DATA(result) = NEW zcl_otm_table_maintenance( 'ZOPENTEST' )->serve( VALUE #(
      method = request->get_method( )
      path   = request->get_header_field( '~path' )
      body   = request->get_binary( ) ) ).

    response->set_binary( result-body ).
    response->set_header_field(
      i_name = 'Content-Type'
      i_value = result-content_type ).
    response->set_status(
      i_code   = result-status
      i_reason = CONV #( result-status ) ).

  ENDMETHOD.
```
