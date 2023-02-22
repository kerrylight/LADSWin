UNIT LADSPostProcUnit;

INTERFACE

  TYPE
    DisplayState       = (FullDisplay, DisplayDisabled);
    HistogramVarieties = (OneDimensHistogram, TwoDimensEqualAreaHistogram,
                          TwoDimensEqualRadiusHistogram);

PROCEDURE V15_AIM_PRINCIPAL_RAY;
PROCEDURE V20_COMPUTE_TRACE_STATISTICS;
PROCEDURE V25_PRODUCE_SPOT_DIAGRAM;
PROCEDURE V30_DISPLAY_INTENSITY_HISTOGRAM
   (DisplayStatus            : DisplayState;
    HistogramType            : HistogramVarieties;
    EnergyBuckets            : INTEGER;
    VAR ImageUniformityMerit : DOUBLE);
(*PROCEDURE V35_PRODUCE_SPOT_DIAGRAM_FILE;*)
PROCEDURE V40_PRODUCE_PSF_FILE;
PROCEDURE V45_DISPLAY_OPD_STATISTICS;

IMPLEMENTATION

  USES SysUtils,
       Graphics,
       (*HistogramUnit,*)
       LADSGraphics,
       LADSData,
       LADSCommandIOMemoUnit,
       EXPERTIO,
       LADSGlassVar,
       LADSTraceUnit,
       LADSFileProcUnit,
       LADSUtilUnit;

  VAR
      HistogramFileCount  : INTEGER;


(**  V15_AIM_PRINCIPAL_RAY  ***************************************************
******************************************************************************)

PROCEDURE V15_AIM_PRINCIPAL_RAY;

  CONST
      MinRayIntercepts = 5;
      CoordFileXName   = 'XCoords.txt';
      CoordFileYName   = 'YCoords.txt';

  VAR
      Valid           : BOOLEAN;

      I               : INTEGER;

      X               : DOUBLE;
      Y               : DOUBLE;
      Afit            : DOUBLE;
      Bfit            : DOUBLE;
      Cfit            : DOUBLE;
      ChiSqr          : DOUBLE;
      rSqr            : DOUBLE;

      CoordFileName   : STRING;

      CoordinateFile  : TEXT;

BEGIN

  IF ARB_TOTAL_RECURS_INTERCEPTS >= MinRayIntercepts THEN
    BEGIN
      IF ZNA_RAY [RayOrdinal].TraceLinearXFan THEN
        CoordFileName := CoordFileXName
      ELSE
        CoordFileName := CoordFileYName;
      ASSIGN (CoordinateFile, CoordFileName);
      REWRITE (CoordinateFile);
      ARC_RECURS_INT_BLOCK_SLOT := 1;
      ARW_RECURS_INT_BLOCK_NMBR := 0;
      X16_REWIND_AND_READ_RECURSIVE_INTRCPT (NoErrors);
      I := 1;
      REPEAT
        BEGIN
          IF ZNA_RAY [RayOrdinal].TraceLinearXFan THEN
            (* This is the original local x-coordinate of the head of the
               bundle ray, i.e., before interaction with any surface.
               The y and z coordinates are, by definition, zero. *)
            X := ZSA_SURFACE_INTERCEPTS.ZSB_A1
          ELSE
            (* This is the original local y-coordinate of the head of the
               bundle ray, i.e., before interaction with any surface.
               The x and z coordinates are, by definition, zero. *)
            X := ZSA_SURFACE_INTERCEPTS.ZSC_B1;
          (* In local coordinates, this is the distance of the intercept
             from the center of the image surface. *)
          Y := Sqrt (Sqr (ZSA_SURFACE_INTERCEPTS.ZSE_X1) +
              Sqr (ZSA_SURFACE_INTERCEPTS.ZSF_Y1) +
              Sqr (ZSA_SURFACE_INTERCEPTS.ZSG_Z1));
          IF ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX < 0.0 THEN
            IF ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN THEN
            (* This is the results from tracing the principal ray.
               Therefore, the Y value just computed represents the
               aim error for the principal ray.*)
              AimError := Y;
          WRITELN (CoordinateFile, X, ' ', Y);
          I := I + 1;
          IF I > ARB_TOTAL_RECURS_INTERCEPTS THEN
          ELSE
            X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors)
        END
      UNTIL (I > ARB_TOTAL_RECURS_INTERCEPTS);
      Close (CoordinateFile);
      SimpleFit (Valid, Afit, Bfit, Cfit, ChiSqr, rSqr, CoordFileName);
      Erase (CoordinateFile);
      IF Valid THEN
        BEGIN
          LSFitOK := TRUE;
          (* Set the first derivative of the fitting equation
                     y^2 = A + B*x + C*x^2
             to zero, and solve for x.  Thus,
                        x = -B / (2*C) *)
(*        WRITELN ('A = ', Afit:12:8, '  B = ', Bfit:12:8,
              '  C = ', Cfit:12:8, '  r2 = ', rSqr:12:8,
              '  ChiSqr = ', ChiSqr:12:8);
          readln (trash);*)
          IF ZNA_RAY [RayOrdinal].TraceLinearXFan THEN
            (* This is best position, in local coordinates, along the
               original x fan of rays. *)
            RayHeadXShift := (-1.0 * Bfit) / (2.0 * Cfit)
          ELSE
            (* This is best position along the original y fan of rays. *)
            RayHeadYShift := (-1.0 * Bfit) / (2.0 * Cfit)
        END
    END
  ELSE
  IF TracePrincipalRayOnly THEN
    BEGIN
      IF ARB_TOTAL_RECURS_INTERCEPTS = 1 THEN
        BEGIN
          LSFitOK := TRUE;
          ARC_RECURS_INT_BLOCK_SLOT := 1;
          ARW_RECURS_INT_BLOCK_NMBR := 0;
          X16_REWIND_AND_READ_RECURSIVE_INTRCPT (NoErrors);
          AimError := Sqrt (Sqr (ZSA_SURFACE_INTERCEPTS.ZSE_X1) +
              Sqr (ZSA_SURFACE_INTERCEPTS.ZSF_Y1) +
              Sqr (ZSA_SURFACE_INTERCEPTS.ZSG_Z1))
        END
      ELSE
        AimError := 1E10
    END

END;




(**  V20_COMPUTE_TRACE_STATISTICS  ********************************************
******************************************************************************)


PROCEDURE V20_COMPUTE_TRACE_STATISTICS;

  VAR
      V20AN_END_OF_FIRST_PASS	       : BOOLEAN;
      V20AO_END_OF_SECOND_PASS	       : BOOLEAN;
      
      I				       : INTEGER;
      J				       : INTEGER;
      V20AJ_SAVE_BEGIN_BLOCK_SLOT      : INTEGER;
      V20AK_SAVE_BEGIN_FILE_BLOCK      : INTEGER;
      V20AL_SAVE_END_BLOCK_SLOT	       : INTEGER;
      V20AM_SAVE_END_FILE_BLOCK	       : INTEGER;
      
      V20AA_INTENSITY_ACCUM	       : DOUBLE;
      V20AB_SUM_X_COORDS	       : DOUBLE;
      V20AC_SUM_Y_COORDS	       : DOUBLE;
      V20AD_SUM_Z_COORDS	       : DOUBLE;
      V20AE_SPOT_X_CENTROID	       : DOUBLE;
      V20AF_SPOT_Y_CENTROID	       : DOUBLE;
      V20AG_SPOT_Z_CENTROID	       : DOUBLE;
      V20AH_DEVIATION_SQUARED_ACCUM    : DOUBLE;
      V20AP_SPOT_RADIUS_SQUARED	       : DOUBLE;
      V20AQ_SPOT_DIAMETER	       : DOUBLE;
      V20AI_SUM_RMS_SPOT_DIAMETERS     : DOUBLE;

BEGIN

  IF ARB_TOTAL_RECURS_INTERCEPTS < 1 THEN
    BEGIN
      ARD_BLUR_SPHERE_DIAMETER := 1.0E20;
      ARF_RMS_SPOT_DIAMETER := 1.0E20;
      ARG_SPOT_X_CENTROID := 0.0;
      ARH_SPOT_Y_CENTROID := 0.0;
      ARI_SPOT_Z_CENTROID := 0.0
    END
  ELSE
    BEGIN
      V20AI_SUM_RMS_SPOT_DIAMETERS := 0.0;
      ARD_BLUR_SPHERE_DIAMETER := 0.0;
      J := 1;
      I := 1;
      ARC_RECURS_INT_BLOCK_SLOT := 1;
      ARW_RECURS_INT_BLOCK_NMBR := 0;
      X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);
      V20AJ_SAVE_BEGIN_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT;
      V20AK_SAVE_BEGIN_FILE_BLOCK := ARW_RECURS_INT_BLOCK_NMBR;
      REPEAT
	BEGIN
	  V20AB_SUM_X_COORDS := 0;
	  V20AC_SUM_Y_COORDS := 0;
	  V20AD_SUM_Z_COORDS := 0;
	  V20AA_INTENSITY_ACCUM := 0.0;
	  V20AN_END_OF_FIRST_PASS := FALSE;
	  (* The first pass sums the intercept coordinates and intensities
	     of all rays in the bundle associated with the current
	     principal ray. *)
	  REPEAT
	    BEGIN
	      V20AB_SUM_X_COORDS := V20AB_SUM_X_COORDS +
		  ZSA_SURFACE_INTERCEPTS.ZSE_X1 *
		  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	      V20AC_SUM_Y_COORDS := V20AC_SUM_Y_COORDS +
		  ZSA_SURFACE_INTERCEPTS.ZSF_Y1 *
		  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	      V20AD_SUM_Z_COORDS := V20AD_SUM_Z_COORDS +
		  ZSA_SURFACE_INTERCEPTS.ZSG_Z1 *
		  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	      V20AA_INTENSITY_ACCUM := V20AA_INTENSITY_ACCUM +
		  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	      V20AL_SAVE_END_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT;
	      V20AM_SAVE_END_FILE_BLOCK := ARW_RECURS_INT_BLOCK_NMBR;
	      IF I < ARB_TOTAL_RECURS_INTERCEPTS THEN
		BEGIN
		  X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
		  (* Exit index < 0.0 indicates a principal ray *)
		  IF ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX < 0.0 THEN
		    V20AN_END_OF_FIRST_PASS := TRUE
		END
	      ELSE
		V20AN_END_OF_FIRST_PASS := TRUE;
              I := I + 1
	    END
	  UNTIL
	    V20AN_END_OF_FIRST_PASS;
	  (* Intialize for the second pass through the intercept data for
             the current ray bundle. *)
	  IF V20AA_INTENSITY_ACCUM > 0.0 THEN
	    BEGIN
	      V20AO_END_OF_SECOND_PASS := FALSE;
	      ARF_RMS_SPOT_DIAMETER := 0.0;
	      V20AH_DEVIATION_SQUARED_ACCUM := 0.0;
              (* Get the (x,y,z) coords. of the intensity-weighted centroid
                 of the current bundle. *)
	      ARG_SPOT_X_CENTROID := V20AB_SUM_X_COORDS /
		  V20AA_INTENSITY_ACCUM;
	      ARH_SPOT_Y_CENTROID := V20AC_SUM_Y_COORDS /
		  V20AA_INTENSITY_ACCUM;
	      ARI_SPOT_Z_CENTROID := V20AD_SUM_Z_COORDS /
		  V20AA_INTENSITY_ACCUM;
              (* Rewind file to the start of the current ray bundle. *)
	      ARC_RECURS_INT_BLOCK_SLOT := V20AJ_SAVE_BEGIN_BLOCK_SLOT;
	      ARW_RECURS_INT_BLOCK_NMBR := V20AK_SAVE_BEGIN_FILE_BLOCK;
              (* Read the principal ray data for the current bundle. *)
	      X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);
	      (* The second pass uses the spot centroid info. just
		 computed.  The sum of the squares of the
		 deviations of the individual intercepts from the
		 overall intercept centroid is obtained for all
		 intercepts in the bundle associated with the present
		 principal ray.	 The largest deviation x 2 is stored as
		 the diameter of the overall blur circle. *)
	      REPEAT
		BEGIN
		  V20AP_SPOT_RADIUS_SQUARED :=
		      Sqr (ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
		          ARG_SPOT_X_CENTROID) +
		      Sqr (ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
		          ARH_SPOT_Y_CENTROID) +
		      Sqr (ZSA_SURFACE_INTERCEPTS.ZSG_Z1 -
		          ARI_SPOT_Z_CENTROID);
		  V20AQ_SPOT_DIAMETER :=
		      2.0 * SQRT (V20AP_SPOT_RADIUS_SQUARED);
		  IF V20AQ_SPOT_DIAMETER > ARD_BLUR_SPHERE_DIAMETER THEN
		    ARD_BLUR_SPHERE_DIAMETER := V20AQ_SPOT_DIAMETER;
                  (* Sum the square of the intensity-weighted deviations. *)
		  V20AH_DEVIATION_SQUARED_ACCUM :=
		      V20AH_DEVIATION_SQUARED_ACCUM +
		      V20AP_SPOT_RADIUS_SQUARED *
		      Sqr (ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY);
		  IF (ARC_RECURS_INT_BLOCK_SLOT = V20AL_SAVE_END_BLOCK_SLOT)
		      AND (ARW_RECURS_INT_BLOCK_NMBR =
		      V20AM_SAVE_END_FILE_BLOCK) THEN
		    V20AO_END_OF_SECOND_PASS := TRUE
		  ELSE
		    X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
		END
	      UNTIL
		V20AO_END_OF_SECOND_PASS;
              (* Compute the RMS spot diameter for the current bundle. *)
	      ARF_RMS_SPOT_DIAMETER :=
		  2 * (SQRT (V20AH_DEVIATION_SQUARED_ACCUM /
		  V20AA_INTENSITY_ACCUM));
              (* Sum the squares of the intensity-weighted RMS spot diameters
                 for all bundles processed to the present time. *)
	      V20AI_SUM_RMS_SPOT_DIAMETERS := V20AI_SUM_RMS_SPOT_DIAMETERS +
		  SQR (ARF_RMS_SPOT_DIAMETER);
              (* Compute the RMS spot diameter for all bundles processed to
                 the present time. J is the number of bundles processed. *)
	      ARF_RMS_SPOT_DIAMETER :=
		  SQRT (V20AI_SUM_RMS_SPOT_DIAMETERS / J);
	      J := J + 1
	    END
	  ELSE
	    BEGIN
	      ARD_BLUR_SPHERE_DIAMETER := 1.0E20;
	      ARF_RMS_SPOT_DIAMETER := 1.0E20
	    END;
	  IF (I <= ARB_TOTAL_RECURS_INTERCEPTS) THEN
	    BEGIN
	      X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
	      V20AJ_SAVE_BEGIN_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT;
	      V20AK_SAVE_BEGIN_FILE_BLOCK := ARW_RECURS_INT_BLOCK_NMBR
	    END
	END
      UNTIL (I > ARB_TOTAL_RECURS_INTERCEPTS)
    END
  
END;



(**  V25_PRODUCE_SPOT_DIAGRAM  ************************************************
******************************************************************************)

PROCEDURE V25_PRODUCE_SPOT_DIAGRAM;

  CONST
      MaxHorizontalViewports           = 4;
      MaxVerticalViewports             = 3;

  VAR
      ColumnsInViewportRadius          : INTEGER;
      RowsInViewportRadius             : INTEGER;
      ColumnsPerViewport               : INTEGER;
      RowsPerViewport                  : INTEGER;

      ViewportCenterColumn             : ARRAY [1..MaxHorizontalViewports] OF
                                             DOUBLE;
      ViewportCenterRow                : ARRAY [1..MaxVerticalViewports] OF
                                             DOUBLE;

      V25AN_END_OF_FIRST_PASS	       : BOOLEAN;
      V25AO_END_OF_SECOND_PASS	       : BOOLEAN;
      MultiplePrincipalRaysExist       : BOOLEAN;

      I				       : INTEGER;
      J				       : INTEGER;
      V25AJ_SAVE_BEGIN_BLOCK_SLOT      : INTEGER;
      V25AK_SAVE_BEGIN_FILE_BLOCK      : INTEGER;
      V25AL_SAVE_END_BLOCK_SLOT	       : INTEGER;
      V25AM_SAVE_END_FILE_BLOCK	       : INTEGER;

      V25AA_INTENSITY_ACCUM	       : DOUBLE;
      V25AB_SUM_X_COORDS	       : DOUBLE;
      V25AC_SUM_Y_COORDS	       : DOUBLE;
      V25AD_SUM_Z_COORDS	       : DOUBLE;
      V25AE_SPOT_X_CENTROID	       : DOUBLE;
      V25AF_SPOT_Y_CENTROID	       : DOUBLE;
      V25AG_SPOT_Z_CENTROID	       : DOUBLE;
      V25AH_DEVIATION_SQUARED_ACCUM    : DOUBLE;
      V25AP_SPOT_RADIUS_SQUARED	       : DOUBLE;




(**  V2505_DETECT_MULTIPLE_PRINCIPAL_RAYS  ************************************
******************************************************************************)

PROCEDURE V2505_DETECT_MULTIPLE_PRINCIPAL_RAYS;

  VAR
      I  : INTEGER;

BEGIN

  MultiplePrincipalRaysExist := FALSE;
  ARC_RECURS_INT_BLOCK_SLOT := 1;
  ARW_RECURS_INT_BLOCK_NMBR := 0;
  X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);
  I := 1;

  WHILE (NOT MultiplePrincipalRaysExist)
      AND (I < ARB_TOTAL_RECURS_INTERCEPTS) DO
    BEGIN
      X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
      I := I + 1;
      (* Exit index < 0.0 indicates a principal ray *)
      IF ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX < 0.0 THEN
	MultiplePrincipalRaysExist := TRUE
    END

END;




(**  V2510_INITIALIZE_FOR_GRAPHICS  *******************************************
******************************************************************************)

PROCEDURE V2510_INITIALIZE_FOR_GRAPHICS;

  VAR
      HorizViewportNum                 : INTEGER;
      VerticalViewportNum              : INTEGER;

BEGIN

  ColumnsPerViewport    := (RasterColumns + 1) DIV MaxHorizontalViewports;
  RowsPerViewport       := (RasterRows + 1) DIV MaxVerticalViewports;

  FOR HorizViewportNum := 1 TO MaxHorizontalViewports DO
    ViewportCenterColumn [HorizViewportNum] :=
        ColumnsPerViewport * HorizViewportNum -
        (ColumnsPerViewport DIV 2) + 0.5;

  FOR VerticalViewportNum := 1 TO MaxVerticalViewports DO
    ViewportCenterRow [VerticalViewportNum] :=
        RowsPerViewport * VerticalViewportNum -
        (RowsPerViewport DIV 2) + 0.5;

  ColumnsInViewportRadius := (RasterColumns + 1) DIV
      (4 * MaxHorizontalViewports);

  RowsInViewportRadius := LONGINT (ColumnsInViewportRadius) *
			       Xaspect DIV Yaspect

END;




(**  V2515_SET_UP_SPOT_DIAGRAM  ***********************************************
******************************************************************************)

PROCEDURE V2515_SET_UP_SPOT_DIAGRAM;

  VAR
      HLineLeftX               : INTEGER;
      HLineLeftY               : INTEGER;
      HLineRightX              : INTEGER;
      HLineRightY              : INTEGER;
      LeftVLineTopX            : INTEGER;
      LeftVLineTopY            : INTEGER;
      LeftVLineBottomX         : INTEGER;
      LeftVLineBottomY         : INTEGER;
      RightVLineTopX           : INTEGER;
      RightVLineTopY           : INTEGER;
      RightVLineBottomX        : INTEGER;
      RightVLineBottomY        : INTEGER;
      HorizViewportNum         : INTEGER;
      VerticalViewportNum      : INTEGER;
      PrintX                   : INTEGER;
      PrintY                   : INTEGER;

      TempString               : STRING;
      String1                  : STRING;
      StringGap1               : STRING;
      String2                  : STRING;
      StringGap2               : STRING;
      String3                  : STRING;

BEGIN

  (* Draw overall border for viewports.*)

  GraphicsOutputForm.Canvas.MoveTo (0, 0);
  LADSBitmap.Canvas.MoveTo (0, 0);
  GraphicsOutputForm.Canvas.LineTo (RasterColumns, 0);
  LADSBitmap.Canvas.LineTo (RasterColumns, 0);
  GraphicsOutputForm.Canvas.LineTo
      (RasterColumns, (RasterRows - RowsPerViewport + 1));
  LADSBitmap.Canvas.LineTo
      (RasterColumns, (RasterRows - RowsPerViewport + 1));
  GraphicsOutputForm.Canvas.LineTo
      ((RasterColumns - (2 * ColumnsPerViewport) + 1),
      (RasterRows - RowsPerViewport + 1));
  LADSBitmap.Canvas.LineTo
      ((RasterColumns - (2 * ColumnsPerViewport) + 1),
      (RasterRows - RowsPerViewport + 1));
  GraphicsOutputForm.Canvas.LineTo
      ((RasterColumns - (2 * ColumnsPerViewport) + 1), RasterRows);
  LADSBitmap.Canvas.LineTo
      ((RasterColumns - (2 * ColumnsPerViewport) + 1), RasterRows);
  GraphicsOutputForm.Canvas.LineTo (0, RasterRows);
  LADSBitmap.Canvas.LineTo (0, RasterRows);
  GraphicsOutputForm.Canvas.LineTo (0, 0);
  LADSBitmap.Canvas.LineTo (0, 0);

  (* Fill in boundaries for each viewport.*)

  (* hor. line *)
  GraphicsOutputForm.Canvas.MoveTo (0, RowsPerViewport);
  LADSBitmap.Canvas.MoveTo (0, RowsPerViewport);
  GraphicsOutputForm.Canvas.LineTo (RasterColumns, RowsPerViewport);
  LADSBitmap.Canvas.LineTo (RasterColumns, RowsPerViewport);

  (* hor. line *)
  GraphicsOutputForm.Canvas.MoveTo (0, (2 * RowsPerViewport));
  LADSBitmap.Canvas.MoveTo (0, (2 * RowsPerViewport));
  GraphicsOutputForm.Canvas.LineTo
      ((2 * ColumnsPerViewport),(2 * RowsPerViewport));
  LADSBitmap.Canvas.LineTo
      ((2 * ColumnsPerViewport),(2 * RowsPerViewport));

  (* vert. line *)
  GraphicsOutputForm.Canvas.MoveTo (ColumnsPerViewport, 0);
  LADSBitmap.Canvas.MoveTo (ColumnsPerViewport, 0);
  GraphicsOutputForm.Canvas.LineTo (ColumnsPerViewport, RasterRows);
  LADSBitmap.Canvas.LineTo (ColumnsPerViewport, RasterRows);

  (* vert. line *)
  GraphicsOutputForm.Canvas.MoveTo ((2 * ColumnsPerViewport), 0);
  LADSBitmap.Canvas.MoveTo ((2 * ColumnsPerViewport), 0);
  GraphicsOutputForm.Canvas.LineTo
      ((2 * ColumnsPerViewport),(2 * RowsPerViewport));
  LADSBitmap.Canvas.LineTo
      ((2 * ColumnsPerViewport),(2 * RowsPerViewport));

  GraphicsOutputForm.Canvas.MoveTo ((3 * ColumnsPerViewport), 0);
  LADSBitmap.Canvas.MoveTo ((3 * ColumnsPerViewport), 0);
  GraphicsOutputForm.Canvas.LineTo
      ((3 * ColumnsPerViewport), (2 * RowsPerViewport));
  LADSBitmap.Canvas.LineTo
      ((3 * ColumnsPerViewport), (2 * RowsPerViewport));

(*FOR HorizViewportNum := 1 TO MaxHorizontalViewports DO
    FOR VerticalViewportNum := 1 TO MaxVerticalViewports DO
      BEGIN*)
        (* Draw a horizontal line segment in each viewport that represents
        the user-specified image surface diameter. *)
(*      HLineLeftX := Round (ViewportCenterColumn [HorizViewportNum]) -
            ColumnsInViewportRadius;
        HLineLeftY := Round (ViewportCenterRow [VerticalViewportNum] +
            1.25 * RowsInViewportRadius);
        HLineRightX := HLineLeftX + 2 * ColumnsInViewportRadius;
        HLineRightY := HLineLeftY;
        Line (HLineLeftX, HLineLeftY, HLineRightX, HLineRightY);*)
        (* Draw vertical line segments at the left and right ends of the
        horizontal line segment.*)
(*      LeftVLineTopX := HLineLeftX;
        LeftVLineTopY := Round (HLineLeftY - 0.1 * RowsInViewportRadius);
        LeftVLineBottomX := HLineLeftX;
        LeftVLineBottomY := Round (LeftVLineTopY + 0.2 * RowsInViewportRadius);
        Line (LeftVLineTopX, LeftVLineTopY, LeftVLineBottomX,
            LeftVLineBottomY);
        RightVLineTopX := HLineRightX;
        RightVLineTopY := LeftVLineTopY;
        RightVLineBottomX := HLineRightX;
        RightVLineBottomY := LeftVLineBottomY;
        Line (RightVLineTopX, RightVLineTopY, RightVLineBottomX,
            RightVLineBottomY)
      END;*)

(*MoveTo (10, 20);

  SetTextJustify (LeftText, TopText);

  OutText ('DIAMETER OF DESIGNATED (IMAGE) SURFACE: ');
  Str (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER, TempString);
  OutText (TempString);

  MoveTo (10, (GetMaxY - 30));

  SetTextJustify (LeftText, BottomText);

  String1 := 'INTENSITY: ';
  StringGap1 := '         ';
  String2 := ' INITIAL   ';
  StringGap2 := '         ';
  String3 := ' ACCUM. (DERATED) AT SURF. ';
  Str (ZFA_OPTION.ZGK_DESIGNATED_SURFACE, TempString);
  TempString := Concat (String1, StringGap1, String2, StringGap2,
      String3, TempString);
  OutText (TempString);
  SpotInitialPixelPosition := TextWidth (String1);
  TempString := Concat (String1, StringGap1, String2);
  SpotAccumPixelPosition := TextWidth (TempString);

  LastInitialIntensityString    := '';
  LastAccumIntensityString      := ''*)

END;




(**  V2520_PLOT_SPOTS  ********************************************************
******************************************************************************)

PROCEDURE V2520_PLOT_SPOTS;

  VAR
      DisplayAngles          : BOOLEAN;

      VerticalViewportNum    : INTEGER;
      HorizViewportNum       : INTEGER;
      PrintX                 : INTEGER;
      PrintY                 : INTEGER;

      XDev                   : DOUBLE;
      YDev                   : DOUBLE;
      ZDev                   : DOUBLE;
      ROW_INDEX_REAL         : DOUBLE;
      COLUMN_INDEX_REAL      : DOUBLE;
      SpotDiameterTest       : DOUBLE;
      FullSpotDiameter       : DOUBLE;
      FullSpotAngularWidthRad  : DOUBLE;
      RMSSpotAngularWidthRad   : DOUBLE;
      FullSpotAngularWidth     : DOUBLE;
      RMSSpotAngularWidth      : DOUBLE;
      Pitch                  : DOUBLE;
      Yaw                    : DOUBLE;
      TestValue              : DOUBLE;

      TempString             : STRING;

BEGIN

  HorizViewportNum := 1;
  VerticalViewportNum := 1;

  I := 1;

  ARC_RECURS_INT_BLOCK_SLOT := 1;
  ARW_RECURS_INT_BLOCK_NMBR := 0;

  X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);

  V25AJ_SAVE_BEGIN_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT;
  V25AK_SAVE_BEGIN_FILE_BLOCK := ARW_RECURS_INT_BLOCK_NMBR;

  REPEAT
    BEGIN
      V25AB_SUM_X_COORDS := 0;
      V25AC_SUM_Y_COORDS := 0;
      V25AD_SUM_Z_COORDS := 0;
      V25AA_INTENSITY_ACCUM := 0.0;
      V25AN_END_OF_FIRST_PASS := FALSE;
      (* The first pass sums the intercept coordinates and intensities
	 of all rays in the bundle associated with the current
	 principal ray. *)
      REPEAT
	BEGIN
	  V25AB_SUM_X_COORDS := V25AB_SUM_X_COORDS +
	      ZSA_SURFACE_INTERCEPTS.ZSE_X1 *
	      ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	  V25AC_SUM_Y_COORDS := V25AC_SUM_Y_COORDS +
	      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 *
	      ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	  V25AD_SUM_Z_COORDS := V25AD_SUM_Z_COORDS +
	      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 *
	      ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	  V25AA_INTENSITY_ACCUM := V25AA_INTENSITY_ACCUM +
	      ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
	  V25AL_SAVE_END_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT;
	  V25AM_SAVE_END_FILE_BLOCK := ARW_RECURS_INT_BLOCK_NMBR;
	  IF I < ARB_TOTAL_RECURS_INTERCEPTS THEN
	    BEGIN
	      X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
	      (* Exit index < 0.0 indicates a principal ray *)
	      IF ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX < 0.0 THEN
		V25AN_END_OF_FIRST_PASS := TRUE
	    END
	  ELSE
	    V25AN_END_OF_FIRST_PASS := TRUE;
          I := I + 1
	END
      UNTIL
	V25AN_END_OF_FIRST_PASS;
      (* Intialize for the second pass through the intercept data for
         the current ray bundle. *)
      IF V25AA_INTENSITY_ACCUM > 0.0 THEN
	BEGIN
	  V25AO_END_OF_SECOND_PASS := FALSE;
	  ARF_RMS_SPOT_DIAMETER := 0.0;
	  V25AH_DEVIATION_SQUARED_ACCUM := 0.0;
          FullSpotDiameter := 0.0;
          (* Get the (x,y,z) coords. of the intensity-weighted centroid
             of the current bundle. *)
	  ARG_SPOT_X_CENTROID := V25AB_SUM_X_COORDS /
	      V25AA_INTENSITY_ACCUM;
	  ARH_SPOT_Y_CENTROID := V25AC_SUM_Y_COORDS /
	      V25AA_INTENSITY_ACCUM;
	  ARI_SPOT_Z_CENTROID := V25AD_SUM_Z_COORDS /
	      V25AA_INTENSITY_ACCUM;
          (* Rewind file to the start of the current ray bundle. *)
	  ARC_RECURS_INT_BLOCK_SLOT := V25AJ_SAVE_BEGIN_BLOCK_SLOT;
	  ARW_RECURS_INT_BLOCK_NMBR := V25AK_SAVE_BEGIN_FILE_BLOCK;
          (* Read the principal ray data for the current bundle. *)
	  X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);
	  (* The second pass uses the spot centroid info. just
	     computed.  The sum of the squares of the
	     deviations of the individual intercepts from the
	     overall intercept centroid is obtained for all
	     intercepts in the bundle associated with the present
	     principal ray.*)
	  REPEAT
	    BEGIN
              (* Plot a point in the current viewport.*)
              XDev := ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
		  ARG_SPOT_X_CENTROID;
              YDev := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
		  ARH_SPOT_Y_CENTROID;
              ZDev := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 -
		  ARI_SPOT_Z_CENTROID;
              IF ARD_BLUR_SPHERE_DIAMETER < 1.0E-12 THEN
                BEGIN
                  ROW_INDEX_REAL := ViewportCenterRow [VerticalViewportNum];
                  COLUMN_INDEX_REAL :=
                      ViewportCenterColumn [HorizViewportNum]
                END
              ELSE
                BEGIN
                  ROW_INDEX_REAL :=
                      (-1.0 * YDev
                      * 2.0 / ARD_BLUR_SPHERE_DIAMETER) *
                      RowsInViewportRadius +
                      ViewportCenterRow [VerticalViewportNum];
                  COLUMN_INDEX_REAL :=
                      (-1.0 * XDev
                      * 2.0 / ARD_BLUR_SPHERE_DIAMETER) *
                      ColumnsInViewportRadius +
                      ViewportCenterColumn [HorizViewportNum]
                END;
              IF (COLUMN_INDEX_REAL < -32768.0)
                  OR (COLUMN_INDEX_REAL > 32767.0)
                  OR (ROW_INDEX_REAL < -32768.0)
                  OR (ROW_INDEX_REAL > 32767.0) THEN
                BEGIN
                  ColumnAndRowOK := FALSE;
                  ColumnAndRowOnScreen := FALSE
                END
              ELSE
                BEGIN
                  ColumnIndex := TRUNC (COLUMN_INDEX_REAL);
                  RowIndex := TRUNC (ROW_INDEX_REAL);
                  ColumnAndRowOK := TRUE;
                  IF (ColumnIndex < 1)
	              OR (ColumnIndex > RasterColumns)
	              OR (RowIndex < 1)
	              OR (RowIndex > RasterRows) THEN
	            ColumnAndRowOnScreen := FALSE
                  ELSE
                    ColumnAndRowOnScreen := TRUE
                END;

	      IF ColumnAndRowOnScreen THEN
                BEGIN
	          GraphicsOutputForm.Canvas.Pixels [ColumnIndex, RowIndex] :=
                      clBlack;
	          LADSBitmap.Canvas.Pixels [ColumnIndex, RowIndex] :=
                      clBlack
                END;
(*  	      TempString := LastAccumIntensityString;
              GraphicsOutputForm.Font.Color := clWhite;
	      LADSBitmap.Canvas.TextOut ((10 + SpotAccumPixelPosition),
                  (RasterRows - 30), TempString);
              GraphicsOutputForm.Font.Color := clBlack;
	      Str (ARY_ACCUM_FINAL_INTENSITY:9:2, TempString);
	      LADSBitmap.Canvas.TextOut ((10 + SpotAccumPixelPosition),
                  (RasterRows - 30), TempString);
	      LastAccumIntensityString := TempString;*)

	      V25AP_SPOT_RADIUS_SQUARED :=
                  Sqr (XDev) + Sqr (YDev) + Sqr (ZDev);
              SpotDiameterTest := 2.0 * Sqrt (V25AP_SPOT_RADIUS_SQUARED);
              IF SpotDiameterTest > FullSpotDiameter THEN
                FullSpotDiameter := SpotDiameterTest;
	      V25AH_DEVIATION_SQUARED_ACCUM :=
		  V25AH_DEVIATION_SQUARED_ACCUM +
		  V25AP_SPOT_RADIUS_SQUARED *
		  Sqr (ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY);
	      IF (ARC_RECURS_INT_BLOCK_SLOT = V25AL_SAVE_END_BLOCK_SLOT)
		  AND (ARW_RECURS_INT_BLOCK_NMBR =
		  V25AM_SAVE_END_FILE_BLOCK) THEN
		V25AO_END_OF_SECOND_PASS := TRUE
	      ELSE
		X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
	    END
	  UNTIL
	    V25AO_END_OF_SECOND_PASS;
          (* Compute the RMS spot diameter for the current bundle. *)
	  ARF_RMS_SPOT_DIAMETER :=
	      2 * (SQRT (V25AH_DEVIATION_SQUARED_ACCUM /
	      V25AA_INTENSITY_ACCUM));
          (* Display coordinates of spot centroid. *)
          PrintX := Round (ViewportCenterColumn [HorizViewportNum] -
              1.7 * ColumnsInViewportRadius);
          PrintY := Round (ViewportCenterRow [VerticalViewportNum] -
              1.7 * RowsInViewportRadius);
          (* LADSBitmap.Canvas.MoveTo (PrintX, PrintY);*)
          (* Determine whether or not to display the spot centroid
          deflection data in angular form.  This determination depends on
          the z-coordinate of the image surface.  If the z-coordinate of
          the image surface is greater than or equal to 1E9 units, the x
          and y spot centroid deflection values will be converted to
          angular measure. *)
          IF Abs (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
              ZBQ_VERTEX_Z) >= 1.0E9 THEN
            DisplayAngles := TRUE
          ELSE
            DisplayAngles := FALSE;
          IF DisplayAngles THEN
            BEGIN
              TestValue :=
                  (abs (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
                  ZBQ_VERTEX_Z) - abs (ARI_SPOT_Z_CENTROID));
              IF abs (TestValue) > 1.0E-10 THEN
                Yaw := Arctan (ARG_SPOT_X_CENTROID / TestValue)
              ELSE
              IF ARG_SPOT_X_CENTROID >= 0.0 THEN
                Yaw := pi / 2.0
              ELSE
                Yaw := -pi / 2.0;
              IF Abs (Yaw) < 1.0E-6 THEN
                BEGIN
                  TempString := Chr (235) + 'X =    0.000' + Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
              ELSE
              IF Abs (Yaw) < (Pi / 180.0) THEN
                BEGIN
                  Yaw := Yaw * 1000.0;
                  Str (Yaw:7:3, TempString);
                  TempString := Chr (235) + 'X = ' + TempString +
                      ' mrad';
                  GraphicsOutputForm.Canvas.TextOut(PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
              ELSE
                BEGIN
                  Yaw := Yaw * 180.0 / Pi;
                  Str (Yaw:8:3, TempString);
                  TempString := Chr (235) + 'X = ' + TempString +
                      Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                     (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END;
              PrintY := PrintY + 10;
              (*LADSBitmap.Canvas.MoveTo (PrintX, (PrintY + 10));*)
              IF abs (TestValue) > 1.0E-10 THEN
                Pitch := Arctan (ARH_SPOT_Y_CENTROID / TestValue)
              ELSE
              IF ARH_SPOT_Y_CENTROID >= 0.0 THEN
                Pitch := pi / 2.0
              ELSE
                Pitch := -pi / 2.0;
              IF Abs (Pitch) < 1.0E-6 THEN
                BEGIN
                  TempString := Chr (235) + 'Y =    0.000' + Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
              ELSE
              IF Abs (Pitch) < (Pi / 180.0) THEN
                BEGIN
                  Pitch := Pitch * 1000.0;
                  Str (Pitch:7:3, TempString);
                  TempString := Chr (235) + 'Y = ' + TempString +
                      ' mrad';
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
              ELSE
                BEGIN
                  Pitch := Pitch * 180.0 / Pi;
                  Str (Pitch:8:3, TempString);
                  TempString := Chr (235) + 'Y = ' + TempString +
                      Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
            END
          ELSE
            BEGIN
              IF Abs (ARG_SPOT_X_CENTROID) < 1.0E-10 THEN
                TempString := '    0.0'
              ELSE
              IF Abs (ARG_SPOT_X_CENTROID) >= 10000.0 THEN
                Str (ARG_SPOT_X_CENTROID:12, TempString)
              ELSE
                Str (ARG_SPOT_X_CENTROID:12:6, TempString);
              TempString := Chr (235) + 'X = ' + TempString;
              GraphicsOutputForm.Canvas.TextOut (PrintX, PrintY, TempString);
              LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString);
              PrintY := PrintY + 10;
              (*MoveTo (PrintX, (PrintY + 10));*)
              IF Abs (ARH_SPOT_Y_CENTROID) < 1.0E-10 THEN
                TempString := '    0.0'
              ELSE
              IF Abs (ARH_SPOT_Y_CENTROID) >= 10000.0 THEN
                Str (ARH_SPOT_Y_CENTROID:12, TempString)
              ELSE
                Str (ARH_SPOT_Y_CENTROID:12:6, TempString);
              TempString := Chr (235) + 'Y = ' + TempString;
              GraphicsOutputForm.Canvas.TextOut (PrintX, PrintY, TempString);
              LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
            END;
          (* Display full and RMS spot diameters in current viewport.*)
          PrintX := Round (ViewportCenterColumn [HorizViewportNum] -
              1.7 * ColumnsInViewportRadius);
          PrintY := Round (ViewportCenterRow [VerticalViewportNum] +
              1.7 * RowsInViewportRadius);
          (*MoveTo (PrintX, PrintY);*)
          IF DisplayAngles THEN
            BEGIN
              FullSpotAngularWidthRad :=
                  2.0 * ArcTan (0.5 * FullSpotDiameter * 1.0E-10);
              RMSSpotAngularWidthRad :=
                  2.0 * ArcTan (0.5 * ARF_RMS_SPOT_DIAMETER * 1.0E-10);
              IF FullSpotAngularWidth < 1.0E-6 THEN
                BEGIN
                  TempString := ' OD =    0.000' + Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  PrintY := PrintY + 10;
                  (*MoveTo (PrintX, (PrintY + 10));*)
                  TempString := 'RMS =    0.000' + Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
              ELSE
              IF FullSpotAngularWidthRad < (Pi / 180.0) THEN
                BEGIN
                  FullSpotAngularWidthRad :=
                      FullSpotAngularWidthRad * 1000.0;
                  Str (FullSpotAngularWidthRad:7:3, TempString);
                  TempString := ' OD = ' + TempString +
                      ' mrad';
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  PrintY := PrintY + 10;
                  (*MoveTo (PrintX, (PrintY + 10));*)
                  RMSSpotAngularWidthRad :=
                      RMSSpotAngularWidthRad * 1000.0;
                  Str (RMSSpotAngularWidthRad:7:3, TempString);
                  TempString := 'RMS = ' + TempString +
                      ' mrad';
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
                END
              ELSE
                BEGIN
                  FullSpotAngularWidth :=
                      FullSpotAngularWidthRad * 180.0 / Pi;
                  Str (FullSpotAngularWidth:8:3, TempString);
                  TempString := ' OD = ' + TempString +
                      Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  PrintY := PrintY + 10;
                  (*MoveTo (PrintX, (PrintY + 10));*)
                  RMSSpotAngularWidth :=
                      RMSSpotAngularWidthRad * 180.0 / Pi;
                  Str (RMSSpotAngularWidth:8:3, TempString);
                  TempString := 'RMS = ' + TempString +
                      Chr (248);
                  GraphicsOutputForm.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                  LADSBitmap.Canvas.TextOut
                      (PrintX, PrintY, TempString);
                END
            END
          ELSE
            BEGIN
              Str (FullSpotDiameter:8:3, TempString);
              TempString := ' OD = '+ TempString;
              GraphicsOutputForm.Canvas.TextOut (PrintX, PrintY, TempString);
              LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString);
              PrintY := PrintY + 10;
              (*MoveTo (PrintX, (PrintY + 10));*)
              Str (ARF_RMS_SPOT_DIAMETER:8:3, TempString);
              TempString := 'RMS = ' + TempString;
              GraphicsOutputForm.Canvas.TextOut (PrintX, PrintY, TempString);
              LADSBitmap.Canvas.TextOut (PrintX, PrintY, TempString)
            END
        END
      ELSE
	BEGIN
	  ARD_BLUR_SPHERE_DIAMETER := 1.0E20;
	  ARF_RMS_SPOT_DIAMETER := 1.0E20
	END;
      IF (I <= ARB_TOTAL_RECURS_INTERCEPTS) THEN
	BEGIN
          (* Read the principal ray associated with the next bundle, and
             store its file address and slot. *)
	  X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors);
	  V25AJ_SAVE_BEGIN_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT;
	  V25AK_SAVE_BEGIN_FILE_BLOCK := ARW_RECURS_INT_BLOCK_NMBR
	END;
      HorizViewportNum := HorizViewportNum + 1;
      IF HorizViewportNum > MaxHorizontalViewports THEN
        BEGIN
          HorizViewportNum := 1;
          VerticalViewportNum := VerticalViewportNum + 1
        END
    END
  UNTIL (I > ARB_TOTAL_RECURS_INTERCEPTS)

END;




(**  V2530_INITIALIZE_1_SPOT_DIAGRAM  *****************************************
******************************************************************************)

PROCEDURE V2530_INITIALIZE_1_SPOT_DIAGRAM;

  VAR
      x1            : INTEGER;
      y1            : INTEGER;
      x2            : INTEGER;
      y2            : INTEGER;

      TempString    : STRING;

BEGIN

  (* Draw a horizontal line segment that represents the viewport diameter. *)

  x1 := Round (RasterCenterColumn - ColumnsInRasterRadius);
  y1 := Round (RasterCenterRow + RowsInRasterRadius) +
      Round (0.125 * RowsInRasterRadius);
  x2 := Round (RasterCenterColumn + ColumnsInRasterRadius);
  y2 := Round (RasterCenterRow + RowsInRasterRadius) +
      Round (0.125 * RowsInRasterRadius);

  LADSBitmap.Canvas.MoveTo (x1, y1);
  LADSBitmap.Canvas.LineTo (x2, y2);

  (* Draw short vertical line segments at the left and right ends of the
     horizontal line segment.*)

  y1 := Round (RasterCenterRow + RowsInRasterRadius) +
      Round (0.105 * RowsInRasterRadius);
  y2 := Round (RasterCenterRow + RowsInRasterRadius) +
      Round (0.145 * RowsInRasterRadius);

  LADSBitmap.Canvas.MoveTo (x1, y1);
  LADSBitmap.Canvas.LineTo (x1, y2);

  LADSBitmap.Canvas.MoveTo (x2, y1);
  LADSBitmap.Canvas.LineTo (x2, y2);

  (* Put x-dimension at center of horizontal scale bar. *)

  Str (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER:15, TempString);

  LADSBitmap.Canvas.TextOut
      (Round (RasterCenterColumn), y2, TempString)

END;




(**  V2540_PLOT_SPOTS  ********************************************************
******************************************************************************)

PROCEDURE V2540_PLOT_SPOTS;

  VAR
      I                      : INTEGER;

      XDev                   : DOUBLE;
      YDev                   : DOUBLE;
      ZDev                   : DOUBLE;
      ROW_INDEX_REAL         : DOUBLE;
      COLUMN_INDEX_REAL      : DOUBLE;

BEGIN

  I := 1;

  ARC_RECURS_INT_BLOCK_SLOT := 1;
  ARW_RECURS_INT_BLOCK_NMBR := 0;

  X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);

  V25AB_SUM_X_COORDS := 0;
  V25AC_SUM_Y_COORDS := 0;
  V25AD_SUM_Z_COORDS := 0;
  V25AA_INTENSITY_ACCUM := 0.0;
  V25AN_END_OF_FIRST_PASS := FALSE;

  (* The first pass sums the intercept coordinates and intensities
     of all rays in the bundle. *)

  REPEAT
    BEGIN
      V25AB_SUM_X_COORDS := V25AB_SUM_X_COORDS +
	  ZSA_SURFACE_INTERCEPTS.ZSE_X1 *
	  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
      V25AC_SUM_Y_COORDS := V25AC_SUM_Y_COORDS +
	  ZSA_SURFACE_INTERCEPTS.ZSF_Y1 *
	  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
      V25AD_SUM_Z_COORDS := V25AD_SUM_Z_COORDS +
	  ZSA_SURFACE_INTERCEPTS.ZSG_Z1 *
	  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
      V25AA_INTENSITY_ACCUM := V25AA_INTENSITY_ACCUM +
	  ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
      IF I < ARB_TOTAL_RECURS_INTERCEPTS THEN
	BEGIN
	  I := I + 1;
	  X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors)
	END
      ELSE
	V25AN_END_OF_FIRST_PASS := TRUE
    END
  UNTIL
    V25AN_END_OF_FIRST_PASS;

  (* START SECOND PASS *)

  IF V25AA_INTENSITY_ACCUM > 0.0 THEN
    BEGIN
      V25AO_END_OF_SECOND_PASS := FALSE;
      (* Compute centroid location of intensity-weighted spot pattern. *)
      ARG_SPOT_X_CENTROID := V25AB_SUM_X_COORDS /
	  V25AA_INTENSITY_ACCUM;
      ARH_SPOT_Y_CENTROID := V25AC_SUM_Y_COORDS /
	  V25AA_INTENSITY_ACCUM;
      ARI_SPOT_Z_CENTROID := V25AD_SUM_Z_COORDS /
	  V25AA_INTENSITY_ACCUM;
      I := 1;
      ARC_RECURS_INT_BLOCK_SLOT := 1;
      ARW_RECURS_INT_BLOCK_NMBR := 0;
      X37_SEEK_AND_READ_RECURSIVE_INTRCPT (NoErrors);
      (* The second pass uses the spot centroid info. just
	 computed.  The sum of the squares of the
	 deviations of the individual intercepts from the
	 overall intercept centroid is obtained for all
	 intercepts in the bundle. *)
      REPEAT
	BEGIN
          (* Plot a point in the current viewport.*)
          XDev := ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
	      ARG_SPOT_X_CENTROID;
          YDev := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
	      ARH_SPOT_Y_CENTROID;
          ZDev := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 -
	      ARI_SPOT_Z_CENTROID;
          ROW_INDEX_REAL :=
              (-1.0 * YDev
              * 2.0 / ZFA_OPTION.ZGL_VIEWPORT_DIAMETER) *
              RowsInRasterRadius + RasterCenterRow;
          COLUMN_INDEX_REAL :=
              (-1.0 * XDev
              * 2.0 / ZFA_OPTION.ZGL_VIEWPORT_DIAMETER) *
              ColumnsInRasterRadius + RasterCenterColumn;
          IF (COLUMN_INDEX_REAL < -32768.0)
              OR (COLUMN_INDEX_REAL > 32767.0)
              OR (ROW_INDEX_REAL < -32768.0)
              OR (ROW_INDEX_REAL > 32767.0) THEN
            BEGIN
              ColumnAndRowOK := FALSE;
              ColumnAndRowOnScreen := FALSE
            END
          ELSE
            BEGIN
              ColumnIndex := TRUNC (COLUMN_INDEX_REAL);
              RowIndex := TRUNC (ROW_INDEX_REAL);
              ColumnAndRowOK := TRUE;
              IF (ColumnIndex < 1)
	          OR (ColumnIndex > RasterColumns)
	          OR (RowIndex < 1)
	          OR (RowIndex > RasterRows) THEN
	        ColumnAndRowOnScreen := FALSE
              ELSE
                ColumnAndRowOnScreen := TRUE
            END;
	  IF ColumnAndRowOnScreen THEN
	    LADSBitmap.Canvas.Pixels [ColumnIndex, RowIndex] := clBlack;
	  IF I < ARB_TOTAL_RECURS_INTERCEPTS THEN
	    BEGIN
	      I := I + 1;
	      X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors)
	    END
	  ELSE
	    V25AO_END_OF_SECOND_PASS := TRUE
	END
      UNTIL
	V25AO_END_OF_SECOND_PASS
    END

END;




(**  V25_PRODUCE_SPOT_DIAGRAM  ************************************************
*                                                                             *
*  If more than one "principal ray" exists, then a separate spot diagram will *
*  be generated by this routine for each separate ray bundle surrounding each *
*  "principal ray."  Each spot diagram will appear in a separate viewport.    *
*                                                                             *
******************************************************************************)


BEGIN

  V2505_DETECT_MULTIPLE_PRINCIPAL_RAYS;

  IF MultiplePrincipalRaysExist THEN
    BEGIN
      V2510_INITIALIZE_FOR_GRAPHICS;
      V2515_SET_UP_SPOT_DIAGRAM;
      V2520_PLOT_SPOTS
    END
  ELSE
    BEGIN
      V2530_INITIALIZE_1_SPOT_DIAGRAM;
      V2540_PLOT_SPOTS
    END

END;




(**  V30_DISPLAY_INTENSITY_HISTOGRAM  *****************************************
******************************************************************************)


PROCEDURE V30_DISPLAY_INTENSITY_HISTOGRAM
   (DisplayStatus            : DisplayState;
    HistogramType            : HistogramVarieties;
    EnergyBuckets            : INTEGER;
    VAR ImageUniformityMerit : DOUBLE);

  CONST
      MaxEnergyBuckets            = 40;

  VAR
      I                           : INTEGER;
      BUCKET			  : INTEGER;

      LongBucket                  : LONGINT;

      V30AG_SPACE_LINE		  : STRING;
      V30AH_SCREEN		  : ARRAY [1..(MaxEnergyBuckets + 3)] OF STRING;
      TEMP_STRING		  : STRING;
      HOLD_STRING		  : STRING;

      AREA_LARGEST_RING		  : DOUBLE;
      AREA_THIS_RING		  : DOUBLE;
      V30AF_BIGGEST_BUCKET	  : DOUBLE;
      V30AB_INTENSITY		  : ARRAY [1..MaxEnergyBuckets]
					OF DOUBLE;
      V30AA_MAX_IMAGE_RADIUS	  : DOUBLE;
      V30AC_MAX_IMAGE_RAD_SQR	  : DOUBLE;
      V30AE_NORMALIZED_INTENSITY  : DOUBLE;
      RingOuterEdge               : DOUBLE;
      SumNormalizedIntensity      : DOUBLE;
      AverageNormalizedIntensity  : DOUBLE;

      TEMP_FILE			  : TEXT;

(**  PrepareScreenOutputArray  ************************************************
******************************************************************************)

PROCEDURE PrepareScreenOutputArray;

  VAR
      I				  : INTEGER;
      COL			  : INTEGER;
      ROW			  : INTEGER;
      BUCKET			  : INTEGER;

BEGIN

  (* The following code places data in the screen output array
     in preparation for displaying the actual intensity histogram data. *)

(*V30AG_SPACE_LINE := '                                        ';
  V30AG_SPACE_LINE := CONCAT (V30AG_SPACE_LINE, V30AG_SPACE_LINE);

  FOR ROW := 1 TO 23 DO
    V30AH_SCREEN [ROW] := V30AG_SPACE_LINE;

  IF HistogramType = OneDimensHistogram THEN
    V30AH_SCREEN [1] :=
	'  IMAGE INTENSITY HISTOGRAM BY EQUAL WIDTH ANNULAR RING'
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [1] :=
	'  IMAGE INTENSITY HISTOGRAM BY EQUAL AREA ANNULAR RING'
  ELSE
  IF HistogramType = TwoDimensEqualRadiusHistogram THEN
    V30AH_SCREEN [1] :=
	'  IMAGE INTENSITY HISTOGRAM BY EQUAL RADIUS ANNULAR RING';

  V30AH_SCREEN [2] := '  1.0 +';
  SetLength (V30AH_SCREEN [2], 59);
  V30AH_SCREEN [2] := CONCAT (V30AH_SCREEN [2], '-- NORMALIZED --');

  V30AH_SCREEN [3, 7] :=  '|';
  SetLength (V30AH_SCREEN [3], 53);
  V30AH_SCREEN [3] := CONCAT (V30AH_SCREEN [3], 'RING  RADIUS  INTENSITY');

  V30AH_SCREEN [4] := '  0.9 +';
  SetLength (V30AH_SCREEN [4], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [4] := CONCAT (V30AH_SCREEN [4], '1    0.025')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [4] := CONCAT (V30AH_SCREEN [4], '1    0.158');

  V30AH_SCREEN [5, 7] :=  '|';
  SetLength (V30AH_SCREEN [5], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [5] := CONCAT (V30AH_SCREEN [5], '2    0.075')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [5] := CONCAT (V30AH_SCREEN [5], '2    0.274');

  V30AH_SCREEN [6] := '  0.8 +';
  SetLength (V30AH_SCREEN [6], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [6] := CONCAT (V30AH_SCREEN [6], '3    0.125')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [6] := CONCAT (V30AH_SCREEN [6], '3    0.354');

  V30AH_SCREEN [7, 7] :=  '|';
  SetLength (V30AH_SCREEN [7], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [7] := CONCAT (V30AH_SCREEN [7], '4    0.175')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [7] := CONCAT (V30AH_SCREEN [7], '4    0.418');

  V30AH_SCREEN [8] := '  0.7 +';
  SetLength (V30AH_SCREEN [8], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [8] := CONCAT (V30AH_SCREEN [8], '5    0.225')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [8] := CONCAT (V30AH_SCREEN [8], '5    0.474');

  V30AH_SCREEN [9, 7] :=  '|';
  SetLength (V30AH_SCREEN [9], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [9] := CONCAT (V30AH_SCREEN [9], '6    0.275')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [9] := CONCAT (V30AH_SCREEN [9], '6    0.524');

  V30AH_SCREEN [10] := '  0.6 +';
  SetLength (V30AH_SCREEN [10], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [10] := CONCAT (V30AH_SCREEN [10], '7    0.325')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [10] := CONCAT (V30AH_SCREEN [10], '7    0.570');

  V30AH_SCREEN [11, 7] :=  '|';
  SetLength (V30AH_SCREEN [11], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [11] := CONCAT (V30AH_SCREEN [11], '8    0.375')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [11] := CONCAT (V30AH_SCREEN [11], '8    0.612');

  V30AH_SCREEN [12] := '  0.5 +';
  SetLength (V30AH_SCREEN [12], 55);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [12] := CONCAT (V30AH_SCREEN [12], '9    0.425')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [12] := CONCAT (V30AH_SCREEN [12], '9    0.652');

  V30AH_SCREEN [13] := 'INTENS|';
  SetLength (V30AH_SCREEN [13], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [13] := CONCAT (V30AH_SCREEN [13], '10    0.475')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [13] := CONCAT (V30AH_SCREEN [13], '10    0.689');

  V30AH_SCREEN [14] := '  0.4 +';
  SetLength (V30AH_SCREEN [14], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [14] := CONCAT (V30AH_SCREEN [14], '11    0.525')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [14] := CONCAT (V30AH_SCREEN [14], '11    0.725');

  V30AH_SCREEN [15, 7] :=  '|';
  SetLength (V30AH_SCREEN [15], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [15] := CONCAT (V30AH_SCREEN [15], '12    0.575')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [15] := CONCAT (V30AH_SCREEN [15], '12    0.758');

  V30AH_SCREEN [16] := '  0.3 +';
  SetLength (V30AH_SCREEN [16], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [16] := CONCAT (V30AH_SCREEN [16], '13    0.625')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [16] := CONCAT (V30AH_SCREEN [16], '13    0.791');

  V30AH_SCREEN [17, 7] :=  '|';
  SetLength (V30AH_SCREEN [17], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [17] := CONCAT (V30AH_SCREEN [17], '14    0.675')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [17] := CONCAT (V30AH_SCREEN [17], '14    0.822');

  V30AH_SCREEN [18] := '  0.2 +';
  SetLength (V30AH_SCREEN [18], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [18] := CONCAT (V30AH_SCREEN [18], '15    0.725')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [18] := CONCAT (V30AH_SCREEN [18], '15    0.851');

  V30AH_SCREEN [19, 7] :=  '|';
  SetLength (V30AH_SCREEN [19], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [19] := CONCAT (V30AH_SCREEN [19], '16    0.775')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [19] := CONCAT (V30AH_SCREEN [19], '16    0.880');

  V30AH_SCREEN [20] := '  0.1 +';
  SetLength (V30AH_SCREEN [20], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [20] := CONCAT (V30AH_SCREEN [20], '17    0.825')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [20] := CONCAT (V30AH_SCREEN [20], '17    0.908');

  V30AH_SCREEN [21, 7] :=  '|';
  SetLength (V30AH_SCREEN [21], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [21] := CONCAT (V30AH_SCREEN [21], '18    0.875')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [21] := CONCAT (V30AH_SCREEN [21], '18    0.935');

  V30AH_SCREEN [22] := CONCAT ('  0.0 +---+---+---+---+---+---+---+---+',
      '---+---+');
  SetLength (V30AH_SCREEN [22], 54);
  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [22] := CONCAT (V30AH_SCREEN [22], '19    0.925')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [22] := CONCAT (V30AH_SCREEN [22], '19    0.962');

  IF (HistogramType = OneDimensHistogram)
      OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
    V30AH_SCREEN [23] := CONCAT ('     RADIUS  .2  .3  .4  .5  .6  .7  .8',
	'  .9  1.0      20    0.975')
  ELSE
  IF HistogramType = TwoDimensEqualAreaHistogram THEN
    V30AH_SCREEN [23] := CONCAT ('     RING 2   4   6   8  10  12  14  16',
	'  18  20       20    0.987');

  FOR BUCKET := 1 TO EnergyBuckets DO
    BEGIN
      COL := 6 + (2 * BUCKET);
      ROW := ROUND ((V30AB_INTENSITY [BUCKET] / V30AF_BIGGEST_BUCKET) *
	  EnergyBuckets);
      IF ROW > EnergyBuckets THEN
	ROW := EnergyBuckets;
      ROW := 21 - ROW;
      FOR I := 20 DOWNTO ROW DO
	V30AH_SCREEN [(I + 1), (COL + 1)] := '*'
    END;*)

  (*STR (HistogramFileCount, TEMP_STRING);*)

  (*HistogramFileCount := HistogramFileCount + 1;*)

  (*HOLD_STRING := CONCAT ('HIST', TEMP_STRING, '.TXT');*)

  (*ASSIGN (TEMP_FILE, HOLD_STRING);

  REWRITE (TEMP_FILE);

  CommandIOMemo.IOHistory.Lines.add (V30AH_SCREEN [1]);
  CommandIOMemo.IOHistory.Lines.add (V30AH_SCREEN [2]);
  CommandIOMemo.IOHistory.Lines.add (V30AH_SCREEN [3]);

  WRITELN (TEMP_FILE, V30AH_SCREEN [1]);
  WRITELN (TEMP_FILE, V30AH_SCREEN [2]);
  WRITELN (TEMP_FILE, V30AH_SCREEN [3]);

  FOR BUCKET := 1 TO EnergyBuckets DO
    BEGIN
      V30AE_NORMALIZED_INTENSITY :=
	  V30AB_INTENSITY [BUCKET] / V30AF_BIGGEST_BUCKET;
      Str (V30AE_NORMALIZED_INTENSITY:6:3, TEMP_STRING);
      CommandIOMemo.IOHistory.Lines.add (V30AH_SCREEN [(BUCKET + 3)] +
          TEMP_STRING);
      WRITELN (TEMP_FILE, V30AH_SCREEN [(BUCKET + 3)] + TEMP_STRING)
    END;

  WRITELN (TEMP_FILE);
  WRITELN (TEMP_FILE,
      '     Initial intensity: ', ARX_ACCUM_INITIAL_INTENSITY:9:2);
  WRITELN (TEMP_FILE,
      '     Within viewport:   ', ARY_ACCUM_FINAL_INTENSITY:9:2);
  WRITELN (TEMP_FILE,
      '     Total throughput:    ', (100.0 * (ARY_ACCUM_FINAL_INTENSITY /
      ARX_ACCUM_INITIAL_INTENSITY)):7:2, '%');*)

  (*HistogramForm.Visible := TRUE;*)
  (*HistogramForm.IntensityHistograms.Enabled := TRUE;*)
  (*HistogramForm.IntensityHistograms.GraphType := 9;*) (* Scatter diagram *)
  (*HistogramForm.IntensityHistograms.DataReset := 9;*) (* Reset all data *)
  (*HistogramForm.IntensityHistograms.NumPoints := EnergyBuckets;*)
  (*HistogramForm.IntensityHistograms.NumSets := 1;*) (* One data set *)
  (*HistogramForm.IntensityHistograms.DrawStyle := 0;*) (* Monochrome *)

  (*WRITELN (TEMP_FILE);
  WRITELN (TEMP_FILE, '"Image Intensity Histogram"');
  WRITELN (TEMP_FILE, '"Ring Outer Radius"');
  WRITELN (TEMP_FILE, '"Normalized Intensity"');
  FOR BUCKET := 1 TO EnergyBuckets DO
    BEGIN
      IF ZFA_OPTION.EnableLinearIntensityHist
          OR ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST THEN
        RingOuterEdge := (BUCKET / EnergyBuckets)
      ELSE
        RingOuterEdge := Sqrt (BUCKET / EnergyBuckets);
      HistogramForm.IntensityHistograms.ThisPoint := BUCKET;
      HistogramForm.IntensityHistograms.XPosData := RingOuterEdge;
      HistogramForm.IntensityHistograms.GraphData :=
          (V30AB_INTENSITY [BUCKET] / V30AF_BIGGEST_BUCKET);
      WRITELN (TEMP_FILE, RingOuterEdge:7:4, ' ',
          (V30AB_INTENSITY [BUCKET] / V30AF_BIGGEST_BUCKET):7:4)
    END;

  HistogramForm.IntensityHistograms.DrawMode := 2;*) (* Drawing enabled *)

  (*WRITELN (TEMP_FILE);
  CLOSE (TEMP_FILE);

  CommandIOMemo.IOHistory.Lines.add
      ('HISTOGRAM WRITTEN TO FILE ' + HOLD_STRING + '.');

  Q980_REQUEST_MORE_OUTPUT;

  HistogramForm.Visible := FALSE*)

END;




(**  V30_DISPLAY_INTENSITY_HISTOGRAM  *****************************************
******************************************************************************)


BEGIN

  IF ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 1.0E-12 THEN
    IF (HistogramType = OneDimensHistogram)
        OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
      V30AA_MAX_IMAGE_RADIUS := ZFA_OPTION.ZGL_VIEWPORT_DIAMETER * 0.5
    ELSE
    IF HistogramType = TwoDimensEqualAreaHistogram THEN
      V30AC_MAX_IMAGE_RAD_SQR := ZFA_OPTION.ZGL_VIEWPORT_DIAMETER *
	  ZFA_OPTION.ZGL_VIEWPORT_DIAMETER * 0.25
  ELSE
    IF (HistogramType = OneDimensHistogram)
        OR (HistogramType = TwoDimensEqualRadiusHistogram) THEN
      V30AA_MAX_IMAGE_RADIUS := ARN_MAX_IMAGE_DIAMETER * 0.5
    ELSE
    IF HistogramType = TwoDimensEqualAreaHistogram THEN
      V30AC_MAX_IMAGE_RAD_SQR := (ARN_MAX_IMAGE_DIAMETER *
	  ARN_MAX_IMAGE_DIAMETER) * 0.25;

  FOR I := 1 TO EnergyBuckets DO
    V30AB_INTENSITY [I] := 0.0;

  ARC_RECURS_INT_BLOCK_SLOT := 1;
  ARW_RECURS_INT_BLOCK_NMBR := 0;
  
  X16_REWIND_AND_READ_RECURSIVE_INTRCPT (NoErrors);
  
  FOR I := 1 TO ARB_TOTAL_RECURS_INTERCEPTS DO
    BEGIN
      (*IF (HistogramType = OneDimensHistogram) THEN
	LongBucket :=
	    TRUNC ((SQRT (SQR (ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
	    (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCV_APERTURE_POSITION_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBM_VERTEX_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBN_VERTEX_DELTA_X)))) /
	    V30AA_MAX_IMAGE_RADIUS) * EnergyBuckets) + 1
      ELSE*)
      IF (HistogramType = TwoDimensEqualRadiusHistogram)
          OR (HistogramType = OneDimensHistogram) THEN
	LongBucket :=
	    TRUNC ((SQRT (SQR (ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
	    (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCV_APERTURE_POSITION_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBM_VERTEX_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBN_VERTEX_DELTA_X))) +
	    SQR (ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
	    (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCW_APERTURE_POSITION_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBO_VERTEX_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBP_VERTEX_DELTA_Y)))) /
	    V30AA_MAX_IMAGE_RADIUS) * EnergyBuckets) + 1
      ELSE
      IF HistogramType = TwoDimensEqualAreaHistogram THEN
	LongBucket :=
	    TRUNC (((SQR (ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
	    (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCV_APERTURE_POSITION_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBM_VERTEX_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBN_VERTEX_DELTA_X))) +
	    SQR (ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
	    (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCW_APERTURE_POSITION_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBO_VERTEX_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZBP_VERTEX_DELTA_Y)))) /
	    (V30AC_MAX_IMAGE_RAD_SQR)) * EnergyBuckets) + 1;
      IF LongBucket <= EnergyBuckets THEN
        BEGIN
	  BUCKET := LongBucket;
	  V30AB_INTENSITY [BUCKET] := V30AB_INTENSITY [BUCKET] +
	      ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY
	END;
      X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors)
    END;

  (* Normalize contents of equal width radial buckets *)
  IF HistogramType = TwoDimensEqualRadiusHistogram THEN
    BEGIN
      AREA_LARGEST_RING := ((2.0 * EnergyBuckets) - 1.0) /
	  (SQR (EnergyBuckets));
      FOR BUCKET := 1 TO EnergyBuckets DO
	BEGIN
	  AREA_THIS_RING := ((2.0 * BUCKET) - 1.0) /
	      (SQR (EnergyBuckets));
	  V30AB_INTENSITY [BUCKET] := V30AB_INTENSITY [BUCKET] *
	      AREA_LARGEST_RING / AREA_THIS_RING
	END
    END;

  V30AF_BIGGEST_BUCKET := 0.0;

  FOR BUCKET := 1 TO EnergyBuckets DO
    BEGIN
      IF V30AB_INTENSITY [BUCKET] > V30AF_BIGGEST_BUCKET THEN
	V30AF_BIGGEST_BUCKET := V30AB_INTENSITY [BUCKET]
    END;

  IF DisplayStatus = DisplayDisabled THEN
    BEGIN
      (* Find average normalized intensity. *)
      SumNormalizedIntensity := 0.0;
      FOR BUCKET := 1 TO EnergyBuckets DO
        SumNormalizedIntensity := SumNormalizedIntensity +
            (V30AB_INTENSITY [BUCKET] / V30AF_BIGGEST_BUCKET);
      AverageNormalizedIntensity := SumNormalizedIntensity /
          EnergyBuckets;
      ImageUniformityMerit := 1.0 - (AverageNormalizedIntensity *
          exp (EnergyBuckets * ln (ARB_TOTAL_RECURS_INTERCEPTS /
          AAA_TOTAL_RAYS_TO_TRACE)))
    END
  ELSE
    PrepareScreenOutputArray

END;




(**  V35_PRODUCE_SPOT_DIAGRAM_FILE  *******************************************
******************************************************************************)


(*PROCEDURE V35_PRODUCE_SPOT_DIAGRAM_FILE;

  VAR
      V35AA_ONE_BLOCK			   : RECORD CASE INTEGER OF
	1: (V35AD_COORDINATES		   : PACKED ARRAY [1..32] OF RECORD
	      V35AE_X_COORDINATE	   : DOUBLE;
	      V35AF_Y_COORDINATE	   : DOUBLE
	    END);
	2: (V35AG_SPOT_RADIUS		   : DOUBLE;
	    V35AH_VIEWPORT_POSITION_X	   : DOUBLE;
	    V35AI_VIEWPORT_POSITION_Y	   : DOUBLE;
	    V35AJ_COORDINATE_PAIRS	   : INTEGER;
	    V35AK_UNUSED		   : ARRAY [1..3] OF INTEGER;
	    V35AL_FIELD_POSITION_X	   : DOUBLE;
	    V35AM_FIELD_POSITION_Y	   : DOUBLE;
	    V35AN_FIELD_POSITION_Z	   : DOUBLE;
	    V35AO_FIELD_ORIENTATION_ROLL   : DOUBLE;
	    V35AP_FIELD_ORIENTATION_PITCH  : DOUBLE;
	    V35AQ_FIELD_ORIENTATION_YAW	   : DOUBLE;
	    V35AR_WAVELENGTH		   : DOUBLE);
	3: (V35AS_ACCUM_INITIAL_INTENSITY  : DOUBLE;
	    V35AT_ACCUM_FINAL_INTENSITY	   : DOUBLE)
      END;
	
      I					   : INTEGER;
      J					   : INTEGER;
      V35AC_DESIG_SURF			   : INTEGER;
      SaveIOResult                         : INTEGER;
      
      V35AL_TEMP_STRING			   : STRING [30];

      V35AB_SPOT_RADIUS			   : DOUBLE;
      V35BA_X_HOLD			   : DOUBLE;
      V35BB_Y_HOLD			   : DOUBLE;
      V35BC_Z_HOLD			   : DOUBLE;
      V35BD_SPOT_X_CENTROID		   : DOUBLE;
      V35BE_SPOT_Y_CENTROID		   : DOUBLE;
      V35BF_SPOT_Z_CENTROID		   : DOUBLE;
      
      ZAD_PLOT_FILE                        : FILE;

BEGIN
  
  IF ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 1.0E-12 THEN
    V35AB_SPOT_RADIUS := ZFA_OPTION.ZGL_VIEWPORT_DIAMETER / 2
  ELSE
    V35AB_SPOT_RADIUS := ARD_BLUR_SPHERE_DIAMETER / 2;
  
  IF V35AB_SPOT_RADIUS < 1.0E-12 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('COMPUTED DIAMETER OF SPOT AT FINAL (IMAGE) SURFACE = 0.');
      CommandIOMemo.IOHistory.Lines.add
          ('CANNOT PRODUCE SPOT DIAGRAM PLOT FILE DUE TO ZERO DIAMETER.')
    END
  ELSE
    BEGIN
      V35AL_TEMP_STRING := ZFA_OPTION.ZFM_SPOT_DIAGRAM_FILE_NAME;
      ASSIGN (ZAD_PLOT_FILE, V35AL_TEMP_STRING);
      {$I-}
      REWRITE (ZAD_PLOT_FILE, CZBG_CHARS_IN_ONE_BLOCK);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ATTEMPT TO CREATE FILE "' +
	      V35AL_TEMP_STRING + '" FAILED, AT V35.1.');
	  CommandIOMemo.IOHistory.Lines.add
              ('(IORESULT IS: ' + IntToStr (SaveIOResult) + '.)')
	END
      ELSE
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('PRODUCING SPOT DIAGRAM PLOT FILE "' +
	      ZFA_OPTION.ZFM_SPOT_DIAGRAM_FILE_NAME + '"...');
	  V35AA_ONE_BLOCK.V35AG_SPOT_RADIUS := V35AB_SPOT_RADIUS;
	  IF ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 1.0E-12 THEN
	    BEGIN
	      V35AA_ONE_BLOCK.V35AH_VIEWPORT_POSITION_X := ZFA_OPTION.
		  ZGC_VIEWPORT_POSITION_X;
	      V35AA_ONE_BLOCK.V35AI_VIEWPORT_POSITION_Y := ZFA_OPTION.
		  ZGD_VIEWPORT_POSITION_Y
	    END
	  ELSE
	    BEGIN
	      V35AA_ONE_BLOCK.V35AH_VIEWPORT_POSITION_X := 0.0;
	      V35AA_ONE_BLOCK.V35AI_VIEWPORT_POSITION_Y := 0.0
	    END;
	  V35AA_ONE_BLOCK.V35AJ_COORDINATE_PAIRS :=
	      ARB_TOTAL_RECURS_INTERCEPTS;
	  V35AC_DESIG_SURF := ZFA_OPTION.ZGK_DESIGNATED_SURFACE;
	  V35AA_ONE_BLOCK.V35AL_FIELD_POSITION_X :=
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBM_VERTEX_X +
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBN_VERTEX_DELTA_X;
	  V35AA_ONE_BLOCK.V35AM_FIELD_POSITION_Y :=
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBO_VERTEX_Y +
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBP_VERTEX_DELTA_Y;
	  V35AA_ONE_BLOCK.V35AN_FIELD_POSITION_Z :=
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBQ_VERTEX_Z +
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBR_VERTEX_DELTA_Z;
	  IF NOT (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 1.0E-12) THEN
	    BEGIN
	      V35BD_SPOT_X_CENTROID := ARG_SPOT_X_CENTROID;
	      V35BE_SPOT_Y_CENTROID := ARH_SPOT_Y_CENTROID;
	      V35BF_SPOT_Z_CENTROID := ARI_SPOT_Z_CENTROID;
	      IF ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].
		  ZVL_COORDINATE_ROTATION_NEEDED THEN
		BEGIN
		  V35BA_X_HOLD := ARG_SPOT_X_CENTROID;
		  V35BB_Y_HOLD := ARH_SPOT_Y_CENTROID;
		  V35BC_Z_HOLD := ARI_SPOT_Z_CENTROID;
		  V35BD_SPOT_X_CENTROID :=
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVB_T11 *
		      V35BA_X_HOLD +
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVE_T21 *
		      V35BB_Y_HOLD +
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVH_T31 *
		      V35BC_Z_HOLD;
		  V35BE_SPOT_Y_CENTROID :=
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVC_T12 *
		      V35BA_X_HOLD +
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVF_T22 *
		      V35BB_Y_HOLD +
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVI_T32 *
		      V35BC_Z_HOLD;
		  V35BF_SPOT_Z_CENTROID :=
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVD_T13 *
		      V35BA_X_HOLD +
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVG_T23 *
		      V35BB_Y_HOLD +
		      ZVA_ROTATION_MATRIX [V35AC_DESIG_SURF].ZVJ_T33 *
		      V35BC_Z_HOLD;
		  IF ABS (V35BD_SPOT_X_CENTROID) < 1.0E-12 THEN
		    V35BD_SPOT_X_CENTROID := 0.0;
		  IF ABS (V35BE_SPOT_Y_CENTROID) < 1.0E-12 THEN
		    V35BE_SPOT_Y_CENTROID := 0.0;
		  IF ABS (V35BF_SPOT_Z_CENTROID) < 1.0E-12 THEN
		    V35BF_SPOT_Z_CENTROID := 0.0
		END;
	      V35AA_ONE_BLOCK.V35AL_FIELD_POSITION_X :=
		  V35AA_ONE_BLOCK.V35AL_FIELD_POSITION_X +
		  V35BD_SPOT_X_CENTROID;
	      V35AA_ONE_BLOCK.V35AM_FIELD_POSITION_Y :=
		  V35AA_ONE_BLOCK.V35AM_FIELD_POSITION_Y +
		  V35BE_SPOT_Y_CENTROID;
	      V35AA_ONE_BLOCK.V35AN_FIELD_POSITION_Z :=
		  V35AA_ONE_BLOCK.V35AN_FIELD_POSITION_Z +
		  V35BF_SPOT_Z_CENTROID
	    END;
	  V35AA_ONE_BLOCK.V35AO_FIELD_ORIENTATION_ROLL :=
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBS_ROLL +
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBT_DELTA_ROLL;
	  V35AA_ONE_BLOCK.V35AP_FIELD_ORIENTATION_PITCH :=
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBU_PITCH +
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBV_DELTA_PITCH;
	  V35AA_ONE_BLOCK.V35AQ_FIELD_ORIENTATION_YAW :=
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBW_YAW +
	      ZBA_SURFACE [V35AC_DESIG_SURF].ZBX_DELTA_YAW;
          (* The next statement does not work.  AKO_SPECIFIED_WAVELENGTH
             is not defined at this point. *)
  	  (*V35AA_ONE_BLOCK.V35AR_WAVELENGTH := AKO_SPECIFIED_WAVELENGTH;
	  BLOCKWRITE (ZAD_PLOT_FILE, V35AA_ONE_BLOCK, 1);
	  V35AA_ONE_BLOCK.V35AS_ACCUM_INITIAL_INTENSITY :=
	      ARX_ACCUM_INITIAL_INTENSITY;
	  V35AA_ONE_BLOCK.V35AT_ACCUM_FINAL_INTENSITY :=
	      ARY_ACCUM_FINAL_INTENSITY;
	  BLOCKWRITE (ZAD_PLOT_FILE, V35AA_ONE_BLOCK, 1);
	  J := 1;
	  ARC_RECURS_INT_BLOCK_SLOT := 1;
	  ARW_RECURS_INT_BLOCK_NMBR := 0;
	  X16_REWIND_AND_READ_RECURSIVE_INTRCPT (NoErrors);
	  FOR I := 1 TO ARB_TOTAL_RECURS_INTERCEPTS DO
	    BEGIN
	      IF NOT (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 1.0E-12) THEN
		BEGIN
		  V35AA_ONE_BLOCK.V35AD_COORDINATES [J].
		      V35AE_X_COORDINATE :=
		      ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
		      ARG_SPOT_X_CENTROID;
		  V35AA_ONE_BLOCK.V35AD_COORDINATES [J].
		      V35AF_Y_COORDINATE :=
		      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
		      ARH_SPOT_Y_CENTROID
		END
	      ELSE
		BEGIN
		  V35AA_ONE_BLOCK.V35AD_COORDINATES [J].
		      V35AE_X_COORDINATE :=
		      ZSA_SURFACE_INTERCEPTS.ZSE_X1;
		  V35AA_ONE_BLOCK.V35AD_COORDINATES [J].
		      V35AF_Y_COORDINATE :=
		      ZSA_SURFACE_INTERCEPTS.ZSF_Y1
		END;
	      J := J + 1;
	      IF J > 32 THEN
		BEGIN
		  J := 1;
		  BLOCKWRITE (ZAD_PLOT_FILE, V35AA_ONE_BLOCK, 1)
		END;
	      X36_SIMPLE_READ_RECURSIVE_INTRCPT (NoErrors)
	    END;
	  IF J > 1 THEN
	    BLOCKWRITE (ZAD_PLOT_FILE, V35AA_ONE_BLOCK, 1);
	  CLOSE (ZAD_PLOT_FILE)
	END
    END

END;*)




(**  V40_PRODUCE_PSF_FILE  ****************************************************

The procedure can be used for either a 1D scan or a 2D scan of the diffraction
pattern.  Three places in the code need to be changed to make the switch
between 1D and 2D.
******************************************************************************)


PROCEDURE V40_PRODUCE_PSF_FILE;

  CONST
      TwoPi = 6.2831853071795864;

      TotalXTestPointsFor2DScan = 127;  (* These are semi-diameters. *)
      TotalYTestPointsFor2DScan = 127;
      TotalXTestPointsFor1DScan = 1000;
      TotalYTestPointsFor1DScan = 1;

  VAR
      NoErrors                              : BOOLEAN;
      TwoDScanEnabled                       : BOOLEAN;
      Done                                  : BOOLEAN;

      XTestPointCounter                     : INTEGER;
      TotalXTestPoints                      : INTEGER;
      YTestPointCounter                     : INTEGER;
      TotalYTestPoints                      : INTEGER;
      RayCount                              : INTEGER;
      ImageSurface                          : INTEGER;

      AiryDiscDia                           : DOUBLE;
      ProbePointX			    : DOUBLE;
      ProbePointY			    : DOUBLE;
      ProbePointZ			    : DOUBLE;
      SaveProbePointX                       : DOUBLE;
      WorkingWavelengthMicrons		    : DOUBLE;
      Index                                 : DOUBLE;
      ImageHeightMillimeters                : DOUBLE;
      PupilPtToProbePtGeomDist	            : DOUBLE;
      PupilPtToProbePtOptDist               : DOUBLE;
      PupilPtToProbePtXMag	            : DOUBLE;
      PupilPtToProbePtYMag	            : DOUBLE;
      PupilPtToProbePtZMag	            : DOUBLE;
      TestPointIntensity		    : DOUBLE;
      StrehlRatio                           : DOUBLE;
      FractionalPhaseAngleRad               : DOUBLE;
      SumSinePhase                          : DOUBLE;
      SumCosinePhase                        : DOUBLE;
      NormalizingFactor                     : DOUBLE;
      RNE                                   : DOUBLE; (*Rel. ensquared energy*)

      PSFFile                               : TEXT;

      XformOperands                         : TransformationRecord;

BEGIN

  TwoDScanEnabled := TRUE;  (* This statement will eventually be replaced by an
  input command from the user. *)

  IF TwoDScanEnabled THEN
    BEGIN
      TotalXTestPoints := TotalXTestPointsFor2DScan;
      TotalYTestPoints := TotalYTestPointsFor2DScan
    END
  ELSE
    BEGIN
      TotalXTestPoints := TotalXTestPointsFor1DScan;
      TotalYTestPoints := TotalYTestPointsFor1DScan
    END;

  StrehlRatio := 0.0;
  NormalizingFactor := ARO_DIFF_RECORD_COUNT;
  RNE := 0.0;

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add ('Generating point spread function...');
  CommandIOMemo.IOHistory.Lines.add ('');

  (* Compute a best guess estimate of the diameter of the Airy disc, and set
  the "radius" of the PSF probe region to the diameter of the Airy disc.
  This computation is based on the equation D = 0.001 x 2.44 x LAMBDA x f/#,
  where D is the diameter of the Airy disc in millimeters,
  LAMBDA is the wavelength in microns, and f/# is the focal ratio.  The
  focal ratio is computed by dividing the distance from the final OPD
  reference surface to the image surface, by the diameter of the final OPD
  reference surface.

  After computing the diameter of the Airy disc, compare this result to the
  actual size of the blur circle.  If the blur circle is larger than the
  predicted size of the Airy disc, set the radius of the PSF probe region to
  the size of the blur circle. *)

(*AiryDiscDia := 0.001 * 2.44 * DiffractionStuff.WorkingWavelength *
      (DiffractionStuff.Range /
      ZBA_SURFACE [DiffractionStuff.FinalOPDSurface].
      ZBJ_OUTSIDE_APERTURE_DIA);

  IF AiryDiscDia < (0.25 * ARD_BLUR_SPHERE_DIAMETER) THEN
    ImageHeightMillimeters := 0.5 * ARD_BLUR_SPHERE_DIAMETER
  ELSE
  IF AiryDiscDia < ARD_BLUR_SPHERE_DIAMETER THEN
    ImageHeightMillimeters := ARD_BLUR_SPHERE_DIAMETER
  ELSE
    ImageHeightMillimeters := AiryDiscDia;*)

  ImageHeightMillimeters := 0.5 * ZFA_OPTION.ZGL_VIEWPORT_DIAMETER;

  CommandIOMemo.IOHistory.Lines.add ('Size of probe region is ' +
      FloatToStr (ImageHeightMillimeters * 2.0) + ' mm x ' +
      FloatToStr (ImageHeightMillimeters * 2.0) + ' mm.');

  WorkingWavelengthMicrons := DiffractionStuff.WorkingWavelength;
  Index := DiffractionStuff.ExitIndex;
  ImageSurface := DiffractionStuff.ImageSurface;

  ASSIGN (PSFFile, ZFA_OPTION.ZFN_PSF_FILE_NAME);

  REWRITE (PSFFile);

  (* Prepare coord. transformation data. *)

  SurfaceOrdinal := ImageSurface;
  XformOperands.CoordinateRotationNeeded :=
      ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      ZVL_COORDINATE_ROTATION_NEEDED;
  XformOperands.CoordinateTranslationNeeded :=
      ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      ZVK_COORDINATE_TRANSLATION_NEEDED;
  XformOperands.RotationMatrixElements :=
      ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      SurfaceRotationMatrix;
  XformOperands.TranslationVectorElements.OriginX :=
      ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X;
  XformOperands.TranslationVectorElements.OriginY :=
      ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y;
  XformOperands.TranslationVectorElements.OriginZ :=
      ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z;
  XformOperands.Orientation.Tx := 0.0;
  XformOperands.Orientation.Ty := 0.0;
  XformOperands.Orientation.Tz := 0.0;

(*  The following code generates an x-y array of probe points.  At each
    probe point, the amplitudes of the Huygens wavelets corresponding to
    the light rays from the exit pupil are vector-summed.  The resultant
    components are squared and summed, to give the intensity at the probe
    point.*)

  XTestPointCounter := -1 * (TotalXTestPoints);

  REPEAT
    BEGIN
      (* Get the local x coordinate of the probe point.*)
      ProbePointX := (ImageHeightMillimeters * XTestPointCounter /
          TotalXTestPoints) + ARG_SPOT_X_CENTROID;
      SaveProbePointX := ProbePointX;
      CommandIOMemo.IOHistory.Lines.add
          ('Generating raster line ' + IntToStr (XTestPointCounter) + '...');
      IF TwoDScanEnabled THEN
        YTestPointCounter := -1 * (TotalYTestPoints)
      ELSE
        YTestPointCounter := 0;
      Done := FALSE;
      REPEAT
        BEGIN
          (* Get the local y coordinate of the probe point.*)
          ProbePointY := (ImageHeightMillimeters * YTestPointCounter /
              TotalYTestPoints) + ARH_SPOT_Y_CENTROID;
          (* Get the local z coordinate of the probe point. *)
          ProbePointZ := ARI_SPOT_Z_CENTROID;
          (* Rotate and translate the probe point coordinates into world
          coordinates. *)
          XformOperands.Position.Rx := ProbePointX;
          XformOperands.Position.Ry := ProbePointY;
          XformOperands.Position.Rz := ProbePointZ;
          TransformLocalCoordsToGlobal (XformOperands);
          ProbePointX := XformOperands.Position.Rx;
          ProbePointY := XformOperands.Position.Ry;
          ProbePointZ := XformOperands.Position.Rz;
          (* Get first pupil point. *)
          X20_REWIND_AND_READ_DIFF (NoErrors);
          PupilPtToProbePtXMag := ProbePointX - ZTA_DIFFRACTION_DATA.ZTB_X;
          PupilPtToProbePtYMag := ProbePointY - ZTA_DIFFRACTION_DATA.ZTC_Y;
          PupilPtToProbePtZMag := ProbePointZ - ZTA_DIFFRACTION_DATA.ZTD_Z;
          PupilPtToProbePtGeomDist := Sqrt (Sqr (PupilPtToProbePtXMag) +
              Sqr (PupilPtToProbePtYMag) +
              Sqr (PupilPtToProbePtZMag));
          PupilPtToProbePtOptDist := PupilPtToProbePtGeomDist * Index;
          FractionalPhaseAngleRad :=
              TwoPi * Frac (((ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH +
              PupilPtToProbePtOptDist) * 1000.0) / WorkingWavelengthMicrons);
          SumCosinePhase := Cos (FractionalPhaseAngleRad);
          SumSinePhase := Sin (FractionalPhaseAngleRad);
          (* Cycle through remaining pupil points. *)
          FOR RayCount := 2 TO ARO_DIFF_RECORD_COUNT DO
	    BEGIN
              X40_SIMPLE_READ_DIFF (NoErrors);
 	      PupilPtToProbePtXMag := ProbePointX - ZTA_DIFFRACTION_DATA.ZTB_X;
	      PupilPtToProbePtYMag := ProbePointY - ZTA_DIFFRACTION_DATA.ZTC_Y;
	      PupilPtToProbePtZMag := ProbePointZ - ZTA_DIFFRACTION_DATA.ZTD_Z;
	      PupilPtToProbePtGeomDist := Sqrt (Sqr (PupilPtToProbePtXMag) +
	          Sqr (PupilPtToProbePtYMag) +
	          Sqr (PupilPtToProbePtZMag));
              (* Calculate optical path distance from this pupil point to
                 probe point.*)
	      PupilPtToProbePtOptDist := PupilPtToProbePtGeomDist * Index;
              (* Add in the optical path distance from the first OPD reference
                 surface to the final OPD reference surface (previously
                 computed during ray tracing).  Convert total optical path length
                 to a value in waves.  Conversion assumes that the optical path
                 length is originally expressed in millimeters, and that the
                 wavelength is expressed in microns.*)
	      FractionalPhaseAngleRad :=
                  TwoPi * Frac (((ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH +
                  PupilPtToProbePtOptDist) * 1000.0) /
	          WorkingWavelengthMicrons);
              SumCosinePhase := SumCosinePhase + Cos (FractionalPhaseAngleRad);
              SumSinePhase := SumSinePhase + Sin (FractionalPhaseAngleRad)
	    END;
          TestPointIntensity := (Sqr (SumCosinePhase) + Sqr (SumSinePhase)) /
              Sqr (NormalizingFactor);
          IF TestPointIntensity > StrehlRatio THEN
            StrehlRatio := TestPointIntensity;
          RNE := RNE + TestPointIntensity;
          (* Select one of the two following lines of code, depending on
             whether the scan is 2D, or 1D. *)
          IF TwoDScanEnabled THEN
            WRITELN (PSFFile, (ImageHeightMillimeters * XTestPointCounter /
                (TotalXTestPoints)), ' ',
                (ImageHeightMillimeters * YTestPointCounter /
                (TotalYTestPoints)), ' ',
                TestPointIntensity:14)
          ELSE
            WRITELN (PSFFile, (ImageHeightMillimeters * XTestPointCounter /
                (TotalXTestPoints)), TestPointIntensity:14);
          ProbePointX := SaveProbePointX;
          YTestPointCounter := YTestPointCounter + 1;
          IF TwoDScanEnabled THEN
            BEGIN
              IF YTestPointCounter > TotalYTestPoints THEN
                Done := TRUE
            END
          ELSE
            BEGIN
              IF YTestPointCounter > 0 THEN
                Done := TRUE
            END
        END
      UNTIL Done;
      XTestPointCounter := XTestPointCounter + 1
    END
  UNTIL
    (XTestPointCounter > TotalXTestPoints);

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('Strehl ratio = ' + FloatToStr (StrehlRatio));
  CommandIOMemo.IOHistory.Lines.add
      ('Relative ensquared energy = ' + FloatToStr (RNE));

  CLOSE (PSFFile)

END;




(**  V45_DISPLAY_OPD_STATISTICS	 **********************************************
******************************************************************************)


PROCEDURE V45_DISPLAY_OPD_STATISTICS;

  VAR
      I				     : INTEGER;

      V45AA_SUM_PATH_LENGTHS	     : DOUBLE;
      V45AB_AVE_PATH_LENGTH	     : DOUBLE;
      V45AC_CENTRAL_RAY_PATH_LENGTH  : DOUBLE;
      V45AD_DELTA_PATH		     : DOUBLE;
      V45AE_SUM_SQR_DELTA_PATHS	     : DOUBLE;
      V45AF_RMS_DELTA_PATH	     : DOUBLE;


(**  V4505_COMPUTE_CENTRAL_RAY_BASED_OPD  *************************************
******************************************************************************)


PROCEDURE V4505_COMPUTE_CENTRAL_RAY_BASED_OPD;

  VAR
      I  : INTEGER;

FUNCTION IntToStrF (Int : LONGINT; Format : INTEGER): STRING;

  VAR
      S  : STRING [25];

BEGIN

  str (Int:Format, S);
  IntToStrF := S

END;

BEGIN

  V45AE_SUM_SQR_DELTA_PATHS := 0.0;
  I := 1;
  V45AD_DELTA_PATH := 0.0;

  IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('CENTRAL-RAY-BASED OPTICAL PATH DIFFERENCES');
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('       --- END OPD REF. SURF. INTERCEPTS ---');
      CommandIOMemo.IOHistory.Lines.add
          (' RAY        X            Y            Z' +
	        '       OPD (LENS UNITS)');
      CommandIOMemo.IOHistory.Lines.add
          ('-----  -----------  -----------  -----------  ------------');
      CommandIOMemo.IOHistory.Lines.add
          (IntToStrF (I, 5) + '  ' +
          FloatToStrF (ZTA_DIFFRACTION_DATA.ZTB_X, ffFixed, 11, 5) + '  ' +
	        FloatToStrF (ZTA_DIFFRACTION_DATA.ZTC_Y, ffFixed, 11, 5) + '  ' +
	        FloatToStrF (ZTA_DIFFRACTION_DATA.ZTD_Z, ffFixed, 11, 5) + '  ' +
	        FloatToStrF (V45AD_DELTA_PATH, ffFixed, 12, 9))
    END;

  X40_SIMPLE_READ_DIFF (NoErrors);

  FOR I := 2 TO ARO_DIFF_RECORD_COUNT DO
    BEGIN
      V45AD_DELTA_PATH := ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH -
	  V45AC_CENTRAL_RAY_PATH_LENGTH;
      IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
	BEGIN
	  IF ((I MOD 15) < 1) THEN
	    Q980_REQUEST_MORE_OUTPUT;
	  CommandIOMemo.IOHistory.Lines.add
              (IntToStrF (I, 5) + '  ' +
              FloatToStrF (ZTA_DIFFRACTION_DATA.ZTB_X, ffFixed, 11, 5) + '  ' +
	      FloatToStrF (ZTA_DIFFRACTION_DATA.ZTC_Y, ffFixed, 11, 5) + '  ' +
	      FloatToStrF (ZTA_DIFFRACTION_DATA.ZTD_Z, ffFixed, 11, 5) + '  ' +
	      FloatToStrF (V45AD_DELTA_PATH, ffFixed, 12, 9))
	END;
      V45AE_SUM_SQR_DELTA_PATHS := V45AE_SUM_SQR_DELTA_PATHS +
	  SQR (V45AD_DELTA_PATH);
      X40_SIMPLE_READ_DIFF (NoErrors)
    END;

  V45AF_RMS_DELTA_PATH := SQRT (V45AE_SUM_SQR_DELTA_PATHS /
      (ARO_DIFF_RECORD_COUNT - 1));
      
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('PRINCIPAL RAY-BASED, RMS OPD = ' + FloatToStr (V45AF_RMS_DELTA_PATH) +
      ' (LENS UNITS)')

END;




(**  V4510_COMPUTE_AVE_PATH_BASED_OPD  ****************************************
******************************************************************************)


PROCEDURE V4510_COMPUTE_AVE_PATH_BASED_OPD;

  VAR
      I  : INTEGER;

FUNCTION IntToStrF (Int : LONGINT; Format : INTEGER): STRING;

  VAR
      S  : STRING [25];

BEGIN

  str (Int:Format, S);
  IntToStrF := S

END;

BEGIN

  V45AA_SUM_PATH_LENGTHS := 0.0;
  
  FOR I := 1 TO ARO_DIFF_RECORD_COUNT DO
    BEGIN
      V45AA_SUM_PATH_LENGTHS := V45AA_SUM_PATH_LENGTHS +
	  ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH -
	  V45AC_CENTRAL_RAY_PATH_LENGTH;
      X40_SIMPLE_READ_DIFF (NoErrors)
    END;
  
  V45AB_AVE_PATH_LENGTH := V45AA_SUM_PATH_LENGTHS /
      ARO_DIFF_RECORD_COUNT;

  X20_REWIND_AND_READ_DIFF (NoErrors);
  
  V45AE_SUM_SQR_DELTA_PATHS := 0.0;
  
  IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('AVERAGE-PATH-BASED OPTICAL PATH DIFFERENCES');
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('       --- END OPD REF. SURF. INTERCEPTS ---');
      CommandIOMemo.IOHistory.Lines.add
          (' RAY        X            Y            Z' +
	  '       OPD (LENS UNITS)');
      CommandIOMemo.IOHistory.Lines.add
          ('-----  -----------  -----------  -----------  ------------')
    END;
  
  FOR I := 1 TO ARO_DIFF_RECORD_COUNT DO
    BEGIN
      V45AD_DELTA_PATH := ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH -
	        V45AC_CENTRAL_RAY_PATH_LENGTH - V45AB_AVE_PATH_LENGTH;
      IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
	      BEGIN
	        IF ((I MOD 15) < 1) THEN
	            Q980_REQUEST_MORE_OUTPUT;
          CommandIOMemo.IOHistory.Lines.add (IntToStrF (I, 5) + '  ' +
              FloatToStrF (ZTA_DIFFRACTION_DATA.ZTB_X, ffFixed, 11, 5) + '  ' +
	            FloatToStrF (ZTA_DIFFRACTION_DATA.ZTC_Y, ffFixed, 11, 5) + '  ' +
	            FloatToStrF (ZTA_DIFFRACTION_DATA.ZTD_Z, ffFixed, 11, 5) + '  ' +
	            FloatToStrF (V45AD_DELTA_PATH, ffFixed, 12, 9))
	      END;
      V45AE_SUM_SQR_DELTA_PATHS := V45AE_SUM_SQR_DELTA_PATHS +
          SQR (V45AD_DELTA_PATH);
      X40_SIMPLE_READ_DIFF (NoErrors)
    END;

  V45AF_RMS_DELTA_PATH := SQRT (V45AE_SUM_SQR_DELTA_PATHS /
      ARO_DIFF_RECORD_COUNT);
  
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('AVERAGE PATH-BASED, RMS OPD = ' + FloatToStr (V45AF_RMS_DELTA_PATH) +
      ' (LENS UNITS)');

  Q980_REQUEST_MORE_OUTPUT

END;




(**  V45_DISPLAY_OPD_STATISTICS	 **********************************************
******************************************************************************)


BEGIN

  (*  THIS FOLLOWING 2 LINES OF CODE ASSUMES THAT THE FIRST RAY IN THE FILE
      CORRESPONDS TO THE CENTRAL RAY IN THE BUNDLE *)
      
  X20_REWIND_AND_READ_DIFF (NoErrors);
  
  V45AC_CENTRAL_RAY_PATH_LENGTH := ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH;
      
  IF ARO_DIFF_RECORD_COUNT > 1 THEN
    IF ZNA_RAY [1].ZFD_TRACE_ASYMMETRIC_FAN THEN
      IF (ZNA_RAY [1].NumberOfRaysInFanOrBundle = 20) THEN
        (* As a special case, a central ray-based OPD will be computed. *)
	V4505_COMPUTE_CENTRAL_RAY_BASED_OPD
      ELSE
	V4510_COMPUTE_AVE_PATH_BASED_OPD
    ELSE
      V4510_COMPUTE_AVE_PATH_BASED_OPD
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('ONLY ' + IntToStr (ARO_DIFF_RECORD_COUNT) +
          ' PATH LENGTH AVAILABLE.');
      CommandIOMemo.IOHistory.Lines.add
          ('CANNOT DO RMS PATH LENGTH DIFFERENCE.')
    END

END;




(**  LADSV  ******************************************************************
*****************************************************************************)


BEGIN

  HistogramFileCount := 1

END.

