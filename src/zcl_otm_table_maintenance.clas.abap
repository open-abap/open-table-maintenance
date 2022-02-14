CLASS zcl_otm_table_maintenance DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
* MIT License, Copyright (c) 2021 open-abap
* https://github.com/open-abap/open-table-maintenance

    TYPES:
      BEGIN OF ty_request,
        method TYPE string,
        path   TYPE string,
        body   TYPE xstring,
      END OF ty_request.
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
    TYPES ty_names TYPE STANDARD TABLE OF abap_compname WITH EMPTY KEY.
    METHODS list_key_fields RETURNING VALUE(names) TYPE ty_names.

* there is no common released type for both steampunk and on-prem, workaround:
    TYPES:
      BEGIN OF ty_fixvalue,
        low        TYPE c LENGTH 10,
        high       TYPE c LENGTH 10,
        option     TYPE c LENGTH 2,
        ddlanguage TYPE c LENGTH 1,
        ddtext     TYPE c LENGTH 60,
      END OF ty_fixvalue.
    TYPES ty_fixvalues TYPE STANDARD TABLE OF ty_fixvalue WITH EMPTY KEY.

    TYPES: BEGIN OF ty_fielddata,
             name      TYPE abap_compname,
             key       TYPE abap_bool,
             type_kind TYPE abap_typekind,
             length    TYPE i,
             fixvalues TYPE ty_fixvalues,
           END OF ty_fielddata.
    TYPES ty_metadata TYPE STANDARD TABLE OF ty_fielddata WITH EMPTY KEY.
    METHODS build_metadata RETURNING VALUE(rt_metadata) TYPE ty_metadata.
ENDCLASS.



CLASS zcl_otm_table_maintenance IMPLEMENTATION.


  METHOD constructor.
    ASSERT iv_table IS NOT INITIAL.
    mv_table = iv_table.
  ENDMETHOD.


  METHOD from_xstring.

    DATA conv TYPE REF TO object.

    TRY.
        CALL METHOD ('CL_ABAP_CONV_CODEPAGE')=>create_in
          RECEIVING
            instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_IN~CONVERT')
          EXPORTING
            source = xstring
          RECEIVING
            result = string.
      CATCH cx_sy_dyn_call_illegal_class.
        DATA(conv_in_class) = 'CL_ABAP_CONV_IN_CE'.
        CALL METHOD (conv_in_class)=>create
          EXPORTING
            encoding = 'UTF-8'
          RECEIVING
            conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING
            input = xstring
          IMPORTING
            data  = string.
    ENDTRY.

  ENDMETHOD.


  METHOD get_html.
    rv_html = |<!DOCTYPE html>\n| &&
      |<html>\n| &&
      |<head>\n| &&
      |<title>open-table-maintenance</title>\n| &&
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
      '    const parsed = JSON.parse(Http.responseText);' && |\n| &&
      '    document.getElementById("tablename").innerHTML = ' && |\n| &&
      '      "<h1 style=\"display:inline\">" + parsed.TABLENAME + "</h1>&nbsp;<tt>" + ' && |\n| &&
      '       parsed.SY.SYSID + "-" + parsed.SY.MANDT + "</tt>";' && |\n| &&
      '    const data = parsed.DATA;' && |\n| &&
      '    if (data.length === 0) { ' && |\n| &&
      '       const obj = {};' && |\n| &&
      '       obj[parsed.META[0]["NAME"]] = "_";' && |\n| &&
      '       data.push(obj);' && |\n| &&
      '    }' && |\n| &&
      '    columnNames = parsed.META.map(n => n.NAME);' && |\n| &&
      '    document.getElementById("content").innerHTML = "";' && |\n| &&
      '    let columnSettings = parsed.META.map(n => {return {' && |\n| &&
      '      "type": n.FIXVALUES.length > 0 ? "dropdown" : undefined,' && |\n| &&
      '      "title": n.NAME,' && |\n| &&
      '      "source": n.FIXVALUES.map(f => f.LOW),' && |\n| &&
      '      "width": Math.min(200, n.LENGTH * 20)' && |\n| &&
      '    };});' && |\n| &&
      '    jtable = jspreadsheet(document.getElementById("content"), {' && |\n| &&
      '      defaultColAlign:"left",' && |\n| &&
      '      allowInsertRow:true,' && |\n| &&
      '      allowManualInsertRow:true,' && |\n| &&
      '      allowInsertColumn:false,' && |\n| &&
      '      allowManualInsertColumn:false,' && |\n| &&
      '      allowDeleteRow:true,' && |\n| &&
      '      allowRenameColumn:false,' && |\n| &&
      '      allowDeleteColumn:false,' && |\n| &&
      '      data: data,' && |\n| &&
      '      onload: function(instance) {' && |\n| &&
      '        const keyCount = parsed.META.filter(n => n.KEY === "X").length;' && |\n| &&
      '        for (let i = 0; i < keyCount; i++) {' && |\n| &&
      '          instance.jexcel.colgroup[i].style.backgroundColor="#F8F8F8";' && |\n| &&
      '        }' && |\n| &&
      '      },' && |\n| &&
      '      columns: columnSettings});' && |\n| &&
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
      |<div id="tablename"><h1>open-table-maintenance</h1></div>\n| &&
      |<button type="button" onclick="save()">Save</button><br>\n| &&
      |<div id="content">loading</div><br>\n| &&
      |</body>\n| &&
      |</html>|.
  ENDMETHOD.

  METHOD build_metadata.
    DATA lv_key TYPE abap_bool.
    DATA lo_element TYPE REF TO cl_abap_elemdescr.
    DATA lt_values TYPE ty_fixvalues.

    DATA(lt_key_fields) = list_key_fields( ).
    DATA(lt_components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
      mv_table ) )->get_components( ).

    LOOP AT lt_components INTO DATA(ls_component).

      lo_element ?= ls_component-type.
      lt_values = lo_element->get_ddic_fixed_values( ).

      READ TABLE lt_key_fields WITH KEY table_line = ls_component-name TRANSPORTING NO FIELDS.
      lv_key = boolc( sy-subrc = 0 ).
      APPEND VALUE #(
        name      = ls_component-name
        key       = lv_key
        type_kind = ls_component-type->type_kind
        length    = ls_component-type->length
        fixvalues = lt_values
        ) TO rt_metadata.
    ENDLOOP.

  ENDMETHOD.

  METHOD list_key_fields.
    DATA obj TYPE REF TO object.
    DATA lv_tabname TYPE c LENGTH 16.
    DATA lr_ddfields TYPE REF TO data.
    FIELD-SYMBOLS <any> TYPE any.
    FIELD-SYMBOLS <field> TYPE simple.
    FIELD-SYMBOLS <ddfields> TYPE ANY TABLE.

* convert to correct type,
    lv_tabname = mv_table.

    TRY.
        CALL METHOD ('XCO_CP_ABAP_DICTIONARY')=>database_table
          EXPORTING
            iv_name           = lv_tabname
          RECEIVING
            ro_database_table = obj.
        ASSIGN obj->('IF_XCO_DATABASE_TABLE~FIELDS->IF_XCO_DBT_FIELDS_FACTORY~KEY') TO <any>.
        ASSERT sy-subrc = 0.
        obj = <any>.
        CALL METHOD obj->('IF_XCO_DBT_FIELDS~GET_NAMES')
          RECEIVING
            rt_names = names.
      CATCH cx_sy_dyn_call_illegal_class.
        DATA(workaround) = 'DDFIELDS'.
        CREATE DATA lr_ddfields TYPE (workaround).
        ASSIGN lr_ddfields->* TO <ddfields>.
        ASSERT sy-subrc = 0.
        <ddfields> = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
          lv_tabname ) )->get_ddic_field_list( ).
        LOOP AT <ddfields> ASSIGNING <any>.
          ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <any> TO <field>.
          IF sy-subrc <> 0 OR <field> <> abap_true.
            CONTINUE.
          ENDIF.
          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <any> TO <field>.
          ASSERT sy-subrc = 0.
          APPEND <field> TO names.
        ENDLOOP.
    ENDTRY.

  ENDMETHOD.


  METHOD read_table.

    FIELD-SYMBOLS <fs> TYPE STANDARD TABLE.
    DATA dref TYPE REF TO data.
    CREATE DATA dref TYPE STANDARD TABLE OF (mv_table) WITH DEFAULT KEY.
    ASSIGN dref->* TO <fs>.
    ASSERT sy-subrc = 0.

    " dont check SUBRC, the table might be empty
    SELECT * FROM (mv_table) ORDER BY PRIMARY KEY INTO TABLE @<fs> ##SUBRC_OK.

    rv_json = to_json( dref ).

  ENDMETHOD.


  METHOD save_table.

    FIELD-SYMBOLS <fs> TYPE STANDARD TABLE.
    DATA dref TYPE REF TO data.
    CREATE DATA dref TYPE STANDARD TABLE OF (mv_table) WITH DEFAULT KEY.
    ASSIGN dref->* TO <fs>.
    ASSERT sy-subrc = 0.

    CALL TRANSFORMATION id SOURCE XML iv_json RESULT data = <fs>.

    MODIFY (mv_table) FROM TABLE @<fs> ##SUBRC_OK.

  ENDMETHOD.


  METHOD serve.

    rs_http-status = 200.

    IF is_request-path CP '*/rest'.
      IF is_request-method = 'GET'.
        DATA(lv_body) = read_table( ).
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
    ASSERT sy-subrc = 0.

    DATA(meta) = build_metadata( ).
    DATA(writer) = cl_sxml_string_writer=>create( if_sxml=>co_xt_json ).
    CALL TRANSFORMATION id
      SOURCE
        data      = <fs>
        meta      = meta
        tablename = mv_table
        sy        = sy
      RESULT XML writer.
    rv_json = from_xstring( writer->get_output( ) ).

  ENDMETHOD.


  METHOD to_xstring.

    DATA conv TYPE REF TO object.

    TRY.
        CALL METHOD ('CL_ABAP_CONV_CODEPAGE')=>create_out
          RECEIVING
            instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_OUT~CONVERT')
          EXPORTING
            source = string
          RECEIVING
            result = xstring.
      CATCH cx_sy_dyn_call_illegal_class.
        DATA(conv_out_class) = 'CL_ABAP_CONV_OUT_CE'.
        CALL METHOD (conv_out_class)=>create
          EXPORTING
            encoding = 'UTF-8'
          RECEIVING
            conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING
            data   = string
          IMPORTING
            buffer = xstring.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
