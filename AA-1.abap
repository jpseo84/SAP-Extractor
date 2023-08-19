REPORT ZAA01_EXTRACT_USER_ROLES.

* Data declaration
TYPES: BEGIN OF ty_user_roles,
         bname TYPE usr02-bname,      " User
         agr_name TYPE agr_users-agr_name, " Role
         from_dat TYPE agr_users-from_dat, " Start Date
       END OF ty_user_roles.

DATA: it_user_roles TYPE TABLE OF ty_user_roles,
      wa_user_roles TYPE ty_user_roles.

* File output
DATA: lv_filename TYPE string,
      lv_csv_data TYPE string.

* Extract User Privileges from USER02 table
SELECT A~BNAME, C~AGR_NAME, C~FROM_DAT
  INTO CORRESPONDING FIELDS OF TABLE it_user_roles
  FROM USR02 AS A
       JOIN AGR_USERS AS C ON C~UNAME = A~BNAME.

LOOP AT it_user_roles INTO wa_user_roles.
  CONCATENATE lv_csv_data wa_user_roles-bname ';' wa_user_roles-agr_name ';' wa_user_roles-from_dat CL_ABAP_CHAR_UTILITIES=>CR_LF INTO lv_csv_data.
ENDLOOP.

* Call save dialog
CALL METHOD cl_gui_frontend_services=>file_save_dialog
  EXPORTING
    window_title  = 'Save As'
    default_file  = 'user_roles_with_dates.csv'
  CHANGING
    filename      = lv_filename.

IF lv_filename IS NOT INITIAL.
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename      = lv_filename
      filetype      = 'ASC'
    CHANGING
      data_tab      = lv_csv_data
    EXCEPTIONS
      OTHERS        = 1.
ENDIF.