UNIT LADSqCPCUnit;

INTERFACE

  PROCEDURE DesignCPC (SurfaceOrdinal : INTEGER);
  PROCEDURE CPCComputations (SurfaceOrdinal : INTEGER);
  PROCEDURE GetRAndZForCPC (SurfaceOrdinal : INTEGER;
                            Phi            : DOUBLE;
                            VAR rCPC, zCPC : DOUBLE);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit,
       LADSData;
  
  CONST
      AngleSteps                       = 20;
      MaxExitAngleForHybridCPCDeg      = 89.999999;
  
  VAR
      MaxEntranceAngleOK               : BOOLEAN;
      MaxExitAngleOK                   : BOOLEAN;
      RefractiveIndexOK                : BOOLEAN;
      ExitApertureRadiusOK             : BOOLEAN;
      CPCDefined                       : BOOLEAN;

      SurfaceProfileFile               : TEXT;

      Code                             : INTEGER;
      
      RealNumber                       : DOUBLE;
      ComputedOverallLength            : DOUBLE;
      ComputedConeSectionLength        : DOUBLE;
      MinIncidentAngleInCPCRad         : DOUBLE;
      MinIncidentAngleForTIRRad        : DOUBLE;
      AngleDifferenceForTIRDeg         : DOUBLE;
      ExitAngleRad                     : DOUBLE;
      MaxRadiusOfConeSection           : DOUBLE;
      AreaConcentrationRatio           : DOUBLE;
      FocalLengthX2                    : DOUBLE;
      FocusToConeDistance              : DOUBLE;
      MaxPhiForParabolaSectionRad      : DOUBLE;


(**  Q01RequestMaxEntranceAngleInAirDeg  ************************************
****************************************************************************)

PROCEDURE Q01RequestMaxEntranceAngleInAirDeg (SurfaceOrdinal : INTEGER);

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'Enter maximum external entrance angle:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add
              ('Enter maximum external angle of incidence at the');
          CommandIOMemo.IOHistory.Lines.add
              ('entrance aperture of the CPC, in degrees.');
	  CommandIOMemo.IOHistory.Lines.add
              ('  (Present value is ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
              SurfaceShapeParameters.MaxEntranceAngleInAirDeg, ffFixed, 10, 4) +
              '.)');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF S01AB_USER_IS_DONE THEN
	BEGIN
          IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              MaxEntranceAngleInAirDeg > 0.0)
              AND (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              MaxEntranceAngleInAirDeg < 90.0) THEN
	    MaxEntranceAngleOK := TRUE
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpCPCDesignParameters
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, Code);
	  IF Code = 0 THEN
	    IF (RealNumber > 0.0)
	        AND (RealNumber < 90.0) THEN
	      BEGIN
	        MaxEntranceAngleOK := TRUE;
	        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                    MaxEntranceAngleInAirDeg := RealNumber
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    MaxEntranceAngleOK
    OR S01AB_USER_IS_DONE

END;




(**  Q05RequestExitAngleDeg  ************************************************
****************************************************************************)

PROCEDURE Q05RequestExitAngleDeg (SurfaceOrdinal : INTEGER);

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'Enter maximum internal exit angle:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add
              ('Enter maximum internal angle of incidence at the exit');
          CommandIOMemo.IOHistory.Lines.add
              ('aperture of the CPC, in degrees.');
	  CommandIOMemo.IOHistory.Lines.add ('  (Present value is ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
              SurfaceShapeParameters.ExitAngleDeg, ffFixed, 10, 4) + '.)');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF S01AB_USER_IS_DONE THEN
	BEGIN
          IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              ExitAngleDeg > 0.0)
              AND (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              ExitAngleDeg <= 90.0) THEN
	    MaxExitAngleOK := TRUE
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpCPCDesignParameters
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, Code);
	  IF Code = 0 THEN
	    IF (RealNumber > 0.0)
	        AND (RealNumber <= 90.0) THEN
	      BEGIN
	        MaxExitAngleOK := TRUE;
	        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                    ExitAngleDeg := RealNumber
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    MaxExitAngleOK
    OR S01AB_USER_IS_DONE

END;



(**  Q10RequestCPCRefractiveIndex  ******************************************
****************************************************************************)

PROCEDURE Q10RequestCPCRefractiveIndex (SurfaceOrdinal : INTEGER);

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'Enter refractive index for CPC (= 1.0 for hollow CPC):';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('Enter refractive index for CPC (= 1.0 for hollow CPC).');
	  CommandIOMemo.IOHistory.Lines.add ('  (Present value is ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
              SurfaceShapeParameters.CPCRefractiveIndex, ffFixed, 10, 6) +
              '.)');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF S01AB_USER_IS_DONE THEN
	BEGIN
          IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              CPCRefractiveIndex >= 1.0)
              AND (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              CPCRefractiveIndex <= 5.0) THEN
	    RefractiveIndexOK := TRUE
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpCPCDesignParameters
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, Code);
	  IF Code = 0 THEN
	    IF (RealNumber >= 1.0)
	        AND (RealNumber <= 5.0) THEN
	      BEGIN
	        RefractiveIndexOK := TRUE;
	        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                    CPCRefractiveIndex := RealNumber;
	        IF ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                    CPCRefractiveIndex > 1.0 THEN
                  BEGIN
                    IF (ZBA_SURFACE [SurfaceOrdinal].
                        ZCF_GLASS_NAME_SPECIFIED [1]
                      OR ZBA_SURFACE [SurfaceOrdinal].
                        ZCF_GLASS_NAME_SPECIFIED [2]) THEN
                    ELSE
                    IF (ZBA_SURFACE [SurfaceOrdinal].
                        ZCG_INDEX_OR_GLASS [1].ZBI_REFRACTIVE_INDEX > 1.0)
                      OR (ZBA_SURFACE [SurfaceOrdinal].
                        ZCG_INDEX_OR_GLASS [2].
                        ZBI_REFRACTIVE_INDEX > 1.0) THEN
                    ELSE
                      BEGIN
                        RefractiveIndexOK := FALSE;
                        CommandIOMemo.IOHistory.Lines.add ('');
                        CommandIOMemo.IOHistory.Lines.add
                            ('ERROR:  The incident and exit refractive');
                        CommandIOMemo.IOHistory.Lines.add
                            ('indices of the original surface were set');
                        CommandIOMemo.IOHistory.Lines.add
                            ('to 1.  Only a hollow CPC is allowed.');
	                Q990_INPUT_ERROR_PROCESSING
                      END
                  END
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    RefractiveIndexOK
    OR S01AB_USER_IS_DONE

END;




(**  Q15RequestRadiusOfOutputAperture  **************************************
****************************************************************************)

PROCEDURE Q15RequestRadiusOfOutputAperture (SurfaceOrdinal : INTEGER);

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'Enter radius of CPC output aperture:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('Enter radius of CPC output aperture.');
	  CommandIOMemo.IOHistory.Lines.add ('  (Present value is ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
              SurfaceShapeParameters.RadiusOfOutputAperture, ffFixed, 10, 4) +
              '.)');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF S01AB_USER_IS_DONE THEN
	BEGIN
          IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              RadiusOfOutputAperture > 0.0) THEN
            BEGIN
	      ExitApertureRadiusOK := TRUE;
              ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA :=
                  ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                  RadiusOfOutputAperture * 2.0;
              ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := TRUE
            END
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpCPCDesignParameters
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, Code);
	  IF Code = 0 THEN
	    IF (RealNumber > 0.0) THEN
	      BEGIN
	        ExitApertureRadiusOK := TRUE;
	        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                    RadiusOfOutputAperture := RealNumber;
                ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA :=
                    RealNumber * 2.0;
                ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := TRUE
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    ExitApertureRadiusOK
    OR S01AB_USER_IS_DONE

END;




(**  Q500RequestFileName  *****************************************************
******************************************************************************)


PROCEDURE Q500RequestFileName (VAR FileOpen  : BOOLEAN);

  VAR
      SaveIOResult               :  INTEGER;

      SurfaceProfileDataFileName : STRING;

BEGIN

  FileOpen := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'Enter surface profile data file name:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('Enter surface profile data file name.');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('Please use only exact file name, including file type.');
	  CommandIOMemo.IOHistory.Lines.add
              ('No wild card characters should be used.')
	END
      ELSE
	BEGIN
	  SurfaceProfileDataFileName := S01AF_BLANKS_STRIPPED_RESPONSE_UC;
	  ASSIGN (SurfaceProfileFile, SurfaceProfileDataFileName);
	  {$I-}
	  RESET (SurfaceProfileFile);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      {$I-}
	      REWRITE (SurfaceProfileFile);
	      {$I+}
	      SaveIOResult := IORESULT;
	      IF SaveIOResult <> 0 THEN
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                      ('ERROR:  Attempt to create text file "' +
		      SurfaceProfileDataFileName + '" failed.');
		  CommandIOMemo.IOHistory.Lines.add
                      ('(IORESULT is: ' + IntToStr (SaveIOResult) + '.)')
		END
	      ELSE
		FileOpen := TRUE
	    END
	  ELSE
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('ATTENTION:  File "' + SurfaceProfileDataFileName +
		  '" already exists.');
	      Q970AB_OUTPUT_STRING :=
		  'Do you wish to over-write the data?';
              Q970_REQUEST_PERMIT_TO_PROCEED;
	      IF Q970AA_OK_TO_PROCEED THEN
		BEGIN
		  {$I-}
		  REWRITE (SurfaceProfileFile);
		  {$I+}
		  SaveIOResult := IORESULT;
		  IF SaveIOResult <> 0 THEN
	            BEGIN
		      CommandIOMemo.IOHistory.Lines.add ('');
		      CommandIOMemo.IOHistory.Lines.add
                          ('ERROR:  Attempt to create text file "' +
			  SurfaceProfileDataFileName + '" failed.');
		      CommandIOMemo.IOHistory.Lines.add ('(IORESULT is: ' +
                          IntToStr (SaveIOResult) + '.)')
		    END
		  ELSE
		    FileOpen := TRUE
		END
              ELSE
		CLOSE (SurfaceProfileFile)
	    END
	END
    END
  UNTIL
    FileOpen
    OR S01AB_USER_IS_DONE

END;




(**  CPCComputations  *******************************************************
****************************************************************************)

PROCEDURE CPCComputations;

  VAR
      SineIncidentAngleInCPC         : DOUBLE;
      CosineIncidentAngleInCPC       : DOUBLE;
      SineMinIncidentAngleForTIR     : DOUBLE;
      CosineMinIncidentAngleForTIR   : DOUBLE;
      MinPhiForConeSectionRad        : DOUBLE;
      MaxPhiForConeSectionRad        : DOUBLE;
      MinPhiForParabolaSectionRad    : DOUBLE;

BEGIN

  (* For a solid concentrator, the maximum incident angle inside the
     concentrator is computed from the maximum incident angle outside
     the concentrator, by use of Snell's law.  For a hollow concentrator,
     the maximum incident angle inside the concentrator will be the same
     as the maximum incident angle outside the concentrator.  *)

  SineIncidentAngleInCPC :=
      sin (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInAirDeg * pi / 180.00) / ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.CPCRefractiveIndex;
  CosineIncidentAngleInCPC := sqrt (1.0 - sqr (SineIncidentAngleInCPC));
  ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad := ArcTan (SineIncidentAngleInCPC /
      CosineIncidentAngleInCPC);
      
  ExitAngleRad := ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      ExitAngleDeg * pi / 180.0;
  
  ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfInputAperture := ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.RadiusOfOutputAperture * sin (ExitAngleRad) /
      sin (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad);

  ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA := 2.0 *
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfInputAperture;

  ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := TRUE;

  AreaConcentrationRatio :=
      sqr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfInputAperture / ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.RadiusOfOutputAperture);
      
  FocalLengthX2 := 2.0 * ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfOutputAperture * (sin (ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad) + sin (ExitAngleRad));
      
  ComputedOverallLength := (ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.RadiusOfOutputAperture +
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfInputAperture) / (sin (ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad) /
      cos (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad));
      
  MinIncidentAngleInCPCRad := (pi / 2.0) - 0.5 * (ExitAngleRad +
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad);

  SineMinIncidentAngleForTIR := 1.0 / ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.CPCRefractiveIndex;
  CosineMinIncidentAngleForTIR :=
      sqrt (1.0 - sqr (SineMinIncidentAngleForTIR));
  IF abs (CosineMinIncidentAngleForTIR) < 1.0E-12 THEN
    MinIncidentAngleForTIRRad := pi / 2.0
  ELSE
    MinIncidentAngleForTIRRad := ArcTan (SineMinIncidentAngleForTIR /
        CosineMinIncidentAngleForTIR);

  ComputedConeSectionLength := FocalLengthX2 * cos (ExitAngleRad) /
      (1.0 - cos (ExitAngleRad + ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad));
      
  MaxRadiusOfConeSection := (FocalLengthX2 * sin (ExitAngleRad) /
      (1.0 - cos (ExitAngleRad + ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad))) -
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfOutputAperture;

  (* The angle "phi" is the angle subtended between two lines formed as
     follows.  The first line extends from the focus of a parabolic
     meridian section of the concentrator, to a point located on the same
     meridian parabolic section (or to a point located on the adjacent
     cone section).  The second line is the axis of the same parabolic
     meridian section.  The vertex of the angle is located at the focus of
     the same parabolic meridian section. *)
      
  MinPhiForConeSectionRad := ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad + ExitAngleRad;
  MaxPhiForConeSectionRad := ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad + pi / 2.0;
  
  MinPhiForParabolaSectionRad := 2.0 * ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad;
  MaxPhiForParabolaSectionRad := ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.MaxEntranceAngleInCPCRad + ExitAngleRad;
  
  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC THEN
    ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.MaxPhi :=
        MaxPhiForConeSectionRad
  ELSE
    ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.MaxPhi :=
        MaxPhiForParabolaSectionRad;

  ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.MinPhi :=
      MinPhiForParabolaSectionRad;

  ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV := DefaultCPCRadius;
  ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT := FALSE;

  ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT := DefaultCPCConicConstant

END;




(**  DisplayComputationResults  *********************************************
****************************************************************************)

PROCEDURE DisplayComputationResults (SurfaceOrdinal  : INTEGER);

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');

  CommandIOMemo.IOHistory.Lines.add
      ('Maximum external entrance angle in air (degrees ) .... ' +
      FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInAirDeg, ffFixed, 10, 4));

  CommandIOMemo.IOHistory.Lines.add
      ('CPC refractive index ................................. ' +
      FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      CPCRefractiveIndex, ffFixed, 10, 4));

  CommandIOMemo.IOHistory.Lines.add
      ('Maximum internal entrance angle in CPC (degrees) ..... ' +
      FloatToStrF ((ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad * 180.0 / pi), ffFixed, 10, 4));

  CommandIOMemo.IOHistory.Lines.add
      ('Maximum internal exit angle in CPC (degrees) ......... ' +
      FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      ExitAngleDeg, ffFixed, 10, 4));

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add
          ('Minor radius of CPC cone section ..................... ' +
	  FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          RadiusOfOutputAperture, ffFixed, 10, 4));
      CommandIOMemo.IOHistory.Lines.add
          ('Major radius of CPC cone section ..................... ' +
	  FloatToStrF (MaxRadiusOfConeSection, ffFixed, 10, 4));
      CommandIOMemo.IOHistory.Lines.add
          ('Length of cone section of CPC ........................ ' +
	  FloatToStrF (ComputedConeSectionLength, ffFixed, 10, 4))
    END
  ELSE
    CommandIOMemo.IOHistory.Lines.add
        ('Radius of CPC output aperture ........................ ' +
	FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
        RadiusOfOutputAperture, ffFixed, 10, 4));
	
  CommandIOMemo.IOHistory.Lines.add
      ('Radius of CPC input aperture ......................... ' +
      FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfInputAperture, ffFixed, 10, 4));
      
  CommandIOMemo.IOHistory.Lines.add
      ('Area concentration ratio ............................. ' +
      FloatToStrF (AreaConcentrationRatio, ffFixed, 10, 4));

  CommandIOMemo.IOHistory.Lines.add
      ('Overall length of CPC ................................ ' +
      FloatToStrF (ComputedOverallLength, ffFixed, 10, 4));

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      CPCRefractiveIndex > 1.0 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add
        ('Minimum incident angle in CPC ........................ ' +
        FloatToStrF ((MinIncidentAngleInCPCRad * 180.0 / pi), ffFixed, 10, 4));
      CommandIOMemo.IOHistory.Lines.add
        ('Minimum incident angle for TIR ....................... ' +
        FloatToStrF ((MinIncidentAngleForTIRRad * 180.0 / pi), ffFixed, 10, 4));
      AngleDifferenceForTIRDeg :=
	  (MinIncidentAngleInCPCRad - MinIncidentAngleForTIRRad) *
	  180.0 / pi;
      IF AngleDifferenceForTIRDeg > 0.0 THEN
	CommandIOMemo.IOHistory.Lines.add
          ('    (TIR will occur, with a margin of ' +
          FloatToStrF (AngleDifferenceForTIRDeg, ffFixed, 8, 4) + ' degrees.)')
      ELSE
	CommandIOMemo.IOHistory.Lines.add ('    (Insufficient for TIR by ' +
          FloatToStrF (AngleDifferenceForTIRDeg, ffFixed, 8, 4) + ' degrees.)')
    END;

  CommandIOMemo.IOHistory.Lines.add
      ('Focal length of parabolic section .................... ' +
      FloatToStrF ((FocalLengthX2 / 2.0), ffFixed, 10, 4));

  Q980_REQUEST_MORE_OUTPUT

END;




(**  GetRAndZForCPC  ********************************************************
****************************************************************************)

PROCEDURE GetRAndZForCPC;

  VAR
      l  : DOUBLE;

BEGIN

  IF Phi <= MaxPhiForParabolaSectionRad THEN
    BEGIN
      rCPC := ((FocalLengthX2 * sin (Phi - ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MaxEntranceAngleInCPCRad)) /
          (1.0 - cos (Phi))) - ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.RadiusOfOutputAperture;
      zCPC := -1.0 * ((FocalLengthX2 * cos (Phi -
          ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          MaxEntranceAngleInCPCRad)) / (1.0 - cos (Phi)))
    END
  ELSE
    BEGIN
      l := (2.0 * ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          RadiusOfOutputAperture * cos (0.5 * (ExitAngleRad -
	  ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          MaxEntranceAngleInCPCRad))) /
	  sin (Phi - 0.5 * (ExitAngleRad + ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MaxEntranceAngleInCPCRad));
      rCPC := l * sin (Phi - ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MaxEntranceAngleInCPCRad) -
          ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          RadiusOfOutputAperture;
      zCPC := -1.0 * l * cos (Phi - ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MaxEntranceAngleInCPCRad)
    END

END;




(**  GenerateCPCProfile  ****************************************************
****************************************************************************)

PROCEDURE GenerateCPCProfile (SurfaceOrdinal : INTEGER);

  VAR
      I       : INTEGER;

      Phi     : DOUBLE;
      rCPC    : DOUBLE;
      zCPC    : DOUBLE;

BEGIN

  WRITELN (SurfaceProfileFile);
  WRITELN (SurfaceProfileFile, '  Fabrication Info:');
  WRITELN (SurfaceProfileFile);

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC THEN
    BEGIN
      WRITELN (SurfaceProfileFile,
          'Minor radius of cone section (CPC output aperture radius) ..... ',
	  ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          RadiusOfOutputAperture:10:4);
      WRITELN (SurfaceProfileFile,
          'Major radius of cone section (tangent to parabolic section) ... ',
	  MaxRadiusOfConeSection:10:4);
      WRITELN (SurfaceProfileFile,
          'Length of cone section .................',
	  '....................... ',
	  ComputedConeSectionLength:10:4)
    END
  ELSE
    WRITELN (SurfaceProfileFile, 'Radius of CPC output aperture ..........',
	'....................... ',
	ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
        RadiusOfOutputAperture:10:4);
	
  WRITELN (SurfaceProfileFile, 'Overall length of CPC ..................',
      '....................... ',
      ComputedOverallLength:10:4);
      
  WRITELN (SurfaceProfileFile, 'Major radius of parabolic section (CPC i',
      'nput aperture radius)   ',
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      RadiusOfInputAperture:10:4);
      
  WRITELN (SurfaceProfileFile, 'Tilt of parabolic section (upper meridia',
      'n section) ............ ',
      (-1.0 * ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad * 180.0 / pi):10:4);
      
  WRITELN (SurfaceProfileFile, 'Focal length of parabolic section ......',
      '....................... ',
      (FocalLengthX2 / 2.0):10:4);
      
  WRITELN (SurfaceProfileFile,
      'Vertex of parabolic section (upper meridian section):');

  WRITELN (SurfaceProfileFile, '  z = ', ((FocalLengthX2 / 2.0) * -1.0 *
      cos (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad)):10:4);
      
  WRITELN (SurfaceProfileFile, '  r = ', ((FocalLengthX2 / 2.0) *
      sin (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad) - ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.RadiusOfOutputAperture):10:4);

  WRITELN (SurfaceProfileFile);
  WRITELN (SurfaceProfileFile, '  Surface Profile:');
  WRITELN (SurfaceProfileFile);

  Phi := ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.MinPhi;
  GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
  WRITELN (SurfaceProfileFile , rCPC, ' ', (zCPC + 0.0));
  WRITELN (SurfaceProfileFile , -rCPC, ' ', (zCPC + 0.0));
      
  FOR I := 1 TO AngleSteps DO
    BEGIN
      Phi := (I / AngleSteps) * (ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MaxPhi - ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MinPhi) + ZBA_SURFACE [SurfaceOrdinal].
          SurfaceShapeParameters.MinPhi;
      GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
      WRITELN (SurfaceProfileFile , rCPC, ' ', (zCPC + 0.0));
      WRITELN (SurfaceProfileFile , -rCPC, ' ', (zCPC + 0.0))
    END

END;




(**  DesignCPC  *************************************************************
****************************************************************************)

PROCEDURE DesignCPC;

  VAR
      FileOpen  : BOOLEAN;

(**  AutoInstall  ***********************************************************
****************************************************************************)

PROCEDURE AutoInstall;

  VAR
      I  : INTEGER;

BEGIN

  ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z :=
      ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
      ComputedOverallLength;

  FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO
      (SurfaceOrdinal + 1) DO
    ZBA_SURFACE [I] := ZBA_SURFACE [I - 1];

  ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
      ZEA_SURFACE_DATA_INITIALIZER;

  ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV := 0.0;

  ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT := TRUE;

  ZBA_SURFACE [SurfaceOrdinal].
      ZCG_INDEX_OR_GLASS [1].ZBI_REFRACTIVE_INDEX :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZCG_INDEX_OR_GLASS [1].ZBI_REFRACTIVE_INDEX;

  ZBA_SURFACE [SurfaceOrdinal].
      ZCG_INDEX_OR_GLASS [2].ZBI_REFRACTIVE_INDEX :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZCG_INDEX_OR_GLASS [2].ZBI_REFRACTIVE_INDEX;

  ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1] :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZCF_GLASS_NAME_SPECIFIED [1];

  ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZCF_GLASS_NAME_SPECIFIED [2];

  ZBA_SURFACE [SurfaceOrdinal].
      ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME;

  ZBA_SURFACE [SurfaceOrdinal].
      ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME;

  ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].ZBD_REFLECTIVE;

  ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].ZBQ_VERTEX_Z -
      ComputedOverallLength;

  ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA :=
      ZBA_SURFACE [(SurfaceOrdinal + 1)].
      ZBJ_OUTSIDE_APERTURE_DIA;

  ZBA_SURFACE [SurfaceOrdinal].
      ZBH_OUTSIDE_DIMENS_SPECD := TRUE;

  ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED := TRUE;

  ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE;

  SurfaceOrdinal := SurfaceOrdinal + 2;

  FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO
      (SurfaceOrdinal + 1) DO
    ZBA_SURFACE [I] := ZBA_SURFACE [I - 1];

  ZBA_SURFACE [SurfaceOrdinal] :=
      ZBA_SURFACE [(SurfaceOrdinal - 2)];

  ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA :=
      ZBA_SURFACE [(SurfaceOrdinal - 1)].SurfaceShapeParameters.
      RadiusOfOutputAperture * 2.0;

  ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z :=
      ZBA_SURFACE [(SurfaceOrdinal - 1)].ZBQ_VERTEX_Z;

  SurfaceOrdinal := SurfaceOrdinal - 1

END;




(**  DesignCPC  *************************************************************
****************************************************************************)


BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('NOTE:  The CPC design parameters you are about to enter are');
  CommandIOMemo.IOHistory.Lines.add
      ('used only for the purpose of defining the shape of the CPC.');
  CommandIOMemo.IOHistory.Lines.add
      ('The shape of the CPC is determined by:');
  CommandIOMemo.IOHistory.Lines.add
      ('  1.) Maximum external angle of incidence (in air) at the');
  CommandIOMemo.IOHistory.Lines.add
      ('        entrance aperture of the CPC');
  CommandIOMemo.IOHistory.Lines.add
      ('  2.) CPC refractive index (referred to air)');
  CommandIOMemo.IOHistory.Lines.add
      ('  3.) Maximum internal angle of incidence (within CPC medium)');
  CommandIOMemo.IOHistory.Lines.add
      ('        at the exit aperture of the CPC');
  CommandIOMemo.IOHistory.Lines.add
      ('  4.) Radius of the CPC exit aperture.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('Although the CPC shape is defined with respect to an air');
  CommandIOMemo.IOHistory.Lines.add
      ('environment, the design will be valid in any environment.');
  CommandIOMemo.IOHistory.Lines.add
      ('Note: TIR may be frustrated if a solid CPC is not used in air.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('The default position (x=y=z=0) for a CPC refers to the');
  CommandIOMemo.IOHistory.Lines.add
      ('center of the entrance aperture.  The default orientation');
  CommandIOMemo.IOHistory.Lines.add
      ('(yaw=pitch=roll=0) exists when the axis of symmetry of the CPC');
  CommandIOMemo.IOHistory.Lines.add
      ('is parallel to the z-axis in world coordinates.  In the');
  CommandIOMemo.IOHistory.Lines.add
      ('default orientation, the CPC opens up toward negative z.');
  Q980_REQUEST_MORE_OUTPUT;

  MaxEntranceAngleOK   := FALSE;
  MaxExitAngleOK       := FALSE;
  RefractiveIndexOK    := FALSE;
  ExitApertureRadiusOK := FALSE;
  CPCDefined           := FALSE;

  Q01RequestMaxEntranceAngleInAirDeg (SurfaceOrdinal);

  IF NOT S01AD_END_EXECUTION_DESIRED THEN
    Q05RequestExitAngleDeg (SurfaceOrdinal);

  IF NOT S01AD_END_EXECUTION_DESIRED THEN
    Q10RequestCPCRefractiveIndex (SurfaceOrdinal);

  IF NOT S01AD_END_EXECUTION_DESIRED THEN
    Q15RequestRadiusOfOutputAperture (SurfaceOrdinal);

  IF MaxEntranceAngleOK
      AND MaxExitAngleOK
      AND RefractiveIndexOK
      AND ExitApertureRadiusOK  THEN
    CPCDefined := TRUE;

  IF CPCDefined THEN
    BEGIN
      IF ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ExitAngleDeg < MaxExitAngleForHybridCPCDeg THEN
	ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := HybridCPC
      ELSE
	ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := CPC;
      CPCComputations (SurfaceOrdinal);
      DisplayComputationResults (SurfaceOrdinal);
      IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC THEN
        BEGIN
          Q970AB_OUTPUT_STRING :=
              'Do you want automatic installation of CPC' +
              ' entrance and exit surfaces?';
          Q970_REQUEST_PERMIT_TO_PROCEED;
          IF Q970AA_OK_TO_PROCEED THEN
            IF SurfaceOrdinal <= (CZAB_MAX_NUMBER_OF_SURFACES - 2) THEN
              BEGIN
                IF (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].
                      ZBN_VERTEX_DELTA_X <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].
                      ZBP_VERTEX_DELTA_Y <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].
                      ZBR_VERTEX_DELTA_Z <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].ZBS_ROLL <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].ZBT_DELTA_ROLL <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].ZBU_PITCH <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].ZBV_DELTA_PITCH <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].ZBW_YAW <> 0.0)
	            OR (ZBA_SURFACE [SurfaceOrdinal].
                      ZBX_DELTA_YAW <> 0.0) THEN
                  BEGIN
                    CommandIOMemo.IOHistory.Lines.add ('');
                    CommandIOMemo.IOHistory.Lines.add
                        ('ERROR:  Position and/or orientation of CPC');
                    CommandIOMemo.IOHistory.Lines.add
                        ('too complex to allow auto installation of');
                    CommandIOMemo.IOHistory.Lines.add
                        ('entrance and exit surfaces.')
                  END
                ELSE
                  AutoInstall
              END
            ELSE
              BEGIN
                CommandIOMemo.IOHistory.Lines.add ('');
                CommandIOMemo.IOHistory.Lines.add
                    ('ERROR:  Not enough room in surface table for');
                CommandIOMemo.IOHistory.Lines.add
                    ('automatic installation of entrance and exit');
                CommandIOMemo.IOHistory.Lines.add
                    ('surfaces for CPC.')
              END
        END;
      Q970AB_OUTPUT_STRING :=
          'Do you wish to produce a CPC surface profile data file?';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      IF Q970AA_OK_TO_PROCEED THEN
	BEGIN
	  Q500RequestFileName (FileOpen);
	  IF FileOpen THEN
            BEGIN
	      GenerateCPCProfile (SurfaceOrdinal);
              CLOSE (SurfaceProfileFile);
              FileOpen := FALSE
            END
	END
    END
  ELSE
    ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := Conic
    
END;




(**  LADSqCPCUnit  **********************************************************
****************************************************************************)


BEGIN

END.
