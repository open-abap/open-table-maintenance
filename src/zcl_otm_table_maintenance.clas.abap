CLASS zcl_otm_table_maintenance DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_request,
             method TYPE string,
             path   TYPE string,
             body   TYPE xstring,
           END OF ty_request.

    TYPES: BEGIN OF ty_http,
             status       TYPE i,
             content_type TYPE string,
             body         TYPE xstring,
           END OF ty_http.

    METHODS constructor
      IMPORTING
        !iv_table TYPE tabname.
    METHODS serve
      IMPORTING
        is_request     TYPE ty_request
      RETURNING
        VALUE(rs_http) TYPE ty_http.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_table TYPE tabname .

    METHODS read_table
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS to_json
      IMPORTING
        ref            TYPE REF TO data
      RETURNING
        VALUE(rv_json) TYPE string.
    METHODS get_html
      RETURNING
        VALUE(rv_html) TYPE string.


ENDCLASS.



CLASS ZCL_OTM_TABLE_MAINTENANCE IMPLEMENTATION.


  METHOD constructor.

    ASSERT iv_table IS NOT INITIAL.
    mv_table = iv_table.

  ENDMETHOD.


  METHOD get_html.
    rv_html = |<!DOCTYPE html>\n| &&
      |<html>\n| &&
      |<head>\n| &&
      |<script>\n| &&
      'function run() {' && |\n| &&
      '  const Http = new XMLHttpRequest();' && |\n| &&
      '  console.dir(window.location);' && |\n| &&
      '  const url = window.location.pathname + "/rest";' && |\n| &&
      '  Http.open("GET", url);' && |\n| &&
      '  Http.send();' && |\n| &&
      '  Http.onreadystatechange = (e) => {' && |\n| &&
      '    console.log(Http.responseText)' && |\n| &&
      '    document.getElementById("content").innerHTML = "blah";' && |\n| &&
      '  }' && |\n| &&
      '}' && |\n| &&
      |</script>\n| &&
      |</head>\n| &&
      |<body onload="run()">\n| &&
      |<h1>open-table-maintenance</h1>\n| &&
      |<div id="content">loading</div>\n| &&
      |</body>\n| &&
      |</html>|.
  ENDMETHOD.


  METHOD read_table.

    FIELD-SYMBOLS <fs> TYPE STANDARD TABLE.
    DATA dref TYPE REF TO data.

    CREATE DATA dref TYPE STANDARD TABLE OF (mv_table) WITH DEFAULT KEY.
    ASSIGN dref->* TO <fs>.
    SELECT * FROM (mv_table) ORDER BY PRIMARY KEY INTO TABLE @<fs>.

    rv_json = to_json( dref ).

  ENDMETHOD.


  METHOD serve.

    DATA lv_body TYPE string.

    rs_http-status = 200.

    IF is_request-path CP '*/rest'.
      IF is_request-method = 'GET'.
        lv_body = read_table( ).
        rs_http-content_type = 'application/json'.
      ELSEIF is_request-method = 'POST'.
* todo, update
      ELSE.
        ASSERT 1 = 2.
      ENDIF.
    ELSE.
      lv_body = get_html( ).
      rs_http-content_type = 'text/html'.
    ENDIF.

    cl_abap_conv_out_ce=>create( )->convert(
      EXPORTING
        data   = lv_body
      IMPORTING
        buffer = rs_http-body ).

  ENDMETHOD.


  METHOD to_json.

    FIELD-SYMBOLS <fs> TYPE STANDARD TABLE.
    ASSIGN ref->* TO <fs>.

    DATA(writer) = cl_sxml_string_writer=>create( if_sxml=>co_xt_json ).
    CALL TRANSFORMATION id SOURCE data = <fs> RESULT XML writer.
    cl_abap_conv_in_ce=>create( )->convert(
      EXPORTING
        input = writer->get_output( )
      IMPORTING
        data = rv_json ).

  ENDMETHOD.
ENDCLASS.
