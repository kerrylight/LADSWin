UNIT LADSArchiveUnit;

INTERFACE

  VAR
      AKA_PUT_DATA_IN_TEMPORARY_STORAGE	       : BOOLEAN;
      AKB_GET_DATA_FROM_TEMPORARY_STORAGE      : BOOLEAN;
      AKC_PUT_DATA_IN_PERMANENT_STORAGE	       : BOOLEAN;
      AKD_GET_DATA_FROM_PERMANENT_STORAGE      : BOOLEAN;
      AED_TRANSFER_SURFACE_DATA		       : BOOLEAN;
      AEE_TRANSFER_RAY_DATA		       : BOOLEAN;
      AEF_TRANSFER_OPTION_DATA		       : BOOLEAN;
      AEG_TRANSFER_ENVIRONMENT_DATA	       : BOOLEAN;

      AKZ_ARCHIVE_FILE_NAME		       : STRING [255];

      ZAB_ARCHIVE_FILE			       : FILE;
      ZAE_ARCHIVE_TEXT			       : TEXT;

PROCEDURE G01_ARCHIVE_DATA;

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit,
       LADSData,
       LADSEnvironUnit,
       LADSInitUnit;
       
       
(**  G01_ARCHIVE_DATA  ********************************************************
******************************************************************************)


PROCEDURE G01_ARCHIVE_DATA;

  VAR
      G01AJ_SUBRANGE_INTEGER	       : 0..255;

      G01AA_ARCHIVE_FILE_OPEN	       : BOOLEAN;
      G01AC_FATAL_ERROR_OCCURRED       : BOOLEAN;
      
      G01AE_BYTE_POINTER	       : INTEGER;
      G01AF_SURFACE_BYTE_POINTER       : INTEGER;
      G01AG_RAY_BYTE_POINTER	       : INTEGER;
      G01AH_OPTION_BYTE_POINTER	       : INTEGER;
      G01AI_ENVIRONMENT_BYTE_POINTER   : INTEGER;
      G01AL_LINE_COUNTER	       : INTEGER;
      StringCount                      : INTEGER;
      
      G01AD_RECORD_TYPE		       : CHAR;
      
      G01AB_ARCHIVE_BLOCK	       : PACKED ARRAY [1..512] OF CHAR;
      
      G01AK_COMMENT_STRING	       : STRING;
      G01AM_TEMP_STRING		       : STRING;

PROCEDURE G05_TEMP_DATA_TO_EXTERNAL_STORAGE;	 FORWARD;
PROCEDURE G10_TEMP_DATA_TO_INTERNAL_STORAGE;	 FORWARD;
PROCEDURE G15_PERM_DATA_TO_EXTERNAL_STORAGE;	 FORWARD;
PROCEDURE G20_PERM_DATA_TO_INTERNAL_STORAGE;	 FORWARD;
PROCEDURE G95_OPEN_OUTPUT_ARCHIVE_FILE;		 FORWARD;
PROCEDURE G96_OPEN_INPUT_ARCHIVE_FILE;		 FORWARD;
PROCEDURE G97_WRITE_ARCHIVE_BLOCK;		 FORWARD;
PROCEDURE G98_READ_ARCHIVE_BLOCK;		 FORWARD;
PROCEDURE G99_INCREMENT_BYTE_POINTER;		 FORWARD;


(**  G05_TEMP_DATA_TO_EXTERNAL_STORAGE	***************************************
******************************************************************************)


PROCEDURE G05_TEMP_DATA_TO_EXTERNAL_STORAGE;


(**  G0505_XFER_SURFACE_DATA_TO_EXTERNAL  *************************************
******************************************************************************)


PROCEDURE G0505_XFER_SURFACE_DATA_TO_EXTERNAL;

  VAR
      G0505AA_ACTIVE_SURFACE_FOUND  : BOOLEAN;
      
      I                             : INTEGER;

BEGIN

  G0505AA_ACTIVE_SURFACE_FOUND := FALSE;
  I := 1;
  REPEAT
    IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
      G0505AA_ACTIVE_SURFACE_FOUND := TRUE
    ELSE
      I := I + 1
  UNTIL
    G0505AA_ACTIVE_SURFACE_FOUND
    OR (I > CZAB_MAX_NUMBER_OF_SURFACES);
    
  IF G0505AA_ACTIVE_SURFACE_FOUND THEN
    REPEAT
      BEGIN
	G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] := 'S';
	G99_INCREMENT_BYTE_POINTER;
	IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
	  BEGIN
	    G01AJ_SUBRANGE_INTEGER := I;
	    G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] :=
		CHR (G01AJ_SUBRANGE_INTEGER);
	    G99_INCREMENT_BYTE_POINTER
	  END;
	IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
	  BEGIN
	    G01AF_SURFACE_BYTE_POINTER := 1;
	    REPEAT
	      BEGIN
		G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] :=
		    ZBA_SURFACE [I].
		    ZDE_SURFACE_ARCHIVE_DATA [G01AF_SURFACE_BYTE_POINTER];
		G99_INCREMENT_BYTE_POINTER;
		G01AF_SURFACE_BYTE_POINTER := G01AF_SURFACE_BYTE_POINTER + 1
	      END
	    UNTIL
	      (G01AF_SURFACE_BYTE_POINTER > CZAM_SIZE_OF_SURFACE_RECORD)
	      OR G01AC_FATAL_ERROR_OCCURRED
	  END;
	IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
	  BEGIN
	    I := I + 1;
	    IF (I <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
	      BEGIN
		G0505AA_ACTIVE_SURFACE_FOUND := FALSE;
		REPEAT
		  IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
		    G0505AA_ACTIVE_SURFACE_FOUND := TRUE
		  ELSE
		    I := I + 1
		UNTIL
		  G0505AA_ACTIVE_SURFACE_FOUND
		  OR (I > CZAB_MAX_NUMBER_OF_SURFACES)
	      END
	  END
      END
    UNTIL
      (I > CZAB_MAX_NUMBER_OF_SURFACES)
      OR G01AC_FATAL_ERROR_OCCURRED

END;




(**  G0510_XFER_RAY_DATA_TO_EXTERNAL  *****************************************
******************************************************************************)


PROCEDURE G0510_XFER_RAY_DATA_TO_EXTERNAL;

  VAR
      G0510AA_ACTIVE_RAY_FOUND	: BOOLEAN;
      
      RayOrdinal                : INTEGER;

BEGIN

  G0510AA_ACTIVE_RAY_FOUND := FALSE;
  RayOrdinal := 1;
  REPEAT
    IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
      G0510AA_ACTIVE_RAY_FOUND := TRUE
    ELSE
      RayOrdinal := RayOrdinal + 1
  UNTIL
    G0510AA_ACTIVE_RAY_FOUND
    OR (RayOrdinal > CZAC_MAX_NUMBER_OF_RAYS);
    
  IF G0510AA_ACTIVE_RAY_FOUND THEN
    REPEAT
      BEGIN
	G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] := 'R';
	G99_INCREMENT_BYTE_POINTER;
	IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
	  BEGIN
	    G01AJ_SUBRANGE_INTEGER := RayOrdinal;
	    G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] :=
		CHR (G01AJ_SUBRANGE_INTEGER);
	    G99_INCREMENT_BYTE_POINTER
	  END;
	IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
	  BEGIN
	    G01AG_RAY_BYTE_POINTER := 1;
	    REPEAT
	      BEGIN
		G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] :=
		    ZNA_RAY [RayOrdinal].
		    ZPD_RAY_ARCHIVE_DATA [G01AG_RAY_BYTE_POINTER];
		G99_INCREMENT_BYTE_POINTER;
		G01AG_RAY_BYTE_POINTER := G01AG_RAY_BYTE_POINTER + 1
	      END
	    UNTIL
	      (G01AG_RAY_BYTE_POINTER > CZAP_SIZE_OF_RAY_RECORD)
	      OR G01AC_FATAL_ERROR_OCCURRED
	  END;
	IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
	  BEGIN
	    RayOrdinal := RayOrdinal + 1;
	    IF (RayOrdinal <= CZAC_MAX_NUMBER_OF_RAYS) THEN
	      BEGIN
		G0510AA_ACTIVE_RAY_FOUND := FALSE;
		REPEAT
		  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
		    G0510AA_ACTIVE_RAY_FOUND := TRUE
		  ELSE
		    RayOrdinal := RayOrdinal + 1
		UNTIL
		  G0510AA_ACTIVE_RAY_FOUND
		  OR (RayOrdinal > CZAC_MAX_NUMBER_OF_RAYS)
	      END
	  END
      END
    UNTIL
      (RayOrdinal > CZAC_MAX_NUMBER_OF_RAYS)
      OR G01AC_FATAL_ERROR_OCCURRED

END;




(**  G0515_XFER_OPTION_DATA_TO_EXTERNAL	 **************************************
******************************************************************************)


PROCEDURE G0515_XFER_OPTION_DATA_TO_EXTERNAL;

BEGIN

  G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] := 'O';
  G99_INCREMENT_BYTE_POINTER;
  
  G01AH_OPTION_BYTE_POINTER := 1;
  
  WHILE (NOT G01AC_FATAL_ERROR_OCCURRED)
      AND (G01AH_OPTION_BYTE_POINTER <= CZAU_SIZE_OF_OPTION_RECORD) DO
    BEGIN
      G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] :=
	  ZFA_OPTION.ZFX_OPTION_ARCHIVE_DATA [G01AH_OPTION_BYTE_POINTER];
      G99_INCREMENT_BYTE_POINTER;
      G01AH_OPTION_BYTE_POINTER := G01AH_OPTION_BYTE_POINTER + 1
    END

END;




(**  G0520_XFER_ENVIRONMENT_DATA_TO_EXTERNAL  *********************************
******************************************************************************)


PROCEDURE G0520_XFER_ENVIRONMENT_DATA_TO_EXTERNAL;

BEGIN

  G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] := 'E';
  G99_INCREMENT_BYTE_POINTER;
  
  G01AI_ENVIRONMENT_BYTE_POINTER := 1;

  WHILE (NOT G01AC_FATAL_ERROR_OCCURRED)
      AND (G01AI_ENVIRONMENT_BYTE_POINTER <=
      CZAY_SIZE_OF_ENVIRONMENT_RECORD) DO
    BEGIN
      G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] := ZHA_ENVIRONMENT.
	  ZIF_ENVIRONMENT_ARCHIVE_DATA [G01AI_ENVIRONMENT_BYTE_POINTER];
      G99_INCREMENT_BYTE_POINTER;
      G01AI_ENVIRONMENT_BYTE_POINTER := G01AI_ENVIRONMENT_BYTE_POINTER + 1
    END

END;




(**  G05_TEMP_DATA_TO_EXTERNAL_STORAGE	***************************************
******************************************************************************)


BEGIN

  IF AED_TRANSFER_SURFACE_DATA THEN
    G0505_XFER_SURFACE_DATA_TO_EXTERNAL;
  
  IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
    IF AEE_TRANSFER_RAY_DATA THEN
      G0510_XFER_RAY_DATA_TO_EXTERNAL;
  
  IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
    IF AEF_TRANSFER_OPTION_DATA THEN
      G0515_XFER_OPTION_DATA_TO_EXTERNAL;
  
  IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
    IF AEG_TRANSFER_ENVIRONMENT_DATA THEN
      G0520_XFER_ENVIRONMENT_DATA_TO_EXTERNAL;
	
  IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
    BEGIN
      G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER] := 'X';
      G99_INCREMENT_BYTE_POINTER
    END;
  
  IF NOT G01AC_FATAL_ERROR_OCCURRED THEN
    IF G01AE_BYTE_POINTER > 1 THEN
      G97_WRITE_ARCHIVE_BLOCK

END;




(**  G10_TEMP_DATA_TO_INTERNAL_STORAGE	***************************************
******************************************************************************)


PROCEDURE G10_TEMP_DATA_TO_INTERNAL_STORAGE;

  VAR
      II  : INTEGER;


(**  G1005_XFER_SURFACE_DATA_TO_INTERNAL  *************************************
******************************************************************************)


PROCEDURE G1005_XFER_SURFACE_DATA_TO_INTERNAL;

  VAR
      I  : INTEGER;

BEGIN

  I := ORD (G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER]);
  G99_INCREMENT_BYTE_POINTER;
  G01AF_SURFACE_BYTE_POINTER := 1;

  WHILE (G01AF_SURFACE_BYTE_POINTER <= CZAM_SIZE_OF_SURFACE_RECORD)
      AND (NOT G01AC_FATAL_ERROR_OCCURRED) DO
    BEGIN
      IF AED_TRANSFER_SURFACE_DATA THEN
	ZBA_SURFACE [I].
	    ZDE_SURFACE_ARCHIVE_DATA [G01AF_SURFACE_BYTE_POINTER] :=
	    G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER];
      G99_INCREMENT_BYTE_POINTER;
      G01AF_SURFACE_BYTE_POINTER := G01AF_SURFACE_BYTE_POINTER + 1
    END

END;




(**  G1010_XFER_RAY_DATA_TO_INTERNAL  *****************************************
******************************************************************************)


PROCEDURE G1010_XFER_RAY_DATA_TO_INTERNAL;

  VAR
      RayOrdinal  : INTEGER;

BEGIN

  RayOrdinal := ORD (G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER]);
  G99_INCREMENT_BYTE_POINTER;
  G01AG_RAY_BYTE_POINTER := 1;

  WHILE (G01AG_RAY_BYTE_POINTER <= CZAP_SIZE_OF_RAY_RECORD)
      AND (NOT G01AC_FATAL_ERROR_OCCURRED) DO
    BEGIN
      IF AEE_TRANSFER_RAY_DATA THEN
	ZNA_RAY [RayOrdinal].
	    ZPD_RAY_ARCHIVE_DATA [G01AG_RAY_BYTE_POINTER] :=
	    G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER];
      G99_INCREMENT_BYTE_POINTER;
      G01AG_RAY_BYTE_POINTER := G01AG_RAY_BYTE_POINTER + 1
    END

END;




(**  G1015_XFER_OPTION_DATA_TO_INTERNAL	 **************************************
******************************************************************************)


PROCEDURE G1015_XFER_OPTION_DATA_TO_INTERNAL;

BEGIN

  G01AH_OPTION_BYTE_POINTER := 1;
  
  WHILE (G01AH_OPTION_BYTE_POINTER <= CZAU_SIZE_OF_OPTION_RECORD)
      AND (NOT G01AC_FATAL_ERROR_OCCURRED) DO
    BEGIN
      IF AEF_TRANSFER_OPTION_DATA THEN
	ZFA_OPTION.ZFX_OPTION_ARCHIVE_DATA [G01AH_OPTION_BYTE_POINTER] :=
	    G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER];
      G99_INCREMENT_BYTE_POINTER;
      G01AH_OPTION_BYTE_POINTER := G01AH_OPTION_BYTE_POINTER + 1
    END

END;




(**  G1020_XFER_ENVIRONMENT_DATA_TO_INTERNAL  *********************************
******************************************************************************)


PROCEDURE G1020_XFER_ENVIRONMENT_DATA_TO_INTERNAL;

BEGIN

  G01AI_ENVIRONMENT_BYTE_POINTER := 1;
  
  WHILE (G01AI_ENVIRONMENT_BYTE_POINTER <= CZAY_SIZE_OF_ENVIRONMENT_RECORD)
      AND (NOT G01AC_FATAL_ERROR_OCCURRED) DO
    BEGIN
      IF AEG_TRANSFER_ENVIRONMENT_DATA THEN
	ZHA_ENVIRONMENT.
	    ZIF_ENVIRONMENT_ARCHIVE_DATA [G01AI_ENVIRONMENT_BYTE_POINTER] :=
	    G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER];
      G99_INCREMENT_BYTE_POINTER;
      G01AI_ENVIRONMENT_BYTE_POINTER := G01AI_ENVIRONMENT_BYTE_POINTER + 1
    END

END;




(**  G10_TEMP_DATA_TO_INTERNAL_STORAGE	***************************************
******************************************************************************)


BEGIN

  IF AED_TRANSFER_SURFACE_DATA THEN
    FOR II := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
      ZBA_SURFACE [II].ZDA_ALL_SURFACE_DATA := ZEA_SURFACE_DATA_INITIALIZER;
      
  IF AEE_TRANSFER_RAY_DATA THEN
    FOR II := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
      ZNA_RAY [II].ZPA_ALL_RAY_DATA := ZQA_RAY_DATA_INITIALIZER;
  
  G98_READ_ARCHIVE_BLOCK;
  
  G01AD_RECORD_TYPE := G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER];
  G99_INCREMENT_BYTE_POINTER;
  
  IF (NOT G01AC_FATAL_ERROR_OCCURRED)
      AND (G01AD_RECORD_TYPE <> 'X') THEN
    REPEAT
      BEGIN
	IF G01AD_RECORD_TYPE = 'S' THEN
	  G1005_XFER_SURFACE_DATA_TO_INTERNAL
	ELSE
	IF G01AD_RECORD_TYPE = 'R' THEN
	  G1010_XFER_RAY_DATA_TO_INTERNAL
	ELSE
	IF G01AD_RECORD_TYPE = 'O' THEN
	  G1015_XFER_OPTION_DATA_TO_INTERNAL
	ELSE
	IF G01AD_RECORD_TYPE = 'E' THEN
	  G1020_XFER_ENVIRONMENT_DATA_TO_INTERNAL;
	G01AD_RECORD_TYPE := G01AB_ARCHIVE_BLOCK [G01AE_BYTE_POINTER];
	G99_INCREMENT_BYTE_POINTER
      END
    UNTIL
      (G01AD_RECORD_TYPE = 'X')
      OR G01AC_FATAL_ERROR_OCCURRED

END;




(**  G15_PERM_DATA_TO_EXTERNAL_STORAGE	***************************************
******************************************************************************)


PROCEDURE G15_PERM_DATA_TO_EXTERNAL_STORAGE;

  VAR
      G15AA_WRITE_HEADER   : BOOLEAN;
      G15AD_WRITE_HEADER_2 : BOOLEAN;

      J                    : INTEGER;
      I                    : INTEGER;
      SaveStringLength     : INTEGER;

      G15AB_HOLD_REAL	   : DOUBLE;

      G15AC_OUTPUT_STRING  : STRING;
      G15AE_TEMP_STRING	   : STRING;


FUNCTION IntToStr (IntegerNumber : INTEGER) : STRING;

  VAR
      TempString  : STRING;

BEGIN

  Str (IntegerNumber, TempString);
  IntToStr := TempString

END;

FUNCTION FltToStr (RealNumber : DOUBLE) : STRING;

  VAR
      TempString  : STRING;

BEGIN

  Str (RealNumber, TempString);
  FltToStr := TempString

END;




(**  G1505_WRITE_OPTIMIZE_LINE	***********************************************
******************************************************************************)


PROCEDURE G1505_WRITE_OPTIMIZE_LINE;

BEGIN

  IF LENGTH (G15AC_OUTPUT_STRING) > 0 THEN
    BEGIN
      IF G15AD_WRITE_HEADER_2 THEN
	BEGIN
	  STR (I, G15AE_TEMP_STRING);
	  G15AC_OUTPUT_STRING := CONCAT (CSAJ_GET_SURF_OPTIMIZE_DATA,
	      G15AE_TEMP_STRING, ' ', G15AC_OUTPUT_STRING);
	  G15AD_WRITE_HEADER_2 := FALSE;
	  IF G15AA_WRITE_HEADER THEN
	    BEGIN
	      G15AC_OUTPUT_STRING := CONCAT (',,,', CAAL_SET_UP_OPTIMIZATION,
		  G15AC_OUTPUT_STRING);
	      G15AA_WRITE_HEADER := FALSE
	    END
	  ELSE
	    G15AC_OUTPUT_STRING := CONCAT (',,', G15AC_OUTPUT_STRING)
	END
      ELSE
	G15AC_OUTPUT_STRING := CONCAT (',', G15AC_OUTPUT_STRING);
      WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
      G15AC_OUTPUT_STRING := ''
    END

END;




(**  G15_PERM_DATA_TO_EXTERNAL_STORAGE	***************************************
******************************************************************************)


BEGIN

  G15AA_WRITE_HEADER := TRUE;

  IF AED_TRANSFER_SURFACE_DATA THEN
    BEGIN
      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	      IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
	        BEGIN
	          IF (I > 1) THEN
              IF NOT ZBA_SURFACE [I - 1].ZBB_SPECIFIED THEN
		            G15AA_WRITE_HEADER := TRUE;
	            IF G15AA_WRITE_HEADER THEN
                BEGIN
		              WRITE (ZAE_ARCHIVE_TEXT, ',,,', CAAB_SET_UP_SURFACE_DATA);
		              WRITE (ZAE_ARCHIVE_TEXT, CBAB_SPECIFY_NEW_SURFACE);
		              WRITE (ZAE_ARCHIVE_TEXT, I, ' ');
		              G15AA_WRITE_HEADER := FALSE
	              END;
	            WRITE (ZAE_ARCHIVE_TEXT, ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV, ' ');
	            IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1] THEN
	              WRITE (ZAE_ARCHIVE_TEXT, ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].
		                ZCH_GLASS_NAME, ' ')
	            ELSE
	              WRITE (ZAE_ARCHIVE_TEXT, ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].
		                ZBI_REFRACTIVE_INDEX:8:5, ' ');
	            IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
	              WRITE (ZAE_ARCHIVE_TEXT, ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].
		                ZCH_GLASS_NAME, ' ')
	            ELSE
                WRITE (ZAE_ARCHIVE_TEXT, ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].
		                ZBI_REFRACTIVE_INDEX:8:5, ' ');
	            WRITELN (ZAE_ARCHIVE_TEXT, ZBA_SURFACE [I].ZBQ_VERTEX_Z)
          END;
        G15AC_OUTPUT_STRING := ',,,S ';
        FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
          BEGIN
	          IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
	            BEGIN
                STR (I, G15AE_TEMP_STRING);
                G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
                    G15AE_TEMP_STRING + ' ';
            (* The following code is for switches that do not require data *)
	          IF ZBA_SURFACE [I].ZBE_CYLINDRICAL THEN
		          G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		              CKAM_CYLINDRICAL_SURF_SW, ' ');
            IF ZBA_SURFACE [I].ZBD_REFLECTIVE THEN
		          G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		              CKBP_REFLECTIVE_SURFACE_SW, ' ');
	          IF ZBA_SURFACE [I].ZBF_OPD_REFERENCE THEN
		          G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		              CKBC_OPD_REF_SURF_SWITCH, ' ');
            IF ZBA_SURFACE [I].ZCI_RAY_TERMINATION_SURFACE THEN
		          G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		              CKAJ_RAY_TERMINATION_SURF_SW, ' ');
            IF ZBA_SURFACE [I].ZBY_BEAMSPLITTER_SURFACE THEN
		          G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		              CKAK_BEAMSPLITTER_SURF_SW, ' ');
            IF ZBA_SURFACE [I].ZCC_SCATTERING_SURFACE THEN
		          G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		              CKAL_SCATTERING_SURF_SW, ' ');
            (* The following code is for switches that require data *)
            IF ZBA_SURFACE [I].LensletArray THEN
              BEGIN
                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
                    SurfaceArraySwitch, ' ',
                    SurfaceArrayXRepeat, ' ',
                    ZBA_SURFACE [I].LensletArrayTotalColumns, ' ',
                    SurfaceArrayYRepeat, ' ',
                    ZBA_SURFACE [I].LensletArrayTotalRows, ' ',
                    SurfaceArrayXSpacing, ' ',
                    ZBA_SURFACE [I].LensletArrayPitchX, ' ',
                    SurfaceArrayYSpacing, ' ',
                    ZBA_SURFACE [I].LensletArrayPitchY, ' ');
                G15AC_OUTPUT_STRING := ''
              END;
	          IF ZBA_SURFACE [I].ZBH_OUTSIDE_DIMENS_SPECD THEN
		          IF ZBA_SURFACE [I].ZCL_OUTSIDE_APERTURE_IS_SQR THEN
		            BEGIN
		              WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
			                CKBL_SQUARE_OUTSIDE_SW,
			                CKBF_GET_OUTSIDE_WIDTH_X, ZBA_SURFACE [I].
                      ZCP_OUTSIDE_APERTURE_WIDTH_X, ' ',
			                CKBG_GET_OUTSIDE_WIDTH_Y, ZBA_SURFACE [I].
			                ZCQ_OUTSIDE_APERTURE_WIDTH_Y);
		              G15AC_OUTPUT_STRING := ''
		            END
		          ELSE
		          IF ZBA_SURFACE [I].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
		            BEGIN
		              WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
			                CKBN_ELLIPTICAL_OUTSIDE_SW,
			                CKBF_GET_OUTSIDE_WIDTH_X, ZBA_SURFACE [I].
			                ZCP_OUTSIDE_APERTURE_WIDTH_X, ' ',
			                CKBG_GET_OUTSIDE_WIDTH_Y, ZBA_SURFACE [I].
			                ZCQ_OUTSIDE_APERTURE_WIDTH_Y);
		              G15AC_OUTPUT_STRING := ''
		            END
		          ELSE
		            BEGIN
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
			                CKBJ_CIRCULAR_OUTSIDE_SW,
			                CKAF_GET_OUTSIDE_DIA, ZBA_SURFACE [I].
			                ZBJ_OUTSIDE_APERTURE_DIA);
		              G15AC_OUTPUT_STRING := ''
		            END;
	            IF ZBA_SURFACE [I].ZCT_INSIDE_DIMENS_SPECD THEN
		            IF ZBA_SURFACE [I].ZCM_INSIDE_APERTURE_IS_SQR THEN
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
			                  CKBM_SQUARE_INSIDE_SW,
			                  CKBH_GET_INSIDE_WIDTH_X, ZBA_SURFACE [I].
			                  ZCR_INSIDE_APERTURE_WIDTH_X, ' ',
			                  CKBI_GET_INSIDE_WIDTH_Y, ZBA_SURFACE [I].
                        ZCS_INSIDE_APERTURE_WIDTH_Y);
                    G15AC_OUTPUT_STRING := ''
		              END
		            ELSE
		            IF ZBA_SURFACE [I].ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
			                  CKBO_ELLIPTICAL_INSIDE_SW,
			                  CKBH_GET_INSIDE_WIDTH_X, ZBA_SURFACE [I].
			                  ZCR_INSIDE_APERTURE_WIDTH_X, ' ',
			                  CKBI_GET_INSIDE_WIDTH_Y, ZBA_SURFACE [I].
			                  ZCS_INSIDE_APERTURE_WIDTH_Y);
                    G15AC_OUTPUT_STRING := ''
		              END
		            ELSE
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
			                  CKBK_CIRCULAR_INSIDE_SW,
			                  CKAG_GET_INSIDE_DIA, ZBA_SURFACE [I].
			                  ZBK_INSIDE_APERTURE_DIA);
                    G15AC_OUTPUT_STRING := ''
		              END;
	              IF (ZBA_SURFACE [I].SurfaceForm = HighOrderAsphere) THEN
		              BEGIN
                    G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		                    CKAI_DEFORMATION_CONSTS_SW, ' ');
                    FOR J := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
		                  BEGIN
		                    WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
                            J, ' ', ZBA_SURFACE [I].SurfaceShapeParameters.
                            ZCA_DEFORMATION_CONSTANT [J]);
		                    G15AC_OUTPUT_STRING := ''
                      END
                  END
                ELSE
                (* This next portion of code must appear AFTER diameter
                processing, because diameter processing turns off the
                CPC switch. *)
                IF (ZBA_SURFACE [I].SurfaceForm = CPC)
                    OR (ZBA_SURFACE [I].SurfaceForm = HybridCPC) THEN
                  BEGIN
		                G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		                    CKAZ_DEFINE_CPC, ',,');
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
                        ZBA_SURFACE [I].SurfaceShapeParameters.
                        MaxEntranceAngleInAirDeg);
		                WRITELN (ZAE_ARCHIVE_TEXT,
                        ZBA_SURFACE [I].SurfaceShapeParameters.
                        ExitAngleDeg);
                    WRITELN (ZAE_ARCHIVE_TEXT,
                        ZBA_SURFACE [I].SurfaceShapeParameters.
                        CPCRefractiveIndex);
                    WRITELN (ZAE_ARCHIVE_TEXT,
                        ZBA_SURFACE [I].SurfaceShapeParameters.
                        RadiusOfOutputAperture, ',,,');
		                G15AC_OUTPUT_STRING := ''
                  END;
	              IF ABS (ZBA_SURFACE [I].ZCV_APERTURE_POSITION_X) > 1.0E-12 THEN
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKBR_GET_APERTURE_POSITION_X, ZBA_SURFACE [I].
		                    ZCV_APERTURE_POSITION_X);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ABS (ZBA_SURFACE [I].ZCW_APERTURE_POSITION_Y) > 1.0E-12 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKBS_GET_APERTURE_POSITION_Y, ZBA_SURFACE [I].
		                    ZCW_APERTURE_POSITION_Y);
		                G15AC_OUTPUT_STRING := ''
                  END;
	              IF ZBA_SURFACE [I].ZBL_CONIC_CONSTANT <> 0.0 THEN
		              BEGIN
                    WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAH_GET_CONIC_CONSTANT, ZBA_SURFACE [I].
		                    ZBL_CONIC_CONSTANT);
		                G15AC_OUTPUT_STRING := ''
		              END;
                IF ZBA_SURFACE [I].ScatteringAngleRadians <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKBD_GET_SCATTERING_ANGLE,
		                    ZBA_SURFACE [I].ScatteringAngleRadians *
		                    ALR_DEGREES_PER_RADIAN);
		                G15AC_OUTPUT_STRING := ''
		              END;
                IF ZBA_SURFACE [I].ZCK_SURFACE_REFLECTIVITY <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
                        CKBE_GET_SURFACE_REFLECTIVITY, ZBA_SURFACE [I].
		                    ZCK_SURFACE_REFLECTIVITY);
		                G15AC_OUTPUT_STRING := ''
		              END;
                IF ZBA_SURFACE [I].ZBM_VERTEX_X <> 0.0 THEN
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAN_GET_SURF_X_POSITION, ZBA_SURFACE [I].
		                    ZBM_VERTEX_X);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAO_GET_SURF_DELTA_X, ZBA_SURFACE [I].
		                    ZBN_VERTEX_DELTA_X);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ZBA_SURFACE [I].ZBO_VERTEX_Y <> 0.0 THEN
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAP_GET_SURF_Y_POSITION, ZBA_SURFACE [I].
		                    ZBO_VERTEX_Y);
		                G15AC_OUTPUT_STRING := ''
                  END;
	              IF ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAQ_GET_SURF_DELTA_Y, ZBA_SURFACE [I].
		                    ZBP_VERTEX_DELTA_Y);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAS_GET_SURF_DELTA_Z, ZBA_SURFACE [I].
		                    ZBR_VERTEX_DELTA_Z);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ZBA_SURFACE [I].ZBS_ROLL <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAT_GET_SURF_ROLL, ZBA_SURFACE [I].
                        ZBS_ROLL);
		                G15AC_OUTPUT_STRING := ''
		              END;
                IF ZBA_SURFACE [I].ZBT_DELTA_ROLL <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAU_GET_SURF_DELTA_ROLL, ZBA_SURFACE [I].
		                    ZBT_DELTA_ROLL);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ZBA_SURFACE [I].ZBU_PITCH <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAV_GET_SURF_PITCH, ZBA_SURFACE [I].
		                    ZBU_PITCH);
		                G15AC_OUTPUT_STRING := ''
		              END;
                IF ZBA_SURFACE [I].ZBV_DELTA_PITCH <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAW_GET_SURF_DELTA_PITCH, ZBA_SURFACE [I].
                        ZBV_DELTA_PITCH);
		                G15AC_OUTPUT_STRING := ''
		              END;
                IF ZBA_SURFACE [I].ZBW_YAW <> 0.0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAX_GET_SURF_YAW, ZBA_SURFACE [I].
		                    ZBW_YAW);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF ZBA_SURFACE [I].ZBX_DELTA_YAW <> 0.0 THEN
                  BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING,
		                    CKAY_GET_SURF_DELTA_YAW, ZBA_SURFACE [I].
		                    ZBX_DELTA_YAW);
		                G15AC_OUTPUT_STRING := ''
		              END;
	              IF LENGTH (G15AC_OUTPUT_STRING) <> 0 THEN
		              BEGIN
		                WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
		                G15AC_OUTPUT_STRING := ''
		              END
          END;
        G15AC_OUTPUT_STRING := ','
    END;

  G15AA_WRITE_HEADER := TRUE;

      (* The following code is devoted exclusively to sleep/wake code. *)
  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	  IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
	    BEGIN
	      IF NOT ZBA_SURFACE [I].ZBC_ACTIVE THEN
	        IF G15AA_WRITE_HEADER THEN
		        BEGIN
		          STR (I, G15AE_TEMP_STRING);
		          G15AC_OUTPUT_STRING :=
		              CONCAT (',,,', CAAB_SET_UP_SURFACE_DATA,
		              CBAH_SLEEP_BLOCK_OF_SURFACES, G15AE_TEMP_STRING, ' ');
		          G15AA_WRITE_HEADER := FALSE
		        END
	        ELSE
	        IF I = CZAB_MAX_NUMBER_OF_SURFACES THEN
	          BEGIN
              WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING, I);
              G15AC_OUTPUT_STRING := '';
		          G15AA_WRITE_HEADER := TRUE
		        END
	        ELSE
	      ELSE
	      IF G15AA_WRITE_HEADER THEN
		      BEGIN
          END
	      ELSE
		      BEGIN
            STR ((I - 1), G15AE_TEMP_STRING);
		        G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		        G15AE_TEMP_STRING);
		        WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
		        G15AC_OUTPUT_STRING := '';
            G15AA_WRITE_HEADER := TRUE
		      END
	    END
	  ELSE
	  IF NOT G15AA_WRITE_HEADER THEN
	    BEGIN
	      STR ((I - 1), G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		    G15AE_TEMP_STRING);
	      WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
	      G15AC_OUTPUT_STRING := '';
	      G15AA_WRITE_HEADER := TRUE
	    END
  END;

  G15AA_WRITE_HEADER := TRUE;

  IF AEE_TRANSFER_RAY_DATA THEN
    BEGIN
      FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
	IF ZNA_RAY [I].ZNB_SPECIFIED THEN
	  BEGIN
	    IF (I > 1) THEN
	      IF NOT ZNA_RAY [I - 1].ZNB_SPECIFIED THEN
		G15AA_WRITE_HEADER := TRUE;
	    IF G15AA_WRITE_HEADER THEN
	      BEGIN
		WRITE (ZAE_ARCHIVE_TEXT, ',,,', CAAC_SET_UP_RAY_DATA);
		WRITE (ZAE_ARCHIVE_TEXT, CCAB_SPECIFY_NEW_RAY);
		WRITE (ZAE_ARCHIVE_TEXT, I, ' ');
		G15AA_WRITE_HEADER := FALSE
	      END;
	    WRITELN (ZAE_ARCHIVE_TEXT,
		ZNA_RAY [I].ZND_TAIL_X_COORDINATE, ' ',
		ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE, ' ',
		ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE);
	    WRITELN (ZAE_ARCHIVE_TEXT, '    ',
		ZNA_RAY [I].ZNG_HEAD_X_COORDINATE, ' ',
		ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE, ' ',
		ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE);
	    WRITELN (ZAE_ARCHIVE_TEXT, '    ',
		ZNA_RAY [I].ZNJ_WAVELENGTH, ' ',
		ZNA_RAY [I].ZNK_INCIDENT_MEDIUM_INDEX)
          END;
      G15AC_OUTPUT_STRING := ',,,R ';
      FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
        BEGIN
	  IF ZNA_RAY [I].ZNB_SPECIFIED THEN
	    BEGIN
              G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
                  IntToStr (I) + ' ';
              SaveStringLength := Length (G15AC_OUTPUT_STRING);
              IF ZNA_RAY [I].ZFR_BUNDLE_HEAD_DIAMETER <>
                  CZBC_DEFAULT_BUNDLE_HEAD_DIA THEN
                G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
                    CFAD_GET_BHD_VALUE +
	            FltToStr (ZNA_RAY [I].ZFR_BUNDLE_HEAD_DIAMETER);
              IF ZNA_RAY [I].MaxZenithDistance <>
	          DefaultMaxZenithDistance THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING + ' ' +
                    GetMaxZenithDistance +
	            FltToStr (ZNA_RAY [I].MaxZenithDistance);
              IF Length (G15AC_OUTPUT_STRING) <> SaveStringLength THEN
                BEGIN
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := '';
                  SaveStringLength := Length (G15AC_OUTPUT_STRING)
                END;
              IF ZNA_RAY [I].ZFC_TRACE_SYMMETRIC_FAN THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
                    CFAP_GENERATE_SYMMETRIC_FAN +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].TraceLinearXFan THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            GenerateLinearXFan +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].ZFB_TRACE_LINEAR_Y_FAN THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFAV_GENERATE_LINEAR_Y_FAN +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].ZFD_TRACE_ASYMMETRIC_FAN THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFAQ_GENERATE_ASYMMETRIC_FAN +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].ZFQ_TRACE_3FAN THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFAE_GENERATE_3FAN +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].TraceSquareGrid THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            GenerateSquareGrid +
	            IntToStr (ZNA_RAY [I].NumberOfRings)
              ELSE
              IF ZNA_RAY [I].ZFE_TRACE_HEXAPOLAR_BUNDLE THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFAR_GENERATE_HEXAPOLAR_ARRAY +
	            IntToStr (ZNA_RAY [I].NumberOfRings)
              ELSE
              IF ZNA_RAY [I].ZFF_TRACE_ISOMETRIC_BUNDLE THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFAS_GENERATE_ISOMETRIC_ARRAY +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].ZFG_TRACE_RANDOM_RAYS THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFAT_GENERATE_RANDOM_ARRAY +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	            CFBF_GENERATE_SOLID_ANGLE_ARRAY +
	            IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].TraceOrangeSliceRays THEN
	        G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
                    GenerateOrangeSliceArray +
                    IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle)
              ELSE
              IF ZNA_RAY [I].TRACE_LAMBERTIAN_RAYS THEN
                BEGIN
                  G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
                      GENERATE_LAMBERTIAN_ARRAY +
                      IntToStr (ZNA_RAY [I].NumberOfRaysInFanOrBundle);
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := '';
                  G15AC_OUTPUT_STRING := GetMaxZenithDistance +
                      FltToStr (ZNA_RAY [I].MaxZenithDistance) + ' ' +
                      GetMinZenithDistance +
                      FltToStr (ZNA_RAY [I].MinZenithDistance);
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := '';
                  G15AC_OUTPUT_STRING := GetAzimuthAngularCenter +
                      FltToStr (ZNA_RAY [I].AzimuthAngularCenter) + ' ' +
                      GetAzimuthAngularSemiLength +
                      FltToStr (ZNA_RAY [I].AzimuthAngularSemiLength);
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := ''
                END
              ELSE
              IF ZNA_RAY [I].TRACE_GAUSSIAN_RAYS THEN
                BEGIN
	          G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	              GENERATE_GAUSSIAN_ARRAY +
	              IntToStr (ZNA_RAY [I].
                      NumberOfRaysInFanOrBundle) + ' ';
	          IF ZNA_RAY [I].HEAD_X_IS_GAUSSIAN THEN
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_HEAD_X_GAUSSIAN +
	                GET_HEAD_X_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_X_HEAD * 2.355)
	          ELSE
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_HEAD_X_UNIFORM +
	                GET_HEAD_X_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_X_HEAD * 2.0);
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := '';
	          IF ZNA_RAY [I].HEAD_Y_IS_GAUSSIAN THEN
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_HEAD_Y_GAUSSIAN +
	                GET_HEAD_Y_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_Y_HEAD * 2.355)
	          ELSE
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_HEAD_Y_UNIFORM +
	                GET_HEAD_Y_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_Y_HEAD * 2.0);
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := '';
	          IF ZNA_RAY [I].TAIL_X_IS_GAUSSIAN THEN
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_TAIL_X_GAUSSIAN +
	                GET_TAIL_X_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_X_TAIL * 2.355)
	          ELSE
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_TAIL_X_UNIFORM +
	                GET_TAIL_X_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_X_TAIL * 2.0);
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := '';
	          IF ZNA_RAY [I].TAIL_Y_IS_GAUSSIAN THEN
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_TAIL_Y_GAUSSIAN +
	                GET_TAIL_Y_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_Y_TAIL * 2.355)
	          ELSE
                    G15AC_OUTPUT_STRING := G15AC_OUTPUT_STRING +
	                ENABLE_TAIL_Y_UNIFORM +
	                GET_TAIL_Y_DIMENSION +
                        FltToStr (ZNA_RAY [I].SIGMA_Y_TAIL * 2.0);
                  IF ZNA_RAY [I].Astigmatism <>
                      DefaultGaussianBeamAstigmatism THEN
                    BEGIN
                      WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                      G15AC_OUTPUT_STRING := '';
                      WRITELN (ZAE_ARCHIVE_TEXT, GET_ASTIGMATISM,
                          ZNA_RAY [I].Astigmatism, ',')
                    END
                  ELSE
                    BEGIN
                      WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING, ',');
                      G15AC_OUTPUT_STRING := ''
                    END
	        END;
              IF (Length (G15AC_OUTPUT_STRING) <> SaveStringLength)
                  AND (Length (G15AC_OUTPUT_STRING) <> 0) THEN
                BEGIN
                  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
                  G15AC_OUTPUT_STRING := ','
                END
              ELSE
                G15AC_OUTPUT_STRING := ',,,R '
            END
	END;
      G15AA_WRITE_HEADER := TRUE;
      (* The following code is devoted exclusively to sleep/wake code. *)
      FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
	IF ZNA_RAY [I].ZNB_SPECIFIED THEN
	  BEGIN
	    IF NOT ZNA_RAY [I].ZNC_ACTIVE THEN
	      IF G15AA_WRITE_HEADER THEN
		BEGIN
		  STR (I, G15AE_TEMP_STRING);
		  G15AC_OUTPUT_STRING := CONCAT (',,,', CAAC_SET_UP_RAY_DATA,
		      CCAH_SLEEP_BLOCK_OF_RAYS, G15AE_TEMP_STRING, ' ');
		  G15AA_WRITE_HEADER := FALSE
		END
	      ELSE
	      IF I = CZAC_MAX_NUMBER_OF_RAYS THEN
	        BEGIN
		  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING, I);
		  G15AC_OUTPUT_STRING := '';
		  G15AA_WRITE_HEADER := TRUE
		END
	      ELSE
	    ELSE
	      IF G15AA_WRITE_HEADER THEN
		BEGIN
		END
	      ELSE
		BEGIN
		  STR ((I - 1), G15AE_TEMP_STRING);
		  G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		      G15AE_TEMP_STRING);
		  WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
		  G15AC_OUTPUT_STRING := '';
		  G15AA_WRITE_HEADER := TRUE
		END
	  END
	ELSE
	  IF NOT G15AA_WRITE_HEADER THEN
	    BEGIN
	      STR ((I - 1), G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  G15AE_TEMP_STRING);
	      WRITELN (ZAE_ARCHIVE_TEXT, G15AC_OUTPUT_STRING);
	      G15AC_OUTPUT_STRING := '';
	      G15AA_WRITE_HEADER := TRUE
	    END
    END;

  G15AA_WRITE_HEADER := TRUE;

  IF AED_TRANSFER_SURFACE_DATA THEN
    BEGIN
      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	BEGIN
	  G15AD_WRITE_HEADER_2 := TRUE;
	  G15AC_OUTPUT_STRING := '';
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMC_OPTIMIZE_RADIUS THEN
	    G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		CUAB_OPTIMIZE_RADIUS_SW);
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMD_ENFORCE_RADIUS_BOUNDS THEN
	    BEGIN
	      Str (ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1:12, G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAD_GET_RADIUS_BOUND_1, G15AE_TEMP_STRING, ' ');
	      Str (ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2:12, G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAE_GET_RADIUS_BOUND_2, G15AE_TEMP_STRING, ' ')
	    END;
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZME_PERMIT_SURF_PITCH_REVERSAL THEN
	    G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		CUAF_PERMIT_SURF_PITCH_REV_SW);
	  G1505_WRITE_OPTIMIZE_LINE;
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMG_OPTIMIZE_POSITION THEN
	    BEGIN
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAH_OPTIMIZE_POSITION_SW);
	      Str (ZBA_SURFACE [I].ZMU_POSITION_BOUND_1:12,
	          G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAJ_GET_POSITION_BOUND_1, G15AE_TEMP_STRING, ' ');
	      Str (ZBA_SURFACE [I].ZMV_POSITION_BOUND_2:12,
	          G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAK_GET_POSITION_BOUND_2, G15AE_TEMP_STRING, ' ')
	    END;
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMM_CONTROL_SEPARATION THEN
	    BEGIN
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAI_CONTROL_SEPARATION);
	      STR (ZBA_SURFACE [I].ZLN_NEXT_SURFACE, G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAR_GET_NEXT_SURFACE, G15AE_TEMP_STRING, ' ');
	      Str (ZBA_SURFACE [I].ZLQ_THICKNESS:12, G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAS_GET_THICKNESS, G15AE_TEMP_STRING, ' ');
	      Str (ZBA_SURFACE [I].ZLO_DELTA_THICKNESS:12, G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAT_GET_DELTA_THICKNESS, G15AE_TEMP_STRING, ' ')
	    END;
	  G1505_WRITE_OPTIMIZE_LINE;
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMI_OPTIMIZE_GLASS THEN
	    G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		CUAL_OPTIMIZE_GLASS_TYPE_SW);
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMJ_USE_PREFERRED_GLASS THEN
	    G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		CUAM_USE_PREFERRED_GLASSES_SW);
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMK_OPTIMIZE_CONIC_CONSTANT THEN
	    G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		CUAN_OPTIMIZE_CONIC_CONST_SW);
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZML_ENFORCE_CONIC_CONST_BOUNDS THEN
	    BEGIN
	      Str (ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1:12,
		  G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAP_GET_CONIC_CONST_BOUND_1, G15AE_TEMP_STRING, ' ');
	      Str (ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2:12,
		  G15AE_TEMP_STRING);
	      G15AC_OUTPUT_STRING := CONCAT (G15AC_OUTPUT_STRING,
		  CUAQ_GET_CONIC_CONST_BOUND_2, G15AE_TEMP_STRING, ' ')
	    END;
	  G1505_WRITE_OPTIMIZE_LINE
	END
    END;

  IF AEF_TRANSFER_OPTION_DATA THEN
    BEGIN
      WRITELN (ZAE_ARCHIVE_TEXT, ',,,', CAAG_SET_UP_TRACE_OPTIONS);
      IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBL_GET_DESIG_SURF_ORDINAL,
            ' ', ZFA_OPTION.ZGK_DESIGNATED_SURFACE,
            ' ', CFBK_GET_VIEWPORT_DIAMETER,
            ' ', ZFA_OPTION.ZGL_VIEWPORT_DIAMETER);
      IF ZFA_OPTION.ApertureStopSurface <>
          ZFA_OPTION.ZGK_DESIGNATED_SURFACE THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', GetApertureStopSurface,
	          ZFA_OPTION.ApertureStopSurface);
      IF ZFA_OPTION.ZGC_VIEWPORT_POSITION_X <>
	        CZBB_DEFAULT_VIEWPORT_POSITION THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBN_GET_VIEWPORT_POSITION_X,
	          ZFA_OPTION.ZGC_VIEWPORT_POSITION_X);
      IF ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y <>
	        CZBB_DEFAULT_VIEWPORT_POSITION THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBO_GET_VIEWPORT_POSITION_Y,
	          ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y);
      IF ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z <>
	        CZBB_DEFAULT_VIEWPORT_POSITION THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBU_GET_VIEWPORT_POSITION_Z,
	          ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z);
      IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBG_ENABLE_RECURSIVE_TRACE);
      IF ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFCD_ENABLE_SURFACE_SEQUENCER);
      IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	        CZBQ_REVERSE_PROCESSING_SEQUENCE THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', CFCC_GET_SURFACE_SEQUENCE,
	          CFCH_ENABLE_REVERSE_SEQUENCING, ',')
      ELSE
      IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	        CZBR_AUTO_SEQUENCING THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFCC_GET_SURFACE_SEQUENCE,
	          CFCI_ENABLE_AUTO_SEQUENCING, ',')
      ELSE
      IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	        CZBS_USER_SPECIFIED_SEQUENCE THEN
	      BEGIN
	        WRITELN (ZAE_ARCHIVE_TEXT, ',', CFCC_GET_SURFACE_SEQUENCE);
	        FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	          IF (ZFA_OPTION.ZGT_SURFACE_SEQUENCER [I] > 0)
		            AND (ZFA_OPTION.ZGT_SURFACE_SEQUENCER [I] <=
		            CZAB_MAX_NUMBER_OF_SURFACES) THEN
	            WRITELN (ZAE_ARCHIVE_TEXT, I, ' ',
		              ZFA_OPTION.ZGT_SURFACE_SEQUENCER [I]);
	            WRITELN (ZAE_ARCHIVE_TEXT)
	      END;
      IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBR_ENABLE_RAY_FILE_READ,
	          ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME);
      IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBQ_ENABLE_RAY_FILE_WRITE,
	          ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME, ' ',
	          ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE);
      IF ZFA_OPTION.DisplayLocalData THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFCJ_ENABLE_LOCAL_DETAIL_TO_CONSOLE);
      IF ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAF_ENABLE_DETAIL_TO_CONSOLE);
      IF ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAX_ENABLE_DETAIL_PRINT);
      IF ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAZ_ENABLE_DETAIL_TO_FILE,
	          ZFA_OPTION.ZGB_TRACE_DETAIL_FILE);
      IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAH_ENABLE_SPOT_DIAGRAM);
      IF ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAL_ENABLE_SPOT_DIAGRAM_FILE,
	          ZFA_OPTION.ZFM_SPOT_DIAGRAM_FILE_NAME);
      IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBB_ENABLE_FULL_OPD_DISPLAY)
      ELSE
      IF ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBM_ENABLE_BRIEF_OPD_DISPLAY);
      IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAN_ENABLE_PSF_FILE,
	          ZFA_OPTION.ZFN_PSF_FILE_NAME);
      IF ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAJ_ENABLE_AREA_INTENSITY_HIST)
      ELSE
      IF ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFAW_ENABLE_RADIUS_INTENSITY_HIST)
      ELSE
      IF ZFA_OPTION.EnableLinearIntensityHist THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', EnableLinearIntensityHistogram);
      IF ZFA_OPTION.ZGR_QUIET_ERRORS THEN
	      WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBT_DISABLE_ERROR_DISPLAY);
      IF ZFA_OPTION.DRAW_RAYS THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', CFBV_ENABLE_DRAW_RAYS);
      IF ZFA_OPTION.ShowSurfaceNumbers THEN
        WRITELN (ZAE_ARCHIVE_TEXT, ',', EnableDisplaySurfaceNumbers);
      WRITELN (ZAE_ARCHIVE_TEXT, ',')
    END;

  IF AEG_TRANSFER_ENVIRONMENT_DATA THEN
    BEGIN
    END;

  WRITELN (ZAE_ARCHIVE_TEXT);
  WRITELN (ZAE_ARCHIVE_TEXT)

END;




(**  G20_PERM_DATA_TO_INTERNAL_STORAGE	***************************************
******************************************************************************)


PROCEDURE G20_PERM_DATA_TO_INTERNAL_STORAGE;

  VAR
      I  : INTEGER;

BEGIN

  IF AED_TRANSFER_SURFACE_DATA THEN
    FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
      ZBA_SURFACE [I].ZDA_ALL_SURFACE_DATA := ZEA_SURFACE_DATA_INITIALIZER;

  IF AEE_TRANSFER_RAY_DATA THEN
    FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
      ZNA_RAY [I].ZPA_ALL_RAY_DATA := ZQA_RAY_DATA_INITIALIZER

END;




(**  G90_OPEN_OUTPUT_ARCHIVE_TEXT  ********************************************
******************************************************************************)


PROCEDURE G90_OPEN_OUTPUT_ARCHIVE_TEXT;

  VAR
      SaveIOResult       : INTEGER;

BEGIN

  G01AA_ARCHIVE_FILE_OPEN := FALSE;

  ASSIGN (ZAE_ARCHIVE_TEXT, AKZ_ARCHIVE_FILE_NAME);
  {$I-}
  RESET (ZAE_ARCHIVE_TEXT);
  {$I+}
  
  SaveIOResult := IORESULT;

  IF SaveIOResult <> 0 THEN
    BEGIN
      {$I-}
      REWRITE (ZAE_ARCHIVE_TEXT);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('FATAL ERROR: Attempt to create archive file "' +
	      AKZ_ARCHIVE_FILE_NAME + '" failed.');
	  CommandIOMemo.IOHistory.Lines.add ('IORESULT is: ' +
              IntToStr (SaveIOResult) + '.')
	END
      ELSE
	G01AA_ARCHIVE_FILE_OPEN := TRUE
    END
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ATTENTION: File "' +
          AKZ_ARCHIVE_FILE_NAME + '" already exists.');
      Q970AB_OUTPUT_STRING := 'Do you wish to over-write the data?';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      IF Q970AA_OK_TO_PROCEED THEN
	BEGIN
	  {$I-}
	  REWRITE (ZAE_ARCHIVE_TEXT);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR: Attempt to create archive file "' +
		  AKZ_ARCHIVE_FILE_NAME + '" failed.');
	      CommandIOMemo.IOHistory.Lines.add ('IORESULT is: ' +
                  IntToStr (SaveIOResult) + '.')
	    END
	  ELSE
	    BEGIN
	      G01AA_ARCHIVE_FILE_OPEN := TRUE;
	      G01AE_BYTE_POINTER := 1
	    END
	END
      ELSE
	CLOSE (ZAE_ARCHIVE_TEXT)
    END

END;




(**  G91_OPEN_INPUT_ARCHIVE_TEXT  *********************************************
******************************************************************************)


PROCEDURE G91_OPEN_INPUT_ARCHIVE_TEXT;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  G01AA_ARCHIVE_FILE_OPEN := FALSE;
  
  ASSIGN (ZAE_ARCHIVE_TEXT, AKZ_ARCHIVE_FILE_NAME);
  {$I-}
  RESET (ZAE_ARCHIVE_TEXT);
  {$I+}

  SaveIOResult := IORESULT;

  IF SaveIOResult <> 0 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('FATAL ERROR: Attempt to open archive file "' +
	  AKZ_ARCHIVE_FILE_NAME + '" failed.');
      CommandIOMemo.IOHistory.Lines.add ('IORESULT is: ' +
          IntToStr (SaveIOResult) + '.')
    END
  ELSE
    G01AA_ARCHIVE_FILE_OPEN := TRUE

END;




(**  G95_OPEN_OUTPUT_ARCHIVE_FILE  ********************************************
******************************************************************************)


PROCEDURE G95_OPEN_OUTPUT_ARCHIVE_FILE;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  G01AA_ARCHIVE_FILE_OPEN := FALSE;

  ASSIGN (ZAB_ARCHIVE_FILE, AKZ_ARCHIVE_FILE_NAME);
  {$I-}
  RESET (ZAB_ARCHIVE_FILE);
  {$I+}
  
  SaveIOResult := IORESULT;
  
  IF SaveIOResult <> 0 THEN
    BEGIN
      {$I-}
      REWRITE (ZAB_ARCHIVE_FILE, CZBG_CHARS_IN_ONE_BLOCK);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('FATAL ERROR: Attempt to create archive file "' +
	      AKZ_ARCHIVE_FILE_NAME + '" failed.');
	  CommandIOMemo.IOHistory.Lines.add ('IORESULT is: ' +
              IntToStr (SaveIOResult) + '.')
	END
      ELSE
	BEGIN
	  G01AA_ARCHIVE_FILE_OPEN := TRUE;
	  G01AE_BYTE_POINTER := 1
	END
    END
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ATTENTION: File "' +
          AKZ_ARCHIVE_FILE_NAME + '" already exists.');
      Q970AB_OUTPUT_STRING := 'Do you wish to over-write the data?';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      IF Q970AA_OK_TO_PROCEED THEN
	BEGIN
	  {$I-}
	  REWRITE (ZAB_ARCHIVE_FILE, CZBG_CHARS_IN_ONE_BLOCK);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR: Attempt to create archive file "' +
		  AKZ_ARCHIVE_FILE_NAME + '" failed.');
	      CommandIOMemo.IOHistory.Lines.add ('IORESULT is: ' +
                  IntToStr (SaveIOResult) + '.')
	    END
	  ELSE
	    BEGIN
	      G01AA_ARCHIVE_FILE_OPEN := TRUE;
	      G01AE_BYTE_POINTER := 1
	    END
	END
      ELSE
	CLOSE (ZAB_ARCHIVE_FILE)
    END

END;




(**  G96_OPEN_INPUT_ARCHIVE_FILE  *********************************************
******************************************************************************)


PROCEDURE G96_OPEN_INPUT_ARCHIVE_FILE;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  G01AA_ARCHIVE_FILE_OPEN := FALSE;
  
  ASSIGN (ZAB_ARCHIVE_FILE, AKZ_ARCHIVE_FILE_NAME);
  {$I-}
  RESET (ZAB_ARCHIVE_FILE, CZBG_CHARS_IN_ONE_BLOCK);
  {$I+}
  
  SaveIOResult := IORESULT;

  IF SaveIOResult <> 0 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('FATAL ERROR: Attempt to open archive file "' +
	  AKZ_ARCHIVE_FILE_NAME + '" failed.');
      CommandIOMemo.IOHistory.Lines.add ('IORESULT is: ' +
          IntToStr (SaveIOResult) + '.')
    END
  ELSE
    BEGIN
      G01AA_ARCHIVE_FILE_OPEN := TRUE;
      G01AE_BYTE_POINTER := 1
    END

END;




(**  G97_WRITE_ARCHIVE_BLOCK  *************************************************
******************************************************************************)


PROCEDURE G97_WRITE_ARCHIVE_BLOCK;

  VAR
      N	 : INTEGER;

BEGIN

  BLOCKWRITE (ZAB_ARCHIVE_FILE, G01AB_ARCHIVE_BLOCK, 1, N);
  
  IF N <> 1 THEN
    BEGIN
      G01AC_FATAL_ERROR_OCCURRED := TRUE;
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('FATAL ERROR: Attempt to write to archive file "' +
	  AKZ_ARCHIVE_FILE_NAME + '" failed.');
      CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
          IntToStr (IORESULT) + '.')
    END

END;




(**  G98_READ_ARCHIVE_BLOCK  **************************************************
******************************************************************************)


PROCEDURE G98_READ_ARCHIVE_BLOCK;

  VAR
      N	 : INTEGER;

BEGIN

  BLOCKREAD (ZAB_ARCHIVE_FILE, G01AB_ARCHIVE_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      G01AC_FATAL_ERROR_OCCURRED := TRUE;
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('FATAL ERROR: Attempt to read from archive file "' +
	  AKZ_ARCHIVE_FILE_NAME + '" failed.');
      CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
          IntToStr (IORESULT) + '.')
    END

END;




(**  G99_INCREMENT_BYTE_POINTER	 **********************************************
******************************************************************************)


PROCEDURE G99_INCREMENT_BYTE_POINTER;

  VAR
      N	 : INTEGER;

BEGIN

  G01AE_BYTE_POINTER := G01AE_BYTE_POINTER + 1;
  
  IF G01AE_BYTE_POINTER > 512 THEN
    BEGIN
      G01AE_BYTE_POINTER := 1;
      IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE THEN
	G97_WRITE_ARCHIVE_BLOCK
      ELSE
      IF AKB_GET_DATA_FROM_TEMPORARY_STORAGE THEN
	G98_READ_ARCHIVE_BLOCK
    END

END;




(**  G01_ARCHIVE_DATA  ********************************************************
******************************************************************************)


BEGIN

  G01AC_FATAL_ERROR_OCCURRED := FALSE;

  IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE THEN
    BEGIN
      G95_OPEN_OUTPUT_ARCHIVE_FILE;
      IF G01AA_ARCHIVE_FILE_OPEN THEN
	BEGIN
	  G05_TEMP_DATA_TO_EXTERNAL_STORAGE;
          CommandIOMemo.Caption := Concat ('Input/Output History    ' +
              'Just wrote file ', AKZ_ARCHIVE_FILE_NAME);
	  CLOSE (ZAB_ARCHIVE_FILE)
	END
      ELSE
	BEGIN
	END
    END
  ELSE
  IF AKB_GET_DATA_FROM_TEMPORARY_STORAGE THEN
    BEGIN
      G96_OPEN_INPUT_ARCHIVE_FILE;
      IF G01AA_ARCHIVE_FILE_OPEN THEN
	BEGIN
	  G10_TEMP_DATA_TO_INTERNAL_STORAGE;
          CommandIOMemo.Caption := Concat ('Input/Output History    ' +
              'Just read-in file ', AKZ_ARCHIVE_FILE_NAME);
	  CLOSE (ZAB_ARCHIVE_FILE)
	END
    END
  ELSE
  IF AKC_PUT_DATA_IN_PERMANENT_STORAGE THEN
    BEGIN
      G90_OPEN_OUTPUT_ARCHIVE_TEXT;
      IF G01AA_ARCHIVE_FILE_OPEN THEN
	BEGIN
          CommandIOdlg.Caption := 'Please enter archive file comments.  ' +
              '(Enter blank line to quit.)';
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('PLEASE ENTER ARCHIVE FILE COMMENTS.' +
	      '  (ENTER BLANK LINE TO QUIT.)');
	  G01AL_LINE_COUNTER := 1;
	  REPEAT
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add
                  (IntToStr (G01AL_LINE_COUNTER) + '>');
              S01AP_FORCE_END_OF_LINE := TRUE;
              S01_PROCESS_REQUEST;
              StringCount := CommandIOMemo.IOHistory.Lines.Count;
              CommandIOMemo.IOHistory.Lines [StringCount - 1] :=
                  CommandIOMemo.IOHistory.Lines [StringCount - 1] +
                  S01BB_INPUT_AREA;
              IF S01AB_USER_IS_DONE THEN
                WRITELN (ZAE_ARCHIVE_TEXT, '')
              ELSE
                WRITELN (ZAE_ARCHIVE_TEXT, S01BB_INPUT_AREA);
	      G01AL_LINE_COUNTER := G01AL_LINE_COUNTER + 1
	    END
	  UNTIL S01AB_USER_IS_DONE;
	  Q970AB_OUTPUT_STRING :=
	      'OK to write archive file?';
	  Q970_REQUEST_PERMIT_TO_PROCEED;
	  IF Q970AA_OK_TO_PROCEED THEN
	    G15_PERM_DATA_TO_EXTERNAL_STORAGE;
            CommandIOMemo.Caption := Concat ('Input/Output History    ' +
                'Just wrote file ', AKZ_ARCHIVE_FILE_NAME);
	    CLOSE (ZAE_ARCHIVE_TEXT)
	END
      ELSE
	BEGIN
	END
    END
  ELSE
  IF AKD_GET_DATA_FROM_PERMANENT_STORAGE THEN
    BEGIN
      G91_OPEN_INPUT_ARCHIVE_TEXT;
      IF G01AA_ARCHIVE_FILE_OPEN THEN
	BEGIN
	  REPEAT
	    BEGIN
	      READLN (ZAE_ARCHIVE_TEXT, G01AK_COMMENT_STRING);
	      CommandIOMemo.IOHistory.Lines.add (G01AK_COMMENT_STRING)
	    END
	  UNTIL LENGTH (G01AK_COMMENT_STRING) = 0;
	  CLOSE (ZAE_ARCHIVE_TEXT);
	  Q970AB_OUTPUT_STRING :=
	      'OK to bring in this file?';
	  Q970_REQUEST_PERMIT_TO_PROCEED;
	  IF Q970AA_OK_TO_PROCEED THEN
	    BEGIN
	      S01AO_USE_ALTERNATE_INPUT_FILE := TRUE;
	      S01AG_ALTERNATE_INPUT_FILE_NAME :=
		  AKZ_ARCHIVE_FILE_NAME;
              (* Read and ignore the initial comment lines... *)
	      REPEAT
		BEGIN
		  S01_PROCESS_REQUEST;
		  IF NOT S01AC_NULL_RESPONSE_GIVEN THEN
		    S01AP_FORCE_END_OF_LINE := TRUE
		END
	      UNTIL
		S01AC_NULL_RESPONSE_GIVEN;
              (* Process the commands and data.  First,
                 initialize the data storage areas... *)
	      G20_PERM_DATA_TO_INTERNAL_STORAGE;
              CommandIOMemo.Caption := Concat ('Input/Output History    ' +
                  'Just read-in file ', AKZ_ARCHIVE_FILE_NAME)
	    END
	END
    END

END;




(**  LADSArchiveUnit  ********************************************************
*****************************************************************************)


BEGIN

END.

