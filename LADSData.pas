UNIT LADSData;

INTERFACE

  USES
    Graphics,
    LADSGlassVar,
    LADSUtilUnit;

  CONST

    UserNeedsHelp                          = 'HELP';
    PI				                             = 3.1415926535897932;
    CZBP_NORMAL_PROCESSING_SEQUENCE	       = 1;
    CZBQ_REVERSE_PROCESSING_SEQUENCE	     = 2;
    CZBR_AUTO_SEQUENCING		               = 3;
    CZBS_USER_SPECIFIED_SEQUENCE	         = 4;
    DefaultRings              	           = 11;
    MaxNumberOfRings          	           = 500;
    CZAI_MAX_DEFORM_CONSTANTS		           = 10;
    CZBC_DEFAULT_BUNDLE_HEAD_DIA   	       = 1.0;
    DefaultMaxZenithDistance               = 30.0;
    DefaultMinZenithDistance               = 0.0;
    DefaultAzimuthCenter                   = 0.0;
    DefaultAzimuthSemiLength               = 180.0;
    CZBD_DEFAULT_COMPUTED_RAY_COUNT	       = 0;
    CZBK_LOWEST_ACCEPTABLE_RAY_INTENSITY   = 0.0001;
    DefaultBeamsplitRatio                  = 0.5;
    MaxBeamsplitRays                       = 10;
    DefaultCPCConicConstant                = 0.0;
    CPCConicConstantError                  = 1.0E-10;
    DefaultCPCRadius                       = 1.0E-10;
    CPCRadiusError                         = 1.0E-10;
    RayAdvanceFactor                       = 0.0001;
    CZBL_DEFAULT_IMAGE_SURFACE	           = 1;
    CZBM_DEFAULT_VIEWPORT_DIAMETER	       = 1.0;
    CZBB_DEFAULT_VIEWPORT_POSITION	       = 0.0;
    CZBN_DEFAULT_SURF_FOR_RAY_WRITE	       = 1;
    MIN_RADIUS                             = 0.0001;
    MAX_RADIUS                             = 10000.0;
    MIN_CONIC_CONSTANT                     = -1000.0;
    MAX_CONIC_CONSTANT                     = 1000.0;
    DEFAULT_GAUSSIAN_BEAM_DIAMETER         = 1.0;
    DefaultGaussianBeamAstigmatism         = 0.0;
    ROOT_3_OVER_3                          = 0.57735026919;
    MAX_SLOTS                              = 5;
    DefaultSurfaceOrdinal                  = 1;
    DefaultRayOrdinal                      = 1;
    DefaultRayCoordinate                   = 0.0;
    DefaultRayHeadZCoordinate              = -1.0;
    DefaultRayTailZCoordinate              = -1E10;
    DefaultRayWavelength                   = 0.5; (* microns *)
    DefaultIncidentMediumIndex             = 1.0;
    DefaultNumberOfRays                    = 1;
    DefaultLensletArrayColumns             = 1;
    DefaultLensletArrayRows                = 1;
    DefaultLensletArrayPitchX              = 0.0;
    DefaultLensletArrayPitchY              = 0.0;
    DefaultRefractiveIndex                 = 1.0;
    DefaultOuterSurfaceDiameter            = 0.0;
    DefaultOuterApertureXDimension         = 1.0;
    DefaultOuterApertureYDimension         = 1.0;
    DefaultInnerApertureDiameter           = 0.0;
    DefaultInnerApertureXDimension         = 1.0;
    DefaultInnerApertureYDimension         = 1.0;
    DefaultRadiusOfCurvature               = 0.0;
    DefaultConicConstant                   = 0.0;
    DefaultScatteringAngle                 = 0.0;
    DefaultSurfaceReflectivity             = 0.0;
    DefaultSurfaceXCoordinate              = 0.0;
    DefaultSurfaceYCoordinate              = 0.0;
    DefaultSurfaceZCoordinate              = 0.0;
    DefaultSurfaceYaw                      = 0.0;
    DefaultSurfacePitch                    = 0.0;
    DefaultSurfaceRoll                     = 0.0;
    DefaultApertureXOffset                 = 0.0;
    DefaultApertureYOffset                 = 0.0;
    DefaultRadialSectorCenterAzimuth       = 0.0;
    DefaultRadialSectorAngularWidth        = 30.0;
    DefaultDeformationConstant             = 0.0;
    DefaultCPCMaxEntraceAngle              = 30.0;
    DefaultCPCRefractiveIndex              = 1.0;
    DefaultCPCExitAngle                    = 70.0;
    DefaultCPCExitApertureRadius           = 1.0;

    (*  THE FOLLOWING 4 CONSTANTS DEFINE THE SIZE OF THE SURFACE DATA
	  ARRAY.  *)

    CZAK_SURFACE_DATA_BOOLEAN_FIELDS	     = 29;
    CZAL_SURFACE_DATA_REAL_FIELDS	         = 46;  (* Was previously 48 *)
    CZAJ_SURFACE_DATA_INTEGER_FIELDS	     = 3;
    CZAM_SIZE_OF_SURFACE_RECORD            = 8 * CZAL_SURFACE_DATA_REAL_FIELDS +
          1 * CZAK_SURFACE_DATA_BOOLEAN_FIELDS +
          4 * CZAJ_SURFACE_DATA_INTEGER_FIELDS;

    (*  THE FOLLOWING 7 CONSTANTS DEFINE THE SIZE OF THE RAY DATA
	  ARRAY.  *)

    CZAC_MAX_NUMBER_OF_RAYS		             = 50;
    CZAD_MAX_COMPUTED_RAYS		             = 10000000;
    CZAN_RAY_DATA_BOOLEAN_FIELDS           = 20;
    RayDataIntegerFields                   = 1;
    RayDataLongintFields                   = 1;
    CZAO_RAY_DATA_REAL_FIELDS	             = 19;
    CZAP_SIZE_OF_RAY_RECORD                = 8 * CZAO_RAY_DATA_REAL_FIELDS +
        4 * RayDataIntegerFields + 4 * RayDataLongintFields +
        1 * CZAN_RAY_DATA_BOOLEAN_FIELDS;

    (*  THE FOLLOWING 7 CONSTANTS DEFINE THE SIZE OF THE OPTION DATA
	  ARRAY.  *)

    CZAB_MAX_NUMBER_OF_SURFACES	           = 150;
    CZBO_MAX_SEQUENCER_GROUPS		           = 10;
    CZAR_OPTION_DATA_INTEGER_FIELDS        = 4 + CZAB_MAX_NUMBER_OF_SURFACES +
        3 * CZBO_MAX_SEQUENCER_GROUPS;
    CZAQ_OPTION_DATA_BOOLEAN_FIELDS        = 20;
    CZAS_OPTION_DATA_REAL_FIELDS           = 4;
    CZAT_OPTION_DATA_STRING_FIELDS         = 5;
    CZAU_SIZE_OF_OPTION_RECORD = CZAQ_OPTION_DATA_BOOLEAN_FIELDS +
      4 * CZAR_OPTION_DATA_INTEGER_FIELDS +
      8 * CZAS_OPTION_DATA_REAL_FIELDS +
      24 * CZAT_OPTION_DATA_STRING_FIELDS;

    CZBG_CHARS_IN_ONE_BLOCK	               = 512;

  TYPE

    ZXE_REAL_VALUES                        = ARRAY [1..8] OF DOUBLE;

    ZDF_ALL_SURFACE_DATA	                 = RECORD
      ZDB_BOOLEAN_DATA		                 : ARRAY
	        [1..CZAK_SURFACE_DATA_BOOLEAN_FIELDS] OF BOOLEAN;
      ZDC_REAL_DATA	         	             : ARRAY
	        [1..CZAL_SURFACE_DATA_REAL_FIELDS] OF DOUBLE;
      ZDD_INTEGER_DATA		                 : ARRAY
	        [1..CZAJ_SURFACE_DATA_INTEGER_FIELDS] OF INTEGER
    END;

    ZDG_SURFACE_ARCHIVE_DATA	             = PACKED ARRAY
        [1..CZAM_SIZE_OF_SURFACE_RECORD] OF CHAR;

    ZGZ_SURFACE_SEQUENCER	                 = ARRAY
        [1..CZAB_MAX_NUMBER_OF_SURFACES] OF INTEGER;

    ZPE_ALL_RAY_DATA		                   = RECORD
      ZPB_BOOLEAN_DATA		                 : ARRAY
	        [1..CZAN_RAY_DATA_BOOLEAN_FIELDS] OF BOOLEAN;
      ZPG_INTEGER_DATA                     : ARRAY
          [1..RayDataIntegerFields] OF INTEGER;
      ZPH_LONGINT_DATA                     : ARRAY
          [1..RayDataLongintFields] OF LONGINT;
      ZPC_REAL_DATA	        	             : ARRAY
	        [1..CZAO_RAY_DATA_REAL_FIELDS] OF DOUBLE
    END;

    ZPF_RAY_ARCHIVE_DATA      	           = PACKED ARRAY
        [1..CZAP_SIZE_OF_RAY_RECORD] OF CHAR;

    ADH_RAY_REC			                       = RECORD CASE INTEGER OF
	    1: (A				                         : DOUBLE;
	        B				                         : DOUBLE;
	        C				                         : DOUBLE;
	        X				                         : DOUBLE;
	        Y				                         : DOUBLE;
	        Z				                         : DOUBLE);
	    2: (ALL				                       : ARRAY [1..6] OF DOUBLE)
	  END;

    BeamsplitRayRec                        = RECORD CASE INTEGER OF
      1: (A                                : DOUBLE;
	        B                                : DOUBLE;
	        C                                : DOUBLE;
	        X                                : DOUBLE;
	        Y                                : DOUBLE;
	        Z                                : DOUBLE;
	        Wavelength                       : SINGLE;
	        Intensity                        : SINGLE;
	        ExitIndex                        : DOUBLE);
	    2: (All                              : ZXE_REAL_VALUES)
	  END;

    SurfaceFormTypes = (Conic, HighOrderAsphere, CPC, HybridCPC);

    SurfaceSequencerGroupControlCodes      = (GroupInactive, GroupActive);

    OPTION_DATA_REC    		                 = RECORD
	    ZFT_BOOLEAN_DATA		                 : ARRAY
	        [1..CZAQ_OPTION_DATA_BOOLEAN_FIELDS] OF BOOLEAN;
	    ZFU_STRING_DATA		                   : ARRAY
	        [1..CZAT_OPTION_DATA_STRING_FIELDS]  OF STRING [23];
	    ZFV_INTEGER_DATA		                 : ARRAY
	        [1..CZAR_OPTION_DATA_INTEGER_FIELDS] OF INTEGER;
	    ZFW_REAL_DATA		                     : ARRAY
	        [1..CZAS_OPTION_DATA_REAL_FIELDS]    OF DOUBLE
    END;

    OPTION_ARCHIVE_REC                     = PACKED ARRAY
	      [1..CZAU_SIZE_OF_OPTION_RECORD] OF CHAR;

    ZXA_INPUT_OUTPUT_BLOCK		             = RECORD CASE INTEGER OF
	    1: (ZXB_BLOCK_DATA		               : ARRAY [1..8] OF RECORD
	          ZXC_REAL_VALUES		             : ZXE_REAL_VALUES
          END);
	    2: (ZXD_ALL_BLOCK_DATA		           : PACKED ARRAY
		         [1..CZBG_CHARS_IN_ONE_BLOCK] OF CHAR)
    END;

  VAR

    ZBA_SURFACE			                       : ARRAY
	       [1..CZAB_MAX_NUMBER_OF_SURFACES] OF RECORD CASE INTEGER OF
	    1: (ZBB_SPECIFIED		                 : BOOLEAN;
	        ZBC_ACTIVE			                 : BOOLEAN;
	        ZBD_REFLECTIVE		               : BOOLEAN;
	        ZBE_CYLINDRICAL		               : BOOLEAN;
	        ZBZ_SURFACE_IS_FLAT		           : BOOLEAN;
	        ZBH_OUTSIDE_DIMENS_SPECD	       : BOOLEAN;
	        ZCT_INSIDE_DIMENS_SPECD	         : BOOLEAN;
	        ZCL_OUTSIDE_APERTURE_IS_SQR	     : BOOLEAN;
	        ZCM_INSIDE_APERTURE_IS_SQR	     : BOOLEAN;
	        ZCN_OUTSIDE_APERTURE_ELLIPTICAL  : BOOLEAN;
	        ZCO_INSIDE_APERTURE_ELLIPTICAL   : BOOLEAN;
          LensletArray                     : BOOLEAN; (* New item. *)
	        ZBF_OPD_REFERENCE		             : BOOLEAN;
          SurfaceForm                      : SurfaceFormTypes;
	        ZCF_GLASS_NAME_SPECIFIED	       : ARRAY [1..2] OF BOOLEAN;
	        ZCI_RAY_TERMINATION_SURFACE	     : BOOLEAN;
	        ZBY_BEAMSPLITTER_SURFACE	       : BOOLEAN;
	        ZCC_SCATTERING_SURFACE	         : BOOLEAN;
	        ZMB_OPTIMIZATION_SWITCHES	       : RECORD
		        ZMC_OPTIMIZE_RADIUS	           : BOOLEAN;
		        ZMD_ENFORCE_RADIUS_BOUNDS      : BOOLEAN;
		        ZME_PERMIT_SURF_PITCH_REVERSAL : BOOLEAN;
		        ZMG_OPTIMIZE_POSITION	         : BOOLEAN;
		        ZMI_OPTIMIZE_GLASS	           : BOOLEAN;
		        ZMJ_USE_PREFERRED_GLASS	       : BOOLEAN;
		        ZMK_OPTIMIZE_CONIC_CONSTANT    : BOOLEAN;
		        ZML_ENFORCE_CONIC_CONST_BOUNDS : BOOLEAN;
		        ZMM_CONTROL_SEPARATION	       : BOOLEAN;
            Unused                         : BOOLEAN;
          END;
	        ZBG_RADIUS_OF_CURV		           : DOUBLE;
	        ZCG_INDEX_OR_GLASS		           : ARRAY [1..2] OF ZCZ_INDEX_RECORD;
	        ZBJ_OUTSIDE_APERTURE_DIA	       : DOUBLE;
	        ZBK_INSIDE_APERTURE_DIA	         : DOUBLE;
	        ZCP_OUTSIDE_APERTURE_WIDTH_X     : DOUBLE;
	        ZCQ_OUTSIDE_APERTURE_WIDTH_Y     : DOUBLE;
	        ZCR_INSIDE_APERTURE_WIDTH_X	     : DOUBLE;
	        ZCS_INSIDE_APERTURE_WIDTH_Y	     : DOUBLE;
	        ZCV_APERTURE_POSITION_X	         : DOUBLE;
	        ZCW_APERTURE_POSITION_Y	         : DOUBLE;
          LensletArrayPitchX               : DOUBLE;   (* New item. *)
          LensletArrayPitchY               : DOUBLE;   (* New item. *)
	        ZBL_CONIC_CONSTANT		           : DOUBLE;
          SurfaceShapeParameters           : RECORD CASE SurfaceFormTypes OF
            HighOrderAsphere               :
              (ZCA_DEFORMATION_CONSTANT    : ARRAY
                  [1..CZAI_MAX_DEFORM_CONSTANTS] OF DOUBLE);
            CPC                            :
              (MaxEntranceAngleInAirDeg    : DOUBLE;
              CPCRefractiveIndex           : DOUBLE;
              ExitAngleDeg                 : DOUBLE;
              RadiusOfOutputAperture       : DOUBLE;
              RadiusOfInputAperture        : DOUBLE;
              MaxEntranceAngleInCPCRad     : DOUBLE;
              MaxPhi                       : DOUBLE;
              MinPhi                       : DOUBLE;
              Unused1                      : DOUBLE;
              Unused2                      : DOUBLE)
          END;
	        ScatteringAngleRadians	         : DOUBLE;
	        ZCK_SURFACE_REFLECTIVITY	       : DOUBLE;
	        ZBM_VERTEX_X		                 : DOUBLE;
	        ZBN_VERTEX_DELTA_X		           : DOUBLE;
	        ZBO_VERTEX_Y		                 : DOUBLE;
	        ZBP_VERTEX_DELTA_Y		           : DOUBLE;
	        ZBQ_VERTEX_Z		                 : DOUBLE;
	        ZBR_VERTEX_DELTA_Z		           : DOUBLE;
	        ZBS_ROLL			                   : DOUBLE;
	        ZBT_DELTA_ROLL		               : DOUBLE;
	        ZBU_PITCH			                   : DOUBLE;
	        ZBV_DELTA_PITCH		               : DOUBLE;
	        ZBW_YAW			                     : DOUBLE;
	        ZBX_DELTA_YAW		                 : DOUBLE;
	        ZMS_RADIUS_BOUND_1		           : DOUBLE;
	        ZMT_RADIUS_BOUND_2		           : DOUBLE;
	        ZMW_CONIC_CONST_BOUND_1	         : DOUBLE;
	        ZMX_CONIC_CONST_BOUND_2	         : DOUBLE;
	        ZMU_POSITION_BOUND_1	           : DOUBLE;
	        ZMV_POSITION_BOUND_2	           : DOUBLE;
	        ZLQ_THICKNESS		                 : DOUBLE;
	        ZLO_DELTA_THICKNESS		           : DOUBLE;
	        ZLN_NEXT_SURFACE		             : INTEGER;
          LensletArrayTotalColumns         : INTEGER;   (* New item. *)
          LensletArrayTotalRows            : INTEGER);  (* New item. *)
	    2: (ZDA_ALL_SURFACE_DATA	           : ZDF_ALL_SURFACE_DATA);
	    3: (ZDE_SURFACE_ARCHIVE_DATA	       : ZDG_SURFACE_ARCHIVE_DATA)
    END;

    ZEA_SURFACE_DATA_INITIALIZER	         : ZDF_ALL_SURFACE_DATA;

    ZNA_RAY				                         : ARRAY
        [1..CZAC_MAX_NUMBER_OF_RAYS] OF RECORD CASE INTEGER OF
	    1: (ZNB_SPECIFIED		                 : BOOLEAN;
	        ZNC_ACTIVE			                 : BOOLEAN;
	        ZFC_TRACE_SYMMETRIC_FAN	         : BOOLEAN;
	        ZFB_TRACE_LINEAR_Y_FAN           : BOOLEAN;
          TraceLinearXFan                  : BOOLEAN;
	        ZFD_TRACE_ASYMMETRIC_FAN	       : BOOLEAN;
	        ZFQ_TRACE_3FAN		               : BOOLEAN;
          TraceSquareGrid                  : BOOLEAN;
	        ZFE_TRACE_HEXAPOLAR_BUNDLE	     : BOOLEAN;
	        ZFF_TRACE_ISOMETRIC_BUNDLE	     : BOOLEAN;
	        ZFG_TRACE_RANDOM_RAYS	           : BOOLEAN;
	        ZGG_TRACE_SOLID_ANGLE_RAYS	     : BOOLEAN;
	        TRACE_GAUSSIAN_RAYS              : BOOLEAN;
          TRACE_LAMBERTIAN_RAYS            : BOOLEAN;
          TraceOrangeSliceRays             : BOOLEAN;
	        HEAD_X_IS_GAUSSIAN               : BOOLEAN;
	        HEAD_Y_IS_GAUSSIAN               : BOOLEAN;
	        TAIL_X_IS_GAUSSIAN               : BOOLEAN;
	        TAIL_Y_IS_GAUSSIAN               : BOOLEAN;
          Unused                           : BOOLEAN;
          NumberOfRings                    : INTEGER;
          NumberOfRaysInFanOrBundle        : LONGINT;
	        MaxZenithDistance                : DOUBLE;
          MinZenithDistance                : DOUBLE;
          AzimuthAngularCenter             : DOUBLE;
          AzimuthAngularSemiLength         : DOUBLE;
	        SIGMA_X_HEAD                     : DOUBLE;
	        SIGMA_Y_HEAD                     : DOUBLE;
	        SIGMA_X_TAIL                     : DOUBLE;
	        SIGMA_Y_TAIL                     : DOUBLE;
          Astigmatism                      : DOUBLE;
          OrangeSliceAngularHalfWidth      : DOUBLE;
	        ZFR_BUNDLE_HEAD_DIAMETER   	     : DOUBLE;
	        ZND_TAIL_X_COORDINATE	           : DOUBLE;
	        ZNE_TAIL_Y_COORDINATE	           : DOUBLE;
	        ZNF_TAIL_Z_COORDINATE	           : DOUBLE;
	        ZNG_HEAD_X_COORDINATE	           : DOUBLE;
	        ZNH_HEAD_Y_COORDINATE	           : DOUBLE;
	        ZNI_HEAD_Z_COORDINATE	           : DOUBLE;
	        ZNJ_WAVELENGTH		               : DOUBLE;
	        ZNK_INCIDENT_MEDIUM_INDEX	       : DOUBLE);
	    2: (ZPA_ALL_RAY_DATA		             : ZPE_ALL_RAY_DATA);
	    3: (ZPD_RAY_ARCHIVE_DATA	           : ZPF_RAY_ARCHIVE_DATA)
    END;

      ZQA_RAY_DATA_INITIALIZER		       : ZPE_ALL_RAY_DATA;

    (**  THE FOLLOWING RECORD RESERVES MEMORY AND DEFINES DATA FIELDS FOR THE
     TRACE OPTIONS.  **)

    ZFA_OPTION    	                       : RECORD CASE INTEGER OF
	    1: (ZGI_RECURSIVE_TRACE		           : BOOLEAN;
	        ZGJ_IMAGE_SURFACE_DESIGNATED     : BOOLEAN;
	        ZFI_PUT_TRACE_DETAIL_ON_CONSOLE  : BOOLEAN;
	        ZFZ_PUT_TRACE_DETAIL_ON_PRINTER  : BOOLEAN;
	        ZGA_PUT_TRACE_DETAIL_ON_FILE     : BOOLEAN;
          DisplayLocalData                 : BOOLEAN;
	        ZFH_DISPLAY_SPOT_DIAGRAM	       : BOOLEAN;
	        DRAW_RAYS                        : BOOLEAN;
          ShowSurfaceNumbers               : BOOLEAN;
	        ZFK_PRODUCE_SPOT_DIAGRAM_FILE    : BOOLEAN;
	        ZGF_DISPLAY_FULL_OPD	           : BOOLEAN;
	        ZGM_DISPLAY_BRIEF_OPD	           : BOOLEAN;
	        ZFL_PRODUCE_PSF_FILE	           : BOOLEAN;
	        ZFJ_PRINT_AREA_INTENSITY_HIST    : BOOLEAN;
	        ZFY_PRINT_RADIUS_INTENSITY_HIST  : BOOLEAN;
          EnableLinearIntensityHist        : BOOLEAN;
	        ZGE_READ_ALTERNATE_RAY_FILE	     : BOOLEAN;
	        ZGN_WRITE_ALTERNATE_RAY_FILE     : BOOLEAN;
	        ZGR_QUIET_ERRORS		             : BOOLEAN;
	        ZGS_USE_SURFACE_SEQUENCER	       : BOOLEAN;
	        ZFM_SPOT_DIAGRAM_FILE_NAME	     : STRING [23];
	        ZFN_PSF_FILE_NAME		             : STRING [23];
	        ZGB_TRACE_DETAIL_FILE	           : STRING [23];
	        ZGO_ALT_INPUT_RAY_FILE_NAME	     : STRING [23];
	        ZGQ_ALT_OUTPUT_RAY_FILE_NAME     : STRING [23];
	        ZGK_DESIGNATED_SURFACE	         : INTEGER;
          ApertureStopSurface              : INTEGER;
	        ZGP_REF_SURF_FOR_RAY_WRITE	     : INTEGER;
	        ZGT_SURFACE_SEQUENCER	           : ZGZ_SURFACE_SEQUENCER;
	        ZGY_SURFACE_SEQUENCER_CONTROL_CODE : INTEGER;
	        ZGU_SURFACE_SEQUENCER_CONTROL    : ARRAY
		          [1..CZBO_MAX_SEQUENCER_GROUPS] OF RECORD
	          ZGV_SEQUENCER_START_SLOT	     : INTEGER;
	          ZGW_SEQUENCER_END_SLOT	       : INTEGER;
	          ZGX_GROUP_PROCESS_CONTROL_CODE : SurfaceSequencerGroupControlCodes
	        END;
	        ZGL_VIEWPORT_DIAMETER	           : DOUBLE;
	        ZGC_VIEWPORT_POSITION_X	         : DOUBLE;
	        ZGD_VIEWPORT_POSITION_Y	         : DOUBLE;
	        ZRA_VIEWPORT_POSITION_Z          : DOUBLE);
	    2: (ZFS_ALL_OPTION_DATA		           : OPTION_DATA_REC);
	    3: (ZFX_OPTION_ARCHIVE_DATA	         : OPTION_ARCHIVE_REC)
    END;

    GraphicsActive                         : BOOLEAN;
    RectangularViewportEnabled             : BOOLEAN;
    EllipticalViewportEnabled              : BOOLEAN;
    CircularViewportEnabled                : BOOLEAN;
    SpotPending                            : BOOLEAN;
    SpotPendingOKToAddIntensity            : BOOLEAN;
    RECURS_INTERCEPT_WORK_FILE_OPEN        : BOOLEAN;
    INTERCEPT_WORK_FILE_OPEN               : BOOLEAN;
    LIST_FILE_OPEN                         : BOOLEAN;
    PRINT_FILE_OPEN                        : BOOLEAN;
    DIFFRACT_WORK_FILE_OPEN                : BOOLEAN;
    OUTPUT_RAY_FILE_OPEN                   : BOOLEAN;
    LineBroken                             : BOOLEAN;
    ColumnAndRowOK                         : BOOLEAN;
    ColumnAndRowOnScreen                   : BOOLEAN;
    F01AD_HEADINGS_NOT_PRINTED	           : BOOLEAN;
    F01AI_TRACE_COMPLETE		               : BOOLEAN;
    F01AB_NO_INTERSECTION		               : BOOLEAN;
    F01AG_RAY_TERMINATION_OCCURRED	       : BOOLEAN;
    F01AE_RAY_VIGNETTING_OCCURRED	         : BOOLEAN;
    F01AS_ALL_DATA_TRANSFERRED	           : BOOLEAN;
    F01AO_TRACING_PRINCIPAL_RAY	           : BOOLEAN;
    F01AM_SUMMING_PATH_LENGTHS	           : BOOLEAN;
    TIR                                    : BOOLEAN;
    CurrentMaterialIsGradientIndex         : BOOLEAN;
    TracingBeamsplitRay                    : BOOLEAN;
    NoMoreRaysToTrace                      : BOOLEAN;
    NoErrors                               : BOOLEAN;
    COORDINATE_ROTATION_NEEDED             : BOOLEAN;
    ParallelLightExists                    : BOOLEAN;
    LSFitOK                                : BOOLEAN;
    TracePrincipalRayOnly                  : BOOLEAN;

    LastInitialIntensityString             : STRING;
    LastAccumIntensityString               : STRING;
    Trash                                  : STRING;

    I					                             : INTEGER;
    J					                             : INTEGER;
    SurfaceOrdinal                         : INTEGER;
    RayOrdinal                             : INTEGER;
    SpotInitialPixelPosition               : INTEGER;
    SpotAccumPixelPosition                 : INTEGER;
    RasterRows       		                   : INTEGER;
    RasterColumns 		                     : INTEGER;
    SpotRadius                             : INTEGER;
    ColumnsInRasterRadius   	             : INTEGER;
    RowsInRasterRadius   	                 : INTEGER;
    ColumnIndex                            : INTEGER;
    RowIndex                               : INTEGER;
    SLOT                                   : INTEGER;
    ARB_TOTAL_RECURS_INTERCEPTS	           : INTEGER;
    F01AH_PREV_WORKING_SURFACE	           : INTEGER;
    ADF_END_OPD_REF_SURFACE		             : INTEGER;
    ADG_BEGIN_OPD_REF_SURFACE		           : INTEGER;
    ARO_DIFF_RECORD_COUNT	                 : INTEGER;
    ARS_DIFF_BLOCK_NMBR                    : INTEGER;
    ARC_RECURS_INT_BLOCK_SLOT	             : INTEGER;
    ARW_RECURS_INT_BLOCK_NMBR              : INTEGER;
    ASA_OUTRAY_BLOCK_SLOT		               : INTEGER;
    ASB_OUTRAY_BLOCK_NMBR                  : INTEGER;
    ARP_INTRCPT_BLOCK_SLOT                 : INTEGER;
    ARQ_INTRCPT_BLOCK_NMBR                 : INTEGER;
    ARR_DIFF_BLOCK_SLOT		                 : INTEGER;
    F01BK_LAST_GLASS			                 : INTEGER;
    F01BL_LAST_WAVELENGTH		               : INTEGER;
    ADA_LAST_RAY                           : INTEGER;
    F01AP_TEMP_SEQ_HI_INDEX		             : INTEGER;
    BSIndex                                : INTEGER;
    ARL_SEQUENCER_HI_INDEX                 : INTEGER;
    HistogramBuckets                       : INTEGER;

    AAA_TOTAL_RAYS_TO_TRACE		             : LONGINT;
    F01AF_RAY_COUNTER			                 : LONGINT;
    ASC_OUTPUT_RAY_COUNT	                 : LONGINT;

    F01AN_TEMPORARY_SEQUENCER		           : ZGZ_SURFACE_SEQUENCER;

    RAY0				                           : ADH_RAY_REC;
    RAY1				                           : ADH_RAY_REC;
    RAY_OLD				                         : ADH_RAY_REC;

    BeamsplitRays                          : ARRAY [1..MaxBeamsplitRays] of
                                                BeamsplitRayRec;

    RasterCenterColumn  	                 : DOUBLE;
    RasterCenterRow  		                   : DOUBLE;
    HoldXaspect                            : DOUBLE;
    HoldYaspect                            : DOUBLE;
    SpotX                                  : DOUBLE;
    SpotY                                  : DOUBLE;
    SpotPendingIntensity                   : DOUBLE;
    SpotPendingDiameter                    : DOUBLE;
    SpotPendingInterceptX                  : DOUBLE;
    SpotPendingInterceptY                  : DOUBLE;
    SpotPendingInterceptZ                  : DOUBLE;
    SpotPendingRefIndex                    : DOUBLE;
    HORIZONTAL_DISPLACEMENT                : DOUBLE;
    VERTICAL_DISPLACEMENT                  : DOUBLE;
    D1				                             : DOUBLE;
    CC				                             : DOUBLE;
    C					                             : ARRAY
        [1..CZAI_MAX_DEFORM_CONSTANTS] OF DOUBLE;
    P                                      : DOUBLE;
    Q                                      : DOUBLE;
    R					                             : DOUBLE;
    RR				                             : DOUBLE;
    HH				                             : DOUBLE;
    H4				                             : DOUBLE;
    H6				                             : DOUBLE;
    H8				                             : DOUBLE;
    H10				                             : DOUBLE;
    H12				                             : DOUBLE;
    H14				                             : DOUBLE;
    H16				                             : DOUBLE;
    H18				                             : DOUBLE;
    H20				                             : DOUBLE;
    H22				                             : DOUBLE;
    SQRT_RR_MINUS_HH			                 : DOUBLE;
    N0				                             : DOUBLE;
    N1				                             : DOUBLE;
    N2				                             : DOUBLE;
    F01AT_PATH_LENGTH			                 : DOUBLE;
    NX				                             : DOUBLE;
    NY				                             : DOUBLE;
    NZ				                             : DOUBLE;
    NXWorld                                : DOUBLE;
    NYWorld                                : DOUBLE;
    NZWorld                                : DOUBLE;
    LocalXDirection                        : DOUBLE;
    LocalYDirection                        : DOUBLE;
    LocalZDirection                        : DOUBLE;
    LocalXIntercept                        : DOUBLE;
    LocalYIntercept                        : DOUBLE;
    LocalZIntercept                        : DOUBLE;
    LocalIncidentAngle                     : DOUBLE;
    LocalExitAngle                         : DOUBLE;

    TEMP_RADIUS_AND_CC                     : ARRAY [1..MAX_SLOTS] OF RECORD
      SURFACE_ORD                          : INTEGER;
      TEMP_CC                              : DOUBLE;
      TEMP_R                               : DOUBLE
    END;

    ALR_DEGREES_PER_RADIAN		             : DOUBLE;
    ARD_BLUR_SPHERE_DIAMETER		           : DOUBLE;
    ARF_RMS_SPOT_DIAMETER		               : DOUBLE;
    MeritFunction                          : DOUBLE;
    ARG_SPOT_X_CENTROID		                 : DOUBLE;
    ARH_SPOT_Y_CENTROID		                 : DOUBLE;
    ARI_SPOT_Z_CENTROID		                 : DOUBLE;
    SpotCentroidGlobalCoordsX              : DOUBLE;
    SpotCentroidGlobalCoordsY              : DOUBLE;
    SpotCentroidGlobalCoordsZ              : DOUBLE;
    ARK_ENCLOSED_SPOT_RMS_DIA		           : DOUBLE;
    ARN_MAX_IMAGE_DIAMETER		             : DOUBLE;
    ARX_ACCUM_INITIAL_INTENSITY	           : DOUBLE;
    ARY_ACCUM_FINAL_INTENSITY		           : DOUBLE;
    HoldX                                  : DOUBLE;
    HoldY                                  : DOUBLE;
    HoldZ                                  : DOUBLE;
    RayHeadXShift                          : DOUBLE;
    RayHeadYShift                          : DOUBLE;
    RayHeadZShift                          : DOUBLE;
    TempHoldIncidentRayTailXCoord          : DOUBLE;
    TempHoldIncidentRayTailYCoord          : DOUBLE;
    LensletXCoordinate                     : DOUBLE;
    LensletYCoordinate                     : DOUBLE;
    AimError                               : DOUBLE;
    BHR			                               : DOUBLE;
    X0			                               : DOUBLE;
    Y0			                               : DOUBLE;
    Z0			                               : DOUBLE;
    A1			                               : DOUBLE;
    B1			                               : DOUBLE;
    C1			                               : DOUBLE;

    RayRotationMatrix                      : RotationMatrix;

    ZVA_ROTATION_MATRIX		                 : ARRAY
        [1..CZAB_MAX_NUMBER_OF_SURFACES] OF RECORD
      SurfaceRotationMatrix                : RotationMatrix;
      ZVK_COORDINATE_TRANSLATION_NEEDED    : BOOLEAN;
      ZVL_COORDINATE_ROTATION_NEEDED	     : BOOLEAN
    END;

      (* The following data area is the workspace for migrating a ray through
      an optical system, while keeping track of the intensity of the ray as it
      gets derated via surface interactions or other processes.

      The A1, B1, C1, X1, Y1, and Z1 variables refer to the post-interaction
      direction cosines and current surface intercept respectively.  The
      intensity variable is the post-interaction intensity.

      This work area should have been named RayWorkArea, or some such. *)

    ZSA_SURFACE_INTERCEPTS                 : RECORD CASE INTEGER OF
      1: (ZSB_A1                           : DOUBLE;
          ZSC_B1                           : DOUBLE;
	        ZSD_C1                           : DOUBLE;
	        ZSE_X1                           : DOUBLE;
	        ZSF_Y1                           : DOUBLE;
	        ZSG_Z1                           : DOUBLE;
	        ZSL_WAVELENGTH                   : SINGLE;
	        ZSH_INTENSITY                    : SINGLE; (* post-interaction *)
	        ZSP_EXIT_INDEX                   : DOUBLE);
      2: (ZSI_FILLER                       : DOUBLE;
	        ZSJ_TOTAL_RAYS_TO_TRACE          : LONGINT;
	        ZSX_FILLER                       : ARRAY [1..2] OF INTEGER;
	        ZSY_FILLER                       : ARRAY [1..6] OF DOUBLE);
      3: (ZSM_ALL_INTERCEPT_DATA           : ZXE_REAL_VALUES)
    END;

    ZTA_DIFFRACTION_DATA		               : RECORD CASE INTEGER OF
      1: (ZTB_X			                       : DOUBLE;
          ZTC_Y			                       : DOUBLE;
          ZTD_Z			                       : DOUBLE;
          ZTE_A			                       : DOUBLE;
          ZTF_B			                       : DOUBLE;
          ZTG_C			                       : DOUBLE;
          ZTH_PATH_LENGTH		               : DOUBLE;
          ZTI_INTENSITY		                 : DOUBLE);
	    2: (ZTJ_ALL_DIFFRACTION_DATA         : ZXE_REAL_VALUES)
	  END;

    DiffractionStuff                       : RECORD
      FinalOPDSurface                      : INTEGER;
      ImageSurface                         : INTEGER;
      WorkingWavelength                    : DOUBLE;
      ExitIndex                            : DOUBLE;
      Range                                : DOUBLE
    END;

    SpotColor                              : WORD;
    Xaspect                                : WORD;
    Yaspect                                : WORD;

    GraphicsDriver                         : INTEGER;
    GraphicsMode                           : INTEGER;

    LADSBitmap                             : Graphics.TBitmap;

    HOLD_OPTIONS                           : OPTION_ARCHIVE_REC;

    ZAG_LIST_FILE			                     : TEXT;
    ZAF_PRINT_FILE			                   : TEXT;

    ZAI_INTERCEPT_WORK_FILE		             : FILE;
    ZAL_OUTPUT_RAY_FILE		                 : FILE;
    ZAK_RECURS_INTERCEPT_WORK_FILE	       : FILE;
    ZAJ_DIFFRACT_WORK_FILE		             : FILE;
    ZAH_DATA_FILE                          : FILE;

    ZZA_INTERCEPT_DATA_BLOCK		           : ZXA_INPUT_OUTPUT_BLOCK;
    ZZB_RECURS_INTERCEPT_DATA_BLOCK	       : ZXA_INPUT_OUTPUT_BLOCK;
    ZZC_OUTRAY_DATA_BLOCK		               : ZXA_INPUT_OUTPUT_BLOCK;
    ZYA_DIFFRACTION_DATA_BLOCK             : ZXA_INPUT_OUTPUT_BLOCK;

IMPLEMENTATION

END.

