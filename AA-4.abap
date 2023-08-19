REPORT ZAA04_EXTRACT_SUPERUSERS.

* Data declaration
TYPES: BEGIN OF ty_superusers,
         bname    TYPE s_user_pro-bname,    " User Name
         profilename TYPE s_user_pro-profile " Profile Name
       END OF ty_superusers.

DATA: it_superusers TYPE TABLE OF ty_superusers,
      wa_superusers TYPE ty_superusers,
      lr_profiles TYPE RANGE OF s_user_pro-profile,
      lv_filename TYPE string,
      lt_csv_data TYPE TABLE OF string,
      lv_csv_line TYPE string.

* Set data extraction parameters
CLEAR lr_profiles.
lr_profiles-SIGN = 'I'.
lr_profiles-OPTION = 'EQ'.

lr_profiles-LOW = 'SAP_ALL'.
APPEND lr_profiles.
lr_profiles-LOW = 'SAP_NEW'.
APPEND lr_profiles.

* Extract superuser lists from S_USER_PRO table
SELECT bname
       profile
  INTO TABLE it_superusers
  FROM s_user_pro
  WHERE profile IN lr_profiles.

* Prepare data for CSV export
LOOP AT it_superusers INTO wa_superusers.
  CONCATENATE wa_superusers-bname wa_superusers-profilename INTO lv_csv_line SEPARATED BY ';'.
  APPEND lv_csv_line TO lt_csv_data.
ENDLOOP.

* Call save dialog
CALL METHOD cl_gui_frontend_services=>file_save_dialog
  EXPORTING
    window_title  = 'Save As'
    default_file  = 'superusers.csv'
  CHANGING
    filename      = lv_filename.

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
