UNIT LADSRandomUnit;

INTERFACE

  VAR
      AFU_RANDOM_SEED_1  : INTEGER;
      AFV_RANDOM_SEED_2  : INTEGER;
      AFW_RANDOM_SEED_3  : INTEGER;

      RANDOM             : DOUBLE;

PROCEDURE RANDGEN;
PROCEDURE SeedRandomNumberGenerator;

IMPLEMENTATION

  USES SysUtils,
       ExpertIO;


(**  RANDGEN  *****************************************************************
******************************************************************************)


PROCEDURE RANDGEN;

  VAR
      TEMP  : DOUBLE;

BEGIN

  (*  FIRST GENERATOR  *)
  
  AFU_RANDOM_SEED_1 := 171 * (AFU_RANDOM_SEED_1 MOD 177) -
      2 * (AFU_RANDOM_SEED_1 DIV 177);
  
  IF AFU_RANDOM_SEED_1 < 0 THEN
    AFU_RANDOM_SEED_1 := AFU_RANDOM_SEED_1 + 30269;
  
  (*  SECOND GENERATOR	*)
  
  AFV_RANDOM_SEED_2 := 172 * (AFV_RANDOM_SEED_2 MOD 176) -
      35 * (AFV_RANDOM_SEED_2 DIV 176);
  
  IF AFV_RANDOM_SEED_2 < 0 THEN
    AFV_RANDOM_SEED_2 := AFV_RANDOM_SEED_2 + 30307;
  
  (*  THIRD GENERATOR  *)
  
  AFW_RANDOM_SEED_3 := 170 * (AFW_RANDOM_SEED_3 MOD 178) -
      63 * (AFW_RANDOM_SEED_3 DIV 178);
  
  IF AFW_RANDOM_SEED_3 < 0 THEN
    AFW_RANDOM_SEED_3 := AFW_RANDOM_SEED_3 + 30323;
  
  (*  COMBINE TO GIVE RANDOM NUMBER  *)
  
  TEMP := AFU_RANDOM_SEED_1 / 30269.0 + AFV_RANDOM_SEED_2 / 30307.0
      + AFW_RANDOM_SEED_3 / 30323.0;
      
  RANDOM := TEMP - TRUNC (TEMP)

END;




(**  SeedFromClock  *********************************************************
****************************************************************************)

PROCEDURE SeedFromClock;

  VAR
      MyTime  : TDateTime;

      Temp    : DOUBLE;

      Hour    : WORD;
      Minute  : WORD;
      Second  : WORD;
      Sec100  : WORD;

BEGIN

  MyTime := Time;
  (* Strip off date portion, and convert to hours. *)
  Temp := (MyTime - trunc (MyTime)) * 24.0; (* hours *)
  Hour := trunc (Temp);
  (* Get minutes *)
  Temp := (Temp - trunc (Temp)) * 60.0; (* minutes *)
  Minute := trunc (Temp);
  (* Get seconds *)
  Temp := (Temp - trunc (Temp)) * 60.0; (* seconds *)
  Second := trunc (Temp);
  (* Get 100ths of a second *)
  Temp := (Temp - trunc (Temp)) * 100.0; (* 100ths of a second *)
  Sec100 := trunc (Temp);

  AFU_RANDOM_SEED_1 := Minute;
  AFV_RANDOM_SEED_2 := Second;
  AFW_RANDOM_SEED_3 := Sec100

END;




(**  UserSeed  **************************************************************
****************************************************************************)

PROCEDURE UserSeed;

  VAR
      ValidSeedSelectCommands  : STRING [9];
      GetSeed1                 : STRING [3];
      GetSeed2                 : STRING [3];
      GetSeed3                 : STRING [3];

(**  RequestSeed  ***********************************************************
****************************************************************************)

PROCEDURE RequestSeed (SeedNumber : INTEGER);

  VAR
    Valid  : BOOLEAN;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      IF S01AA_EXPERT_MODE_OFF THEN
	BEGIN
          WRITELN;
	  WRITELN ('ENTER VALUE FOR RANDOM SEED #', SeedNumber);
          WRITELN;
	  WRITE ('>')
	END;
      S01_PROCESS_REQUEST;
      IF IntegerFound THEN
        BEGIN
          Valid := TRUE;
          IF SeedNumber = 1 THEN
            AFU_RANDOM_SEED_1 := IntegerNumber
          ELSE
          IF SeedNumber = 2 THEN
            AFV_RANDOM_SEED_2 := IntegerNumber
          ELSE
          IF SeedNumber = 3 THEN
            AFW_RANDOM_SEED_3 := IntegerNumber
          ELSE
            BEGIN
              Valid := FALSE;
              Q990_INPUT_ERROR_PROCESSING
            END
        END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  WRITELN;
	  WRITELN ('Enter a number in the range -', MaxInt, ' through ',
              MaxInt)
	END
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL Valid
      OR S01AB_USER_IS_DONE


END;




(**  UserSeed  **************************************************************
****************************************************************************)


BEGIN

  ValidSeedSelectCommands := 'S1 S2 S3 ';
  GetSeed1                := 'S1 ';
  GetSeed2                := 'S2 ';
  GetSeed3                := 'S3 ';

  REPEAT
    BEGIN
      IF S01AA_EXPERT_MODE_OFF THEN
	BEGIN
	  WRITELN;
          WRITELN ('PRESENT VALUES:');
          WRITELN ('  S1 = ', AFU_RANDOM_SEED_1);
          WRITELN ('  S2 = ', AFV_RANDOM_SEED_2);
          WRITELN ('  S3 = ', AFW_RANDOM_SEED_3);
	  WRITELN;
	  WRITELN ('SELECT SEED (S1, S2, S3)');
	  WRITELN;
	  WRITE ('>')
	END;
      S01_PROCESS_REQUEST;
      IF POS (S01AI_LENGTH_3_RESPONSE, ValidSeedSelectCommands) > 0 THEN
	BEGIN
	  IF S01AI_LENGTH_3_RESPONSE = GetSeed1 THEN
	    RequestSeed (1)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = GetSeed2 THEN
	    RequestSeed (2)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = GetSeed3 THEN
	    RequestSeed (3);
	  IF NOT S01AD_END_EXECUTION_DESIRED THEN
	    S01AB_USER_IS_DONE := FALSE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  WRITELN;
	  WRITELN ('The random number generator uses three seeds.  You');
	  WRITELN ('may select, and then revise, any of these seeds by');
          WRITELN ('first entering the appropriate command, i.e., S1');
          WRITELN ('(for seed 1), etc.')
	END
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  SeedRandomNumberGenerator  *********************************************
****************************************************************************)

PROCEDURE SeedRandomNumberGenerator;

  VAR
      ValidUserSeedCommands : STRING [12];
      RequestUserSeeds      : STRING [6];
      SeedFromSystemClock   : STRING [6];

BEGIN

  ValidUserSeedCommands := 'KEYIN CLOCK ';
  RequestUserSeeds      := 'KEYIN ';
  SeedFromSystemClock   := 'CLOCK ';

  REPEAT
    BEGIN
      IF S01AA_EXPERT_MODE_OFF THEN
	BEGIN
	  WRITELN;
	  WRITELN ('ENTER SEED COMMAND (KEYIN, CLOCK)');
	  WRITELN;
	  WRITE ('>')
	END;
      S01_PROCESS_REQUEST;
      IF POS (S01AI_LENGTH_3_RESPONSE, ValidUserSeedCommands) > 0 THEN
	BEGIN
	  IF S01AK_LENGTH_6_RESPONSE = RequestUserSeeds THEN
	    UserSeed
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = SeedFromSystemClock THEN
	    SeedFromClock;
	  IF NOT S01AD_END_EXECUTION_DESIRED THEN
	    S01AB_USER_IS_DONE := FALSE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  WRITELN;
	  WRITELN ('The random number generator uses three seeds.  At');
	  WRITELN ('program startup, the random number generator is seeded');
          WRITELN ('from the system clock.  The random number generator');
          WRITELN ('may be re-seeded at any time from the system clock by');
          WRITELN ('use of the CLOCK command.  Alternatively, the three');
          WRITELN ('seeds may be revised manually by use of the KEYIN');
          WRITELN ('command.')
	END
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  LADSRandomUnit  ********************************************************
****************************************************************************)


BEGIN

  SeedFromClock

END.

