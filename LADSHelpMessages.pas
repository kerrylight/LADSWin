unit LADSHelpMessages;

interface

uses SysUtils;

PROCEDURE TeachLADS;
PROCEDURE HelpLADS;
PROCEDURE HelpSurfaceCommands;
PROCEDURE HelpRayCommands;
PROCEDURE HelpListCommand;
PROCEDURE HelpFullOrBriefList;
PROCEDURE HelpTraceOption;
PROCEDURE HelpSequencerOrdinalRange;
PROCEDURE HelpSequencerGroupID;
PROCEDURE HelpSurfaceSequencerCommands;
PROCEDURE HelpArchiveCommands;
PROCEDURE HelpArchiveFileName;
PROCEDURE HelpArchiveDataType;
PROCEDURE HelpEnvironment;
PROCEDURE HelpGlassCatalogCommand;
PROCEDURE HelpSurfaceRevisionCommands;
PROCEDURE HelpRadiusOfCurvature;
PROCEDURE HelpIndexOfRefraction;
PROCEDURE HelpInsideAndOutsideApertures;
PROCEDURE HelpConicConstant;
PROCEDURE HelpSurfaceArrayParameters;
PROCEDURE HelpScatteringAngle;
PROCEDURE HelpSurfaceReflectivity;
PROCEDURE HelpGlassName;
PROCEDURE HelpGRINAlias;
PROCEDURE HelpSurfacePosition;
PROCEDURE HelpSurfaceOrientation;
PROCEDURE HelpSurfaceOrdinal;
PROCEDURE HelpSurfaceOrdinalRange;
PROCEDURE HelpDestinationSurfaceOrdinal;
PROCEDURE HelpRayRevisionCommands;
PROCEDURE HelpRayCoordinates;
PROCEDURE HelpRayWavelength;
PROCEDURE HelpIncidentMediumIndex;
PROCEDURE HelpRayOrdinal;
PROCEDURE HelpRayOrdinalRange;
PROCEDURE HelpDestinationRayOrdinal;
PROCEDURE HelpRayBundleHeadDiameter;
PROCEDURE HelpComputedRayCount;
PROCEDURE HelpRayConeHalfAngle;
PROCEDURE HelpMinimumZenithDistance;
PROCEDURE HelpAzimuthAngularCenter;
PROCEDURE HelpAzimuthSemiLength;
PROCEDURE HelpOrangeSliceAngularWidth;
PROCEDURE HelpGaussianRayBundleCommands;
PROCEDURE HelpOptimizationCommands;
PROCEDURE HelpOptimizationMeritFunction;
PROCEDURE HelpOptimizationSurfaceDataCommands;
PROCEDURE HelpOptimizationRadiusBounds;
PROCEDURE HelpOptimizationPositionBounds;
PROCEDURE HelpGraphicsCommands;
PROCEDURE HelpCPCDesignParameters;
PROCEDURE HelpAsphericDeformationConstants;
implementation

  USES ExpertIO,
       LADSData,
       LADSInitUnit,
       LADSGlassVar,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;

PROCEDURE TeachLADS;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
		('LADS1 (Horizon Optical Systems Simulator #1) is a general');
  CommandIOMemo.IOHistory.Lines.add
		('purpose 3-dimensional, vector-based optical system simulation');
  CommandIOMemo.IOHistory.Lines.add
		('program.  LADS1 has features similar to those provided by many');
  CommandIOMemo.IOHistory.Lines.add
		('commercially available optical design programs, including the');
  CommandIOMemo.IOHistory.Lines.add
		('usual range of geometrical and wave optics capabilities (e.g.,');
  CommandIOMemo.IOHistory.Lines.add
		('spot diagrams, point spread functions, etc.).  In addition,');
  CommandIOMemo.IOHistory.Lines.add
		('however, LADS1 provides powerful features and capabilities');
  CommandIOMemo.IOHistory.Lines.add
		('rarely found or unavailable in other programs.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('A special feature provided by LADS1 is its friendly and');
  CommandIOMemo.IOHistory.Lines.add
		('sophisticated user interface.  This heirarchical, menu-driven');
  CommandIOMemo.IOHistory.Lines.add
		('user interface is facilitated by the tree-structured top-down');
  CommandIOMemo.IOHistory.Lines.add
		('design of the LADS1 source code.  Help functions and input');
  CommandIOMemo.IOHistory.Lines.add
		('validation are provided at every command and data entry point.');
  CommandIOMemo.IOHistory.Lines.add
		('Command and data input are completely free form.  In addition,');
  CommandIOMemo.IOHistory.Lines.add
		('LADS1 provides a type-ahead "expert-mode" data entry capability');
  CommandIOMemo.IOHistory.Lines.add
		('for the expert user.  Both ASCII and binary data file');
  CommandIOMemo.IOHistory.Lines.add
		('processing and archiving ("librarian") features are also');
  CommandIOMemo.IOHistory.Lines.add
		('provided.  These features, in combination with the multi-level');
  CommandIOMemo.IOHistory.Lines.add
		('text file processing features provided by the EXPERTIO code');
  CommandIOMemo.IOHistory.Lines.add
		('unit, make sophisticated multi-tiered batch file processing');
  CommandIOMemo.IOHistory.Lines.add
		('possible.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('LADS1 provides powerful capabilities in the area of 3-');
  CommandIOMemo.IOHistory.Lines.add
		('dimensional optical system simulation.  These capabilities');
  CommandIOMemo.IOHistory.Lines.add
		('comprise a significant departure from traditional methods for');
  CommandIOMemo.IOHistory.Lines.add
		('describing the geometry of optical systems.  The traditional');
  CommandIOMemo.IOHistory.Lines.add
		('approach is to assume that optical surfaces are distributed');
  CommandIOMemo.IOHistory.Lines.add
		('along a 1-dimensional optical axis.  Historically, this');
  CommandIOMemo.IOHistory.Lines.add
		('approach was useful for describing linear optical systems, such');
  CommandIOMemo.IOHistory.Lines.add
		('as telescopes, microscopes, etc.  However, as optical systems');
  CommandIOMemo.IOHistory.Lines.add
		('become more and more sophisticated, this approach becomes more');
  CommandIOMemo.IOHistory.Lines.add
		('and more difficult to justify.  Instead, LADS1 requires the');
  CommandIOMemo.IOHistory.Lines.add
		('position (x,y,z) and orientation (yaw, pitch, roll) for each');
  CommandIOMemo.IOHistory.Lines.add
		('surface to be specified, within a global 3-dimensional');
  CommandIOMemo.IOHistory.Lines.add
		('cartesian coordinate system.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('In LADS1, the position of the vertex of the optical surface,');
  CommandIOMemo.IOHistory.Lines.add
		('and the gradient (i.e., "normal") vector of the surface at the');
  CommandIOMemo.IOHistory.Lines.add
		('vertex, are the basis for describing the position and');
  CommandIOMemo.IOHistory.Lines.add
		('orientation of the surface in global coordinates.  A local');
  CommandIOMemo.IOHistory.Lines.add
		('coordinate system may be thought of as being attached to the');
  CommandIOMemo.IOHistory.Lines.add
		('optical surface, with the origin of the local coordinate system');
  CommandIOMemo.IOHistory.Lines.add
		('located at the surface vertex.  The positive direction along');
  CommandIOMemo.IOHistory.Lines.add
		('the surface vertex normal vector represents the positive z-axis');
  CommandIOMemo.IOHistory.Lines.add
		('of the local surface coordinate system, and becomes the basis');
  CommandIOMemo.IOHistory.Lines.add
		('for making reference to the orientation of the surface with');
  CommandIOMemo.IOHistory.Lines.add
		('respect to the external, master coordinate system.  The x and y');
  CommandIOMemo.IOHistory.Lines.add
		('axes of the local coordinate system are arbitrary for axially-');
  CommandIOMemo.IOHistory.Lines.add
		('symmetric surfaces; for cylindrical surfaces, the local x-axis');
  CommandIOMemo.IOHistory.Lines.add
		('is parallel to the long axis of the cylinder.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('Thus, the position of an optical surface is described in LADS1');
  CommandIOMemo.IOHistory.Lines.add
		('by specifying the x-, y-, and z-coordinates of the surface');
  CommandIOMemo.IOHistory.Lines.add
		('vertex (or, in other words, of the origin of the local');
  CommandIOMemo.IOHistory.Lines.add
		('coordinate system attached to the surface vertex), within the');
  CommandIOMemo.IOHistory.Lines.add
		('master coordinate system.  The orientation of the surface');
  CommandIOMemo.IOHistory.Lines.add
		('within the master coordinate system is described by specifying');
  CommandIOMemo.IOHistory.Lines.add
		('the yaw, pitch, and roll of the local surface coordinate');
  CommandIOMemo.IOHistory.Lines.add
		('system.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('One ramification, and benefit, of this approach is that it is');
  CommandIOMemo.IOHistory.Lines.add
		('no longer necessary to refer to the orientation of an optical');
  CommandIOMemo.IOHistory.Lines.add
		('surface by the artificial means of specifying a positive or a');
  CommandIOMemo.IOHistory.Lines.add
		('negative radius of curvature.  The surface orientation is');
  CommandIOMemo.IOHistory.Lines.add
		('described in the simple terms of how it is actually situated');
  CommandIOMemo.IOHistory.Lines.add
		('within the master coordinate system, and the radius of');
  CommandIOMemo.IOHistory.Lines.add
		('curvature is always a positive number.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('Since linear geometry is frequently encountered in optical');
  CommandIOMemo.IOHistory.Lines.add
		('systems, LADS1 provides a simplified approach for describing');
  CommandIOMemo.IOHistory.Lines.add
		('new surfaces by requesting only the z-axis coordinate of the');
  CommandIOMemo.IOHistory.Lines.add
		('surface vertex.  After surfaces are initially entered, LADS1');
  CommandIOMemo.IOHistory.Lines.add
		('provides powerful and user friendly tools for easy manipulation');
  CommandIOMemo.IOHistory.Lines.add
		('of the position and orientation of single surfaces, or entire');
  CommandIOMemo.IOHistory.Lines.add
		('groups of surfaces.  Rotations can be specified with respect to');
  CommandIOMemo.IOHistory.Lines.add
		('global coordinates, or with respect to the local coordinate');
  CommandIOMemo.IOHistory.Lines.add
		('system attached to a particular surface vertex.  (LADS1 always');
  CommandIOMemo.IOHistory.Lines.add
		('recomputes the position and orientation of each surface in');
  CommandIOMemo.IOHistory.Lines.add
		('terms of global coordinates.)  A pivot point may be located at');
  CommandIOMemo.IOHistory.Lines.add
		('a surface or at any arbitrary point, with rotations specified');
  CommandIOMemo.IOHistory.Lines.add
		('either in terms of Euler angles, or in terms of rotations about');
  CommandIOMemo.IOHistory.Lines.add
		('an Euler axis (via a quaternion specified by the user).');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('By means of this approach, LADS1 is able to express the design');
  CommandIOMemo.IOHistory.Lines.add
		('of an optical system in terms useful to MCAD and finite element');
  CommandIOMemo.IOHistory.Lines.add
		('analysis programs.  With this approach, LADS1 is easily able to');
  CommandIOMemo.IOHistory.Lines.add
		('establish an interface between independently designed optical');
  CommandIOMemo.IOHistory.Lines.add
		('subsections of extremely complex optical systems.  This');
  CommandIOMemo.IOHistory.Lines.add
		('complete 3-dimensional approach also greatly facilitates the');
  CommandIOMemo.IOHistory.Lines.add
		('ability to perform recursive ray tracing for energy transfer');
  CommandIOMemo.IOHistory.Lines.add
		('(etendue) or radiometric analyses.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('LADS1 presently allows for the specification of 50 optical');
  CommandIOMemo.IOHistory.Lines.add
		('surfaces.  Either axially-symmetric or cylindrical optical');
  CommandIOMemo.IOHistory.Lines.add
		('surfaces may be specified in any of a number of different');
  CommandIOMemo.IOHistory.Lines.add
		('forms, including conics and high-order aspherics.  10 user-');
  CommandIOMemo.IOHistory.Lines.add
		('defined light rays, and up to 10,000 program-generated light');
  CommandIOMemo.IOHistory.Lines.add
		('rays (more, depending on available memory) are available.');
  CommandIOMemo.IOHistory.Lines.add
		('Program-generated light rays are provided in a number of useful');
  CommandIOMemo.IOHistory.Lines.add
		('forms, including non-symmetric gaussian light ray bundles for');
  CommandIOMemo.IOHistory.Lines.add
		('simulating a wide variety of laser beams, plus many other');
  CommandIOMemo.IOHistory.Lines.add
		('useful types of ray fans and bundles.  Each user-specified ray');
  CommandIOMemo.IOHistory.Lines.add
		('is treated as a principal ray for the specified bundle or fan.');
  CommandIOMemo.IOHistory.Lines.add
		('Extremely complex optical systems containing more than 50');
  CommandIOMemo.IOHistory.Lines.add
		('surfaces can be easily analysed by saving the system of light');
  CommandIOMemo.IOHistory.Lines.add
		('rays as they exit a specified surface, as a data file.  This');
  CommandIOMemo.IOHistory.Lines.add
		('ray data file is then used as input for the next group of');
  CommandIOMemo.IOHistory.Lines.add
		('surfaces to be processed.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
		('Future LADS1 Enhancements');
  CommandIOMemo.IOHistory.Lines.add
		('------------------------');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
		('Future enhancements to LADS1 will include a graphical user');
  CommandIOMemo.IOHistory.Lines.add
		('interface, and graphics data exchange capabilities for');
  CommandIOMemo.IOHistory.Lines.add
		('facilitating the incorporation of optical design data into a');
  CommandIOMemo.IOHistory.Lines.add
		('mechanical design, via MCAD software.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpLADS;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  This is a general purpose, three-dimensional vector-');
  CommandIOMemo.IOHistory.Lines.add
	('  based optical ray trace program.  ' +
        IntToStr (CZAD_MAX_COMPUTED_RAYS) + ' light ray');
  CommandIOMemo.IOHistory.Lines.add
	('  vectors (' + IntToStr (CZAC_MAX_NUMBER_OF_RAYS) +
      ' are user-definable) may be traced');
  CommandIOMemo.IOHistory.Lines.add
	('  through ' + IntToStr (CZAB_MAX_NUMBER_OF_SURFACES) +
      ' consecutive optical surfaces.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid commands are:');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  S    Surface -- the user will be prompted to describe');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         an optical surface.');	  
  CommandIOMemo.IOHistory.Lines.add
	('  R    Ray -- the user will be prompted to describe an');	  
  CommandIOMemo.IOHistory.Lines.add
	('         incident optical light ray vector.');	  
  CommandIOMemo.IOHistory.Lines.add
	('  G    Glass catalog information -- This command');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         enables the user to view the contents of the');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         glass catalog.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  E    Environment -- The user will be prompted to');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         describe the spatial configuration of a');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         specified block of surfaces.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  L    List -- will list the current stored data for 1');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         or more surfaces or rays.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  O    Trace option -- specific trace options may be');
  CommandIOMemo.IOHistory.Lines.add	  
	('         set or cancelled.');
  CommandIOMemo.IOHistory.Lines.add	  
	('  T    Trace -- execute ray tracing.');
  CommandIOMemo.IOHistory.Lines.add	  
	('  A    Archive data -- copy surface data to or from');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         permanent storage.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  I    Initialize -- initializes/clears LADS1 memory.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  V    Version report -- lists current LADS1');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         enhancements and/or bug fixes.');	  
  Q980_REQUEST_MORE_OUTPUT;	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  HELP   This command activates the built-in');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         documentation or teach functions of this');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         program.  "HELP" may be entered at any command');
  CommandIOMemo.IOHistory.Lines.add	  
	('         or data entry point.');
  CommandIOMemo.IOHistory.Lines.add	  
	('  END  This command causes immediate end of execution of');
  CommandIOMemo.IOHistory.Lines.add	  
	('         this program.  "END" may be entered at any');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('         command or data entry point.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  UPPER or lower case letters are always acceptable.');	  
  CommandIOMemo.IOHistory.Lines.add ('');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  "ENTER COMMAND:');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('     S(urface R(ay L(ist O(ption T(race A(rchive", etc.');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  is at the highest level of the program.  The user may');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  always transfer control from lower levels of the');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  program to higher levels (e.g., the ENTER COMMAND');
  CommandIOMemo.IOHistory.Lines.add	  
	('  level) by one or more blank carriage returns, by one');
  CommandIOMemo.IOHistory.Lines.add	  
	('  or more trailing commas, or by two or more imbedded');
  CommandIOMemo.IOHistory.Lines.add	  
	('  commas.');	  
  Q980_REQUEST_MORE_OUTPUT;	  
  CommandIOMemo.IOHistory.Lines.add ('');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  An alternate command (disk) file is also available to');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  the user.  Interactive commands in the format');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  expected by this program may be entered in this file');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  via one of the system editors.  At the beginning of');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  execution of this program, this command file (called');	  
  CommandIOMemo.IOHistory.Lines.add	  
	('  LADSCMND.TEXT) will be opened and read by the');	  
  CommandIOMemo.IOHistory.Lines.add
	('  program.  After the instructions on this alternate');
  CommandIOMemo.IOHistory.Lines.add
	('  file have been executed, control will be passed to');
  CommandIOMemo.IOHistory.Lines.add
  	('  the user.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid surface operation types are:');
  CommandIOMemo.IOHistory.Lines.add
	('  N    New/replace -- This command provides for entering');
  CommandIOMemo.IOHistory.Lines.add
	('         new surface specifications for a surface which');
  CommandIOMemo.IOHistory.Lines.add
	('         has not yet been specified.  This command can');
  CommandIOMemo.IOHistory.Lines.add
  	('         also be used as an automatic Delete/Insert.');
  CommandIOMemo.IOHistory.Lines.add
	('         The effect of this is to replace all surface');
  CommandIOMemo.IOHistory.Lines.add
	('         data for an "old" surface with completely new');
  CommandIOMemo.IOHistory.Lines.add
	('         data.');
  CommandIOMemo.IOHistory.Lines.add
	('  I    Insert -- This command will cause a new surface');
  CommandIOMemo.IOHistory.Lines.add
	('         to be inserted ahead of the surface indicated');
  CommandIOMemo.IOHistory.Lines.add
	('         by the user.  For example, the command "I 3"');
  CommandIOMemo.IOHistory.Lines.add
	('         will cause old surface 3 to become surface 4,');
  CommandIOMemo.IOHistory.Lines.add
	('         and all subsequent surfaces will shift up by');
  CommandIOMemo.IOHistory.Lines.add
	('         1.  The user may then enter data for new');
  CommandIOMemo.IOHistory.Lines.add
	('         surface 3.');
  CommandIOMemo.IOHistory.Lines.add
	('  D    Delete -- This command will cause the current');
  CommandIOMemo.IOHistory.Lines.add
	('         surface to be deleted, and all subsequent');
  CommandIOMemo.IOHistory.Lines.add
	('         surfaces will shift down by 1.  For example,');
  CommandIOMemo.IOHistory.Lines.add
	('         "D 3" will delete surface 3 by causing surface');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('         4 to become surface 3, surface 5 to become 4,');
  CommandIOMemo.IOHistory.Lines.add
	('         etc.  Surface deletion is not performed until');
  CommandIOMemo.IOHistory.Lines.add
	('         after the user has indicated all surfaces to be');
  CommandIOMemo.IOHistory.Lines.add
	('         deleted.');
  CommandIOMemo.IOHistory.Lines.add
	('  C    Copy -- This command allows the user to first');
  CommandIOMemo.IOHistory.Lines.add
	('         identify a block of surfaces to Copy, and then');
  CommandIOMemo.IOHistory.Lines.add
	('         to specify a destination surface where the');
  CommandIOMemo.IOHistory.Lines.add
	('         Copied block of surfaces will be inserted.  The');
  CommandIOMemo.IOHistory.Lines.add
	('         Copied block of surfaces will be inserted');
  CommandIOMemo.IOHistory.Lines.add
	('         before (ahead of) the destination surface.  The');
  CommandIOMemo.IOHistory.Lines.add
	('         Copied block of surfaces will not be deleted');
  CommandIOMemo.IOHistory.Lines.add
	('         from their original location.  (Caution:  there');
  CommandIOMemo.IOHistory.Lines.add
	('         is room for only ' +
        IntToStr (CZAB_MAX_NUMBER_OF_SURFACES) +
      ' surfaces in this program.');
  CommandIOMemo.IOHistory.Lines.add
	('         Therefore, the final surface(s) will be lost as');
  CommandIOMemo.IOHistory.Lines.add
	('         new surfaces are added via Copy or Insert.)');
  CommandIOMemo.IOHistory.Lines.add
  	('  M    Move -- The action of this command is identical');
  CommandIOMemo.IOHistory.Lines.add
	('         to the operation of the Copy command, except');
  CommandIOMemo.IOHistory.Lines.add
	('         that the Moved block of surfaces are deleted');
  CommandIOMemo.IOHistory.Lines.add
	('         from their original location.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  S    Sleep -- This command causes the specified');
  CommandIOMemo.IOHistory.Lines.add
	('         surface(s) to be ignored during ray tracing.');
  CommandIOMemo.IOHistory.Lines.add
	('         This command would normally be used in');
  CommandIOMemo.IOHistory.Lines.add
	('         conjunction with the Wake command to quickly');
  CommandIOMemo.IOHistory.Lines.add
	('         ascertain the effect of temporarily removing');
  CommandIOMemo.IOHistory.Lines.add
	('         surfaces from an optical train.');
  CommandIOMemo.IOHistory.Lines.add
  	('  W    Wake -- Used in conjunction with Sleep command.');
  CommandIOMemo.IOHistory.Lines.add
	('         (See Sleep command description above.)');
  CommandIOMemo.IOHistory.Lines.add
	('  R    Revise -- This command will enable the user to');
  CommandIOMemo.IOHistory.Lines.add
	('         revise all surface data elements, except the');
  CommandIOMemo.IOHistory.Lines.add
	('         surface ordinal and the Wake/Sleep flag.');
  CommandIOMemo.IOHistory.Lines.add
	('  nn   If a number is entered, this program will assume');
  CommandIOMemo.IOHistory.Lines.add
	('         that the user wishes to revise surface data');
  CommandIOMemo.IOHistory.Lines.add
	('         for the surface whose ordinal number is entered');
  CommandIOMemo.IOHistory.Lines.add
	('         here.  This saves a little time in not having');
  CommandIOMemo.IOHistory.Lines.add
	('         to first enter the "R" command to designate a');
  CommandIOMemo.IOHistory.Lines.add
	('         revision.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid ray operation types are:');
  CommandIOMemo.IOHistory.Lines.add
	('  N    New/replace -- This command provides for entering');
  CommandIOMemo.IOHistory.Lines.add
	('         new ray specifications for a ray which');
  CommandIOMemo.IOHistory.Lines.add
  	('         has not yet been specified.  This command can');
  CommandIOMemo.IOHistory.Lines.add
	('         also be used as an automatic Delete/Insert.');
  CommandIOMemo.IOHistory.Lines.add
	('         The effect of this is to replace all ray');
  CommandIOMemo.IOHistory.Lines.add
	('         data for an "old" ray with completely new');
  CommandIOMemo.IOHistory.Lines.add
	('         data.');
  CommandIOMemo.IOHistory.Lines.add
	('  I    Insert -- This command will cause a new ray');
  CommandIOMemo.IOHistory.Lines.add
	('         to be inserted ahead of the ray indicated');
  CommandIOMemo.IOHistory.Lines.add
	('         by the user.  For example, the command "I 3"');
  CommandIOMemo.IOHistory.Lines.add
	('         will cause old ray 3 to become ray 4,');
  CommandIOMemo.IOHistory.Lines.add
	('         and all subsequent rays will shift up by 1.');
  CommandIOMemo.IOHistory.Lines.add
	('         The user may then enter data for new ray 3.');
  CommandIOMemo.IOHistory.Lines.add
	('  D    Delete -- This command will cause the current');
  CommandIOMemo.IOHistory.Lines.add
	('         ray to be deleted, and all subsequent');
  CommandIOMemo.IOHistory.Lines.add
	('         rays will shift down by 1.  For example,');
  CommandIOMemo.IOHistory.Lines.add
	('         "D 3" will delete ray 3 by causing ray');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('         4 to become ray 3, ray 5 to become 4,');
  CommandIOMemo.IOHistory.Lines.add
	('         etc.  Ray deletion is not performed until');
  CommandIOMemo.IOHistory.Lines.add
	('         after the user has indicated all rays to be');
  CommandIOMemo.IOHistory.Lines.add
	('         deleted.');
  CommandIOMemo.IOHistory.Lines.add
	('  C    Copy -- This command allows the user to first');
  CommandIOMemo.IOHistory.Lines.add
	('         identify a block of rays to Copy, and then');
  CommandIOMemo.IOHistory.Lines.add
	('         to specify a destination ray where the');
  CommandIOMemo.IOHistory.Lines.add
	('         Copied block of rays will be inserted.  The');
  CommandIOMemo.IOHistory.Lines.add
	('         Copied block of rays will be inserted');
  CommandIOMemo.IOHistory.Lines.add
	('         before (ahead of) the destination ray.  The');
  CommandIOMemo.IOHistory.Lines.add
	('         Copied block of rays will not be deleted');
  CommandIOMemo.IOHistory.Lines.add
	('         from their original location.  (Caution:  there');
  CommandIOMemo.IOHistory.Lines.add
	('         is room for only ' +
        IntToStr (CZAC_MAX_NUMBER_OF_RAYS) +
      ' rays in this program.');
  CommandIOMemo.IOHistory.Lines.add
	('         Therefore, the final ray(s) will be lost as');
  CommandIOMemo.IOHistory.Lines.add
	('         new rays are added via Copy or Insert.)');
  CommandIOMemo.IOHistory.Lines.add
  	('  M    Move -- The action of this command is identical');
  CommandIOMemo.IOHistory.Lines.add
	('         to the operation of the Copy command, except');
  CommandIOMemo.IOHistory.Lines.add
	('         that the Moved block of rays are deleted');
  CommandIOMemo.IOHistory.Lines.add
	('         from their original location.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  S    Sleep -- This command causes the specified');
  CommandIOMemo.IOHistory.Lines.add
	('         ray(s) to be ignored during ray tracing.');
  CommandIOMemo.IOHistory.Lines.add
	('         This command would normally be used in');
  CommandIOMemo.IOHistory.Lines.add
	('         conjunction with the Wake command to quickly');
  CommandIOMemo.IOHistory.Lines.add
	('         ascertain the effect of temporarily removing');
  CommandIOMemo.IOHistory.Lines.add
	('         rays while analyzing an optical train.');
  CommandIOMemo.IOHistory.Lines.add
  	('  W    Wake -- Used in conjunction with Sleep command.');
  CommandIOMemo.IOHistory.Lines.add
	('         (See Sleep command description above.)');
  CommandIOMemo.IOHistory.Lines.add
	('  R    Revise -- This command will enable the user to');
  CommandIOMemo.IOHistory.Lines.add
	('         revise all ray data elements, except the');
  CommandIOMemo.IOHistory.Lines.add
	('         ray ordinal and the Wake/Sleep flag.');
  CommandIOMemo.IOHistory.Lines.add
	('  nnn  If a number is entered, this program will assume');
  CommandIOMemo.IOHistory.Lines.add
	('         that the user wishes to revise ray data');
  CommandIOMemo.IOHistory.Lines.add
	('         for the ray whose ordinal number is entered');
  CommandIOMemo.IOHistory.Lines.add
	('         here.  This saves a little time in not having');
  CommandIOMemo.IOHistory.Lines.add
	('         to first enter the "R" command to designate a');
  CommandIOMemo.IOHistory.Lines.add
	('         revision.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpListCommand;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
  	('Valid responses are:');
  CommandIOMemo.IOHistory.Lines.add
  	('  S    List surfaces.  User must specify range of');
  CommandIOMemo.IOHistory.Lines.add
  	('         surfaces to list.');
  CommandIOMemo.IOHistory.Lines.add
  	('  R    List rays.  User must specify range of rays to');
  CommandIOMemo.IOHistory.Lines.add
  	('         list.');
  CommandIOMemo.IOHistory.Lines.add
  	('  P    Printer output switch.  This is a toggle');
  CommandIOMemo.IOHistory.Lines.add
  	('         switch.  When enabled, information will be');
  CommandIOMemo.IOHistory.Lines.add
  	('         displayed on the console, and will also be');
  CommandIOMemo.IOHistory.Lines.add
  	('         printed on the system printer.  When');
  CommandIOMemo.IOHistory.Lines.add
  	('         disabled, information will be displayed only');
  CommandIOMemo.IOHistory.Lines.add
  	('         on the console.');
  CommandIOMemo.IOHistory.Lines.add
  	('  L    List file output switch.  This is a toggle');
  CommandIOMemo.IOHistory.Lines.add
  	('         switch.  When enabled, information will be');
  CommandIOMemo.IOHistory.Lines.add
  	('         displayed on the console, and will also be');
  CommandIOMemo.IOHistory.Lines.add
  	('         written to a permanent text file.  When');
  CommandIOMemo.IOHistory.Lines.add
  	('         disabled, information will be displayed only');
  CommandIOMemo.IOHistory.Lines.add
  	('         on the console.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpFullOrBriefList;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid responses are:');
  CommandIOMemo.IOHistory.Lines.add
	('  F    Full -- Full listing of all input data for the');
  CommandIOMemo.IOHistory.Lines.add
	('         specified range of surfaces or rays.');
  CommandIOMemo.IOHistory.Lines.add
	('  B    Brief -- Brief listing of only essential data');
  CommandIOMemo.IOHistory.Lines.add
	('         elements for specified range of surfaces or');
  CommandIOMemo.IOHistory.Lines.add
  	('         rays.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpTraceOption;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('Valid trace option codes are:');
  CommandIOMemo.IOHistory.Lines.add
      ('  ORD    Designated "image" surface (default is 1).');
  CommandIOMemo.IOHistory.Lines.add
      ('           Viewport position and diameter will be');
  CommandIOMemo.IOHistory.Lines.add
      ('           set to surface position and diameter, for');
  CommandIOMemo.IOHistory.Lines.add
      ('           subsequent use by ray trace graphics');
  CommandIOMemo.IOHistory.Lines.add
      ('           functions, such as spot diagrams, etc.');
  CommandIOMemo.IOHistory.Lines.add
      ('  DES    Activates designated image surface.  Image');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface is automatically activated by "ORD"');
  CommandIOMemo.IOHistory.Lines.add
      ('           function.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XDES   De-activates designated image surface.');
  CommandIOMemo.IOHistory.Lines.add
      ('  VX     X coordinate of viewport for spot diagram or');
  CommandIOMemo.IOHistory.Lines.add
      ('           for draw function.');
  CommandIOMemo.IOHistory.Lines.add
      ('  VY     Y coordinate of viewport for spot diagram or');
  CommandIOMemo.IOHistory.Lines.add
      ('           for draw function.');
  CommandIOMemo.IOHistory.Lines.add
      ('  VZ     Z coordinate of viewport for draw function.');
  CommandIOMemo.IOHistory.Lines.add
      ('  DIA    Viewport diameter for spot diagram or for');
  CommandIOMemo.IOHistory.Lines.add
      ('           draw function.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  CLR    Clears all option switches related to');
  CommandIOMemo.IOHistory.Lines.add
      ('           automatic generation of light rays,');
  CommandIOMemo.IOHistory.Lines.add
      ('           and manner of display of trace results (i.e.');
  CommandIOMemo.IOHistory.Lines.add
      ('           spot diagrams, spot intensity distribution,');
  CommandIOMemo.IOHistory.Lines.add
      ('           OPD, etc.)');
  CommandIOMemo.IOHistory.Lines.add
      ('  REC    Activate non-sequential ray tracing.  The next');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface to be encountered in the ray trace');
  CommandIOMemo.IOHistory.Lines.add
      ('           will be that surface which has the smallest');
  CommandIOMemo.IOHistory.Lines.add
      ('           distance, in the direction of the light ray,');
  CommandIOMemo.IOHistory.Lines.add
      ('           from the present point of interaction.  The');
  CommandIOMemo.IOHistory.Lines.add
      ('           point of intersection of the light ray with');
  CommandIOMemo.IOHistory.Lines.add
      ('           each surface must first be computed in order');
  CommandIOMemo.IOHistory.Lines.add
      ('           to determine which surface is to be the next');
  CommandIOMemo.IOHistory.Lines.add
      ('           one for interaction with the light ray.  Note');
  CommandIOMemo.IOHistory.Lines.add
      ('           that each surface can be accessed any number');
  CommandIOMemo.IOHistory.Lines.add
      ('           of times before the intensity of the light');
  CommandIOMemo.IOHistory.Lines.add
      ('           falls below the minimum cutoff value.  Also,');
  CommandIOMemo.IOHistory.Lines.add
      ('           a light ray may fail to encounter any');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface.  Obviously, non-sequentail ray tracing');
  CommandIOMemo.IOHistory.Lines.add
      ('           can be extremely time consuming.  Use it with');
  CommandIOMemo.IOHistory.Lines.add
      ('           caution.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  SDEF   User will be prompted to enter a sequence of');
  CommandIOMemo.IOHistory.Lines.add
      ('           surfaces.  The LADS1 surface sequencer will');
  CommandIOMemo.IOHistory.Lines.add
      ('           process surfaces in the order specified by');
  CommandIOMemo.IOHistory.Lines.add
      ('           the user during the actual ray trace, if the');
  CommandIOMemo.IOHistory.Lines.add
      ('           user enables the surface sequencer via the');
  CommandIOMemo.IOHistory.Lines.add
      ('           "SON" command.');
  CommandIOMemo.IOHistory.Lines.add
      ('  SON    The LADS1 surface sequencer will process');
  CommandIOMemo.IOHistory.Lines.add
      ('           surfaces in the order specified by the user,');
  CommandIOMemo.IOHistory.Lines.add
      ('           as defined in the surface sequence table.');
  CommandIOMemo.IOHistory.Lines.add
      ('  SOFF   The LADS1 surface sequencer will process');
  CommandIOMemo.IOHistory.Lines.add
      ('           surfaces in numerically ascending order, by');
  CommandIOMemo.IOHistory.Lines.add
      ('           the surface ordinal value, or in non-.' +
      'sequential order.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XREC   De-activates non-sequential ray tracing.');
  CommandIOMemo.IOHistory.Lines.add
      ('  ERRON  Enables printing of non-fatal error messages');
  CommandIOMemo.IOHistory.Lines.add
      ('           during sequential ray trace.');
  CommandIOMemo.IOHistory.Lines.add
      ('  EROFF  Disables printing of non-fatal error messages');
  CommandIOMemo.IOHistory.Lines.add
      ('           during sequential ray trace.  Typical error');
  CommandIOMemo.IOHistory.Lines.add
      ('           messages relating to vignetting, etc., will');
  CommandIOMemo.IOHistory.Lines.add
      ('           be disabled.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  WRAY   Enable writing of alternate ray file.');
  CommandIOMemo.IOHistory.Lines.add
      ('           You will be prompted to enter the name of an');
  CommandIOMemo.IOHistory.Lines.add
      ('           alternate ray file, and the ordinal');
  CommandIOMemo.IOHistory.Lines.add
      ('           value for a surface.  The position and');
  CommandIOMemo.IOHistory.Lines.add
      ('           direction cosines for the light rays written');
  CommandIOMemo.IOHistory.Lines.add
      ('           to the alternate ray file will be as they');
  CommandIOMemo.IOHistory.Lines.add
      ('           exist after the rays exit the specified');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface.');
  CommandIOMemo.IOHistory.Lines.add
      ('  RRAY   Enable reading of alternate ray file.  This');
  CommandIOMemo.IOHistory.Lines.add
      ('           command will override the use of user-');
  CommandIOMemo.IOHistory.Lines.add
      ('           specified rays, and program-generated rays,');
  CommandIOMemo.IOHistory.Lines.add
      ('           for the present execution of the Trace');
  CommandIOMemo.IOHistory.Lines.add
      ('           command.  You will be prompted to enter the');
  CommandIOMemo.IOHistory.Lines.add
      ('           name of an alternate ray file.');
  CommandIOMemo.IOHistory.Lines.add
      ('  NRAY   Cancel reading/writing of an alternate ray');
  CommandIOMemo.IOHistory.Lines.add
      ('           file.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  DRAW   Surfaces and rays within the vicinity of the');
  CommandIOMemo.IOHistory.Lines.add
      ('           the viewport will be drawn on the display');
  CommandIOMemo.IOHistory.Lines.add
      ('           during ray tracing.  The position of the');
  CommandIOMemo.IOHistory.Lines.add
      ('           viewport must first be specified by means');
  CommandIOMemo.IOHistory.Lines.add
      ('           the VX, VY, and VZ commands, with the data');
  CommandIOMemo.IOHistory.Lines.add
      ('           being interpreted as the coordinates of the');
  CommandIOMemo.IOHistory.Lines.add
      ('           center of the viewport.  The viewport is');
  CommandIOMemo.IOHistory.Lines.add
      ('           considered as lying in the y-z plane.  The');
  CommandIOMemo.IOHistory.Lines.add
      ('           intersection of this plane with each surface');
  CommandIOMemo.IOHistory.Lines.add
      ('           results in curves which are displayed on');
  CommandIOMemo.IOHistory.Lines.add
      ('           the terminal.  The diameter of the viewport');
  CommandIOMemo.IOHistory.Lines.add
      ('           provides the drawing scale.  Rays are drawn');
  CommandIOMemo.IOHistory.Lines.add
      ('           by projecting them onto the viewport y-z');
  CommandIOMemo.IOHistory.Lines.add
      ('           plane.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XDRAW  Cancel drawing of surfaces and rays.');
  CommandIOMemo.IOHistory.Lines.add
      ('  NUM    Surface numbers will be displayed adjacent to');
  CommandIOMemo.IOHistory.Lines.add
      ('           each surface, when the "DRAW" command is');
  CommandIOMemo.IOHistory.Lines.add
      ('           enabled.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XNUM   Cancel display of surface numbers.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  CDTL   Ray trace detail results will be displayed on');
  CommandIOMemo.IOHistory.Lines.add
      ('           the system display terminal, in global');
  CommandIOMemo.IOHistory.Lines.add
      ('           coordinates.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XCDTL  Disable CDTL.');
  CommandIOMemo.IOHistory.Lines.add
      ('  LDTL   Ray trace detail results will be displayed on');
  CommandIOMemo.IOHistory.Lines.add
      ('           the system display terminal, in local');
  CommandIOMemo.IOHistory.Lines.add
      ('           coordinates.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XLDTL  Disable LDTL.');
  CommandIOMemo.IOHistory.Lines.add
      ('  PDTL   Ray trace detail results will be printed on');
  CommandIOMemo.IOHistory.Lines.add
      ('           system printer.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XPDTL  Disable PDTL.');
  CommandIOMemo.IOHistory.Lines.add
      ('  FDTL   Ray trace detail results will be written to');
  CommandIOMemo.IOHistory.Lines.add
      ('           user-specified file.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XFDTL  Disable FDTL.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  CSPT   The spot diagram will be displayed on your' +
      ' terminal.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XCSPT  Disable CSPT.');
  CommandIOMemo.IOHistory.Lines.add
      ('  CTRL   Specify surface to be used as a limiting' +
      ' aperture.');
  CommandIOMemo.IOHistory.Lines.add
      ('  FSPT   Put spot diagram coordinates on an output file');
  CommandIOMemo.IOHistory.Lines.add
      ('           for off-line plotting.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XFSPT  Disable FSPT.');
  CommandIOMemo.IOHistory.Lines.add
      ('  FOPD   Display full optical path difference statistics');
  CommandIOMemo.IOHistory.Lines.add
      ('           including RMS optical path difference.  For');
  CommandIOMemo.IOHistory.Lines.add
      ('           the OPD-type functions, you must specify an');
  CommandIOMemo.IOHistory.Lines.add
      ('           entrance OPD reference surface and an exit');
  CommandIOMemo.IOHistory.Lines.add
      ('           OPD reference surface.  The entrance OPD');
  CommandIOMemo.IOHistory.Lines.add
      ('           reference surface would typically be a flat');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface placed on the infinite conjugates');
  CommandIOMemo.IOHistory.Lines.add
      ('           side of a lens system, while the exit OPD');
  CommandIOMemo.IOHistory.Lines.add
      ('           reference surface would have a radius equal');
  CommandIOMemo.IOHistory.Lines.add
      ('           to the outgoing wavefront, and would be');
  CommandIOMemo.IOHistory.Lines.add
      ('           placed near the system exit pupil.');
  CommandIOMemo.IOHistory.Lines.add
      ('  BOPD   Display only RMS optical path difference.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XOPD   Disable OPD.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  FPSF   Put position and intensity coordinates for the');
  CommandIOMemo.IOHistory.Lines.add
      ('           PSF on an output file for off-line plotting.');
  CommandIOMemo.IOHistory.Lines.add
      ('           This program does a point-by-point compu-');
  CommandIOMemo.IOHistory.Lines.add
      ('           tation of the PSF using an algebraic');
  CommandIOMemo.IOHistory.Lines.add
      ('           approach based on superposition of Huygens');
  CommandIOMemo.IOHistory.Lines.add
      ('           wavelets.  Please ensure that: (1) entrance');
  CommandIOMemo.IOHistory.Lines.add
      ('           and exit OPD reference surfaces are speci-');
  CommandIOMemo.IOHistory.Lines.add
      ('           fied; (2) the exit OPD reference surface is');
  CommandIOMemo.IOHistory.Lines.add
      ('           chosen to be near, or coincide with, the');
  CommandIOMemo.IOHistory.Lines.add
      ('           system exit pupil; (3) the image surface is');
  CommandIOMemo.IOHistory.Lines.add
      ('           centered on, and normal to, the z-axis; (4)');
  CommandIOMemo.IOHistory.Lines.add
      ('           the diameter of the image surface is set to');
  CommandIOMemo.IOHistory.Lines.add
      ('           be between 2 and 3 times the diameter of the');
  CommandIOMemo.IOHistory.Lines.add
      ('           Airy disc.  In addition, this program');
  CommandIOMemo.IOHistory.Lines.add
      ('           assumes that all rays have uniform intensity');
  CommandIOMemo.IOHistory.Lines.add
      ('           and have parallel polarization, that the PSF');
  CommandIOMemo.IOHistory.Lines.add
      ('           has circular symmetry about the z-axis (100');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('           probe points are distributed along the y-axis)');
  CommandIOMemo.IOHistory.Lines.add
      ('           that the lens system units are mm, and that');
  CommandIOMemo.IOHistory.Lines.add
      ('           wavelengths are in microns.  The Kirchoff');
  CommandIOMemo.IOHistory.Lines.add
      ('           obliquity factor and range factor are');
  CommandIOMemo.IOHistory.Lines.add
      ('           ignored, due to the extremely small angles');
  CommandIOMemo.IOHistory.Lines.add
      ('           involved.  It is suggested that you use');
  CommandIOMemo.IOHistory.Lines.add
      ('           random ray generation to populate the ray');
  CommandIOMemo.IOHistory.Lines.add
      ('           bundle to be used for PSF computation.');
  CommandIOMemo.IOHistory.Lines.add
      ('           Aliasing and granularity are reduced as');
  CommandIOMemo.IOHistory.Lines.add
      ('           the random ray bundle is populated with');
  CommandIOMemo.IOHistory.Lines.add
      ('           increasing numbers of rays.  This must be');
  CommandIOMemo.IOHistory.Lines.add
      ('           balanced against the increase in time to');
  CommandIOMemo.IOHistory.Lines.add
      ('           compute the PSF.  Good accuracy may');
  CommandIOMemo.IOHistory.Lines.add
      ('           typically be achieved with 10,000 rays.  For');
  CommandIOMemo.IOHistory.Lines.add
      ('           higher numerical apertures (> 0.2), you may');
  CommandIOMemo.IOHistory.Lines.add
      ('           find it desirable to improve accuracy by');
  CommandIOMemo.IOHistory.Lines.add
      ('           tracing a larger number of rays.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XFPSF  Disable FPSF.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  AHIST  Display intensity histogram.  Histogram will');
  CommandIOMemo.IOHistory.Lines.add
      ('           be generated by counting rays within equal');
  CommandIOMemo.IOHistory.Lines.add
      ('           area annular rings centerd on the image');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface.');
  CommandIOMemo.IOHistory.Lines.add
      ('  RHIST  Display intensity histogram.  Histogram will');
  CommandIOMemo.IOHistory.Lines.add
      ('           be generated by counting rays within equal');
  CommandIOMemo.IOHistory.Lines.add
      ('           width annular rings centerd on the image');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface.  Results are scaled by the area');
  CommandIOMemo.IOHistory.Lines.add
      ('           of the respective ring within which a');
  CommandIOMemo.IOHistory.Lines.add
      ('           particular ray is counted.');
  CommandIOMemo.IOHistory.Lines.add
      ('  LHIST  Display intensity histogram.  Histogram will');
  CommandIOMemo.IOHistory.Lines.add
      ('           be generated by counting rays within equal');
  CommandIOMemo.IOHistory.Lines.add
      ('           width annular rings centered on the image');
  CommandIOMemo.IOHistory.Lines.add
      ('           surface.  IMPORTANT!!! Ray counts are NOT');
  CommandIOMemo.IOHistory.Lines.add
      ('           scaled by the area of the respective rings.');
  CommandIOMemo.IOHistory.Lines.add
      ('           This function is generally only');
  CommandIOMemo.IOHistory.Lines.add
      ('           appropriate when using a linear fan of rays');
  CommandIOMemo.IOHistory.Lines.add
      ('           or when evaluating the performance of optics');
  CommandIOMemo.IOHistory.Lines.add
      ('           which produce line images.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XHIST  Cancel intensity histogram.');
  CommandIOMemo.IOHistory.Lines.add
      ('  SEED   Provides access to the seeds for the random');
  CommandIOMemo.IOHistory.Lines.add
      ('           number generator used by LADS1.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSequencerOrdinalRange;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('You will be prompted to specify a surface sequencer');
  CommandIOMemo.IOHistory.Lines.add
	('range, within which the individual surfaces will be');
  CommandIOMemo.IOHistory.Lines.add
	('treated as a contiguous group.  This information is');
  CommandIOMemo.IOHistory.Lines.add
	('used for the purpose of drawing lens borders when');
  CommandIOMemo.IOHistory.Lines.add
	('graphical output is displayed.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('Alternatively, enter C to cancel the current group.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSequencerGroupID;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('The sequencer group ID number must be specified');
  CommandIOMemo.IOHistory.Lines.add
      ('before other commands may be activated.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceSequencerCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid responses are:');
  CommandIOMemo.IOHistory.Lines.add
	('  N .. The surface sequencer will process surfaces in');
  CommandIOMemo.IOHistory.Lines.add
	('         ascending order by surface ordinal.');
  CommandIOMemo.IOHistory.Lines.add
	('  R .. The surface sequencer will process surfaces in');
  CommandIOMemo.IOHistory.Lines.add
	('         descending order by surface ordinal.');
  CommandIOMemo.IOHistory.Lines.add
	('  A .. This command causes the surface sequencer to');
  CommandIOMemo.IOHistory.Lines.add
	('         process surfaces in ascending order by surface');
  CommandIOMemo.IOHistory.Lines.add
	('         ordinal, unless recursive ray tracing is also');
  CommandIOMemo.IOHistory.Lines.add
	('         specified.  If auto sequencing and recursive');
  CommandIOMemo.IOHistory.Lines.add
	('         ray tracing are both specified, the first ray');
  CommandIOMemo.IOHistory.Lines.add
	('         will be traced under full recursive searching.');
  CommandIOMemo.IOHistory.Lines.add
	('         The sequence of surfaces yielded by tracing the');
  CommandIOMemo.IOHistory.Lines.add
  	('         initial ray will be stored in the sequencer.');
  CommandIOMemo.IOHistory.Lines.add
	('         This surface sequence will then be used in');
  CommandIOMemo.IOHistory.Lines.add
	('         tracing all remaining rays.');
  CommandIOMemo.IOHistory.Lines.add
	('  G .. The group command allows contiguous blocks of');
  CommandIOMemo.IOHistory.Lines.add
	('         sequence numbers to be specified, for the');
  CommandIOMemo.IOHistory.Lines.add
	('         purpose of drawing lens borders from lens to');
  CommandIOMemo.IOHistory.Lines.add
	('         lens.  When the Draw command is activated,');
  CommandIOMemo.IOHistory.Lines.add
	('         lens borders will be drawn in ascending order');
  CommandIOMemo.IOHistory.Lines.add
	('         by sequence number.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('         IMPORTANT:');
  CommandIOMemo.IOHistory.Lines.add
  	('         Auto sequencing and recursive tracing are both');
  CommandIOMemo.IOHistory.Lines.add
	('         disabled after the first ray has been traced,');
  CommandIOMemo.IOHistory.Lines.add
	('         and the remaining rays will be traced normally');
  CommandIOMemo.IOHistory.Lines.add
	('         (i.e., without recursive searching) according');
  CommandIOMemo.IOHistory.Lines.add
	('         to the "learned" sequence.  At trace');
  CommandIOMemo.IOHistory.Lines.add
	('         completion, the learned sequence is still');
  CommandIOMemo.IOHistory.Lines.add
	('         retained as if it were a user-specified');
  CommandIOMemo.IOHistory.Lines.add
	('         sequence, for use during subsequent trace');
  CommandIOMemo.IOHistory.Lines.add
	('         executions.  If recursive ray tracing is not');
  CommandIOMemo.IOHistory.Lines.add
	('         specified, the Auto command will not be');
  CommandIOMemo.IOHistory.Lines.add
	('         disabled at the conclusion of the trace.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  nn nn  The user may specify any order for surface');
  CommandIOMemo.IOHistory.Lines.add
	('         processing by entering a sequencer slot number,');
  CommandIOMemo.IOHistory.Lines.add
	('         followed immediately by a surface ordinal');
  CommandIOMemo.IOHistory.Lines.add
	('         value.  Surfaces will be processed in the order');
  CommandIOMemo.IOHistory.Lines.add
	('         specified by the user in the surface sequencer.');
  CommandIOMemo.IOHistory.Lines.add
	('         If a surface ordinal value of 0 is entered, the');
  CommandIOMemo.IOHistory.Lines.add
	('         sequencer slot will be treated as if vacant.');
  CommandIOMemo.IOHistory.Lines.add
	('         Discrepancies, such as vacant slots, are');
  CommandIOMemo.IOHistory.Lines.add
	('         removed by LADS1 at the beginning of the ray');
  CommandIOMemo.IOHistory.Lines.add
	('         trace.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpArchiveCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('User specified LADS1 data (i.e., for surfaces, rays,');
  CommandIOMemo.IOHistory.Lines.add
	('etc.) may be save on magnetic media and then retrieved');
  CommandIOMemo.IOHistory.Lines.add
	('at some later time.  This data is handled by LADS1 in');
  CommandIOMemo.IOHistory.Lines.add
	('either of two ways, depending on whether the user wishes');
  CommandIOMemo.IOHistory.Lines.add
	('to store the data permanently or temporarily.  Temporary');
  CommandIOMemo.IOHistory.Lines.add
	('storage is accomplished by LADS1 writing images of');
  CommandIOMemo.IOHistory.Lines.add
	('program memory directly out to an external data file.');
  CommandIOMemo.IOHistory.Lines.add
	('This storage mode is very fast, but the resulting data');
  CommandIOMemo.IOHistory.Lines.add
	('file may be unreadable by future versions of LADS1.');
  CommandIOMemo.IOHistory.Lines.add
  	('On the other hand, to ensure the readability of the');
  CommandIOMemo.IOHistory.Lines.add
	('stored information by future versions of LADS1, the user');
  CommandIOMemo.IOHistory.Lines.add
	('may specify that the programmatic data be stored in a');
  CommandIOMemo.IOHistory.Lines.add
	('permanent fashion.  This will lead to the production of');
  CommandIOMemo.IOHistory.Lines.add
	('a text file, with user-readable commands and data.  This');
  CommandIOMemo.IOHistory.Lines.add
	('type of file requires more computer time to produce.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('Valid archive commands are:');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  TS    Temporary save.  Program memory will be copied');
  CommandIOMemo.IOHistory.Lines.add
	('          to a binary data file, whose name is specified');
  CommandIOMemo.IOHistory.Lines.add
	('          by the user.  The file will be opened,');
  CommandIOMemo.IOHistory.Lines.add
	('          and the requested data type(s) will be copied');
  CommandIOMemo.IOHistory.Lines.add
	('          to the file.  If the file already exists, the');
  CommandIOMemo.IOHistory.Lines.add
	('          the user will be given the option to overwrite');
  CommandIOMemo.IOHistory.Lines.add
	('          the present (i.e., old) contents of the file,');
  CommandIOMemo.IOHistory.Lines.add
	('          or choose a new file name.');
  CommandIOMemo.IOHistory.Lines.add
	('  TL    Temporary load -- re-load specified data type(s)');
  CommandIOMemo.IOHistory.Lines.add
	('          from temporary storage.  The user will be');
  CommandIOMemo.IOHistory.Lines.add
	('          requested to supply a file name.  This program');
  CommandIOMemo.IOHistory.Lines.add
	('          will attempt to open the specified file, and');
  CommandIOMemo.IOHistory.Lines.add
	('          then copy the contents of the file into');
  CommandIOMemo.IOHistory.Lines.add
  	('          program memory.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  PS    Permanent save.  Same as temporary save, except');
  CommandIOMemo.IOHistory.Lines.add
	('          that programmatic commands and data will be');
  CommandIOMemo.IOHistory.Lines.add
	('          saved in user-readable form on a text file.');
  CommandIOMemo.IOHistory.Lines.add
	('          These commands and data are generated by');
  CommandIOMemo.IOHistory.Lines.add
	('          LADS1, and are simply those necessary to');
  CommandIOMemo.IOHistory.Lines.add
	('          rebuild the existing system of surfaces,');
  CommandIOMemo.IOHistory.Lines.add
	('          rays, etc.');
  CommandIOMemo.IOHistory.Lines.add
	('  PL    Permanent load.  User readable commands and data');
  CommandIOMemo.IOHistory.Lines.add
	('          stored within the specified text file will be');
  CommandIOMemo.IOHistory.Lines.add
  	('          interpreted by LADS1');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpArchiveFileName;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('LADS1 will append a type designator to the specified');
  CommandIOMemo.IOHistory.Lines.add
	('file name, depending on whether temporary (".DAT")');
  CommandIOMemo.IOHistory.Lines.add
  	('or permanent (".TXT") storage has been indicated.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpArchiveDataType;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid responses are:');
  CommandIOMemo.IOHistory.Lines.add
	('  S    Surface-related information will be saved or');
  CommandIOMemo.IOHistory.Lines.add
	('         loaded.');
  CommandIOMemo.IOHistory.Lines.add
	('  R    Ray-related information will be saved or');
  CommandIOMemo.IOHistory.Lines.add
	('         loaded.');
  CommandIOMemo.IOHistory.Lines.add
	('  O    Trace option information will be saved or');
  CommandIOMemo.IOHistory.Lines.add
	('         loaded.');
  CommandIOMemo.IOHistory.Lines.add
	('  E    Spatial manipulation environment information will');
  CommandIOMemo.IOHistory.Lines.add
	('         be saved or loaded.');
  CommandIOMemo.IOHistory.Lines.add
	('  A    All information pertaining to surfaces, rays,');
  CommandIOMemo.IOHistory.Lines.add
	('         trace options, and the spatial manipulation');
  CommandIOMemo.IOHistory.Lines.add
  	('         environment will be either saved or loaded.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpEnvironment;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  RO  Rotate - Activates the systemic rotation of a');
  CommandIOMemo.IOHistory.Lines.add
	('        designated range of surfaces or rays about the' +
      ' designated');
  CommandIOMemo.IOHistory.Lines.add
	('        pivot point.  User must first supply rotation');
  CommandIOMemo.IOHistory.Lines.add
	('        data via the commands described below.  If');
  CommandIOMemo.IOHistory.Lines.add
	('        "YPR" has been specified, then rotation is');
  CommandIOMemo.IOHistory.Lines.add
	('        accomplished by first "yawing" (by RHR) about' +
      ' the y');
  CommandIOMemo.IOHistory.Lines.add
	('        axis, then "pitching" (by LHR) about the' +
      ' "yawed" x axis,');
  CommandIOMemo.IOHistory.Lines.add
  	('        and then "rolling" (by RHR) about the "yawed"' +
      ' and');
  CommandIOMemo.IOHistory.Lines.add
	('        "pitched" z axis.  The specified yaw, pitch,');
  CommandIOMemo.IOHistory.Lines.add
	('        and roll will be applied as an increment to the');
  CommandIOMemo.IOHistory.Lines.add
	('        present orientation of each surface and ray in' +
      ' the');
  CommandIOMemo.IOHistory.Lines.add
	('        specified ranges of surfaces and rays.  If' +
      ' "EULER" has been');
  CommandIOMemo.IOHistory.Lines.add
	('        specified, then the systemic rotation will');
  CommandIOMemo.IOHistory.Lines.add
	('        occur about an arbitrary Euler axis specified' +
      ' by the');
  CommandIOMemo.IOHistory.Lines.add
	('        user.  The magnitude of the rotation is');
  CommandIOMemo.IOHistory.Lines.add
	('        specified by the user in terms of an angle of');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation about the arbitrary Euler axis.  For' +
      ' any ');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation, the specified ranges of surfaces and' +
      ' rays are');
  CommandIOMemo.IOHistory.Lines.add
	('        always rotated about a specified pivot point.');
  CommandIOMemo.IOHistory.Lines.add
	('        Thus, the position of each surface or ray,');
  CommandIOMemo.IOHistory.Lines.add
	('        as well as the orientation, will be');
  CommandIOMemo.IOHistory.Lines.add
	('        modified as the RO(tate command is activated.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  TR  Translate -- each surface or ray in the' +
      ' specified ranges');
  CommandIOMemo.IOHistory.Lines.add
	('        will be translated from its present location by');
  CommandIOMemo.IOHistory.Lines.add
  	('        amounts equal to DX, DY, and DZ.  IMPORTANT!! A');
  CommandIOMemo.IOHistory.Lines.add
	('        coordinate rotation transformation is always');
  CommandIOMemo.IOHistory.Lines.add
	('        applied to the specified displacement values');
  CommandIOMemo.IOHistory.Lines.add
	('        DX, DY, and DZ before the actual translation is');
  CommandIOMemo.IOHistory.Lines.add
	('        performed.  The rotation transformation is');
  CommandIOMemo.IOHistory.Lines.add
	('        based on the current values specified for ROLL,');
  CommandIOMemo.IOHistory.Lines.add
	('        PITCH, and YAW.  All surfaces and rays within');
  CommandIOMemo.IOHistory.Lines.add
	('        the specified ranges retain their original');
  CommandIOMemo.IOHistory.Lines.add
	('        relative positions and orientations.');
  CommandIOMemo.IOHistory.Lines.add
	('  TH  Adjust thickness -- This command is identical in');
  CommandIOMemo.IOHistory.Lines.add
	('        operation to the TRanslate command, except the');
  CommandIOMemo.IOHistory.Lines.add
	('        specified ranges of surfaces and rays are' +
      ' first translated');
  CommandIOMemo.IOHistory.Lines.add
	('        such that the vertex of the first surface in');
  CommandIOMemo.IOHistory.Lines.add
	('        the surface range, and/or the head of the' +
      ' first');
  CommandIOMemo.IOHistory.Lines.add
	('        ray in the ray range, is made to coincide' +
      ' with the');
  CommandIOMemo.IOHistory.Lines.add
	('        specified reference point.  (The reference');
  CommandIOMemo.IOHistory.Lines.add
	('        point is typically the vertex position of a');
  CommandIOMemo.IOHistory.Lines.add
	('        REFerence surface).  The overall effect is to');
  CommandIOMemo.IOHistory.Lines.add
	('        establish a specified separation (i.e.,');
  CommandIOMemo.IOHistory.Lines.add
	('        "thickness") from the reference point to the');
  CommandIOMemo.IOHistory.Lines.add
	('        first surface in the surface range, and/or the');
  CommandIOMemo.IOHistory.Lines.add
	('        first ray in the ray range.  This separation');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('        will be equal to SQRT (DX^2 + DY^2 + DZ^2).');
  CommandIOMemo.IOHistory.Lines.add
	('  FACTOR  This command will initiate a prompt for');
  CommandIOMemo.IOHistory.Lines.add
	('        entry of a geometric scale factor.  This scale');
  CommandIOMemo.IOHistory.Lines.add
	('        factor may be applied to surfaces and/or rays,');
  CommandIOMemo.IOHistory.Lines.add
	('        per the current surface-range and ray-range');
  CommandIOMemo.IOHistory.Lines.add
	('        settings.  The scale factor will cause an');
  CommandIOMemo.IOHistory.Lines.add
	('        increase or decrease in the value of all');
  CommandIOMemo.IOHistory.Lines.add
	('        geometric parameters associated with each');
  CommandIOMemo.IOHistory.Lines.add
	('        specified surface or ray.  For position');
  CommandIOMemo.IOHistory.Lines.add
	('        parameters, the scale factor will be applied');
  CommandIOMemo.IOHistory.Lines.add
	('        with respect to the current (x,y,z) pivot');
  CommandIOMemo.IOHistory.Lines.add
	('        point coordinates.  For example, in the');
  CommandIOMemo.IOHistory.Lines.add
	('        process of scaling a lens surface, a vector will');
  CommandIOMemo.IOHistory.Lines.add
	('        be formed, with the tail at the pivot point,');
  CommandIOMemo.IOHistory.Lines.add
	('        and the head at the location of the surface');
  CommandIOMemo.IOHistory.Lines.add
	('        vertex.  A scale factor of 1.2 will thus cause');
  CommandIOMemo.IOHistory.Lines.add
	('        the distance from the pivot point to the');
  CommandIOMemo.IOHistory.Lines.add
	('        surface vertex to increase by 20%, in a');
  CommandIOMemo.IOHistory.Lines.add
  	('        direction along the previously defined vector.');
  CommandIOMemo.IOHistory.Lines.add
	('        A scale factor of 1 implies no change.  Scale');
  CommandIOMemo.IOHistory.Lines.add
	('        factors of zero (or less) are not valid.');
  CommandIOMemo.IOHistory.Lines.add
	('  SC  Adjust scale of all surfaces and/or rays in the');
  CommandIOMemo.IOHistory.Lines.add
	('        current ranges, per the current scale factor.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  SBLOK  User will be asked to designate a range of');
  CommandIOMemo.IOHistory.Lines.add
	('        surfaces which are to participate in a systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation or translation.');
  CommandIOMemo.IOHistory.Lines.add
	('  NS   Deactivates surface range.');
  CommandIOMemo.IOHistory.Lines.add
	('  RBLOK  User will be asked to designate a range of');
  CommandIOMemo.IOHistory.Lines.add
  	('        rays which are to participate in a systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation or translation.');
  CommandIOMemo.IOHistory.Lines.add
	('  NR   Deactivates ray range.');
  CommandIOMemo.IOHistory.Lines.add
	('  REF  User will be asked to designate a surface which');
  CommandIOMemo.IOHistory.Lines.add
	('        will act as a reference surface.  This command');
  CommandIOMemo.IOHistory.Lines.add
	('        is important in relation to the systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        translation commands TR and TH, and the ROtate');
  CommandIOMemo.IOHistory.Lines.add
	('        command.  For these commands, the position');
  CommandIOMemo.IOHistory.Lines.add
	('        and orientation of the reference surface can be');
  CommandIOMemo.IOHistory.Lines.add
	('        picked up by means of the various "*" commands.');
  CommandIOMemo.IOHistory.Lines.add
	('        IMPORTANT!!  The reference surface is');
  CommandIOMemo.IOHistory.Lines.add
	('        automatically set to the first surface in the');
  CommandIOMemo.IOHistory.Lines.add
	('        specified range whenever the SR command is');
  CommandIOMemo.IOHistory.Lines.add
	('        used.  If the reference surface should be a');
  CommandIOMemo.IOHistory.Lines.add
	('        surface other than the first surface in the');
  CommandIOMemo.IOHistory.Lines.add
	('        range, then the REF command should be used');
  CommandIOMemo.IOHistory.Lines.add
	('        AFTER the SR command.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  YPR  This command causes the program to make use of');
  CommandIOMemo.IOHistory.Lines.add
	('        yaw, pitch, and roll data, as opposed to Euler');
  CommandIOMemo.IOHistory.Lines.add
	('        axis data, when the RO(tate command is');
  CommandIOMemo.IOHistory.Lines.add
	('        activated.');
  CommandIOMemo.IOHistory.Lines.add
	('  EULER  This command causes the program to utilize');
  CommandIOMemo.IOHistory.Lines.add
	('        Euler axis data, as opposed to yaw, pitch, and');
  CommandIOMemo.IOHistory.Lines.add
	('        roll, when the RO(tate command is activated.');
  CommandIOMemo.IOHistory.Lines.add
	('        In some cases, it may be more convenient to');
  CommandIOMemo.IOHistory.Lines.add
	('        specify rotation about an arbitrary Euler' +
      ' axis, as');
  CommandIOMemo.IOHistory.Lines.add
	('        opposed to specifying rotation via yaw, pitch,');
  CommandIOMemo.IOHistory.Lines.add
	('        and roll parameters.');
  CommandIOMemo.IOHistory.Lines.add
	('  SYSTEM  Rotation values, as specified for the systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation, are with respect to the system');
  CommandIOMemo.IOHistory.Lines.add
	('        coordinates (master reference coordinates).');
  CommandIOMemo.IOHistory.Lines.add
	('  LOCAL  If the vertex position of the first surface in');
  CommandIOMemo.IOHistory.Lines.add
	('        the specified range is identical to the');
  CommandIOMemo.IOHistory.Lines.add
	('        specified pivot point, then the rotation values,');
  CommandIOMemo.IOHistory.Lines.add
	('        as specified for the systemic rotation, are with');
  CommandIOMemo.IOHistory.Lines.add
	('        respect to the present (local) orientation of');
  CommandIOMemo.IOHistory.Lines.add
	('        the first surface in the range.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  REFL  Pivot surface (first surface in range) will');
  CommandIOMemo.IOHistory.Lines.add
	('        rotate as a reflector during the systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation.  This means that the pivot surface');
  CommandIOMemo.IOHistory.Lines.add
	('        will experience only half the rotation');
  CommandIOMemo.IOHistory.Lines.add
	('        experienced by the other members of the range.');
  CommandIOMemo.IOHistory.Lines.add
	('        Any rays specified to be included in the' +
      ' systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        rotation experience the full rotation.');
  CommandIOMemo.IOHistory.Lines.add
	('  NULL  This command causes the pivot surface to not');
  CommandIOMemo.IOHistory.Lines.add
	('        participate in the systemic rotation which has');
  CommandIOMemo.IOHistory.Lines.add
	('        been specified for the range.  Any rays' +
      ' specified to be');
  CommandIOMemo.IOHistory.Lines.add
	('        included in the systemic rotation experience' +
      ' the full rotation.');
  CommandIOMemo.IOHistory.Lines.add
	('  FULL  This command causes the pivot surface to');
  CommandIOMemo.IOHistory.Lines.add
	('        participate in full with the systemic rotation');
  CommandIOMemo.IOHistory.Lines.add
	('        specified for the range.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  PERM  All systemic translation and rotation revisions');
  CommandIOMemo.IOHistory.Lines.add
	('        will be saved as permanent data.');
  CommandIOMemo.IOHistory.Lines.add
	('  TEMP  Systemic translation and rotation revisions will');
  CommandIOMemo.IOHistory.Lines.add
	('        be saved as temporary incremental ("delta")');
  CommandIOMemo.IOHistory.Lines.add
	('        data.  Revisions generated while this condition');
  CommandIOMemo.IOHistory.Lines.add
	('        is set, may be easily cleared via ZERO or INC.');
  CommandIOMemo.IOHistory.Lines.add
	('        This command is intended to provide the user');
  CommandIOMemo.IOHistory.Lines.add
	('        with the capability to introduce temporary');
  CommandIOMemo.IOHistory.Lines.add
	('        tilts about an arbitrary axis, so that the');
  CommandIOMemo.IOHistory.Lines.add
	('        effects on system performance may be observed.');
  CommandIOMemo.IOHistory.Lines.add
	('        Typically, the roll, pitch, and yaw are');
  CommandIOMemo.IOHistory.Lines.add
	('        specified about an arbitrary point in space');
  CommandIOMemo.IOHistory.Lines.add
	('        (usually not connected with any optical');
  CommandIOMemo.IOHistory.Lines.add
	('        surface).  By specifying the range of surfaces');
  CommandIOMemo.IOHistory.Lines.add
	('        to participate in the systemic rotation, the');
  CommandIOMemo.IOHistory.Lines.add
	('        user is able to conveniently test the effect of');
  CommandIOMemo.IOHistory.Lines.add
	('        mechanical perturbations, about the most likely');
  CommandIOMemo.IOHistory.Lines.add
	('        mechanical flexture points.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  YAW  This command is followed by yaw value in degrees.');
  CommandIOMemo.IOHistory.Lines.add
	('        Yaw is specified as a right-hand-rule rotation');
  CommandIOMemo.IOHistory.Lines.add
	('        about the y-axis.');
  CommandIOMemo.IOHistory.Lines.add
	('  PITCH  Data entry command for pitch.  Pitch is defined');
  CommandIOMemo.IOHistory.Lines.add
	('        as a left-hand-rule rotation about the "yawed"');
  CommandIOMemo.IOHistory.Lines.add
	('        x-axis.');
  CommandIOMemo.IOHistory.Lines.add
	('  ROLL  Data entry command for roll.  Roll is defined as');
  CommandIOMemo.IOHistory.Lines.add
	('        a right-hand-rule rotation about the "yawed" and');
  CommandIOMemo.IOHistory.Lines.add
	('        "pitched" z-axis.');
  CommandIOMemo.IOHistory.Lines.add
	('  EX  X-component of the Euler axis vector.');
  CommandIOMemo.IOHistory.Lines.add
	('  EY  Y-component of the Euler axis vector.');
  CommandIOMemo.IOHistory.Lines.add
  	('  EZ  Z-component of the Euler axis vector.');
  CommandIOMemo.IOHistory.Lines.add
	('        It is not necessary that the x, y, and z');
  CommandIOMemo.IOHistory.Lines.add
	('        components of the vector representing the Euler');
  CommandIOMemo.IOHistory.Lines.add
	('        axis be the components of a unit vector.  This');
  CommandIOMemo.IOHistory.Lines.add
	('        program will convert the user input values into');
  CommandIOMemo.IOHistory.Lines.add
	('        a unit vector when internal computations are');
  CommandIOMemo.IOHistory.Lines.add
	('        performed.');
  CommandIOMemo.IOHistory.Lines.add
	('  ER  Magnitude of the rotation about the Euler axis, in');
  CommandIOMemo.IOHistory.Lines.add
	('        degrees.  ER is a signed quantity.  Positive');
  CommandIOMemo.IOHistory.Lines.add
	('        values indicate a right-hand-rule rotation about');
  CommandIOMemo.IOHistory.Lines.add
	('        the Euler axis vector.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  *   This command causes the reference or pivot point');
  CommandIOMemo.IOHistory.Lines.add
	('        location X, Y, and Z to be obtained from the');
  CommandIOMemo.IOHistory.Lines.add
	('        vertex position of the REFerence surface. In');
  CommandIOMemo.IOHistory.Lines.add
	('        addition, ROLL, PITCH, and YAW data will be');
  CommandIOMemo.IOHistory.Lines.add
	('        obtained from the roll, pitch, and yaw data for');
  CommandIOMemo.IOHistory.Lines.add
	('        the REFerence surface.');
  CommandIOMemo.IOHistory.Lines.add
	('  *P  This command causes only the reference or pivot');
  CommandIOMemo.IOHistory.Lines.add
	('        point location X, Y, and Z to be obtained from');
  CommandIOMemo.IOHistory.Lines.add
	('        the vertex position of the REFerence surface.');
  CommandIOMemo.IOHistory.Lines.add
	('  *O  This command causes only the ROLL, PITCH, and YAW');
  CommandIOMemo.IOHistory.Lines.add
	('        values to be obtained from the vertex position');
  CommandIOMemo.IOHistory.Lines.add
	('        of the REFerence surface.');
  CommandIOMemo.IOHistory.Lines.add
	('  *-  This command causes negative values for ROLL,');
  CommandIOMemo.IOHistory.Lines.add
	('        PITCH, and YAW to be obtained from the');
  CommandIOMemo.IOHistory.Lines.add
	('        present orientation of the REFerence surface.');
  CommandIOMemo.IOHistory.Lines.add
	('  X   X-coordinate of reference or pivot point for a');
  CommandIOMemo.IOHistory.Lines.add
	('        systemic translation or rotation.');
  CommandIOMemo.IOHistory.Lines.add
	('  Y   Y-coordinate of reference or pivot point for a');
  CommandIOMemo.IOHistory.Lines.add
	('        systemic translation or rotation.');
  CommandIOMemo.IOHistory.Lines.add
	('  Z   Z-coordinate of reference or pivot point for a');
  CommandIOMemo.IOHistory.Lines.add
  	('        systemic translation or rotation.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('        The reference/pivot point for systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        translations and rotations is specified by');
  CommandIOMemo.IOHistory.Lines.add
	('        means of [x,y,z] coordinates.  For systemic');
  CommandIOMemo.IOHistory.Lines.add
	('        rotations, these coordinates represent an');
  CommandIOMemo.IOHistory.Lines.add
	('        arbitrary pivot point in the master coordinate');
  CommandIOMemo.IOHistory.Lines.add
	('        system, about which the rotation will occur.');
  CommandIOMemo.IOHistory.Lines.add
	('        For a THickness adjustment, these coordinates');
  CommandIOMemo.IOHistory.Lines.add
	('        represent an arbitrary reference point in the');
  CommandIOMemo.IOHistory.Lines.add
	('        master coordinate system, to which the range of');
  CommandIOMemo.IOHistory.Lines.add
  	('        surfaces or rays will be initially translated' +
      ' before');
  CommandIOMemo.IOHistory.Lines.add
	('        the specified displacements DX, DY, and DZ are');
  CommandIOMemo.IOHistory.Lines.add
	('        applied.  The reference/pivot point need not');
  CommandIOMemo.IOHistory.Lines.add
	('        coincide with the position of an optical');
  CommandIOMemo.IOHistory.Lines.add
	('        surface.  If it does, the [x,y,z] coordinate');
  CommandIOMemo.IOHistory.Lines.add
	('        data may be automatically obtained from the');
  CommandIOMemo.IOHistory.Lines.add
	('        vertex position of the REFerence surface by');
  CommandIOMemo.IOHistory.Lines.add
	('        means of the "*" commands.  Systemic rotation');
  CommandIOMemo.IOHistory.Lines.add
	('        about an axis passing through an arbitrary');
  CommandIOMemo.IOHistory.Lines.add
	('        pivot point might be used to analyse the effect');
  CommandIOMemo.IOHistory.Lines.add
  	('        on the optical performance of a system which');
  CommandIOMemo.IOHistory.Lines.add
	('        will experience some slight mechanical flexure.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  DX  Data entry command for thickness or incremental');
  CommandIOMemo.IOHistory.Lines.add
	('        translation, in the x direction.');
  CommandIOMemo.IOHistory.Lines.add
	('  DY  Data entry command for thickness or incremental');
  CommandIOMemo.IOHistory.Lines.add
	('        translation, in the y direction.');
  CommandIOMemo.IOHistory.Lines.add
	('  DZ  Data entry command for thickness or incremental');
  CommandIOMemo.IOHistory.Lines.add
	('        translation, in the z direction.');
  CommandIOMemo.IOHistory.Lines.add
      ('  AIM This command activates automated ray aiming, for');
  CommandIOMemo.IOHistory.Lines.add
      ('        the block of rays specified by RBLOK.  Each');
  CommandIOMemo.IOHistory.Lines.add
      ('        principal ray in the block will be aimed at');
  CommandIOMemo.IOHistory.Lines.add
      ('        the center of the surface specified by REF.');
  CommandIOMemo.IOHistory.Lines.add
      ('        The position of the head of each light ray is');
  CommandIOMemo.IOHistory.Lines.add
      ('        modified in such a manner that the ray will');
  CommandIOMemo.IOHistory.Lines.add
      ('        intersect the center of the specified REF');
  CommandIOMemo.IOHistory.Lines.add
      ('        surface.  "Buried" pupils or apertures are');
  CommandIOMemo.IOHistory.Lines.add
      ('        accomdodated, because full-blown sequential');
  CommandIOMemo.IOHistory.Lines.add
      ('        or non-sequential tracing is utilized in the');
  CommandIOMemo.IOHistory.Lines.add
      ('        aiming procedure.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  ZERO  This command causes all temporary-type');
  CommandIOMemo.IOHistory.Lines.add
  	('        position and orientation data for the designated');
  CommandIOMemo.IOHistory.Lines.add
	('        surfaces to be zeroed, without incorporating the');
  CommandIOMemo.IOHistory.Lines.add
	('        values.  This command is useful when used in');
  CommandIOMemo.IOHistory.Lines.add
	('        conjunction with temporary position/orientation');
  CommandIOMemo.IOHistory.Lines.add
	('        changes introduced, for example, in the');
  CommandIOMemo.IOHistory.Lines.add
	('        tolerancing process.');
  CommandIOMemo.IOHistory.Lines.add
	('  INC  This command is used when it is desirable to');
  CommandIOMemo.IOHistory.Lines.add
	('        incorporate temporary position/orientation');
  CommandIOMemo.IOHistory.Lines.add
	('        changes, as permanent data.');
  CommandIOMemo.IOHistory.Lines.add
	('  CLR  This command initializes the Environment');
  CommandIOMemo.IOHistory.Lines.add
	('        variables to their default values.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpGlassCatalogCommand;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid glass catalog commands are:');
  CommandIOMemo.IOHistory.Lines.add
	('  L .. List glass catalog data for specified glass.');
  CommandIOMemo.IOHistory.Lines.add
	('  I .. Compute and display refractive index for');
  CommandIOMemo.IOHistory.Lines.add
	('         specified glass and wavelength.');
  CommandIOMemo.IOHistory.Lines.add
      ('  S .. Setup alias for gradient index (GRIN) material.');
  CommandIOMemo.IOHistory.Lines.add
      ('         This command allows you to enter a position' +
      ' and orientation');
  CommandIOMemo.IOHistory.Lines.add
      ('         for the bulk GRIN material.  The same GRIN' +
      ' material may be');
  CommandIOMemo.IOHistory.Lines.add
      ('         used more than once, as long as each alias' +
      ' is unique.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('NOTE:  additions, deletions, or revisions to the');
  CommandIOMemo.IOHistory.Lines.add
      ('glass catalog may be made with your operating system');
  CommandIOMemo.IOHistory.Lines.add
      ('text file editor.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('NOTE:  additions, deletions, or revisions to the');
  CommandIOMemo.IOHistory.Lines.add
	('glass catalog may be made with your operating system');
  CommandIOMemo.IOHistory.Lines.add
  	('text file editor.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceRevisionCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid surface revision codes are:');
  CommandIOMemo.IOHistory.Lines.add
	('  RA  Radius of curvature.');
  CommandIOMemo.IOHistory.Lines.add
	('  N1  Refractive index on one side of optical interface.');
  CommandIOMemo.IOHistory.Lines.add
	('  N2  Refractive index on other side of optical');
  CommandIOMemo.IOHistory.Lines.add
	('        interface.');
  CommandIOMemo.IOHistory.Lines.add
	('  OD  Outside diameter of circular clear aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('  ID  Inside diameter of circular clear aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('        Default is zero.');
  CommandIOMemo.IOHistory.Lines.add
	('  OX  Outside width of clear aperture, parallel to the');
  CommandIOMemo.IOHistory.Lines.add
  	('        x axis, for a square or elliptical aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('        Default is zero.');
  CommandIOMemo.IOHistory.Lines.add
	('  OY  Outside width of clear aperture, parallel to the');
  CommandIOMemo.IOHistory.Lines.add
	('        y axis, for a square or elliptical aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('        Default is zero.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  IX  Inside width of clear aperture, parallel to the');
  CommandIOMemo.IOHistory.Lines.add
	('        x axis, for a square or elliptical aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('        Default is zero.');
  CommandIOMemo.IOHistory.Lines.add
	('  IY  Inside width of clear aperture, parallel to the');
  CommandIOMemo.IOHistory.Lines.add
	('        y axis, for a square or elliptical aperture.');
  CommandIOMemo.IOHistory.Lines.add
  	('        Default is zero.');
  CommandIOMemo.IOHistory.Lines.add
	('  AX  X-coordinate of clear aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('  AY  Y-coordinate of clear aperture.');
  CommandIOMemo.IOHistory.Lines.add
	('  CO  Outside edge of clear aperture is circular.');
  CommandIOMemo.IOHistory.Lines.add
	('        (This is the default.)');
  CommandIOMemo.IOHistory.Lines.add
	('  CI  Inside edge of clear aperture is circular.');
  CommandIOMemo.IOHistory.Lines.add
	('  QO  Outside edge of clear aperture is square.');
  CommandIOMemo.IOHistory.Lines.add
	('  QI  Inside edge of clear aperture is square.');
  CommandIOMemo.IOHistory.Lines.add
	('  EO  Outside edge of clear aperture is elliptical.');
  CommandIOMemo.IOHistory.Lines.add
	('  EI  Inside edge of clear aperture is elliptical.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
  	('  CC  Conic constant (default is zero).');
  CommandIOMemo.IOHistory.Lines.add
	('  CP  Toggle switch.  This switch activates/deactivates');
  CommandIOMemo.IOHistory.Lines.add
	('        treatment of the surface as a theta-in/theta-');
  CommandIOMemo.IOHistory.Lines.add
	('        out type non-imaging compound parabolic');
  CommandIOMemo.IOHistory.Lines.add
	('        concentrator.  When this switch is activated,');
  CommandIOMemo.IOHistory.Lines.add
	('        the user will be requested to enter 4 critical');
  CommandIOMemo.IOHistory.Lines.add
	('        design parameters which specify the shape of');
  CommandIOMemo.IOHistory.Lines.add
	('        the CPC.');
  CommandIOMemo.IOHistory.Lines.add
	('  DE  Toggle switch.  This switch activates/deactivates');
  CommandIOMemo.IOHistory.Lines.add
	('        utilization of deformation constants in');
  CommandIOMemo.IOHistory.Lines.add
	('        computation of sag via the aspheric sag');
  CommandIOMemo.IOHistory.Lines.add
	('        equation.');
  CommandIOMemo.IOHistory.Lines.add
	('  nn  This command provides the means to access and');
  CommandIOMemo.IOHistory.Lines.add
	('        modify the coefficients associated with the');
  CommandIOMemo.IOHistory.Lines.add
	('        high order aspheric terms in the aspheric sag');
  CommandIOMemo.IOHistory.Lines.add
	('        equation.  A total of ' +
        IntToStr (CZAI_MAX_DEFORM_CONSTANTS) +
      ' aspheric terms are');
  CommandIOMemo.IOHistory.Lines.add
	('        defined, with the coefficients being accessed by');
  CommandIOMemo.IOHistory.Lines.add
	('        entering a number in the range 1 thru ' +
      IntToStr (CZAI_MAX_DEFORM_CONSTANTS) + '.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  TE  This toggle switch causes the present surface to');
  CommandIOMemo.IOHistory.Lines.add
  	('        be treated as a ray termination surface (i.e.,');
  CommandIOMemo.IOHistory.Lines.add
	('        a perfect absorber).  Default is "off."');
  CommandIOMemo.IOHistory.Lines.add
	('  BE  This toggle switch causes the present surface to');
  CommandIOMemo.IOHistory.Lines.add
	('        be treated as a beamsplitter.  Default is "off."');
  CommandIOMemo.IOHistory.Lines.add
	('        The refracted ray component is traced first.');
  CommandIOMemo.IOHistory.Lines.add
	('        A maximum of ' + IntToStr (MaxBeamsplitRays) +
        ' reflected components can be');
  CommandIOMemo.IOHistory.Lines.add
	('        held in temporary program storage.');
  CommandIOMemo.IOHistory.Lines.add
	('  RE  User will be prompted to enter a reflectivity');
  CommandIOMemo.IOHistory.Lines.add
	('        value for the present surface.');
  CommandIOMemo.IOHistory.Lines.add
	('  M   This switch toggles the status of the present');
  CommandIOMemo.IOHistory.Lines.add
  	('        surface between transmissive and reflective.');
  CommandIOMemo.IOHistory.Lines.add
	('        (Default is transmissive.)');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  SC  This toggle switch causes the present surface to');
  CommandIOMemo.IOHistory.Lines.add
	('        be treated as a scatterer, with a Gaussian');
  CommandIOMemo.IOHistory.Lines.add
	('        scattering distribution centered about the');
  CommandIOMemo.IOHistory.Lines.add
	('        unscattered reflected or refracted ray.');
  CommandIOMemo.IOHistory.Lines.add
	('  SI  User will be prompted to enter the standard');
  CommandIOMemo.IOHistory.Lines.add
	('        deviation, in degrees, for a Gaussian scattering');
  CommandIOMemo.IOHistory.Lines.add
	('        distribution.');
  CommandIOMemo.IOHistory.Lines.add
	('  CY  Spherical/Cylindrical surface-type toggle switch.');
  CommandIOMemo.IOHistory.Lines.add
  	('        (Default is spherical.)');
  CommandIOMemo.IOHistory.Lines.add
	('  O   OPD reference surface indicator toggle switch.');
  CommandIOMemo.IOHistory.Lines.add
	('        (Default is "off," i.e., not a ref. surface.)');
  CommandIOMemo.IOHistory.Lines.add
	('  X   X-coordinate of present surface vertex (default');
  CommandIOMemo.IOHistory.Lines.add
	('        is zero).');
  CommandIOMemo.IOHistory.Lines.add
	('  DX  Incremental adjustment to vertex x-coordinate');
  CommandIOMemo.IOHistory.Lines.add
	('        of present surface (default is zero).  May be');
  CommandIOMemo.IOHistory.Lines.add
	('        canceled by entering zero.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  Y   Y-coordinate of present surface vertex (default');
  CommandIOMemo.IOHistory.Lines.add
	('        is zero).');
  CommandIOMemo.IOHistory.Lines.add
  	('  DY  Incremental adjustment to vertex y-coordinate');
  CommandIOMemo.IOHistory.Lines.add
	('        of present surface (default is zero).  May be');
  CommandIOMemo.IOHistory.Lines.add
	('        canceled by entering zero.');
  CommandIOMemo.IOHistory.Lines.add
	('  Z   Z-coordinate of present surface vertex (default');
  CommandIOMemo.IOHistory.Lines.add
	('        is zero).');
  CommandIOMemo.IOHistory.Lines.add
	('  DZ  Incremental adjustment to vertex z-coordinate');
  CommandIOMemo.IOHistory.Lines.add
	('        of present surface (default is zero).  May be');
  CommandIOMemo.IOHistory.Lines.add
	('        canceled by entering zero.');
  CommandIOMemo.IOHistory.Lines.add
	('  YA  Yaw of present surface vertex normal vector about');
  CommandIOMemo.IOHistory.Lines.add
	('        reference system y-axis (default is zero).');
  CommandIOMemo.IOHistory.Lines.add
	('  DA  Incremental adjustment to yaw of present surface');
  CommandIOMemo.IOHistory.Lines.add
	('        (default is zero).  Enter zero to cancel.');
  CommandIOMemo.IOHistory.Lines.add
	('  P   Pitch of present surface vertex normal vector');
  CommandIOMemo.IOHistory.Lines.add
	('        about "yawed" surface x-axis (default is zero).');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  DP  Incremental adjustment to pitch of present surface');
  CommandIOMemo.IOHistory.Lines.add
	('        (default is zero).  Enter zero to cancel.');
  CommandIOMemo.IOHistory.Lines.add
	('  R   Roll of present surface about "yawed", "pitched"');
  CommandIOMemo.IOHistory.Lines.add
	('        surface vertex normal vector (surface z-axis).');
  CommandIOMemo.IOHistory.Lines.add
	('        (Default is zero.)');
  CommandIOMemo.IOHistory.Lines.add
	('  DR  Incremental adjustment to roll of present surface');
  CommandIOMemo.IOHistory.Lines.add
	('        (default is zero).  Enter zero to cancel.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('  AS  Surface array indicator toggle switch.');
  CommandIOMemo.IOHistory.Lines.add
	('        (Default is "off," i.e., not a surface array.)');
  CommandIOMemo.IOHistory.Lines.add
	('  XR  Surface array X dimension, i.e, number of repetitions.');
  CommandIOMemo.IOHistory.Lines.add
	('  YR  Surface array Y dimension, i.e, number of repetitions.');
  CommandIOMemo.IOHistory.Lines.add
	('  XS  Surface array center-to-center X spacing.');
  CommandIOMemo.IOHistory.Lines.add
	('  YS  Surface array center-to-center Y spacing.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRadiusOfCurvature;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('A valid radius is any number greater than or equal to');
  CommandIOMemo.IOHistory.Lines.add
	('zero.  A value of zero for the radius of curvature');
  CommandIOMemo.IOHistory.Lines.add
	('indicates a flat surface.  Values less than zero are');
  CommandIOMemo.IOHistory.Lines.add
	('not permitted.  The orientation of the surface is');
  CommandIOMemo.IOHistory.Lines.add
	('specified in terms of roll, pitch, and yaw, which must');
  CommandIOMemo.IOHistory.Lines.add
  	('be entered separately.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpIndexOfRefraction;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid input consists of a number greater than or equal');
  CommandIOMemo.IOHistory.Lines.add
	('to 1.0, or a glass name.  If a glass name is');
  CommandIOMemo.IOHistory.Lines.add
	('entered, LADS1 will immediately attempt to');
  CommandIOMemo.IOHistory.Lines.add
	('verify that the glass name is found in the glass');
  CommandIOMemo.IOHistory.Lines.add
	('catalog.  If not found, a warning message will be');
  CommandIOMemo.IOHistory.Lines.add
	('posted to that effect, and an opportunity will be');
  CommandIOMemo.IOHistory.Lines.add
	('presented to enter another glass name.  Please note that');
  CommandIOMemo.IOHistory.Lines.add
	(CKAC_GET_INDEX_1 + ' should represent the ' +
      'incident medium');
  CommandIOMemo.IOHistory.Lines.add
	('refractive index, and that ' + CKAE_GET_INDEX_2 + ' is ' +
      'intended to');
  CommandIOMemo.IOHistory.Lines.add
	('represent the exit medium index.  However, this rule');
  CommandIOMemo.IOHistory.Lines.add
	('is only rigidly enforced for glass type optimization.');
  CommandIOMemo.IOHistory.Lines.add
      ('GRIN media must be referenced indirectly, via an alias.');
  CommandIOMemo.IOHistory.Lines.add
      ('(See the G(lass command.)');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpInsideAndOutsideApertures;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('A clear aperture for a surface consists of the active');
  CommandIOMemo.IOHistory.Lines.add
   ('area of the surface as contained between the outside');
  CommandIOMemo.IOHistory.Lines.add
   ('perimeter and the inside perimeter.  An inside');
  CommandIOMemo.IOHistory.Lines.add
   ('perimeter, with dimensions larger than zero, implies a');
  CommandIOMemo.IOHistory.Lines.add
   ('central hole.  A light ray which intersects a surface');
  CommandIOMemo.IOHistory.Lines.add
   ('beyond the outside perimeter, or within the inside');
  CommandIOMemo.IOHistory.Lines.add
   ('perimeter, will generate a trace-time error message,');
  CommandIOMemo.IOHistory.Lines.add
   ('unless the "eroff" T(race option has been selected,');
  CommandIOMemo.IOHistory.Lines.add
   ('or unless recursive tracing has been selected.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('Any combination of circular, elliptical, or rectangular');
  CommandIOMemo.IOHistory.Lines.add
   ('inside and outside perimeters may be selected.  Trace');
  CommandIOMemo.IOHistory.Lines.add
   ('time checking is performed to ensure that the inside');
  CommandIOMemo.IOHistory.Lines.add
   ('perimeter is smaller at all points than the outside');
  CommandIOMemo.IOHistory.Lines.add
   ('perimeter.  Trace-time checking is also performed to');
  CommandIOMemo.IOHistory.Lines.add
   ('ensure that the perimeter dimensions are physically');
  CommandIOMemo.IOHistory.Lines.add
   ('possible, with respect to the surface radius of');
  CommandIOMemo.IOHistory.Lines.add
   ('curvature.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('It is possible to specify a perimeter offset, such');
  CommandIOMemo.IOHistory.Lines.add
   ('that the outside and inside perimeters are shifted');
  CommandIOMemo.IOHistory.Lines.add
   ('away from the origin of the local coordinate system');
  CommandIOMemo.IOHistory.Lines.add
   ('attached to the surface vertex.  (At this time, it is');
  CommandIOMemo.IOHistory.Lines.add
   ('not possible to specify separate offsets for the');
  CommandIOMemo.IOHistory.Lines.add
   ('inside and outside perimeters.)  One should note that');
  CommandIOMemo.IOHistory.Lines.add
   ('somewhat strange, perhaps unanticipated, results may');
  CommandIOMemo.IOHistory.Lines.add
   ('result from decentering an aperture on a strongly');
  CommandIOMemo.IOHistory.Lines.add
   ('curved surface.  For example, if one decenters a');
  CommandIOMemo.IOHistory.Lines.add
   ('circular perimeter on a strongly curved surface, the');
  CommandIOMemo.IOHistory.Lines.add
   ('projection of the circular perimeter onto the surface');
  CommandIOMemo.IOHistory.Lines.add
   ('will be elliptical.  Perimeter offsets are always');
  CommandIOMemo.IOHistory.Lines.add
   ('taken with respect to local surface coordinates,');
  CommandIOMemo.IOHistory.Lines.add
   ('regardless of the orientation of the surface in world');
  CommandIOMemo.IOHistory.Lines.add
   ('coordinates.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('Elliptical and rectangular perimeters are aligned with');
  CommandIOMemo.IOHistory.Lines.add
   ('the principal axes of the local coordinate system');
  CommandIOMemo.IOHistory.Lines.add
   ('attached to the surface vertex.  The perimeter x');
  CommandIOMemo.IOHistory.Lines.add
   ('dimension thus specifies the width of the perimeter');
  CommandIOMemo.IOHistory.Lines.add
   ('in a direction parallel to the local x axis, and the');
  CommandIOMemo.IOHistory.Lines.add
   ('y dimension of the perimeter is with respect to the');
  CommandIOMemo.IOHistory.Lines.add
   ('local y axis.  As with perimeter offsets, the perimeter');
  CommandIOMemo.IOHistory.Lines.add
   ('dimensions are always with respect to local coordinates');
  CommandIOMemo.IOHistory.Lines.add
   ('regardless of the orientation of the surface in world');
  CommandIOMemo.IOHistory.Lines.add
   ('coordinates.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('Cylindrical optics perimeters are treated in nearly');
  CommandIOMemo.IOHistory.Lines.add
   ('the same manner as for rotationally symmetric optics.');
  CommandIOMemo.IOHistory.Lines.add
   ('The cylinder, which is always oriented such that');
  CommandIOMemo.IOHistory.Lines.add
   ('the zero power axis of the cylinder is parallel to the');
  CommandIOMemo.IOHistory.Lines.add
   ('local x axis, must have a radius of curvature to exceed');
  CommandIOMemo.IOHistory.Lines.add
   ('the diameter of a circular perimeter, or to exceed the');
  CommandIOMemo.IOHistory.Lines.add
   ('y axis dimension of a rectangular or elliptical');
  CommandIOMemo.IOHistory.Lines.add ('perimeter.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpConicConstant;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  Valid entries for the conic constant (cc), and their');
  CommandIOMemo.IOHistory.Lines.add
   ('  meanings, are:');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('    cc < -1      --  hyperboloid');
  CommandIOMemo.IOHistory.Lines.add
   ('    cc = -1      --  paraboloid');
  CommandIOMemo.IOHistory.Lines.add
   ('    -1 < cc < 0  --  ellipsoid of rev. about major axis');
  CommandIOMemo.IOHistory.Lines.add
   ('    cc = 0       --  sphere (default value)');
  CommandIOMemo.IOHistory.Lines.add
   ('    cc > 0       --  ellipsoid of rev. about minor axis');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  For values of cc <= 0, the conic constant is related');
  CommandIOMemo.IOHistory.Lines.add
   ('  to the eccentricity of the conic surface by:');
  CommandIOMemo.IOHistory.Lines.add
   ('       cc = -1 * e^2, where "e" is the eccentricity.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  It is possible to define a cone by setting');
  CommandIOMemo.IOHistory.Lines.add
   ('  the conic constant to a value less than -1 (i.e., a');
  CommandIOMemo.IOHistory.Lines.add
   ('  hyperbola), and the radius to a very small value.  The');
  CommandIOMemo.IOHistory.Lines.add
   ('  specific relationship between the conic constant and');
  CommandIOMemo.IOHistory.Lines.add
   ('  the semi vertex angle of the cone (theta) is');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('       cc = -1 * ((1 / ((tan (90 - theta))^2)) + 1)');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  The refractive analog of a parabolic mirror, for');
  CommandIOMemo.IOHistory.Lines.add
   ('  bringing parallel light rays to a point focus, is');
  CommandIOMemo.IOHistory.Lines.add
   ('  defined by a surface with elliptical shape.  The');
  CommandIOMemo.IOHistory.Lines.add
   ('  conic constant for the ellipse is defined by');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('                   cc = -1 / n^2');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  The radius of curvature for the elliptical surface is');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('             r = f / (1 + 1 / (n - 1))');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  where f = desired focal length.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  More cool stuff about ellipses:');
  CommandIOMemo.IOHistory.Lines.add
   ('    Shape parameters:');
  CommandIOMemo.IOHistory.Lines.add
   ('      a:  semimajor axis');
  CommandIOMemo.IOHistory.Lines.add
   ('      b:  semiminor axis');
  CommandIOMemo.IOHistory.Lines.add
   ('      c:  1/2 distance between foci f1 and f2');
  CommandIOMemo.IOHistory.Lines.add
   ('          = sqrt(a^2 - b^2)');
  CommandIOMemo.IOHistory.Lines.add
   ('    Optical parameters vs. shape parameters:');
  CommandIOMemo.IOHistory.Lines.add
   ('      cc  = [(b/a)^2] - 1  (conic constant)');
  CommandIOMemo.IOHistory.Lines.add
   ('      r   = (b^2)/a        (osculating radius)');
  CommandIOMemo.IOHistory.Lines.add
   ('      f/# = c/(2*b)');
  CommandIOMemo.IOHistory.Lines.add
   ('      f1  = a - c          (vertex to first focus)');
  CommandIOMemo.IOHistory.Lines.add
   ('      f2  = a + c          (vertex to second focus)');
  CommandIOMemo.IOHistory.Lines.add
   ('    Optical parameters vs. f1 and magnification M');
  CommandIOMemo.IOHistory.Lines.add
   ('      M   = f2/f1          (magnification)');
  CommandIOMemo.IOHistory.Lines.add
   ('      cc  = {4*M/[(M + 1)^2]} - 1');
  CommandIOMemo.IOHistory.Lines.add
   ('      r   = (2*f1*M)/(M + 1)');
  CommandIOMemo.IOHistory.Lines.add
   ('      f/# = [(M - 1)*sqrt(M)]/(4*M)');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('    Relation between shape parameters, M, and f1:');
  CommandIOMemo.IOHistory.Lines.add ('      a   = [f1*(M + 1)]/2');
  CommandIOMemo.IOHistory.Lines.add ('      b   = f1*sqrt(M)');
  CommandIOMemo.IOHistory.Lines.add ('      c   = [f1*(M - 1)]/2');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceArrayParameters;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('No help currently available for surface array parameters.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpScatteringAngle;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('LADS1 uses two scattering models.  The first model');
  CommandIOMemo.IOHistory.Lines.add
      ('assumes the scattered light is purely Lambertian,');
  CommandIOMemo.IOHistory.Lines.add
      ('with no preferred specular component.  This is');
  CommandIOMemo.IOHistory.Lines.add
      ('physically approximated by surfaces covered with');
  CommandIOMemo.IOHistory.Lines.add
      ('barium sulfate.  The second model (presently not');
  CommandIOMemo.IOHistory.Lines.add
      ('available) assumes there is a preferred or specular');
  CommandIOMemo.IOHistory.Lines.add
      ('component in the scattered radiation.  This is');
  CommandIOMemo.IOHistory.Lines.add
      ('physically approximated by imperfectly polished');
  CommandIOMemo.IOHistory.Lines.add
      ('surfaces.  In this model, the user specifies Gaussian');
  CommandIOMemo.IOHistory.Lines.add
      ('statistics for the scattering process, by means of');
  CommandIOMemo.IOHistory.Lines.add
      ('the standard deviation of the scattering pattern.  For');
  CommandIOMemo.IOHistory.Lines.add
      ('a large number of light rays, the distribution of light');
  CommandIOMemo.IOHistory.Lines.add
      ('rays emanating from a scattering surface will be');
  CommandIOMemo.IOHistory.Lines.add
      ('distributed in a random (Gaussian) fashion about the');
  CommandIOMemo.IOHistory.Lines.add
      ('unscattered (specular) direction.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceReflectivity;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('Exact Fresnel reflection (along with polarization');
  CommandIOMemo.IOHistory.Lines.add
   ('data) based on refractive index and angle of incidence');
  CommandIOMemo.IOHistory.Lines.add
   ('is not computed at this time.  Therefore, you must');
  CommandIOMemo.IOHistory.Lines.add
   ('enter the reflection coefficient for each surface.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('For a beamsplitter surface, a reflected ray will be');
  CommandIOMemo.IOHistory.Lines.add
   ('generated only if the reflected ray has a minimum');
  CommandIOMemo.IOHistory.Lines.add
   ('intensity greater than or equal to ' +
      FloatToStrF (CZBK_LOWEST_ACCEPTABLE_RAY_INTENSITY,ffFixed, 6, 4) + '.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpGlassName;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('The glass name must correspond to the name of a glass');
  CommandIOMemo.IOHistory.Lines.add
   ('found in the system file called "' + CZAA_GLASS_CATALOG +
      '."  The');
  CommandIOMemo.IOHistory.Lines.add
   ('current contents of this file may be examined in');
  CommandIOMemo.IOHistory.Lines.add
   ('detail by means of your text system editor.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpGRINAlias;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('The GRIN alias uniquely identifies the referenced');
  CommandIOMemo.IOHistory.Lines.add
      ('GRIN bulk material with respect to a particular');
  CommandIOMemo.IOHistory.Lines.add
      ('position and orientation in global coordinates.  The');
  CommandIOMemo.IOHistory.Lines.add
      ('same bulk GRIN material may be referred again,');
  CommandIOMemo.IOHistory.Lines.add
      ('as long as the alias is unique.  The alias may not');
  CommandIOMemo.IOHistory.Lines.add
      ('be the same as any existing glass in the glass');
  CommandIOMemo.IOHistory.Lines.add
      ('catalog.  Maximum allowed characters in the alias is ' +
      IntToStr (CZAH_MAX_CHARS_IN_GLASS_NAME) + '.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfacePosition;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  The position of each optical surface is defined with');
  CommandIOMemo.IOHistory.Lines.add
   ('  respect to a master reference coordinate system.  The');
  CommandIOMemo.IOHistory.Lines.add
   ('  location of the origin of the reference coordinate');
  CommandIOMemo.IOHistory.Lines.add
   ('  system is completely arbitrary; however, the positions');
  CommandIOMemo.IOHistory.Lines.add
   ('  of the optical elements within this reference');
  CommandIOMemo.IOHistory.Lines.add
   ('  coordinate system must all be mutually consistent.');
  CommandIOMemo.IOHistory.Lines.add
   ('  The position of each optical element is specified by');
  CommandIOMemo.IOHistory.Lines.add
   ('  the (x,y,z) coordinates of the vertex of the optical');
  CommandIOMemo.IOHistory.Lines.add ('  surface.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  The incremental position adjustment for the present');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface provides the user with the opportunity to');
  CommandIOMemo.IOHistory.Lines.add
   ('  make a temporary incremental change to the surface');
  CommandIOMemo.IOHistory.Lines.add
   ('  position, while keeping the fundamental position');
  CommandIOMemo.IOHistory.Lines.add
   ('  data intact.  This provides the ability to easily');
  CommandIOMemo.IOHistory.Lines.add
   ('  observe the effect of slight (or even large) amounts');
  CommandIOMemo.IOHistory.Lines.add
   ('  of surface "decenter" on system performance, and');
  CommandIOMemo.IOHistory.Lines.add
   ('  then cancel the effect by changing the incremental');
  CommandIOMemo.IOHistory.Lines.add ('  adjustment back to zero.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceOrientation;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  The roll, pitch (elevation), and yaw (azimuth) of an');
  CommandIOMemo.IOHistory.Lines.add
   ('  optical surface describe the orientation of the');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface within a master reference coordinate system.');
  CommandIOMemo.IOHistory.Lines.add
   ('  The origin and orientation of this master reference');
  CommandIOMemo.IOHistory.Lines.add
   ('  coordinate system are completely arbitrary.  However,');
  CommandIOMemo.IOHistory.Lines.add
   ('  the positions and orientations of the optical surfaces');
  CommandIOMemo.IOHistory.Lines.add
   ('  within this reference coordinate system must be');
  CommandIOMemo.IOHistory.Lines.add
   ('  be mutually consistent.  The user has complete freedom');
  CommandIOMemo.IOHistory.Lines.add
   ('  to specify all six degrees of freedom for each optical');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface within the master reference coordinate system.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  The position and orientation of each optical surface');
  CommandIOMemo.IOHistory.Lines.add
   ('  within the reference coordinate system is defined');
  CommandIOMemo.IOHistory.Lines.add
   ('  with respect to a "local" coordinate system attached');
  CommandIOMemo.IOHistory.Lines.add
   ('  to the surface vertex.  The z-axis of the "local"');
  CommandIOMemo.IOHistory.Lines.add
   ('  coordinate system is defined to be colinear with the');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface vertex normal vector.  The surface vertex');
  CommandIOMemo.IOHistory.Lines.add
   ('  normal vector always points away from the convex');
  CommandIOMemo.IOHistory.Lines.add
   ('  side of the surface; thus, the orientation of the');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface is completely described by specifying the');
  CommandIOMemo.IOHistory.Lines.add
   ('  direction of the local z-axis, as is described');
  CommandIOMemo.IOHistory.Lines.add
   ('  later.  This, in turn, makes it unnecessary to');
  CommandIOMemo.IOHistory.Lines.add
   ('  specify positive and negative radii of curvature in');
  CommandIOMemo.IOHistory.Lines.add
   ('  order to identify the orientation of the surface.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  The x- and y-axes of of the local coordinate system');
  CommandIOMemo.IOHistory.Lines.add
   ('  have no meaning for surfaces with rotational');
  CommandIOMemo.IOHistory.Lines.add
   ('  symmetry.  For cylindrical surfaces, the x-axis is');
  CommandIOMemo.IOHistory.Lines.add
   ('  aligned with the long axis of the cylinder.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  The orientation of the local coordinate system is');
  CommandIOMemo.IOHistory.Lines.add
   ('  specified in terms of roll, pitch, and yaw.  Roll,');
  CommandIOMemo.IOHistory.Lines.add
   ('  pitch, and yaw are zero when the axes of the local');
  CommandIOMemo.IOHistory.Lines.add
   ('  coordinate system are aligned with the axes of the');
  CommandIOMemo.IOHistory.Lines.add
   ('  master reference coordinate system.  When this is');
  CommandIOMemo.IOHistory.Lines.add
   ('  the case, the axis of rotational symmetry of the');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface will be parallel to the reference coordinate');
  CommandIOMemo.IOHistory.Lines.add
   ('  system z-axis.  We will now define what is meant by');
  CommandIOMemo.IOHistory.Lines.add
   ('  roll, pitch, and yaw.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  Yaw is defined as a "right-hand rule" rotation about');
  CommandIOMemo.IOHistory.Lines.add
   ('  the y-axis; pitch is defined as a "left-hand rule"');
  CommandIOMemo.IOHistory.Lines.add
   ('  rotation about the "yawed" x-axis; and roll is');
  CommandIOMemo.IOHistory.Lines.add
   ('  defined as a "right-hand rule" rotation about the');
  CommandIOMemo.IOHistory.Lines.add
   ('  "yawed" and "pitched" z-axis.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  The orientation of the surface is specified by first');
  CommandIOMemo.IOHistory.Lines.add
   ('  specifying the yaw, then the pitch, and finally the');
  CommandIOMemo.IOHistory.Lines.add
   ('  roll.  This particular sequence of rotations');
  CommandIOMemo.IOHistory.Lines.add
   ('  has several advantages over the standard sequence for');
  CommandIOMemo.IOHistory.Lines.add
   ('  specifying Euler angles, at least in the context of');
  CommandIOMemo.IOHistory.Lines.add ('  this program.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  One advantage for specifying rotations in this order');
  CommandIOMemo.IOHistory.Lines.add
   ('  is that yaw and pitch become indistinguishable');
  CommandIOMemo.IOHistory.Lines.add
   ('  from azimuth (about the y-axis) and elevation (above');
  CommandIOMemo.IOHistory.Lines.add
   ('  the x-z plane), at least for surfaces with rotational');
  CommandIOMemo.IOHistory.Lines.add
   ('  symmetry.  Thus, the orientation of the rotationally');
  CommandIOMemo.IOHistory.Lines.add
   ('  symmetric surfaces becomes a simple matter of');
  CommandIOMemo.IOHistory.Lines.add
   ('  specifying their azimuth and elevation, which seems');
  CommandIOMemo.IOHistory.Lines.add
   ('  much more intellectually tractable than specifying');
  CommandIOMemo.IOHistory.Lines.add
   ('  the usual Euler angles.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
   ('  The incremental adjustment to roll, pitch (elevation),');
  CommandIOMemo.IOHistory.Lines.add
   ('  and yaw (azimuth) for the present surface provides the');
  CommandIOMemo.IOHistory.Lines.add
   ('  user with the opportunity to make temporary changes to');
  CommandIOMemo.IOHistory.Lines.add
   ('  these data elements, while keeping the fundamental');
  CommandIOMemo.IOHistory.Lines.add
   ('  data intact.  This provides the ability to easily');
  CommandIOMemo.IOHistory.Lines.add
   ('  observe the effect of slight (or even large) amounts');
  CommandIOMemo.IOHistory.Lines.add
   ('  of surface tilt on system performance, and then cancel');
  CommandIOMemo.IOHistory.Lines.add
   ('  the effect by changing the incremental adjustment back');
  CommandIOMemo.IOHistory.Lines.add ('  to zero.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceOrdinal;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  The surface ordinal is the means by which this');
  CommandIOMemo.IOHistory.Lines.add
   ('  program identifies each optical surface.  Thus, the');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface ordinal must be specified before a new');
  CommandIOMemo.IOHistory.Lines.add
   ('  optical surface may be entered into the system, or');
  CommandIOMemo.IOHistory.Lines.add
   ('  before an old optical surface may be revised or');
  CommandIOMemo.IOHistory.Lines.add
   ('  deleted, or otherwise referred to in any way.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpSurfaceOrdinalRange;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  Several surface-related operations (e.g., Delete,');
  CommandIOMemo.IOHistory.Lines.add
   ('  List, etc.) require a range of surfaces over which');
  CommandIOMemo.IOHistory.Lines.add
   ('  the operation will be performed.  All surfaces');
  CommandIOMemo.IOHistory.Lines.add
   ('  specified in the range (including the first and last');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface) will take part in the operation.  Where only');
  CommandIOMemo.IOHistory.Lines.add
   ('  one surface is to be acted upon, the first surface in');
  CommandIOMemo.IOHistory.Lines.add
   ('  the range and the last surface in the range will be');
  CommandIOMemo.IOHistory.Lines.add
   ('  the same number.  For example, to delete surface 10,');
  CommandIOMemo.IOHistory.Lines.add
   ('  the proper command sequence is "D 10 10".');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
   ('  Entry of "*" will cause the program to use the');
  CommandIOMemo.IOHistory.Lines.add
   ('  highest possible surface ordinal for the final');
  CommandIOMemo.IOHistory.Lines.add
   ('  surface in the range.  The highest possible surface');
  CommandIOMemo.IOHistory.Lines.add
   ('  ordinal is presently equal to ' +
      IntToStr (CZAB_MAX_NUMBER_OF_SURFACES) + '.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpDestinationSurfaceOrdinal;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  The Move and Copy functions require a "destination"');
  CommandIOMemo.IOHistory.Lines.add
	('  surface where the Moved or Copied surfaces will be');
  CommandIOMemo.IOHistory.Lines.add
	('  inserted.  The Moved or Copied block of surfaces will');
  CommandIOMemo.IOHistory.Lines.add
  	('  be inserted ahead of the destination surface.  A valid');
  CommandIOMemo.IOHistory.Lines.add
	('  destination surface must be less than or equal to the');
  CommandIOMemo.IOHistory.Lines.add
	('  first member of the block, or greater than the last');
  CommandIOMemo.IOHistory.Lines.add
	('  member of the block.  For example, command "M 4 7 5"');
  CommandIOMemo.IOHistory.Lines.add
	('  is not valid because surface 5 (the destination');
  CommandIOMemo.IOHistory.Lines.add
	('  surface) is a member of the move block.  Likewise,');
  CommandIOMemo.IOHistory.Lines.add
	('  "M 4 7 7" is invalid, but "M 4 7 4" is valid.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  An example of a valid Move command is "M 4 7 10".');
  CommandIOMemo.IOHistory.Lines.add
	('  This will cause surfaces 4 thru 7 inclusive to be');
  CommandIOMemo.IOHistory.Lines.add
	('  deleted from their present location, and inserted');
  CommandIOMemo.IOHistory.Lines.add
  	('  before surface 10.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayRevisionCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add
      ('You must enter a light ray in the form of a line segment,');
  CommandIOMemo.IOHistory.Lines.add
      ('with a "tail" and a "head."  You must also supply a');
  CommandIOMemo.IOHistory.Lines.add
      ('wavelength value in microns, an incident medium index, and');
  CommandIOMemo.IOHistory.Lines.add
      ('some optional parameters relating to the automatic ray');
  CommandIOMemo.IOHistory.Lines.add
      ('generation features of the program.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('Internally, light rays are treated either as line segments');
  CommandIOMemo.IOHistory.Lines.add
      ('or as vectors, depending on the type of computation being');
  CommandIOMemo.IOHistory.Lines.add
      ('performed.  For example, light rays are treated as line');
  CommandIOMemo.IOHistory.Lines.add
      ('segments when finding the point of intersection with a');
  CommandIOMemo.IOHistory.Lines.add
      ('surface, or as vectors, when computing Snells law-type');
  CommandIOMemo.IOHistory.Lines.add
      ('surface interactions.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('For data entry purposes, a line segment representing a');
  CommandIOMemo.IOHistory.Lines.add
      ('light ray is specified by defining the (x,y,z) coordinates');
  CommandIOMemo.IOHistory.Lines.add
      ('of the "tail," and the (x,y,z) coordinates of the "head."');
  CommandIOMemo.IOHistory.Lines.add
      ('For internal Snells law interactions, an equivalent light');
  CommandIOMemo.IOHistory.Lines.add
      ('ray vector is formed parallel to the line segment, with a');
  CommandIOMemo.IOHistory.Lines.add
      ('magnitude proportional to the length of the line segment,');
  CommandIOMemo.IOHistory.Lines.add
      ('and with a direction pointing from the tail of the line');
  CommandIOMemo.IOHistory.Lines.add
      ('segment to the head.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('If the head of the line segment is defined to be beyond a');
  CommandIOMemo.IOHistory.Lines.add
      ('surface, no interaction will occur.  Thus, care must be');
  CommandIOMemo.IOHistory.Lines.add
      ('exercised in "ray aiming."  You may aim a ray at a pupil or');
  CommandIOMemo.IOHistory.Lines.add
      ('aperture stop buried inside an optical system, but the head');
  CommandIOMemo.IOHistory.Lines.add
      ('of the line segment representing the light ray must be');
  CommandIOMemo.IOHistory.Lines.add
      ('placed ahead of the entrance surface.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('You may specify up to ' + IntToStr (CZAC_MAX_NUMBER_OF_RAYS) + ' rays. ');
  CommandIOMemo.IOHistory.Lines.add
      ('Each of these rays may be considered to be the principal');
  CommandIOMemo.IOHistory.Lines.add
      ('ray of a fan or bundle containing up to ' +
      IntToStr (CZAD_MAX_COMPUTED_RAYS) + ' program-generated rays.');
  CommandIOMemo.IOHistory.Lines.add
      ('(Options for program-generated fans and bundles are described');
  CommandIOMemo.IOHistory.Lines.add ('below.)');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('The dimensions of the fan or bundle are defined by');
  CommandIOMemo.IOHistory.Lines.add
      ('specifying the bundle/fan head diameter, or by specifying');
  CommandIOMemo.IOHistory.Lines.add
      ('the ray cone vertex half-angle, or both, depending on the');
  CommandIOMemo.IOHistory.Lines.add
      ('type of fan or bundle selected.  For example, for a');
  CommandIOMemo.IOHistory.Lines.add
      ('hexpolar array, a conical bundle of rays will be generated. ');
  CommandIOMemo.IOHistory.Lines.add
      ('Each of the hexapolar rays will originate at a point');
  CommandIOMemo.IOHistory.Lines.add
      ('located at the tail of the principal ray, and terminate at');
  CommandIOMemo.IOHistory.Lines.add
      ('a point located in a disk-shaped region perpendicular to,');
  CommandIOMemo.IOHistory.Lines.add
      ('and located at the head of, the principal ray.  The');
  CommandIOMemo.IOHistory.Lines.add
      ('diameter of the disk-shaped region is specified by means of');
  CommandIOMemo.IOHistory.Lines.add ('the "BHD" parameter.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('Valid ray/bundle revision codes are:');
  CommandIOMemo.IOHistory.Lines.add
      ('  BHD ... Ray bundle (or fan) head diameter (default is 1.)');
  CommandIOMemo.IOHistory.Lines.add
      ('  ZEN ... Illumination cone vertex semi-angle (def. is 0).');
  CommandIOMemo.IOHistory.Lines.add
      ('  TX .... Tail of light ray, x-coordinate.');
  CommandIOMemo.IOHistory.Lines.add
      ('  TY .... Tail of light ray, y-coordinate.');
  CommandIOMemo.IOHistory.Lines.add
      ('  TZ .... Tail of light ray, z-coordinate.');
  CommandIOMemo.IOHistory.Lines.add
      ('  HX .... Head of light ray, x-coordinate.');
  CommandIOMemo.IOHistory.Lines.add
      ('  HY .... Head of light ray, y-coordinate.');
  CommandIOMemo.IOHistory.Lines.add
      ('  HZ .... Head of light ray, z-coordinate.');
  CommandIOMemo.IOHistory.Lines.add
      ('  L ..... Wavelength associated with light ray,');
  CommandIOMemo.IOHistory.Lines.add
      ('            in microns.');
  CommandIOMemo.IOHistory.Lines.add
      ('  IN .... Refractive index of the medium within which');
  CommandIOMemo.IOHistory.Lines.add
      ('            this light ray originates.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
      ('  SFAN .. Generate symmetric equal-area ray fan.');
  CommandIOMemo.IOHistory.Lines.add
      ('  AFAN .. Generate asymmetric equal-area ray fan.');
  CommandIOMemo.IOHistory.Lines.add
      ('  3FAN .. Generate tri-lateral equal-area ray fan.');
  CommandIOMemo.IOHistory.Lines.add
      ('            This ray fan is best for use during auto-');
  CommandIOMemo.IOHistory.Lines.add
      ('            matic optimization.');
  CommandIOMemo.IOHistory.Lines.add
      ('  LFAN .. Generate symmetric equidistant y-axis ray fan.');
  CommandIOMemo.IOHistory.Lines.add
      ('  LXFAN . Generate symmetric equidistant x-axis ray fan.');
  CommandIOMemo.IOHistory.Lines.add
      ('  SQR ... Generate square grid of rays.');
  CommandIOMemo.IOHistory.Lines.add
      ('  HEX ... Generate hexapolar ray bundle.');
  CommandIOMemo.IOHistory.Lines.add
      ('  ISO ... Generate isometric ray bundle.');
  CommandIOMemo.IOHistory.Lines.add
      ('  SOLID . Generate random rays into solid angle.');
  CommandIOMemo.IOHistory.Lines.add
      ('  RAND .. Generate random rays.');
  CommandIOMemo.IOHistory.Lines.add
      ('  GAUSS . Generate Gaussian ray bundle.');
  CommandIOMemo.IOHistory.Lines.add
      ('  LAMB .. Generate Lambertian ray bundle.  Use of this');
  CommandIOMemo.IOHistory.Lines.add
      ('            command requires specification of both a');
  CommandIOMemo.IOHistory.Lines.add
      ('            ray cone angle (ZEN) and a bundle head');
  CommandIOMemo.IOHistory.Lines.add
      ('            diameter (BHD).  The bundle head will be');
  CommandIOMemo.IOHistory.Lines.add
      ('            "illuminated" with rays from a Lambertian');
  CommandIOMemo.IOHistory.Lines.add
      ('            source whose angular subtense is equal to');
  CommandIOMemo.IOHistory.Lines.add
      ('            twice the specified cone angle.  Please');
  CommandIOMemo.IOHistory.Lines.add
      ('            note that the cone angle specifies the');
  CommandIOMemo.IOHistory.Lines.add
      ('            Lambertian source size, as viewed from the');
  CommandIOMemo.IOHistory.Lines.add
      ('            head of the principal ray.');
  CommandIOMemo.IOHistory.Lines.add
      ('  XRAY .. Cancel fan/bundle generation.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayCoordinates;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  Valid entry is any numeric value -- positive,');
  CommandIOMemo.IOHistory.Lines.add
	('  negative, or zero.  This data item represents the');
  CommandIOMemo.IOHistory.Lines.add
	('  x-, y-, or z-coordinate of the tail or head of a');
  CommandIOMemo.IOHistory.Lines.add
	('  light ray.  A light ray is specified by defining its');
  CommandIOMemo.IOHistory.Lines.add
	('  beginning point (i.e., the tail, somewhere on the');
  CommandIOMemo.IOHistory.Lines.add
	('  object) and its ending point (i.e., the head,');
  CommandIOMemo.IOHistory.Lines.add
  	('  usually located near the first optical surface).');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayWavelength;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  Valid entry is any non-zero numeric value.');
  CommandIOMemo.IOHistory.Lines.add
	('  Ray wavelength should be expressed in microns.');
  CommandIOMemo.IOHistory.Lines.add
	('  When the glass type, rather than the refractive');
  CommandIOMemo.IOHistory.Lines.add
	('  index, is specified for a particular surface,');
  CommandIOMemo.IOHistory.Lines.add
	('  the index of refraction will be computed based');
  CommandIOMemo.IOHistory.Lines.add
	('  on this wavelength and the dispersion equation for');
  CommandIOMemo.IOHistory.Lines.add
  	('  the specified glass type.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpIncidentMediumIndex;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid input consists of a number greater than or equal');
  CommandIOMemo.IOHistory.Lines.add
  	('to 1.0.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayOrdinal;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  The ray ordinal is the means by which this program');
  CommandIOMemo.IOHistory.Lines.add
	('  identifies each light ray vector.  Thus, the');
  CommandIOMemo.IOHistory.Lines.add
	('  ray ordinal must be specified before a new light');
  CommandIOMemo.IOHistory.Lines.add
	('  ray vector may be entered into the system, or before');
  CommandIOMemo.IOHistory.Lines.add
  	('  an old light ray vector may be revised or deleted.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayOrdinalRange;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  Several ray-related operations (e.g., Delete,');
  CommandIOMemo.IOHistory.Lines.add
	('  List, etc.) require a range of rays over which');
  CommandIOMemo.IOHistory.Lines.add
	('  the operation will be performed.  All rays');
  CommandIOMemo.IOHistory.Lines.add
	('  specified in the range (including the first and last');
  CommandIOMemo.IOHistory.Lines.add
	('  ray) will take part in the operation.  Where only');
  CommandIOMemo.IOHistory.Lines.add
	('  one ray is to be acted upon, the first ray in');
  CommandIOMemo.IOHistory.Lines.add
	('  the range and the last ray in the range will be');
  CommandIOMemo.IOHistory.Lines.add
	('  the same number.  For example, to delete ray 10,');
  CommandIOMemo.IOHistory.Lines.add
	('  the proper command sequence is "D 10 10".');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  Entry of "*" will cause the program to use the');
  CommandIOMemo.IOHistory.Lines.add
	('  highest possible ray ordinal for the final');
  CommandIOMemo.IOHistory.Lines.add
	('  ray in the range.  The highest possible ray');
  CommandIOMemo.IOHistory.Lines.add
	('  ordinal is presently equal to ' +
      IntToStr (CZAC_MAX_NUMBER_OF_RAYS) + '.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpDestinationRayOrdinal;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  The Move and Copy functions require a "destination"');
  CommandIOMemo.IOHistory.Lines.add
	('  ray where the Moved or Copied rays will be');
  CommandIOMemo.IOHistory.Lines.add
  	('  inserted.  The destination ray must not be a');
  CommandIOMemo.IOHistory.Lines.add
	('  member of the block of rays which are being');
  CommandIOMemo.IOHistory.Lines.add
	('  Moved or Copied.  For example, the command "M 4 7 5"');
  CommandIOMemo.IOHistory.Lines.add
	('  is not valid because ray 5 (the destination');
  CommandIOMemo.IOHistory.Lines.add
	('  ray) is a member of the move block.  The');
  CommandIOMemo.IOHistory.Lines.add
	('  commands "M 4 7 4" and "M 4 7 7" are likewise');
  CommandIOMemo.IOHistory.Lines.add
	('  invalid.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  An example of a valid Move command is "M 4 7 10".');
  CommandIOMemo.IOHistory.Lines.add
	('  This will cause rays 4 thru 7 inclusive to be');
  CommandIOMemo.IOHistory.Lines.add
	('  deleted from their present location, and inserted');
  CommandIOMemo.IOHistory.Lines.add
  	('  before ray 10.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayBundleHeadDiameter;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid entry is any numeric value greater than zero.');
  CommandIOMemo.IOHistory.Lines.add
	('This program uses the ray bundle head diameter (BHD)');
  CommandIOMemo.IOHistory.Lines.add
	('in the automatic procedures for generating ray');
  CommandIOMemo.IOHistory.Lines.add
	('bundles or ray fans.  For example, when a ray bundle');
  CommandIOMemo.IOHistory.Lines.add
	('is selected, the user-specified ray becomes the');
  CommandIOMemo.IOHistory.Lines.add
	('central, or principal, ray for a bundle of rays which');
  CommandIOMemo.IOHistory.Lines.add
	('are arranged in the form of a right circular cone.');
  CommandIOMemo.IOHistory.Lines.add
	('The vertex of the conical bundle coincides with the');
  CommandIOMemo.IOHistory.Lines.add
  	('tail of the principal ray, and the head of the');
  CommandIOMemo.IOHistory.Lines.add
	('principal ray is located at the center of the base of');
  CommandIOMemo.IOHistory.Lines.add
	('the cone.  The diameter of the circular base of the');
  CommandIOMemo.IOHistory.Lines.add
	('cone is the bundle head diameter.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('The BHD for a symmetric fan of rays is just the width');
  CommandIOMemo.IOHistory.Lines.add
	('of the fan at the location of the head of the principal');
  CommandIOMemo.IOHistory.Lines.add
	('ray.  The vertex of the fan is located at tail of the');
  CommandIOMemo.IOHistory.Lines.add
	('principal ray.  The BHD for an asymmetric fan has the');
  CommandIOMemo.IOHistory.Lines.add
	('same meaning as for a symmetric fan, if the asymmetric');
  CommandIOMemo.IOHistory.Lines.add
	('fan is considered to be one half of a symmetric fan,');
  CommandIOMemo.IOHistory.Lines.add
  	('split along the axis of symmetry.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpComputedRayCount;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  For fan rays and random rays, valid entry is any');
  CommandIOMemo.IOHistory.Lines.add
	('  numeric value greater than zero and less than ' +
      IntToStr (CZAD_MAX_COMPUTED_RAYS ) + '.');
  CommandIOMemo.IOHistory.Lines.add
	('  For a hexapolar ray bundle, valid entry is any');
  CommandIOMemo.IOHistory.Lines.add
	('  numeric value greater than zero and not greater than ' +
      IntToStr (MaxNumberOfRings) + '.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpRayConeHalfAngle;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
  	('  Valid entry is an angle (in degrees) from 0 to 180.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpMinimumZenithDistance;

BEGIN

END;

PROCEDURE HelpAzimuthAngularCenter;

BEGIN

END;

PROCEDURE HelpAzimuthSemiLength;

BEGIN

END;

PROCEDURE HelpOrangeSliceAngularWidth;

BEGIN

END;

PROCEDURE HelpGaussianRayBundleCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('A gaussian ray bundle simulates the intensity profile');
  CommandIOMemo.IOHistory.Lines.add
	('of a laser beam.  This program can simulate the');
  CommandIOMemo.IOHistory.Lines.add
	('intensity profile of beams produced by several kinds');
  CommandIOMemo.IOHistory.Lines.add
	('of lasers, including excimer, diode, HeNe, etc.  This');
  CommandIOMemo.IOHistory.Lines.add
	('is done by generating a ray bundle whose diameter is');
  CommandIOMemo.IOHistory.Lines.add
	('specified at both the head and tail of the principal');
  CommandIOMemo.IOHistory.Lines.add
	('ray, rather than just at the head.  Typically, the head');
  CommandIOMemo.IOHistory.Lines.add
	('of the gaussian bundle will be associated with the beam');
  CommandIOMemo.IOHistory.Lines.add
	('waist.  Several types of lasers (e.g., excimer, diode)');
  CommandIOMemo.IOHistory.Lines.add
	('produce beams which are elliptical, and which may also');
  CommandIOMemo.IOHistory.Lines.add
	('be uniform in intensity along one axis at the beam');
  CommandIOMemo.IOHistory.Lines.add
	('waist.  Thus, this program provides a facility for');
  CommandIOMemo.IOHistory.Lines.add
	('specifying whether the beam is gaussian or uniform');
  CommandIOMemo.IOHistory.Lines.add
	('along the local x and y axes, at the bundle head and');
  CommandIOMemo.IOHistory.Lines.add
  	('at the bundle tail.  The useage of the gaussian bundle');
  CommandIOMemo.IOHistory.Lines.add
	('commands are illustrated by means of the following');
  CommandIOMemo.IOHistory.Lines.add
	('example.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('We will specify an excimer laser with an output beam');
  CommandIOMemo.IOHistory.Lines.add
	('which is uniform in the vertical direction at the beam');
  CommandIOMemo.IOHistory.Lines.add
	('waist, but gaussian in the horizontal direction.  In');
  CommandIOMemo.IOHistory.Lines.add
	('the far field, the beam is gaussian in both directions,');
  CommandIOMemo.IOHistory.Lines.add
	('but is highly elliptical.  We associate the beam waist');
  CommandIOMemo.IOHistory.Lines.add
	('of the excimer laser with the head of the gaussian');
  CommandIOMemo.IOHistory.Lines.add
	('bundle.  Since the intensity profile of the excimer');
  CommandIOMemo.IOHistory.Lines.add
  	('beam is uniform in the vertical (y) direction, the y');
  CommandIOMemo.IOHistory.Lines.add
	('dimension of the gaussian bundle head is flagged as');
  CommandIOMemo.IOHistory.Lines.add
	('uniform by invoking the "HYU" command.  The physical');
  CommandIOMemo.IOHistory.Lines.add
	('size of the beam in the vertical dimension is then');
  CommandIOMemo.IOHistory.Lines.add
	('specified by invoking the "HY" command, followed by a');
  CommandIOMemo.IOHistory.Lines.add
	('value which is equal to the full vertical height of the');
  CommandIOMemo.IOHistory.Lines.add
	('beam.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('The gaussian nature of the excimer beam intensity');
  CommandIOMemo.IOHistory.Lines.add
	('profile in the horizontal (x) direction is');
  CommandIOMemo.IOHistory.Lines.add
	('specified by invoking the "HXG" command.  The beam');
  CommandIOMemo.IOHistory.Lines.add
  	('width in the horizontal direction is specified by "HX"');
  CommandIOMemo.IOHistory.Lines.add
	('followed by a value which is equal to the full beam');
  CommandIOMemo.IOHistory.Lines.add
	('width at the half power point, i.e., FWHM.  In a');
  CommandIOMemo.IOHistory.Lines.add
	('similar manner, the tail of the gaussian beam is');
  CommandIOMemo.IOHistory.Lines.add
	('specified as gaussian in both the x and y directions,');
  CommandIOMemo.IOHistory.Lines.add
	('by means of the "TXG" and "TYG" commands, while the');
  CommandIOMemo.IOHistory.Lines.add
	('actual elliptical shape of the tail is specified by');
  CommandIOMemo.IOHistory.Lines.add
	('means of the different FWHM values entered in response');
  CommandIOMemo.IOHistory.Lines.add
	('to the "TX" and "TY" commands.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('Laser manufacturers typically state the dimensions of');
  CommandIOMemo.IOHistory.Lines.add
  	('the laser output beam in terms of the beam waist size');
  CommandIOMemo.IOHistory.Lines.add
	('and the beam divergence.  Note that this program does');
  CommandIOMemo.IOHistory.Lines.add
	('not request the beam divergence, but, instead, requests');
  CommandIOMemo.IOHistory.Lines.add
	('the size of the beam at two different places, i.e., at');
  CommandIOMemo.IOHistory.Lines.add
	('the head and tail of the beam principal ray.  The');
  CommandIOMemo.IOHistory.Lines.add
	('divergence characteristics of the beam are implicitly');
  CommandIOMemo.IOHistory.Lines.add
	('contained in this information.  The reason for this');
  CommandIOMemo.IOHistory.Lines.add
	('approach is to provide better visibility of the');
  CommandIOMemo.IOHistory.Lines.add
	('geometrical approach used by this program to simulate');
  CommandIOMemo.IOHistory.Lines.add
	('gaussian beams.  Since the beam waist size may not be');
  CommandIOMemo.IOHistory.Lines.add
	('explicitly stated, the following formulas may be');
  CommandIOMemo.IOHistory.Lines.add
	('helpful:');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  BEAM DIVERGENCE:');
  CommandIOMemo.IOHistory.Lines.add
	('    2*tan (alpha) = (4/pi)*(lambda/d)*(-1/2)*ln(I/Imax)');
  CommandIOMemo.IOHistory.Lines.add
	('      where alpha = asymptotic divergence half angle');
  CommandIOMemo.IOHistory.Lines.add
	('                    of beam for the isophote with');
  CommandIOMemo.IOHistory.Lines.add
	('                    intensity I/Imax.  Note that the');
  CommandIOMemo.IOHistory.Lines.add
	('                    quantity 2*tan (alpha) is simply');
  CommandIOMemo.IOHistory.Lines.add
	('                    equal to the inverse f/# of the');
  CommandIOMemo.IOHistory.Lines.add
	('                    diverging beam.');
  CommandIOMemo.IOHistory.Lines.add
  	('                d = beam waist diameter, at the');
  CommandIOMemo.IOHistory.Lines.add
	('                    I/Imax isophote.');
  CommandIOMemo.IOHistory.Lines.add
	('           lambda = wavelength, in units consistent');
  CommandIOMemo.IOHistory.Lines.add
	('                    with d.');
  CommandIOMemo.IOHistory.Lines.add
	('           I/Imax = fractional beam intensity level.');
  CommandIOMemo.IOHistory.Lines.add
	('             Imax = intensity level at center of beam.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('  BEAM DIAMETER:');
  CommandIOMemo.IOHistory.Lines.add
	('    At z >> d:');
  CommandIOMemo.IOHistory.Lines.add
	('      D = 2 * tan (alpha) * z');
  CommandIOMemo.IOHistory.Lines.add
	('          where D = beam diameter at the I/Imax');
  CommandIOMemo.IOHistory.Lines.add
	('                    isophote.');
  CommandIOMemo.IOHistory.Lines.add
	('                z = distance from beam waist.');
  CommandIOMemo.IOHistory.Lines.add
	('    At any position in beam:');
  CommandIOMemo.IOHistory.Lines.add
	('      D = l * sqrt [(-1/2) ln (I/Imax)]');
  CommandIOMemo.IOHistory.Lines.add
	('          where l = deam diameter at the 1/(e^2)');
  CommandIOMemo.IOHistory.Lines.add
	('                    isophote.');
  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('It is hoped that these formulas may be useful in');
  CommandIOMemo.IOHistory.Lines.add
	('converting the output beam specifications for');
  CommandIOMemo.IOHistory.Lines.add
	('commercially available lasers, into the FWHM values');
  CommandIOMemo.IOHistory.Lines.add
	('expected by this program.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpOptimizationCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('This program performs optimization via a process first');
  CommandIOMemo.IOHistory.Lines.add
	('developed for computerized optimization of electronic');
  CommandIOMemo.IOHistory.Lines.add
	('circuits, known as simulated annealing.  This approach');
  CommandIOMemo.IOHistory.Lines.add
	('allows parameter space to be searched in its entirety,');
  CommandIOMemo.IOHistory.Lines.add
	('but in a random fashion, rather than by means of the');
  CommandIOMemo.IOHistory.Lines.add
	('traditional process where a single parameter is varied');
  CommandIOMemo.IOHistory.Lines.add
	('while holding all others constant.  The traditional');
  CommandIOMemo.IOHistory.Lines.add
	('approach, involving the calculus of variations, is');
  CommandIOMemo.IOHistory.Lines.add
  	('superior to simulated annealing when it is necessary to');
  CommandIOMemo.IOHistory.Lines.add
	('optimize only a few parameters.  However, this');
  CommandIOMemo.IOHistory.Lines.add
	('approach becomes too time consuming, even for high');
  CommandIOMemo.IOHistory.Lines.add
	('speed computers, when an entire optical system');
  CommandIOMemo.IOHistory.Lines.add
	('involving many surfaces must be optimized.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('Simulated annealing usually permits a good solution');
  CommandIOMemo.IOHistory.Lines.add
	('to be found in a relatively short amount of time.');
  CommandIOMemo.IOHistory.Lines.add
	('Although this solution may not be the absolute best');
  CommandIOMemo.IOHistory.Lines.add
	('possible, nevertheless, the solution may be acceptable');
  CommandIOMemo.IOHistory.Lines.add
	('for the task at hand.  An advantage of the simulated');
  CommandIOMemo.IOHistory.Lines.add
  	('annealing approach is that better and better solutions');
  CommandIOMemo.IOHistory.Lines.add
	('may be achieved by allowing for longer and longer');
  CommandIOMemo.IOHistory.Lines.add
	('processing times.  This process may actually be');
  CommandIOMemo.IOHistory.Lines.add
	('accelarated by allowing the "temperature" (i.e., the');
  CommandIOMemo.IOHistory.Lines.add
	('allowable range of variation for a given parameter) to');
  CommandIOMemo.IOHistory.Lines.add
	('be reduced, either as a function of processing time, or');
  CommandIOMemo.IOHistory.Lines.add
	('as improved solutions are encountered.  This program');
  CommandIOMemo.IOHistory.Lines.add
	('reduces parameter "temperature" as improved solutions');
  CommandIOMemo.IOHistory.Lines.add
	('are obtained.  The user activates the bound reduction');
  CommandIOMemo.IOHistory.Lines.add
	('feature by setting flag "B" listed in the main');
  CommandIOMemo.IOHistory.Lines.add
	('optimization menu.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	('Flag "C" in the main optimization menu activates a');
  CommandIOMemo.IOHistory.Lines.add
	('feature which causes the limiting values, or bounds,');
  CommandIOMemo.IOHistory.Lines.add
	('for each optimization parameter to be recentered about');
  CommandIOMemo.IOHistory.Lines.add
	('the current best parameter value, whenever an improved');
  CommandIOMemo.IOHistory.Lines.add
	('solution is found.  This capability is independent of');
  CommandIOMemo.IOHistory.Lines.add
	('the bound reduction feature.  However, bound reduction');
  CommandIOMemo.IOHistory.Lines.add
	('may not be enabled unless bound recentering is also');
  CommandIOMemo.IOHistory.Lines.add
	('active.  The other options listed in the main menu');
  CommandIOMemo.IOHistory.Lines.add
	('provide access to lower level menus, where additional');
  CommandIOMemo.IOHistory.Lines.add
	('help is available.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpOptimizationMeritFunction;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid merit function codes are:');
  CommandIOMemo.IOHistory.Lines.add
	('  R  Merit function will be based on miminizing the');
  CommandIOMemo.IOHistory.Lines.add
	('       RMS diameter of the blur circle on the');
  CommandIOMemo.IOHistory.Lines.add
	('       designated (image) surface.');
  CommandIOMemo.IOHistory.Lines.add
	('  F  Merit function will be based on minimizing the');
  CommandIOMemo.IOHistory.Lines.add
  	('       full diameter of the blur circle on the');
  CommandIOMemo.IOHistory.Lines.add
	('       designated (image) surface.');
  CommandIOMemo.IOHistory.Lines.add
        ('  U  Merit function is 1 minus the average normalized');
  CommandIOMemo.IOHistory.Lines.add
        ('       image intensity times the fraction of rays');
  CommandIOMemo.IOHistory.Lines.add
        ('       which arrive at the image surface.');
  CommandIOMemo.IOHistory.Lines.add
	('Note that the designated surface may be at a great');
  CommandIOMemo.IOHistory.Lines.add
	('distance, or at the far-field focus of a lens or');
  CommandIOMemo.IOHistory.Lines.add
	('mirror system.  If the designated surface is then');
  CommandIOMemo.IOHistory.Lines.add
	('placed at some distance off axis, or if an off-center');
  CommandIOMemo.IOHistory.Lines.add
	('aperture is used, an "angle solve" solution may be');
  CommandIOMemo.IOHistory.Lines.add
	('obtained.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpOptimizationSurfaceDataCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid responses are:');
  CommandIOMemo.IOHistory.Lines.add
	(' A..Optimize radius (toggle).  Radius of curvature');
  CommandIOMemo.IOHistory.Lines.add
  	('    for the present surface will be optimized.  The');
  CommandIOMemo.IOHistory.Lines.add
	('    current value for the radius will be used as the');
  CommandIOMemo.IOHistory.Lines.add
	('    starting value for optimization.  Optimization');
  CommandIOMemo.IOHistory.Lines.add
	('    values will be chosen at random over the range');
  CommandIOMemo.IOHistory.Lines.add
	('    between radius bounds #1 and #2.');
  CommandIOMemo.IOHistory.Lines.add
	(' B..Set radius bounds to default values of ' +
      FloatToStrF (MIN_RADIUS, ffFixed, 7, 4) + ' and');
  CommandIOMemo.IOHistory.Lines.add
	('    ' + FloatToStrF (MAX_RADIUS, ffFixed, 7, 1) +
        '.  Any initial value for the');
  CommandIOMemo.IOHistory.Lines.add
	('    radius is permitted.  If the surface is initially');
  CommandIOMemo.IOHistory.Lines.add
	('    flat, the surface orientation reversal flag will');
  CommandIOMemo.IOHistory.Lines.add
	('    also be enabled.  This will cause both convex and');
  CommandIOMemo.IOHistory.Lines.add
	('    concave radii to be searched during optimization.');
  CommandIOMemo.IOHistory.Lines.add
	(' C..User will be prompted to enter a value for radius');
  CommandIOMemo.IOHistory.Lines.add
	('    bound #1.');
  CommandIOMemo.IOHistory.Lines.add
	(' D..User will be prompted to enter a value for radius');
  CommandIOMemo.IOHistory.Lines.add
	('    bound #2.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	(' E..Permit surface orientation reversal (toggle).  If');
  CommandIOMemo.IOHistory.Lines.add
	('    this switch is enabled, both convex and concave');
  CommandIOMemo.IOHistory.Lines.add
	('    radii will be searched.  It is not a good idea');
  CommandIOMemo.IOHistory.Lines.add
	('    to enable orientation reversal when the bound');
  CommandIOMemo.IOHistory.Lines.add
	('    recentering and/or reduction features are active.');
  CommandIOMemo.IOHistory.Lines.add
	('    The correct orientation for the surface should be');
  CommandIOMemo.IOHistory.Lines.add
	('    determined before activating bound recentering or');
  CommandIOMemo.IOHistory.Lines.add
	('    reduction.  This will speed up optimization by as');
  CommandIOMemo.IOHistory.Lines.add
	('    much as a factor of 2.');
  CommandIOMemo.IOHistory.Lines.add
	(' G..Optimize position (toggle).  Z-axis position');
  CommandIOMemo.IOHistory.Lines.add
	('    for the present surface will be optimized.  The');
  CommandIOMemo.IOHistory.Lines.add
	('    current value for the position will be used as the');
  CommandIOMemo.IOHistory.Lines.add
	('    starting value for optimization.  Optimization');
  CommandIOMemo.IOHistory.Lines.add
	('    values will be chosen at random over the range');
  CommandIOMemo.IOHistory.Lines.add
	('    between position bounds #1 and #2.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	(' I..User will be prompted to enter a value for');
  CommandIOMemo.IOHistory.Lines.add
	('    position bound #1.');
  CommandIOMemo.IOHistory.Lines.add
	(' J..User will be prompted to enter a value for');
  CommandIOMemo.IOHistory.Lines.add
	('    position bound #2.');
  CommandIOMemo.IOHistory.Lines.add
	(' H..Control distance to next surface (toggle).  This');
  CommandIOMemo.IOHistory.Lines.add
	('    flag should be set when it is desirable to');
  CommandIOMemo.IOHistory.Lines.add
	('    maintain a particular distance ("thickness") to');
  CommandIOMemo.IOHistory.Lines.add
	('    an adjacent surface during position optimization.');
  CommandIOMemo.IOHistory.Lines.add
	('    The next 3 commands are used in conjunction with');
  CommandIOMemo.IOHistory.Lines.add
	('    the thickness control feature.');
  CommandIOMemo.IOHistory.Lines.add
  	(' S..Surface ordinal of position-controlled surface.');
  CommandIOMemo.IOHistory.Lines.add
	('    Position optimization must be enabled for this');
  CommandIOMemo.IOHistory.Lines.add
	('    surface.  Surface must have position bounds which');
  CommandIOMemo.IOHistory.Lines.add
	('    are identical to the primary (controlling) surface.');
  CommandIOMemo.IOHistory.Lines.add
	(' Q..Ideal distance to position-controlled surface.');
  CommandIOMemo.IOHistory.Lines.add
	(' R..Permitted variation in ideal distance to position-');
  CommandIOMemo.IOHistory.Lines.add
	('    controlled surface.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	(' K..Optimize lens material (glass type).  This flag');
  CommandIOMemo.IOHistory.Lines.add
	('    enables a feature which will allow various glass');
  CommandIOMemo.IOHistory.Lines.add
	('    types to be chosen at random from among those');
  CommandIOMemo.IOHistory.Lines.add
  	('    presently contained in the on-line glass catalog.');
  CommandIOMemo.IOHistory.Lines.add
	('    The on-line glass catalog is a faster version of');
  CommandIOMemo.IOHistory.Lines.add
	('    the ASCII glass catalog supplied with this program.');
  CommandIOMemo.IOHistory.Lines.add
	('    The on-line glass catalog is always empty at');
  CommandIOMemo.IOHistory.Lines.add
	('    program start-up.  A glass may be added to the on-');
  CommandIOMemo.IOHistory.Lines.add
	('    line catalog by either of two methods.  One method');
  CommandIOMemo.IOHistory.Lines.add
	('    is to perform a glass catalog inquiry, via the');
  CommandIOMemo.IOHistory.Lines.add
	('    "G(lass" command, for each glass type which the');
  CommandIOMemo.IOHistory.Lines.add
	('    user wishes to carry into the optimization run.');
  CommandIOMemo.IOHistory.Lines.add
	('    The second method is to execute an initial ray');
  CommandIOMemo.IOHistory.Lines.add
	('    trace with "dummy" surfaces (optimization disabled)');
  CommandIOMemo.IOHistory.Lines.add
	('    which are assigned glass types which the user');
  CommandIOMemo.IOHistory.Lines.add
	('    wishes to carry into the optimization run.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	(' L..Use only preferred glass types.  This flag causes');
  CommandIOMemo.IOHistory.Lines.add
	('    the program to select only preferred glass types,');
  CommandIOMemo.IOHistory.Lines.add
	('    from among those contained in the on-line catalog,');
  CommandIOMemo.IOHistory.Lines.add
	('    during glass optimization.');
  CommandIOMemo.IOHistory.Lines.add
	(' M..Optimize conic constant (toggle).  Conic constant');
  CommandIOMemo.IOHistory.Lines.add
	('    for the present surface will be optimized.  The');
  CommandIOMemo.IOHistory.Lines.add
	('    current value for the conic constant will be used');
  CommandIOMemo.IOHistory.Lines.add
	('    as the starting value for optimization.  Values');
  CommandIOMemo.IOHistory.Lines.add
	('    will be chosen at random over the range between');
  CommandIOMemo.IOHistory.Lines.add
	('    conic constant bounds #1 and #2.');
  CommandIOMemo.IOHistory.Lines.add
	(' N..Set conic constant bounds to default values of ' +
      FloatToStrF (MIN_CONIC_CONSTANT, ffFixed, 7, 4) + ' and');
  CommandIOMemo.IOHistory.Lines.add
	('    ' + FloatToStrF (MAX_CONIC_CONSTANT, ffFixed, 7, 4) +
      '.  Any initial value for the');
  CommandIOMemo.IOHistory.Lines.add
	('    conic constant is permitted.');
  Q980_REQUEST_MORE_OUTPUT;
  CommandIOMemo.IOHistory.Lines.add
	(' O..User will be prompted to enter a value for conic');
  CommandIOMemo.IOHistory.Lines.add
	('    constant bound #1.');
  CommandIOMemo.IOHistory.Lines.add
	(' P..User will be prompted to enter a value for conic');
  CommandIOMemo.IOHistory.Lines.add
	('    constant bound #2.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpOptimizationRadiusBounds;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Any value greater than zero is acceptable.  Further');
  CommandIOMemo.IOHistory.Lines.add
  	('validation is performed at trace-time.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpOptimizationPositionBounds;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Any value is acceptable.  Further validation is');
  CommandIOMemo.IOHistory.Lines.add
  	('performed at trace time.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpGraphicsCommands;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
	('Valid commands are:');
  CommandIOMemo.IOHistory.Lines.add
	('  A .. Revise aspect ratio.  The user will be prompted');
  CommandIOMemo.IOHistory.Lines.add
	('         to revise the screen aspect ratio, through');
  CommandIOMemo.IOHistory.Lines.add
	('         interactive adjustment of the appearance of');
  CommandIOMemo.IOHistory.Lines.add
	('         a circular viewport.');
  CommandIOMemo.IOHistory.Lines.add
	('  X .. Coordinates of center of viewport.  The');
  CommandIOMemo.IOHistory.Lines.add
  	('  Y ..   displayed curves which represent the surfaces');
  CommandIOMemo.IOHistory.Lines.add
	('  Z ..   are formed from the intersection of a y-z');
  CommandIOMemo.IOHistory.Lines.add
	('         plane which passes through the surfaces and');
  CommandIOMemo.IOHistory.Lines.add
	('         also through the (x,y,z) position of the');
  CommandIOMemo.IOHistory.Lines.add
	('         center of the viewport.');
  CommandIOMemo.IOHistory.Lines.add
	('  O .. Diameter of viewport.  The viewport itself will');
  CommandIOMemo.IOHistory.Lines.add
	('         not be displayed, but is simply an aid in');
  CommandIOMemo.IOHistory.Lines.add
	('         determining the viewing scale.');
  CommandIOMemo.IOHistory.Lines.add
	('  D .. The present set of defined surfaces will be');
  CommandIOMemo.IOHistory.Lines.add
	('         drawn on the screen, according to viewport');
  CommandIOMemo.IOHistory.Lines.add
	('         dimensions previously supplied by the user.');
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpCPCDesignParameters;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('There are four design parameters which define the shape of a hybrid');
  CommandIOMemo.IOHistory.Lines.add
      ('("theta-in, theta-out") CPC.  They are:');
  CommandIOMemo.IOHistory.Lines.add
      ('  1.) Maximum external angle of incidence (in air) at the');
  CommandIOMemo.IOHistory.Lines.add
      ('        entrance aperture of the CPC');
  CommandIOMemo.IOHistory.Lines.add
      ('  2.) CPC refractive index (referred to air)');
  CommandIOMemo.IOHistory.Lines.add
      ('  3.) Maximum internal angle for light rays (within CPC medium)');
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
  Q980_REQUEST_MORE_OUTPUT

END;

PROCEDURE HelpAsphericDeformationConstants;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('The aspheric deformation constants are the coefficients of the 4th,');
  CommandIOMemo.IOHistory.Lines.add
      ('6th, 8th, etc. through 22nd even-order axi-symmetric terms which are');
  CommandIOMemo.IOHistory.Lines.add
      ('appended to the usual sagitta equation.');
  Q980_REQUEST_MORE_OUTPUT

END;

end.
