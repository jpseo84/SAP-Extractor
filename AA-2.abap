REPORT ZAA02_EXTRACT_PWD_PARAMS.

* Data Declarations
TYPES: BEGIN OF ty_password_params,
         partype   TYPE pahi-partype,       " Parameter Type
         hostname  TYPE pahi-hostname,      " Host Name
         systemid  TYPE pahi-systemid,      " System ID
         pardate   TYPE pahi-pardate,       " Date when parameter was set
         parname   TYPE pahi-parname,       " Parameter Name
         parstate  TYPE pahi-parstate,      " Parameter State
         parvalue  TYPE pahi-parvalue       " Parameter Value
       END OF ty_password_params.

DATA: it_password_params TYPE TABLE OF ty_password_params,
      wa_password_params TYPE ty_password_params,
      lr_parname TYPE RANGE OF pahi-parname,
      lv_filename TYPE string,
      lt_csv_data TYPE TABLE OF string,
      lv_csv_line TYPE string.

* Populate the range table with desired parameters
CLEAR lr_parname.
lr_parname-SIGN = 'I'.
lr_parname-OPTION = 'EQ'.

lr_parname-LOW = 'login/min_password_lng'.
APPEND lr_parname.
lr_parname-LOW = 'login/min_password_digits'.
APPEND lr_parname.
lr_parname-LOW = 'login/min_password_letters'.
APPEND lr_parname.
lr_parname-LOW = 'login/min_password_lowercase'.
APPEND lr_parname.
lr_parname-LOW = 'login/min_password_uppercase'.
APPEND lr_parname.
lr_parname-LOW = 'login/min_password_specials'.
APPEND lr_parname.
lr_parname-LOW = 'login/password_expiration_time'.
APPEND lr_parname.

* Fetch the specified parameters from SAP PAHI table
SELECT partype
       hostname
       systemid
       pardate
       parname
       parstate
       parvalue
  INTO TABLE it_password_params
  FROM pahi
  WHERE parname IN lr_parname.

* Prepare data for CSV export
LOOP AT it_password_params INTO wa_password_params.
  CONCATENATE wa_password_params-partype wa_password_params-hostname wa_password_params-systemid wa_password_params-pardate wa_password_params-parname wa_password_params-parstate wa_password_params-parvalue INTO lv_csv_line SEPARATED BY ';'.
  APPEND lv_csv_line TO lt_csv_data.
ENDLOOP.

* Prompt user to select a location for saving the CSV file
CALL METHOD cl_gui_frontend_services=>file_save_dialog
  EXPORTING
    window_title  = 'Save As'
    default_file  = 'password_parameters.csv'
  CHANGING
    filename      = lv_filename.

* Export to CSV file
IF lv_filename IS NOT INITIAL.
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename      = lv_filename
      filetype      = 'ASC'
    CHANGING
      data_tab      = lt_csv_data
    EXCEPTIONS
      OTHERS        = 1.
ENDIF.
