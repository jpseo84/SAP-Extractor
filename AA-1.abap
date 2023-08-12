REPORT ZAA01_EXTRACT_USER_ROLES.

* 변수선언
TYPES: BEGIN OF ty_user_roles,
         bname TYPE usr02-bname,      " User
         agr_name TYPE agr_users-agr_name, " Role
         from_dat TYPE agr_users-from_dat, " Start Date
       END OF ty_user_roles.

DATA: it_user_roles TYPE TABLE OF ty_user_roles,
      wa_user_roles TYPE ty_user_roles.

* 파일출력
DATA: lv_filename TYPE string,
      lv_csv_data TYPE string.

* 사용자 권한을 USR02 테이블 정보를 기준으로 추출
SELECT A~BNAME, C~AGR_NAME, C~FROM_DAT
  INTO CORRESPONDING FIELDS OF TABLE it_user_roles
  FROM USR02 AS A
       JOIN AGR_USERS AS C ON C~UNAME = A~BNAME.

LOOP AT it_user_roles INTO wa_user_roles.
  CONCATENATE lv_csv_data wa_user_roles-bname ';' wa_user_roles-agr_name ';' wa_user_roles-from_dat CL_ABAP_CHAR_UTILITIES=>CR_LF INTO lv_csv_data.
ENDLOOP.

* 파일출력을 위한 대화상자 프론트엔드 호출
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
