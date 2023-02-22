UNIT LADSFileProcUnit;

INTERFACE

uses SysUtils;

PROCEDURE X05_SIMPLE_WRITE_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X06_SIMPLE_WRITE_RECURSIVE_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X07_SIMPLE_WRITE_OUTPUT_RAY (VAR NoErrors : BOOLEAN);
PROCEDURE X10_SIMPLE_WRITE_DIFF (VAR NoErrors : BOOLEAN);
PROCEDURE X15_REWIND_AND_READ_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X16_REWIND_AND_READ_RECURSIVE_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X17_REWIND_RECURSIVE_INTRCPT;
PROCEDURE X20_REWIND_AND_READ_DIFF (VAR NoErrors : BOOLEAN);
PROCEDURE X30_UPDATE_AND_READ_DIFF (VAR NoErrors : BOOLEAN);
PROCEDURE X35_SIMPLE_READ_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X36_SIMPLE_READ_RECURSIVE_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X37_SEEK_AND_READ_RECURSIVE_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X40_SIMPLE_READ_DIFF (VAR NoErrors : BOOLEAN);
PROCEDURE X45_WRITE_LAST_BLOCK_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X46_WRITE_LAST_BLOCK_RECURS_INTRCPT (VAR NoErrors : BOOLEAN);
PROCEDURE X47_WRITE_LAST_BLOCK_OUTRAY (VAR NoErrors : BOOLEAN);
PROCEDURE X50_WRITE_LAST_BLOCK_DIFF (VAR NoErrors : BOOLEAN);

IMPLEMENTATION

  USES LADSData,
       LADSTraceUnit,
       LADSCommandIOMemoUnit;

  CONST
      MaxSlotsPerBlock = 8;
       
       
(**  X05_SIMPLE_WRITE_INTRCPT  ***********************************************
******************************************************************************)


PROCEDURE X05_SIMPLE_WRITE_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN
  
  ZZA_INTERCEPT_DATA_BLOCK.ZXB_BLOCK_DATA [ARP_INTRCPT_BLOCK_SLOT].
      ZXC_REAL_VALUES :=
      ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA;
      
  ARP_INTRCPT_BLOCK_SLOT := ARP_INTRCPT_BLOCK_SLOT + 1;
  
  IF ARP_INTRCPT_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ARP_INTRCPT_BLOCK_SLOT := 1;
    (*SEEK (ZAI_INTERCEPT_WORK_FILE, ARQ_INTRCPT_BLOCK_NMBR);*)
      BLOCKWRITE (ZAI_INTERCEPT_WORK_FILE, ZZA_INTERCEPT_DATA_BLOCK, 1, N);
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ERROR IN WRITING TO FILE');
	  CommandIOMemo.IOHistory.Lines.add ('AT RELATIVE BLOCK #' +
              IntToStr (ARQ_INTRCPT_BLOCK_NMBR) + ', AT X05.1.');
	  NoErrors := FALSE
	END
      ELSE
	ARQ_INTRCPT_BLOCK_NMBR := ARQ_INTRCPT_BLOCK_NMBR + 1
    END

END;




(**  X06_SIMPLE_WRITE_RECURSIVE_INTRCPT	 **************************************
******************************************************************************)


PROCEDURE X06_SIMPLE_WRITE_RECURSIVE_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN
  
  ZZB_RECURS_INTERCEPT_DATA_BLOCK.ZXB_BLOCK_DATA [ARC_RECURS_INT_BLOCK_SLOT].
      ZXC_REAL_VALUES := ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA;
  
  ARC_RECURS_INT_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT + 1;
  
  IF ARC_RECURS_INT_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ARC_RECURS_INT_BLOCK_SLOT := 1;
    (*SEEK (ZAK_RECURS_INTERCEPT_WORK_FILE, ARW_RECURS_INT_BLOCK_NMBR);*)
      BLOCKWRITE (ZAK_RECURS_INTERCEPT_WORK_FILE,
	  ZZB_RECURS_INTERCEPT_DATA_BLOCK, 1, N);
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ERROR IN WRITING TO FILE');
	  CommandIOMemo.IOHistory.Lines.add ('AT RELATIVE BLOCK #' +
              IntToStr (ARW_RECURS_INT_BLOCK_NMBR) + ', AT X06.1.');
	  NoErrors := FALSE
	END
      ELSE
	ARW_RECURS_INT_BLOCK_NMBR := ARW_RECURS_INT_BLOCK_NMBR + 1
    END
    
END;




(**  X07_SIMPLE_WRITE_OUTPUT_RAY  ********************************************
******************************************************************************)


PROCEDURE X07_SIMPLE_WRITE_OUTPUT_RAY;

  VAR
      N	 : INTEGER;

BEGIN
  
  ZZC_OUTRAY_DATA_BLOCK.ZXB_BLOCK_DATA [ASA_OUTRAY_BLOCK_SLOT].
      ZXC_REAL_VALUES :=
      ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA;
  
  ASA_OUTRAY_BLOCK_SLOT := ASA_OUTRAY_BLOCK_SLOT + 1;
  
  IF ASA_OUTRAY_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ASA_OUTRAY_BLOCK_SLOT := 1;
    (*SEEK (ZAL_OUTPUT_RAY_FILE, ASB_OUTRAY_BLOCK_NMBR);*)
      BLOCKWRITE (ZAL_OUTPUT_RAY_FILE, ZZC_OUTRAY_DATA_BLOCK, 1, N);
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR IN WRITING TO OUTPUT RAY FILE');
	  CommandIOMemo.IOHistory.Lines.add ('AT RELATIVE BLOCK #' +
              IntToStr (ASB_OUTRAY_BLOCK_NMBR) + ', AT X07.1.');
	  NoErrors := FALSE
	END
      ELSE
	ASB_OUTRAY_BLOCK_NMBR := ASB_OUTRAY_BLOCK_NMBR + 1
    END

END;




(**  X10_SIMPLE_WRITE_DIFF  **************************************************
******************************************************************************)


PROCEDURE X10_SIMPLE_WRITE_DIFF;

  VAR
      N	 : INTEGER;

BEGIN
  
  ZYA_DIFFRACTION_DATA_BLOCK.ZXB_BLOCK_DATA [ARR_DIFF_BLOCK_SLOT].
      ZXC_REAL_VALUES :=
      ZTA_DIFFRACTION_DATA.ZTJ_ALL_DIFFRACTION_DATA;
  
  ARR_DIFF_BLOCK_SLOT := ARR_DIFF_BLOCK_SLOT + 1;
  
  IF ARR_DIFF_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ARR_DIFF_BLOCK_SLOT := 1;
    (*SEEK (ZAJ_DIFFRACT_WORK_FILE, ARS_DIFF_BLOCK_NMBR);*)
      BLOCKWRITE (ZAJ_DIFFRACT_WORK_FILE, ZYA_DIFFRACTION_DATA_BLOCK, 1, N);
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ERROR IN WRITING TO FILE');
	  CommandIOMemo.IOHistory.Lines.add ('AT RELATIVE BLOCK #' +
              IntToStr (ARS_DIFF_BLOCK_NMBR) + ', AT X10.1.');
	  NoErrors := FALSE
	END
      ELSE
	ARS_DIFF_BLOCK_NMBR := ARS_DIFF_BLOCK_NMBR + 1
    END

END;




(**  X15_REWIND_AND_READ_INTRCPT  ********************************************
******************************************************************************)


PROCEDURE X15_REWIND_AND_READ_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN
  
  ARQ_INTRCPT_BLOCK_NMBR := 0;
  ARP_INTRCPT_BLOCK_SLOT := 1;
  
  SEEK (ZAI_INTERCEPT_WORK_FILE, ARQ_INTRCPT_BLOCK_NMBR);
  
  BLOCKREAD (ZAI_INTERCEPT_WORK_FILE, ZZA_INTERCEPT_DATA_BLOCK, 1, N);
  
  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO READ FROM FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARQ_INTRCPT_BLOCK_NMBR) + ', AT X15.1.');
      NoErrors := FALSE
    END
  ELSE
    ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
	ZZA_INTERCEPT_DATA_BLOCK.
	ZXB_BLOCK_DATA [ARP_INTRCPT_BLOCK_SLOT].ZXC_REAL_VALUES

END;




(**  X16_REWIND_AND_READ_RECURSIVE_INTRCPT  ***********************************
******************************************************************************)


PROCEDURE X16_REWIND_AND_READ_RECURSIVE_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN

  ARW_RECURS_INT_BLOCK_NMBR := 0;

  SEEK (ZAK_RECURS_INTERCEPT_WORK_FILE, ARW_RECURS_INT_BLOCK_NMBR);
  
  BLOCKREAD (ZAK_RECURS_INTERCEPT_WORK_FILE,
      ZZB_RECURS_INTERCEPT_DATA_BLOCK, 1, N);
  
  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO READ FROM FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARW_RECURS_INT_BLOCK_NMBR) + ', AT X16.1.');
      NoErrors := FALSE
    END
  ELSE
    ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
	ZZB_RECURS_INTERCEPT_DATA_BLOCK.
	ZXB_BLOCK_DATA [ARC_RECURS_INT_BLOCK_SLOT].ZXC_REAL_VALUES

END;




(**  X17_REWIND_RECURSIVE_INTRCPT  ********************************************
******************************************************************************)


PROCEDURE X17_REWIND_RECURSIVE_INTRCPT;

BEGIN

  ARW_RECURS_INT_BLOCK_NMBR := 0;

  SEEK (ZAK_RECURS_INTERCEPT_WORK_FILE, ARW_RECURS_INT_BLOCK_NMBR)

END;




(**  X20_REWIND_AND_READ_DIFF  ***********************************************
******************************************************************************)


PROCEDURE X20_REWIND_AND_READ_DIFF;

  VAR
      N	 : INTEGER;

BEGIN

  ARS_DIFF_BLOCK_NMBR := 0;
  ARR_DIFF_BLOCK_SLOT := 1;

  SEEK (ZAJ_DIFFRACT_WORK_FILE, ARS_DIFF_BLOCK_NMBR);

  BLOCKREAD (ZAJ_DIFFRACT_WORK_FILE, ZYA_DIFFRACTION_DATA_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO READ FROM FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARS_DIFF_BLOCK_NMBR) + ', AT X20.1.');
      NoErrors := FALSE
    END
  ELSE
    ZTA_DIFFRACTION_DATA.ZTJ_ALL_DIFFRACTION_DATA :=
	ZYA_DIFFRACTION_DATA_BLOCK.
	ZXB_BLOCK_DATA [ARR_DIFF_BLOCK_SLOT].ZXC_REAL_VALUES

END;




(**  X30_UPDATE_AND_READ_DIFF  ***********************************************
******************************************************************************)


PROCEDURE X30_UPDATE_AND_READ_DIFF;

  VAR
      N	 : INTEGER;

BEGIN

  ZYA_DIFFRACTION_DATA_BLOCK.ZXB_BLOCK_DATA [ARR_DIFF_BLOCK_SLOT].
      ZXC_REAL_VALUES :=
      ZTA_DIFFRACTION_DATA.ZTJ_ALL_DIFFRACTION_DATA;

  ARR_DIFF_BLOCK_SLOT := ARR_DIFF_BLOCK_SLOT + 1;

  IF ARR_DIFF_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      SEEK (ZAJ_DIFFRACT_WORK_FILE, ARS_DIFF_BLOCK_NMBR);
      BLOCKWRITE (ZAJ_DIFFRACT_WORK_FILE, ZYA_DIFFRACTION_DATA_BLOCK, 1, N);
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO WRITE TO FILE');
	  CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	      IntToStr (ARS_DIFF_BLOCK_NMBR) + ', AT X30.1.');
	  NoErrors := FALSE
	END
      ELSE
	BEGIN
	  ARS_DIFF_BLOCK_NMBR := ARS_DIFF_BLOCK_NMBR + 1;
	  ARR_DIFF_BLOCK_SLOT := 1;
	(*SEEK (ZAJ_DIFFRACT_WORK_FILE, ARS_DIFF_BLOCK_NMBR);*)
	  BLOCKREAD (ZAJ_DIFFRACT_WORK_FILE,
	      ZYA_DIFFRACTION_DATA_BLOCK, 1, N);
	  IF EOF (ZAJ_DIFFRACT_WORK_FILE) THEN
	    BEGIN
	    END
	  ELSE
	  IF N <> 1 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('ERROR: ATTEMPT TO READ FROM FILE');
	      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
		  IntToStr (ARS_DIFF_BLOCK_NMBR) + ', AT X30.2.');
	      NoErrors := FALSE
	    END
	END
    END;

  ZTA_DIFFRACTION_DATA.ZTJ_ALL_DIFFRACTION_DATA :=
      ZYA_DIFFRACTION_DATA_BLOCK.ZXB_BLOCK_DATA [ARR_DIFF_BLOCK_SLOT].
      ZXC_REAL_VALUES

END;




(**  X35_SIMPLE_READ_INTRCPT  ************************************************
******************************************************************************)


PROCEDURE X35_SIMPLE_READ_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN

  ARP_INTRCPT_BLOCK_SLOT := ARP_INTRCPT_BLOCK_SLOT + 1;

  IF ARP_INTRCPT_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ARQ_INTRCPT_BLOCK_NMBR := ARQ_INTRCPT_BLOCK_NMBR + 1;
      ARP_INTRCPT_BLOCK_SLOT := 1;
    (*SEEK (ZAI_INTERCEPT_WORK_FILE, ARQ_INTRCPT_BLOCK_NMBR);*)
      BLOCKREAD (ZAI_INTERCEPT_WORK_FILE, ZZA_INTERCEPT_DATA_BLOCK, 1, N);
      IF EOF (ZAI_INTERCEPT_WORK_FILE) THEN
	BEGIN
	END
      ELSE
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR: ATTEMPT TO READ FROM FILE');
	  CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	      IntToStr (ARQ_INTRCPT_BLOCK_NMBR) + ', AT X35.3.');
	  NoErrors := FALSE
	END
    END;

  ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
      ZZA_INTERCEPT_DATA_BLOCK.ZXB_BLOCK_DATA [ARP_INTRCPT_BLOCK_SLOT].
      ZXC_REAL_VALUES

END;




(**  X36_SIMPLE_READ_RECURSIVE_INTRCPT	***************************************
******************************************************************************)


PROCEDURE X36_SIMPLE_READ_RECURSIVE_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN

  ARC_RECURS_INT_BLOCK_SLOT := ARC_RECURS_INT_BLOCK_SLOT + 1;

  IF ARC_RECURS_INT_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ARW_RECURS_INT_BLOCK_NMBR := ARW_RECURS_INT_BLOCK_NMBR + 1;
      ARC_RECURS_INT_BLOCK_SLOT := 1;
    (*SEEK (ZAK_RECURS_INTERCEPT_WORK_FILE, ARW_RECURS_INT_BLOCK_NMBR);*)
      BLOCKREAD (ZAK_RECURS_INTERCEPT_WORK_FILE,
	  ZZB_RECURS_INTERCEPT_DATA_BLOCK, 1, N);
      IF EOF (ZAK_RECURS_INTERCEPT_WORK_FILE) THEN
	BEGIN
	END
      ELSE
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO READ FROM FILE');
	  CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	      IntToStr (ARW_RECURS_INT_BLOCK_NMBR) + ', AT X36.1.');
	  NoErrors := FALSE
	END
    END;

  ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
      ZZB_RECURS_INTERCEPT_DATA_BLOCK.
      ZXB_BLOCK_DATA [ARC_RECURS_INT_BLOCK_SLOT].ZXC_REAL_VALUES

END;




(**  X37_SEEK_AND_READ_RECURSIVE_INTRCPT  ************************************
******************************************************************************)


PROCEDURE X37_SEEK_AND_READ_RECURSIVE_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN

  SEEK (ZAK_RECURS_INTERCEPT_WORK_FILE, ARW_RECURS_INT_BLOCK_NMBR);

  BLOCKREAD (ZAK_RECURS_INTERCEPT_WORK_FILE,
      ZZB_RECURS_INTERCEPT_DATA_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO READ FROM FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARW_RECURS_INT_BLOCK_NMBR) + ', AT X37.1.');
      NoErrors := FALSE
    END
  ELSE
    ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
	ZZB_RECURS_INTERCEPT_DATA_BLOCK.
	ZXB_BLOCK_DATA [ARC_RECURS_INT_BLOCK_SLOT].ZXC_REAL_VALUES

END;




(**  X40_SIMPLE_READ_DIFF  ***************************************************
******************************************************************************)


PROCEDURE X40_SIMPLE_READ_DIFF;

  VAR
      N	 : INTEGER;

BEGIN

  ARR_DIFF_BLOCK_SLOT := ARR_DIFF_BLOCK_SLOT + 1;

  IF ARR_DIFF_BLOCK_SLOT > MaxSlotsPerBlock THEN
    BEGIN
      ARS_DIFF_BLOCK_NMBR := ARS_DIFF_BLOCK_NMBR + 1;
      ARR_DIFF_BLOCK_SLOT := 1;
    (*SEEK (ZAJ_DIFFRACT_WORK_FILE, ARS_DIFF_BLOCK_NMBR);*)
      BLOCKREAD (ZAJ_DIFFRACT_WORK_FILE, ZYA_DIFFRACTION_DATA_BLOCK, 1, N);
      IF EOF (ZAJ_DIFFRACT_WORK_FILE) THEN
	BEGIN
	END
      ELSE
      IF N <> 1 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR: ATTEMPT TO READ FROM FILE');
	  CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	      IntToStr (ARS_DIFF_BLOCK_NMBR) + ', AT X40.1.');
	  NoErrors := FALSE
	END
    END;

  ZTA_DIFFRACTION_DATA.ZTJ_ALL_DIFFRACTION_DATA :=
      ZYA_DIFFRACTION_DATA_BLOCK.ZXB_BLOCK_DATA [ARR_DIFF_BLOCK_SLOT].
      ZXC_REAL_VALUES

END;




(**  X45_WRITE_LAST_BLOCK_INTRCPT  *******************************************
******************************************************************************)


PROCEDURE X45_WRITE_LAST_BLOCK_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN

(*SEEK (ZAI_INTERCEPT_WORK_FILE, ARQ_INTRCPT_BLOCK_NMBR);*)

  BLOCKWRITE (ZAI_INTERCEPT_WORK_FILE, ZZA_INTERCEPT_DATA_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO WRITE TO FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARQ_INTRCPT_BLOCK_NMBR) + ', AT X45.1.');
      NoErrors := FALSE
    END

END;




(**  X46_WRITE_LAST_BLOCK_RECURS_INTRCPT  *************************************
******************************************************************************)


PROCEDURE X46_WRITE_LAST_BLOCK_RECURS_INTRCPT;

  VAR
      N	 : INTEGER;

BEGIN

(*SEEK (ZAK_RECURS_INTERCEPT_WORK_FILE, ARW_RECURS_INT_BLOCK_NMBR);*)

  BLOCKWRITE (ZAK_RECURS_INTERCEPT_WORK_FILE,
      ZZB_RECURS_INTERCEPT_DATA_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO WRITE TO FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARW_RECURS_INT_BLOCK_NMBR) + ', AT X46.1.');
      NoErrors := FALSE
    END

END;




(**  X47_WRITE_LAST_BLOCK_OUTRAY  ********************************************
******************************************************************************)


PROCEDURE X47_WRITE_LAST_BLOCK_OUTRAY;

  VAR
      N	 : INTEGER;

BEGIN

(*SEEK (ZAL_OUTPUT_RAY_FILE, ASB_OUTRAY_BLOCK_NMBR);*)

  BLOCKWRITE (ZAL_OUTPUT_RAY_FILE, ZZC_OUTRAY_DATA_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO WRITE TO OUTPUT RAY FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ASB_OUTRAY_BLOCK_NMBR) + ', AT X47.1.');
      NoErrors := FALSE
    END

END;




(**  X50_WRITE_LAST_BLOCK_DIFF	**********************************************
******************************************************************************)


PROCEDURE X50_WRITE_LAST_BLOCK_DIFF;

  VAR
      N	 : INTEGER;

BEGIN

(*SEEK (ZAJ_DIFFRACT_WORK_FILE, ARS_DIFF_BLOCK_NMBR);*)

  BLOCKWRITE (ZAJ_DIFFRACT_WORK_FILE, ZYA_DIFFRACTION_DATA_BLOCK, 1, N);

  IF N <> 1 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR: ATTEMPT TO WRITE TO FILE');
      CommandIOMemo.IOHistory.Lines.add ('FAILED AT RELATIVE BLOCK #' +
	  IntToStr (ARS_DIFF_BLOCK_NMBR) + ', AT X50.1.');
      NoErrors := FALSE
    END

END;




(**  LADSX  ******************************************************************
*****************************************************************************)


BEGIN

END.

