UNIT LADSListUnit;

INTERFACE

  USES Printers;

  TYPE
      LineArray = ARRAY [1..25] OF STRING;

  VAR
      ListFullData                    : BOOLEAN;
      ListParametersAlreadyAvailable  : BOOLEAN;
      ListSurfacesAndRays             : BOOLEAN;

      FirstSurface                    : INTEGER;
      LastSurface                     : INTEGER;
      FirstRay                        : INTEGER;
      LastRay                         : INTEGER;

PROCEDURE ListInputData
    (VAR NeedListFile, NeedPrintout  : BOOLEAN;
     VAR CommandString, ListfileName  : STRING);
PROCEDURE D12_DO_FULL_RAY_LIST
    (VAR LN  : INTEGER;
     VAR Line : LineArray;
     RayOrdinal : INTEGER);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSUtilUnit,
       LADSData,
       LADSInitUnit,
       LADSq1Unit,
       LADSq6Unit,
       LADSq7Unit,
       LADSCommandIOMemoUnit;


(**  ListInputData  ***********************************************************
******************************************************************************)


PROCEDURE ListInputData;

  CONST
      MAX_LINES_PER_CRT_SCREEN    = 20;
      FIELD_WIDTH                 = 20;
      SHORT_FIELD_WIDTH           = 7;

  VAR
      Valid                       : BOOLEAN;
      
      I				  : INTEGER;
      J				  : INTEGER;
      K				  : INTEGER;
      LN			  : INTEGER;
      SaveIOResult                : INTEGER;

      ERROR_DETECTED              : BOOLEAN;
      HEADINGS_NOT_PRINTED	  : BOOLEAN;

      TEMP_STRING		  : STRING;
      TEMP2_STRING		  : STRING;
      SLEEP_WAKE_FLAG		  : STRING [1];

      LINE			  : LineArray;


(**  D05_LIST_SURFACES	*******************************************************
******************************************************************************)


PROCEDURE D05_LIST_SURFACES;

  VAR
      I                           : INTEGER;
      J                           : INTEGER;

      X_COORD			  : DOUBLE;
      Y_COORD			  : DOUBLE;
      Z_COORD			  : DOUBLE;
      ROLL			  : DOUBLE;
      PITCH			  : DOUBLE;
      YAW			  : DOUBLE;
      STD_DEV			  : DOUBLE;

      REFLECT_REFRACT_FLAG	  : STRING [1];
      D05AA_GLASS_NAME_STRING	  : ARRAY [1..2] OF
				    STRING [FIELD_WIDTH];
      D05AB_GLASS_NAME_INIT	  : STRING [FIELD_WIDTH];

BEGIN

  D05AB_GLASS_NAME_INIT := '';
  FOR J := 1 TO (FIELD_WIDTH - 1) DO
    D05AB_GLASS_NAME_INIT := CONCAT (D05AB_GLASS_NAME_INIT, ' ');

  HEADINGS_NOT_PRINTED := TRUE;

  LN := 1;
  LINE [LN] := '';

  FOR I := FirstSurface TO LastSurface DO
    BEGIN
      IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1] THEN
        BEGIN
          D05AA_GLASS_NAME_STRING [1] := D05AB_GLASS_NAME_INIT;
          FOR J := 1 TO LENGTH (ZBA_SURFACE [I].
  	  ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME) DO
    	D05AA_GLASS_NAME_STRING [1, J] :=
  	    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME [J]
        END;
      IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
        BEGIN
          D05AA_GLASS_NAME_STRING [2] := D05AB_GLASS_NAME_INIT;
          FOR J := 1 TO LENGTH (ZBA_SURFACE [I].
  	  ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME) DO
  	D05AA_GLASS_NAME_STRING [2, J] :=
  	    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME [J]
        END;
      IF ListFullData THEN
        BEGIN
          LN := LN + 1;
          STR (I, LINE [LN]);
          LINE [LN] := CONCAT ('  SURFACE: ', LINE [LN]);
          IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
  	BEGIN
  	  LINE [LN] := CONCAT (LINE [LN], '  (SPECIFIED');
  	  IF ZBA_SURFACE [I].ZBC_ACTIVE THEN
    	    LINE [LN] := CONCAT (LINE [LN], ', ACTIVE')
  	  ELSE
  	    LINE [LN] := CONCAT (LINE [LN], ', INACTIVE');
  	  IF ZBA_SURFACE [I].ZBF_OPD_REFERENCE THEN
  	    LINE [LN] := CONCAT (LINE [LN], ', OPD');
  	  IF ZBA_SURFACE [I].ZCI_RAY_TERMINATION_SURFACE THEN
  	    LINE [LN] := CONCAT (LINE [LN], ', TERMINAL');
  	  IF ZBA_SURFACE [I].ZBY_BEAMSPLITTER_SURFACE THEN
  	    LINE [LN] := CONCAT (LINE [LN], ', BEAMSPLITTER');
  	  IF ZBA_SURFACE [I].ZCC_SCATTERING_SURFACE THEN
  	    LINE [LN] := CONCAT (LINE [LN], ', SCATTERER');
          IF ZBA_SURFACE [I].SurfaceForm = Conic THEN
            LINE [LN] := CONCAT (LINE [LN], ', CONIC')
          ELSE
          IF ZBA_SURFACE [I].SurfaceForm = HighOrderAsphere THEN
            LINE [LN] := CONCAT (LINE [LN], ', HIGH-ORDER ASPHERE')
          ELSE
          IF ZBA_SURFACE [I].SurfaceForm = CPC THEN
            LINE [LN] := CONCAT (LINE [LN], ', CPC')
          ELSE
          IF ZBA_SURFACE [I].SurfaceForm = HybridCPC THEN
            LINE [LN] := CONCAT (LINE [LN], ', HYBRID CPC');
  	  LINE [LN] := CONCAT (LINE [LN], ')')
  	END
          ELSE
  	LINE [LN] := CONCAT (LINE [LN], '  (NOT SPECIFIED)');
          (*******)
          LN := LN + 1;
          IF ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT THEN
  	LINE [LN] :=
  	    'RADIUS ...................  0.0 (FLAT)         '
          ELSE
          IF ZBA_SURFACE [I].ZBE_CYLINDRICAL THEN
  	LINE [LN] := 'RADIUS (CYLINDRICAL) ..... '
          ELSE
  	LINE [LN] := 'RADIUS (SPHERICAL) ....... ';
          IF NOT ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT THEN
  	BEGIN
  	  Str (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV:FIELD_WIDTH,
  	      TEMP_STRING);
    	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING)
  	END;
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBL_CONIC_CONSTANT:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('CONIC CONSTANT ........... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1] THEN
  	LINE [LN] := 'GLASS 1 '
          ELSE
  	LINE [LN] := 'INDEX 1 ';
          IF ZBA_SURFACE [I].ZBD_REFLECTIVE THEN
  	LINE [LN] := CONCAT (LINE [LN], '(REFLECTIVE) ..... ')
          ELSE
  	LINE [LN] := CONCAT (LINE [LN], '(REFRACTIVE) ..... ');
          IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1] THEN
  	LINE [LN] := CONCAT (LINE [LN], ' ',
  	    D05AA_GLASS_NAME_STRING [1])
          ELSE
    	BEGIN
  	  Str (ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].
  	      ZBI_REFRACTIVE_INDEX:FIELD_WIDTH, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING)
  	END;
          (*******)
          LN := LN + 1;
          IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
  	LINE [LN] := 'GLASS 2 '
          ELSE
  	LINE [LN] := 'INDEX 2 ';
          IF ZBA_SURFACE [I].ZBD_REFLECTIVE THEN
  	LINE [LN] := CONCAT (LINE [LN], '(REFLECTIVE) ..... ')
          ELSE
  	LINE [LN] := CONCAT (LINE [LN], '(REFRACTIVE) ..... ');
          IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
  	LINE [LN] := CONCAT (LINE [LN], ' ',
  	    D05AA_GLASS_NAME_STRING [2])
          ELSE
  	BEGIN
    	  Str (ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].
  	      ZBI_REFRACTIVE_INDEX:FIELD_WIDTH, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING)
  	END;
          (*******)
          IF ZBA_SURFACE [I].ZBH_OUTSIDE_DIMENS_SPECD THEN
  	IF ZBA_SURFACE [I].ZCL_OUTSIDE_APERTURE_IS_SQR THEN
  	  BEGIN
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCP_OUTSIDE_APERTURE_WIDTH_X:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('OUTER SQR CA WIDTH X ..... ',
  		LINE [LN]);
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCQ_OUTSIDE_APERTURE_WIDTH_Y:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('OUTER SQR CA WIDTH Y ..... ',
  		LINE [LN])
  	  END
  	ELSE
    	IF ZBA_SURFACE [I].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
  	  BEGIN
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCP_OUTSIDE_APERTURE_WIDTH_X:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('OUTER ELLIP CA WIDTH X ... ',
  		LINE [LN]);
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCQ_OUTSIDE_APERTURE_WIDTH_Y:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('OUTER ELLIP CA WIDTH Y ... ',
  		LINE [LN])
  	  END
  	ELSE
  	  BEGIN
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA:FIELD_WIDTH,
  	        LINE [LN]);
  	    LINE [LN] := CONCAT ('OUTER CA DIAMETER ........ ',
  		LINE [LN])
    	  END
          ELSE
  	BEGIN
  	  LN := LN + 1;
  	  Str (ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA:FIELD_WIDTH,
  	      LINE [LN]);
  	  LINE [LN] := CONCAT ('OUTER CA DIA (BY TRACE) .. ',
  	      LINE [LN])
  	END;
          IF ZBA_SURFACE [I].ZCT_INSIDE_DIMENS_SPECD THEN
  	IF ZBA_SURFACE [I].ZCM_INSIDE_APERTURE_IS_SQR THEN
  	  BEGIN
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCR_INSIDE_APERTURE_WIDTH_X:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('INNER SQR CA WIDTH X ..... ',
  		LINE [LN]);
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCS_INSIDE_APERTURE_WIDTH_Y:FIELD_WIDTH, LINE [LN]);
    	    LINE [LN] := CONCAT ('INNER SQR CA WIDTH Y ..... ',
  		LINE [LN])
  	  END
  	ELSE
  	IF ZBA_SURFACE [I].ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
  	  BEGIN
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCR_INSIDE_APERTURE_WIDTH_X:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('INNER ELLIP CA WIDTH X ... ',
  		LINE [LN]);
  	    LN := LN + 1;
  	    Str (ZBA_SURFACE [I].
  	        ZCS_INSIDE_APERTURE_WIDTH_Y:FIELD_WIDTH, LINE [LN]);
  	    LINE [LN] := CONCAT ('INNER ELLIP CA WIDTH Y ... ',
  		LINE [LN])
  	  END
  	ELSE
  	  BEGIN
  	    LN := LN + 1;
    	    Str (ZBA_SURFACE [I].ZBK_INSIDE_APERTURE_DIA:FIELD_WIDTH,
  	        LINE [LN]);
  	    LINE [LN] := CONCAT ('INNER CA DIAMETER ........ ',
  		LINE [LN])
  	  END;
          (*******)
          IF ABS (ZBA_SURFACE [I].ZCV_APERTURE_POSITION_X) > 1.0E-13 THEN
  	BEGIN
  	  LN := LN + 1;
  	  Str (ZBA_SURFACE [I].ZCV_APERTURE_POSITION_X:FIELD_WIDTH,
  	      LINE [LN]);
  	  LINE [LN] := CONCAT ('CLEAR APERTURE OFFSET X .. ',
  	      LINE [LN])
  	END;
          (*******)
          IF ABS (ZBA_SURFACE [I].ZCW_APERTURE_POSITION_Y) > 1.0E-13 THEN
  	BEGIN
  	  LN := LN + 1;
  	  Str (ZBA_SURFACE [I].ZCW_APERTURE_POSITION_Y:FIELD_WIDTH,
  	      LINE [LN]);
    	  LINE [LN] := CONCAT ('CLEAR APERTURE OFFSET Y .. ',
  	      LINE [LN])
  	END;
          (*******)
          LN := LN + 1;
          Str ((ZBA_SURFACE [I].ScatteringAngleRadians *
  	  ALR_DEGREES_PER_RADIAN):FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('SCATTERING ANGLE ......... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZCK_SURFACE_REFLECTIVITY:FIELD_WIDTH,
              LINE [LN]);
          LINE [LN] := CONCAT ('SURFACE REFLECTIVITY ..... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBM_VERTEX_X:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('VERTEX X-COORDINATE ...... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('VERTEX DELTA X ........... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBO_VERTEX_Y:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('VERTEX Y-COORDINATE ...... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('VERTEX DELTA Y ........... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBQ_VERTEX_Z:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('VERTEX Z-COORDINATE ...... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('VERTEX DELTA Z ........... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBW_YAW:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('YAW ...................... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBX_DELTA_YAW:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('DELTA YAW ................ ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBU_PITCH:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('PITCH .................... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBV_DELTA_PITCH:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('DELTA PITCH .............. ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBS_ROLL:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('ROLL ..................... ', LINE [LN]);
          (*******)
          LN := LN + 1;
          Str (ZBA_SURFACE [I].ZBT_DELTA_ROLL:FIELD_WIDTH, LINE [LN]);
          LINE [LN] := CONCAT ('DELTA ROLL ............... ', LINE [LN]);
          (*******)
          IF ZBA_SURFACE [I].SurfaceForm = HighOrderAsphere THEN
  	BEGIN
  	  K := 3; (* Goes opposite surface radius info *)
  	  LINE [K] :=
  	      CONCAT (LINE [K], '   -- DEFORMATION CONSTANTS --');
  	  FOR J := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
  	    BEGIN
  	      Str (ZBA_SURFACE [I].SurfaceShapeParameters.
  	          ZCA_DEFORMATION_CONSTANT [J]:FIELD_WIDTH,
  		  TEMP_STRING);
  	      STR (J, TEMP2_STRING);
  	      IF J < 10 THEN
  		TEMP2_STRING := CONCAT ('   ', TEMP2_STRING)
  	      ELSE
  	        TEMP2_STRING := CONCAT ('  ', TEMP2_STRING);
  	      LINE [J + K] := CONCAT (LINE [J + K],
  		  TEMP2_STRING, ' ... ', TEMP_STRING)
  	    END
    	END
        END
      ELSE
        BEGIN
          IF HEADINGS_NOT_PRINTED THEN
  	BEGIN
  	  LN := LN + 1;
  	  LINE [LN] := '';
  	  LN := LN + 1;
  	  LINE [LN] :=
  	      CONCAT ('  INACTIVE SURFACES = *    REFLECTIVE',
  	      ' SURFACES = "M"');
  	  LN := LN + 1;
  	  LINE [LN] := '';
  	  LN := LN + 1;
  	  LINE [LN] := CONCAT (
  	      'SURF        OUTSIDE   REF.    ------ POSITION --',
  	      '-----     --- ORIENTATION ---  ');
  	  LN := LN + 1;
  	  LINE [LN] := CONCAT (
    	      '  #  RADIUS   DIA.   INDEX   X-COORD  Y-COORD   ',
  	      'Z-COORD   YAW -> PITCH -> ROLL ');
  	  LN := LN + 1;
  	  LINE [LN] := CONCAT (
  	      ' -- -------- ------ ------- -------- -------- --',
  	      '------- ------- ------- -------');
  	  HEADINGS_NOT_PRINTED := FALSE
  	END;
          LN := LN + 1;
          STR (I:2, TEMP2_STRING);
          IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
  	BEGIN
  	  IF ZBA_SURFACE [I].ZBC_ACTIVE THEN
  	    SLEEP_WAKE_FLAG := ' '
  	  ELSE
  	    SLEEP_WAKE_FLAG := '*';
  	  IF ZBA_SURFACE [I].ZBD_REFLECTIVE THEN
  	    REFLECT_REFRACT_FLAG := 'M'
  	  ELSE
  	    REFLECT_REFRACT_FLAG := ' ';
    	  X_COORD := ZBA_SURFACE [I].ZBM_VERTEX_X +
  	      ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X;
  	  Y_COORD := ZBA_SURFACE [I].ZBO_VERTEX_Y +
  	      ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y;
  	  Z_COORD := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
  	      ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
  	  ROLL := ZBA_SURFACE [I].ZBS_ROLL +
  	      ZBA_SURFACE [I].ZBT_DELTA_ROLL;
  	  PITCH := ZBA_SURFACE [I].ZBU_PITCH +
  	      ZBA_SURFACE [I].ZBV_DELTA_PITCH;
  	  YAW := ZBA_SURFACE [I].ZBW_YAW +
  	      ZBA_SURFACE [I].ZBX_DELTA_YAW;
  	  LINE [LN] := CONCAT (SLEEP_WAKE_FLAG, TEMP2_STRING);
  	  Str (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV:9:3, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING);
  	  Str (ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA:7:2,
  	      TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING, ' ');
  	  IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
  	    FOR J := 1 TO SHORT_FIELD_WIDTH DO
    	      LINE [LN] :=
  	          CONCAT (LINE [LN], D05AA_GLASS_NAME_STRING [2, J])
  	  ELSE
  	    BEGIN
  	      Str (ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].
  	          ZBI_REFRACTIVE_INDEX:7:4, TEMP_STRING);
  	      LINE [LN] := CONCAT (LINE [LN], TEMP_STRING)
  	    END;
  	  LINE [LN] := CONCAT (LINE [LN], REFLECT_REFRACT_FLAG);
  	  Str (X_COORD:8:3, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING, ' ');
  	  Str (Y_COORD:8:3, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING, ' ');
  	  Str (Z_COORD:9:3, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING, ' ');
  	  Str (YAW:7:2, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING, ' ');
  	  Str (PITCH:7:2, TEMP_STRING);
  	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING, ' ');
  	  Str (ROLL:7:2, TEMP_STRING);
    	  LINE [LN] := CONCAT (LINE [LN], TEMP_STRING)
  	END
          ELSE
  	LINE [LN] := CONCAT (' ', TEMP2_STRING,
  	    ' >> SURFACE NOT SPECIFIED <<');
        END;
      IF ListFullData
          OR (LN >= MAX_LINES_PER_CRT_SCREEN) THEN
        BEGIN
          FOR J := 1 TO LN DO
  	BEGIN
  	  CommandIOMemo.IOHistory.Lines.add (LINE [J]);
  	  IF NeedListfile THEN
  	    WRITELN (ZAG_LIST_FILE, LINE [J]);
  	  IF NeedPrintout THEN
  	    WRITELN (ZAF_PRINT_FILE, LINE [J])
  	END;
          LN := 0;
          Q980_REQUEST_MORE_OUTPUT
        END
    END;

  IF NOT ListFullData THEN
    FOR J := 1 TO LN DO
      BEGIN
        CommandIOMemo.IOHistory.Lines.add (LINE [J]);
        IF NeedListfile THEN
          WRITELN (ZAG_LIST_FILE, LINE [J]);
        IF NeedPrintout THEN
          WRITELN (ZAF_PRINT_FILE, LINE [J])
      END

END;




(**  D10_LIST_RAYS  ***********************************************************
******************************************************************************)


PROCEDURE D10_LIST_RAYS;

  CONST
      MAX_LINES_PER_CRT_SCREEN = 20;

  VAR
      HEADINGS_NOT_PRINTED	  : BOOLEAN;

      I				  : INTEGER;
      J                           : INTEGER;
      LINE_COUNTER		  : INTEGER;

      SLEEP_WAKE_FLAG		  : STRING [1];

BEGIN

  HEADINGS_NOT_PRINTED := TRUE;

  LN := 1;
  LINE [LN] := '';

  FOR I := FirstRay TO LastRay DO
    BEGIN
      IF ListFullData THEN
        D12_DO_FULL_RAY_LIST (LN, LINE, I)
      ELSE
        BEGIN
  	  IF HEADINGS_NOT_PRINTED THEN
  	    BEGIN
  	      LN := LN + 1;
  	      LINE [LN] := '';
  	      LN := LN + 1;
  	      LINE [LN] := '  "SLEEPING" RAYS DENOTED BY *';
  	      LN := LN + 1;
  	      LINE [LN] := '';
  	      LN := LN + 1;
  	      LINE [LN] :=
  	  	      'RAY   TAIL      TAIL      TAIL      HEAD      ' +
  	  	      'HEAD      HEAD     WAVE-  INC MED';
  	      LN := LN + 1;
  	      LINE [LN] :=
  	  	      ' #   X-COORD   Y-COORD   Z-COORD   X-COORD   Y' +
  	  	      '-COORD   Z-COORD   LENGTH  INDEX ';
  	      LN := LN + 1;
  	      LINE [LN] :=
  	  	      ' -- --------- --------- --------- --------- --' +
  	  	      '------- --------- ------- -------';
  	      HEADINGS_NOT_PRINTED := FALSE
            END;
          LN := LN + 1;
          STR (I:2, TEMP2_STRING);
  	  IF ZNA_RAY [I].ZNB_SPECIFIED THEN
  	    BEGIN
  	      IF ZNA_RAY [I].ZNC_ACTIVE THEN
  	  	    SLEEP_WAKE_FLAG := ' '
  	      ELSE
  	  	    SLEEP_WAKE_FLAG := '*';
              LINE [LN] := SLEEP_WAKE_FLAG + TEMP2_STRING;
  	      STR (ZNA_RAY [I].ZND_TAIL_X_COORDINATE:9:3, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE:9:3, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE:9:3, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNG_HEAD_X_COORDINATE:9:3, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE:9:3, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE:9:3, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNJ_WAVELENGTH:7:1, TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING;
  	      STR (ZNA_RAY [I].ZNK_INCIDENT_MEDIUM_INDEX:7:4,
  	  	      TEMP_STRING);
  	      LINE [LN] := LINE [LN] + ' ' + TEMP_STRING
  	    END
  	  ELSE
            LINE [LN] := ' ' + TEMP2_STRING + ' >> RAY NOT SPECIFIED <<'
        END;
      IF ListFullData
          OR (LN >= MAX_LINES_PER_CRT_SCREEN) THEN
        BEGIN
          FOR J := 1 TO LN DO
  	    BEGIN
  	      CommandIOMemo.IOHistory.Lines.add (LINE [J]);
  	      IF NeedListfile THEN
  	        WRITELN (ZAG_LIST_FILE, LINE [J]);
  	      IF NeedPrintout THEN
  	        WRITELN (ZAF_PRINT_FILE, LINE [J])
            END;
          LN := 0;
          Q980_REQUEST_MORE_OUTPUT
        END
    END;

  IF NOT ListFullData THEN
    FOR J := 1 TO LN DO
      BEGIN	  
        CommandIOMemo.IOHistory.Lines.add (LINE [J]);	  
        IF NeedListfile THEN	  
          WRITELN (ZAG_LIST_FILE, LINE [J]);	  
        IF NeedPrintout THEN	  
          WRITELN (ZAF_PRINT_FILE, LINE [J])	  
      END

END;




(**  ListInputData  ***********************************************************
******************************************************************************)


BEGIN

  ERROR_DETECTED := FALSE;

  IF NeedPrintout THEN
    BEGIN
      AssignPrn (ZAF_PRINT_FILE);
      {$I-}
      REWRITE (ZAF_PRINT_FILE);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR: Could not bring printer on-line, at D01.1.');
	  CommandIOMemo.IOHistory.Lines.add ('Printer output is now disabled.');
	  NeedPrintout := FALSE;
	  Q970AB_OUTPUT_STRING :=
	      'Do you wish to continue with listing to CONSOLE?  (Y or N)';
	  Q970_REQUEST_PERMIT_TO_PROCEED;
	  IF NOT Q970AA_OK_TO_PROCEED THEN
	    ERROR_DETECTED := TRUE
	END
    END;

  IF NeedListfile THEN
    BEGIN
      ASSIGN (ZAG_LIST_FILE, ListfileName);
      {$I-}
      REWRITE (ZAG_LIST_FILE);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ERROR: Could not create file "' +
	      ListfileName + '", at D01.2.');
	  CommandIOMemo.IOHistory.Lines.add
              ('List file output is now disabled.');
	  NeedListfile := FALSE;
	  Q970AB_OUTPUT_STRING :=
	      'Do you wish to continue with listing to CONSOLE?  (Y or N)';
	  Q970_REQUEST_PERMIT_TO_PROCEED;
	  IF NOT Q970AA_OK_TO_PROCEED THEN
	    ERROR_DETECTED := TRUE
	END
      ELSE
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('Writing List output to file "' +
	      ListfileName + '"...')
	END
    END;

  IF NOT ERROR_DETECTED THEN
    BEGIN
      IF CommandString = CDAB_LIST_SURFACES THEN
        BEGIN
          Valid := TRUE;
          IF NOT ListParametersAlreadyAvailable THEN
            BEGIN
              Q041_REQUEST_FULL_OR_BRIEF_LIST (Valid, ListFullData);
              IF Valid THEN
                Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface,
                    Valid)
            END;
          IF Valid THEN
            D05_LIST_SURFACES
        END
      ELSE
      IF CommandString = CDAC_LIST_RAYS THEN
        BEGIN
          Valid := TRUE;
          IF NOT ListParametersAlreadyAvailable THEN
            BEGIN
              Q041_REQUEST_FULL_OR_BRIEF_LIST (Valid, ListFullData);
              IF Valid THEN
                Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid)
            END;
          IF Valid THEN
            D10_LIST_RAYS
        END
      ELSE
      IF ListSurfacesAndRays THEN
        BEGIN
          D05_LIST_SURFACES;
          D10_LIST_RAYS
        END
    END;

  IF NeedListfile THEN
    BEGIN
      WRITELN (ZAG_LIST_FILE);
      CLOSE (ZAG_LIST_FILE)
    END;

  IF NeedPrintout THEN
    BEGIN
      WRITELN (ZAF_PRINT_FILE);
      CLOSE (ZAF_PRINT_FILE)
    END

END;




(**  D12_DO_FULL_RAY_LIST  ****************************************************
******************************************************************************)

PROCEDURE D12_DO_FULL_RAY_LIST (VAR LN     : INTEGER;
                                VAR LINE   : LineArray;
                                RayOrdinal : INTEGER);

BEGIN

  LN := LN + 1;
  LINE [LN] := 'RAY ' + IntToStr (RayOrdinal) + ':';

  LN := LN + 1;
  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
    LINE [LN] := '  SPECIFIED.......................... TRUE'
  ELSE
    LINE [LN] := '  SPECIFIED.......................... FALSE';

  LN := LN + 1;
  IF ZNA_RAY [RayOrdinal].ZNC_ACTIVE THEN
    LINE [LN] := '  AWAKE.............................. TRUE'
  ELSE
    LINE [LN] := '  AWAKE.............................. FALSE';

  LN := LN + 1;
  IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
    LINE [LN] := '  SOLID ANGLE CONE HALF ANGLE........ ' +
	FloatToStr (ZNA_RAY [RayOrdinal].MaxZenithDistance)
  ELSE
  IF ZNA_RAY [RayOrdinal].TraceOrangeSliceRays THEN
    BEGIN
      LINE [LN] := '  SLICE CENTER ZENITH DISTANCE....... ' +
	  FloatToStr (ZNA_RAY [RayOrdinal].MaxZenithDistance);
      LN := LN + 1;
      LINE [LN] := '  SLICE ANGULAR SEMI WIDTH........... ' +
          FloatToStr (ZNA_RAY [RayOrdinal].
          OrangeSliceAngularHalfWidth);
      LN := LN + 1;
      LINE [LN] := '  RAY BUNDLE/FAN HEAD DIAMETER....... ' +
	  FloatToStr (ZNA_RAY [RayOrdinal].
          ZFR_BUNDLE_HEAD_DIAMETER)
    END
  ELSE
  IF ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
    BEGIN
      LINE [LN] := '  SOLID ANGLE MAX ZENITH DISTANCE.... ' +
	  FloatToStr (ZNA_RAY [RayOrdinal].MaxZenithDistance);
      LN := LN + 1;
      LINE [LN] := '  SOLID ANGLE MIN ZENITH DISTANCE.... ' +
          FloatToStr (ZNA_RAY [RayOrdinal].MinZenithDistance);
      LN := LN + 1;
      LINE [LN] := '  SOLID ANGLE AZIMUTH CENTER ANGLE... ' +
          FloatToStr (ZNA_RAY [RayOrdinal].AzimuthAngularCenter);
      LN := LN + 1;
      LINE [LN] := '  SOLID ANGLE AZIMUTH SEMI WIDTH..... ' +
          FloatToStr (ZNA_RAY [RayOrdinal].AzimuthAngularSemiLength);
      LN := LN + 1;
      LINE [LN] := '  RAY BUNDLE/FAN HEAD DIAMETER....... ' +
	  FloatToStr (ZNA_RAY [RayOrdinal].
          ZFR_BUNDLE_HEAD_DIAMETER)
    END
  ELSE
    LINE [LN] := '  RAY BUNDLE/FAN HEAD DIAMETER....... ' +
        FloatToStr (ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER);

  LN := LN + 1;
  LINE [LN] := '  COMPUTED RAY STATUS ............... ';
  IF ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN THEN
    LINE [LN] := LINE [LN] + 'SFAN, ' +
        IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].TraceLinearXFan THEN
    LINE [LN] := LINE [LN] + 'LXFAN, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN THEN
    LINE [LN] := LINE [LN] + 'LFAN, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN THEN
    LINE [LN] := LINE [LN] + 'AFAN, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN THEN
    LINE [LN] := LINE [LN] + '3FAN, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].TraceSquareGrid THEN
    LINE [LN] := LINE [LN] + 'SQR, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE THEN
    LINE [LN] := LINE [LN] + 'HEX, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE THEN
    LINE [LN] := LINE [LN] + 'ISO, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS THEN
    LINE [LN] := LINE [LN] + 'RAND, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
    LINE [LN] := LINE [LN] + 'SOLID, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].TraceOrangeSliceRays THEN
    LINE [LN] := LINE [LN] + 'SLICE, ' +
        IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
    LINE [LN] := LINE [LN] + 'LAMB, ' +
	IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) + ' RAYS'
  ELSE
  IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN
    BEGIN
      LINE [LN] := LINE [LN] + 'GAUSS, ' +
	  IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) +
          ' RAYS';
      LN := LN + 1;
      IF ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN THEN
	LINE [LN] := '  GAUSSIAN BUNDLE HEAD X FWHM ....... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_HEAD * 2.355)
      ELSE
	LINE [LN] := '  GAUSSIAN BUNDLE HEAD X DIAMETER ... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_HEAD * 2.0);
      IF ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN THEN
	LINE [LN] := '  GAUSSIAN BUNDLE HEAD Y FWHM ....... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD * 2.355)
      ELSE
	LINE [LN] := '  GAUSSIAN BUNDLE HEAD Y DIAMETER ... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD * 2.0);
      IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
	LINE [LN] := '  GAUSSIAN BUNDLE TAIL X FWHM ....... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL * 2.355)
      ELSE
	LINE [LN] := '  GAUSSIAN BUNDLE TAIL X DIAMETER ... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL * 2.0);
      IF ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
	LINE [LN] := '  GAUSSIAN BUNDLE TAIL Y FWHM ....... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL * 2.355)
      ELSE
	LINE [LN] := '  GAUSSIAN BUNDLE TAIL Y DIAMETER ... ' +
	    FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL * 2.0);
      LINE [LN] := '  ASTIGMATISM ....................... ' +
          FloatToStr (ZNA_RAY [RayOrdinal].Astigmatism)
    END
  ELSE
    LINE [LN] := LINE [LN] + 'OFF';

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE, LINE [LN]);
  LINE [LN] := '  TAIL OF PRINCIPAL RAY, X COORD..... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE, LINE [LN]);
  LINE [LN] := '  TAIL OF PRINCIPAL RAY, Y COORD..... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE, LINE [LN]);
  LINE [LN] := '  TAIL OF PRINCIPAL RAY, Z COORD..... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE, LINE [LN]);
  LINE [LN] := '  HEAD OF PRINCIPAL RAY, X COORD..... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE, LINE [LN]);
  LINE [LN] := '  HEAD OF PRINCIPAL RAY, Y COORD..... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE, LINE [LN]);
  LINE [LN] := '  HEAD OF PRINCIPAL RAY, Z COORD..... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH, LINE [LN]);
  LINE [LN] := '  RAY WAVELENGTH..................... ' +
      LINE [LN];

  LN := LN + 1;
  STR (ZNA_RAY [RayOrdinal].ZNK_INCIDENT_MEDIUM_INDEX, LINE [LN]);
  LINE [LN] := '  INCIDENT MEDIUM INDEX.............. ' +
      LINE [LN]

END;




(**  LADSListUnit  ***********************************************************
*****************************************************************************)


BEGIN

      ListParametersAlreadyAvailable := FALSE;
      ListSurfacesAndRays := FALSE

END.

