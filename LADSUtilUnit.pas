UNIT LADSUtilUnit;

INTERFACE

  TYPE
      PositionVector                    = RECORD
        Rx                              : DOUBLE;
        Ry                              : DOUBLE;
        Rz                              : DOUBLE
      END;

      OrientationVector                 = RECORD
        Tx                              : DOUBLE;
        Ty                              : DOUBLE;
        Tz                              : DOUBLE
      END;

      RotationMatrix                    = RECORD
        T11				: DOUBLE;
	T12				: DOUBLE;
	T13				: DOUBLE;
	T21				: DOUBLE;
	T22				: DOUBLE;
	T23				: DOUBLE;
	T31				: DOUBLE;
	T32				: DOUBLE;
	T33				: DOUBLE
      END;

      TranslationVector                 = RECORD
        OriginX                         : DOUBLE;
        OriginY                         : DOUBLE;
        OriginZ                         : DOUBLE
      END;

      TransformationRecord              = RECORD
        CoordinateRotationNeeded        : BOOLEAN;
        CoordinateTranslationNeeded     : BOOLEAN;
        RotationMatrixElements          : RotationMatrix;
        TranslationVectorElements       : TranslationVector;
        Position                        : PositionVector;
        Orientation                     : OrientationVector
      END;


FUNCTION IntToStrF (Int : LONGINT; Format : INTEGER): STRING;
FUNCTION LeftJustifyBlankFill
                (SourceString    : STRING;
                 DestSize        : INTEGER) : STRING;
PROCEDURE DoFit (VAR Valid : BOOLEAN;
                 VAR Afit, Bfit, Cfit, ChiSqrFinal, rSqr : DOUBLE;
                 SurfaceShapeFileName : STRING);
PROCEDURE SimpleFit (VAR Valid : BOOLEAN;
                     VAR Afit, Bfit, Cfit, ChiSqrFinal, rSqr : DOUBLE;
                     SurfaceShapeFileName : STRING);
PROCEDURE TransformGlobalCoordsToLocal
    (VAR TransformationOperands : TransformationRecord);
PROCEDURE TransformLocalCoordsToGlobal
    (VAR TransformationOperands : TransformationRecord);

IMPLEMENTATION

  CONST
      MaxUnknowns = 20;
      MinAcceptableError = 1.0E-12;

  TYPE
      VectorType                     = ARRAY [1..MaxUnknowns] OF DOUBLE;

      MatrixType                     = ARRAY [1..MaxUnknowns] OF
                                           VectorType;

  VAR
      MatinvOK                         : BOOLEAN;
      LSFerror                         : BOOLEAN;
      LSFfound                         : BOOLEAN;

      Unknowns                         : INTEGER;
      J                                : INTEGER;
      Points                           : INTEGER;

      DELTA                            : DOUBLE;
      FirstGuessA                      : DOUBLE;
      FirstGuessB                      : DOUBLE;
      FirstGuessC                      : DOUBLE;
      AGuess                           : DOUBLE;
      BGuess                           : DOUBLE;
      CGuess                           : DOUBLE;
      ABest                            : DOUBLE;
      BBest                            : DOUBLE;
      CBest                            : DOUBLE;
      InitialLambda                    : DOUBLE;
      Lambda                           : DOUBLE;
      SumYObsSqr                       : DOUBLE;
      SumYCompSqr                      : DOUBLE;
      ChiSqr                           : DOUBLE;
      BestChiSqr                       : DOUBLE;
      X                                : DOUBLE;
      Y  	                       : DOUBLE;
      DET                              : DOUBLE;

      Matrix  	                       : MatrixType;
      MATRIX_2                         : MatrixType;
      MATRIX_3                         : MatrixType;

      Vector  	                       : VectorType;

      SurfaceShapeFile                 : TEXT;

(**  InvertMatrix  **********************************************************

   This procedure expects to find the user data
   residing in a variable called Matrix.  Matrix is defined as a
   square two-dimensional array of DOUBLE data type.  The data in
   Matrix is stored in rows and columns, which are accessed by
   statements of the form "Matrix [row, column]".  For example,
   the data for a set of 4 equations in 4 unknowns would be arranged
   such that the first row of the matrix contains the 4 data items
   from the first equation, etc.  Thus, the statement Matrix [1,3]
   would refer to the third data item from the first equation.
   After inversion, the data items originally stored in Matrix by
   the user are replaced by elements of the inverted matrix.  The
   user may then use the inverted matrix for whatever purpose, as
   for example, returning into this program to do a matrix-vector
   multiplication.

****************************************************************************)

PROCEDURE InvertMatrix (NOrder : INTEGER);

  VAR
      TIME_TO_QUIT  : BOOLEAN;

      I  	    : INTEGER;
      J  	    : INTEGER;
      K  	    : INTEGER;
      L  	    : INTEGER;
      IK            : ARRAY [1..MaxUnknowns] OF INTEGER;
      JK            : ARRAY [1..MaxUnknowns] OF INTEGER;

      AMAX          : DOUBLE;
      SAVE          : DOUBLE;



(**  FIND_LARGE   ***********************************************************
****************************************************************************)


PROCEDURE FIND_LARGE;

  VAR
      I   : INTEGER;
      J   : INTEGER;

BEGIN

  AMAX := 0.0;

  FOR I := K TO NOrder DO
    FOR J := K TO NOrder DO
      IF (ABS (AMAX) - ABS (MATRIX [I, J]) <= 0.0) THEN
        BEGIN
	  AMAX := MATRIX [I, J];
	  IK [K] := I;
	  JK [K] := J
        END;

  IF ABS (AMAX) < 1.0E-34 THEN
    BEGIN
      DET := 0.0;
      MatinvOK := FALSE
(*    WRITELN;
      WRITELN ('ERROR:  No non-zero data in matrix.');
      WRITELN ('AMAX = ', AMAX)*)
    END
  
END;




(**  INTERCHANGE  ***********************************************************
****************************************************************************)


PROCEDURE INTERCHANGE;

  VAR
      I  : INTEGER;

BEGIN

  J := JK [K];

  IF (J - K) < 0 THEN
    BEGIN
    END
  ELSE
  IF (J - K) = 0 THEN
    TIME_TO_QUIT := TRUE
  ELSE
    FOR I := 1 TO NOrder DO
      BEGIN
        SAVE := MATRIX [I, K];
        MATRIX [I, K] := MATRIX [I, J];
        MATRIX [I, J] := -SAVE;
        TIME_TO_QUIT := TRUE
      END
      
END;




(**  InvertMatrix  **********************************************************
****************************************************************************)


BEGIN

  MatinvOK := TRUE;

  DET := 1.0;
  
  IF NOrder > MaxUnknowns THEN
    BEGIN
      MatinvOK := FALSE;
      WRITELN;
      WRITELN ('Maximum number of unknowns (20) exceeded.')
    END
  ELSE
    BEGIN
      FOR K := 1 TO NOrder DO
	BEGIN
	  TIME_TO_QUIT := FALSE;
	  REPEAT
	    BEGIN
	      FIND_LARGE;
	      IF MatinvOK THEN
		BEGIN
		  I := IK [K];
		  IF (I - K) < 0 THEN
		    BEGIN
		    END
		  ELSE
		  IF (I - K) = 0 THEN
		    INTERCHANGE
		  ELSE
		    BEGIN
		      FOR J := 1 TO NOrder DO
			BEGIN
			  SAVE := MATRIX [K, J];
			  MATRIX [K, J] := MATRIX [I, J];
			  MATRIX [I, J] := -SAVE
			END;
		      INTERCHANGE
		    END
		END
	    END
	  UNTIL TIME_TO_QUIT
	    OR (NOT MatinvOK);
	  IF MatinvOK THEN
	    BEGIN
	      FOR I := 1 TO NOrder DO
		IF (I - K) <> 0 THEN
		  MATRIX [I, K] := -MATRIX [I, K] / AMAX;
	      FOR I := 1 TO NOrder DO
		FOR J := 1 TO NOrder DO
		  IF (I - K) <> 0 THEN
		    IF (J - K) <> 0 THEN
		      MATRIX [I, J] := MATRIX [I, J] +
			  MATRIX [I, K] * MATRIX [K, J];
	      FOR J := 1 TO NOrder DO
		IF (J - K) <> 0 THEN
		  MATRIX [K, J] := MATRIX [K, J] / AMAX;
	      MATRIX [K, K] := 1.0 / AMAX;
	      DET := DET * AMAX;
              IF Abs (DET) > 1.0E100 THEN
                MatinvOK := FALSE
	    END
	END
    END;

  IF MatinvOK THEN
    FOR L := 1 TO NOrder DO
      BEGIN
	K := NOrder - L + 1;
	J := IK [K];
	IF (J - K) > 0 THEN
	  FOR I := 1 TO NOrder DO
	    BEGIN
	      SAVE := MATRIX [I, K];
	      MATRIX [I, K] := -MATRIX [I, J];
	      MATRIX [I, J] := SAVE
	    END;
	I := JK [K];
	IF (I - K) > 0 THEN
	  FOR J := 1 TO NOrder DO
	    BEGIN
	      SAVE := MATRIX [K, J];
	      MATRIX [K, J] := -MATRIX [I, J];
	      MATRIX [I, J] := SAVE
	    END
      END

END;




(**  MatrixVectorMult  ******************************************************

   This procedure is typically called after the
   InvertMatrix procedure has been used to invert a matrix, and after
   user data has been supplied into the variable called Vector.
   Vector is defined as a 1-dimensional array of DOUBLE data type.
   For solving a system of n equations in n unknowns, each row of
   Matrix will contain n data elements from the right side of each
   equation, and Vector will contain n elements each of which will
   correspond to the single data item from the left side of each
   equation.

****************************************************************************)

PROCEDURE MatrixVectorMult (NOrder : INTEGER);

  VAR
      I      : INTEGER;
      J      : INTEGER;

      HOLD   : VectorType;


BEGIN

  FOR I := 1 TO NOrder DO
    BEGIN
      HOLD [I] := 0.0;
      FOR J := 1 TO NOrder DO
        HOLD [I] := HOLD [I] + MATRIX [I, J] * VECTOR [J]
    END;
    
  VECTOR := HOLD

END;




(**  MATRIX_MATRIX_MULT  ****************************************************
****************************************************************************)


PROCEDURE MATRIX_MATRIX_MULT (NOrder : INTEGER);

  VAR
      LM_ROW  : INTEGER;
      LM_COL  : INTEGER;
      RM_ROW  : INTEGER;
      RM_COL  : INTEGER;
      
      ACCUM   : DOUBLE;


BEGIN

  FOR LM_ROW := 1 TO NOrder DO
    FOR LM_COL := 1 TO NOrder DO
      MATRIX_3 [LM_ROW, LM_COL] := 0.0;

  LM_ROW := 1;
  LM_COL := 1;
  RM_ROW := 1;
  RM_COL := 1;
  ACCUM := 0.0;
  
  REPEAT
    BEGIN
      REPEAT
	BEGIN
	  REPEAT
	    BEGIN
	      ACCUM := ACCUM +
		  MATRIX [LM_ROW, LM_COL] * MATRIX_2 [RM_ROW, RM_COL];
	      LM_COL := LM_COL + 1;
	      RM_ROW := RM_ROW + 1
	    END
	  UNTIL
	    LM_COL > NOrder;
	  MATRIX_3 [LM_ROW, RM_COL] := ACCUM;
	  ACCUM := 0.0;
	  LM_ROW := LM_ROW + 1;
	  LM_COL := 1;
	  RM_ROW := 1;
	END
      UNTIL
	LM_ROW > NOrder;
      LM_ROW := 1;
      RM_COL := RM_COL + 1
    END
  UNTIL
    RM_COL > NOrder

END;




(**  ComputeChiSqr  ********************************************************
***************************************************************************)


PROCEDURE ComputeChiSqr;

  VAR
      K  	  	         : INTEGER;
      L  	  	         : INTEGER;

      COMPUTED  	         : DOUBLE;
      RESIDUAL  	         : DOUBLE;
      X  	  	         : DOUBLE;
      PARTIAL  	                 : ARRAY [1..6] OF DOUBLE;
      P        	                 : DOUBLE;

BEGIN

  ChiSqr := 0.0;
  SumYObsSqr := 0.0;
  SumYCompSqr := 0.0;

  FOR K := 1 TO UNKNOWNS DO
    BEGIN
      VECTOR [K] := 0.0;
      FOR L := 1 TO UNKNOWNS DO
        MATRIX [K, L] := 0.0
    END;

  RESET (SurfaceShapeFile);

  IF (NOT LSFerror)
      AND (NOT (EOF (SurfaceShapeFile))) THEN
    REPEAT
      BEGIN
        READLN (SurfaceShapeFile, X, Y);
        P := AGuess + BGuess * X + CGuess * X * X;
        IF P < 0.0 THEN
          LSFerror := TRUE
        ELSE
          BEGIN
            COMPUTED := Sqrt (P);
            RESIDUAL := Y - COMPUTED;
            ChiSqr := ChiSqr +  SQR (RESIDUAL);
            SumYObsSqr := SumYObsSqr + Sqr (Y);
            SumYCompSqr := SumYCompSqr + P;
            (* Evaluate partial derivatives *)
            PARTIAL [1] := 0.5 / COMPUTED;  (* dY / dA *)
            PARTIAL [2] := X * PARTIAL [1]; (* dY / dB *)
            PARTIAL [3] := X * PARTIAL [2]; (* dY / dC *)
            FOR K := 1 TO UNKNOWNS DO
	      BEGIN
    	        VECTOR [K] := VECTOR [K] + RESIDUAL * PARTIAL [K];
	        FOR L := 1 TO UNKNOWNS DO
    	          MATRIX [K, L] := MATRIX [K, L] +
		      PARTIAL [K] * PARTIAL [L]
	      END
          END
      END
    UNTIL LSFerror OR (EOF (SurfaceShapeFile))

END;




(**  RefineFit  ***************************************************************
******************************************************************************)


PROCEDURE RefineFit;

  CONST
      MAX_ITERATIONS = 200;

  VAR
      k  	  	         : INTEGER;
      J  	  	         : INTEGER;

      SaveA                      : DOUBLE;
      SaveB                      : DOUBLE;
      SaveC                      : DOUBLE;

      trash                      : STRING;

      SaveMatrix                 : MatrixType;

      SaveVector                 : VectorType;

BEGIN

  LSFerror := FALSE;

  AGuess := FirstGuessA;
  BGuess := FirstGuessB;
  CGuess := FirstGuessC;

  Lambda := InitialLambda;

  ComputeChiSqr;

  BestChiSqr := ChiSqr;

  ABest := AGuess;
  BBest := BGuess;
  CBest := CGuess;

  J := 1;

  REPEAT
    SaveMatrix := Matrix;
    SaveVector := Vector;
    FOR k := 1 TO Unknowns DO
      Matrix [k, k] := Matrix [k, k] * (1.0 + Lambda);
    InvertMatrix (UNKNOWNS);
    IF MatinvOK THEN
      BEGIN
        MatrixVectorMult (UNKNOWNS);
        SaveA := AGuess;
        SaveB := BGuess;
        SaveC := CGuess;
        AGuess := AGuess + VECTOR [1];
        BGuess := BGuess + VECTOR [2];
        CGuess := CGuess + VECTOR [3];
        ComputeChiSqr;
        DELTA := Abs (BestChiSqr - ChiSqr);
        IF ChiSqr < BestChiSqr THEN
          BEGIN
            Lambda := 0.1 * Lambda;
            BestChiSqr := ChiSqr;
            ABest := AGuess;
            BBest := BGuess;
            CBest := CGuess
          END
        ELSE
        IF DELTA < MinAcceptableError THEN
          LSFfound := TRUE
        ELSE
          BEGIN
            Lambda := 10.0 * Lambda;
            AGuess := SaveA;
            BGuess := SaveB;
            CGuess := SaveC;
            Matrix := SaveMatrix;
            Vector := SaveVector
          END;
        J := J + 1
      END
    ELSE
      LSFerror := TRUE
  UNTIL
    LSFfound
    OR LSFerror
    OR (J > MAX_ITERATIONS);

  IF J > MAX_ITERATIONS THEN
    LSFerror := TRUE

END;




(**  DoFit  *****************************************************************
     This procedure obtains the constants A, B, and C for the equation

     y^2 = A + Bx + Cx^2

     by a non-linear least-squares fit via application of the
     Levenberg-Marquardt method.  Input to this program is an ASCII text data
     file called POINTS.TXT.

****************************************************************************)

PROCEDURE DoFit;

BEGIN

  LSFfound := FALSE;
  Valid := FALSE;
  UNKNOWNS := 3;

  ASSIGN (SurfaceShapeFile, SurfaceShapeFileName);
  {$I-}
  RESET (SurfaceShapeFile);
  {$I+}

  IF IOResult = 0 THEN
    BEGIN
      FirstGuessA := 0.00001;
      FirstGuessB := 1.0;
      FirstGuessC := 1.0;
      REPEAT
        BEGIN
          InitialLambda := 0.001;
          REPEAT
            BEGIN
              RefineFit;
              IF LSFerror THEN
                InitialLambda := InitialLambda * 10.0
            END
          UNTIL LSFfound
              OR (InitialLambda > 10.0);
          IF NOT LSFfound THEN
            FirstGuessA := FirstGuessA * 10.0
        END
      UNTIL LSFfound
        OR (FirstGuessA > 101.0);
      IF LSFfound THEN
        BEGIN
          Valid := TRUE;
          Afit := ABest;
          Bfit := BBest;
          Cfit := CBest;
          ChiSqrFinal := ChiSqr;
          rSqr := SumYCompSqr / SumYObsSqr
        END;
      CLOSE (SurfaceShapeFile)
    END
  ELSE
    BEGIN
      WRITELN;
      WRITELN ('ERROR:  Surface shape file ', SurfaceShapeFileName,
          ' missing.')
    END

END;




(**  SimpleFit  *************************************************************
     This procedure obtains the constants A, B, and C for the equation

     y = A + Bx + Cx^2

     by a linear least-squares fit.  Input to this program is an ASCII text
     data file called POINTS.TXT.

****************************************************************************)

PROCEDURE SimpleFit;


(**  ProcessInputData  *****************************************************
***************************************************************************)

PROCEDURE ProcessInputData;

  VAR
      SumN       : DOUBLE;
      SumX       : DOUBLE;
      SumX2      : DOUBLE;
      SumX3      : DOUBLE;
      SumX4      : DOUBLE;
      SumXY      : DOUBLE;
      SumX2Y     : DOUBLE;
      SumY       : DOUBLE;
      X2         : DOUBLE;
      X3         : DOUBLE;
      X4         : DOUBLE;
      XY         : DOUBLE;
      X2Y        : DOUBLE;

BEGIN

  SumN := 0.0;
  SumX := 0.0;
  SumX2 := 0.0;
  SumX3 := 0.0;
  SumX4 := 0.0;
  SumXY := 0.0;
  SumX2Y := 0.0;
  SumY := 0.0;

  RESET (SurfaceShapeFile);

  IF NOT (EOF (SurfaceShapeFile)) THEN
    REPEAT
      BEGIN
        READLN (SurfaceShapeFile, X, Y);
        X2 := Sqr (X);
        X3 := X2 * X;
        X4 := Sqr (X2);
        XY := X * Y;
        X2Y := Sqr (X) * Y;
        SumN := SumN + 1.0;
        SumX := SumX + X;
        SumX2 := SumX2 + X2;
        SumX3 := SumX3 + X3;
        SumX4 := SumX4 + X4;
        SumXY := SumXY + XY;
        SumX2Y := SumX2Y + X2Y;
        SumY := SumY + Y;
      END
    UNTIL EOF (SurfaceShapeFile);

  Matrix [1, 1] := SumN;
  Matrix [1, 2] := SumX;
  Matrix [1, 3] := SumX2;
  Matrix [2, 1] := SumX;
  Matrix [2, 2] := SumX2;
  Matrix [2, 3] := SumX3;
  Matrix [3, 1] := SumX2;
  Matrix [3, 2] := SumX3;
  Matrix [3, 3] := SumX4;
  Vector [1] := SumY;
  Vector [2] := SumXY;
  Vector [3] := SumX2Y

END;




(**  SimpleFit  *************************************************************
****************************************************************************)

BEGIN

  LSFfound := FALSE;
  Valid := FALSE;
  UNKNOWNS := 3;

  ASSIGN (SurfaceShapeFile, SurfaceShapeFileName);
  {$I-}
  RESET (SurfaceShapeFile);
  {$I+}

  IF IOResult = 0 THEN
    BEGIN
      ProcessInputData;
      InvertMatrix (UNKNOWNS);
      IF MatinvOK THEN
        BEGIN
          MatrixVectorMult (UNKNOWNS);
          Afit := Vector [1];
          Bfit := Vector [2];
          Cfit := Vector [3];
          Valid := TRUE
(*        ChiSqrFinal := ChiSqr;
          rSqr := SumYCompSqr / SumYObsSqr*)
        END;
      CLOSE (SurfaceShapeFile)
    END
  ELSE
    BEGIN
      WRITELN;
      WRITELN ('ERROR:  Surface shape file ', SurfaceShapeFileName,
          ' missing.')
    END

END;




(**  IntToStrF  ***************************************************************
******************************************************************************)

FUNCTION IntToStrF (Int : LONGINT; Format : INTEGER): STRING;

  VAR
      S  : STRING [25];

BEGIN

  str (Int:Format, S);
  IntToStrF := S

END;




(**  LeftJustifyBlankFill  ***************************************************
******************************************************************************)

FUNCTION LeftJustifyBlankFill
                (SourceString  : STRING;
                 DestSize      : INTEGER) : STRING;

  VAR
      I            : INTEGER;

      DestString   : STRING;

BEGIN

  DestString := Copy (SourceString, 1, DestSize);

  IF (Length (DestString) < DestSize) THEN
    FOR I := (Length (DestString) + 1) TO DestSize DO
      DestString := DestString + ' ';

  LeftJustifyBlankFill := DestString

END;




(**  TransformGlobalCoordsToLocal  *******************************************
******************************************************************************)


PROCEDURE TransformGlobalCoordsToLocal
    (VAR TransformationOperands : TransformationRecord);

  VAR
      HoldA  : DOUBLE;
      HoldB  : DOUBLE;
      HoldC  : DOUBLE;
      HoldX  : DOUBLE;
      HoldY  : DOUBLE;
      HoldZ  : DOUBLE;

BEGIN

  IF TransformationOperands.CoordinateTranslationNeeded THEN
    BEGIN
      TransformationOperands.Position.Rx :=
          TransformationOperands.Position.Rx -
	  TransformationOperands.TranslationVectorElements.OriginX;
      TransformationOperands.Position.Ry :=
          TransformationOperands.Position.Ry -
	  TransformationOperands.TranslationVectorElements.OriginY;
    END;

  TransformationOperands.Position.Rz :=
      TransformationOperands.Position.Rz -
      TransformationOperands.TranslationVectorElements.OriginZ;

  IF TransformationOperands.CoordinateRotationNeeded THEN
    BEGIN
      (* Rotate position. *)
      HoldX := TransformationOperands.Position.Rx;
      HoldY := TransformationOperands.Position.Ry;
      HoldZ := TransformationOperands.Position.Rz;
      TransformationOperands.Position.Rx :=
          TransformationOperands.RotationMatrixElements.T11 * HoldX +
	  TransformationOperands.RotationMatrixElements.T12 * HoldY +
	  TransformationOperands.RotationMatrixElements.T13 * HoldZ;
      TransformationOperands.Position.Ry :=
          TransformationOperands.RotationMatrixElements.T21 * HoldX +
	  TransformationOperands.RotationMatrixElements.T22 * HoldY +
	  TransformationOperands.RotationMatrixElements.T23 * HoldZ;
      TransformationOperands.Position.Rz :=
          TransformationOperands.RotationMatrixElements.T31 * HoldX +
	  TransformationOperands.RotationMatrixElements.T32 * HoldY +
	  TransformationOperands.RotationMatrixElements.T33 * HoldZ;
      (* Rotate orientation. *)
      HoldA := TransformationOperands.Orientation.Tx;
      HoldB := TransformationOperands.Orientation.Ty;
      HoldC := TransformationOperands.Orientation.Tz;
      TransformationOperands.Orientation.Tx :=
          TransformationOperands.RotationMatrixElements.T11 * HoldA +
	  TransformationOperands.RotationMatrixElements.T12 * HoldB +
	  TransformationOperands.RotationMatrixElements.T13 * HoldC;
      TransformationOperands.Orientation.Ty :=
          TransformationOperands.RotationMatrixElements.T21 * HoldA +
	  TransformationOperands.RotationMatrixElements.T22 * HoldB +
	  TransformationOperands.RotationMatrixElements.T23 * HoldC;
      TransformationOperands.Orientation.Tz :=
          TransformationOperands.RotationMatrixElements.T31 * HoldA +
	  TransformationOperands.RotationMatrixElements.T32 * HoldB +
	  TransformationOperands.RotationMatrixElements.T33 * HoldC
    END;

  IF ABS (TransformationOperands.Position.Rx) < 1.0E-12 THEN
    TransformationOperands.Position.Rx := 0.0;

  IF ABS (TransformationOperands.Position.Ry) < 1.0E-12 THEN
    TransformationOperands.Position.Ry := 0.0;

  IF ABS (TransformationOperands.Position.Rz) < 1.0E-12 THEN
    TransformationOperands.Position.Rz := 0.0;

  IF ABS (TransformationOperands.Orientation.Tx) < 1.0E-12 THEN
    TransformationOperands.Orientation.Tx := 0.0;

  IF ABS (TransformationOperands.Orientation.Ty) < 1.0E-12 THEN
    TransformationOperands.Orientation.Ty := 0.0;

  IF (TransformationOperands.Orientation.Tx = 0.0)
      AND (TransformationOperands.Orientation.Ty = 0.0) THEN
    IF TransformationOperands.Orientation.Tz > 0.0 THEN
      TransformationOperands.Orientation.Tz := 1.0
    ELSE
      TransformationOperands.Orientation.Tz := -1.0

END;




(**  TransformLocalCoordsToGlobal  *******************************************
******************************************************************************)

PROCEDURE TransformLocalCoordsToGlobal
    (VAR TransformationOperands : TransformationRecord);

  VAR
      HoldA  : DOUBLE;
      HoldB  : DOUBLE;
      HoldC  : DOUBLE;
      HoldX  : DOUBLE;
      HoldY  : DOUBLE;
      HoldZ  : DOUBLE;
      NXHold : DOUBLE;
      NYHold : DOUBLE;
      NZHold : DOUBLE;

BEGIN

  IF TransformationOperands.CoordinateRotationNeeded THEN
    BEGIN
      (* Rotate orientation. *)
      HoldA := TransformationOperands.Orientation.Tx;
      HoldB := TransformationOperands.Orientation.Ty;
      HoldC := TransformationOperands.Orientation.Tz;
      TransformationOperands.Orientation.Tx :=
          TransformationOperands.RotationMatrixElements.T11 * HoldA +
	  TransformationOperands.RotationMatrixElements.T21 * HoldB +
	  TransformationOperands.RotationMatrixElements.T31 * HoldC;
      TransformationOperands.Orientation.Ty :=
          TransformationOperands.RotationMatrixElements.T12 * HoldA +
	  TransformationOperands.RotationMatrixElements.T22 * HoldB +
	  TransformationOperands.RotationMatrixElements.T32 * HoldC;
      TransformationOperands.Orientation.Tz :=
          TransformationOperands.RotationMatrixElements.T13 * HoldA +
	  TransformationOperands.RotationMatrixElements.T23 * HoldB +
	  TransformationOperands.RotationMatrixElements.T33 * HoldC;
      IF ABS (TransformationOperands.Orientation.Tx) < 1.0E-12 THEN
        TransformationOperands.Orientation.Tx := 0.0;
      IF ABS (TransformationOperands.Orientation.Ty) < 1.0E-12 THEN
        TransformationOperands.Orientation.Ty := 0.0;
      IF (TransformationOperands.Orientation.Tx = 0.0)
          AND (TransformationOperands.Orientation.Ty = 0.0) THEN
        BEGIN
          IF TransformationOperands.Orientation.Tz > 0.0 THEN
            TransformationOperands.Orientation.Tz := 1.0
          ELSE
            TransformationOperands.Orientation.Tz := -1.0
        END;
      (* Rotate position. *)
      HoldX := TransformationOperands.Position.Rx;
      HoldY := TransformationOperands.Position.Ry;
      HoldZ := TransformationOperands.Position.Rz;
      TransformationOperands.Position.Rx :=
          TransformationOperands.RotationMatrixElements.T11 * HoldX +
	  TransformationOperands.RotationMatrixElements.T21 * HoldY +
	  TransformationOperands.RotationMatrixElements.T31 * HoldZ;
      TransformationOperands.Position.Ry :=
          TransformationOperands.RotationMatrixElements.T12 * HoldX +
	  TransformationOperands.RotationMatrixElements.T22 * HoldY +
	  TransformationOperands.RotationMatrixElements.T32 * HoldZ;
      TransformationOperands.Position.Rz :=
          TransformationOperands.RotationMatrixElements.T13 * HoldX +
	  TransformationOperands.RotationMatrixElements.T23 * HoldY +
	  TransformationOperands.RotationMatrixElements.T33 * HoldZ;
      IF ABS (TransformationOperands.Position.Rx) < 1.0E-12 THEN
	TransformationOperands.Position.Rx := 0.0;
      IF ABS (TransformationOperands.Position.Ry) < 1.0E-12 THEN
	TransformationOperands.Position.Ry := 0.0;
      IF ABS (TransformationOperands.Position.Rz) < 1.0E-12 THEN
	TransformationOperands.Position.Rz := 0.0
    END;

(*IF ZFA_OPTION.DisplayLocalData THEN
    IF TransformationOperands.CoordinateRotationNeeded THEN
      BEGIN
        NXHold := NX;
        NYHold := NY;
        NZHold := NZ;
        NXWorld :=
            TransformationOperands.RotationMatrixElements.T11 * NXHold +
            TransformationOperands.RotationMatrixElements.T21 * NYHold +
            TransformationOperands.RotationMatrixElements.T31 * NZHold;
        NYWorld :=
            TransformationOperands.RotationMatrixElements.T12 * NXHold +
            TransformationOperands.RotationMatrixElements.T22 * NYHold +
            TransformationOperands.RotationMatrixElements.T32 * NZHold;
        NZWorld :=
            TransformationOperands.RotationMatrixElements.T13 * NXHold +
            TransformationOperands.RotationMatrixElements.T23 * NYHold +
            TransformationOperands.RotationMatrixElements.T33 * NZHold;
        IF ABS (NXWorld) < 1.0E-12 THEN
	  NXWorld := 0.0;
        IF ABS (NYWorld) < 1.0E-12 THEN
	  NYWorld := 0.0;
        IF (NXWorld = 0.0)
	    AND (NYWorld = 0.0) THEN
	  BEGIN
	    IF NZWorld > 0.0 THEN
	      NZWorld := 1.0
	    ELSE
	      NZWorld := -1.0
	  END
      END
    ELSE
      BEGIN
        NXWorld := NX;
        NYWorld := NY;
        NZWorld := NZ
      END;*)

  (* We will now de-translate. *)

  IF TransformationOperands.CoordinateTranslationNeeded THEN
    BEGIN
      TransformationOperands.Position.Rx :=
          TransformationOperands.Position.Rx +
	  TransformationOperands.TranslationVectorElements.OriginX;
      TransformationOperands.Position.Ry :=
          TransformationOperands.Position.Ry +
	  TransformationOperands.TranslationVectorElements.OriginY;
    END;

  TransformationOperands.Position.Rz :=
      TransformationOperands.Position.Rz +
      TransformationOperands.TranslationVectorElements.OriginZ;

(*RAY0.ALL := RAY_OLD.ALL;

  IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
    IF SurfaceOrdinal = ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE THEN
      IF NOT F01AG_RAY_TERMINATION_OCCURRED THEN
	BEGIN
	  ZSA_SURFACE_INTERCEPTS.ZSE_X1 := RAY1.X;
	  ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := RAY1.Y;
	  ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := RAY1.Z;
	  ZSA_SURFACE_INTERCEPTS.ZSB_A1 := RAY1.A;
	  ZSA_SURFACE_INTERCEPTS.ZSC_B1 := RAY1.B;
	  ZSA_SURFACE_INTERCEPTS.ZSD_C1 := RAY1.C;
	  ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := N1;
	  IF F01AO_TRACING_PRINCIPAL_RAY THEN
	    ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := -1.0 *
	        ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX;
	  X07_SIMPLE_WRITE_OUTPUT_RAY (NoErrors);
	  ASC_OUTPUT_RAY_COUNT := ASC_OUTPUT_RAY_COUNT + 1
	END*)

END;


BEGIN

END.
