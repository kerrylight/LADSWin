UNIT LADSGlassCompUnit;

INTERFACE

  USES
      LADSGlassVar,
      LADSUtilUnit;

PROCEDURE U010_SEARCH_GLASS_CATALOG
    (U010AC_ADD_GLASS_TO_MINI_CATALOG      : BOOLEAN;
     VAR U010AA_GLASS_RECORD_FOUND,
     GradientIndexMaterialDetected,
     U010AD_GLASS_IN_MINI_CATALOG	   : BOOLEAN;
     VAR U010AB_GLASS_MINI_CAT_PTR	   : INTEGER);
PROCEDURE U015SearchOnLineMiniCatalog
    (VAR GlassRecordFound,
     GradientIndexMaterialDetected : BOOLEAN;
     VAR MiniCatPtr	           : INTEGER);
PROCEDURE U016CheckBulkGRINMatlAliases
    (Alias                                 : GlassType;
     VAR GRINMaterialAliasFound,
     ActualGRINMatlFound                   : BOOLEAN;
     VAR GRINMaterialName                  : GlassType);
PROCEDURE U050_CALCULATE_REFRACTIVE_INDEX
    (ComputeGradientOnly                   : BOOLEAN;
     BulkMatlPosition                      : PositionVector;
     Lambda                                : DOUBLE;
     GlassData                             : ZJA_GLASS_RECORD;
     VAR RefIndexOK                        : BOOLEAN;
     VAR RefractiveIndex                   : DOUBLE;
     VAR GradientOfIndex                   : Gradient);
PROCEDURE U060_READ_REFRACTIVE_INDEX
    (VAR U060AA_REFRACTIVE_INDEX	   : DOUBLE;
     VAR U060AB_NO_ERRORS,
         MediumIsGRIN	  	           : BOOLEAN);
PROCEDURE U070_FILL_IN_LAMBDAS_AND_INDICES
    (VAR U070AA_OUT_OF_ROOM_IN_MINI_CAT	   : BOOLEAN;
     VAR U070AB_NO_ERRORS		   : BOOLEAN);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSData,
       LADSCommandIOMemoUnit;
       
       
(**  U005_VERIFY_GLASS_CATALOG  ***********************************************
******************************************************************************)


PROCEDURE U005_VERIFY_GLASS_CATALOG;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  ASSIGN (ZAA_GLASS_CATALOG, CZAA_GLASS_CATALOG);
  {$I-};
  RESET (ZAA_GLASS_CATALOG);
  {$I+};
  
  SaveIOResult := IORESULT;
  
  IF SaveIOResult <> 0 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ATTENTION:  Glass catalog "' +
          CZAA_GLASS_CATALOG + '" not found.');
      CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
          IntToStr (SaveIOResult) + '.');
      CommandIOMemo.IOHistory.Lines.add ('Creating empty glass catalog "' +
	  CZAA_GLASS_CATALOG + '"...');
      {$I-}
      REWRITE (ZAA_GLASS_CATALOG);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('FATAL ERROR:  Glass catalog "' +
	      CZAA_GLASS_CATALOG + '" could not be created.');
	  CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
              IntToStr (SaveIOResult) + '.')
	END
      ELSE
	BEGIN
	  WRITELN (ZAA_GLASS_CATALOG, 'LAST');
	  WRITELN (ZAA_GLASS_CATALOG);
	  CLOSE (ZAA_GLASS_CATALOG)
	END
    END
  ELSE
    CLOSE (ZAA_GLASS_CATALOG)

END;




(**  U010_SEARCH_GLASS_CATALOG	***********************************************
******************************************************************************)


PROCEDURE U010_SEARCH_GLASS_CATALOG
    (U010AC_ADD_GLASS_TO_MINI_CATALOG      : BOOLEAN;
     VAR U010AA_GLASS_RECORD_FOUND,
     GradientIndexMaterialDetected,
     U010AD_GLASS_IN_MINI_CATALOG	   : BOOLEAN;
     VAR U010AB_GLASS_MINI_CAT_PTR	   : INTEGER);

  VAR
      U010AJ_NO_FILE		   : BOOLEAN;
      
      I				   : INTEGER;
      CODE                         : INTEGER;
      U010AI_INDEX_LIMIT	   : INTEGER;
      
      REAL_NUMBER                  : DOUBLE;
      
      U010AH_INPUT_STRING	   : STRING [255];
      
BEGIN

  U010AA_GLASS_RECORD_FOUND     := FALSE;
  GradientIndexMaterialDetected := FALSE;
  U010AB_GLASS_MINI_CAT_PTR     := 1;
  U010AD_GLASS_IN_MINI_CATALOG  := FALSE;
  
  WHILE (NOT U010AA_GLASS_RECORD_FOUND)
      AND (U010AB_GLASS_MINI_CAT_PTR <= ABD_GLASS_HIGH_PTR) DO
    BEGIN
      IF ZKA_MINI_GLASS_CATALOG.
	  ZKB_GLASS_DATA [U010AB_GLASS_MINI_CAT_PTR].ZJC_GLASS_NAME =
	  AKJ_SPECIFIED_GLASS_NAME THEN
	BEGIN
	  S01BH_REWIND_FILE_BEFORE_READ := FALSE;
	  U010AA_GLASS_RECORD_FOUND := TRUE;
	  U010AD_GLASS_IN_MINI_CATALOG := TRUE;
	  ZKZ_GLASS_DATA_IO_AREA := ZKA_MINI_GLASS_CATALOG.
	      ZKB_GLASS_DATA [U010AB_GLASS_MINI_CAT_PTR];
          IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = GRINGLC THEN
            GradientIndexMaterialDetected := TRUE
	END
      ELSE
	U010AB_GLASS_MINI_CAT_PTR := U010AB_GLASS_MINI_CAT_PTR + 1
    END;
  
  IF NOT U010AA_GLASS_RECORD_FOUND THEN
    BEGIN
      S01AO_USE_ALTERNATE_INPUT_FILE := TRUE;
      S01AG_ALTERNATE_INPUT_FILE_NAME := CZAA_GLASS_CATALOG;
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('Glass "' +
          AKJ_SPECIFIED_GLASS_NAME +
          '" not on-line.  Searching glass catalog...');
      IF S01BH_REWIND_FILE_BEFORE_READ THEN
	S01AQ_FORCE_END_OF_FILE := FALSE;
      U010AJ_NO_FILE := FALSE;
      REPEAT
	BEGIN
	  S01_PROCESS_REQUEST;
	  IF S01AO_USE_ALTERNATE_INPUT_FILE
	      AND (S01AG_ALTERNATE_INPUT_FILE_NAME = CZAA_GLASS_CATALOG) THEN
	    IF AKJ_SPECIFIED_GLASS_NAME =
		S01AF_BLANKS_STRIPPED_RESPONSE_UC THEN
	      BEGIN
		U010AA_GLASS_RECORD_FOUND := TRUE;
		ZKZ_GLASS_DATA_IO_AREA.ZJC_GLASS_NAME :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC;
                ZKZ_GLASS_DATA_IO_AREA.GlassNameMixedCase :=
                    S01AM_BLANKS_STRIPPED_RESPONSE;
		S01_PROCESS_REQUEST;
		ZKZ_GLASS_DATA_IO_AREA.ZJD_MANUFACTURER_CODE := '       ';
		ZKZ_GLASS_DATA_IO_AREA.ZJD_MANUFACTURER_CODE [1] :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC [1];
		FOR I := 2 TO 7 DO
		  IF I <= LENGTH (S01AM_BLANKS_STRIPPED_RESPONSE) THEN
		    ZKZ_GLASS_DATA_IO_AREA.ZJD_MANUFACTURER_CODE [I] :=
			S01AM_BLANKS_STRIPPED_RESPONSE [I];
		S01_PROCESS_REQUEST;
                IF S01AF_BLANKS_STRIPPED_RESPONSE_UC = 'GLC' THEN
                  BEGIN
                    ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA :=
                        GRINGLC;
                    GradientIndexMaterialDetected := TRUE
                  END
                ELSE
                IF S01AF_BLANKS_STRIPPED_RESPONSE_UC [1] = 'S' THEN
                  ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA := Schott
                ELSE
                IF S01AF_BLANKS_STRIPPED_RESPONSE_UC [1] = 'G' THEN
                  ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA := Hoya
                ELSE
                IF S01AF_BLANKS_STRIPPED_RESPONSE_UC [1] = 'C' THEN
                  ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA := Crystal
                ELSE
                  ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA := Nope;
		S01_PROCESS_REQUEST;
		ZKZ_GLASS_DATA_IO_AREA.ZJF_PREFERENCE_CODE := '       ';
		ZKZ_GLASS_DATA_IO_AREA.ZJF_PREFERENCE_CODE [1] :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC [1];
		FOR I := 2 TO 7 DO
		  IF I <= LENGTH (S01AM_BLANKS_STRIPPED_RESPONSE) THEN
		    ZKZ_GLASS_DATA_IO_AREA.ZJF_PREFERENCE_CODE [I] :=
			S01AM_BLANKS_STRIPPED_RESPONSE [I];
		S01_PROCESS_REQUEST;
		ZKZ_GLASS_DATA_IO_AREA.ZJG_INDEX_TYPE := '       ';
		ZKZ_GLASS_DATA_IO_AREA.ZJG_INDEX_TYPE [1] :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC [1];
		FOR I := 2 TO 7 DO
		  IF I <= LENGTH (S01AM_BLANKS_STRIPPED_RESPONSE) THEN
		    ZKZ_GLASS_DATA_IO_AREA.ZJG_INDEX_TYPE [I] :=
			S01AM_BLANKS_STRIPPED_RESPONSE [I];
		S01_PROCESS_REQUEST;
		VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
		ZKZ_GLASS_DATA_IO_AREA.ZJH_SHORT_WAVE_CUTOFF :=
		    REAL_NUMBER;
		S01_PROCESS_REQUEST;
		VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
		ZKZ_GLASS_DATA_IO_AREA.ZJI_LONG_WAVE_CUTOFF :=
		     REAL_NUMBER;
		IF ZKZ_GLASS_DATA_IO_AREA.
                    ZJB_DISPERSION_FORMULA = Schott THEN
		  U010AI_INDEX_LIMIT := 6
		ELSE
                IF ZKZ_GLASS_DATA_IO_AREA.
                    ZJB_DISPERSION_FORMULA = Hoya THEN
		  U010AI_INDEX_LIMIT := 6
		ELSE
                IF ZKZ_GLASS_DATA_IO_AREA.
                    ZJB_DISPERSION_FORMULA = Crystal THEN
		  U010AI_INDEX_LIMIT := 10
		ELSE
                IF ZKZ_GLASS_DATA_IO_AREA.
                    ZJB_DISPERSION_FORMULA = GRINGLC THEN
		  U010AI_INDEX_LIMIT := 12
		ELSE
		  U010AI_INDEX_LIMIT := CZBF_MAX_GLASS_DISPERSION_CONSTS;
		FOR I := 1 TO U010AI_INDEX_LIMIT DO
		  BEGIN
		    S01_PROCESS_REQUEST;
		    VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER,
		        CODE);
		    ZKZ_GLASS_DATA_IO_AREA.ZJJ_DISPERSION_CONSTANT [I] :=
			REAL_NUMBER
		  END;
		S01AP_FORCE_END_OF_LINE := TRUE
	      END
	    ELSE
	      S01AP_FORCE_END_OF_LINE := TRUE
	  ELSE
	    U010AJ_NO_FILE := TRUE
	END
      UNTIL
	U010AA_GLASS_RECORD_FOUND
	OR U010AJ_NO_FILE
	OR (S01AF_BLANKS_STRIPPED_RESPONSE_UC = CZBI_LAST_GLASS);
      IF S01AO_USE_ALTERNATE_INPUT_FILE
	  AND (S01AG_ALTERNATE_INPUT_FILE_NAME = CZAA_GLASS_CATALOG) THEN
	S01AQ_FORCE_END_OF_FILE := TRUE;
      IF U010AA_GLASS_RECORD_FOUND THEN
	IF U010AC_ADD_GLASS_TO_MINI_CATALOG THEN
	  BEGIN
	    ABD_GLASS_HIGH_PTR := ABD_GLASS_HIGH_PTR + 1;
	    IF ABD_GLASS_HIGH_PTR <= CZBA_MAX_GLASSES_IN_MINI_CAT THEN
	      BEGIN
		U010AB_GLASS_MINI_CAT_PTR := ABD_GLASS_HIGH_PTR;
		ZKA_MINI_GLASS_CATALOG.
		    ZKB_GLASS_DATA [ABD_GLASS_HIGH_PTR] :=
		    ZKZ_GLASS_DATA_IO_AREA;
		U010AD_GLASS_IN_MINI_CATALOG := TRUE
	      END
	    ELSE
	      BEGIN
		ABD_GLASS_HIGH_PTR := CZBA_MAX_GLASSES_IN_MINI_CAT;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('ATTENTION:  No room to store glass "' +
		    AKJ_SPECIFIED_GLASS_NAME + '" on-line.')
	      END
	  END
	ELSE
	  BEGIN
	  END
      ELSE
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ATTENTION:  Glass "' +
              AKJ_SPECIFIED_GLASS_NAME + '" not present in glass catalog.')
	END
    END
    
END;




(**  U015SearchOnLineMiniCatalog  ********************************************
******************************************************************************)


PROCEDURE U015SearchOnLineMiniCatalog
    (VAR GlassRecordFound,
     GradientIndexMaterialDetected : BOOLEAN;
     VAR MiniCatPtr	           : INTEGER);

BEGIN

  GlassRecordFound := FALSE;
  GradientIndexMaterialDetected := FALSE;
  MiniCatPtr := 1;

  WHILE (NOT GlassRecordFound)
      AND (MiniCatPtr <= ABD_GLASS_HIGH_PTR) DO
    BEGIN
      IF ZKA_MINI_GLASS_CATALOG.
	  ZKB_GLASS_DATA [MiniCatPtr].ZJC_GLASS_NAME =
	  AKJ_SPECIFIED_GLASS_NAME THEN
	BEGIN
	  GlassRecordFound := TRUE;
	  ZKZ_GLASS_DATA_IO_AREA := ZKA_MINI_GLASS_CATALOG.
	      ZKB_GLASS_DATA [MiniCatPtr];
          IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = GRINGLC THEN
            GradientIndexMaterialDetected := TRUE
	END
      ELSE
	MiniCatPtr := MiniCatPtr + 1
    END

END;




(**  U016CheckBulkGRINMatlAliases  ****************************************
**************************************************************************)

PROCEDURE U016CheckBulkGRINMatlAliases
    (Alias                     : GlassType;
    VAR GRINMaterialAliasFound,
    ActualGRINMatlFound        : BOOLEAN;
    VAR GRINMaterialName       : GlassType);

  VAR
      I  : INTEGER;

BEGIN

  GRINMaterialAliasFound := FALSE;
  ActualGRINMatlFound := FALSE;
  GRINMaterialName := '';

  FOR I := 1 TO MaxBulkGRINMaterials DO
    BEGIN
      IF Pos (Alias, GRINMaterial [I].GRINMatlAlias) > 0 THEN
        BEGIN
          GRINMaterialAliasFound := TRUE;
          (* Verify that aliased GRIN material is found in the on-line
             mini glass catalog. *)
	  AKJ_SPECIFIED_GLASS_NAME := GRINMaterial [I].GRINMatlName;
          U015SearchOnLineMiniCatalog
              (AKF_GLASS_RECORD_FOUND,
               FoundGradientIndexMaterial,
               ABC_GLASS_MINI_CAT_PTR);
	  IF AKF_GLASS_RECORD_FOUND THEN
            BEGIN
              ActualGRINMatlFound := TRUE;
              GRINMaterialName := GRINMaterial [I].GRINMatlName
            END
        END
    END

END;




(**  U050_CALCULATE_REFRACTIVE_INDEX  *****************************************
******************************************************************************)


PROCEDURE U050_CALCULATE_REFRACTIVE_INDEX
    (ComputeGradientOnly : BOOLEAN;
     BulkMatlPosition    : PositionVector;
     Lambda              : DOUBLE;
     GlassData           : ZJA_GLASS_RECORD;
     VAR RefIndexOK      : BOOLEAN;
     VAR RefractiveIndex : DOUBLE;
     VAR GradientOfIndex : Gradient);

  VAR
      I		       : INTEGER;
      
      MINIMUM_LAMBDA   : DOUBLE;
      MAXIMUM_LAMBDA   : DOUBLE;
      A  : ARRAY [1..CZBF_MAX_GLASS_DISPERSION_CONSTS] OF DOUBLE;

BEGIN

  MINIMUM_LAMBDA := GlassData.ZJH_SHORT_WAVE_CUTOFF;

  MAXIMUM_LAMBDA := GlassData.ZJI_LONG_WAVE_CUTOFF;

  IF ComputeGradientOnly THEN
    BEGIN
      IF GlassData.ZJB_DISPERSION_FORMULA = GRINGLC THEN
        BEGIN
          (* This code will NOT work unless a call has been previously
             made to compute the refractive index, Factor1, Factor2,
             Factor3, etc. *)
          GradientOfIndex.Dx := RefractiveIndex *
              ((2.0 * BulkMatlPosition.Rx * Factor2) +
              (4.0 * BulkMatlPosition.Rx * RSquared * Factor3));
          GradientOfIndex.Dy := RefractiveIndex *
              ((2.0 * BulkMatlPosition.Ry * Factor2) +
              (4.0 * BulkMatlPosition.Ry * RSquared * Factor3));
          GradientOfIndex.Dz := 0.0
        END
    END
  ELSE
  IF (Lambda >= MINIMUM_LAMBDA)
      AND (Lambda <= MAXIMUM_LAMBDA) THEN
    BEGIN
      FOR I := 1 TO CZBF_MAX_GLASS_DISPERSION_CONSTS DO
	A [I] := GlassData.ZJJ_DISPERSION_CONSTANT [I];
      IF GlassData.ZJB_DISPERSION_FORMULA = Hoya THEN
	RefractiveIndex :=
	    SQRT (A [1] + A [2] * SQR (Lambda) +
	    A [3] / (SQR (Lambda)) + A [4] / (SQR (SQR (Lambda))) + A [5] /
	    (SQR (SQR (Lambda)) * SQR (Lambda)) + A [6] /
	    (SQR (SQR (SQR (Lambda)))))
      ELSE
      IF GlassData.ZJB_DISPERSION_FORMULA = Schott THEN
        RefractiveIndex :=
            SQRT (1.0 + (A [1] * SQR (Lambda) / (SQR (Lambda) - A [4]))
            + (A [2] * SQR (Lambda) / (SQR (Lambda) - A [5]))
            + (A [3] * SQR (Lambda) / (SQR (Lambda) - A [6])))
      ELSE
      IF GlassData.ZJB_DISPERSION_FORMULA = Crystal THEN
	RefractiveIndex :=
	    SQRT (A [1] * SQR (SQR (SQR (Lambda))) +
	    A [2] * SQR (SQR (Lambda)) * SQR (Lambda) +
	    A [3] * SQR (SQR (Lambda)) +
	    A [4] * SQR (Lambda) +
	    A [5] +
	    A [6] / (SQR (Lambda)) +
	    A [7] / (SQR (SQR (Lambda))) +
	    A [8] / (SQR (SQR (Lambda)) * SQR (Lambda)) +
	    A [9] / (SQR (SQR (SQR (Lambda)))) +
	    A [10] / (SQR (SQR (SQR (Lambda))) * SQR (Lambda)))
      ELSE
      IF GlassData.ZJB_DISPERSION_FORMULA = GRINGLC THEN
        BEGIN
          LambdaSquared := Sqr (Lambda * 1000.0); (* i.e., in nm. *)
          Lambda4th := Sqr (LambdaSquared);
          RSquared := Sqr (BulkMatlPosition.Rx) + Sqr (BulkMatlPosition.Ry);
          R4th := Sqr (RSquared);
          Factor1 :=
              A [1] +
              (A [2] * LambdaSquared) +
              (A [3] / LambdaSquared) +
              (A [4] / Lambda4th);
          Factor2 :=
              A [5] +
              (A [6] * LambdaSquared) +
              (A [7] / LambdaSquared) +
              (A [8] / Lambda4th);
          Factor3 :=
              A [9] +
              (A [10] * LambdaSquared) +
              (A [11] / LambdaSquared) +
              (A [12] / Lambda4th);
          RefractiveIndex :=
              Factor1 +
              RSquared * Factor2 +
              R4th * Factor3;
          (* Calculate the gradient of the refractive index field
             at (Rx,Ry,Rz). *)
          GradientOfIndex.Dx :=
              RefractiveIndex * ((2.0 * BulkMatlPosition.Rx * Factor2) +
              (4.0 * BulkMatlPosition.Rx * RSquared * Factor3));
          GradientOfIndex.Dy :=
              RefractiveIndex * ((2.0 * BulkMatlPosition.Ry * Factor2) +
              (4.0 * BulkMatlPosition.Ry * RSquared * Factor3));
          GradientOfIndex.Dz := 0.0
        END;
      RefIndexOK := TRUE
    END
  ELSE
    BEGIN
      AKP_REFRACTIVE_INDEX_CALCULATED := FALSE;
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('Specified wavelength of ' +
          FloatToStrF (LAMBDA, ffFixed, 9, 6) + ' microns is out');
      CommandIOMemo.IOHistory.Lines.add ('of the valid range ' +
          FloatToStrF (MINIMUM_LAMBDA, ffFixed, 9, 6) + ' microns thru');
      CommandIOMemo.IOHistory.Lines.add
          (FloatToStrF (MAXIMUM_LAMBDA, ffFixed, 9, 6) +
          ' microns for use of the dispersion equation.')
    END

END;




(**  U060_READ_REFRACTIVE_INDEX	 **********************************************

  This procedure is only executed from within the F52_REFLECT_OR_REFRACT
  procedure within the T(race command, in order to get the refractive index.
  Searching is limited to the on-line mini glass catalog, and GRIN alias
  table.

******************************************************************************)


PROCEDURE U060_READ_REFRACTIVE_INDEX
    (VAR U060AA_REFRACTIVE_INDEX	   : DOUBLE;
     VAR U060AB_NO_ERRORS,
         MediumIsGRIN		           : BOOLEAN);

  VAR
      FOUND_LAMBDA                   : BOOLEAN;
      AKF_GLASS_RECORD_FOUND         : BOOLEAN;
      ComputeGradientOnly            : BOOLEAN;
      AliasDefined                   : BOOLEAN;
      GRINMatlInOnlineCatalog        : BOOLEAN;

      LAMBDA_PTR                     : INTEGER;
      ABC_GLASS_MINI_CAT_PTR         : INTEGER;

      RefIndexGradient               : Gradient;

      Alias                          : GlassType;
      ActualGRINMaterialName         : GlassType;

BEGIN

  MediumIsGRIN := FALSE;
  ComputeGradientOnly := FALSE;
  U060AB_NO_ERRORS := TRUE;

  U015SearchOnLineMiniCatalog
     (AKF_GLASS_RECORD_FOUND,
      MediumIsGRIN,
      ABC_GLASS_MINI_CAT_PTR);

  IF AKF_GLASS_RECORD_FOUND THEN
    BEGIN
      (* Since this is not a GRIN material, it should be possible to
         do a table look-up based on wavelength. *)
      LAMBDA_PTR := 1;
      FOUND_LAMBDA := FALSE;
      WHILE (NOT FOUND_LAMBDA)
	  AND (LAMBDA_PTR <= AKG_LAMBDA_HIGH_PTR) DO
        BEGIN
	  IF Abs (ZKA_MINI_GLASS_CATALOG.
	      ZKB_GLASS_DATA [ABC_GLASS_MINI_CAT_PTR].
	      ZJK_WAVELENGTH_AND_INDEX [LAMBDA_PTR].
	      ZJL_WAVELENGTH - AKO_SPECIFIED_WAVELENGTH) < 1.0E-7 THEN
	    BEGIN
	      U060AA_REFRACTIVE_INDEX := ZKA_MINI_GLASS_CATALOG.
		  ZKB_GLASS_DATA [ABC_GLASS_MINI_CAT_PTR].
		  ZJK_WAVELENGTH_AND_INDEX [LAMBDA_PTR].
		  ZJM_INDEX;
	      FOUND_LAMBDA := TRUE
	    END
	  ELSE
	    LAMBDA_PTR := LAMBDA_PTR + 1
        END;
      IF FOUND_LAMBDA THEN
      ELSE
        BEGIN
          U060AB_NO_ERRORS := FALSE;
          CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add ('Wavelength not found, at U060.1')
        END
    END
  ELSE
    (* This condition can only occur because the glass type specified by
       the surface is an alias for a gradient index material.  Therefore,
       check the alias table. *)
    BEGIN
      Alias := AKJ_SPECIFIED_GLASS_NAME;
      U016CheckBulkGRINMatlAliases
          (Alias,
           AliasDefined,
           MediumIsGRIN,
           ActualGRINMaterialName);
      (* The refractive index must always be calculated for a GRIN
         material, because the index is a function of position.  Thus,
         it is not possible to do a quick table look-up based on
         wavelength. *)
      U050_CALCULATE_REFRACTIVE_INDEX
         (ComputeGradientOnly,
          BulkMatlPosition,
          AKO_SPECIFIED_WAVELENGTH,
          ZKZ_GLASS_DATA_IO_AREA,
          AKP_REFRACTIVE_INDEX_CALCULATED,
          AKQ_CALCULATED_REFRACTIVE_INDEX,
          RefIndexGradient);
      IF AKP_REFRACTIVE_INDEX_CALCULATED THEN
	U060AA_REFRACTIVE_INDEX := AKQ_CALCULATED_REFRACTIVE_INDEX
      ELSE
	U060AB_NO_ERRORS := FALSE
    END

END;




(**  U070_FILL_IN_LAMBDAS_AND_INDICES  ****************************************

  This code is only executed at ray-trace time, and is used to make sure that
  all glasses referred to in the surface specifications are "on-line" in the
  mini glass catalog.  This will greatly speed-up ray tracing.

******************************************************************************)


PROCEDURE U070_FILL_IN_LAMBDAS_AND_INDICES
    (VAR U070AA_OUT_OF_ROOM_IN_MINI_CAT	   : BOOLEAN;
     VAR U070AB_NO_ERRORS		   : BOOLEAN);

  VAR
      LAMBDA_FOUND                : BOOLEAN;
      AliasDefined                : BOOLEAN;
      GRINMatlInOnlineCatalog     : BOOLEAN;

      I		                  : INTEGER;
      J                           : INTEGER;
      LAMBDA_PTR                  : INTEGER;
      SurfaceOrdinal              : INTEGER;
      RayOrdinal                  : INTEGER;

      Alias                       : GlassType;
      ActualGRINMaterialName      : GlassType;


BEGIN

  U070AA_OUT_OF_ROOM_IN_MINI_CAT := FALSE;

  (*  MAKE SURE THE GLASSES SPECIFIED IN EACH SPECIFIED SURFACE HAVE BEEN
      ENTERED INTO THE MINI GLASS CATALOG  *)

  FOR SurfaceOrdinal := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
      FOR I := 1 TO 2 DO
	IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [I] THEN
	  BEGIN
	    AKJ_SPECIFIED_GLASS_NAME := ZBA_SURFACE [SurfaceOrdinal].
		ZCG_INDEX_OR_GLASS [I].ZCH_GLASS_NAME;
	    S01BH_REWIND_FILE_BEFORE_READ := TRUE;
	    AKE_ADD_GLASS_TO_MINI_CATALOG := TRUE;
	    U010_SEARCH_GLASS_CATALOG (AKE_ADD_GLASS_TO_MINI_CATALOG,
	        AKF_GLASS_RECORD_FOUND,
                FoundGradientIndexMaterial,
		ABE_GLASS_IN_MINI_CATALOG,
		ABC_GLASS_MINI_CAT_PTR);
	    IF AKF_GLASS_RECORD_FOUND THEN
              BEGIN
                IF FoundGradientIndexMaterial THEN
                  (* Error.  Is is not permissible for surfaces to specify
                     GRIN materials, except through an alias.  This
                     BOOLEAN condition should never occur, since there is
                     checking at surface data entry time to make sure that
                     GRIN materials are not entered. *)
                  BEGIN
	            U070AB_NO_ERRORS := FALSE;
                    AKF_GLASS_RECORD_FOUND := FALSE;
                    IF ABE_GLASS_IN_MINI_CATALOG THEN
                      BEGIN
                        ABE_GLASS_IN_MINI_CATALOG := FALSE;
	                ABD_GLASS_HIGH_PTR := ABD_GLASS_HIGH_PTR - 1;
                        ABC_GLASS_MINI_CAT_PTR := ABD_GLASS_HIGH_PTR
                      END
                  END
                ELSE
	        IF ABE_GLASS_IN_MINI_CATALOG THEN
		  BEGIN
		  END
	        ELSE
		  U070AA_OUT_OF_ROOM_IN_MINI_CAT := TRUE
              END
	    ELSE
              (* Glass not found on-line in mini catalog.  Is it an alias
                 for a GRIN material? *)
              BEGIN
                Alias := AKJ_SPECIFIED_GLASS_NAME;
                U016CheckBulkGRINMatlAliases
                    (Alias,
                     AliasDefined,
                     GRINMatlInOnlineCatalog,
                     ActualGRINMaterialName);
                IF AliasDefined THEN
                  (* i.e., alias name entry found in alias table. *)
                  IF GRINMatlInOnlineCatalog THEN
                    AKF_GLASS_RECORD_FOUND := TRUE
                  ELSE
                    (* GRIN alias found, but actual glass name not in mini
                       catalog.  This should never happen. *)
	            U070AB_NO_ERRORS := FALSE
                ELSE
                  (* Evidently this was not a GRIN material. *)
	          U070AB_NO_ERRORS := FALSE
              END
	  END;

  (*  STORE ALL WAVELENGTHS DEFINED IN THE RAY RECORDS IN
      ZKZ_GLASS_DATA_IO_AREA.  ZKZ_GLASS_DATA_IO_AREA IS USED TO TEMPORARILY
      STORE ALL SPECIFIED WAVELENGTHS.	*)
      
  IF U070AB_NO_ERRORS THEN
    BEGIN
      AKG_LAMBDA_HIGH_PTR := 0;
      FOR RayOrdinal := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
	BEGIN
	  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
	    BEGIN
	      AKO_SPECIFIED_WAVELENGTH := ZNA_RAY [RayOrdinal].
		  ZNJ_WAVELENGTH;
	      LAMBDA_PTR := 1;
	      LAMBDA_FOUND := FALSE;
	      WHILE (NOT LAMBDA_FOUND)
		  AND (LAMBDA_PTR <= AKG_LAMBDA_HIGH_PTR) DO
		IF ZKZ_GLASS_DATA_IO_AREA.
		    ZJK_WAVELENGTH_AND_INDEX [LAMBDA_PTR].ZJL_WAVELENGTH =
		    AKO_SPECIFIED_WAVELENGTH THEN
		  LAMBDA_FOUND := TRUE
		ELSE
		  LAMBDA_PTR := LAMBDA_PTR + 1;
	      IF NOT LAMBDA_FOUND THEN
		BEGIN
		  AKG_LAMBDA_HIGH_PTR := AKG_LAMBDA_HIGH_PTR + 1;
		  IF AKG_LAMBDA_HIGH_PTR > CZBH_MAX_LAMBDAS_IN_MINI_CAT THEN
		    BEGIN
		      U070AA_OUT_OF_ROOM_IN_MINI_CAT := TRUE;
		      AKG_LAMBDA_HIGH_PTR := CZBH_MAX_LAMBDAS_IN_MINI_CAT
		    END
		  ELSE
		    ZKZ_GLASS_DATA_IO_AREA.
			ZJK_WAVELENGTH_AND_INDEX [AKG_LAMBDA_HIGH_PTR].
			ZJL_WAVELENGTH := AKO_SPECIFIED_WAVELENGTH
		END
	    END
	END
    END;
  
  (*  PUT WAVELENGTH INFORMATION IN MINI GLASS CATALOG	*)
  
  IF U070AB_NO_ERRORS THEN
    FOR I := 1 TO ABD_GLASS_HIGH_PTR DO
      FOR J := 1 TO AKG_LAMBDA_HIGH_PTR DO
        ZKA_MINI_GLASS_CATALOG.ZKB_GLASS_DATA [I].
            ZJK_WAVELENGTH_AND_INDEX [J].ZJL_WAVELENGTH :=
            ZKZ_GLASS_DATA_IO_AREA.ZJK_WAVELENGTH_AND_INDEX [J].
            ZJL_WAVELENGTH;

  (*  PUT REFRACTIVE INDEX INFORMATION IN MINI GLASS CATALOG  *)

  IF U070AB_NO_ERRORS THEN
    FOR I := 1 TO ABD_GLASS_HIGH_PTR DO
      FOR J := 1 TO AKG_LAMBDA_HIGH_PTR DO
	BEGIN
	  ZKZ_GLASS_DATA_IO_AREA :=
	      ZKA_MINI_GLASS_CATALOG.ZKB_GLASS_DATA [I];
	  AKO_SPECIFIED_WAVELENGTH :=
	      ZKZ_GLASS_DATA_IO_AREA.ZJK_WAVELENGTH_AND_INDEX [J].
	      ZJL_WAVELENGTH;
          ComputeGradientOnly := FALSE;
	  U050_CALCULATE_REFRACTIVE_INDEX
             (ComputeGradientOnly,
              BulkMatlPosition,
              AKO_SPECIFIED_WAVELENGTH,
              ZKZ_GLASS_DATA_IO_AREA,
              AKP_REFRACTIVE_INDEX_CALCULATED,
              AKQ_CALCULATED_REFRACTIVE_INDEX,
              RefIndexGradient);
	  IF AKP_REFRACTIVE_INDEX_CALCULATED THEN
	    ZKA_MINI_GLASS_CATALOG.ZKB_GLASS_DATA [I].
		ZJK_WAVELENGTH_AND_INDEX [J].ZJM_INDEX :=
		AKQ_CALCULATED_REFRACTIVE_INDEX
	  ELSE
            BEGIN
              (* This situation forces initialization of mini glass cat. *)
	      U070AB_NO_ERRORS := FALSE;
              ABD_GLASS_HIGH_PTR := 0;
              AKG_LAMBDA_HIGH_PTR := 0
            END
	END

END;




(**  LADSGlassCompUnit  ******************************************************
*****************************************************************************)


BEGIN

END.

