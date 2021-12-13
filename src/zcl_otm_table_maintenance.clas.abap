CLASS zcl_otm_table_maintenance DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_request,
        method TYPE string,
        path   TYPE string,
        body   TYPE xstring,
      END OF ty_request .
    TYPES:
      BEGIN OF ty_http,
        status       TYPE i,
        content_type TYPE string,
        body         TYPE xstring,
      END OF ty_http .

    METHODS constructor
      IMPORTING
        !iv_table TYPE tabname .
    METHODS serve
      IMPORTING
        !is_request    TYPE ty_request
      RETURNING
        VALUE(rs_http) TYPE ty_http .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_table TYPE tabname .

    METHODS from_xstring
      IMPORTING
        !xstring      TYPE xstring
      RETURNING
        VALUE(string) TYPE string .
    METHODS get_html
      RETURNING
        VALUE(rv_html) TYPE string .
    METHODS read_table
      RETURNING
        VALUE(rv_json) TYPE string .
    METHODS save_table
      IMPORTING
        !iv_json TYPE string .
    METHODS to_json
      IMPORTING
        !ref           TYPE REF TO data
      RETURNING
        VALUE(rv_json) TYPE string .
    METHODS to_xstring
      IMPORTING
        !string        TYPE string
      RETURNING
        VALUE(xstring) TYPE xstring .
ENDCLASS.



CLASS ZCL_OTM_TABLE_MAINTENANCE IMPLEMENTATION.


  METHOD constructor.
    ASSERT iv_table IS NOT INITIAL.
    mv_table = iv_table.
  ENDMETHOD.


  METHOD from_xstring.
    string = cl_abap_conv_codepage=>create_in( )->convert( xstring ).
  ENDMETHOD.


  METHOD get_html.
    rv_html = |<!DOCTYPE html>\n| &&
      |<html>\n| &&
      |<head>\n| &&
      |<script src="https://bossanova.uk/jspreadsheet/v4/jexcel.js"></script>\n| &&
      |<script src="https://jsuites.net/v4/jsuites.js"></script>\n| &&
      |<link rel="stylesheet" href="https://jsuites.net/v4/jsuites.css" type="text/css" />\n| &&
      |<link rel="stylesheet" href="https://bossanova.uk/jspreadsheet/v4/jexcel.css" type="text/css" />\n| &&
      |<script>\n| &&
      'let jtable;' && |\n| &&
      'let columnNames;' && |\n| &&
      'const url = window.location.pathname + "/rest";' && |\n| &&
      'function run() {' && |\n| &&
      '  const Http = new XMLHttpRequest();' && |\n| &&
      '  Http.open("GET", url);' && |\n| &&
      '  Http.send();' && |\n| &&
      '  Http.onloadend = (e) => {' && |\n| &&
      '    const data = JSON.parse(Http.responseText).DATA;' && |\n| &&
      '    columnNames = Object.keys(data[0]);' && |\n| &&
      '    document.getElementById("content").innerHTML = "";' && |\n| &&
      '    let columnSettings = columnNames.map(n => {return {"title": n};});' && |\n| &&
      '    jtable = jspreadsheet(document.getElementById("content"), {data: data, columns: columnSettings});' && |\n| &&
      '  }' && |\n| &&
      '}' && |\n| &&
      'function toObject(row) {' && |\n| &&
      '  let ret = {};' && |\n| &&
      '  for (let i = 0; i < columnNames.length; i++) {' && |\n| &&
      '    ret[columnNames[i]] = row[i];' && |\n| &&
      '  }' && |\n| &&
      '  return ret;' && |\n| &&
      '}' && |\n| &&
      'function save() {' && |\n| &&
      '  const body = {"DATA": jtable.getData().map(toObject)};' && |\n| &&
      '  console.dir(body);' && |\n| &&
      '  const Http = new XMLHttpRequest();' && |\n| &&
      '  Http.open("POST", url);' && |\n| &&
      '  Http.send(JSON.stringify(body));' && |\n| &&
      '  Http.onloadend = (e) => {' && |\n| &&
      '    alert("data saved");' && |\n| &&
      '  }' && |\n| &&
      '}' && |\n| &&
      |</script>\n| &&
      |</head>\n| &&
      |<body onload="run()">\n| &&
      |<h1>open-table-maintenance</h1>\n| &&
      |<button type="button" onclick="save()">Save</button><br>\n| &&
      |<div id="content">loading</div><br>\n| &&
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


  METHOD save_table.

    FIELD-SYMBOLS <fs> TYPE STANDARD TABLE.
    DATA dref TYPE REF TO data.
    CREATE DATA dref TYPE STANDARD TABLE OF (mv_table) WITH DEFAULT KEY.
    ASSIGN dref->* TO <fs>.

    CALL TRANSFORMATION id SOURCE XML iv_json RESULT data = <fs>.

* todo

  ENDMETHOD.


  METHOD serve.

    DATA lv_body TYPE string.

    rs_http-status = 200.

    IF is_request-path CP '*/rest'.
      IF is_request-method = 'GET'.
        lv_body = read_table( ).
        rs_http-content_type = 'application/json'.
      ELSEIF is_request-method = 'POST'.
        save_table( from_xstring( is_request-body ) ).
      ELSE.
        ASSERT 1 = 2.
      ENDIF.
    ELSE.
      lv_body = get_html( ).
      rs_http-content_type = 'text/html'.
    ENDIF.

    rs_http-body = to_xstring( lv_body ).

  ENDMETHOD.


  METHOD to_json.

    FIELD-SYMBOLS <fs> TYPE STANDARD TABLE.
    ASSIGN ref->* TO <fs>.

    DATA(writer) = cl_sxml_string_writer=>create( if_sxml=>co_xt_json ).
    CALL TRANSFORMATION id SOURCE data = <fs> RESULT XML writer.
    rv_json = from_xstring( writer->get_output( ) ).

  ENDMETHOD.


  METHOD to_xstring.
    xstring = cl_abap_conv_codepage=>create_out( )->convert( string ).
  ENDMETHOD.
ENDCLASS.
