UNIT LADSSurfUnit;

INTERFACE

PROCEDURE B01_SET_UP_SURFACE_DATA (VAR CommandString  : STRING);

IMPLEMENTATION

  USES SysUtils,
       ExpertIO,
       LADSCommandIOMemoUnit,
       LADSData,
       LADSInitUnit,
       LADSq1Unit,
       LADSq5bUnit,
       LADSq5cUnit,
       LADSq6Unit,
       LADSq7Unit;


(**  B01_SET_UP_SURFACE_DATA  *************************************************
*******************************************************************************
*									      *
*  NOTE:  B01_SET_UP_SURFACE_DATA contains routines which add and delete      *
*  surfaces, and routines which modify surface data.			      *
*									      *
*******************************************************************************
******************************************************************************)


PROCEDURE B01_SET_UP_SURFACE_DATA;
      
PROCEDURE B05_SPECIFY_NEW_SURFACE;		      FORWARD;
PROCEDURE B10_INSERT_NEW_SURFACE;		      FORWARD;
PROCEDURE B15_DELETE_SURFACE;			      FORWARD;
PROCEDURE B20_COPY_BLOCK_OF_SURFACES;		      FORWARD;
PROCEDURE B25_MOVE_BLOCK_OF_SURFACES;		      FORWARD;
PROCEDURE B30_WAKE_UP_SURFACE;			      FORWARD;
PROCEDURE B35_PUT_SURF_TO_SLEEP;		      FORWARD;


(**  B05_SPECIFY_NEW_SURFACE  *************************************************
******************************************************************************)


PROCEDURE B05_SPECIFY_NEW_SURFACE;

  VAR
      B05AD_TIME_TO_QUIT	    : BOOLEAN;
      Valid                         : BOOLEAN;
      
      SurfaceOrdinal                : INTEGER;
      
      B05AA_SURF_DATA_TEMP_STORAGE  : ZDF_ALL_SURFACE_DATA;

BEGIN

  Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
  
  IF Valid THEN
    IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
      BEGIN
	CommandIOMemo.IOHistory.Lines.add ('');
	CommandIOMemo.IOHistory.Lines.add ('Surface ' +
            IntToStr (SurfaceOrdinal) + ' is already specified.');
	Q970AB_OUTPUT_STRING :=
	    'Do you wish to re-specify this surface?  (Y or N)';
	Q970_REQUEST_PERMIT_TO_PROCEED;
	IF Q970AA_OK_TO_PROCEED THEN
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('Re-initializing surface ' +
                IntToStr (SurfaceOrdinal) + '...');
	    B05AA_SURF_DATA_TEMP_STORAGE :=
		ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA;
	    ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
		ZEA_SURFACE_DATA_INITIALIZER;
	    Q101_REQUEST_RADIUS_OF_CURVATURE (SurfaceOrdinal, Valid);
	    IF Valid THEN
	      Q102_REQUEST_INDEX_OF_REFRACTION (1, SurfaceOrdinal, Valid);
	    IF Valid THEN
	      Q102_REQUEST_INDEX_OF_REFRACTION (2, SurfaceOrdinal, Valid);
	    IF Valid THEN
              Q120_REQUEST_SURFACE_POSITION (CKAR_GET_SURF_Z_POSITION,
		  SurfaceOrdinal);
	    IF Valid THEN
	      BEGIN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
		  ZBA_SURFACE [SurfaceOrdinal].
		      ZCK_SURFACE_REFLECTIVITY := 1.0;
		ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := FALSE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add ('SURFACE ' +
                    IntToStr (SurfaceOrdinal) + ' RE-SPECIFIED.')
	      END
	    ELSE
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add ('RESTORING SURFACE ' +
                    IntToStr (SurfaceOrdinal) + ' DATA...');
		ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
		    B05AA_SURF_DATA_TEMP_STORAGE
	      END
	  END
	ELSE
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('"N(ew/replace" COMMAND IGNORED.')
	  END
      END
    ELSE
      BEGIN
	B05AD_TIME_TO_QUIT := FALSE;
	REPEAT
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('READY TO ENTER NEW SURFACE ' +
		IntToStr (SurfaceOrdinal) + '...');
	    ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
		ZEA_SURFACE_DATA_INITIALIZER;
	    Q101_REQUEST_RADIUS_OF_CURVATURE (SurfaceOrdinal, Valid);
	    IF Valid THEN
	      Q102_REQUEST_INDEX_OF_REFRACTION (1, SurfaceOrdinal, Valid);
	    IF Valid THEN
	      Q102_REQUEST_INDEX_OF_REFRACTION (2, SurfaceOrdinal, Valid);
	    IF Valid THEN
	      Q120_REQUEST_SURFACE_POSITION (CKAR_GET_SURF_Z_POSITION,
		  SurfaceOrdinal);
	    IF Valid THEN
	      BEGIN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
		  ZBA_SURFACE [SurfaceOrdinal].
		      ZCK_SURFACE_REFLECTIVITY := 1.0;
		ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := FALSE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add ('SURFACE ' +
                    IntToStr (SurfaceOrdinal) + ' SPECIFIED.')
	      END;
	    IF Valid THEN
	      BEGIN
		SurfaceOrdinal := SurfaceOrdinal + 1;
		IF (SurfaceOrdinal <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
		  IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
		    B05AD_TIME_TO_QUIT := TRUE
		  ELSE
		    BEGIN
		    END
		ELSE
		  B05AD_TIME_TO_QUIT := TRUE
	      END
	    ELSE
	      B05AD_TIME_TO_QUIT := TRUE
	  END
	UNTIL
	  B05AD_TIME_TO_QUIT
      END
      
END;




(**  B10_INSERT_NEW_SURFACE  **************************************************
******************************************************************************)


PROCEDURE B10_INSERT_NEW_SURFACE;

  VAR
      Valid           : BOOLEAN;
      
      I               : INTEGER;
      SurfaceOrdinal  : INTEGER;

BEGIN
  
  Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
  
  IF Valid THEN
    BEGIN
      FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO (SurfaceOrdinal + 1) DO
	ZBA_SURFACE [I] := ZBA_SURFACE [I - 1];
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('READY TO ENTER NEW SURFACE ' +
	  IntToStr (SurfaceOrdinal) + '...');
      ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
	  ZEA_SURFACE_DATA_INITIALIZER;
      Q101_REQUEST_RADIUS_OF_CURVATURE (SurfaceOrdinal, Valid);
      IF Valid THEN
	Q102_REQUEST_INDEX_OF_REFRACTION (1, SurfaceOrdinal, Valid);
      IF Valid THEN
	Q102_REQUEST_INDEX_OF_REFRACTION (2, SurfaceOrdinal, Valid);
      IF Valid THEN
	Q120_REQUEST_SURFACE_POSITION (CKAR_GET_SURF_Z_POSITION,
	    SurfaceOrdinal);
      IF Valid THEN
	BEGIN
	  IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
	    ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY := 1.0;
	  ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED := TRUE;
	  ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE;
	  ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := FALSE
	END
    END

END;




(**  B15_DELETE_SURFACE	 ******************************************************
******************************************************************************)


PROCEDURE B15_DELETE_SURFACE;

  VAR
      I					 : INTEGER;
      J					 : INTEGER;
      K					 : INTEGER;
      FirstSurface                       : INTEGER;
      LastSurface                        : INTEGER;
      
      B15AA_DELETE_THIS_SURFACE		 : ARRAY
	  [1..CZAB_MAX_NUMBER_OF_SURFACES] OF BOOLEAN;
	  
      Valid                              : BOOLEAN;
      B15AB_AT_LEAST_ONE_SURF_TO_DELETE	 : BOOLEAN;

BEGIN

  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    B15AA_DELETE_THIS_SURFACE [I] := FALSE;
    
  B15AB_AT_LEAST_ONE_SURF_TO_DELETE := FALSE;

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE(S) OF SURFACES TO BE DELETED.  <<');
      CommandIOMemo.IOHistory.Lines.add
          ('(SURFACES WILL BE DELETED ONLY AFTER LIST IS COMPLETE.)')
    END;
    
  Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface, Valid);

  WHILE Valid DO
    BEGIN
      FOR I := FirstSurface TO LastSurface DO
	B15AA_DELETE_THIS_SURFACE [I] := TRUE;
      B15AB_AT_LEAST_ONE_SURF_TO_DELETE := TRUE;
      Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface, Valid)
    END;

  IF S01AC_NULL_RESPONSE_GIVEN
      AND B15AB_AT_LEAST_ONE_SURF_TO_DELETE THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('The following surfaces are scheduled for deletion...');
      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	IF B15AA_DELETE_THIS_SURFACE [I] THEN
	  CommandIOMemo.IOHistory.Lines.add ('     Surface ' +
              IntToStr (I) + '.');
      Q970AB_OUTPUT_STRING := 'Proceed with deletions?  (Y or N)';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      IF Q970AA_OK_TO_PROCEED THEN
	BEGIN
	  K := CZAB_MAX_NUMBER_OF_SURFACES;
          I := 1;
          REPEAT
	    BEGIN
	      IF B15AA_DELETE_THIS_SURFACE [I] THEN
		BEGIN
		  FOR J := I TO (K - 1) DO
		    BEGIN
		      ZBA_SURFACE [J] := ZBA_SURFACE [J + 1];
		      B15AA_DELETE_THIS_SURFACE [J] :=
			  B15AA_DELETE_THIS_SURFACE [J + 1]
		    END;
		  ZBA_SURFACE [K].ZDA_ALL_SURFACE_DATA :=
		      ZEA_SURFACE_DATA_INITIALIZER;
		  B15AA_DELETE_THIS_SURFACE [K] := FALSE;
		  K := K - 1;
		  I := I - 1
		END;
              I := I + 1
	    END
          UNTIL
            I >= K
	END
    END

END;




(**  B20_COPY_BLOCK_OF_SURFACES	 **********************************************
******************************************************************************)


PROCEDURE B20_COPY_BLOCK_OF_SURFACES;

  VAR
      Valid                         : BOOLEAN;
      
      B20AD_SURFACES_TO_COPY        : INTEGER;
      I			            : INTEGER;
      J			            : INTEGER;
      FirstSurface                  : INTEGER;
      LastSurface                   : INTEGER;
      DestinationSurface            : INTEGER;
      
      B20AA_SURF_DATA_TEMP_STORAGE  : ZDF_ALL_SURFACE_DATA;

BEGIN

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF SURFACES TO COPY.  <<')
    END;
    
  Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface, Valid);
  
  IF Valid THEN
    Q192_REQUEST_DESTINATION_SURFACE (FirstSurface, LastSurface,
        DestinationSurface, Valid);
    
  IF Valid THEN
    BEGIN
      IF DestinationSurface > LastSurface THEN
	BEGIN
	  FOR J := LastSurface DOWNTO FirstSurface DO
	    BEGIN
	      FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO
		  (DestinationSurface + 1) DO
		ZBA_SURFACE [I] := ZBA_SURFACE [I - 1];
	      ZBA_SURFACE [DestinationSurface] := ZBA_SURFACE [J]
	    END
	END
      ELSE
	BEGIN
	  B20AD_SURFACES_TO_COPY :=
	      (LastSurface - FirstSurface) + 1;
	  FOR J := 1 TO B20AD_SURFACES_TO_COPY DO
	    BEGIN
	      B20AA_SURF_DATA_TEMP_STORAGE :=
		  ZBA_SURFACE [LastSurface].ZDA_ALL_SURFACE_DATA;
	      FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO
		  (DestinationSurface + 1) DO
		ZBA_SURFACE [I] := ZBA_SURFACE [I - 1];
	      ZBA_SURFACE [DestinationSurface].ZDA_ALL_SURFACE_DATA :=
		  B20AA_SURF_DATA_TEMP_STORAGE
	    END
	END
    END
    
END;




(**  B25_MOVE_BLOCK_OF_SURFACES	 **********************************************
******************************************************************************)


PROCEDURE B25_MOVE_BLOCK_OF_SURFACES;

  VAR
      Valid                         : BOOLEAN;
      
      B25AD_SURFACES_TO_MOVE        : INTEGER;
      I			            : INTEGER;
      J			            : INTEGER;
      FirstSurface                  : INTEGER;
      LastSurface                   : INTEGER;
      DestinationSurface            : INTEGER;

      B25AA_SURF_DATA_TEMP_STORAGE  : ZDF_ALL_SURFACE_DATA;

BEGIN

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF SURFACES TO MOVE.  <<')
    END;
    
  Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface, Valid);
  
  IF Valid THEN
    Q192_REQUEST_DESTINATION_SURFACE (FirstSurface, LastSurface,
        DestinationSurface, Valid);
    
  IF Valid THEN
    BEGIN
      B25AD_SURFACES_TO_MOVE := (LastSurface - FirstSurface) + 1;
      IF DestinationSurface > LastSurface THEN
	BEGIN
	  FOR J := (LastSurface + 1) TO (DestinationSurface - 1) DO
	    BEGIN
	      B25AA_SURF_DATA_TEMP_STORAGE :=
		  ZBA_SURFACE [J].ZDA_ALL_SURFACE_DATA;
	      FOR I := J DOWNTO (J - (B25AD_SURFACES_TO_MOVE - 1)) DO
		ZBA_SURFACE [I] := ZBA_SURFACE [I - 1];
	      I := J - B25AD_SURFACES_TO_MOVE;
	      ZBA_SURFACE [I].ZDA_ALL_SURFACE_DATA :=
		  B25AA_SURF_DATA_TEMP_STORAGE
	    END
	END
      ELSE
	BEGIN
	  FOR J := (FirstSurface - 1) DOWNTO DestinationSurface DO
	    BEGIN
	      B25AA_SURF_DATA_TEMP_STORAGE :=
		  ZBA_SURFACE [J].ZDA_ALL_SURFACE_DATA;
	      FOR I := J TO (J + (B25AD_SURFACES_TO_MOVE - 1)) DO
		ZBA_SURFACE [I] := ZBA_SURFACE [I + 1];
	      I := J + B25AD_SURFACES_TO_MOVE;
	      ZBA_SURFACE [I].ZDA_ALL_SURFACE_DATA :=
		  B25AA_SURF_DATA_TEMP_STORAGE
	    END
	END
    END
	      
END;




(**  B30_WAKE_UP_SURFACE  *****************************************************
******************************************************************************)


PROCEDURE B30_WAKE_UP_SURFACE;

  VAR
      Valid         : BOOLEAN;
      
      I             : INTEGER;
      FirstSurface  : INTEGER;
      LastSurface   : INTEGER;

BEGIN
  
  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF SURFACES TO "WAKE UP".  <<')
    END;
    
  Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface, Valid);
  
  IF Valid THEN
    FOR I := FirstSurface TO LastSurface DO
      ZBA_SURFACE [I].ZBC_ACTIVE := TRUE

END;




(**  B35_PUT_SURF_TO_SLEEP  ***************************************************
******************************************************************************)


PROCEDURE B35_PUT_SURF_TO_SLEEP;

  VAR
      Valid         : BOOLEAN;
      
      I             : INTEGER;
      FirstSurface  : INTEGER;
      LastSurface   : INTEGER;

BEGIN

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF SURFACES TO "PUT TO SLEEP".  <<')
    END;
    
  Q191_REQUEST_SURF_ORDINAL_RANGE (FirstSurface, LastSurface, Valid);
  
  IF Valid THEN
    FOR I := FirstSurface TO LastSurface DO
      ZBA_SURFACE [I].ZBC_ACTIVE := FALSE;

END;




(**  B01_SET_UP_SURFACE_DATA  *************************************************
******************************************************************************)


BEGIN

  IF CommandString = CBAB_SPECIFY_NEW_SURFACE THEN
    B05_SPECIFY_NEW_SURFACE
  ELSE
  IF CommandString = CBAC_INSERT_NEW_SURFACE THEN
    B10_INSERT_NEW_SURFACE
  ELSE
  IF CommandString = CBAD_DELETE_BLOCK_OF_SURFACES THEN
    B15_DELETE_SURFACE
  ELSE
  IF CommandString = CBAE_COPY_BLOCK_OF_SURFACES THEN
    B20_COPY_BLOCK_OF_SURFACES
  ELSE
  IF CommandString = CBAF_MOVE_BLOCK_OF_SURFACES THEN
    B25_MOVE_BLOCK_OF_SURFACES
  ELSE
  IF CommandString = CBAG_WAKE_BLOCK_OF_SURFACES THEN
    B30_WAKE_UP_SURFACE
  ELSE
  IF CommandString = CBAH_SLEEP_BLOCK_OF_SURFACES THEN
    B35_PUT_SURF_TO_SLEEP

END;




(**  LADSB  ******************************************************************
*****************************************************************************)


BEGIN

END.

