UNIT LADSGlassVar;

INTERFACE

  USES
      LADSUtilUnit;

  CONST
      CZAA_GLASS_CATALOG		   = 'GLASS.TXT';
      CZBI_LAST_GLASS			   = 'LAST';
      CZAH_MAX_CHARS_IN_GLASS_NAME	   = 15;
      CZBA_MAX_GLASSES_IN_MINI_CAT	   = 11;
      CZBF_MAX_GLASS_DISPERSION_CONSTS	   = 12;
      CZBH_MAX_LAMBDAS_IN_MINI_CAT	   = 5;
      MaxBulkGRINMaterials                 = 10;

  TYPE
      DispersionFormulaTypes               = (Schott, Hoya,
                                              Crystal, GRINGLC,
                                              GRINGradium, GRINNSG,
                                              Nope);

      Gradient                             = RECORD
        Dx                                 : DOUBLE;
        Dy                                 : DOUBLE;
        Dz                                 : DOUBLE
      END;

      GlassType = STRING [CZAH_MAX_CHARS_IN_GLASS_NAME];

      ZJA_GLASS_RECORD			   = RECORD
	ZJC_GLASS_NAME	                   : GlassType;
        GlassNameMixedCase                 : GlassType;
	ZJD_MANUFACTURER_CODE		   : STRING [7];
	ZJB_DISPERSION_FORMULA             : DispersionFormulaTypes;
	ZJG_INDEX_TYPE			   : STRING [7];
	ZJF_PREFERENCE_CODE		   : STRING [7];
	ZJH_SHORT_WAVE_CUTOFF		   : DOUBLE;
	ZJI_LONG_WAVE_CUTOFF		   : DOUBLE;
	ZJJ_DISPERSION_CONSTANT		   : ARRAY
	    [1..CZBF_MAX_GLASS_DISPERSION_CONSTS] OF DOUBLE;
	ZJK_WAVELENGTH_AND_INDEX	   : ARRAY
	    [1..CZBH_MAX_LAMBDAS_IN_MINI_CAT] OF RECORD
	  ZJL_WAVELENGTH		   : DOUBLE;
	  ZJM_INDEX			   : DOUBLE
	END
      END;
	    
      ZCZ_INDEX_RECORD			   = RECORD CASE INTEGER OF
	1: (ZBI_REFRACTIVE_INDEX	   : DOUBLE;
            Unused                         : DOUBLE);
	2: (ZCH_GLASS_NAME  : STRING [CZAH_MAX_CHARS_IN_GLASS_NAME])
      END;
      
      BulkGRINMaterialProperties           = RECORD
        CoordinateRotationNeeded           : BOOLEAN;
        CoordinateTranslationNeeded        : BOOLEAN;
        GRINMatlAlias       : STRING [CZAH_MAX_CHARS_IN_GLASS_NAME];
        GRINMatlName        : STRING [CZAH_MAX_CHARS_IN_GLASS_NAME];
        RotationMatrixElements             : RotationMatrix;
        TranslationVectorElements          : TranslationVector;
        BulkMaterialPosition               : PositionVector;
        BulkMaterialOrientation            : OrientationVector
      END;

  VAR
      AKP_REFRACTIVE_INDEX_CALCULATED	   : BOOLEAN;
      ARJ_SET_UP_GLASS_CATALOG		   : BOOLEAN;
      AKE_ADD_GLASS_TO_MINI_CATALOG	   : BOOLEAN;
      AKF_GLASS_RECORD_FOUND		   : BOOLEAN;
      ComputeGradientOnly                  : BOOLEAN;
      FoundGradientIndexMaterial           : BOOLEAN;
      ABE_GLASS_IN_MINI_CATALOG		   : BOOLEAN;
      AKT_NEED_SHORTWAVE_CUTOFF		   : BOOLEAN;
      AKW_LIST_GLASS_DATA		   : BOOLEAN;
      AKX_COMPUTE_REFRACTIVE_INDEX	   : BOOLEAN;
      ALP_OUT_OF_ROOM_IN_MINI_CAT	   : BOOLEAN;
      GlassCommandIsValid                  : BOOLEAN;
      SetupGRINMaterialAlias               : BOOLEAN;

      
      ABD_GLASS_HIGH_PTR		   : INTEGER;
      ABC_GLASS_MINI_CAT_PTR		   : INTEGER;
      AKG_LAMBDA_HIGH_PTR		   : INTEGER;
      AKS_DISPERSION_INDEX		   : INTEGER;
      GRINMaterialOrdinal                  : INTEGER;

      AKO_SPECIFIED_WAVELENGTH		   : DOUBLE;
      AKQ_CALCULATED_REFRACTIVE_INDEX	   : DOUBLE;
      Ax                                   : DOUBLE;
      Ay                                   : DOUBLE;
      Az                                   : DOUBLE;
      Bx                                   : DOUBLE;
      By                                   : DOUBLE;
      Bz                                   : DOUBLE;
      Cx                                   : DOUBLE;
      Cy                                   : DOUBLE;
      Cz                                   : DOUBLE;
      Dx                                   : DOUBLE;
      Dy                                   : DOUBLE;
      Dz                                   : DOUBLE;
      LambdaSquared                        : DOUBLE;
      Lambda4th                            : DOUBLE;
      RSquared                             : DOUBLE;
      R4th                                 : DOUBLE;
      Factor1                              : DOUBLE;
      Factor2                              : DOUBLE;
      Factor3                              : DOUBLE;

      RefIndexGradient                     : Gradient;

      BulkMatlPosition                     : PositionVector;

      AKJ_SPECIFIED_GLASS_NAME	: STRING [CZAH_MAX_CHARS_IN_GLASS_NAME];
      
      ZKA_MINI_GLASS_CATALOG		   : RECORD
	ZKB_GLASS_DATA			   : ARRAY
	    [1..CZBA_MAX_GLASSES_IN_MINI_CAT] OF ZJA_GLASS_RECORD
      END;
      
      GRINMaterial                         : ARRAY
          [1..MaxBulkGRINMaterials] OF BulkGRINMaterialProperties;

      ZKZ_GLASS_DATA_IO_AREA		   : ZJA_GLASS_RECORD;
      
      ZAA_GLASS_CATALOG			   : TEXT;
      
IMPLEMENTATION


(**  LADSIVAR  ***************************************************************
*****************************************************************************)


BEGIN

END.

