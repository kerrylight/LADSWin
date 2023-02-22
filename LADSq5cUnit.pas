UNIT LADSq5cUnit;

INTERFACE

PROCEDURE Q101_REQUEST_RADIUS_OF_CURVATURE
    (SurfaceOrdinal : INTEGER;
     VAR Valid      : BOOLEAN);
PROCEDURE Q102_REQUEST_INDEX_OF_REFRACTION
    (Medium, SurfaceOrdinal : INTEGER;
     VAR Valid      : BOOLEAN);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSGlassVar,
       LADSData,
       LADSGlassCompUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(**  Q101_REQUEST_RADIUS_OF_CURVATURE  ****************************************
******************************************************************************)


PROCEDURE Q101_REQUEST_RADIUS_OF_CURVATURE;

  VAR
      CODE       : INTEGER;
      
      RealNumber : DOUBLE;

BEGIN

  Valid	 := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SURFACE ' + IntToStr (SurfaceOrdinal) +
          ' RADIUS OF CURVATURE';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER SURFACE ' + IntToStr (SurfaceOrdinal) +
                ' RADIUS OF CURVATURE');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpRadiusOfCurvature
      ELSE
	BEGIN
  	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
	  IF CODE = 0 THEN
	    IF RealNumber >= 0 THEN
	      BEGIN
		Valid := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV :=
		    RealNumber;
		IF ABS (RealNumber) < 1.0E-12 THEN
		  ZBA_SURFACE [SurfaceOrdinal].
		      ZBZ_SURFACE_IS_FLAT := TRUE
		ELSE
		  ZBA_SURFACE [SurfaceOrdinal].
		      ZBZ_SURFACE_IS_FLAT := FALSE
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q102_REQUEST_INDEX_OF_REFRACTION  ****************************************
******************************************************************************)


PROCEDURE Q102_REQUEST_INDEX_OF_REFRACTION;

  VAR
      GRINMaterialAliasFound     : BOOLEAN;
      ActualGRINMatlFound        : BOOLEAN;

      CODE                       : INTEGER;

      RealNumber                 : DOUBLE;

      Alias                      : GlassType;
      GRINMaterialName           : GlassType;

BEGIN

  Valid	:= FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER MEDIUM ' + IntToStr (Medium) + ' REFRACTIVE INDEX OR' +
          ' GLASS NAME';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER MEDIUM ' + IntToStr (Medium) + ' REFRACTIVE INDEX OR' +
	      ' GLASS NAME');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpIndexOfRefraction
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
	  IF CODE = 0 THEN
	    IF RealNumber >= 1.0 THEN
	      BEGIN
		Valid := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].
		    ZCG_INDEX_OR_GLASS [Medium].
		    ZBI_REFRACTIVE_INDEX := RealNumber;
		ZBA_SURFACE [SurfaceOrdinal].
		    ZCF_GLASS_NAME_SPECIFIED [Medium] := FALSE;
		ZBA_SURFACE [SurfaceOrdinal].
		    ZBD_REFLECTIVE := FALSE
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    IF LENGTH (S01AF_BLANKS_STRIPPED_RESPONSE_UC) <=
		CZAH_MAX_CHARS_IN_GLASS_NAME THEN
	      BEGIN
		AKJ_SPECIFIED_GLASS_NAME :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC;
		AKE_ADD_GLASS_TO_MINI_CATALOG := TRUE;
		U010_SEARCH_GLASS_CATALOG
		   (AKE_ADD_GLASS_TO_MINI_CATALOG,
		    AKF_GLASS_RECORD_FOUND,
                    FoundGradientIndexMaterial,
		    ABE_GLASS_IN_MINI_CATALOG,
		    ABC_GLASS_MINI_CAT_PTR);
		IF NOT AKF_GLASS_RECORD_FOUND THEN
		  BEGIN
                    Alias := AKJ_SPECIFIED_GLASS_NAME;
                    U016CheckBulkGRINMatlAliases
                        (Alias,
                        GRINMaterialAliasFound,
                        ActualGRINMatlFound,
                        GRINMaterialName);
                    IF GRINMaterialAliasFound THEN
                      BEGIN
                        Valid := TRUE;
		        ZBA_SURFACE [SurfaceOrdinal].
		            ZCG_INDEX_OR_GLASS [Medium].ZCH_GLASS_NAME :=
		            Alias;
		        ZBA_SURFACE [SurfaceOrdinal].
		            ZCF_GLASS_NAME_SPECIFIED [Medium] := TRUE;
		        ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE :=
		            FALSE
                      END
                    ELSE
                      BEGIN
		        CommandIOMemo.IOHistory.Lines.add ('');
		        CommandIOMemo.IOHistory.Lines.add
                            ('ATTENTION: Specified glass name "' +
			    AKJ_SPECIFIED_GLASS_NAME +
			    '" not found in glass catalog.');
                        AKJ_SPECIFIED_GLASS_NAME := ''
                      END
		  END
                ELSE
                IF FoundGradientIndexMaterial THEN
                  BEGIN
                    CommandIOMemo.IOHistory.Lines.add ('');
                    CommandIOMemo.IOHistory.Lines.add
                        ('ERROR:  Gradient index material ' +
                        AKJ_SPECIFIED_GLASS_NAME + ' must be ');
                    CommandIOMemo.IOHistory.Lines.add
                        ('referenced indirectly by an alias.  Use' +
                        ' the G(lass command');
                    CommandIOMemo.IOHistory.Lines.add
                        ('to establish an alias for this material.');
                    AKF_GLASS_RECORD_FOUND := FALSE;
                    AKJ_SPECIFIED_GLASS_NAME := '';
                    IF ABE_GLASS_IN_MINI_CATALOG THEN
                      BEGIN
                        ABE_GLASS_IN_MINI_CATALOG := FALSE;
	                ABD_GLASS_HIGH_PTR := ABD_GLASS_HIGH_PTR - 1;
                        ABC_GLASS_MINI_CAT_PTR := ABD_GLASS_HIGH_PTR
                      END
                  END
                ELSE
                  BEGIN
                    Valid := TRUE;
		    ZBA_SURFACE [SurfaceOrdinal].
		        ZCG_INDEX_OR_GLASS [Medium].ZCH_GLASS_NAME :=
		        AKJ_SPECIFIED_GLASS_NAME;
		    ZBA_SURFACE [SurfaceOrdinal].
		        ZCF_GLASS_NAME_SPECIFIED [Medium] := TRUE;
		    ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE :=
		        FALSE
                  END
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  LADSq5cUnit  ***********************************************************
****************************************************************************)

BEGIN

END.
