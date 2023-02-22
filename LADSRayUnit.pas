UNIT LADSRayUnit;

INTERFACE

PROCEDURE C01_SET_UP_RAY_DATA (VAR CommandString  : STRING);

IMPLEMENTATION

  USES
       SysUtils,
       ExpertIO,
       LADSCommandIOMemoUnit,
       LADSData,
       LADSq7Unit,
       LADSInitUnit;


(**  C01_SET_UP_RAY_DATA  *****************************************************
*******************************************************************************
*									      *
*  NOTE:  C01_SET_UP_RAY_DATA is the only entry point into the routines	      *
*  which add, delete, or modify ray data.				      *
*									      *
*******************************************************************************
******************************************************************************)


PROCEDURE C01_SET_UP_RAY_DATA;

PROCEDURE C05_SPECIFY_NEW_RAY;			  FORWARD;
PROCEDURE C10_INSERT_NEW_RAY;			  FORWARD;
PROCEDURE C15_DELETE_RAY;			  FORWARD;
PROCEDURE C20_COPY_BLOCK_OF_RAYS;		  FORWARD;
PROCEDURE C25_MOVE_BLOCK_OF_RAYS;		  FORWARD;
PROCEDURE C30_WAKE_UP_RAY;			  FORWARD;
PROCEDURE C35_PUT_RAY_TO_SLEEP;			  FORWARD;


(**  C05_SPECIFY_NEW_RAY  *****************************************************
******************************************************************************)


PROCEDURE C05_SPECIFY_NEW_RAY;

  VAR
      C05AD_TIME_TO_QUIT	   : BOOLEAN;
      Valid                        : BOOLEAN;
      
      RayOrdinal                   : INTEGER;
      
      C05AA_RAY_DATA_TEMP_STORAGE  : ZPE_ALL_RAY_DATA;

BEGIN

  Q290_REQUEST_RAY_ORDINAL (RayOrdinal, Valid);
  
  IF Valid THEN
    IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
      BEGIN
	CommandIOMemo.IOHistory.Lines.add ('');
	CommandIOMemo.IOHistory.Lines.add ('Ray ' +
            IntToStr (RayOrdinal) + ' is already specified.');
	Q970AB_OUTPUT_STRING :=
	    'Do you wish to re-specify this ray?  (Y or N)';
	Q970_REQUEST_PERMIT_TO_PROCEED;
	IF Q970AA_OK_TO_PROCEED THEN
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('RE-INITIALIZING RAY ' +
                IntToStr (RayOrdinal) + '...');
	    C05AA_RAY_DATA_TEMP_STORAGE :=
		ZNA_RAY [RayOrdinal].ZPA_ALL_RAY_DATA;
	    Y010_INITIALIZE_A_RAY (RayOrdinal);
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        CRAB_GET_RAY_TAIL_X_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAC_GET_RAY_TAIL_Y_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAD_GET_RAY_TAIL_Z_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAE_GET_RAY_HEAD_X_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAF_GET_RAY_HEAD_Y_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAG_GET_RAY_HEAD_Z_COORD, Valid);
	    IF Valid THEN
	      Q208_REQUEST_RAY_WAVELENGTH (RayOrdinal, Valid);
	    IF Valid THEN
	      Q209_REQUEST_INCIDENT_MEDIUM_INDEX (RayOrdinal, Valid);
	    IF Valid THEN
	      BEGIN
		ZNA_RAY [RayOrdinal].ZNB_SPECIFIED := TRUE;
		ZNA_RAY [RayOrdinal].ZNC_ACTIVE := TRUE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add ('RAY ' +
                    IntToStr (RayOrdinal) + ' RE-SPECIFIED.')
	      END
	    ELSE
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add ('RESTORING RAY ' +
                    IntToStr (RayOrdinal) + ' DATA...');
		ZNA_RAY [RayOrdinal].ZPA_ALL_RAY_DATA :=
		    C05AA_RAY_DATA_TEMP_STORAGE
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
	C05AD_TIME_TO_QUIT := FALSE;
	REPEAT
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('READY TO ENTER NEW RAY ' +
		IntToStr (RayOrdinal) + '...');
	    Y010_INITIALIZE_A_RAY (RayOrdinal);
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        CRAB_GET_RAY_TAIL_X_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAC_GET_RAY_TAIL_Y_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAD_GET_RAY_TAIL_Z_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAE_GET_RAY_HEAD_X_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAF_GET_RAY_HEAD_Y_COORD, Valid);
	    IF Valid THEN
	      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	          CRAG_GET_RAY_HEAD_Z_COORD, Valid);
	    IF Valid THEN
	      Q208_REQUEST_RAY_WAVELENGTH (RayOrdinal, Valid);
	    IF Valid THEN
	      Q209_REQUEST_INCIDENT_MEDIUM_INDEX (RayOrdinal, Valid);
	    IF Valid THEN
	      BEGIN
		ZNA_RAY [RayOrdinal].ZNB_SPECIFIED := TRUE;
		ZNA_RAY [RayOrdinal].ZNC_ACTIVE := TRUE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add ('RAY ' +
                    IntToStr (RayOrdinal) + ' SPECIFIED.')
	      END;
	    IF Valid THEN
	      BEGIN
		RayOrdinal := RayOrdinal + 1;
		IF (RayOrdinal <= CZAC_MAX_NUMBER_OF_RAYS) THEN
		  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
		    C05AD_TIME_TO_QUIT := TRUE
		  ELSE
		    BEGIN
		    END
		ELSE
		  C05AD_TIME_TO_QUIT := TRUE
	      END
	    ELSE
	      C05AD_TIME_TO_QUIT := TRUE
	  END
	UNTIL
	  C05AD_TIME_TO_QUIT
      END
      
END;




(**  C10_INSERT_NEW_RAY	 ******************************************************
******************************************************************************)


PROCEDURE C10_INSERT_NEW_RAY;

  VAR
      Valid       : BOOLEAN;
      
      RayOrdinal  : INTEGER;
      
      I	          : INTEGER;

BEGIN
  
  Q290_REQUEST_RAY_ORDINAL (RayOrdinal, Valid);

  IF Valid THEN
    BEGIN
      FOR I := CZAC_MAX_NUMBER_OF_RAYS DOWNTO (RayOrdinal + 1) DO
	ZNA_RAY [I] := ZNA_RAY [I - 1];
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('READY TO ENTER NEW RAY ' +
	  IntToStr (RayOrdinal) + '...');
      Y010_INITIALIZE_A_RAY (RayOrdinal);
      Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
          CRAB_GET_RAY_TAIL_X_COORD, Valid);
      IF Valid THEN
	Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	    CRAC_GET_RAY_TAIL_Y_COORD, Valid);
      IF Valid THEN
	Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	    CRAD_GET_RAY_TAIL_Z_COORD, Valid);
      IF Valid THEN
	Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	    CRAE_GET_RAY_HEAD_X_COORD, Valid);
      IF Valid THEN
	Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	    CRAF_GET_RAY_HEAD_Y_COORD, Valid);
      IF Valid THEN
	Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	    CRAG_GET_RAY_HEAD_Z_COORD, Valid);
      IF Valid THEN
	Q208_REQUEST_RAY_WAVELENGTH (RayOrdinal, Valid);
      IF Valid THEN
	Q209_REQUEST_INCIDENT_MEDIUM_INDEX (RayOrdinal, Valid);
      IF Valid THEN
	BEGIN
	  ZNA_RAY [RayOrdinal].ZNB_SPECIFIED := TRUE;
	  ZNA_RAY [RayOrdinal].ZNC_ACTIVE := TRUE
	END
    END

END;




(**  C15_DELETE_RAY  **********************************************************
******************************************************************************)


PROCEDURE C15_DELETE_RAY;

  VAR
      I					 : INTEGER;
      J					 : INTEGER;
      K					 : INTEGER;
      FirstRay                           : INTEGER;
      LastRay                            : INTEGER;
      
      C15AA_DELETE_THIS_RAY		 : ARRAY
	  [1..CZAC_MAX_NUMBER_OF_RAYS] OF BOOLEAN;
	  
      Valid                              : BOOLEAN;
      C15AB_AT_LEAST_ONE_RAY_TO_DELETE	 : BOOLEAN;

BEGIN

  FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
    C15AA_DELETE_THIS_RAY [I] := FALSE;
    
  C15AB_AT_LEAST_ONE_RAY_TO_DELETE := FALSE;

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE(S) OF RAYS TO BE DELETED.  <<');
      CommandIOMemo.IOHistory.Lines.add
          ('(RAYS WILL BE DELETED ONLY AFTER LIST IS COMPLETE.)')
    END;
    
  Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid);
  
  WHILE Valid DO
    BEGIN
      FOR I := FirstRay TO LastRay DO
	C15AA_DELETE_THIS_RAY [I] := TRUE;
      C15AB_AT_LEAST_ONE_RAY_TO_DELETE := TRUE;
      Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid)
    END;
    
  IF S01AC_NULL_RESPONSE_GIVEN
      AND C15AB_AT_LEAST_ONE_RAY_TO_DELETE THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('The following rays are scheduled for deletion...');
      FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
	IF C15AA_DELETE_THIS_RAY [I] THEN
	  CommandIOMemo.IOHistory.Lines.add ('     Ray ' +
              IntToStr (I) + '.');
      Q970AB_OUTPUT_STRING := 'Proceed with deletions?  (Y or N)';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      IF Q970AA_OK_TO_PROCEED THEN
	BEGIN
	  K := CZAC_MAX_NUMBER_OF_RAYS;
          I := 1;
          REPEAT
	    BEGIN
	      IF C15AA_DELETE_THIS_RAY [I] THEN
		BEGIN
		  FOR J := I TO (K - 1) DO
		    BEGIN
		      ZNA_RAY [J] := ZNA_RAY [J + 1];
		      C15AA_DELETE_THIS_RAY [J] :=
			  C15AA_DELETE_THIS_RAY [J + 1]
		    END;
		  ZNA_RAY [K].ZPA_ALL_RAY_DATA :=
		      ZQA_RAY_DATA_INITIALIZER;
		  C15AA_DELETE_THIS_RAY [K] := FALSE;
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




(**  C20_COPY_BLOCK_OF_RAYS  **************************************************
******************************************************************************)


PROCEDURE C20_COPY_BLOCK_OF_RAYS;

  VAR
      Valid                         : BOOLEAN;
      
      C20AD_RAYS_TO_COPY	    : INTEGER;
      I				    : INTEGER;
      J				    : INTEGER;
      FirstRay                      : INTEGER;
      LastRay                       : INTEGER;
      DestinationRay                : INTEGER;
      
      C20AA_RAY_DATA_TEMP_STORAGE   : ZPE_ALL_RAY_DATA;

BEGIN

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF RAYS TO COPY.  <<')
    END;
    
  Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid);

  IF Valid THEN
    Q292_REQUEST_DESTINATION_RAY (FirstRay, LastRay, DestinationRay, Valid);
    
  IF Valid THEN
    BEGIN
      IF DestinationRay > LastRay THEN
	BEGIN
	  FOR J := LastRay DOWNTO FirstRay DO
	    BEGIN
	      FOR I := CZAC_MAX_NUMBER_OF_RAYS DOWNTO
		  (DestinationRay + 1) DO
		ZNA_RAY [I] := ZNA_RAY [I - 1];
	      ZNA_RAY [DestinationRay] := ZNA_RAY [J]
	    END
	END
      ELSE
	BEGIN
	  C20AD_RAYS_TO_COPY :=
	      (LastRay - FirstRay) + 1;
	  FOR J := 1 TO C20AD_RAYS_TO_COPY DO
	    BEGIN
	      C20AA_RAY_DATA_TEMP_STORAGE :=
		  ZNA_RAY [LastRay].ZPA_ALL_RAY_DATA;
	      FOR I := CZAC_MAX_NUMBER_OF_RAYS DOWNTO
		  (DestinationRay + 1) DO
		ZNA_RAY [I] := ZNA_RAY [I - 1];
	      ZNA_RAY [DestinationRay].ZPA_ALL_RAY_DATA :=
		  C20AA_RAY_DATA_TEMP_STORAGE
	    END
	END
    END
    
END;




(**  C25_MOVE_BLOCK_OF_RAYS  **************************************************
******************************************************************************)


PROCEDURE C25_MOVE_BLOCK_OF_RAYS;

  VAR
      Valid                           : BOOLEAN;
      
      C25AD_RAYS_TO_MOVE	      : INTEGER;
      I				      : INTEGER;
      J				      : INTEGER;
      FirstRay                        : INTEGER;
      LastRay                         : INTEGER;
      DestinationRay                  : INTEGER;

      C25AA_RAY_DATA_TEMP_STORAGE     : ZPE_ALL_RAY_DATA;

BEGIN

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF RAYS TO MOVE.  <<')
    END;
    
  Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid);
  
  IF Valid THEN
    Q292_REQUEST_DESTINATION_RAY (FirstRay, LastRay, DestinationRay, Valid);
    
  IF Valid THEN
    BEGIN
      C25AD_RAYS_TO_MOVE :=
	  (LastRay - FirstRay) + 1;
      IF DestinationRay > LastRay THEN
	BEGIN
	  FOR J := (LastRay + 1) TO 
	      (DestinationRay - 1) DO
	    BEGIN
	      C25AA_RAY_DATA_TEMP_STORAGE :=
		  ZNA_RAY [J].ZPA_ALL_RAY_DATA;
	      FOR I := J DOWNTO (J - (C25AD_RAYS_TO_MOVE - 1)) DO
		ZNA_RAY [I] := ZNA_RAY [I - 1];
	      I := J - C25AD_RAYS_TO_MOVE;
	      ZNA_RAY [I].ZPA_ALL_RAY_DATA :=
		  C25AA_RAY_DATA_TEMP_STORAGE
	    END
	END
      ELSE
	BEGIN
	  FOR J := (FirstRay - 1) DOWNTO
	      DestinationRay DO
	    BEGIN
	      C25AA_RAY_DATA_TEMP_STORAGE :=
		  ZNA_RAY [J].ZPA_ALL_RAY_DATA;
	      FOR I := J TO (J + (C25AD_RAYS_TO_MOVE - 1)) DO
		ZNA_RAY [I] := ZNA_RAY [I + 1];
	      I := J + C25AD_RAYS_TO_MOVE;
	      ZNA_RAY [I].ZPA_ALL_RAY_DATA :=
		  C25AA_RAY_DATA_TEMP_STORAGE
	    END
	END
    END
	      
END;




(**  C30_WAKE_UP_RAY  *********************************************************
******************************************************************************)


PROCEDURE C30_WAKE_UP_RAY;

  VAR
      Valid        : BOOLEAN;
      
      I	           : INTEGER;
      FirstRay     : INTEGER;
      LastRay      : INTEGER;

BEGIN
  
  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF RAYS TO "WAKE UP".  <<')
    END;
    
  Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid);
  
  IF Valid THEN
    FOR I := FirstRay TO LastRay DO
      ZNA_RAY [I].ZNC_ACTIVE := TRUE

END;




(**  C35_PUT_RAY_TO_SLEEP  ****************************************************
******************************************************************************)


PROCEDURE C35_PUT_RAY_TO_SLEEP;

  VAR
      Valid       : BOOLEAN;
      
      I	          : INTEGER;
      FirstRay    : INTEGER;
      LastRay     : INTEGER;

BEGIN

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('>>  PLEASE LIST RANGE OF RAYS TO "PUT TO SLEEP".  <<')
    END;
    
  Q291_REQUEST_RAY_ORDINAL_RANGE (FirstRay, LastRay, Valid);
  
  IF Valid THEN
    FOR I := FirstRay TO LastRay DO
      ZNA_RAY [I].ZNC_ACTIVE := FALSE;

END;




(**  C01_SET_UP_RAY_DATA  *****************************************************
******************************************************************************)


BEGIN

  IF CommandString = CCAB_SPECIFY_NEW_RAY THEN
    C05_SPECIFY_NEW_RAY
  ELSE
  IF CommandString = CCAC_INSERT_NEW_RAY THEN
    C10_INSERT_NEW_RAY
  ELSE
  IF CommandString = CCAD_DELETE_BLOCK_OF_RAYS THEN
    C15_DELETE_RAY
  ELSE
  IF CommandString = CCAE_COPY_BLOCK_OF_RAYS THEN
    C20_COPY_BLOCK_OF_RAYS
  ELSE
  IF CommandString = CCAF_MOVE_BLOCK_OF_RAYS THEN
    C25_MOVE_BLOCK_OF_RAYS
  ELSE
  IF CommandString = CCAG_WAKE_BLOCK_OF_RAYS THEN
    C30_WAKE_UP_RAY
  ELSE
  IF CommandString = CCAH_SLEEP_BLOCK_OF_RAYS THEN
    C35_PUT_RAY_TO_SLEEP
    
END;




(**  LADSC  ******************************************************************
*****************************************************************************)


BEGIN

END.

