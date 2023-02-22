UNIT LADSInitUnit;

INTERFACE

(****************************************************************************
*****************************************************************************
									      *
  The following variables are treated as constants.
									      *
*****************************************************************************
****************************************************************************)
  
  VAR

    J                                      : INTEGER;

    CAAA_VALID_LADS_COMMANDS		           : STRING [26];
	  CAAB_SET_UP_SURFACE_DATA	             : STRING [2];
	  CAAC_SET_UP_RAY_DATA		               : STRING [2];
	  CAAD_SET_UP_GLASS_CATALOG	             : STRING [2];
	  CAAE_SET_UP_ENVIRONMENT		             : STRING [2];
	  CAAF_SET_UP_LIST_PARAMS		             : STRING [2];
	  CAAG_SET_UP_TRACE_OPTIONS	             : STRING [2];
	  CAAH_EXECUTE_RAY_TRACE		             : STRING [2];
	  CAAI_ARCHIVE_DATA		                   : STRING [2];
	  CAAJ_INIT_LADS_MEMORY		               : STRING [2];
	  CAAK_LIST_VERSION_REPORT	             : STRING [2];
	  CAAL_SET_UP_OPTIMIZATION	             : STRING [2];
	  CAAM_TEACH_LADS			                   : STRING [2];
	  CAAN_SET_UP_GRAPHICS                   : STRING [2];
      
    CBAA_VALID_SURFACE_COMMANDS	           : STRING [16];
	  CBAB_SPECIFY_NEW_SURFACE	             : STRING [2];
	  CBAC_INSERT_NEW_SURFACE		             : STRING [2];
	  CBAD_DELETE_BLOCK_OF_SURFACES	         : STRING [2];
	  CBAE_COPY_BLOCK_OF_SURFACES	           : STRING [2];
	  CBAF_MOVE_BLOCK_OF_SURFACES	           : STRING [2];
	  CBAG_WAKE_BLOCK_OF_SURFACES	           : STRING [2];
	  CBAH_SLEEP_BLOCK_OF_SURFACES	         : STRING [2];
	  CBAI_REVISE_SURFACE_SPECS	             : STRING [2];

    CCAA_VALID_RAY_COMMANDS		             : STRING [16];
	  CCAB_SPECIFY_NEW_RAY		               : STRING [2];
	  CCAC_INSERT_NEW_RAY		                 : STRING [2];
	  CCAD_DELETE_BLOCK_OF_RAYS	             : STRING [2];
	  CCAE_COPY_BLOCK_OF_RAYS		             : STRING [2];
	  CCAF_MOVE_BLOCK_OF_RAYS		             : STRING [2];
	  CCAG_WAKE_BLOCK_OF_RAYS		             : STRING [2];
	  CCAH_SLEEP_BLOCK_OF_RAYS	             : STRING [2];
	  CCAI_REVISE_RAY_SPECS		               : STRING [2];
      
    CDAA_VALID_LIST_COMMANDS		           : STRING [8];
	  CDAB_LIST_SURFACES		                 : STRING [2];
	  CDAC_LIST_RAYS			                   : STRING [2];
	  CDAD_PRINTER_OUTPUT_SWITCH	           : STRING [2];
	  CDAE_LISTFILE_OUTPUT_SWITCH	           : STRING [2];
      
    CEAA_VALID_LIST_TYPES		               : STRING [4];
	  CEAB_FULL_LIST_DESIRED		             : STRING [2];
	  CEAC_BRIEF_LIST_DESIRED		             : STRING [2];

    CFAA_VALID_OPTION_COMMANDS_1	         : STRING [66];
    CFAB_VALID_OPTION_COMMANDS_2	         : STRING [72];
    CFCA_VALID_OPTION_COMMANDS_4	         : STRING [66];
    CFCB_VALID_OPTION_COMMANDS_5	         : STRING [66];
	  CFBI_ENABLE_DESIGNATED_SURFACE	       : STRING [6];
	  CFBJ_DISABLE_DESIGNATED_SURFACE	       : STRING [6];
	  CFBK_GET_VIEWPORT_DIAMETER	           : STRING [6];
	  CFBN_GET_VIEWPORT_POSITION_X	         : STRING [6];
	  CFBO_GET_VIEWPORT_POSITION_Y	         : STRING [6];
	  CFBU_GET_VIEWPORT_POSITION_Z	         : STRING [6];
	  CFBL_GET_DESIG_SURF_ORDINAL	           : STRING [6];
    GetApertureStopSurface                 : STRING [6];
	  CFCC_GET_SURFACE_SEQUENCE	             : STRING [6];
	  CFCD_ENABLE_SURFACE_SEQUENCER	         : STRING [6];
	  CFCE_DISABLE_SURFACE_SEQUENCER	       : STRING [6];
	  CFBG_ENABLE_RECURSIVE_TRACE	           : STRING [6];
	  CFBH_DISABLE_RECURSIVE_TRACE	         : STRING [6];
	  CFBD_CLEAR_ALL_OPTION_SWITCHES	       : STRING [6];
	  CFBV_ENABLE_DRAW_RAYS                  : STRING [6];
	  CFBW_DISABLE_DRAW_RAYS                 : STRING [6];
    EnableDisplaySurfaceNumbers            : STRING [6];
    DisableDisplaySurfaceNumbers           : STRING [6];
    CFCJ_ENABLE_LOCAL_DETAIL_TO_CONSOLE    : STRING [6];
    CFCK_DISABLE_LOCAL_DETAIL_TO_CONSOLE   : STRING [6];
	  CFAF_ENABLE_DETAIL_TO_CONSOLE	         : STRING [6];
  	CFAG_DISABLE_DETAIL_TO_CONSOLE	       : STRING [6];
  	CFAX_ENABLE_DETAIL_PRINT	             : STRING [6];
  	CFAY_DISABLE_DETAIL_PRINT	             : STRING [6];
  	CFAZ_ENABLE_DETAIL_TO_FILE	           : STRING [6];
  	CFBA_DISABLE_DETAIL_TO_FILE	           : STRING [6];
  	CFAH_ENABLE_SPOT_DIAGRAM	             : STRING [6];
  	CFAI_DISABLE_SPOT_DIAGRAM	             : STRING [6];
  	CFAL_ENABLE_SPOT_DIAGRAM_FILE	         : STRING [6];
  	CFAM_DISABLE_SPOT_DIAGRAM_FILE	       : STRING [6];
  	CFBB_ENABLE_FULL_OPD_DISPLAY	         : STRING [6];
  	CFBM_ENABLE_BRIEF_OPD_DISPLAY	         : STRING [6];
  	CFBC_DISABLE_OPD_DISPLAY	             : STRING [6];
  	CFAN_ENABLE_PSF_FILE		               : STRING [6];
  	CFAO_DISABLE_PSF_FILE		               : STRING [6];
  	CFAJ_ENABLE_AREA_INTENSITY_HIST	       : STRING [6];
  	CFAW_ENABLE_RADIUS_INTENSITY_HIST      : STRING [6];
    EnableLinearIntensityHistogram         : STRING [6];
  	CFAK_DISABLE_INTENSITY_HISTOGRAM       : STRING [6];
  	CFBP_DISABLE_RAY_FILE		               : STRING [6];
  	CFBQ_ENABLE_RAY_FILE_WRITE	           : STRING [6];
  	CFBR_ENABLE_RAY_FILE_READ	             : STRING [6];
  	CFBS_ENABLE_ERROR_DISPLAY	             : STRING [6];
  	CFBT_DISABLE_ERROR_DISPLAY	           : STRING [6];
    GET_SEEDS_FOR_RAND_NUMBER_GEN          : STRING [6];

    VALID_GAUSSIAN_COMMANDS                : STRING [78];
    ENABLE_HEAD_X_GAUSSIAN                 : STRING [6];
  	ENABLE_HEAD_X_UNIFORM                  : STRING [6];
  	ENABLE_HEAD_Y_GAUSSIAN                 : STRING [6];
  	ENABLE_HEAD_Y_UNIFORM                  : STRING [6];
    ENABLE_TAIL_X_GAUSSIAN                 : STRING [6];
  	ENABLE_TAIL_X_UNIFORM                  : STRING [6];
  	ENABLE_TAIL_Y_GAUSSIAN                 : STRING [6];
	  ENABLE_TAIL_Y_UNIFORM                  : STRING [6];
	  GET_HEAD_X_DIMENSION                   : STRING [6];
	  GET_HEAD_Y_DIMENSION                   : STRING [6];
	  GET_TAIL_X_DIMENSION                   : STRING [6];
	  GET_TAIL_Y_DIMENSION                   : STRING [6];
    GET_ASTIGMATISM                        : STRING [6];

    CFCF_VALID_SEQUENCER_COMMANDS	         : STRING [8];
	  CFCG_ENABLE_NORMAL_SEQUENCING	         : STRING [2];
	  CFCH_ENABLE_REVERSE_SEQUENCING	       : STRING [2];
	  CFCI_ENABLE_AUTO_SEQUENCING	           : STRING [2];
    SpecifyGroupOfSequenceNumbers          : STRING [2];

    ValidSequencerGroupCommands            : STRING [2];
    GroupCancelCommand                     : STRING [2];

    CGAA_VALID_ARCHIVE_COMMANDS	           : STRING [12];
  	CGAB_TEMP_TO_EXTERNAL_STORAGE	         : STRING [3];
  	CGAC_TEMP_TO_INTERNAL_STORAGE	         : STRING [3];
  	CGAD_PERM_TO_EXTERNAL_STORAGE	         : STRING [3];
  	CGAE_PERM_TO_INTERNAL_STORAGE	         : STRING [3];

    CHAA_VALID_ARCHIVE_DATA_TYPES	         : STRING [10];
    CHAB_ARCHIVE_SURFACE_DATA	             : STRING [2];
    CHAC_ARCHIVE_RAY_DATA		               : STRING [2];
  	CHAD_ARCHIVE_OPTION_DATA	             : STRING [2];
  	CHAE_ARCHIVE_ENVIRONMENT_DATA	         : STRING [2];
  	CHAF_ARCHIVE_ALL_DATA		               : STRING [2];

    CIAA_VALID_ENVIRON_COMMANDS_1	         : STRING [48];
    CIAB_VALID_ENVIRON_COMMANDS_2	         : STRING [48];
    CIAC_VALID_ENVIRON_COMMANDS_3	         : STRING [30];
    CIAD_VALID_ENVIRON_COMMANDS_4	         : STRING [48];
    CIAE_VALID_ENVIRON_COMMANDS_5	         : STRING [33];
	  CIAG_GET_DX_VALUE		                   : STRING [3];
	  CIAH_GET_DY_VALUE		                   : STRING [3];
	  CIAI_GET_DZ_VALUE		                   : STRING [3];
	  CIAJ_PICKUP_POS_AND_ORIENT	           : STRING [3];
	  CIBK_PICKUP_REF_SURF_POS	             : STRING [3];
	  CIBL_PICKUP_REF_SURF_ORIENT	           : STRING [3];
	  CIBM_PICKUP_REF_SURF_NEG_ORIENT	       : STRING [3];
	  CIAK_GET_PIVOT_POINT_X_COORD	         : STRING [3];
	  CIAL_GET_PIVOT_POINT_Y_COORD	         : STRING [3];
  	CIAM_GET_PIVOT_POINT_Z_COORD	         : STRING [3];
	  CIAN_GET_EULER_AXIS_X_MAG	             : STRING [3];
  	CIAO_GET_EULER_AXIS_Y_MAG	             : STRING [3];
	  CIAP_GET_EULER_AXIS_Z_MAG	             : STRING [3];
	  CIAQ_GET_EULER_AXIS_ROT_VALUE	         : STRING [3];
    DeactivateSurfaceRange                 : STRING [3];
    DeactivateRayRange                     : STRING [3];
	  CIBN_GET_ENVIRON_REF_SURF	             : STRING [6];
	  CIAR_SPECIFY_ENVIRON_BLOCK	           : STRING [6];
    SpecifyEnvironmentRayBlock             : STRING [6];
    ClearEnvironmentVariables              : STRING [6];
  	CIAS_ENABLE_YAW_PITCH_ROLL	           : STRING [6];
  	CIAT_GET_ROLL_VALUE		                 : STRING [6];
  	CIAU_GET_PITCH_VALUE		               : STRING [6];
  	CIAV_GET_YAW_VALUE		                 : STRING [6];
  	CIAW_ENABLE_EULER_AXIS_ROT	           : STRING [6];
  	CIAX_ENVIRON_MODS_ARE_PERM	           : STRING [6];
  	CIAY_ENVIRON_MODS_ARE_TEMP	           : STRING [6];
  	CIAZ_1ST_BLOCK_SURF_REFLECTOR	         : STRING [6];
  	CIBA_1ST_BLOCK_SURF_IS_NULL	           : STRING [6];
  	CIBB_1ST_BLOCK_SURF_FULL_ROT	         : STRING [6];
  	CIBC_ZERO_OUT_TEMPORARY_CHNGS	         : STRING [6];
  	CIBD_INCORPORATE_TEMP_CHNGS	           : STRING [6];
  	CIBF_COORDS_ARE_REF_SYSTEM	           : STRING [11];
  	CIBG_COORDS_ARE_LOCAL		               : STRING [11];
	  CIBH_PERFORM_TRANSLATION	             : STRING [6];
	  CIBJ_ADJUST_THICKNESS		               : STRING [6];
  	CIBI_PERFORM_ROTATION		               : STRING [6];
    GetScaleFactor                         : STRING [11];
    PerformScaleAdjustment                 : STRING [6];
    PerformRayAiming                       : STRING [6];

    CJAA_VALID_GLASS_CAT_COMMANDS	         : STRING [6];
	  CJAB_LIST_CAT_DATA_FOR_GLASS	         : STRING [2];
  	CJAF_COMPUTE_REFRACTIVE_INDEX	         : STRING [2];
    SetupGRINMatlAlias                     : STRING [2];

    GRINMaterialAliasCommands              : STRING [42];
    GetXPosition                           : STRING [6];
    GetYPosition                           : STRING [6];
    GetZPosition                           : STRING [6];
    GetYawOrientation                      : STRING [6];
    GetPitchOrientation                    : STRING [6];
    GetRollOrientation                     : STRING [6];
    GetAlias                               : STRING [6];

    CKAA_VALID_SURF_REV_COMMANDS_1	       : STRING [72];
    CKAB_VALID_SURF_REV_COMMANDS_2	       : STRING [63];
  	CKAD_GET_RADIUS			                   : STRING [3];
  	CKAC_GET_INDEX_1		                   : STRING [3];
	  CKAE_GET_INDEX_2		                   : STRING [3];
	  CKAF_GET_OUTSIDE_DIA		               : STRING [3];
	  CKAG_GET_INSIDE_DIA		                 : STRING [3];
	  CKBF_GET_OUTSIDE_WIDTH_X	             : STRING [3];
	  CKBG_GET_OUTSIDE_WIDTH_Y	             : STRING [3];
  	CKBH_GET_INSIDE_WIDTH_X		             : STRING [3];
	  CKBI_GET_INSIDE_WIDTH_Y		             : STRING [3];
	  CKBR_GET_APERTURE_POSITION_X	         : STRING [3];
	  CKBS_GET_APERTURE_POSITION_Y	         : STRING [3];
	  CKBJ_CIRCULAR_OUTSIDE_SW	             : STRING [3];
	  CKBK_CIRCULAR_INSIDE_SW		             : STRING [3];
	  CKBL_SQUARE_OUTSIDE_SW		             : STRING [3];
	  CKBM_SQUARE_INSIDE_SW		               : STRING [3];
	  CKBN_ELLIPTICAL_OUTSIDE_SW	           : STRING [3];
	  CKBO_ELLIPTICAL_INSIDE_SW	             : STRING [3];
	  CKAH_GET_CONIC_CONSTANT		             : STRING [3];
  	CKAI_DEFORMATION_CONSTS_SW	           : STRING [3];
	  CKAZ_DEFINE_CPC                        : STRING [3];
	  CKAJ_RAY_TERMINATION_SURF_SW	         : STRING [3];
	  CKAK_BEAMSPLITTER_SURF_SW	             : STRING [3];
	  CKBE_GET_SURFACE_REFLECTIVITY	         : STRING [3];
	  CKBP_REFLECTIVE_SURFACE_SW	           : STRING [3];
	  CKAL_SCATTERING_SURF_SW		             : STRING [3];
	  CKBD_GET_SCATTERING_ANGLE	             : STRING [3];
	  CKAM_CYLINDRICAL_SURF_SW	             : STRING [3];
	  CKAN_GET_SURF_X_POSITION	             : STRING [3];
	  CKAO_GET_SURF_DELTA_X		               : STRING [3];
	  CKAP_GET_SURF_Y_POSITION	             : STRING [3];
	  CKAQ_GET_SURF_DELTA_Y		               : STRING [3];
	  CKAR_GET_SURF_Z_POSITION	             : STRING [3];
	  CKAS_GET_SURF_DELTA_Z		               : STRING [3];
	  CKAT_GET_SURF_ROLL		                 : STRING [3];
	  CKAU_GET_SURF_DELTA_ROLL	             : STRING [3];
	  CKAV_GET_SURF_PITCH		                 : STRING [3];
	  CKAW_GET_SURF_DELTA_PITCH	             : STRING [3];
	  CKAX_GET_SURF_YAW		                   : STRING [3];
	  CKAY_GET_SURF_DELTA_YAW		             : STRING [3];
	  CKBC_OPD_REF_SURF_SWITCH	             : STRING [3];
    SurfaceArraySwitch                     : STRING [3];
    SurfaceArrayXRepeat                    : STRING [3];
    SurfaceArrayYRepeat                    : STRING [3];
    SurfaceArrayXSpacing                   : STRING [3];
    SurfaceArrayYSpacing                   : STRING [3];

    CMAA_VALID_GLASS_REC_FIELD_CODE	       : STRING [14];
	  CMAB_GET_MANUFACTURER_CODE	           : STRING [2];
	  CMAC_GET_MATERIAL_TYPE		             : STRING [2];
  	CMAD_GET_GLASS_PREF_CODE	             : STRING [2];
  	CMAE_GET_NON_GLASS_INDEX_TYPE	         : STRING [2];
  	CMAF_GET_SHORTWAVE_CUTOFF	             : STRING [2];
	  CMAG_GET_LONGWAVE_CUTOFF	             : STRING [2];
  	CMAH_GET_DISPERSION_CONSTANTS	         : STRING [2];

    CNAA_VALID_MANUFAC_COMMANDS	           : STRING [12];
	  CNAB_GET_SCHOTT_MANUFAC_CODE	         : STRING [2];
	  CNAC_GET_OHARA_MANUFAC_CODE	           : STRING [2];
	  CNAD_GET_HOYA_MANUFAC_CODE	           : STRING [2];
	  CNAE_GET_SUMITA_MANUFAC_CODE	         : STRING [2];
	  CNAF_GET_DYNASIL_MANUFAC_CODE	         : STRING [2];
	  CNAG_GET_CVD_MANUFACE_CODE	           : STRING [2];

    COAA_VALID_MATERIAL_COMMANDS	         : STRING [4];
	  COAB_GET_GLASS_MATERIAL_TYPE	         : STRING [2];
	  COAC_GET_XTAL_MATERIAL_TYPE	           : STRING [2];
      
    CPAA_VALID_GLASS_PREF_COMMANDS	       : STRING [6];
	  CPAB_GET_PREFERRED_GLASS_CODE	         : STRING [2];
	  CPAC_GET_NOT_PREF_GLASS_CODE	         : STRING [2];
	  CPAD_GET_UNAVAIL_GLASS_CODE	           : STRING [2];

    CQAA_VALID_INDEX_TYPE_COMMANDS	       : STRING [4];
	  CQAB_GET_ORDINARY_INDEX_CODE	         : STRING [2];
	  CQAC_GET_EXTRAORD_INDEX_CODE	         : STRING [2];

    CRAA_VALID_RAY_REV_COMMANDS	           : STRING [24];
    ValidRayRevCommands2                   : STRING [60];
    ValidRayRevCommands3                   : STRING [60];
	  CRAB_GET_RAY_TAIL_X_COORD	             : STRING [3];
	  CRAC_GET_RAY_TAIL_Y_COORD	             : STRING [3];
	  CRAD_GET_RAY_TAIL_Z_COORD	             : STRING [3];
	  CRAE_GET_RAY_HEAD_X_COORD	             : STRING [3];
	  CRAF_GET_RAY_HEAD_Y_COORD	             : STRING [3];
	  CRAG_GET_RAY_HEAD_Z_COORD	             : STRING [3];
	  CRAI_GET_RAY_WAVLNGTH_MICRONS	         : STRING [3];
  	CRAJ_GET_INCIDENT_MED_INDEX	           : STRING [3];
	  CFAD_GET_BHD_VALUE		                 : STRING [6];
    GetMaxZenithDistance                   : STRING [6];
    GetMinZenithDistance                   : STRING [6];
    GetAzimuthAngularCenter                : STRING [6];
    GetAzimuthAngularSemiLength            : STRING [6];
  	CFAP_GENERATE_SYMMETRIC_FAN	           : STRING [6];
  	GenerateLinearXFan        	           : STRING [6];
	  CFAV_GENERATE_LINEAR_Y_FAN	           : STRING [6];
	  CFAQ_GENERATE_ASYMMETRIC_FAN	         : STRING [6];
	  CFAE_GENERATE_3FAN		                 : STRING [6];
    GenerateSquareGrid                     : STRING [6];
	  CFAR_GENERATE_HEXAPOLAR_ARRAY	         : STRING [6];
  	CFAS_GENERATE_ISOMETRIC_ARRAY	         : STRING [6];
	  CFAT_GENERATE_RANDOM_ARRAY	           : STRING [6];
	  CFBF_GENERATE_SOLID_ANGLE_ARRAY	       : STRING [6];
    GenerateOrangeSliceArray               : STRING [6];
    GetAngularWidthOfSlice                 : STRING [6];
    GENERATE_LAMBERTIAN_ARRAY              : STRING [6];
  	GENERATE_GAUSSIAN_ARRAY                : STRING [6];
  	CFAU_DISABLE_COMPUTED_RAYS	           : STRING [6];

    CSAA_VALID_OPTIMIZE_COMMANDS	         : STRING [12];
	  CSAB_OPTIMIZE_ACTIVE_SWITCH	           : STRING [2];
	  CSAD_BOUND_REDUCTION_SWITCH	           : STRING [2];
	  CSAE_BOUND_RECENTERING_SWITCH	         : STRING [2];
	  CSAC_GET_MERIT_FUNCTION		             : STRING [2];
  	CSAJ_GET_SURF_OPTIMIZE_DATA	           : STRING [2];
    CSAK_CLEAR_ALL_PARAMETERS              : STRING [2];

    CTAA_VALID_MERIT_FUNC_COMMANDS	       : STRING [6];
	  CTAB_GET_RMS_BLUR_DIA_CODE	           : STRING [2];
  	CTAC_GET_FULL_BLUR_DIA_CODE	           : STRING [2];
    CTAD_GET_IMAGE_UNIFORMITY              : STRING [2];

    CUAA_VALID_SURF_OPTIMIZE_CMDS	         : STRING [36];
  	CUAB_OPTIMIZE_RADIUS_SW		             : STRING [2];
	  CUAC_RESET_RADIUS_BOUNDS     	         : STRING [2];
	  CUAD_GET_RADIUS_BOUND_1		             : STRING [2];
	  CUAE_GET_RADIUS_BOUND_2		             : STRING [2];
  	CUAF_PERMIT_SURF_PITCH_REV_SW	         : STRING [2];
	  CUAH_OPTIMIZE_POSITION_SW	             : STRING [2];
  	CUAJ_GET_POSITION_BOUND_1	             : STRING [2];
  	CUAK_GET_POSITION_BOUND_2	             : STRING [2];
  	CUAI_CONTROL_SEPARATION		             : STRING [2];
	  CUAR_GET_NEXT_SURFACE		               : STRING [2];
	  CUAS_GET_THICKNESS		                 : STRING [2];
  	CUAT_GET_DELTA_THICKNESS	             : STRING [2];
  	CUAL_OPTIMIZE_GLASS_TYPE_SW	           : STRING [2];
	  CUAM_USE_PREFERRED_GLASSES_SW	         : STRING [2];
	  CUAN_OPTIMIZE_CONIC_CONST_SW	         : STRING [2];
  	CUAO_RESET_CONIC_CONST_BOUNDS	         : STRING [2];
  	CUAP_GET_CONIC_CONST_BOUND_1	         : STRING [2];
  	CUAQ_GET_CONIC_CONST_BOUND_2	         : STRING [2];

    CVAA_VALID_GRAPHICS_COMMANDS           : STRING [12];
    CVAB_REVISE_SCREEN_ASPECT_RATIO        : STRING [2];
    CVAC_SET_X_COORD                       : STRING [2];
    CVAD_SET_Y_COORD                       : STRING [2];
    CVAE_SET_Z_COORD                       : STRING [2];
    CVAF_GET_VIEWPORT_DIAMETER             : STRING [2];
    CVAG_PICTURE_SURFACES                  : STRING [2];

PROCEDURE Y005_INITIALIZE_LADS;
PROCEDURE Y010_INITIALIZE_A_RAY (RayOrdinal : INTEGER);

IMPLEMENTATION

  USES LADSData,
       LADSEnvironUnit,
       LADSGlassVar,
       LADSOptimizeUnit;


(**  Y005_INITIALIZE_LADS  ****************************************************
******************************************************************************)


PROCEDURE Y005_INITIALIZE_LADS;

  VAR
      I  : INTEGER;

BEGIN

(**  INITIALIZE ALL SURFACES AND RAYS  **)

  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    ZBA_SURFACE [I].ZDA_ALL_SURFACE_DATA := ZEA_SURFACE_DATA_INITIALIZER;

  FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
    Y010_INITIALIZE_A_RAY (I);

  (*  Initialize environment data *)

  ZHA_ENVIRONMENT.ZIA_ALL_ENVIRONMENT_DATA := ENVIRONMENT_DATA_INITIALIZER;
  ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL := TRUE;
  ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE := 1;
  ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK := 1;
  ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK := CZAB_MAX_NUMBER_OF_SURFACES;
  ZHA_ENVIRONMENT.FirstRayInBlock := 1;
  ZHA_ENVIRONMENT.LastRayInBlock := CZAC_MAX_NUMBER_OF_RAYS;
  ZHA_ENVIRONMENT.ScaleFactor := 1.0;

(**  INITIALIZE VARIOUS DATA ITEMS  **)

  Xaspect := 10000;
  Yaspect := 10000;

  ABD_GLASS_HIGH_PTR := 0;
  AKG_LAMBDA_HIGH_PTR := 0;

  FOR I := 1 TO MaxBulkGRINMaterials DO
    BEGIN
      GRINMaterial [I].CoordinateRotationNeeded := FALSE;
      GRINMaterial [I].CoordinateTranslationNeeded := FALSE;
      GRINMaterial [I].GRINMatlAlias := '';
      GRINMaterial [I].GRINMatlName := '';
      GRINMaterial [I].RotationMatrixElements.T11 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T12 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T13 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T21 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T22 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T23 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T31 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T32 := 0.0;
      GRINMaterial [I].RotationMatrixElements.T33 := 0.0;
      GRINMaterial [I].TranslationVectorElements.OriginX := 0.0;
      GRINMaterial [I].TranslationVectorElements.OriginY := 0.0;
      GRINMaterial [I].TranslationVectorElements.OriginZ := 0.0;
      GRINMaterial [I].BulkMaterialPosition.Rx := 0.0;
      GRINMaterial [I].BulkMaterialPosition.Ry := 0.0;
      GRINMaterial [I].BulkMaterialPosition.Rz := 0.0;
      GRINMaterial [I].BulkMaterialOrientation.Tx := 0.0;
      GRINMaterial [I].BulkMaterialOrientation.Ty := 0.0;
      GRINMaterial [I].BulkMaterialOrientation.Tz := 0.0
    END;

  FOR I := 1 TO CZAQ_OPTION_DATA_BOOLEAN_FIELDS DO
    ZFA_OPTION.ZFS_ALL_OPTION_DATA.ZFT_BOOLEAN_DATA [I] := FALSE;
  ZFA_OPTION.ZGK_DESIGNATED_SURFACE := CZBL_DEFAULT_IMAGE_SURFACE;
  ZFA_OPTION.ZGL_VIEWPORT_DIAMETER := CZBM_DEFAULT_VIEWPORT_DIAMETER;
  ZFA_OPTION.ZGC_VIEWPORT_POSITION_X := CZBB_DEFAULT_VIEWPORT_POSITION;
  ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y := CZBB_DEFAULT_VIEWPORT_POSITION;
  ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z := CZBB_DEFAULT_VIEWPORT_POSITION;
  ZFA_OPTION.ZFN_PSF_FILE_NAME := '';
  ZFA_OPTION.ZFM_SPOT_DIAGRAM_FILE_NAME := '';
  ZFA_OPTION.ZGB_TRACE_DETAIL_FILE := '';
(*ZFA_OPTION.ZFO_COMPUTED_RAY_COUNT := CZBD_DEFAULT_COMPUTED_RAY_COUNT;*)
  ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME := '';
  ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME := '';
  ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE := CZBN_DEFAULT_SURF_FOR_RAY_WRITE;
  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    ZFA_OPTION.ZGT_SURFACE_SEQUENCER [I] := I;
  ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE :=
      CZBP_NORMAL_PROCESSING_SEQUENCE;
  FOR I := 1 TO CZBO_MAX_SEQUENCER_GROUPS DO
    BEGIN
      ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [I].
	  ZGV_SEQUENCER_START_SLOT := 1;
      ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [I].
	  ZGW_SEQUENCER_END_SLOT := 1;
      ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [I].
	  ZGX_GROUP_PROCESS_CONTROL_CODE := GroupInactive
    END;

  ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED := FALSE;
  ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED := FALSE;
  ZLA_OPTIMIZATION_DATA.ZLF_BOUND_RECENTERING_ACTIVATED := FALSE;
  ZLA_OPTIMIZATION_DATA.ZLD_MERIT_FUNCTION_CODE := 'R';
  ZLA_OPTIMIZATION_DATA.ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE := 1.0E19;
  ZLA_OPTIMIZATION_DATA.ZLY_OLD_MERIT_VALUE := 1.0E19

END;




(**  Y010_INITIALIZE_A_RAY  ***************************************************
******************************************************************************)


PROCEDURE Y010_INITIALIZE_A_RAY (RayOrdinal : INTEGER);

BEGIN

  ZNA_RAY [RayOrdinal].ZPA_ALL_RAY_DATA := ZQA_RAY_DATA_INITIALIZER;
  ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER :=
      CZBC_DEFAULT_BUNDLE_HEAD_DIA;
  ZNA_RAY [RayOrdinal].MaxZenithDistance := DefaultMaxZenithDistance;
  ZNA_RAY [RayOrdinal].MinZenithDistance := DefaultMinZenithDistance;
  ZNA_RAY [RayOrdinal].AzimuthAngularCenter := DefaultAzimuthCenter;
  ZNA_RAY [RayOrdinal].AzimuthAngularSemiLength := DefaultAzimuthSemiLength;
  ZNA_RAY [RayOrdinal].SIGMA_X_HEAD := DEFAULT_GAUSSIAN_BEAM_DIAMETER;
  ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD := DEFAULT_GAUSSIAN_BEAM_DIAMETER;
  ZNA_RAY [RayOrdinal].SIGMA_X_TAIL := DEFAULT_GAUSSIAN_BEAM_DIAMETER;
  ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL := DEFAULT_GAUSSIAN_BEAM_DIAMETER;
  ZNA_RAY [RayOrdinal].Astigmatism := DefaultGaussianBeamAstigmatism;
  ZNA_RAY [RayOrdinal].NumberOfRings := DefaultRings

END;




(**  LADSInitUnit  ************************************************************
******************************************************************************)


BEGIN

  ALR_DEGREES_PER_RADIAN := 180.0 / PI;

(**  INITIALIZE SURFACE, RAY, AND ENVIRONMENT INITIALIZATION AREAS  **)

  FOR J := 1 TO CZAK_SURFACE_DATA_BOOLEAN_FIELDS DO
    ZEA_SURFACE_DATA_INITIALIZER.ZDB_BOOLEAN_DATA [J] := FALSE;
  FOR J := 1 TO CZAL_SURFACE_DATA_REAL_FIELDS DO
    ZEA_SURFACE_DATA_INITIALIZER.ZDC_REAL_DATA [J] := 0.0;
  FOR J := 1 TO CZAJ_SURFACE_DATA_INTEGER_FIELDS DO
    ZEA_SURFACE_DATA_INITIALIZER.ZDD_INTEGER_DATA [J] := 0;

  FOR J := 1 TO CZAN_RAY_DATA_BOOLEAN_FIELDS DO
    ZQA_RAY_DATA_INITIALIZER.ZPB_BOOLEAN_DATA [J] := FALSE;
  FOR J := 1 TO RayDataIntegerFields DO
    ZQA_RAY_DATA_INITIALIZER.ZPG_INTEGER_DATA [J] := 0;
  FOR J := 1 TO CZAO_RAY_DATA_REAL_FIELDS DO
    ZQA_RAY_DATA_INITIALIZER.ZPC_REAL_DATA [J] := 0.0;

  FOR J := 1 TO CZAV_ENVIRONMENT_DATA_BOOLEAN_FIELDS DO
    ENVIRONMENT_DATA_INITIALIZER.ZIB_BOOLEAN_DATA [J] := FALSE;
  FOR J := 1 TO CZAW_ENVIRONMENT_DATA_INTEGER_FIELDS DO
    ENVIRONMENT_DATA_INITIALIZER.ZID_INTEGER_DATA [J] := 0;
  FOR J := 1 TO CZAX_ENVIRONMENT_DATA_REAL_FIELDS DO
    ENVIRONMENT_DATA_INITIALIZER.ZIE_REAL_DATA [J] := 0.0;

  (* Initialize the following variable for use as "constants" *)

  CAAA_VALID_LADS_COMMANDS	               := 'S R G E L O T A I X V Z D ';
    CAAB_SET_UP_SURFACE_DATA	             := 'S ';
    CAAC_SET_UP_RAY_DATA	                 := 'R ';
    CAAD_SET_UP_GLASS_CATALOG	             := 'G ';
    CAAE_SET_UP_ENVIRONMENT	               := 'E ';
    CAAF_SET_UP_LIST_PARAMS	               := 'L ';
    CAAG_SET_UP_TRACE_OPTIONS	             := 'O ';
    CAAH_EXECUTE_RAY_TRACE	               := 'T ';
    CAAI_ARCHIVE_DATA		                   := 'A ';
    CAAJ_INIT_LADS_MEMORY	                 := 'I ';
    CAAL_SET_UP_OPTIMIZATION	             := 'X ';
    CAAK_LIST_VERSION_REPORT	             := 'V ';
    CAAM_TEACH_LADS		                     := 'Z ';
    CAAN_SET_UP_GRAPHICS                   := 'D ';
  
  CBAA_VALID_SURFACE_COMMANDS	             := 'N I D C M W S R ';
    CBAB_SPECIFY_NEW_SURFACE	             := 'N ';
    CBAC_INSERT_NEW_SURFACE	               := 'I ';
    CBAD_DELETE_BLOCK_OF_SURFACES          := 'D ';
    CBAE_COPY_BLOCK_OF_SURFACES	           := 'C ';
    CBAF_MOVE_BLOCK_OF_SURFACES	           := 'M ';
    CBAG_WAKE_BLOCK_OF_SURFACES	           := 'W ';
    CBAH_SLEEP_BLOCK_OF_SURFACES           := 'S ';
    CBAI_REVISE_SURFACE_SPECS	             := 'R ';
  
  CCAA_VALID_RAY_COMMANDS	                 := 'N I D C M W S R ';
    CCAB_SPECIFY_NEW_RAY	                 := 'N ';
    CCAC_INSERT_NEW_RAY		                 := 'I ';
    CCAD_DELETE_BLOCK_OF_RAYS	             := 'D ';
    CCAE_COPY_BLOCK_OF_RAYS	               := 'C ';
    CCAF_MOVE_BLOCK_OF_RAYS	               := 'M ';
    CCAG_WAKE_BLOCK_OF_RAYS	               := 'W ';
    CCAH_SLEEP_BLOCK_OF_RAYS	             := 'S ';
    CCAI_REVISE_RAY_SPECS	                 := 'R ';

  CDAA_VALID_LIST_COMMANDS	               := 'S R P L ';
    CDAB_LIST_SURFACES		                 := 'S ';
    CDAC_LIST_RAYS		                     := 'R ';
    CDAD_PRINTER_OUTPUT_SWITCH	           := 'P ';
    CDAE_LISTFILE_OUTPUT_SWITCH	           := 'L ';
  
  CEAA_VALID_LIST_TYPES		                 := 'F B ';
    CEAB_FULL_LIST_DESIRED	               := 'F ';
    CEAC_BRIEF_LIST_DESIRED	               := 'B ';

  CFAA_VALID_OPTION_COMMANDS_1 :=
      'CLR   CDTL  XCDTL PDTL  XPDTL FDTL  XFDTL CSPT  XCSPT ORD   CTRL  ';
  CFAB_VALID_OPTION_COMMANDS_2 :=
      'FSPT  XFSPT AHIST LHIST RHIST ' +
      'XHIST DES   XDES  DIA   VX    VY    VZ    ';
  CFCA_VALID_OPTION_COMMANDS_4 :=
      'FPSF  XFPSF FOPD  BOPD  XOPD  RRAY  WRAY  NRAY  ERRON EROFF SEED  ';
  CFCB_VALID_OPTION_COMMANDS_5 :=
      'SDEF  SON   SOFF  REC   XREC  DRAW  XDRAW NUM   XNUM  LDTL  XLDTL ';
    CFBD_CLEAR_ALL_OPTION_SWITCHES         := 'CLR   ';
    CFBI_ENABLE_DESIGNATED_SURFACE         := 'DES   ';
    CFBJ_DISABLE_DESIGNATED_SURFACE        := 'XDES  ';
    CFBK_GET_VIEWPORT_DIAMETER	           := 'DIA   ';
    CFBN_GET_VIEWPORT_POSITION_X           := 'VX    ';
    CFBO_GET_VIEWPORT_POSITION_Y           := 'VY    ';
    CFBU_GET_VIEWPORT_POSITION_Z           := 'VZ    ';
    CFBL_GET_DESIG_SURF_ORDINAL	           := 'ORD   ';
    GetApertureStopSurface                 := 'CTRL  ';
    CFCC_GET_SURFACE_SEQUENCE	             := 'SDEF  ';
    CFCD_ENABLE_SURFACE_SEQUENCER          := 'SON   ';
    CFCE_DISABLE_SURFACE_SEQUENCER         := 'SOFF  ';
    CFBG_ENABLE_RECURSIVE_TRACE	           := 'REC   ';
    CFBH_DISABLE_RECURSIVE_TRACE           := 'XREC  ';
    CFBV_ENABLE_DRAW_RAYS                  := 'DRAW  ';
    CFBW_DISABLE_DRAW_RAYS                 := 'XDRAW ';
    EnableDisplaySurfaceNumbers            := 'NUM   ';
    DisableDisplaySurfaceNumbers           := 'XNUM  ';
    CFCJ_ENABLE_LOCAL_DETAIL_TO_CONSOLE    := 'LDTL  ';
    CFCK_DISABLE_LOCAL_DETAIL_TO_CONSOLE   := 'XLDTL ';
    CFAF_ENABLE_DETAIL_TO_CONSOLE          := 'CDTL  ';
    CFAG_DISABLE_DETAIL_TO_CONSOLE         := 'XCDTL ';
    CFAX_ENABLE_DETAIL_PRINT	             := 'PDTL  ';
    CFAY_DISABLE_DETAIL_PRINT	             := 'XPDTL ';
    CFAZ_ENABLE_DETAIL_TO_FILE	           := 'FDTL  ';
    CFBA_DISABLE_DETAIL_TO_FILE	           := 'XFDTL ';
    CFAH_ENABLE_SPOT_DIAGRAM	             := 'CSPT  ';
    CFAI_DISABLE_SPOT_DIAGRAM	             := 'XCSPT ';
    CFAL_ENABLE_SPOT_DIAGRAM_FILE          := 'FSPT  ';
    CFAM_DISABLE_SPOT_DIAGRAM_FILE         := 'XFSPT ';
    CFAJ_ENABLE_AREA_INTENSITY_HIST        := 'AHIST ';
    CFAW_ENABLE_RADIUS_INTENSITY_HIST      := 'RHIST ';
    EnableLinearIntensityHistogram         := 'LHIST ';
    CFAK_DISABLE_INTENSITY_HISTOGRAM       := 'XHIST ';
    CFAN_ENABLE_PSF_FILE	                 := 'FPSF  ';
    CFAO_DISABLE_PSF_FILE	                 := 'XFPSF ';
    CFBB_ENABLE_FULL_OPD_DISPLAY           := 'FOPD  ';
    CFBM_ENABLE_BRIEF_OPD_DISPLAY          := 'BOPD  ';
    CFBC_DISABLE_OPD_DISPLAY	             := 'XOPD  ';
    CFBP_DISABLE_RAY_FILE	                 := 'NRAY  ';
    CFBQ_ENABLE_RAY_FILE_WRITE	           := 'WRAY  ';
    CFBR_ENABLE_RAY_FILE_READ	             := 'RRAY  ';
    CFBS_ENABLE_ERROR_DISPLAY	             := 'ERRON ';
    CFBT_DISABLE_ERROR_DISPLAY	           := 'EROFF ';
    GET_SEEDS_FOR_RAND_NUMBER_GEN          := 'SEED  ';
    
  VALID_GAUSSIAN_COMMANDS := 'HXG   HXU   HYG   HYU   TXG   TXU   ' +
      'TYG   TYU   HX    HY    TX    TY    ASTIG ';
    ENABLE_HEAD_X_GAUSSIAN                 := 'HXG   ';
    ENABLE_HEAD_X_UNIFORM                  := 'HXU   ';
    ENABLE_HEAD_Y_GAUSSIAN                 := 'HYG   ';
    ENABLE_HEAD_Y_UNIFORM                  := 'HYU   ';
    ENABLE_TAIL_X_GAUSSIAN                 := 'TXG   ';
    ENABLE_TAIL_X_UNIFORM                  := 'TXU   ';
    ENABLE_TAIL_Y_GAUSSIAN                 := 'TYG   ';
    ENABLE_TAIL_Y_UNIFORM                  := 'TYU   ';
    GET_HEAD_X_DIMENSION                   := 'HX    ';
    GET_HEAD_Y_DIMENSION                   := 'HY    ';
    GET_TAIL_X_DIMENSION                   := 'TX    ';
    GET_TAIL_Y_DIMENSION                   := 'TY    ';
    GET_ASTIGMATISM                        := 'ASTIG ';
    
  CFCF_VALID_SEQUENCER_COMMANDS	           := 'N R A G ';
    CFCG_ENABLE_NORMAL_SEQUENCING          := 'N ';
    CFCH_ENABLE_REVERSE_SEQUENCING         := 'R ';
    CFCI_ENABLE_AUTO_SEQUENCING	           := 'A ';
    SpecifyGroupOfSequenceNumbers          := 'G ';
      
  ValidSequencerGroupCommands              := 'C ';
    GroupCancelCommand                     := 'C ';

  CGAA_VALID_ARCHIVE_COMMANDS	             := 'TS TL PS PL ';
    CGAB_TEMP_TO_EXTERNAL_STORAGE          := 'TS ';
    CGAC_TEMP_TO_INTERNAL_STORAGE          := 'TL ';
    CGAD_PERM_TO_EXTERNAL_STORAGE          := 'PS ';
    CGAE_PERM_TO_INTERNAL_STORAGE          := 'PL ';
  
  CHAA_VALID_ARCHIVE_DATA_TYPES	           := 'S R O E A ';
    CHAB_ARCHIVE_SURFACE_DATA	             := 'S ';
    CHAC_ARCHIVE_RAY_DATA	                 := 'R ';
    CHAD_ARCHIVE_OPTION_DATA	             := 'O ';
    CHAE_ARCHIVE_ENVIRONMENT_DATA          := 'E ';
    CHAF_ARCHIVE_ALL_DATA	                 := 'A ';

  CIAA_VALID_ENVIRON_COMMANDS_1	    :=
      'DX DY DZ *  *P *O *- X  Y  Z  EX EY EZ ER NS NR ';
  CIAB_VALID_ENVIRON_COMMANDS_2	    :=
      'REF   SBLOK RBLOK YPR   ROLL  PITCH YAW   EULER ';
  CIAC_VALID_ENVIRON_COMMANDS_3	    := 'PERM  TEMP  REFL  NULL  FULL  ';
  CIAD_VALID_ENVIRON_COMMANDS_4	    :=
      'TR    TH    RO    SC    ZERO  INC   CLR   AIM   ';
  CIAE_VALID_ENVIRON_COMMANDS_5	    := 'SYSTEM     LOCAL      FACTOR     ';
    CIAG_GET_DX_VALUE		                   := 'DX ';
    CIAH_GET_DY_VALUE		                   := 'DY ';
    CIAI_GET_DZ_VALUE		                   := 'DZ ';
    CIAJ_PICKUP_POS_AND_ORIENT	           := '*  ';
    CIBK_PICKUP_REF_SURF_POS	             := '*P ';
    CIBL_PICKUP_REF_SURF_ORIENT	           := '*O ';
    CIBM_PICKUP_REF_SURF_NEG_ORIENT        := '*- ';
    CIAK_GET_PIVOT_POINT_X_COORD           := 'X  ';
    CIAL_GET_PIVOT_POINT_Y_COORD           := 'Y  ';
    CIAM_GET_PIVOT_POINT_Z_COORD           := 'Z  ';
    CIAN_GET_EULER_AXIS_X_MAG	             := 'EX ';
    CIAO_GET_EULER_AXIS_Y_MAG	             := 'EY ';
    CIAP_GET_EULER_AXIS_Z_MAG	             := 'EZ ';
    CIAQ_GET_EULER_AXIS_ROT_VALUE          := 'ER ';
    DeactivateSurfaceRange                 := 'NS ';
    DeactivateRayRange                     := 'NR ';
    CIBN_GET_ENVIRON_REF_SURF	             := 'REF   ';
    CIAR_SPECIFY_ENVIRON_BLOCK	           := 'SBLOK ';
    SpecifyEnvironmentRayBlock             := 'RBLOK ';
    CIAS_ENABLE_YAW_PITCH_ROLL	           := 'YPR   ';
    CIAT_GET_ROLL_VALUE		                 := 'ROLL  ';
    CIAU_GET_PITCH_VALUE	                 := 'PITCH ';
    CIAV_GET_YAW_VALUE		                 := 'YAW   ';
    CIAW_ENABLE_EULER_AXIS_ROT	           := 'EULER ';
    CIAX_ENVIRON_MODS_ARE_PERM	           := 'PERM  ';
    CIAY_ENVIRON_MODS_ARE_TEMP	           := 'TEMP  ';
    CIAZ_1ST_BLOCK_SURF_REFLECTOR          := 'REFL  ';
    CIBA_1ST_BLOCK_SURF_IS_NULL	           := 'NULL  ';
    CIBB_1ST_BLOCK_SURF_FULL_ROT           := 'FULL  ';
    CIBH_PERFORM_TRANSLATION	             := 'TR    ';
    CIBJ_ADJUST_THICKNESS	                 := 'TH    ';
    CIBI_PERFORM_ROTATION	                 := 'RO    ';
    PerformScaleAdjustment                 := 'SC    ';
    PerformRayAiming                       := 'AIM   ';
    CIBC_ZERO_OUT_TEMPORARY_CHNGS          := 'ZERO  ';
    CIBD_INCORPORATE_TEMP_CHNGS	           := 'INC   ';
    ClearEnvironmentVariables              := 'CLR   ';
    CIBF_COORDS_ARE_REF_SYSTEM	           := 'SYSTEM     ';
    CIBG_COORDS_ARE_LOCAL	                 := 'LOCAL      ';
    GetScaleFactor                         := 'FACTOR     ';

  CJAA_VALID_GLASS_CAT_COMMANDS	           := 'L I S ';
    CJAB_LIST_CAT_DATA_FOR_GLASS           := 'L ';
    CJAF_COMPUTE_REFRACTIVE_INDEX          := 'I ';
    SetupGRINMatlAlias                     := 'S ';

  GRINMaterialAliasCommands                :=
      'X     Y     Z     ROLL  PITCH YAW   ALIAS ';
    GetXPosition                           := 'X     ';
    GetYPosition                           := 'Y     ';
    GetZPosition                           := 'Z     ';
    GetYawOrientation                      := 'YAW   ';
    GetPitchOrientation                    := 'PITCH ';
    GetRollOrientation                     := 'ROLL  ';
    GetAlias                               := 'ALIAS ';

  CKAA_VALID_SURF_REV_COMMANDS_1  :=
      'RA N1 N2 M  CC DE CP TE BE RE SC SI CY X  DX Y  DY Z  DZ ' +
          'AS XR YR XS YS ';
  CKAB_VALID_SURF_REV_COMMANDS_2  :=
      'R  DR P  DP YA DA O  OD ID OX OY IX IY AX AY CO CI QO QI EO EI ';
    CKAD_GET_RADIUS		                     := 'RA ';
    CKAC_GET_INDEX_1		                   := 'N1 ';
    CKAE_GET_INDEX_2		                   := 'N2 ';
    CKAF_GET_OUTSIDE_DIA	                 := 'OD ';
    CKAG_GET_INSIDE_DIA		                 := 'ID ';
    CKBF_GET_OUTSIDE_WIDTH_X	             := 'OX ';
    CKBG_GET_OUTSIDE_WIDTH_Y	             := 'OY ';
    CKBH_GET_INSIDE_WIDTH_X	               := 'IX ';
    CKBI_GET_INSIDE_WIDTH_Y	               := 'IY ';
    CKBR_GET_APERTURE_POSITION_X           := 'AX ';
    CKBS_GET_APERTURE_POSITION_Y           := 'AY ';
    CKBJ_CIRCULAR_OUTSIDE_SW	             := 'CO ';
    CKBK_CIRCULAR_INSIDE_SW	               := 'CI ';
    CKBL_SQUARE_OUTSIDE_SW	               := 'QO ';
    CKBM_SQUARE_INSIDE_SW	                 := 'QI ';
    CKBN_ELLIPTICAL_OUTSIDE_SW	           := 'EO ';
    CKBO_ELLIPTICAL_INSIDE_SW	             := 'EI ';
    CKAH_GET_CONIC_CONSTANT	               := 'CC ';
    CKAI_DEFORMATION_CONSTS_SW	           := 'DE ';
    CKAZ_DEFINE_CPC                        := 'CP ';
    CKAJ_RAY_TERMINATION_SURF_SW           := 'TE ';
    CKAK_BEAMSPLITTER_SURF_SW	             := 'BE ';
    CKBE_GET_SURFACE_REFLECTIVITY          := 'RE ';
    CKBP_REFLECTIVE_SURFACE_SW	           := 'M  ';
    CKAL_SCATTERING_SURF_SW	               := 'SC ';
    CKBD_GET_SCATTERING_ANGLE	             := 'SI ';
    CKAM_CYLINDRICAL_SURF_SW	             := 'CY ';
    CKAN_GET_SURF_X_POSITION	             := 'X  ';
    CKAO_GET_SURF_DELTA_X	                 := 'DX ';
    CKAP_GET_SURF_Y_POSITION	             := 'Y  ';
    CKAQ_GET_SURF_DELTA_Y	                 := 'DY ';
    CKAR_GET_SURF_Z_POSITION	             := 'Z  ';
    CKAS_GET_SURF_DELTA_Z	                 := 'DZ ';
    CKAT_GET_SURF_ROLL		                 := 'R  ';
    CKAU_GET_SURF_DELTA_ROLL	             := 'DR ';
    CKAV_GET_SURF_PITCH		                 := 'P  ';
    CKAW_GET_SURF_DELTA_PITCH	             := 'DP ';
    CKAX_GET_SURF_YAW		                   := 'YA ';
    CKAY_GET_SURF_DELTA_YAW	               := 'DA ';
    CKBC_OPD_REF_SURF_SWITCH	             := 'O  ';
    SurfaceArraySwitch                     := 'AS ';
    SurfaceArrayXRepeat                    := 'XR ';
    SurfaceArrayYRepeat                    := 'YR ';
    SurfaceArrayXSpacing                   := 'XS ';
    SurfaceArrayYSpacing                   := 'YS ';

  
  CMAA_VALID_GLASS_REC_FIELD_CODE          := '1 2 3 4 5 6 7 ';
    CMAB_GET_MANUFACTURER_CODE	           := '1 ';
    CMAC_GET_MATERIAL_TYPE	               := '2 ';
    CMAD_GET_GLASS_PREF_CODE	             := '3 ';
    CMAE_GET_NON_GLASS_INDEX_TYPE          := '4 ';
    CMAF_GET_SHORTWAVE_CUTOFF	             := '5 ';
    CMAG_GET_LONGWAVE_CUTOFF	             := '6 ';
    CMAH_GET_DISPERSION_CONSTANTS          := '7 ';

  CNAA_VALID_MANUFAC_COMMANDS	             := 'S O H U D C ';
    CNAB_GET_SCHOTT_MANUFAC_CODE           := 'S ';
    CNAC_GET_OHARA_MANUFAC_CODE	           := 'O ';
    CNAD_GET_HOYA_MANUFAC_CODE	           := 'H ';
    CNAE_GET_SUMITA_MANUFAC_CODE           := 'U ';
    CNAF_GET_DYNASIL_MANUFAC_CODE          := 'D ';
    CNAG_GET_CVD_MANUFACE_CODE	           := 'C ';
  
  COAA_VALID_MATERIAL_COMMANDS	           := 'G C ';
    COAB_GET_GLASS_MATERIAL_TYPE           := 'G ';
    COAC_GET_XTAL_MATERIAL_TYPE	           := 'C ';

  CPAA_VALID_GLASS_PREF_COMMANDS           := 'P N U ';
    CPAB_GET_PREFERRED_GLASS_CODE          := 'P ';
    CPAC_GET_NOT_PREF_GLASS_CODE           := 'N ';
    CPAD_GET_UNAVAIL_GLASS_CODE	           := 'U ';
  
  CQAA_VALID_INDEX_TYPE_COMMANDS           := 'O E ';
    CQAB_GET_ORDINARY_INDEX_CODE           := 'O ';
    CQAC_GET_EXTRAORD_INDEX_CODE           := 'E ';
  
  CRAA_VALID_RAY_REV_COMMANDS	  := 'TX TY TZ HX HY HZ L  IN ';
  ValidRayRevCommands2 :=
      'BHD   ZEN   SFAN  LFAN  AFAN  3FAN  HEX   ISO   RAND  SOLID ';
  ValidRayRevCommands3 :=
      'SQR   LXFAN SLICE WIDE  LAMB  MIN   AZCTR AZWID GAUSS XRAY  ';
    CRAB_GET_RAY_TAIL_X_COORD	             := 'TX ';
    CRAC_GET_RAY_TAIL_Y_COORD	             := 'TY ';
    CRAD_GET_RAY_TAIL_Z_COORD	             := 'TZ ';
    CRAE_GET_RAY_HEAD_X_COORD	             := 'HX ';
    CRAF_GET_RAY_HEAD_Y_COORD	             := 'HY ';
    CRAG_GET_RAY_HEAD_Z_COORD	             := 'HZ ';
    CRAI_GET_RAY_WAVLNGTH_MICRONS          := 'L  ';
    CRAJ_GET_INCIDENT_MED_INDEX            := 'IN ';
    CFAD_GET_BHD_VALUE		                 := 'BHD   ';
    GetMaxZenithDistance                   := 'ZEN   ';
    GetMinZenithDistance                   := 'MIN   ';
    GetAzimuthAngularCenter                := 'AZCTR ';
    GetAzimuthAngularSemiLength            := 'AZWID ';
    CFAP_GENERATE_SYMMETRIC_FAN	           := 'SFAN  ';
    GenerateLinearXFan                     := 'LXFAN ';
    CFAV_GENERATE_LINEAR_Y_FAN             := 'LFAN  ';
    CFAQ_GENERATE_ASYMMETRIC_FAN           := 'AFAN  ';
    CFAE_GENERATE_3FAN		                 := '3FAN  ';
    GenerateSquareGrid                     := 'SQR   ';
    CFAR_GENERATE_HEXAPOLAR_ARRAY          := 'HEX   ';
    CFAS_GENERATE_ISOMETRIC_ARRAY          := 'ISO   ';
    CFAT_GENERATE_RANDOM_ARRAY	           := 'RAND  ';
    CFBF_GENERATE_SOLID_ANGLE_ARRAY        := 'SOLID ';
    GenerateOrangeSliceArray               := 'SLICE ';
    GetAngularWidthOfSlice                 := 'WIDE  ';
    GENERATE_LAMBERTIAN_ARRAY              := 'LAMB  ';
    GENERATE_GAUSSIAN_ARRAY                := 'GAUSS ';
    CFAU_DISABLE_COMPUTED_RAYS	           := 'XRAY  ';

  CSAA_VALID_OPTIMIZE_COMMANDS	           := 'A B C D I Z ';
    CSAB_OPTIMIZE_ACTIVE_SWITCH	           := 'A ';
    CSAD_BOUND_REDUCTION_SWITCH	           := 'B ';
    CSAE_BOUND_RECENTERING_SWITCH          := 'C ';
    CSAC_GET_MERIT_FUNCTION	               := 'D ';
    CSAJ_GET_SURF_OPTIMIZE_DATA	           := 'I ';
    CSAK_CLEAR_ALL_PARAMETERS              := 'Z ';

  CTAA_VALID_MERIT_FUNC_COMMANDS           := 'R F U ';
    CTAB_GET_RMS_BLUR_DIA_CODE	           := 'R ';
    CTAC_GET_FULL_BLUR_DIA_CODE	           := 'F ';
    CTAD_GET_IMAGE_UNIFORMITY              := 'U ';

  CUAA_VALID_SURF_OPTIMIZE_CMDS	  := 'A B C D E G H I J K L M N O P Q R S ';
    CUAB_OPTIMIZE_RADIUS_SW	               := 'A ';
    CUAC_RESET_RADIUS_BOUNDS               := 'B ';
    CUAD_GET_RADIUS_BOUND_1	               := 'C ';
    CUAE_GET_RADIUS_BOUND_2	               := 'D ';
    CUAF_PERMIT_SURF_PITCH_REV_SW          := 'E ';
    CUAH_OPTIMIZE_POSITION_SW	             := 'G ';
    CUAJ_GET_POSITION_BOUND_1	             := 'I ';
    CUAK_GET_POSITION_BOUND_2	             := 'J ';
    CUAI_CONTROL_SEPARATION	               := 'H ';
    CUAR_GET_NEXT_SURFACE	                 := 'S ';
    CUAS_GET_THICKNESS		                 := 'Q ';
    CUAT_GET_DELTA_THICKNESS	             := 'R ';
    CUAL_OPTIMIZE_GLASS_TYPE_SW	           := 'K ';
    CUAM_USE_PREFERRED_GLASSES_SW          := 'L ';
    CUAN_OPTIMIZE_CONIC_CONST_SW           := 'M ';
    CUAO_RESET_CONIC_CONST_BOUNDS          := 'N ';
    CUAP_GET_CONIC_CONST_BOUND_1           := 'O ';
    CUAQ_GET_CONIC_CONST_BOUND_2           := 'P ';
    
  CVAA_VALID_GRAPHICS_COMMANDS             := 'A X Y Z O D ';
    CVAB_REVISE_SCREEN_ASPECT_RATIO        := 'A ';
    CVAC_SET_X_COORD                       := 'X ';
    CVAD_SET_Y_COORD                       := 'Y ';
    CVAE_SET_Z_COORD                       := 'Z ';
    CVAF_GET_VIEWPORT_DIAMETER             := 'O ';
    CVAG_PICTURE_SURFACES                  := 'D ';

END.

