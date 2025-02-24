/******************************************************************************
* LAOG project - Yorick Contribution package
*******************************************************************************/

func oiFitsUtils(void)
/* DOCUMENT oiFitsUtils                                                               
                                                                                       
   DESCRIPTION
   Tools to manipulate oiStructures of the OI_FITS format.
   
   *** USER-ORIENTED FUNCTIONS ***
   
   Read/Write:
   - oiFitsListFiles          : list files in a directory (ls function)
   - oiFitsLoadFiles          : load a list of OIFITS files into oiStructs
   - oiFitsWriteFiles         : write oiStructs into OIFITS files

   Manipulate wavelength table:
   - oiFitsKeepWave           : keep only part of the spectrum
   - oiFitsShiftWave          : shift the spectrum
   - oiFitsSortWave           : re-sort the spectrum LbdMin->LbdMax
   - oiFitsInterpWave         : interpolate the spectrum dimension
   - oiFitsAverageWave        : average the spectrum dimension
   - oiFitsUpdateOiWave       : change manually the table
   - oiFitsRenameInsName      : change the insName of some observations

   Manipulate UV:
   - oiFitsRotateUV           : rotate the UV reference frame
   - oiFitsSwapBaseline       : swap some baseline (station, uv and phases)
                                closure-phase is not supported.

   List and select observations:
   - oiFitsListTarget         : list all target in oiTarget
   - oiFitsListObs            : list obs in oiVis2, oiVis or oiT3, by grouping
                                simultaneous observation (# bases).
   - oiFitsListAllObs         : list all obs in oiVis2, oiVis or oiT3
   - oiFitsFlagOiData         : fonction to flag observations
   - oiFitsKeepWave           : keep only data within a part of the spectrum
   - oiFitsKeepTargets        : keep only data on specific targets
   - oiFitsCutTargets         : remove data on specific targets
   - oiFitsKeepInsName        : keep only data on specific insName
   - oiFitsKeepTime           : keep only data taken within time-intervals
   - oiFitsKeepDate           : keep only data with specified dateObs
   - oiFitsKeepSetup          : keep only data with specified setup string
   - oiFitsKeepLogElement     : keep only data with specified oiLog element
   - oiFitsCutTime            : remove a period of time
   - oiFitsCutTimeBase        : remove a range of time, in a given baseline
   - oiFitsCutSingle          : remove a single observation, defined by
                                its baseline and its approximate mjd
   - oiFitsSplitNight         : split the night in sub-part
   - oiFitsSelectSequences    : split the night in sequences (CAL/SCI/CAL)
   - oiFitsSplitArrays        : split the observations into different
                                yorick arrays to manipulate them

   Find correspondences:
   - oiFitsGetOiWave          : found the oiWave corresponding to an obs.
   - oiFitsGetOiTarget        : found the oiTarget corresponding to an obs.
   - oiFitsGetOiDiam          : found the oiDiam corresponding to an obs.
   - oiFitsGetOiLog           : found the oiLog corresponding to an obs.
   - oiFitsBaseMatch

   Extract information:
   - oiFitsGetBaseLength      : return base length in meters
   - oiFitsGetBaseAngle       : return baseline angle in deg
   - oiFitsGetBaseName        : return the baseline name: "A0-K0"
   - oiFitsGetStationName     : return the station name: ["A0","K0"]
   - oiFitsGetTargetName      : return the target name
   - oiFitsGetIsCal           : return the corresponding flag 'isCal' (0/1)
   - oiFitsGetDiam            : return the corresponding target diameter
   - oiFitsGetSetup           : return the corresponding setup, as a string
   - oiFitsGetLogElement      : return the corresponding oiLog.element
   - oiFitsGetBaseId          : return index correspondong to the base
   - oiFitsGetBandId          : return index corresponding to J,H or K
   - oiFitsGetTargetId        : return index targetId
   - oiFitsGetSetupId         : return index of the instrumental setup
   - oiFitsGetMjdId           : return index of the MJD
   - oiFitsGetObsId           : return index corresponding to the obs
                                (several baselines can have same ObsId)
   
   Plot:
   - oiFitsPlotUV             : plot the uv plane
   - oiFitsPlotOiData         : plot vis2, t3Phi and visPhi in a generic manner
                                (versus base, time, lbd...)
   - oiFitsPlotTfTime         : plot TF-estimation versus time.
   
   Extract/modify data:
   - oiFitsGetLambda          : extract the waveEff table (in mum, so 10-6m)
   - oiFitsSetLambda          : put the waveEff table (in mum, so 10-6m)
   - oiFitsGetData            : extract the data (vis2, t3Phi...) from oiData
   - oiFitsSetData            : put the data into a single oiData
   - oiFitsSetDataArray       : put the data into multiple oiDatas
   - oiFitsCropAccuracy       : define a minimum values for the errors

   Manipulate data:
   - oiFitsAverageOiData      : average a set of conformable oiData
   - oiFitsGroupOiData        : find 'groups' and average the consecutives
                                oiData with oiFitsAverageOiData
                                
   Absolute Calibration
   - oiFitsLoadOiDiamFromCatalogs: extract diameter from catalogs.
   - oiFitsLoadOiDiamManual   : same but manual.
   - oiFitsWrite/ReadOiDiam   : write/read oiDiam structure into a FITS file.
   - oiFitsCalibrateDiam      : calibrate the oiVis2 from diameters
                                (called by oiFitsExtractTf)
   - oiFitsExtractTf          : extract and compute the TF-estimations
   - oiFitsApplyTf            : interpolate and apply the TF to all data
   - oiFitsCalibrateNight     : does all previous step in a raw, on oiVis2,
                                oiVis and oiT3, then store the results into
                                OIFITS files (one per insName, so it can
                                be read with readMode=1)

   Differential Calibration
   - oiFitsNormalizeContinuum : fit the continuum and force it at v2=1, phi=0
   - oiFitsCleanSocks         : apply a filter to data(lbd), along the
                                spectral direction, to remove "Moire" fringes

   
   Experimental:
   - oiFitsAddNoise
   - oiFitsSearchOiT3ForCompanion
   - oiFitsCleanDataFromDummy : clean the data so that they can be used
                                for the mira image reconstruction software.

   *** INSTRUMENT-RELATED FUNCTIONS ***

   - oiFitsDefaultReadLog     : read oiLog (instrument-related info)
   - oiFitsDefaultWriteLog    : write oiLog (instrument-related info)
   - oiFitsDefaultSetup       : get the instrumental setup of observation
   
   Look at the function oiFitsAmberSetup, oiFitsAmberReadLog and
   oiFitsAmberWriteLog if you want to create your own set of instrument
   related function.

   
   *** OIFITS STRUCTURES ***

   Semantic about structures:
   - oiStruct                 : generic name for oiVis, oiT3, oiVis2,
                                oiTarget, oiArray, oiWave, oiDiam, oiLog
   - oiData                   : generic name for oiVis, oiVis2, oiT3
   
   List of structures:
   - struct_oiArray           : standart, contains array info
   - struct_oiTarget          : standart, list all targets
   - struct_oiWavelength      : standart, wavelength table
   - struct_oiVis2            : standart, vis2 data points
   - struct_oiVis             : standart, complex-vis data points
   - struct_oiT3              : standart, closure-phase data points
   - struct_oiLog             : non-standar, additional observation info for 
                                instrument dependent info (dit, p2vmid,...)
   - struct_oiDiam            : non-standart, additional target info (diam,...)

   
   *** FUNCTIONS FOR ADVANCE USERS ***
   
   Extract/Manipulate oiData:
   - oiFitsGetStructData
   - oiFitsOperandStructData

   Test:
   - oiFitsIsOiData
   - oiFitsIsOiVis2
   - oiFitsIsOiVis
   - oiFitsIsOiT3
   - oiFitsIsOiArray
   - oiFitsIsOiTarget
   - oiFitsIsOiWave

   Other simple manipulation:
   - oiFitsReshape
   - oiFitsClean
   - oiFitsCleanUnused
   - oiFitsCleanFlag
   - oiFitsGrowArrays
   - oiFitsAverageData
   - oiFitsAverageSample

   REQUIRE
   - yoco.i
   - cfitsioPlugin.i (could probably be hacked to work with fits2.i)
   Both packages are included in amdlib.i

   List of comptemplated improvements and known bugs:
    
   FIXME: BUG: Telescope name should contain more than 1 letter, otherwise
          it gives an error while reading (bug in cfitsioPlugin, to be fixed).
          
   FIXME: units are currently not written.
   
   FIXME: oiLog are currently not written.

   VERSION
   
   AUTHORS                                  
   - jean-baptiste.lebouquin@obs.ujf-grenoble.fr
*/
  {
    local version;
    
    version = strpart(strtok("$Revision: 1.50 $",":")(2),2:-2);
    if (am_subroutine())
    {
        write, format="package version: %s\n", version;
        help, oiFitsUtils;
    }
    
    return version;
}

/* This package is mandatory */
require,"yoco.i";
require,"cfitsioPlugin.i";
require,"ieee.i";

yocoLogInfo, "oiFitsUtils package loaded";


local struct_oiTarget, struct_oiArray, struct_oiWavelength;
local struct_oiVis2, struct_oiT3, struct_oiVis;
local struct_oiLog, struct_oiDiam;
/* DOCUMENT structures defined in 'oiFitsUtils.i'

   DESCRIPTION
    Structure containing interferometric data:
    - struct_oiVis2
    - struct_oiVis
    - struct_oiT3
   
    Structure containing observational info:
    - struct_oiTarget
    - struct_oiWavelength
    - struct_oiArray

    Other structures:
    - struct_oiLog:
      Non standart structure to store additional information about
      the observation setup and content. This is filled by an
      instrument-dependent routine.

    - oiDiam:
      Non standart structure to store additional information
      about the target, such as diameter, and a flag coding is the
      target should be used as calibrator.

   SEE ALSO: oiFitsUtils.i
*/

struct struct_oiDiam {
  int    targetId;          // same id as in oiTarget.targetId
  double diam;              // target diameter in (mas)
  double diamErr;           // error on the diameter
  double Hmag, Kmag, Vmag;  // magnitudes
  long   isCal;             // 1 if the target should be used as calibrator
  string target;
  string info;
};

struct struct_oiLog {
  long     logId;           // for referencing with other Structures
  string   fileName;        // name of the OIFITS file
  string   orgFileName;     
  string   dateObs;         // ESO keyword
  double   dit;             // ESO keyword
  long     ndit;            // ESO keyword
  long     nditSkip;        // ESO keyword
  long     nrow;            // ESO keyword
  string   insMode;         // ESO keyword
  string   objName;         // ESO keyword
  string   obsName;         // ESO keyword
  long     tplNo;           // ESO keyword
  long     ObsId;           // ESO keyword
  long     p2vmId;          // ESO keyword
  string   dprType;         // ESO keyword
  string   dprCatg;         // ESO keyword
  string   proCatg;         // ESO keyword         
  double   ra, dec, lst;    // ESO keyword
  double   alt, az;         // ESO keyword
  string   ftSensor;        // ESO keyword
  string   opdcAlgoType;    // ESO keyword
  double   delFntPhaRmsCh1; // ESO keyword
  double   delFntPhaRmsCh2; // ESO keyword
  double   delFntLockCh1;   // ESO keyword
  double   delFntLockCh2;   // ESO keyword
  double   issFntDitCh1;    // ESO keyword
  double   issFntDitCh2;    // ESO keyword
  double   parangStart;     // ESO keyword
  double   parangEnd;       // ESO keyword
  double   airmassStart;    // ESO keyword
  double   airmassEnd;      // ESO keyword
  string   issStation1;     // ESO keyword
  string   issStation2;     // ESO keyword
  string   issStation3;     // ESO keyword
};

struct struct_oiArrayHdr {
  long     logId;           // Non standar: for referencing with oiLog
  string   arrName;         // Header:  (optional) corresponding OI_ARRAY
  string   frame;           // Header:
  double   arrayX;          // Header:
  double   arrayY;          // Header:
  double   arrayZ;          // Header:
};

struct struct_oiArray {
  struct_oiArrayHdr hdr;
  string   telName;         // -      8A 
  string   staName;         // -      8A 
  int      staIndex;        // -      I
  float    diameter;        // m      E
  double   staXYZ(3);       // m      3D
};

struct struct_oiTargetHdr {
  long     logId;           // Non standar: for referencing with oiLog
};

struct struct_oiTarget {
  struct_oiTargetHdr hdr;
  int      targetId;        // -      1I
  string   target;          // -      16A
  double   raEp0;           // deg    1D
  double   decEp0;          // deg    1D
  float    equinox;         // yr     1E
  double   raErr;           // deg    1D
  double   decErr;          // deg    1D
  double   sysVel;          // m/s    1D
  string   velTyp;          // -      8A
  string   velDef;          // -      8A
  double   pmRa;            // deg/yr 1D
  double   pmDec;           // deg/yr 1D
  double   pmRaErr;         // deg/yr 1D
  double   pmDecErr;        // deg/yr 1D
  float    parallax;        // deg    1E
  float    paraErr;         // deg    1E
  string   specTyp;         // -      16A
};

struct struct_oiWavelengthHdr {
  long     logId;           // Non standar: for referencing with oiLog
  string   insName;         // Header: Name of detector, for cross-referencing
};  

struct struct_oiWavelength {
  struct_oiWavelengthHdr hdr;
  float      effWave;       // m      E array
  float      effBand;       // m      E array
}
  
struct struct_oiVis2Hdr {
  long     logId;           // Non standar: for referencing with oiLog
  string   insName;         // Header:  corresponding OI_WAVELENGTH table
  string   arrName;         // Header:  (optional) corresponding OI_ARRAY
  string   dateObs;         // Header:  UTC start date of observations
};

struct struct_oiVis2 {
  struct_oiVis2Hdr hdr;
  int      targetId;        // -    1I
  double   time;            // s    1D
  double   mjd;             // day  1D
  double   intTime;         // s    1D
  double   vis2Data;        // -    D array
  double   vis2Err;         // -    D array
  double   uCoord;          // m    1D
  double   vCoord;          // m    1D
  int      staIndex(2);     // -    2I
  char     flag;            // -    1L array
};

struct struct_oiT3Hdr {
  long     logId;           // Non standar: for referencing with oiLog
  string   insName;         // Header:  corresponding OI_WAVELENGTH table
  string   arrName;         // Header:  (optional) corresponding OI_ARRAY
  string   dateObs;         // Header:  UTC start date of observations
};

struct struct_oiT3 {
  struct_oiT3Hdr hdr;
  int      targetId;        // -    1I
  double   time;            // s    1D
  double   mjd;             // day  1D
  double   intTime;         // s    1D
  double   t3Amp;           // -    D array
  double   t3AmpErr;        // -    D array
  double   t3Phi;           // -    D array
  double   t3PhiErr;        // -    D array
  double   u1Coord;         // m    1D
  double   v1Coord;         // m    1D
  double   u2Coord;         // m    1D
  double   v2Coord;         // m    1D
  int      staIndex(3);     // -    3I
  char     flag;            // -    1L array
};

struct struct_oiVisHdr {
  long     logId;           // Non standar: for referencing with oiLog
  string   insName;         // Header:  corresponding OI_WAVELENGTH table
  string   arrName;         // Header:  (optional) corresponding OI_ARRAY
  string   dateObs;         // Header:  UTC start date of observations
};

struct struct_oiVis {
  struct_oiVisHdr hdr;
  int      targetId;        // -      1I
  double   time;            // s      1D
  double   mjd;             // day    1D
  double   intTime;         // s      1D
  complex  visData;         // -      C array
  complex  visErr;          // -      C array
  double   visAmp;          // -      D array
  double   visAmpErr;       // -      D array
  double   visPhi;          // -      D array
  double   visPhiErr;       // -      D array
  double   uCoord;          // m      1D
  double   vCoord;          // m      1D
  int      staIndex(2);     // -      2I
  char     flag;            // -      1L array
};

local table_oiFitsMemberName;
table_oiFitsMemberName =
  [["effWave",      "EFF_WAVE",  "m"],
   ["effBand",      "EFF_BAND",  "m"],
   ["intTime",      "INT_TIME",  "s"],
   ["time",         "TIME",      "s"],
   ["mjd",          "MJD",       "d"],
   ["staName",      "STA_NAME",  ""],
   ["staIndex",     "STA_INDEX", ""],
   ["targetId",     "TARGET_ID", ""],
   ["telName",      "TEL_NAME",  ""],
   ["sysVel",       "SYSVEL",    "m/s"],
   ["raEp0",        "RAEP0",     "deg"],
   ["decEp0",       "DECEP0",    "deg"],
   ["raErr",        "RA_ERR",    "deg"],
   ["decErr",       "DEC_ERR",   "deg"],
   ["pmRa",         "PMRA",      "deg/yr"],
   ["pmDec",        "PMDEC",     "deg/yr"],
   ["pmRaErr",      "PMRA_ERR",  "deg/yr"],
   ["pmDecErr",     "PMDEC_ERR", "deg/yr"],
   ["paraErr",      "PARA_ERR",  "deg"],
   ["parallax",     "PARALLAX",  "deg"],
   ["equinox",      "EQUINOX",   "year"],
   ["diameter",     "DIAMETER",  "m"],
   ["staXYZ",       "STAXYZ",    "m"],
   ["uCoord",       "UCOORD",    "m"],
   ["vCoord",       "VCOORD",    "m"],
   ["u1Coord",      "U1COORD",   "m"],
   ["v1Coord",      "V1COORD",   "m"],
   ["u2Coord",      "U2COORD",   "m"],
   ["v2Coord",      "V2COORD",   "m"],
   ["visPhi",       "VISPHI",    "deg"],
   ["visPhiErr",    "VISPHIERR", "deg"],
   ["t3Phi",        "T3PHI",     "deg"],
   ["t3PhiErr",     "T3PHIERR",  "deg"],
   ["fluxRatio",    "FLUX_RATIO",  ""],
   ["fluxSum",      "FLUX_SUM",    ""],
   ["fluxProduct",  "FLUX_PRODUCT",""],
   ["fringeSnr",    "FRINGE_SNR",  ""],
   ["dateObs",      "DATE-OBS",    ""]];

/* -----------------------------------------------------------------------
   High level routines, load/write file
   ----------------------------------------------------------------------- */

func oiFitsListFiles(command,nols)
/* DOCUMENT files = oiFitsListFiles(path)

   DESCRIPTION
   Return the exact output of the shell command "ls" by
   using a pipe.

   WARNING
   This funciton only works if the shell command
   "ls" is set on the system.

   EXAMPLES
   > alldir  = oiFitsListFiles("~/*");
   > allinfo = oiFitsListFiles("-l ~/*.fits");

   SEE ALSO: popen
 */
{
  local liste;
  
  lscommand = "ls";
  if(nols) lscommand="";

  if(is_void(commande)) commande="";
  
  liste = rdline(popen(lscommand+" "+string(command),0),20000);
  liste = liste(where(liste != string(0)));
  
  return liste;
}

/* -- */

func oiFitsFixFlagArray(&oiData)
/* DOCUMENT oiFitsFixFlagArray(&oiData)

   DESCRIPTION
   Fix the flag array in case it has been written as a scalar while
   it should be an array.
 */
{
  yocoLogTrace,"oiFitsFixFlagArray()";
  local amp, flag;

  /* Loop on data */
  for (i=1;i<=numberof(oiData);i++) {

    /* Get data */
    oiFitsGetData, oiData(i), amp,,,,flag

    /* Check */
    if (numberof(flag) != numberof(amp) ) {
      yocoLogWarning,"Fix the FLAG array.";
      flag = array(flag(*)(1), dimsof(amp));
      oiFitsSetStructDataScalar, oiData, i, "flag", flag;
    }
  }
  
  yocoLogTrace,"oiFitsFixFlagArray done";
  return 1;
}


/* -- */

func oiFitsLoadFiles(files, &oiTarget, &oiWave, &oiArray, &oiVis2, &oiVis, &oiT3, &oiLog,
                     readMode=, clean=, funcLog=, append=, shell=)
/* DOCUMENT oiFitsLoadFiles(files, &oiTarget, &oiWave, &oiArray, &oiVis2,
                            &oiVis,&oiT3, &oiLog, readMode=, clean=, funcLog=,
                            append=, shell=)

   DESCRIPTION
     Load the content of one or more OI_FITS file(s) into yorick
     structures. If append=1, data are append to the current oiVis2,
     oiArray, oiT3.

     The important parameter READMODE defines how to deal with
     spectro-interferometric data set:
     
     - readMode = 0: assume all observations have **only one** spectral channel;
       the data arrays (vis2Data, t3PhiErr...) are defined as scalars.
       For instance:
       > dimsof(oiVis2(1).vis2Data) = [0];
       > dimsof(oiWave(1).effBand)  = [0];

     - readMode = 1 : assume all observation have the **same number** of
       spectral channels; the data arrays (vis2Data, t3PhiErr...) are defined
       as array of fixed length (the nb. of channels). For instance:
       > dimsof(oiVis2(1).vis2Data) = [1,120];
       > dimsof(oiWave(1).effBand)  = [1,120];

     - readMode = -1: can deal with observations made with **different numbers** of
       channels; the data arrays (vis2Data, t3PhiErr...) are yorick pointers.
       For instance:
       > typeof( oiVis2(1).vis2Data ) = "pointer" 
       > dimsof( *oiVis2(1).vis2Data ) = [1,12];
       > dimsof( *oiVis2(2).vis2Data ) = [1,109];

   NOTES
     Default is readMode=-1. 

     readMode=0 is not suported by all function, so it should be avoid, you should
     prefer readMode=1 even if the data have only 1 spectral channel.

     readMode=-1 format is the most versatil, but also the most complicate to use
     since the complete dataset (oiVis2.vis2Data) is not an numerical array
     but a pointer array.

     Note that the two first format can deal with observations made at different
     wavelengths, only the **number** of spectral channels has to match.

   PARAMETERS
     - clean: if set to 0, the arrays are not cleaned (leave it to 1, the
       default)
     - funcLog= optional, default is oiFitsDefaultReadLog. Function to fill the
       oiLog structure, which is instrument dependent. You can create your own
       function to read specific data. It is called with syntax:
       oiLog = funcLog(filename)
     - shell=

   EXAMPLES
   > files = oiFitsListFiles("/mydata/AMBER*fits");
   > oiFitsLoadFiles, files, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3;

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsLoadFiles()";
  local _oiTarget, _oiWave, _oiVis2, _oiT3, _oiHdr, _oiArray, _oiVis, _oiLog;
  local iMax;

  /* If append if nil, we
     erase the current data */
  if (!append) {
    oiTarget = oiWave = oiVis2 = oiT3 = oiHdr = oiArray = oiVis = oiLog = [];
  } else {
    yocoLogInfo,"New data will be append to already loaded one.";
  }
 
  /* If "shell", this means the input is a ls command to load files.
     So list all the files by the mean of oiFitsListFiles */
  if (shell!=0) {
    command = files;
    for ( files = [], i=1 ; i<=numberof(command) ; i++ )
      grow, files, oiFitsListFiles(command(i));
  }

  /* If no files to be loaded */
  if ( numberof(files)<1 ) {
    yocoError,"No files specified";
    return 0;
  }
  

  /* Loop on the files */
  iMax = numberof(files);
  for ( i=1 ; i<=iMax ; i++ ) {

    /* if verbose */
    if (_yocoLogLevel>1)
    write,format="\r read file %i over %i",i,iMax;
    
    /* Load this file */
    oiFitsLoadFile, files(i), _oiTarget, _oiWave, _oiArray, _oiVis2, _oiVis, _oiT3, _oiLog,
      readMode=readMode,funcLog=funcLog;

    /* Check the compatibibility */
    if ((i>1) && (structof(_oiWave)!=structof(oiWave))) {
      yocoLogWarning,"Number of spectral-bins incompatible with previous files"+
        "(use readMode=-1 to read them all):",files(i)+" has not been loaded.";
      continue;
    }

    /* Check the compatibibility */
    if ( is_void(_oiWave) && is_void(_oiArray) && is_void(_oiTarget) &&
         is_void(_oiVis2) && is_void(_oiT3) && is_void(_oiVis)) {
      yocoLogInfo,"Following file does not contain OIFITS data:",files(i);
      continue;
    }

    /* Clean and setup the logId (which correpond to the file) */
    if (is_array(_oiTarget)) _oiTarget.hdr.logId = i;
    if (is_array(_oiWave))   _oiWave.hdr.logId = i;
    if (is_array(_oiVis2))   _oiVis2.hdr.logId = i;
    if (is_array(_oiVis) )   _oiVis.hdr.logId = i;
    if (is_array(_oiT3) )    _oiT3.hdr.logId = i;
    if (is_array(_oiLog) )   _oiLog.logId = i;
    
    /* Grow arrays */
    oiFitsGrowArrays, oiVis2, _oiVis2, oiT3, _oiT3,
      oiVis,  _oiVis, oiArray, _oiArray,
      oiWave, _oiWave, oiLog, _oiLog,
      oiTarget, _oiTarget;
    
    /* Partial clean */
    if (clean==2 && i%200==0) {
      oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
    }
  }

  /* Add a line */
  if (_yocoLogLevel>1)  write,"";

  /* Clean the arrays to avoid mutiple instance of the same elements
     in oiWave, oiTarget, oiArray and oiLog. This may be long but will
     fasten all other operations. Additionally, the spectral bins
     are re-sorted by increasing wavelength */
  if (clean!=0) {
    yocoLogInfo,"Clean arrays.";
    oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
    oiFitsSortWave, oiWave, oiVis2, oiVis, oiT3;
  }

  yocoLogTrace,"oiFitsLoadFiles done";
  return 1;
}

/* -- */

func oiFitsLoadFile(file, &oiTarget, &oiWave, &oiArray, &oiVis2, &oiVis, &oiT3, &oiLog,
                    readMode=,funcLog=)
/* DOCUMENT oiFitsLoadFile(file, &oiTarget, &oiWave, &oiArray, &oiVis2, &oiVis,
                                 &oiT3, &oiLog, readMode=,funcLog=)

   DESCRIPTION
     Load a single OI_FITS file, see 'oiFitsLoadFiles' for
     instruction on how to use it.
 */
{
  yocoLogTrace,"oiFitsLoadFile()";

  /* Init and clean outputs */
  local fh,xte,i;
  oiTarget = oiWave = oiVis = oiVis2 = oiArray = oiT3 = oiLog = [];
  
  /* catch possible errors */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    yocoError, "Failure reading OIFITS file";
    return 0;
  }

  /* Read the log, by default as an AMBER log */
  if ( is_void(funcLog) ) funcLog = oiFitsDefaultReadLog;
  oiLog = funcLog(file);

  /* load the file */
  if(typeof(file) == "string")   fh = cfitsio_open(file);
  else                           fh = file;

  /* number of HDU */
  nHdu = cfitsio_get_num_hdus(fh);

  /* get the size of lambda, if not specfied or 1 */
  if ( is_void(readMode) ) readMode=-1;
  if ( readMode==1 ) readMode = oiFitsFoundNRows(fh);
  
  /* loop on HDUs */
  for(i=2;i<=nHdu;i++) {
    cfitsio_goto_hdu,fh,i;
    xte = cfitsio_get(fh,"EXTNAME");
    
    if(xte == "OI_TARGET" ) {
      grow, oiTarget, oiFitsLoadOiTable(fh,struct_oiTarget);   
    }
    else if(xte == "OI_ARRAY" ) {
      grow, oiArray, oiFitsLoadOiTable(fh, struct_oiArray);   
    }   
    else if(xte == "OI_WAVELENGTH" || xte == "OI_WAVELENGTH_FT") {
      grow, oiWave, oiFitsLoadWaveTable(fh, readMode);
    }   
    else if(xte == "OI_VIS2" || xte == "OI_VIS2_FT") {
      grow, oiVis2, oiFitsLoadOiTable(fh, oiFitsGetOiStruct("oiVis2", readMode) );   
    }
    else if(xte == "OI_VIS" || xte == "OI_VIS_FT") {
      grow, oiVis,  oiFitsLoadOiTable(fh, oiFitsGetOiStruct("oiVis", readMode) );   
    }
    else if(xte == "OI_T3" || xte == "OI_T3_FT") {
      grow, oiT3,  oiFitsLoadOiTable(fh, oiFitsGetOiStruct("oiT3", readMode) );
    }
    else {
      yocoLogTest,"Find "+xte+" -> skipped";
    }
  }

  /* Ensure the INSNAME is unique by using the first/last wavelength bins */
  oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;

  /* Fix the flag arrays */
  oiFitsFixFlagArray, oiVis2;
  oiFitsFixFlagArray, oiVis;
  oiFitsFixFlagArray, oiT3;

  /* close the file */
  if(typeof(file) == "string") cfitsio_close,fh;

  yocoLogTrace,"oiFitsLoadFile done";
  return 1;
}

/* --- */

func oiFitsWriteFiles(fileRoot, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog,
                      overwrite=, writeMode=, funcLog=)
/* DOCUMENT oiFitsWriteFiles(fileRoot, oiTarget, oiWave, oiArray, oiVis2,
                             oiVis, oiT3, oiLog,
                             overwrite=, writeMode=, funcLog=)

   DESCRIPTION
   Write the content of the oiStructures into one or several OIFITS file(s).
   See oiFitsWriteFile for writeMode explanation.
   
   PARAMETERS
   - writeMode=0 (default):
     Write all structure into a single file, keeping the appropriate
     index so that the cross-references remains valid.
     See oiFitsWriteFile for more explanation detail of the side effects.

   - writeMode=1:
     write each insName in a separated file.
     This has also the advantage of creating
     files that can be read entirely using 'readMode=1'
     Note that we write the log of the file corresponding to the oiWave
     (that is the log of the first file read with this insName)
 */
{
  yocoLogInfo,"oiFitsWriteFiles()";
  
  /* Default for parameters */
  local insName, id, w;
  if ( is_void(writeMode)) writeMode=0;
  if ( !yocoTypeIsStringScalar(fileRoot) ) return yocoError("fileRoot is not valid");

  if ( writeMode==1 ) {
    
    /* If writeMode==1, write each insName in a separated file,
       so loop on the insNames */
    insName = yocoListClean( oiWave.hdr.insName );
    for ( i=1 ; i<=numberof(insName) ; i++) {
      
      w = oiWave( where(oiWave.hdr.insName==insName(i)) );
      oiFitsWriteFile,
        fileRoot+"_"+yocoStrReplace(insName(i),[" ","/","(",")"],["_","-","",""])+".fits",
        oiTarget, w, oiArray,
        ( is_array(oiVis2) ? oiVis2( where(oiVis2.hdr.insName== insName(i)) ) : [] ),
        ( is_array(oiVis)  ? oiVis(  where(oiVis.hdr.insName == insName(i)) ) : [] ),
        ( is_array(oiT3)   ? oiT3(   where(oiT3.hdr.insName  == insName(i)) ) : [] ),
        ( is_array(oiLog)  ? oiFitsGetOiLog(w, oiLog) : []),
        overwrite=overwrite, funcLog=funcLog;
    }
    
  } else if ( writeMode==0 ) {

    if ( !strmatch(fileRoot,".fits") ) fileRoot = fileRoot + ".fits";
    /* Write everything into a single file */
    oiFitsWriteFile, fileRoot, oiTarget, oiWave, oiArray, oiVis2,
      oiVis, oiT3, oiLog, overwrite=overwrite, funcLog=funcLog;
    
  } else {
    return yocoError("This writeMode is not implemented yet.");
  }

  yocoLogTrace,"oiFitsWriteFiles done";
  return 1;
}

/* --- */

func oiFitsWriteFile(file, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog,
                     overwrite=, funcLog=,clean=)
/* DOCUMENT oiFitsWriteFile(file, oiTarget, oiWave, oiArray, oiVis2, oiVis,
                            oiT3, oiLog, overwrite=, funcLog= clean=)

   DESCRIPTION
     Experimental routine to write the content of the yorick structures into
     a single OI_FITS file. See oiFitsWriteFiles to produce a bunch of files.

     oiArray can contain stations from different arrays, each array will be
     written in a different table, with arrName written in the header, for
     cross-referencing as defined in the OI_FITS format.

     oiWave can be an array (so contain several insName), each of them will
     be written in a different table, with insName written in the header, for
     cross-referencing as defined in the OI_FITS format.

     The data structures (oiVis2, oiT3, oiVis) are written in differents tables
     homegeneous in header keywords: insName, arrName and dateObs.

     It is the responsability of the user to ensure the structures have been
     properly defined, and check they are homogeneous in cross-references.

   WARNING concerning the main header:
     Obvioulsy, only one main header can be written into a OIFITS file.
     This function writes the first log, that is oiLog(1). Therefore all
     other headers are lost in this operation. It is recomended to store
     with this function only data that are independent from an header, that
     are already calibrated.

   WARNING: the log is not writen anyway... because of a pb with cfitsio.
 */
{
  yocoLogTrace,"oiFitsWriteFile()";

  local fh,xte;
  if (is_void(clean)) clean = 1;
  if (is_void(overwrite)) overwrite = 1;

  /* catch possible errors */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    yocoError, "Error writing OIFITS file.";
    return 0;
  }

  /* if clean */
  if (clean) oiFitsCleanUnused,oiTarget,oiWave,oiArray,oiVis2,oiVis,oiT3,oiLog;

  /* Create the file */
  if (overwrite) remove,file;
  fh = cfitsio_open(file,"w");

  /* write all target in a raw */
  if ( is_array(oiTarget) )
    oiFitsWriteOiTable, fh, oiTarget, "OI_TARGET";

  /* write the wave in different tables */
  for ( i=1 ; i<=numberof(oiWave) ; i++)
    oiFitsWriteOiTable, fh, oiWave(i), "OI_WAVELENGTH";

  /* write the arrays in different tables */
  if ( is_array(oiArray) ) {
    id = yocoListUniqueId( oiArray.hdr.arrName );
    for ( i=1 ; i<=max(id) ; i++ )
      oiFitsWriteOiTable, fh, oiArray(where(id==i)), "OI_ARRAY";
  }

  /* write vis data in table homogeneous in header */
  if ( is_array(oiVis) ) {
    id = yocoListUniqueId( oiVis.hdr.arrName + oiVis.hdr.insName + oiVis.hdr.dateObs);
    for ( i=1 ; i<=max(id) ; i++ )
      oiFitsWriteOiTable, fh, oiVis(where(id==i)), "OI_VIS";
  }

  /* write vis2 data in table homogeneous in header */
  if ( is_array(oiVis2) ) {
    id = yocoListUniqueId( oiVis2.hdr.arrName + oiVis2.hdr.insName + oiVis2.hdr.dateObs);
    for ( i=1 ; i<=max(id) ; i++ )
      oiFitsWriteOiTable, fh, oiVis2(where(id==i)), "OI_VIS2";
  }

  /* write oiT3 data in table homogeneous in header */
  if ( is_array(oiT3) ) {
    id = yocoListUniqueId( oiT3.hdr.arrName + oiT3.hdr.insName + oiT3.hdr.dateObs);
    for ( i=1 ; i<=max(id) ; i++ )
      oiFitsWriteOiTable, fh, oiT3(where(id==i)), "OI_T3";
  }
  
  /* close the file */
  yocoLogTrace,"close the file";
  cfitsio_close,fh;
  
  /* FIXME: Write the log, default is write it with the AMBER function */
  if ( numberof(oiLog) == 1 ) {
    funcLog  = (is_void(funcLog) ? oiFitsDefaultWriteLog : funcLog);
    funcLog, file, oiLog(1);
  } else if ( numberof(oiLog) >1 ){
    yocoLogTrace, "Cannot write the log... several of them.";
  }

  yocoLogInfo,"Write file:",file;
  yocoLogTrace,"oiFitsWriteFile done";
  return 1;
}

func oiFitsWriteOiLog(file, oiLog, overwrite=)
/* DOCUMENT oiFitsWriteOiLog(file, oiLog, overwrite=)

   DESCRIPTION
   Write the oiLog structure into a FITS HDU table called OIU_LOG.

   PARAMETERS
   - file: FITS file name.
   - oiLog:
   - overwrite=1: remove existing file, otherwise append a new HDU table.
   
   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsWriteOiLog()";
  local fh;

  /* Catch possible errors when writting */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    remove,file;
    yocoLogWarning, "Cannot write the oiLog into a file.";
    return 0;
  }
  
  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file,"w",overwrite=overwrite) : file );
  
  /* Write the data */
  oiFitsWriteStructTable, fh, oiLog, "OIU_LOG";
  
  /* eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;
  
  yocoLogTrace,"oiFitsWriteOiLog done";
  return 1;
}

func oiFitsReadOiLog(file, &oiLog)
/* DOCUMENT oiFitsReadOiLog(file, oiLog, overwrite=)

   DESCRIPTION
   Read the oiLog structure from the FITS HDU table called OIU_LOG.

   PARAMETERS
   - file: FITS file name.
   - oiLog:
   
   SEE ALSO
*/
{
  yocoLogInfo,"oiFitsReadOiLog()";
  local fh;
  oiLog = [];

  /* Catch possible errors when writting */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    yocoLogWarning, "Cannot read the oiLog from file.";
    return 0;
  }
  
  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file,"r") : file );

  /* Read the data */
  cfitsio_goto_hdu, fh, "OIU_LOG";
  oiLog = oiFitsLoadStructTable( fh, struct_oiLog );
  
  /* eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;
  
  yocoLogTrace,"oiFitsReadOiLog done";
  return 1;
}

/* --- */

func oiFitsReshape(&oiVis2, &oiVis, &oiT3)
/* DOCUMENT oiFitsReshape(&oiVis2, &oiVis, &oiT3)

   DESCRIPTION
     Rehape the dimension of the oiFitss from
     [1, nbObs x nbBase] into [2, nbObs, nBase].

   CAUTIONS
     Better to not use this function since an oiData with more
     than one dimension may not be compliant with others routines
     of this package.

     To manage the different baseline, use the functions:
     - oiFitsGetBaseId: give a unique Id per baseline
     - oiFitsGetObsId: give a unique Id per observation

   PARAMETERS
     - oiVis2, oiVis2, oiT3: oiData to be reshaped
 */
{
  yocoLogTrace,"oiFitsReshape()";

  /* reshape the oiVis2 */
  if (is_array(oiVis2) ) {
    baseId = oiFitsGetBaseId(oiVis2);
    baseNb = numberof( yocoListClean(baseId) );
    if ( numberof(oiVis2)%baseNb ) return yocoError("oiVis2 has a wrong number of element to do a reshape");
    oiVis2 = oiVis2( msort(baseId, oiVis2.hdr.logId) );
    oiVis2 = reform (oiVis2, [2, numberof(oiVis2)/baseNb, baseNb]);
  }
  /* reshape the oiVis */
  if (is_array(oiVis) ) {
    baseId = oiFitsGetBaseId(oiVis);
    baseNb = numberof( yocoListClean(baseId) );
    if ( numberof(oiVis)%baseNb ) return yocoError("oiVis has a wrong number of element to do a reshape");
    oiVis = oiVis( msort(baseId, oiVis.hdr.logId) );
    oiVis = reform (oiVis, [2, numberof(oiVis)/baseNb, baseNb]);
  }
  /* reshape the oiT3 */
  if (is_array(oiT3) ) {
    baseId = oiFitsGetBaseId(oiT3);
    baseNb = numberof( yocoListClean(baseId) );
    if ( numberof(oiT3)%baseNb ) return yocoError("oiT3 has a wrong number of element to do a reshape");
    oiT3 = oiT3( msort(baseId, oiT3.hdr.logId) );
    oiT3 = reform (oiT3, [2, numberof(oiT3)/baseNb, baseNb]);    
  }

  yocoLogTrace,"oiFitsReshape done";
  return 1;
}

/* --- */

func oiFitsKeepFlaggedWorker(f1,f2)
{
 ok = array(0, dimsof(f1));
 for (i = 1; i <= numberof(f1); ++i)
 {
   ok(i) = anyof(f1(i) == f2);
 }
 id = where(ok);
 return id;
}


func oiFitsKeepFlagged(&oiData, oiWave, oiArray, oiTarget, oiLog)
{
  yocoLogTrace,"oiFitsKeepFlagged()";
  local isOK,n0;
  n0 = numberof(oiData);

  /* Already void */
  if ( n0==0 ) return 1;

  /* Keep only the oiData with associated oiInfo */
  if ( is_array(oiData) & is_array(oiWave) )
    oiData = oiData(*)( oiFitsKeepFlaggedWorker(oiData.hdr.insName, oiWave.hdr.insName) );

  if ( is_array(oiData) & is_array(oiTarget) )
    oiData = oiData(*)( oiFitsKeepFlaggedWorker(oiData.targetId, oiTarget.targetId) );

  if ( is_array(oiData) & is_array(oiLog) )
    oiData = oiData(*)( oiFitsKeepFlaggedWorker(oiData.hdr.logId, oiLog.logId) );

  if ( is_array(oiData) & is_array(oiArray) ) {
    isOK = ( ( (oiData.staIndex(,-,) == oiArray.staIndex(-,))(,sum,) )(min,)>0 );
    oiData = oiData(*)( where( isOK) );
  }
  
  if ( is_array(oiData) & is_array(oiArray) )
  {
    dat_sta = oiData.staIndex;
    arr_sta = oiArray.staIndex;
    oiData = oiData(*)( oiFitsKeepFlaggedWorker(dat_sta(1,), arr_sta) );
   if (is_array(oiData))
   {
     dat_sta = oiData.staIndex;
     oiData = oiData(*)( oiFitsKeepFlaggedWorker(dat_sta(2,), arr_sta) );
   }
  }

  

  /* Some verbose */
  if ( numberof(oiData) != n0 )
    yocoLogWarning,"Some "+oiFitsStructRoot(oiData)+" are not associated with oiArray, oiWave, oiTarget or oiLog.",
      "A total of "+pr1(n0-numberof(oiData))+" elements been removed";
      
  if ( is_void(oiData) )
    yocoLogWarning,oiFitsStructRoot(oiData)+" is now void."

  yocoLogTrace,"oiFitsKeepFlagged done";
  return 1;
}

/* --- */

func oiFitsGrowArrays(&oiVis2, _oiVis2, &oiT3, _oiT3,
                      &oiVis,  _oiVis, &oiArray, _oiArray,
                      &oiWave, _oiWave, &oiLog, _oiLog,
                      &oiTarget, _oiTarget)
/* DOCUMENT oiFitsGrowArrays(&oiVis2, _oiVis2, &oiT3, _oiT3,
                      &oiVis,  _oiVis, &oiArray, _oiArray,
                      &oiWave, _oiWave, &oiLog, _oiLog)

   DESCRIPTION
   Grow the oiArrays with the elements of _oiArrays.
   The oiTarget.targetId, oiLog.logId, oiArray.staIndex
   are updated to avoid conflicts.
*/
{
    yocoLogTrace,"oiFitsGrowArrays()";
    
    /* Ensure a unique Target id */
    if (is_array(_oiTarget)) {
      addValue = (is_array(oiTarget) ? max(oiTarget.targetId) : 0) + 1; 
      _oiTarget.targetId += addValue;
      if(is_array(_oiVis2)) _oiVis2.targetId += addValue;
      if(is_array(_oiVis))  _oiVis.targetId  += addValue;
      if(is_array(_oiT3))   _oiT3.targetId   += addValue;
    }
    
    /* Ensure a unique Log Id */
    if (is_array(_oiLog)) {
      addValue = (is_array(oiLog) ? max(oiLog.logId) : 0) + 1;
      _oiLog.logId = _oiLog.logId + addValue;
      if(is_array(_oiT3))     _oiT3.hdr.logId     += addValue;
      if(is_array(_oiVis))    _oiVis.hdr.logId    += addValue;
      if(is_array(_oiVis2))   _oiVis2.hdr.logId   += addValue;
      if(is_array(_oiTarget)) _oiTarget.hdr.logId += addValue;
      if(is_array(_oiArray))  _oiArray.hdr.logId  += addValue;
      if(is_array(_oiWave))   _oiWave.hdr.logId   += addValue;
    }

    /* Ensure a unique staIndex */
    if(is_array(_oiArray))  {
      addValue = (is_array(oiArray) ? max(oiArray.staIndex) : 0) + 1; 
      _oiArray.staIndex += addValue;
      if(is_array(_oiVis2))   _oiVis2.staIndex  += addValue;
      if(is_array(_oiVis))    _oiVis.staIndex   += addValue;
      if(is_array(_oiT3))     _oiT3.staIndex    += addValue;
    }
    
    /* Grow the arrays */
    if(is_array(_oiVis2))  grow, oiVis2,   _oiVis2;
    if(is_array(_oiT3))    grow, oiT3,     _oiT3;
    if(is_array(_oiVis))   grow, oiVis,    _oiVis;
    if(is_array(_oiWave))  grow, oiWave,   _oiWave;
    if(is_array(_oiLog))   grow, oiLog,    _oiLog;
    if(is_array(_oiArray)) grow, oiArray,  _oiArray;
    if(is_array(_oiTarget))grow, oiTarget, _oiTarget;

    yocoLogTrace,"oiFitsGrowArrays done";
    return 1;
}

/* --- */

func oiFitsCleanFlag(&oiVis2, &oiVis, &oiT3)
/* DOCUMENT oiFitsCleanFlag(&oiVis2, &oiVis, &oiT3)

   DESCRIPTION
   Remove observations where the flag!=char(0) for all spectral bin.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogTrace,"oiFitsCleanFlag()";
  local i, id, flag;
  
  if (is_array(oiVis2)) {
    for (id=[],i=1;i<=numberof(oiVis2);i++) {
      oiFitsGetData, oiVis2(i), ,,,,flag;
      if ( anyof(flag == char(0)) ) grow, id, i;
    }
    id = (is_array(id) ? id : where());
    oiVis2 = oiVis2(id);
  }

  if (is_array(oiVis)) {
    for (id=[],i=1;i<=numberof(oiVis);i++) {
      oiFitsGetData, oiVis(i), ,,,,flag;
      if ( anyof(flag == char(0)) ) grow, id, i;
    }
    id = (is_array(id) ? id : where());
    oiVis = oiVis(id);
  }
  
  if (is_array(oiT3)) {
    for (id=[],i=1;i<=numberof(oiT3);i++) {
      oiFitsGetData, oiT3(i), ,,,,flag;
      if ( anyof(flag == char(0)) ) grow, id, i;
    }
    id = (is_array(id) ? id : where());
    oiT3 = oiT3(id);
  }

  yocoLogTrace,"oiFitsCleanFlag()";
  return 1;
}

/* --- */

func oiFitsAlignTargetName(&oiTarget)
/* DOCUMENT oiFitsAlignTargetName(&oiTarget)

   DESCRIPTION
   Align the target name stored in oiTarget.target
   with some default specification.
   HD-XXX -> HDXXX
   HD_XXX -> HDXXX
   HIP_XXX -> HIPXXX
   HIP-XXX -> HIPXXX

   After calling oiFitsAlignTargetName', you may want to call
   oiFitsClean to remove duplicates.

   EXAMPLES:
   > oiFitsLoadFiles,files,oiTarget,oiWave,oiArray,oiVis2,,oiT3,oiLog;
   > oiFitsAlignTargetName, oiTarget;
   > oiFitsClean,oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;

   SEE ALSO
 */
{
  // Loop on target
  for (i=1;i<=numberof(oiTarget);i++)
  {
    target = oiTarget(i).target;
    if ( strglob("HD [0-9]*",target) ) {
      new = "HD"+strpart(target,4:);
      yocoLogInfo,"Replace "+target+" by "+new;
      oiTarget(i).target = new;
    }

    target = oiTarget(i).target;
    if ( strglob("HD_[0-9]*",target) ) {
      new = "HD"+strpart(target,4:);
      yocoLogInfo,"Replace "+target+" by "+new;
      oiTarget(i).target = new;
    }

    if ( strglob("HD-[0-9]*",target) ) {
      new = "HD"+strpart(target,4:);
      yocoLogInfo,"Replace "+target+" by "+new;
      oiTarget(i).target = new;
    }

    if ( strglob("HIP [0-9]*",target) ) {
      new = "HIP"+strpart(target,5:);
      yocoLogInfo,"Replace "+target+" by "+new;
      oiTarget(i).target = new;
    }
    
    if ( strglob("HIP_[0-9]*",target) ) {
      new = "HIP"+strpart(target,5:);
      yocoLogInfo,"Replace "+target+" by "+new;
      oiTarget(i).target = new;
    }
    
    if ( strglob("HIP-[0-9]*",target) ) {
      new = "HIP"+strpart(target,5:);
      yocoLogInfo,"Replace "+target+" by "+new;
      oiTarget(i).target = new;
    }
  }

  return 1;
}

/* --- */

func oiFitsClean(&oiTarget, &oiWave, &oiArray, &oiVis2, &oiVis, &oiT3, &oiLog)
/* DOCUMENT oiFitsClean( &oiTarget, &oiWave, &oiArray, &oiVis2, &oiVis,
                         &oiT3, &oiLog )

   DESCRIPTION
   Clean the oiTarget, oiArray and oiLog from redundant elements. Associated
   ids are also changed in the oiVis2, oiVis and oiT3 structures to match
   the new oiArray, oiTarget and oiLog ids.

   The oiTarget, oiArray and oiLog are sorted by increasing ids, and the ids
   should range 1..numberof(oiArray) for instance. So that one can use:
   > names = oiTarget.target ( oiVis2.targetId );

   CAUTIONS
    - assume 'oiTarget.target' is univoque amoung the whole oiTarget array.
    - assume 'oiLog.fileName' is univoque amoung the whole oiLog array.
    - assume 'oiArray.staName+oiArray.arrName' is univoque amoung the
      whole oiArray array.

   RETURN VALUES
   0/1
     
   SEE ALSO:
 */
{
  yocoLogTrace,"oiFitsClean()";
  local idInit, idNews, idClean;
  
  /* Clean the similar oiWave,
     according to the instrument name */
  if (numberof(oiWave)>1 ) {
    oiWave = yocoListClean(oiWave,oiWave.hdr.insName);
  }

  /* Remove oiData without any oiWave, or oiArray, or ... */
  yocoLogTrace,"Remove oiData without any oiWave, or oiArray, or oiLog.";
  oiFitsKeepFlagged, oiVis2, oiWave, oiArray, oiTarget, oiLog;
  oiFitsKeepFlagged, oiVis,  oiWave, oiArray, oiTarget, oiLog;
  oiFitsKeepFlagged, oiT3,   oiWave, oiArray, oiTarget, oiLog;
  
  if ( numberof(oiLog)>1 ) {
    yocoLogTrace,"Give the same logId to all the same fileName name.";
    idInit = oiLog.logId;
    idNews = yocoListUniqueId(oiLog.fileName);
    oiLog.logId  = idNews;
    if ( is_array(oiWave) )
      oiWave.hdr.logId = idNews( yocoListId(oiWave.hdr.logId, idInit) );
    if ( is_array(oiVis2) )
      oiVis2.hdr.logId = idNews( yocoListId(oiVis2.hdr.logId, idInit) );
    if ( is_array(oiVis) )
      oiVis.hdr.logId  = idNews( yocoListId(oiVis.hdr.logId,  idInit) );
    if ( is_array(oiT3) )
      oiT3.hdr.logId   = idNews( yocoListId(oiT3.hdr.logId,   idInit) );
    if ( is_array(oiTarget) )
      oiTarget.hdr.logId   = idNews( yocoListId(oiTarget.hdr.logId,   idInit) );
    /* Then clean the oiLog */
    idClean = yocoListClean(idNews);
    oiLog   = oiLog( yocoListId(idClean, idNews));
  }  

  if ( numberof(oiTarget)>1 ) {
    yocoLogTrace,"Give the same targetId to all the same target name.";
    idInit = oiTarget.targetId;
    idNews = yocoListUniqueId(oiTarget.target);
    oiTarget.targetId = idNews;
    if ( is_array(oiVis2) )
      oiVis2.targetId   = grow(-1, idNews)( yocoListId(oiVis2.targetId, idInit) +1 );
    if ( is_array(oiVis) )
      oiVis.targetId    = grow(-1, idNews)( yocoListId(oiVis.targetId,  idInit) +1 );
    if ( is_array(oiT3) )
      oiT3.targetId     = grow(-1, idNews)( yocoListId(oiT3.targetId,   idInit) +1 );
    /* Clean the oiTarget */
    idClean  = yocoListClean(idNews);
    oiTarget = oiTarget( yocoListId(idClean, idNews));
  }

  if ( numberof(oiArray)>1 ) {
    yocoLogTrace,"Give the same staIndex to all the same staName+arrName pairs.";
    idInit = oiArray.staIndex;
    idNews = yocoListUniqueId( oiArray.staName + "-" +oiArray.hdr.arrName );
    
    oiArray.staIndex  = idNews;
    if ( is_array(oiVis2) )
      oiVis2.staIndex = reform( idNews( yocoListId(oiVis2.staIndex(*), idInit) ), dimsof(oiVis2.staIndex) );
    if ( is_array(oiVis) )
      oiVis.staIndex  = reform( idNews( yocoListId(oiVis.staIndex(*),  idInit) ), dimsof(oiVis.staIndex)  );
    if ( is_array(oiT3) )
      oiT3.staIndex   = reform( idNews( yocoListId(oiT3.staIndex(*),   idInit) ), dimsof(oiT3.staIndex)   );
    /* Then clean the oiFits */
    idClean = yocoListClean(idNews);
    oiArray = oiArray( yocoListId(idClean, idNews) );
  }
  
  yocoLogTrace,"oiFitsClean done";
  return 1;
}

// func oiFitsCleanFlag(&oiVis2, &oiVis, &oiT3)
// {
//   yocoLogTrace,"oiFitsCleanFlag()";
//   if (is_array(oiVis))
//   for (i=1 ; i<= numberof(oiVis2) ; i++) {
//     oiFitsGetData, oiVis2(i), ,,,,flag;
//     if ( allof(*oiVis2(1).flag == char(0)) ) grow, id, i;
//   }
//   yocoLogTrace,"oiFitsCleanFlag done";
//   return 1;
// }

func oiFitsCleanUnused(&oiTarget, &oiWave, &oiArray, &oiVis2,
                       &oiVis, &oiT3, &oiLog)
/* DOCUMENT oiFitsCleanUnused(&oiTarget, &oiWave, &oiArray,
                              &oiVis2, &oiVis, &oiT3, &oiLog)

   DESCRIPTION
   Clean oiTarget, oiWave, oiArray, oiT3 from unused elements, that means
   remove elements that not cross-referenced in oivis2, oiVis, oiT3.

   PARAMETERS
   - all parameters are optionals.

   EXAMPLES
   > oiFitsCleanUnused, oiTarget, , , oiVis2, oiVis;

   SEE ALSO
 */
{
  yocoLogTrace,"oiFitsCleanUnused()";
  local i,lst;
  
  /* Clean unused oiTarget */
  if ( is_array(oiTarget) ) {
    yocoLogTrace,"oiFitsCleanUnused oiTarget";
    lst = [];
    if ( is_array(oiVis2) ) grow, lst, oiVis2.targetId;
    if ( is_array(oiVis) )  grow, lst, oiVis.targetId;
    if ( is_array(oiT3) )   grow, lst, oiT3.targetId;
    lst = oiFitsGetId( oiTarget.targetId, yocoListClean(lst) );
    oiTarget = oiTarget( where(lst) );
  }

  /* Clean unused oiWave */
  if ( is_array(oiWave) ) {
    yocoLogTrace,"oiFitsCleanUnused oiWave";
    lst = [];
    if ( is_array(oiVis2) ) grow, lst, oiVis2.hdr.insName;
    if ( is_array(oiVis) )  grow, lst, oiVis.hdr.insName;
    if ( is_array(oiT3) )   grow, lst, oiT3.hdr.insName;
    lst = oiFitsGetId( oiWave.hdr.insName, yocoListClean(lst) );
    oiWave = oiWave( where(lst) );
  }
  
  /* Clean unused oiLog */
  if ( is_array(oiLog) ) {
    yocoLogTrace,"oiFitsCleanUnused oiLog";
    lst = [];
    if ( is_array(oiVis2) )   grow, lst, oiVis2.hdr.logId;
    if ( is_array(oiVis) )    grow, lst, oiVis.hdr.logId;
    if ( is_array(oiT3) )     grow, lst, oiT3.hdr.logId;
    if ( is_array(oiWave) )   grow, lst, oiWave.hdr.logId;
    if ( is_array(oiTarget) ) grow, lst, oiTarget.hdr.logId;
    lst = oiFitsGetId( oiLog.logId, yocoListClean(lst) );
    oiLog = oiLog( where(lst) );
  }

  /* Clean unused oiArray: remove unused arrName */
  if ( is_array(oiArray) ) {
    yocoLogTrace,"clean oiArray";
    lst = [];
    if ( is_array(oiVis2) ) grow, lst, string(oiVis2.hdr.arrName);
    if ( is_array(oiVis) )  grow, lst, string(oiVis.hdr.arrName);
    if ( is_array(oiT3) )   grow, lst, string(oiT3.hdr.arrName);
    lst = oiFitsGetId( string(oiArray.hdr.arrName), yocoListClean(lst) );
    oiArray = oiArray( where(lst) );
  }

  yocoLogTrace,"oiFitsCleanUnused done";
  return 1;
}

/* ----------------------------------------------------------------------
   Structure manipulation: found members, read/write
   ---------------------------------------------------------------------- */

func oiFitsConvertOiMemberToFile(name, tab, &units)
/* DOCUMENT oiFitsConvertOiMemberToFile(name, tab, &units)

   DESCRIPTION
     Convert the 'name' from member names of the oiStructures
     to the associated names in the OIARRAY files (header keyname
     of binary table column name).

     Tab is an optional string array:
     - 1 column = structure member name
     - 2 column = name in the OIARRAY file (in header or in bintable titles)
     - 3 column = units
 */
{
  local out, id, idOk, tmp;
  units = [];

  /* Default tab allows to read the standart OIFITS information
     from standar headers */
  if ( is_void(tab) ) {
    tab = table_oiFitsMemberName;
  } else if ( structof(tab)!=string && dimsof(tab)(1)!=2 ) {
    return yocoError("specified TAB is not a valid string array.");
  }

  /* found the match */
  out   = name;
  units = array("",dimsof(name));
  id   = yocoListId(out, tab(1,));
  idOk = where(id!=0);

  /* replace if some convertion founded */
  if (numberof(idOk)>0 ) {
    out(idOk)   = tab(2,id(idOk));
    units(idOk) = tab(3,id(idOk));
  }
  
  /* put anyway in upper cases */
  out  = strcase(1, out);
  
  return out;
}

/* --- */

func oiFitsLoadOiHdr(fh, strType, tab)
/* DOCUMENT oiFitsLoadOiHdr(fh, strType, tab)

   DESCRIPTION
     Load the structure elements strType from the header of the FITS ADU fh.
     Name into the structure and into the file will be matched using
     the function 'oiFitsConvertOiMemberToFile'. The latter use an
     optional argument 'tab' which you can specify here.
     Return the filled structure.

   PARAMETERS
     - fh: open FITS file, at the correct ADU
     - strType: sturcture definition, as return by structof(XX)
 */
{
  yocoLogTrace,"oiFitsLoadOiHdr()";
  local name, type, nameUpper, i;

  /* get the element name and types */
  oiFitsStrReadMembers, strType(), name, type;
  outStr = strType();
  
  /* convert the structure names into file names */
  nameUpper = oiFitsConvertOiMemberToFile(name,tab);

  /* loop in the structure */
  for ( i=1 ; i<=numberof(name) ; i++ ) {

    /* check if found in the header */
    if ( typeof((tmp=cfitsio_get(fh,nameUpper(i)))) == type(i) ) {
      yocoLogTest,"found in header: "+name(i);

      /* if the read parameter is char,
         suppose this is a 'logical' keyword */
      if( structof(tmp)==char ) {
        tmp(*) = [char(1),char(0)]( 1+(tmp(*)=='F'));
      }

      /* put it */
      get_member(outStr,name(i))(*) = tmp(*);
      
    } else {
      yocoLogTest,"not found: "+name(i);
    }
    
  }
  
  /* return the structure */
  yocoLogTrace,"oiFitsLoadOiHdr done";
  return outStr;
}

/* --- */

func oiFitsFoundNRows(fh)
{
  yocoLogTrace,"oiFitsFoundNRows()";
  local nrows;
  
  /* Found the readMode */
  cfitsio_goto_hdu, fh, "OI_WAVELENGTH";
  nrows = cfitsio_get(fh, "NAXIS2");
  
  yocoLogTrace,"oiFitsFoundNRows done";
  return nrows;
}

/* --- */

func oiFitsLoadWaveTable(fh, readMode)
/* DOCUMENT oiFitsLoadWaveTable(fh, readMode)

   DESCRIPTION
     Load the current ADU of FITS file fh as a OI_WAVELENGTH array.
     The header and data are returned as a struct_oiWavelength
     structure. The data array of this structure are scalar/array/pointers
     depending on the readMode keyword (see oiFitsLoadFiles).
 */
{
  yocoLogTrace,"oiFitsLoadWaveTable()";

  /* Prepare the output */
  local outStr, Bin;
  outStr = oiFitsGetOiStruct("oiWavelength", readMode)();

  /* Load the header */
  outStr.hdr = oiFitsLoadOiHdr(fh, outStr(1).hdr );

  /* Load the data */
  Bin = cfitsio_read_bintable(fh,Tit);

  /* Put them in the structure */
  if (readMode < 0) {
    outStr.effWave = & ( float( *Bin(where(Tit=="EFF_WAVE")(1)) ));
    outStr.effBand = & ( float( *Bin(where(Tit=="EFF_BAND")(1)) ));
  } else if (readMode ==0 ) {
    outStr.effWave = float( *Bin(where(Tit=="EFF_WAVE")(1)) )(1);
    outStr.effBand = float( *Bin(where(Tit=="EFF_BAND")(1)) )(1);
  } else {
    outStr.effWave = float( *Bin(where(Tit=="EFF_WAVE")(1)) );
    outStr.effBand = float( *Bin(where(Tit=="EFF_BAND")(1)) );
  }
  
  yocoLogTrace,"oiFitsLoadWaveTable done";
  return outStr;
}

/* --- */

func oiFitsLoadOiTable(fh, strType, noload)
/* DOCUMENT oiFitsLoadOiTable(fh, strType, noload)

   DESCRIPTION
     Load the current ADU of FITS file fh into a structure of type strType.
     ADU and strType should match (OI_VIS2 and struct_oiVis2...).
     The structure can have data array of type scalar/array/pointers
     (see oiFitsLoadFiles), the data will be converted accordingly.

     If noload==1, only the header is readed.
 */
{
  yocoLogTrace,"oiFitsLoadOiTable()";
  local outStr, outHdr, n, e, name, Bin, Tit, type, nrow;
  local strName, i, tmp, nameUpper, l;

  /* get the element name and types */
  oiFitsStrReadMembers, strType(), name, type, strName;

  /* read the OI_TABLE */
  Bin = cfitsio_read_bintable(fh,Tit);

  /* get number of ligne and construct the output structure
     expect for oiWavelength... */
  nrow = numberof(*Bin(1));
  outStr = array(strType,nrow);

  /* Read the header if any */
  if ( anyof(name == "hdr") ) {
    outStr.hdr = oiFitsLoadOiHdr(fh, outStr(1).hdr );
  }

  /* convert the structure names into file names */
  nameUpper = oiFitsConvertOiMemberToFile(name);
  
  /* loop in the structure */
  for ( i=1 ; i<=numberof(name) ; i++ ) {
    local data;

    /* skip the fileName, the logId and the hdr members */
    if ( anyof(name(i)==["logId","hdr"]) ) continue;

    /* check if found in the data */
    if ( !noload  &&  numberof( (n=where(Tit==nameUpper(i)))) > 0 ) {
      yocoLogTest,name(i)+" found in "+Tit(n(1));

      /* Check if flag is really a char */
      if ( name(i)=="flag" ) {
        data = [char(1),char(0)]( 1+(*Bin(n(1))=="F"));
        if (__gravity__) data = [char(1),char(0)]( 1+(*Bin(n(1))!="F")); 
      } else {
        data = *Bin(n(1));
      }

      /* put the data with dedicated function */
      _ofSSDa, outStr, ,name(i), data;
    } else {
      yocoLogTest,"not found: "+name(i);
    }
  }
  
  /* return the structure */
  yocoLogTrace,"oiFitsLoadOiTable done";
  return outStr;
}

/* --- */

func oiFitsWriteOiHdr(fh, hdr, tab)
/* DOCUMENT oiFitsWriteOiHdr(fh, hdr, tab)

   DESCRIPTION
     Write the structure elements hdr into the header of the FITS ADU fh.
     Name into the structure and into the file will be matched using
     the function 'oiFitsConvertOiMemberToFile'
 */
{
  yocoLogTrace,"oiFitsWriteOiHdr()";
  local outStr, outHdr, n, e, name, Bin, Tit, type, nrow;
  local strName, i, tmp, nameUpper, units;

  /* get the element name and types */
  oiFitsStrReadMembers, hdr, name, type, strName;
  /* convert the structure names into file names */
  nameUpper = oiFitsConvertOiMemberToFile(name,tab, units);

  /* loop in the structure */
  for ( i=1 ; i<=numberof(name) ; i++ ) {
    /* skip the filename */
    if ( anyof(name(i)==["logId","fileName","hdr"]) ) continue;
    /* skip if pointer */
    if ( anyof(type(i)==["pointer","struct_instance"]) ) continue;
    /* write the value */
    cfitsio_set, fh, nameUpper(i), get_member(hdr,name(i)),,units(i);
  }
  
  yocoLogTrace,"oiFitsWriteOiHdr done";
  return 1;
}

/* --- */

func oiFitsWriteOiTable(fh, str, extname)
/* DOCUMENT oiFitsWriteOiTable(fh, str, extname)

   DESCRIPTION
     Can deal with both pointer/scalar/array oiData.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogTrace,"oiFitsWriteOiTable()";
  local n, e, name, Bin, Tit, type, nrow, tmp;
  local strName, i, tmp, tmp2, nameUpper, units, Units;

  Bin = Tit = [];

  /* get the element name and types */
  oiFitsStrReadMembers, str, name, type, strName;

  /* convert the structure names into file names */
  nameUpper = oiFitsConvertOiMemberToFile(name, , units);

  /* if oiWavelength */
  if ( strmatch(strName,"oiWavelength") ) {
    tmp   = oiFitsGetStructData(str,"effWave")(*);
    tmp2  = oiFitsGetStructData(str,"effBand")(*);
    Bin   = [&float(tmp), &float(tmp2)];
    Units = ["m", "m"];
    Tit   = ["EFF_WAVE","EFF_BAND"];
  }
  /* else simply loop in the structure members */
  else {

    /* if scalar, add a dimension */
    if ( yocoTypeIsScalar(str) ) str = [str];
    for ( i=1 ; i<=numberof(name) ; i++ ) {
      
      /* skip the fileName, the logId and the hdr members */
      if ( anyof(name(i)==["logId","fileName","hdr"]) ) continue;

      tmp = get_member(str,name(i));
      if ( typeof(tmp)=="pointer" ) {
        local j,dat;
        for (dat=[],j=1;j<=numberof(tmp);j++) {
          if ( is_array(*tmp(j)) ) grow,dat,[*tmp(j)];
        }
        tmp = dat;
      }
      if ( !is_array(tmp) ) continue;
      grow, Bin, &(tmp);
      grow, Tit, nameUpper(i);
      grow, Units, units(i);
    }
  }

  /* write the table */
  cfitsio_add_bintable,fh, Bin, Tit, Units, extname;
  cfitsio_set, fh, "OI_REVN", 1, "Revision number of the table definition";

  /* Write the header if any */
  if ( numberof((n=where(name=="hdr"))) ) {
    oiFitsWriteOiHdr, fh, str.hdr;
  }
  
  /* return the structure */
  yocoLogTrace,"oiFitsWriteOiTable done";
  return 1;
}

func oiFitsLoadStructTable(fh, strType)
/* DOCUMENT oiFitsLoadStructTable(fh, strType)

 */
{
  yocoLogTrace,"oiFitsLoadStructTable()";
  local outStr, outHdr, n, e, name, Bin, Tit, type, nrow;
  local strName, i, tmp, nameUpper, l;

  /* get the element name and types */
  oiFitsStrReadMembers, strType(), name, type, strName;

  /* read the OI_TABLE */
  Bin = cfitsio_read_bintable(fh,Tit);

  /* get number of ligne and construct the output structure
     expect for oiWavelength... */
  nrow = numberof(*Bin(1));
  outStr = array(strType,nrow);

  /* convert the structure names into file names */
  nameUpper = oiFitsConvertOiMemberToFile(name);
  
  /* loop in the structure */
  for ( i=1 ; i<=numberof(name) ; i++ ) {
    local data;

    /* check if found in the data */
    if ( numberof( (n=where(Tit==nameUpper(i)))) > 0 ) {
      yocoLogTest,name(i)+" found in "+Tit(n(1));
      
      data = *Bin(n(1));

      /* eventually convert the logical that have been read as string */
      if ( type(i)=="char" && structof(data)==string) {
        data = [char(1),char(0)]( 1+(data=="F") );
      }
      
      /* put the data with dedicated function */
      _ofSSDa, outStr, ,name(i), data;
    } else {
      yocoLogTest,"not found: "+name(i);
    }
  }
  
  /* return the structure */
  yocoLogTrace,"oiFitsLoadStructTable done";
  return outStr;
}

func oiFitsWriteStructTable(fh, str, extname)
/* DOCUMENT oiFitsWriteStructTable(fh, str, extname)

   DESCRIPTION
     Can deal with both pointer/scalar/array oiData.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogTrace,"oiFitsWriteStructTable()";
  local n, e, name, Bin, Tit, type, nrow, tmp;
  local strName, i, tmp, tmp2, nameUpper, units, Units;

  Bin = Tit = [];

  /* get the element name and types */
  oiFitsStrReadMembers, str, name, type, strName;

  /* convert the structure names into file names */
  nameUpper = oiFitsConvertOiMemberToFile(name, , units);

  /* if scalar, add a dimension */
  if ( yocoTypeIsScalar(str) ) str = [str];
  for ( i=1 ; i<=numberof(name) ; i++ ) {
      
    tmp = get_member(str,name(i));
    if ( typeof(tmp)=="pointer" ) {
      local j,dat;
      for (dat=[],j=1;j<=numberof(tmp);j++) {
        if ( yocoTypeIsNumerical(*tmp(j)) ) grow,dat,[*tmp(j)];
      }
      tmp = dat;
    }
    if ( !is_array(tmp) ) continue;
    grow, Bin, &(tmp);
    grow, Tit, nameUpper(i);
    grow, Units, units(i);
  }

  /* write the table */
  cfitsio_add_bintable,fh, Bin, Tit, Units, extname;
  
  /* return the structure */
  yocoLogTrace,"oiFitsWriteStructTable done";
  return 1;
}

/* --- */

func oiFitsGetOiStruct(str, nrows, &name)
/* DOCUMENT oiFitsGetOiStruct(str, nrows, &name)

   DESCRIPTION
   Return the pseudo-dynamique structure associated
   with the structure 'str' and 'nrows'.

   If already installed, the str_nrows structure is
   not re-installed.
   
   SEE ALSO:
 */
{
  yocoLogTrace,"oiFitsOiGetStruct()";
  local lines,i,lid,nrows;
  extern __strTested;
  name = [];

  /* construct the complete struc name */
  if ( structof(str) != string ) name = str = structof(str);
  else name = str = "struct_"+str;

  /* if scalar, return the definition */
  if (nrows==0) return symbol_def(name);

  /* else construct the full name */
  name = (nrows>0 ? swrite(format=name+"_%i",nrows) : name+"_p");

  /* test if already installed */
  funcdef("funcset __strTested "+name);
  if ( is_struct(__strTested) ) return __strTested;

  /* test if the 'racine' structure exist,
     to then install it */
  funcdef("funcset __strTested "+str);
  if ( !is_struct(__strTested) ) return yocoError("Cannot install the pseudo-dynamique structure:"+name);
  
  /* default file name */
  local filetmp;
  filetmp = "~/.oiFitsStructTmp.i";
  yocoLogTest,"Install the pseudo-dynamique structure: "+name;

  /* print the structure definition,
     replace the array of readMode 
     add the number of row to the structure name  */
  lines = print(__strTested);
  // lid   = where( strmatch(lines," vis") | strmatch(lines,"t3") |
  //                strmatch(lines, "eff") | strmatch(lines,"drs" ));
  if (nrows<0) {
    lines(1) = yocoStrReplace(lines(1), " {", "_p {");
    lines = yocoStrReplace(lines, " t3", " *t3");
    lines = yocoStrReplace(lines, " vis", " *vis");
    lines = yocoStrReplace(lines, " eff", " *eff");
    lines = yocoStrReplace(lines, " flag", " *flag");
  }
  else {
    lines(1) = yocoStrReplace(lines(1), " {", swrite(format="_%i {",nrows));
    lines = yocoStrReplace(lines, "Data;", swrite(format="Data(%i);",nrows));
    lines = yocoStrReplace(lines, "Amp;",  swrite(format="Amp(%i);",nrows));
    lines = yocoStrReplace(lines, "Phi;",  swrite(format="Phi(%i);",nrows));
    lines = yocoStrReplace(lines, "Err;",  swrite(format="Err(%i);",nrows));
    lines = yocoStrReplace(lines, "effBand;",  swrite(format="effBand(%i);",nrows));
    lines = yocoStrReplace(lines, "effWave;",  swrite(format="effWave(%i);",nrows));
    lines = yocoStrReplace(lines, " flag;",  swrite(format=" flag(%i);",nrows));
  }

  /* write the tmp file and include it
     this can be replaced by   include,lines;   */
  write,(f=open(filetmp,"w")),lines+"\n";
  close,f;
  include,filetmp,1;
  
  yocoLogTrace,"oiFitsGetOiStruct done";
  return symbol_def(name);
}

/* --- */

func oiFitsAreComformable(left,right)
/* DOCUMENT oiFitsAreComformable(left,right)

   DESCRIPTION
   Return 1 if the operation left(*)=right
   is possible, meaning that the array are of
   compatible size and type

   EXAMPLES
   > oiFitsAreComformable([2.4,2.6],[1])
   1
   > oiFitsAreComformable([2.4,2.6],"test")
   0
 */
{
  /* catch the eventual error of cast */
  if ( catch(-1) ) {
    return 0;
  }
  left = left(*);
  left(*) = right;
  return 1;
}

/* --- */

func oiFitsStrHasMembers(stru,members)
/* DOCUMENT oiFitsStrHasMembers(stru,members)

   DESCRIPTION
   Check if the structure stru contains elements
   with name members.
   
   EXAMPLES
   > oiFitsStrHasMembers(complex,["re","toto","im"]);
   [1,0,1]
   > oiFitsStrHasMembers(double,"double");
   0
 */
{ 
  if(typeof(stru) != "struct_definition") stru = structof(stru);
  if(!yocoTypeIsString(members)) return yocoError("members is not valid");
  
  /* get a representation of the structure */
  name = oiFitsStrReadMembers(stru);
  
  /* return the test */
  return ( name==members(-,) )(sum,);
}

/* --- */

func oiFitsStrAreComformable(stru, member, value)
/* DOCUMENT oiFitsStrAreComformable(stru, member, value)

   DESCRIPTION
   Return 1 if the operation stru."member"=value
   is possible; that is if type and arrays size
   are compatible.

   EXAMPLES
   > test = array(complex,2);
   > oiFitsStrAreComformable(test,"im",[6,9])
   1
   > oiFitsStrAreComformable(test,"im",3.6)
   > 1
   > oiFitsStrAreComformable(test,"im","STR")
   0

   SEE ALSO
 */
{
  local flag,left,right;
  
  /* check if member is in */
  if ( !oiFitsStrHasMembers(stru, member) ) return 0;

  /* check if conformable */
  left = get_member(stru,member);
  if ( !oiFitsAreComformable(left,value) ) return 0;

  /* return 1 */
  return 1;
}

/* --- */

func oiFitsStrCheckMember(stru,member)
/* DOCUMENT oiFitsStrHasMember(stru,member)

   DESCRIPTION
   Return the type of stru."member"
   If member is not in the structure, return 0.

   EXAMPLES
   > oiFitsStrCheckMember(complex,"toto")
   0
   > ( oiFitsStrCheckMember(complex,"re") == double )
   1
*/
{
  local flag;
  if(!yocoTypeIsStringScalar(member)) return yocoError("member is not valid");
  
  /* check if inside the structure */
  if ( !oiFitsStrHasMembers(stru,member) ) return 0;

  /* return the type */
  return structof( get_member(stru(),member) );
}

/* --- */

func oiFitsStrReadMembers(stru,&name,&type,&strutype)
  /* DOCUMENT oiFitsStrReadMembers, stru, name, type, strutype;
        -or-  oiFitsStrReadMembers(stru,,type)
        -or-  ...

     DESCRIPTION
       Extract as string format :
       NAME : name of each element of the structure
       TYPE : the type of each element of the structure, as typeof(stru.elem)
       STRUNAME : the typeof of the structure as typeof(stru);

       The function return NAME.
       The STRU input could be a struct_definition or a variable.
  */
{
  local name,type;
  if(typeof(stru) != "struct_definition") stru = structof(stru);

  /* print a representation of the structure */
  stru = print(stru);
  if(stru(1)=="[]") {name = type = string([]); return name;}

  /* find the name of each element */
  strutype = strpart(stru(1),8:-2);
  if(numberof(stru)==2) {name = type = string([]); return name;}
  stru = strtrim(stru(2:-1));
  stru = strtok(stru," ");
  name = strpart(stru(2,),1:-1);
  /* remove the end, if ( or [ are present */
  name = strtok(name,"([")(1,);

  /* type of each element */  
  type = stru(1,);
    
  return name;
}

/* --- */

func oiFitsConvertOiStruct(oiStr,&oiNew,n)
/* DOCUMENT oiFitsConvertOiStruct(oiStr,&oiNew,n)

   DESCRIPTION
   Convert a pointer-like oiStruc into a array-like
   oiStruct. n is the dimension of the array (readMode).

   No check of comformability is done.
   
   PARAMETERS
   - oiStr: input structure (pointer)
   - oiNew: output structure (array)
 */
{
  local name, type, strName, tmp, i;
  
  oiFitsStrReadMembers, oiStr, name, type, strName;
  oiNew = array( oiFitsGetOiStruct(oiFitsStructRoot(oiStr), 1), dimsof(oiStr) );

  /* Loop on members */
  for (i=1;i<=numberof(name);i++) {
    old = get_member(oiStr,name(i));

    /* If not a pointer, simply copy */
    if (structof(old)!=pointer)
      get_member(oiNew, name(i)) = old;
    else
      for (s=1;s<=numberof(oiNew);s++)
        get_member(oiNew(s), name(i)) = *old(s);
  }
  
  return 1;
}

/* --- */

func oiFitsCorrectNansInfs(expr, value)
/* DOCUMENT oiFitsCorrectNansInfs(expr, value)

   DESCRIPTION
   Correct the data from Inf or Nan values.
   It replaces all Inf/Nan values in exprs
   by value (default is -1).

   This function is based on ieee.i
*/
{
    if (is_void(value)) value = -1;

    /* correct from NaN and Inf */
    if ( structof(expr)!=complex ) {
      nans = where(ieee_test(double(expr)))
      if( is_array(nans) ) expr(nans) = value;
    }
    else
    {
      nans = where(ieee_test(double(expr.im)))
      if( is_array(nans) ) expr.im(nans) = value;
      nans = where(ieee_test(double(expr.re)))
      if( is_array(nans) ) expr.re(nans) = value;
    }
    return expr;
}

/* --- */

func oiFitsGetStructData(str,name,fake)
/* DOCUMENT oiFitsGetStructData(str,name,fake)

   DESCRIPTION
   Expert function
 */
{
  local l, nrow, tmp, out;
  tmp = get_member(str,name);

  /* If scalar, eventually add a dimension before returning
     the data */
  if ( oiFitsStructNumMode(str)==0 ) {
    out = oiFitsCorrectNansInfs(tmp);
    return (fake ? out(-,) : out);
  }

  /* Numerical array */
  if ( oiFitsStructNumMode(str)>0 ) {
    return oiFitsCorrectNansInfs(tmp);
  }
  
  /* Is a pointer, but all scalar */
  if (yocoTypeIsScalar(tmp) && yocoTypeIsScalar(*tmp(1)) ) {
    return yocoError("BUG: this mode should be removed isn't it ?  -> jlebouqu@eso.org");
    out = *tmp(1);
    return oiFitsCorrectNansInfs(out);
  }

  /* is a scalar, and array */
  nrow  = numberof(tmp);
  out  =  array(structof(*tmp(1)), dimsof(*tmp(1))(0), dimsof(tmp));
  for ( l=1; l<=nrow; l++) {
    /* FIXME: check conformability */
    out(,l) = *(tmp(l));
  }
  return oiFitsCorrectNansInfs(out);
}

/* --- */

func oiFitsSetStructDataScalar(&str,i,name,data)
/* DOCUMENT oiFitsSetStructDataScalar(str,i,name,data)

   DESCRIPTION
   Expert function
 */
{
  local l, nrow, size, tmp, out;
  tmp = get_member(str(i),name);

  /* if not a pointer - FIXME: check conformability */
  if ( structof(tmp) != pointer ) {
    data = ( structof(data) == pointer ? *data : data );
    get_member(str(i),name) = data;
    return 1;
  }

  /* if a pointer - FIXME: check conformability */
  if ( structof(tmp) == pointer ) {
    data = ( structof(data) == pointer ? data : &data );
    nrow = numberof(tmp);
    for ( l=1; l<=nrow; l++) {
      get_member(str(i),name)(l) = data;
    }
    return 1;
  }
  
  return yocoError("Data not passed into the scruture.");
}

/* --- */

func oiFitsSetStructDataArray(&str,i,name,data)
/* DOCUMENT oiFitsSetStructDataArray(str,i,name,data)

   DESCRIPTION
   Expert function
 */
{
  local l, nrow, size, tmp, out;
  tmp  = get_member(str(i),name);
  size = dimsof(data)(0);
  nrow = numberof(tmp);
  
  /* if both pointer or both non-pointer - FIXME: check conformability */
  if ( (structof(tmp) == pointer && structof(data) == pointer ) ||
       (structof(tmp) != pointer && structof(data) != pointer )) {
    get_member(str(i),name) = reform ( data, dimsof(get_member(str(i),name)) );
    return 1;
  }

  if (is_void(i)) i=indgen(nrow);
  /* if a numerical/pointer - FIXME: check conformability */
  if ( structof(tmp) != pointer && structof(data) == pointer ) {
    for (l=1;l<=nrow;l++) get_member(str(i(l)),name)  = *( data(l%size) ); 
    return 1;
  }
  /* if a pointer/numerical - FIXME: check conformability */
  if ( structof(tmp) == pointer && structof(data) != pointer ) {
    for ( l=1; l<=nrow; l++) get_member(str(i(l)),name) = &( data(..,l%size)(*) );
    return 1;
  }

  return yocoError("Data not passed into the scructure.");
}

/* --- */

func oiFitsCopyStructForExozodi(input, &output)
{
  local name, type, strName;
  oiFitsStrReadMembers, input, name, type, strName;

  include, ["struct struct_oiVis2_p {",
            " struct_oiVis2Hdr hdr;",
            " int      targetId;",
            " double   time; ",
            " double   mjd;",
            " double   intTime;", 
            " pointer  vis2Data; ",
            " pointer  vis2Err; ",
            " pointer  vis2ErrSys;",
            " double   uCoord;  ",
            " double   vCoord;  ",
            " int      staIndex(2);", 
            " pointer  flag;      ",
            "};"],1;
  output = array(struct_oiVis2_p, dimsof(input));

  for (i=1;i<=numberof(name);i++) {
    get_member(output,name(i)) = get_member(input,name(i));
  }

  return 1;
}

func oiFitsCopyStruct(input, &output, strType=)
{
  local name, type, strName
  oiFitsStrReadMembers, input, name, type, strName;

  if (is_struct(strType))
    output = array(strType, dimsof(input));

  for (i=1;i<=numberof(name);i++) {
    get_member(output,name(i)) = get_member(input,name(i));
  }

  return 1;
}

func oiFitsOperandStructDataArray(&str,i,name,data,op)
/* DOCUMENT oiFitsOperandStructDataArray(&oiData,i,name,data,op)

   DESCRIPTION
   Expert function.
   Apply an operand to oiData.

   PARAMETERS
   - oiData
   - name: element of oiData (ex: "vis2Err", "visPhi"...)
   - i: index of oiData on which the operand has to be applied,
     (ex: 1, [1,2,3], or can be void to apply to all).
     Should be conformable with the array data.
   - op: operand: "+", "-", "*", "/", "max", "min";
   - data: to be applied, can be an 1-D array of pointer or a numerical
     array.

   EXAMPLES
   // increase yocoError bars of the 3 first oiVis2
   > oiFitsOperandStructDataArray, oiVis2, [1,2,3], "vis2Err",
     [2.0,2.1,2.3], "*";

   // compute and apply the calibration by the target size
   // in case oiVis2 contains different wavelength table
   > for(cal=[],i=1; i<=numberof(oiVis2) ; i++) 
     grow, cal, [&( yocoMathAiry( fact(i) / oiFitsGetLambda(oiVis2(i),oiWave)
                    *1e6 )^-2.0 )];
   > oiFitsOperandStructDataArray, oiVis2,,"vis2Data",cal,"*";

   FIXME: Conformability is not checked...

   SEE ALSO
 */
{
  local l, nrow, size, tmp, out;
  tmp  = get_member(str(i),name);
  size = max( dimsof(data)(0), 1);
  nrow = numberof(tmp);

  /* if both non-pointer - FIXME: check conformability */
  if ( structof(tmp) != pointer && structof(data) != pointer ) {
         if (op=="+")      get_member(str(i),name) += data;
    else if (op=="-")      get_member(str(i),name)  = get_member(str(i),name) - data;
    else if (op=="*")      get_member(str(i),name) *= data;
    else if (op=="/")      get_member(str(i),name)  = get_member(str(i),name) / data;
    else if (op=="max")    get_member(str(i),name)  = max(data,get_member(str(i),name));
    else if (op=="min")    get_member(str(i),name)  = min(data,get_member(str(i),name));
    else return yocoError("operator not known!");
    return 1;
  }
  if (is_void(i)) i=indgen(nrow);
  /* if a numerical/pointer - FIXME: check conformability */
  if ( structof(tmp) != pointer && structof(data) == pointer ) {
         if (op=="+")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) += *( data(l%size) ); }
    else if (op=="-")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name)  =  get_member(str(i)(l),name) - *( data(l%size) ); }
    else if (op=="*")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) *= *( data(l%size) ); }
    else if (op=="/")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name)  =  get_member(str(i)(l),name) / *( data(l%size) ); }
    else if (op=="max")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name)  = max( *( data(l%size) ), get_member(str(i)(l),name) ); }
    else if (op=="min")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name)  = min( *( data(l%size) ), get_member(str(i)(l),name) ); }
    else return yocoError("operator not known!");    
    return 1;
  }
  /* if a pointer/numerical - FIXME: check conformability */
  if ( structof(tmp) == pointer && structof(data) != pointer ) {
         if (op=="+")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i)(l),name)) + data(..,l%size) ); }
    else if (op=="-")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i)(l),name)) - data(..,l%size) ); }
    else if (op=="*")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i),name)(l)) * data(..,l%size) ); }
    else if (op=="/")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i)(l),name)) / data(..,l%size)); }
    else if (op=="max")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( max( data(..,l%size), *(get_member(str(i)(l),name))) ); }
    else if (op=="min")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( min( data(..,l%size), *(get_member(str(i)(l),name))) ); }
    else return yocoError("operator not known!");
    return 1;
  }
  /* if a pointer/pointer - FIXME: check conformability */
  if ( structof(tmp) == pointer && structof(data) == pointer ) {
         if (op=="+")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i)(l),name)) + *data(l%size) ); }
    else if (op=="-")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i)(l),name)) - *data(l%size) ); }
    else if (op=="*")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &( *(get_member(str(i)(l),name)) * *data(l%size) ); }
    else if (op=="/")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &(  *(get_member(str(i)(l),name)) / *data(l%size)); }
    else if (op=="max")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &(  max( *data(l%size) , *(get_member(str(i)(l),name)) ) ); }
    else if (op=="min")     { for (l=1;l<=nrow;l++)
        get_member(str(i(l)),name) = &(  min( *data(l%size) , *(get_member(str(i)(l),name)) ) ); }
    else return yocoError("operator not known!");
    return 1;
  }

  return yocoError("Data not passed into the structure.");
}

/* Local shortcut, when used in high-level routine */
_ofGSD  = oiFitsGetStructData;
_ofSSDs = oiFitsSetStructDataScalar;
_ofSSDa = oiFitsSetStructDataArray;
_ofOSDa = oiFitsOperandStructDataArray;


/* ------------------------------------------------------------------------
               Struture manipulation
   ------------------------------------------------------------------------ */

func oiFitsStructName(str)
{
  return nameof(structof(str));
}

/* --- */

func oiFitsStructRoot(str)
{
  return strtok(string(nameof(structof(str))),"_",3)(2,);
}

/* --- */

func oiFitsStructMode(str)
{
  return strtok(string(nameof(structof(str))),"_",3)(3,);
}

/* --- */

func oiFitsStructNumMode(str)
{
  local m;
  m = oiFitsStructMode(str);
  return (m=="p" ? -1 : yocoStr2Long(m));
}

/* --- */

local oiFitsStructName, oiFitsStructRoot;
local oiFitsStructMode, oiFitsStructNumMode;
/* DOCUMENT name = oiFitsStructName(oiFits)
            root = oiFitsStructRoot(oiFits)
            mode = oiFitsStructMode(oiFits)
            numM = oiFitsStructNumMode(oiFits)

   DESCRIPTION
   Return the struct name and the struct root of the
   input oiFits variable

   EXAMPLES
   > oiFitsStructName(myOiArray)
   "struct_oiArray"
   > oiFitsStructName(myOiVis2)
   "struct_oiVis2_p"
   > oiFitsStructRoot(myOiArray)
   "oiArray"
   > oiFitsStructRoot(myOiVis2)
   "oiVis2"
 */

func oiFitsIsOiT3(oiStr)     { return oiFitsStructRoot(oiStr)=="oiT3";}
func oiFitsIsOiVis(oiStr)    { return oiFitsStructRoot(oiStr)=="oiVis";}
func oiFitsIsOiVis2(oiStr)   { return oiFitsStructRoot(oiStr)=="oiVis2";}
func oiFitsIsOiTarget(oiStr) { return oiFitsStructRoot(oiStr)=="oiTarget";}
func oiFitsIsOiWave(oiStr)   { return oiFitsStructRoot(oiStr)=="oiWavelength";}
func oiFitsIsOiLog(oiStr)    { return oiFitsStructRoot(oiStr)=="oiLog";}
func oiFitsIsOiDiam(oiStr)   { return oiFitsStructRoot(oiStr)=="oiDiam";}
func oiFitsIsOiArray(oiStr)  { return oiFitsStructRoot(oiStr)=="oiArray";}

/* --- */

func oiFitsIsImgData(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["imgData"]);
}

/* --- */

func oiFitsIsOiDataOrImgData(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["oiVis2","oiT3","oiVis","imgData"]);
}

/* --- */

func oiFitsIsOiData(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["oiVis2","oiT3","oiVis"]);
}

/* --- */

func oiFitsIsOiStr(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr) ==
               ["oiVis2","oiT3","oiVis","oiTarget",
                "oiWavelength","oiLog","oiArray",
                "oiDiam","imgData"]);
}

/* --- */

func oiFitsIsOiDataOrTarget(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["oiVis2","oiT3","oiVis","oiDiam","oiTarget"]);
}

/* --- */

func oiFitsIsOiDataOrDiam(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["oiVis2","oiT3","oiVis","oiDiam"]);
}

/* --- */

func oiFitsIsOiDataOrArray(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["oiVis2","oiT3","oiVis","oiArray"]);
}

/* --- */

func oiFitsIsOiDataOrWave(oiStr)
{
  return anyof(oiFitsStructRoot(oiStr)==
               ["oiVis2","oiT3","oiVis","oiWavelength"]);
}

/* --- */

local oiFitsIsOiT3, oiFitsIsOiVis, oiFitsIsOiVis2, oiFitsIsOiTarget;
local oiFitsIsOiWave, oiFitsIsOiArray, oiFitsIsOiLog, oiFitsIsOiData;
local oiFitsIsOiLog, oiFitsIsOiDiam, oiFitsIsOiStr;
local oiFitsIsOiDataOrTarget, oiFitsIsOiDataOrDiam, oiFitsIsOiDataOrArray;
local oiFitsIsOiDataOrWave;
/* DOCUMENT oiFitsIsOiT3
            oiFitsIsOiVis
            oiFitsIsOiVis2
            oiFitsIsOiTarget
            oiFitsIsOiWave
            oiFitsIsOiArray
            oiFitsIsOiLog
            oiFitsIsOiDiam
            oiFitsIsOiData
            oiFitsIsOiStr
   
   DESCRIPTION
   Routines to check the type of the input oiStr, returning 0/1.
   oiFitsIsOiData returns 1 if oiStr is an oiT3, oiVis or oiVis2.
   oiFitsIsOiStr return 1 if oiStr is whatever oiFits structure.
   
   EXAMPLES
   > oiFitsIsOiData(myOiVis2)
   1
   > oiFitsIsOiTarget(myOiVis2)
   0
*/


/* --------------------------------------------------------------
   Small routines for private use, mainly to deal with list
   and index
   -------------------------------------------------------------- */

func oiFitsIsInsideInterv(interv,X)
{
  if ( is_void(interv) && !is_void(X)) return array(1, dimsof(X));
  if (dimsof(interv)(1)==1) interv=[interv];
  return ((interv(1,)(-,)<=X) & (interv(2,)(-,)>=X))(,sum);
}

func oiFitsGetIntervId(interv,X,invers)
{
  local out;
  if ( is_void(interv) && !is_void(X)) return indgen(numberof(X));
  if (dimsof(interv)(1)==1) interv=[interv];
  out = ((interv(1,)(-,)<=X) & (interv(2,)(-,)>=X))(,sum);
  if (invers) out = !out;
  out = where(out);
  if (dimsof(X)(1)==0 ) out=out(1);
  return out;
}

/* --- */

func _get_param(l,i,pp)
{
  if (is_void(l)) return [];
  if (numberof(l)==1) return array(l(1),dimsof(i));
  l =  l(*)( ((i-1)%numberof(l))+1);
  if (pp && typeof(l)=="pointer") return *l;
  return l;
}

/* --- */

func _get_array(l,i)
{
  if (is_void(l)) return [];
  if (typeof(l)!="pointer") return l;
  return *l(i%numberof(l));
}

/* --- */

local oiFitsUniqueIdLoop, oiFitsUniqueId;
/* DOCUMENT id = oiFitsUniqueId(x)
            id = oiFitsUniqueIdLoop(x)
   

   DESCRIPTION
   Return an id (integer) identical for all identical
   elements of the 1D array input. Second form is more
   efficient for long string array.
   
   CAUTIONS
   In oiFitsUniqueId, the id is increasing by
   sorting order (as sort(x)) while it is increasing
   by order of apparition on the array in oiFitsUniqueIdLoop
*/

func oiFitsUniqueIdLoop(x)
{
  local res,id,t,counter;
  if (numberof(x)==1 )
    return array(long(1),dimsof(x));

  /* init */
  id = array(long,dimsof(x));
  counter = 1;
  res = x;

  /* Look for the elements */
  do {
    id(where(x==res(1))) = counter;
    res = res(where(res!=res(1)));
    counter++;
  } while( is_array(res) );
  
  return id;
}

func oiFitsUniqueId(x)
{  
  local id,in;
  if (numberof(x)==1 ) return 1;
  in = x(*)(sort(x(*)));
  id = grow( 0, in(:-1)!=in(2:) )(psum)+1;
  return id(oiFitsGetId(x,in));
}

/* --- */

func oiFitsGetId(id,ref)
/* DOCUMENT id = oiFitsGetId(id,ref)

   DESCRIPTION
   For each id, return the (last) position in ref where id==ref
   Return 0 where there is no match.

   EXAMPLES:
   // prepare example
   > sName  = ["deltaCen", "Altair", "Aldebaran"];
   > sIndex = [1,2,3];
   
   // get the ids
   > myId = [1,3,3,1,2,9];
   > oiFitsGetId(myId, sIndex);
   [1,3,3,1,2,0]

   // recover the names
   > grow("no-name",sName) ( oiFitsGetId(myId, sIndex)+1 );
   ["deltaCen","Aldebaran","Aldebaran","deltaCen","Altair","no-name"]
 */
{
  local _id,out;
  /* Deal with simple case */
  if (numberof(id)==1 & numberof(ref)==1) {
    if ( id(1) != ref(1) ) return where();
    return 1;
  }
  ref= ref(*);
  
  out = array(0,dimsof(id));
  _id =  where2(id(*) == ref(-,));
  if (is_array(_id)) out(*)(_id(1,)) = _id(2,);
  return out;
}

func oiFitsGetIdLoop(id,ref)
{
  local _id,out,i;
  
  /* Deal with simple case */
  if (numberof(id)==1 & numberof(ref)==1) {
    if ( id(1) != ref(1) ) return where();
    return 1;
  }
  ref= ref(*);

  for ( out=[],i=1 ; i<=numberof(id) ; i++ )
    {
      _id = where(id(i)==ref);
      _id = ( is_array(_id) ? _id(0) : 0 );
      grow, out, id;
    }
  
  return out;
}

/* --- */

func oiFitsFindGroupId(data,delta)
/* DOCUMENT oiFitsFindGroupId(data,delta)

   DESCRIPTION
   Return a unique Id for group of data. A group a define by group of value
   separated by less than 'delta' between consecutives value.

   Note that data does not need to be sorted, and is not sorted by this
   function.

   EXAMPLES:
   > d = random(10);
   > oiFitsFindGroupId(d,0.1);
 */
{
  local in,id;

  /* Case only one element */
  if (numberof(data)==1)
    return array(long(1),dimsof(data));
  
  /* Found the groups */
  in = data(*)(sort(data(*)));
  id = grow( 0, abs(in(dif))>delta)(psum)+1;
  /* Return the group id */
  return id(yocoListId(data,in));
}


/* -------------------------------------------------------------------
   Routine to associated oiData with oiArray, oiTarget, oiWave...
   ------------------------------------------------------------------ */

func oiFitsGetOiLog(oiStr,oiLog)
/* DOCUMENT oiFitsGetOiLog(oiStr,oiLog)

   DESCRIPTION
   Get the corresponding log(s) associated with
   the oiFits structure oiStr, searching into the array
   of logs oiLog.

   PARAMETERS
   - oiStr: can be oiVis, oiVis2, oiT3, oiArray...
   - oiLog:

   EXAMPLES
   Recover the original file names for the
   all vis2 observation contained in oiVis2:
   > oiFitsGetOiLog(oiVis2,oiLog).orgFileName
 */
{
  local id;
  if( !oiFitsIsOiLog(oiLog) ) return yocoError("oiLog not valid");
  if( !oiFitsIsOiStr(oiStr) ) return yocoError("oiStr not valid");
  id = oiFitsGetId(oiStr.hdr.logId, oiLog.logId);
  return is_array(id) ? oiLog(*)(id) : [];
}

/* --- */

func oiFitsGetOiTarget(oiData,oiTarget)
/* DOCUMENT oiFitsGetOiTarget(oiData,oiTarget)

   DESCRIPTION
   Get the oiTarget structure associated with oiData,
   searching into oiTarget.

   PARAMETERS
   - oiData: oiVis, oiVis2, oiT3.
   - oiTarget:

   EXAMPLES
   Get the RA proper motion of vis2 observations:
   > trgPmRa = oiFitsGetOiTarget(oiVis2, oiTarget).pmRa
 */
{
  if (is_void(oiTarget) ) oiTarget = oiData;
  if( !oiFitsIsOiTarget(oiTarget) )     return yocoError("oiTarget not valid");
  if( !oiFitsIsOiDataOrTarget(oiData) ) return yocoError("oiData not valid");
  return oiTarget(*)(oiFitsGetId(oiData.targetId, oiTarget.targetId));
}

/* --- */

func oiFitsGetOiWave(oiData,oiWave)
/* DOCUMENT oiFitsGetOiWave(oiData,oiWave)

   DESCRIPTION
   Get the oiWave structure corresponding to oiData,
   searching into the oiWave.

   PARAMETERS
   - oiData: (oiVis2, oiT3, oiVis)
   - oiWave:

   EXAMPLES
   Get the spectral-bin size of of the first oiVis2 observation:
   > wBand = oiFitsGetOiWave(oiVis2(1),oiWave).effBand

   Get the instrument names of all oiVis2 observation
   > insName = oiFitsGetOiWave(oiVis2,oiWave).hdr.insName
*/
{
  local id;
  if ( is_void(oiWave) ) oiWave=oiData;
  if( !oiFitsIsOiWave(oiWave) )       return yocoError("oiWave not valid");
  if( !oiFitsIsOiDataOrWave(oiData) ) return yocoError("oiData not valid");
  id = oiFitsGetId(oiData.hdr.insName, oiWave.hdr.insName);
  if ( nallof(id) ) return yocoError("No oiWave for some oiData");
  return oiWave(id);
}


/* --- */

func oiFitsGetOiDiam(oiData,oiDiam)
/* DOCUMENT oiFitsGetOiDiam(oiData,oiDiam)

   DESCRIPTION
   Get the oiDiam structure associated with oiData,
   searching into oiTarget.

   PARAMETERS
   - oiData: oiVis, oiVis2, oiT3, oiTarget
   - oiDiam:

   EXAMPLES
   Get the diameter associated to vis2 observations:
   > obsDiam = oiFitsGetOiDiam(oiVis2, oiDiam).diam
*/
{
  local id;
  if (is_void(oiDiam) ) oiDiam = oiData;
  if( !oiFitsIsOiDataOrDiam(oiDiam) )   return yocoError("oiDiam not valid");
  if( !oiFitsIsOiDataOrTarget(oiData) ) return yocoError("oiData not valid");
  
  /* oiDiam is not necessarely complete (some data may have no entry in it)
     So here we ensure that this data are associated with a default oiDiam */
  id = oiFitsGetId(oiData.targetId, oiDiam.targetId);
  id = 1 + (is_array(id) ? id : 0);
  return grow(struct_oiDiam(),oiDiam(*))(id);
}

/* Put errors at the upper level */
errs2caller, oiFitsGetOiLog, oiFitsGetOiTarget, oiFitsGetOiDiam, oiFitsGetOiWave;

/* -----------------------------------------------------------
   Routines for oiData, to directly access the corresponing
   information stored into oiArray, oiTarget, oiWave...
   -----------------------------------------------------------*/

func oiFitsGetTargetName(oiData,oiTarget)
/* DOCUMENT oiFitsGetTargetName(oiData,oiTarget)

   DESCRIPTION
   Get the target of oiData, searching the neams into oiTarget.

   PARAMETERS
   - oiData: oiVis, oiVis2, oiT3.
   - oiTarget:

   EXAMPLES
   Get the target name of vis2 observations:
   > trgName = oiFitsGetTargetName(oiVis2, oiTarget)
*/
{
  return oiFitsGetOiTarget(oiData,oiTarget).target;
}

/* --- */

func oiFitsGetStationName(oiData,oiArray)
/* DOCUMENT oiFitsGetStationName(oiData,oiArray)

   DESCRIPTION
   Get the station name in format [sta1,sta2], corresponding
   to the observation contained in oiData, searching
   the station name into oiArray.

   PARAMETERS
   - oiData: (oiVis, oiT3, oiVis)
   - oiArray:
 */
{
  local idx;
  /* Check parameters*/
  if ( !oiFitsIsOiArray(oiArray) ) return yocoError("oiArray not valid");
  if ( (structof(oiData)==int || structof(oiData)==long) ) {
    idx = oiData;
  } else if ( oiFitsIsOiData(oiData) ) {
    idx = oiData.staIndex;
  } else {
    return yocoError("oiData not valid");
  }
  return oiArray.staName( oiFitsGetId(idx, oiArray.staIndex) );
}

/* --- */

func oiFitsGetBaseLength(oiData)
/* DOCUMENT oiFitsGetBaseLength(oiData)

   DESCRIPTION
     Return the base length of the oiData, from the uCoord
     and vCoord values. Results is in meters.

     If oiData is an oiT3, function returns the length of
     the longest baseline.

   PARAMETERS
     - oiData: (oiVis2, oiT3, oiVis)
 */
{
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  return ( !oiFitsIsOiT3(oiData) ? abs( oiData.uCoord, oiData.vCoord ) :
           max( abs( oiData.u1Coord+oiData.u2Coord, oiData.v1Coord+oiData.v2Coord ),
                abs( oiData.u1Coord, oiData.v1Coord ),
                abs( oiData.u2Coord, oiData.v2Coord ) )
           );
}

/* --- */

func oiFitsGetBaseAngle(oiData)
/* DOCUMENT oiFitsGetBaseLength(oiData)

   DESCRIPTION
     Return the base angle of the oiData, from the uCoord
     and vCoord values. Results is in deg.
     
     Note that  U->east and V->north
     and so that atan(u,v) is North->East angle

     If oiData is an oiT3, function returns the PA of
     the third baseline: atan(u1+u2,v1+v2) * 180/pi

   PARAMETERS
     - oiData: (oiVis2, oiT3, oiVis)
 */
{ 
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  return ( oiFitsIsOiT3(oiData) ?
           atan( oiData.u1Coord+oiData.u2Coord, oiData.v1Coord+oiData.v2Coord ) *180./pi :
           atan( oiData.uCoord, oiData.vCoord ) * 180./pi );
}

/* --- */

func oiFitsGetBaseName(oiData,oiArray)
/* DOCUMENT oiFitsGetBaseName(oiData,oiArray)

   DESCRIPTION
   Get the baseline name in format "sta1-sta2" of the
   oiData, searching the station name into oiArray.

   PARAMETERS
   - oiData: (oiVis, oiT3, oiVis)
   - oiArray:

   EXAMPLES
   Found which oiVis2 observation have been done with UT1-UT3
   > isUT13 = ( oiFitsGetBaseName(oiVis2,oiArray) == "U1-U3" )
*/
{
  if( !( yocoTypeIsInteger(oiData) || oiFitsIsOiData(oiData)) ) return yocoError("oiData not valid");
  if( !oiFitsIsOiArray(oiArray) ) return yocoError("oiArray not valid");

  local sta;
  sta = oiFitsGetStationName(oiData,oiArray);

  if (numberof(sta(,1))==1) return sta;
  return (sta(1:-1,)+"-")(sum,)+sta(0,);
}

func oiFitsGetHA(oiData, oiTarget)
{
  local mjd;
  if( !oiFitsIsOiData(oiData) )    return yocoError("oiData not valid");
  if( !oiFitsIsOiArray(oiTarget) ) return yocoError("oiTarget not valid");

  /* Extract MJD and convert into LST */
  mjd = oiData.mjd;
  error, "FIXME: not implemented yet ! ! !";

  return HA;
}

func oiFitsGetBaseStrIds(oiData)
{
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  return ( oiFitsIsOiT3(oiData) ?
           swrite(format="%i%i%i",oiData.staIndex(1,),oiData.staIndex(2,),oiData.staIndex(3,)) :
           swrite(format="%i%i",oiData.staIndex(1,),oiData.staIndex(2,)) );
}


/* --- */

func oiFitsGetIsCal(oiData,oiDiam)
/* DOCUMENT oiFistGetDiam(oiData,oiDiam)

   DESCRIPTION
   Return the flag isCal of targets observed in
   oiData, as specified in oiDiam.
 */
{
  return oiFitsGetOiDiam(oiData,oiDiam).isCal;
}

/* --- */

func oiFitsGetDiam(oiData,oiDiam)
/* DOCUMENT oiFitsGetDiam(oiData,oiDiam)

   DESCRIPTION
   Return the diameter of targets observed in
   oiData, as specified in oiDiam.
 */
{
  return oiFitsGetOiDiam(oiData,oiDiam).diam;
}

/* --- */

func oiFitsGetLambda(oiData,oiWave)
/* DOCUMENT oiFitsGetLambda(oiData,oiWave)

   DESCRIPTION
   Get the wavelength table of a single
   oiData, searching into the oiWave
   array. Table is returned in 10-6 meters (mum).

   PARAMETERS
   - oiData: scalar, like oiVis2(1), oiT3(1), oiVis(1).
   - oiWave:

   EXAMPLES
   Get the wavelength table of the first observation:
   > wlen = oiFitsGetLambda(oiVis2(1),oiWave)
   
   Get the wavelength table of the first oiWave
   > wlen = oiFitsGetLambda(oiWave(1))
 */
{
  if ( numberof(oiData)>1 ) return yocoError("oiData should be a scalar oiData");
  return oiFitsGetStructData(oiFitsGetOiWave(oiData(1),oiWave),"effWave") * 1e6;
}

/* --- */

func oiFitsGetSetup(oiData,oiLog,funcSetup=)
/* DOCUMENT oiFitsGetSetup(oiData,oiLog,funcSetup=)

   DESCRIPTION
   Return the corresponding instrumental setup
   of oiData, as a string.

   PARAMETERS
   - oiData, oiLog: 
   - funcSetup= (optional) temporary override 'oiFitsDefaultSetup'
     see the help of 'oiFitsDefaultSetup' for more information
*/
{
  local setAll, setDat;
  
  /* Check parameter */
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;
  if (!oiFitsIsOiData(oiData)) return yocoError("oiData not valid");
  if (!oiFitsIsOiLog(oiLog))   return yocoError("oiLog not valid");
  
  /* Return the setup of oiData */
  return funcSetup(oiData,oiLog);
}

/* --- */

func oiFitsGetLogElement(&oiData,oiLog,param)
/* DOCUMENT oiFitsGetLogElement(oiData,oiLog,param)

   DESCRIPTION
   Return the corresponding value of the parameter
   param (specified as a string) as from the oiLof.

   PARAMETERS
   - oiData, oiLog:
   - param: scalar string

   EXAMPLES:
   > oiFitsGetLogElement(oiVis2,oiLog,"insMode")
   ["3std_LowRes","2t_normal"]
*/
{
  local flag;
  /* check parameters */
  if ( !oiFitsIsOiLog(oiLog) )           return yocoError("oiLog not valid");
  if ( !oiFitsIsOiData(oiData) )         return yocoError("oiData not valid");
  if ( !yocoTypeIsStringScalar(param) )  return yocoError("param not valid");

  /* Protect the get_member */
  if ( catch(-1) ) {
    return yocoError("Following element not in oiLog",string(param));
  }

  /* get the param */
  flag = get_member(oiFitsGetOiLog(oiData,oiLog),param);
  return flag;
}

/* -----------------------------------------------------------
   Routines to create index based on information contained
   into oiStrucures
   ----------------------------------------------------------- */

func oiFitsGetBandId(oiData,oiWave)
/* DOCUMENT id = oiFitsGetBandId(oiData,oiWave)
    - or -  id = oiFitsGetBandId(oiWave)

   DESCRIPTION
   Get an id corresponding to the spectral band of observation.
   The returned band is the one of the average of the wavelength
   table, with the following coding:
    - 0 = smaller than J
    - 1 = J
    - 2 = H
    - 3 = K
    - 4 = larger than K

   PARAMETERS
   - oiData, oiWave:

   EXAMPLES
   Check which of oiVis2 are Jband observation:
   > oiW = oiFitsGetOiWave(oiVis2, oiWave);
   > isJ = ( oiFitsGetBandId(oiW) == 1 );
 */
{
  local oiW,i,out;

  /* Check parameters */
  if ( !( oiFitsIsOiWave(oiData) || oiFitsIsOiData(oiData) ) ) return yocoError("first parameter not valid");
  if ( !( is_void(oiWave) || oiFitsIsOiWave(oiWave) ) ) return yocoError("second parameter not valid");
       
  /* Get the oiWave */
  oiW = ( is_void(oiWave) ? oiData : oiFitsGetOiWave(oiData,oiWave) );
  
  /* Extract the average lambda */
  for (i=1,out=[]; i<=numberof(oiW); i++)
    grow, out, oiFitsGetLambda(oiW(i))(avg);

  /* Compare it to band */
  out = (out > (yocoAstroSI.band.J - .5*yocoAstroSI.band.Jwd )*1e6) + 
        (out > (yocoAstroSI.band.J + .5*yocoAstroSI.band.Jwd )*1e6) + 
        (out > (yocoAstroSI.band.H + .5*yocoAstroSI.band.Hwd )*1e6) + 
        (out > (yocoAstroSI.band.K + .5*yocoAstroSI.band.Kwd )*1e6) ;

  return out;
}

/* --- */

func oiFitsGetTargetId(oiData)
/* DOCUMENT oiFitsGetTargetId(oiData)

   DESCRIPTION
   Return the targetId.
 */
{
  if (!oiFitsIsOiDataOrTarget(oiData)) return yocoError("oiData not valid");
  return oiData.targetId;
}

/* --- */

func oiFitsGetSetupId(oiData,oiLog,oiAll,funcSetup=)
/* DOCUMENT oiFitsGetSetupId(oiData,oiLog,oiAll,funcSetup=)

   DESCRIPTION
   Return an index corresponding to the instrumental setup
   of oiData. 

   PARAMETERS
   - oiData, oiLog: 
   - funcSetup= (optional) temporary override 'oiFitsDefaultSetup'
     see the help of 'oiFitsDefaultSetup' for more information
*/
{
  local setAll, setDat;
  
  /* Check parameter */
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;
  if (!oiFitsIsOiData(oiData)) return yocoError("oiData not valid");
  if (!oiFitsIsOiLog(oiLog))   return yocoError("oiLog not valid");
  
  /* Return the setup ID of oiData */
  if ( is_void(oiAll) ) return oiFitsUniqueIdLoop( funcSetup(oiData,oiLog) );

  /* Return the setup, as in position within oiAll */
  setAll = funcSetup(oiAll,oiLog);
  setDat = funcSetup(oiData,oiLog);
  return oiFitsUniqueIdLoop(setAll) ( yocoListId(setDat, setAll ) );
}
  
/* --- */

func oiFitsGetMjdId(oiData,oiAll)
/* DOCUMENT oiFitsGetMjdId(oiData)

   DESCRIPTION
   Get a unique ID of each element of oiData based on the
   MJD of observation. Return:
   yocoListUniqueId(int(oiData.mjd))

   PARAMETERS
   - oiData: (oiVis2, oiVis, oiT3)
   - oiAll:  all oiData (in the case the first
     parameter contains only a subset).

   EXAMPLES

   SEE ALSO
 */
{
  local id,_all,setDat, setAll;

  /* Check for arguments */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");

  /* Eventually return */
  setDat = int(oiData.mjd);
  if (is_void(oiAll)) return yocoListUniqueId(setDat);

  /* Check oiAll */
  if( !oiFitsIsOiData(oiAll) ) return yocoError("oiAll not valid");
  if (numberof(oiData)==1 && numberof(oiAll)==1) return [1];

  /* Return the position within oiAll */
  setAll = int(oiAll.mjd)
  return oiFitsUniqueIdLoop(setAll) ( yocoListId(setDat, setAll) );
}

/* --- */

func oiFitsGetObsId(oiData,dtime=)
/* DOCUMENT oiFitsGetObsId(oiData,dtime=)
   
   DESCRIPTION
   Get a unique ID for each element of oiData based on
   the observation, meaning that different baselines, or
   different bands, of a single observation will have the
   same ID.

   Observations are matched by considering time difference
   being smaller than 10s.

   PARAMETERS
   - oiData: (oiVis, oiT3, oiVis)
   - dtime: in day, default is 10s
*/
{
  local id,_all,setDat, setAll, tmp;
  dtime = ( is_void(dtime) ? 10./24./3600. : double(dtime)(1) );

  /* Check for arguments */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");

  /* If unique */
  if (numberof(oiData)==1) return [1];

  /* Found the groups */
  tmp    = oiData.mjd + 100.*oiFitsGetTargetId( oiData );

  
  setDat = oiFitsFindGroupId( tmp, dtime );
  
  /* Eventually return */
  return oiFitsUniqueIdLoop(setDat);
}

/* --- */

func oiFitsGetBaseIdWorker(idx, rev)
{
  local n, i, eps;

  if ( !rev ) {
    n = dimsof(idx)(2);
    return ( (idx+1) * (100^indgen(n-1:0:-1)) )(sum,);
  }

  /* If rev, we invert the relation */
  n = int( log(idx) / log(100) ) + 1;
  if (anyof(n!=n(1))) return yocoError("not a valid idx");
  else n = n(1);
  idx -=  (100^indgen(0:n-1))(sum);
  idx = ( idx(-,) % ( 100^indgen(n:1:-1) ) ) / 100^indgen(n-1:0:-1);

  return idx;
}

func oiFitsGetBaseId(oiData,oiAll,oiArray,&names)
/* DOCUMENT oiFitsGetBaseId(oiData,oiAll,oiArray,&names)

   DESCRIPTION
   Get a unique id of each element of oiData based on the baseline.
   Id ranges 1:nbOfDifferentBase

   PARAMETERS
   - oiData: (oiVis, oiT3, oiVis)
   - oiAll:  all oiData of the night (in the case the first
     parameter contains only a subset).

   EXAMPLES
   Get a unique ID for each baseline, in order to loop:
   > ids = oiFitsGetBaseId( oiVis2 );
   > for (i=1 ;i <=max(ids) ; i++) {
        oiVis2tmp = oiVis2( where(ids == i) );
        // ... perform what I want on this baseline ...
     }
*/
{
  local id;
  yocoLogTrace,"oiFitsGetBaseId()";
  
  /* Check parameters */
  if (is_void(oiAll)) oiAll=oiData;
  if ( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if ( !oiFitsIsOiData(oiAll) )  return yocoError("oiAll not valid");
  if ( oiFitsStructRoot(oiData) != oiFitsStructRoot(oiAll)) return yocoError("oiData and oiAll incompatible");

  /* Return the setup ID of oiData */
  if ( is_void(oiAll) ) {    
    idAll = oiFitsGetBaseIdWorker(oiData.staIndex);
    id = oiFitsUniqueId( idAll );
  }
  else {
    idAll = oiFitsGetBaseIdWorker(oiAll.staIndex);
    idDat = oiFitsGetBaseIdWorker(oiData.staIndex);
    id    = oiFitsUniqueId(idAll)(*) ( yocoListId(idDat, idAll ) );
  }

  /* If is array is not defined, we don't need to compute the names */
  if( is_void(oiArray) || is_void(id) ) {
    yocoLogTrace,"oiFitsGetBaseId done";
    return id;
  }

  /* We compute the name */
  idAll = yocoListClean(idAll);
  idAll = oiFitsGetBaseIdWorker(idAll(sort(idAll)), 1);
  names = oiFitsGetBaseName(idAll,oiArray);

  yocoLogTrace,"oiFitsGetBaseId done";
  return id;
}

/* -------------------------------------------------------------
   Routines to explore and cut/extract oiData obtained on some
   specific time or target.
   ------------------------------------------------------------- */

func oiFitsRemoveMjdRef(&oiVis2,&oiVis,&oiT3,ref)
/* DOCUMENT oiFitsRemoveMjdRef(&oiVis2,&oiVis,&oiT3,ref)

   DESCRIPTION
   Highly non-standart routine to move the MJD of all observations.
   This may be interesting for private use, for dealing with smaller
   MJD (plots, observation selection...).

   newMJD = MJD - ref
 */
{
  yocoLogInfo,"oiFitsRemoveMjdRef()";

  /* default is 54400.0 */
  ref = (is_void(ref) ? 54400.0 : double(ref)(1) );

  /* remove that ref */
  if ( oiFitsIsOiVis2(oiVis2) )
    oiVis2.mjd -= ref;
  if ( oiFitsIsOiVis(oiVis) )
    oiVis.mjd -= ref;
  if ( oiFitsIsOiT3(oiT3) )
    oiT3.mjd -= ref;

  yocoLogWarning, "MJD has been moved from "+pr1(-ref)+"days";
  yocoLogTrace,"oiFitsRemoveMjdRef done";
  return 1;
}

/* --- */

func oiFitsListTarget(oiTarget,oiDiam)
/* DOCUMENT oiFitsListTarget(oiTarget,oiDiam)

   DESCRIPTION
   Print a list of the target included into oiTarget.
   Also print the diameter and the 'isCal' flag if
   the oiDiam structure is passed to the function.

   PARAMETERS
   - oiTarget, oiDiam:
 */
{
  yocoLogTrace,"oiFitsListTarget()";
  local diam, cal;
  
  /* If diameter is filled */
  if ( is_array(oiDiam) ) {
    diam = oiFitsGetOiDiam(oiTarget,oiDiam);
    cal  = ["sci","cal"](diam.isCal+1);
    diam = swrite(format="%4.2f",diam.diam);
  } else {
    diam = array("  ?  ",dimsof(oiTarget) );
    cal  = array(" ? ",dimsof(oiTarget) );
  }
  
  /* Write the outputs */
  write,"=== List of Target ==";
  write,format="%3i: %s\t - %smas - %s\n",
    oiTarget.targetId, oiTarget.target,diam,cal;

  yocoLogTrace,"oiFitsListTarget done";
  return 1;
}

/* --- */

func oiFitsListObs(oiData,oiTarget,oiArray,oiLog,oiDiam,dtime=,funcSetup=,file=,filename=,date=,nameOB=)
/* DOCUMENT oiFitsListObs(oiData,oiTarget,oiArray,oiLog,oiDiam,dtime=,funcSetup=,file=,filename=,nameOB=)

   DESCRIPTION
   Print a list of all observations contained into oiData, by looking
   at the parameters into associated arrays.

   Data with same target and same instrumental setup and closer in time
   than dtime are grouped into the same output.

   PARAMETERS
   - oiData, oiTarget, oiArray, oiLog
   - oiDiam: optional
   - dtime: in day, default is 5min.
   - funcSetup= optional, temporary override 'oiFitsDefaultSetup'
     see the help of 'oiFitsDefaultSetup' for more information
 */
{
  yocoLogInfo,"oiFitsListObs()";
  local setup, id, diam, cal, s, str, time, grpId, com, isCal;

  /* check arguments */
  if(is_void(dtime))  dtime = 5*60./24./3600.; // 5min
  if(is_void(nameOB)) nameOB=0;
  if (!oiFitsIsOiData(oiData))      return yocoError("oiData not valid");
  if (!oiFitsIsOiTarget(oiTarget))  return yocoError("oiTarget not valid");
  if (!oiFitsIsOiArray(oiArray))    return yocoError("oiArray not valid");
  if (!oiFitsIsOiLog(oiLog))        return yocoError("oiLog not valid");
  if ( is_void(funcSetup) ) funcSetup = oiFitsDefaultSetup;
  if ( is_void(filename) )  filename  = 0;
    
  /* Found the groups, data should be separated by less than 100 days */
  tmp = oiData.mjd + 100.*oiFitsGetTargetId( oiData ) + 10000.*oiFitsGetSetupId(oiData, oiLog, funcSetup=funcSetup);
  grpId = oiFitsFindGroupId( tmp, dtime );
  grpId = yocoListUniqueId(grpId);

  /* Loop on the group to build */
  for (str=time=[],i=1 ; i<=max(grpId) ; i++ ) {

    /* Get the obs */
    id  = where(grpId==i);
    oiTmp = oiData(id);
    com = (filename ? yocoFileSplitName( oiFitsGetOiLog(oiTmp, oiLog).fileName )(1) : "");

    if (date) grow, time, oiTmp(1).hdr.dateObs;
    else      grow, time, swrite(format="%.5f",oiTmp.mjd(min));

    /* Write the line */
    grow, str, swrite( format="%s: %10s %s%s- %2i obs: %s %s",
                       time(i),
                       oiFitsGetTargetName(oiTmp(1),oiTarget),
                       (is_array(oiDiam) ? ["(sci) ","(cal) "](oiFitsGetIsCal(oiTmp(1),oiDiam)+1) : ""),
                       (nameOB>0 ? strpart(oiFitsGetOiLog(oiTmp(1), oiLog).obsName,1:nameOB)+" " : ""),
                       numberof(oiTmp),
                       (yocoListClean(oiFitsGetBaseName(oiTmp,oiArray))+",")(*)(sum) + "  "+
                       oiFitsGetSetup(oiTmp(1),oiLog),
                       com);
  }

  /* Sort by time */
  str = str( sort(time) );

  /* write the list */
  if (is_void(file)) {
    write,str+"\n", linesize=strlen(str)(max)+2;
  } else {
    remove,file;
    file=open(file,"w");
    write,file,str+"\n", linesize=strlen(str)(max)+2;
    close,file;
  }
  
  yocoLogTrace,"oiFitsListObs done";
}

/* --- */

func oiFitsListAllObs(oiData,oiTarget,oiArray,oiLog,oiDiam,funcSetup=)
/* DOCUMENT oiFitsListAllObs(oiData,oiTarget,oiArray,oiLog,oiDiam,funcSetup=)

   DESCRIPTION
   Print a list of all observations contained into oiData, by looking
   at the parameters into associated arrays. If oiLog is given, the
   function will also compute and print the instrumental-setup of each
   observation as given by funcSetup(oiData, oiLog).

   Data are sorted by MJD.

   PARAMETERS
   - oiData, oiTarget, oiArray
   - oiLog,oiDiam: optional
   - funcSetup= optional, temporary override 'oiFitsDefaultSetup'
     see the help of 'oiFitsDefaultSetup' for more information
 */
{
  yocoLogInfo,"oiFitsListAllObs()";
  local setup, id, diam, cal, s;

  /* checl arguments */
  if (!oiFitsIsOiData(oiData))     return yocoError("oiData not valid");
  if (!oiFitsIsOiTarget(oiTarget)) return yocoError("oiTarget not valid");
  if (!oiFitsIsOiArray(oiArray))   return yocoError("oiArray not valid");
  
  /* sort by ascending time */
  id = indgen(numberof(oiData));
  s  = sort(oiData.mjd);

  /* If oiLog is filled, we try to compute the setup */
  if ( oiFitsIsOiLog(oiLog) ) {
    /* Default for funcSetup */
    if ( is_void(funcSetup) ) funcSetup = oiFitsDefaultSetup;
    /* Define the setup string */
    setup = funcSetup(oiData,oiLog);
  } else {
    setup = array(" ???????? ",numberof(oiData));
  }

  /* If diameter is filed */
  if ( is_array(oiDiam) ) {
    diam = oiFitsGetOiDiam(oiData,oiDiam);
    cal  = ["sci","cal"](diam.isCal+1);
  } else {
    cal  = array(" ? ",dimsof(oiData) );
  }

  /* write the list */
  write,"=== List of Observation ==";
  write,format="%.5f: %10s - %s - %s\n",
    oiData.mjd(s),
    oiFitsGetTargetName(oiData,oiTarget)(s),
    cal(s),
    ( oiFitsGetBaseName(oiData,oiArray)+" - "+setup )(s);

  yocoLogTrace,"oiFitsListAllObs done";
  return 1;
}

/* --- */

func oiFitsKeepWorker(&oiData,action,invers,p1,p2,p3)
/* DOCUMENT oiFitsKeepWorker(&oiData,action,invers,p1,p2,p3)

   DESCRIPTION
   PRIVATE FUNCTION
*/
{
  if (is_void(oiData)) return 1;

  if ( action == "time" ) {
    id = oiFitsIsInsideInterv(p1,oiData.mjd);
  } else if ( action == "insName" ) {
    id = yocoListId(oiData.hdr.insName,p1(*));
  } else if ( action == "date" ) {
    id = yocoListId(oiData.hdr.dateObs,p1(*));
  } else if ( action == "targets" ) {
    id = yocoListId(oiFitsGetTargetName(oiData,p2),p1(*));
  } else if ( action == "bases" ) {
    id = yocoListId(oiFitsGetBaseName(oiData,p2),p1(*));
  } else if ( action == "logElement" ) {
    id = yocoListId(oiFitsGetLogElement(oiData,p1,p2),p3(*));
  } else if ( action == "setup" ) {
    id = yocoListId(p1(oiData,p2),p3(*));
  } else {
    yocoError, "action is not known.";
  }

  /* Keep the correct one */
  if (invers) id=!id;
  oiData = oiData(where(id));
  
  /* Add a warning in case the array is now void */
  if (numberof(oiData)==0) {
    yocoLogWarning,oiFitsStructRoot(oiData)+
      " is now void: all observations have been excluded";
  }
  
  return 1;
}

/* --- */

func oiFitsKeepScience(&oiVis2,&oiVis,&oiT3,oiDiam)
/* DOCUMENT oiFitsKeepScience(&oiVis2,&oiVis,&oiT3,oiDiam)

   DESCRIPTION
   Keep only the science observation (remove observation with isCal==1).
 */
{
  yocoLogTrace,"oiFitsKeepScience()";

  if (is_array(oiVis2)) oiVis2 = oiVis2( where(!oiFitsGetIsCal(oiVis2,oiDiam)) );
  if (is_array(oiVis))  oiVis  = oiVis( where(!oiFitsGetIsCal(oiVis,oiDiam)) );
  if (is_array(oiT3))   oiT3   = oiT3( where(!oiFitsGetIsCal(oiT3,oiDiam)) );

  yocoLogTrace,"oiFitsKeepScience done";
  return 1;
}

func oiFitsKeepCalib(&oiVis2,&oiVis,&oiT3,oiDiam)
/* DOCUMENT oiFitsKeepCalib(&oiVis2,&oiVis,&oiT3,oiDiam)

   DESCRIPTION
   Keep only the calib observation (remove observation with isCal!=1).
 */
{
  yocoLogTrace,"oiFitsKeepCalib()";

  if (is_array(oiVis2)) oiVis2 = oiVis2( where(oiFitsGetIsCal(oiVis2,oiDiam)) );
  if (is_array(oiVis))  oiVis  = oiVis( where(oiFitsGetIsCal(oiVis,oiDiam)) );
  if (is_array(oiT3))   oiT3   = oiT3( where(oiFitsGetIsCal(oiT3,oiDiam)) );

  yocoLogTrace,"oiFitsKeepCalib done";
  return 1;
}

/* --- */

func oiFitsKeepSetup(oiLog,&oi1,&oi2,&oi3,&oi4,&oi5,&oi6,&oi7,&oi8,&oi9,&oi10,setupList=,invers=, funcSetup=)
/* DOCUMENT oiFitsKeepSetup(oiLog, oiVis2, oiT3, oiVis, oiVis2Tfe, ...,
                            setupList=,invers=, funcSetup=)

   DESCRIPTION
   Keep only the oiData (oiVis2, oiT3, oiVis) with setup string corresponding
   to setupList (array of string). oiLog is kept untouched.
   
   PARAMETERS
   - oiVis2, oiT3, oiVis ... array that will be cleaned in place
   - oiLog : mandatory
   - setupList : array of string
   - invers=(0/1) : optional
   - funcSetup : optional
 */
{
  yocoLogInfo, "oiFitsKeepSetup()";

  /* Check argument */
  if ( !oiFitsIsOiLog(oiLog) )    return yocoError("oiLog not valid");
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;

  oiFitsKeepWorker, oi1,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi2,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi3,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi4,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi5,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi6,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi7,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi8,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi9,  "setup", invers, funcSetup, oiLog, setupList;
  oiFitsKeepWorker, oi10, "setup", invers, funcSetup, oiLog, setupList;
  
  yocoLogTrace, "oiFitsKeepSetup done";
  return 1;
}

/* --- */

func oiFitsKeepLogElement(&oiLog,&oiVis2,&oiVis,&oiT3,param=,value=,invers=)
/* DOCUMENT oiFitsKeepLogElement(&oiLog,&oiVis2,&oiVis,&oiT3,param=,value=,invers=)

   DESCRIPTION
   Keep only oiVis2, oiT3, oiVis observations of that have
   corresponding oiLog."param" == value.
   Note that match should be **exact**.

   PARAMETERS
   - oiVis2, oiT3, oiVis: optional
   - param: member of oiLog to be checked, defined as a string
   - value: value that should be accepted (can be 1-D array to
            keep different value)
   - invers=1: invers the selection (remove observation matching)

   EXAMPLES
   > oiFitsKeepLogElement, oiLog, oiVis2, oiVis, oiT3,
                           param="insMode",value="3Tstd_Low_JHK";
   > oiFitsKeepLogElement, oiLog, oiVis2, param="p2vmId", value=[124,643,456];
*/
{
  local id, logValue;
  yocoLogInfo, "oiFitsKeepLogElement()";

  /* Check argument */
  if ( !oiFitsIsOiLog(oiLog) )    return yocoError("oiLog not valid");
  if ( oiFitsStrCheckMember(oiLog,param) != structof(value) )
    return yocoError("param or value not valid");

  /* Execute action */
  oiFitsKeepWorker, oiVis2, "logElement", invers, oiLog, param, value;
  oiFitsKeepWorker, oiVis,  "logElement", invers, oiLog, param, value;
  oiFitsKeepWorker, oiT3,   "logElement", invers, oiLog, param, value;

  yocoLogTrace, "oiFitsKeepLogElement done";
  return 1;
}

/* --- */

func oiFitsKeepTime(&oiVis2,&oiVis,&oiT3,tlimit=,invers=)
/* DOCUMENT oiFitsKeepTime(&oiVis2,&oiVis,&oiT3,tlimit=,invers=)

   DESCRIPTION
   Keep only observations (oiVis2, oiT3, oiVis) taken within
   the time (sub-)intervals defined by tlimit. The time is
   defined in MJD. The arguments oiVis2, oiVis and oiT3 are
   modified inplace.

   PARAMETERS
   - oiVis2, oiT3, oiVis: optional
   - tlimit: limit of the cut, in MJD, with possible format:
             [start,end] -or-
             [[s1,e1],[s2,e2],...,[sN,eN]]
   - invers=1: invers the selection

   EXAMPLES
   // Keep only oiT3 observations taken at the begining of the day 54600
   > mjdLimit = 54600+[0.,0.5];
   > oiFitsKeepTime,,,oiT3,tlimit=mjdLimit;
*/
{
  yocoLogTrace, "oiFitsKeepTime()";

  /* Check argument */
  if (is_void(tlimit)) tlimit = [0.,10e6];

  /* Execute action */
  oiFitsKeepWorker, oiVis2, "time", invers, tlimit;
  oiFitsKeepWorker, oiVis,  "time", invers, tlimit;
  oiFitsKeepWorker, oiT3,   "time", invers, tlimit;

  yocoLogTrace,"oiFitsKeepTime done";
  return 1;
}


/* --- */

func oiFitsKeepInsName(&oi1,&oi2,&oi3,&oi4,&oi5,&oi6,&oi7,&oi8,&oi9,&oi10,insList=,invers=)
/* DOCUMENT oiFitsKeepInsName(&oiWave,&oiVis2,&oiVis,&oiT3,...,insList=,invers=)

   DESCRIPTION
   Keep only oiWave, oiVis2, oiT3, oiVis observations with insName included
   in insList.

   PARAMETERS
   - oiWave, oiVis2, oiT3, oiVis: optional
   - insList: string array, list of insName to be kept.
   - invers=1: invers the selection
*/
{
  yocoLogInfo, "oiFitsKeepInsName()";

  /* Check argument */
  if ( structof(insList)!=string)    return yocoError("insList not valid");

  /* Execute action */
  oiFitsKeepWorker, oi1, "insName", invers, insList;
  oiFitsKeepWorker, oi2, "insName", invers, insList;
  oiFitsKeepWorker, oi3, "insName", invers, insList;
  oiFitsKeepWorker, oi4, "insName", invers, insList;
  oiFitsKeepWorker, oi5, "insName", invers, insList;
  oiFitsKeepWorker, oi6, "insName", invers, insList;
  oiFitsKeepWorker, oi7, "insName", invers, insList;
  oiFitsKeepWorker, oi8, "insName", invers, insList;
  oiFitsKeepWorker, oi9, "insName", invers, insList;
  oiFitsKeepWorker, oi10,"insName", invers, insList;

  yocoLogTrace,"oiFitsKeepInsName done";
  return 1;
}

/* --- */

func oiFitsKeepDate(&oiVis2,&oiVis,&oiT3,dateList=,invers=)
/* DOCUMENT oiFitsKeepDate(&oiVis2,&oiVis,&oiT3,dateList=,invers=)

   DESCRIPTION
   Keep only oiVis2, oiT3, oiVis observations with insName included
   in insList.

   PARAMETERS
   - oiVis2, oiT3, oiVis: optional
   - insList: string array, list of insName to be kept.
   - invers=1: invers the selection
*/
{
  yocoLogInfo, "oiFitsKeepDate()";

  /* Check argument */
  if ( !oiFitsIsOiTarget(oiTarget) ) return yocoError("oiTarget not valid");
  if ( structof(dateList)!=string)    return yocoError("dateList not valid");

  /* Execute action */
  oiFitsKeepWorker, oiVis2, "date", invers, dateList;
  oiFitsKeepWorker, oiVis,  "date", invers, dateList;
  oiFitsKeepWorker, oiT3,   "date", invers, dateList;

  yocoLogTrace,"oiFitsKeepDate done";
  return 1;
}

/* --- */

func oiFitsKeepBases(&oiArray,&oiVis2,&oiVis,&oiT3,baseList=,invers=)
/* DOCUMENT oiFitsKeepBases(&oiArray,&oiVis2,&oiVis,&oiT3,baseList=,invers=)

   DESCRIPTION
   Keep only oiVis2, oiT3, oiVis observations of targets included
   into baseList. Name matching should be exact.

   PARAMETERS
   - oiVis2, oiT3, oiVis: optional
   - oiTarget: name matching should be exact with baseList
   - baseList: string array, list of target to be kept.
   - invers=1: invers the selection
*/
{
  yocoLogInfo, "oiFitsKeepBases()";

  /* Check argument */
  if ( !oiFitsIsOiArray(oiArray) ) return yocoError("oiArray not valid");
  if ( structof(baseList)!=string) return yocoError("baseList not valid");

  /* Execute action */
  oiFitsKeepWorker, oiVis2, "bases", invers, baseList, oiArray;
  oiFitsKeepWorker, oiVis,  "bases", invers, baseList, oiArray;
  oiFitsKeepWorker, oiT3,   "bases", invers, baseList, oiArray;
  
  yocoLogTrace,"oiFitsKeepBases done";
  return 1;
}

/* --- */

func oiFitsCopyArrays(oi1, &o1,
                      oi2, &o2,
                      oi3, &o3,
                      oi4, &o4,
                      oi5, &o5,
                      oi6, &o6,
                      oi7, &o7,
                      oi8, &o8,
                      oi9, &o9,
                      oi10, &o10,
                      oi11, &o11,
                      oi12, &o12)
/* DOCUMENT oiFitsCopyArrays, oiStr1, &oiStr1Cp, oiStr2, &oiStr2Cp, oiStr3, &oiStr3Cp ...

   DESCRIPTION
   Copy oiStructures with duplication of the data. This is mandatory to use
   instead of simple oiStrCp = oiStr because for large data arrays, this
   will not copy the data.
 */
{
  /* Init output arrays */
  o1 = o2 = o3 = o4 = o5 = o6 = o7 = o8 = o9 = o10 = o11 = o12 = [];

  /* Copy arrays, here I should enforce they are actually copied */
  if (is_array(oi1) )   o1  = oi1(*);
  if (is_array(oi2) )   o2  = oi2(*);
  if (is_array(oi3) )   o3  = oi3(*);
  if (is_array(oi4) )   o4  = oi4(*);
  if (is_array(oi5) )   o5  = oi5(*);
  if (is_array(oi6) )   o6  = oi6(*);
  if (is_array(oi7) )   o7  = oi7(*);
  if (is_array(oi8) )   o8  = oi8(*);
  if (is_array(oi9) )   o9  = oi9(*);
  if (is_array(oi10) )  o10 = oi10(*);
  if (is_array(oi11) )  o11 = oi11(*);
  if (is_array(oi12) )  o12 = oi12(*);

  return 1;
}

func oiFitsKeepTargets(&oiTarget,&oiVis2,&oiVis,&oiT3,trgList=,invers=)
/* DOCUMENT oiFitsKeepTargets(&oiTarget,&oiVis2,&oiVis,&oiT3,trgList=,invers=)

   DESCRIPTION
   Keep only oiVis2, oiT3, oiVis observations of targets included
   into trgList. Name matching should be exact.

   PARAMETERS
   - oiVis2, oiT3, oiVis: optional
   - oiTarget: name matching should be exact with trgList
   - trgList: string array, list of target to be kept.
   - invers=1: invers the selection

   EXAMPLES
   // Keep only vis2 observation of targets that also have
   // closure-phase data:
   > trgT3 = oiFitsGetTargetName(oiT3, oiTarget);
   > oiFitsKeepTargets, oiTarget, oiVis2, trgList=trgT3;
*/
{
  yocoLogInfo, "oiFitsKeepTargets()";

  /* Check argument */
  if ( !oiFitsIsOiTarget(oiTarget) ) return yocoError("oiTarget not valid");
  if ( structof(trgList)!=string) return yocoError("trgList not valid");

  /* Execute action */
  oiFitsKeepWorker, oiVis2, "targets", invers, trgList, oiTarget;
  oiFitsKeepWorker, oiVis,  "targets", invers, trgList, oiTarget;
  oiFitsKeepWorker, oiT3,   "targets", invers, trgList, oiTarget;
  
  yocoLogTrace,"oiFitsKeepTargets done";
  return 1;
}

/* --- */

func oiFitsCutTargets(&oiTarget,&oiVis2,&oiVis,&oiT3,trgList=)
{
  yocoLogInfo, "oiFitsCutTargets()";

  /* Check argument */
  if ( !oiFitsIsOiTarget(oiTarget) ) return yocoError("oiTarget not valid");
  if ( structof(trgList)!=string) return yocoError("trgList not valid");

  /* Execute action */
  invers = 1;
  oiFitsKeepWorker, oiVis2, "targets", invers, trgList, oiTarget;
  oiFitsKeepWorker, oiVis,  "targets", invers, trgList, oiTarget;
  oiFitsKeepWorker, oiT3,   "targets", invers, trgList, oiTarget;
  
  yocoLogTrace,"oiFitsCutTargets done";
  return 1;
}

/* --- */

func oiFitsChangeTarget(oiTarget,&oiVis2,&oiVis,&oiT3,oldName=,newName=,tlimit=)
/* DOCUMENT oiFitsChangeTarget(oiTarget,&oiVis2,&oiVis,&oiT3,oldName=,newName=,tlimit=)

   DESCRIPTION
   Change the target name for these observations to newName (should exist in oiTarget).
   The observations to be updated are search by matching target name (oldName, could
   be "*" for all) and by time interval tlimit.
     
   SEE ALSO:
 */
{
  yocoLogInfo,"oiFitsChangeTarget()";

  if (is_void(tlimit)) tlimit=[-1e9,1e9];
  if (is_void(oldName)) oldName="*";

  /* Get the new targetId */
  id1 = where(oiTarget.target==newName);
  if (!is_array(id1)) {yocoLogInfo,"'"+newName+"' is not in oiTarget"; return 0;}
  id1 = oiTarget(id1).targetId;

  if ( is_array(oiVis2) ) {
    isOk  = oiFitsIsInsideInterv(tlimit, oiVis2.mjd);
    isOk *= strglob(oldName,oiFitsGetTargetName(oiVis2,oiTarget));
    oiVis2.targetId = oiVis2.targetId * (!isOk)  +  id1*(isOk);
  }

  if ( is_array(oiT3) ) {
    isOk  = oiFitsIsInsideInterv(tlimit, oiT3.mjd);
    isOk *= strglob(oldName,oiFitsGetTargetName(oiT3,oiTarget));
    oiT3.targetId = oiT3.targetId * (!isOk)  +  id1*(isOk);
  }

  if ( is_array(oiVis) ) {
    isOk  = oiFitsIsInsideInterv(tlimit, oiVis.mjd);
    isOk *= strglob(oldName,oiFitsGetTargetName(oiVis,oiTarget));
    oiVis.targetId = oiVis.targetId * (!isOk)  +  id1*(isOk);
  }
  
  yocoLogTrace,"oiFitsChangeTarget done";
  return 1;
}

/* --- */

func oiFitsCutSingle(oiData, oiArray, mjd, base, &oiDatac)
/* DOCUMENT oiFitsCutSingle( oiData, oiArray, mjd, base, &oiDatac )

   DESCRIPTION
   Among all element of oiData of baseline BASE, remove the one with
   the closest oiData.mjd from MJD. This allows to quicly remove
   an observation indified as outlier in a plot oiData(mjd).

   PARAMETERS
   - oiData, oiArray:
   - mjd: scalar double (54389.887)
   - base: scalar string ("E0-G0", or "A0-D0-H0")
   - &oiDatac: output
*/
{
  yocoLogInfo,"oiFitsCutSingle()";

  /* Definitions and init */
  local b,i,n,id;
  oiDatac = [];
  
  n = numberof(oiData);
  if ( !oiFitsIsOiData(oiData) )      return yocoError("oiData not valid");
  if ( numberof(base)!=numberof(mjd)) return yocoError("mjd and base not valid");

  /* Get the base name */
  b = oiFitsGetBaseName(oiData, oiArray);
  
  for (id=[], i=1 ; i<=numberof(mjd) ; i++) {
    grow, id, ( abs(oiData.mjd-mjd(i)) + (1.e9*(b!=base(i))) )(mnx);
  }

  /* Update oiData */
  n = indgen(n);
  n = where( !oiFitsGetId(n, id) );
  oiDatac = oiData(n);
  
  yocoLogTrace,"oiFitsCutSingle done";
  return 1;
}

/* --- */


func oiFitsSplitArrays(oiArray, oiTarget,
                       &oiVis2, &oiVis2_1,
                       &oiT3, &oiT3_1,
                       &oiVis, &oiVis_1,
                       base=, tlimit=, target=)
{
  yocoLogInfo,"oiFitsSplitArrays";

  if (is_array(oiVis2))
    oiFitsSplitArray, oiArray, oiTarget, oiVis2, oiVis2_1,
      base=base, tlimit=tlimit, target=target;

  if (is_array(oiT3))
    oiFitsSplitArray, oiArray, oiTarget, oiT3, oiT3_1,
      base=base, tlimit=tlimit, target=target;

  if (is_array(oiVis))
    oiFitsSplitArray, oiArray, oiTarget, oiVis, oiVis_1,
      base=base, tlimit=tlimit, target=target;

  yocoLogTrace,"oiFitsSplitArrays done";
  return 1;
}

func oiFitsSplitArray(oiArray, oiTarget,
                      &oiData, &oiData_1,
                      base=, tlimit=, target=)
{
  yocoLogTrace,"oiFitsSplitArray()";

  local id, i, tmp;
  
  /* Default is all data */
  if (is_void(tlimit)) tlimit = [0,1e10];
  if (is_void(base))   base   = "*";
  if (is_void(target)) target = "*";

  /* Time */
  id  = oiFitsIsInsideInterv(tlimit, oiData.mjd);

  /* Basename */
  tmp = oiFitsGetBaseName(oiData, oiArray);
  for (i=1;i<=numberof(base);i++) id += strglob(base(i), tmp);

  /* Target name */
  tmp = oiFitsGetTargetName(oiData, oiTarget);
  for (i=1;i<=numberof(target);i++) id += strglob(target(i), tmp); 

  /* Split the array */
  oiData_1 = oiData( where(id>=3) );
  oiData   = oiData( where(id<3) );
  
  yocoLogTrace,"oiFitsSplitArray done";
  return 1;
}

/* --- */

func oiFitsChangeStations(oiArray, &oiVis2, &oiVis, &oiT3, oldNames=, newNames=)
/* DOCUMENT oiFitsChangeStations(oiArray, &oiVis2, &oiVis, &oiT3, oldNames=, newNames=)

   DESCRIPTION
   Change the station name of observation.
   The new names should already exist on oiArray.
 */
{
  yocoLogInfo,"oiFitsChangeStations()";

  if ( is_array(oiVis2) ) {
    name = oiFitsGetStationName(oiVis2,oiArray);
    name = yocoStrReplace(name, oldNames(*), newNames(*));
    ids  = yocoListId(name, oiArray.staName);
    if (anyof(ids==0)) { yocoError,"Station does not exist"; return 0;}
    oiVis2.staIndex = oiArray( ids ).staIndex;
  }

  if ( is_array(oiVis) ) {
    name = oiFitsGetStationName(oiVis,oiArray);
    name = yocoStrReplace(name, oldNames(*), newNames(*));
    ids  = yocoListId(name, oiArray.staName);
    if (anyof(ids==0)) { yocoError,"Station does not exist"; return 0;}
    oiVis.staIndex = oiArray( ids ).staIndex;
  }

  if ( is_array(oiT3) ) {
    name = oiFitsGetStationName(oiT3,oiArray);
    name = yocoStrReplace(name, oldNames(*), newNames(*));
    ids  = yocoListId(name, oiArray.staName);
    if (anyof(ids==0)) { yocoError,"Station does not exist"; return 0;}
    oiT3.staIndex = oiArray( ids ).staIndex;
  }
  
  yocoLogTrace,"oiFitsChangeStations done";
  return 1;
}

/* --- */

func oiFitsBaseMatch(oiData, oiArray, base)
/* DOCUMENT oiFitsBaseMatch(oiData, oiArray, base)

   DESCRIPTION
   Return an id of matching base (0 if no match)

   PARAMETERS
   - oiData, oiArray
   - base: array of string

   EXAMPLES
   id = oiFitsBaseMatch(oiVis2, oiArray, "A0-G1");
   id = oiFitsBaseMatch(oiVis2, oiArray, ["*G1*","A0-K0"]);

   SEE ALSO
 */
{
  yocoLogTrace,"oiFitsBaseMatch()";
  
  local bname, id, b;
  bname = oiFitsGetBaseName(oiData,oiArray);
  id  = array(0,dimsof(bname));
  
  for (b=1;b<=numberof(base);b++)
    id += b*strglob( base(b), bname );

  return id;
}

func oiFitsFlagOiData(oiWave, oiArray, &oiVis2, &oiT3, &oiVis, wlimit=, base=, tlimit=, unflag=)
/* DOCUMENT oiFitsFlagOiData(oiWave, oiArray, &oiVis2, &oiT3, &oiVis, wlimit=, base=, tlimit=)

   DESCRIPTION
   Flag (remove) the observations that match all criteria : wavelength interval,
   baseline and time interval.

   Default value means "all observation" regarding this parameter:
   wlimit= [1,1e10]
   base  = "*"
   tlimit= [1,1e10]

   PARAMETERS
   wlimit= : interval of wavelength in mum [s,e] or [[s1,e1],... [sn,en]]
   base=   : baseline, for instance "A0-K0" or "*K0*" or ["A0-K0-G1","B0*"]
   tlimit= : interval of time in MJD [s,e] or [[s1,e1],... [sn,en]]

   EXAMPLES
   > oiFitsFlagData, oiWave, oiArray, oiVis2, wlimit=, base="*K0*", tlimit=;

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsFlagOiData()";
  local id, i, action;
  
  /* Default is all data */
  if (is_void(tlimit)) tlimit = [0,1e10];
  if (is_void(base))   base   = "*";
  if (is_void(wlimit)) wlimit = [0,100.];
  if (unflag) action="unflag"; else action="flag";

  local id, bname;

  /* Loop on oiVis2 */
  for (i=1;i<=numberof(oiVis2);i++) {
    if ( oiFitsIsInsideInterv(tlimit, oiVis2(i).mjd)(1) * 
         oiFitsBaseMatch(oiVis2(i), oiArray, base) )
      oiVis2(i) = oiFitsDataWaveWorker( oiVis2(i), oiWave, action, wlimit );
  }

  /* Loop on oiT3 */
  for (i=1;i<=numberof(oiT3);i++) {
    if ( oiFitsIsInsideInterv(tlimit, oiT3(i).mjd)(1) *
         oiFitsBaseMatch(oiT3(i), oiArray, base) )
      oiT3(i) = oiFitsDataWaveWorker( oiT3(i), oiWave, action, wlimit );
  }

  /* Loop on oiVis */
  for (i=1;i<=numberof(oiVis);i++) {
    if ( oiFitsIsInsideInterv(tlimit, oiVis(i).mjd)(1) *
         oiFitsBaseMatch(oiVis(i), oiArray, base) )
      oiVis(i) = oiFitsDataWaveWorker( oiVis(i), oiWave, action, wlimit );
  }
  
  yocoLogTrace,"oiFitsFlagOiData done";
  return 1;
}
/* --- */

func oiFitsCutTimeBase(oiData, oiArray, tlimit, base, &oiDatac)
/* DOCUMENT oiFitsCutTimeBase(oiData, oiArray, tlimit, base, &oiDatac)

   DESCRIPTION
   Remove all element of oiData with baseline BASE and with mjd within
   the intervals TLIMIT. See oiFitsCutSingle if you want to remove
   a single observation on a given base.

   PARAMETERS
   - oiData, oiArray:
   - tlimit: interval(s) in mjd: [Start, End] -or- [[S1,E1],...[Si,Ei]]
   - base: "E0-G0" or "A0-D0-H1". If base="*", then observation on
           all baselines are removed.
   - &oiDatac: output
*/
{
  yocoLogInfo,"oiFitsCutTimeBase()";
  local id;
  oiDatac = [];
  
  if ( !oiFitsIsOiData(oiData) )      return yocoError("oiData not valid");
  if ( !yocoTypeIsStringScalar(base)) return yocoError("base not valid");

  /* Flag data to be removed */
  id  =
    oiFitsIsInsideInterv(tlimit, oiData.mjd) &
    strglob( base, oiFitsGetBaseName(oiData,oiArray) );
  
  /* Update oiData */
  oiDatac = oiData(where(!id));

  yocoLogTrace,"oiFitsCutTimeBase done";
  return 1;
}

/* --- */

func oiFitsSelectSequences(&oiWave, &oiVis2, &oiVis, &oiT3, tsplit=, idsplit=)
/* DOCUMENT oiFitsSelectSequences(&oiWave, &oiVis2, &oiVis, &oiT3, tsplit=, idsplit=)

   Split the night by defining different insName for different
   sequences of the night. This will force the software to define
   an independent calibration for each sequence.

   Note that observation that are outside all the sequences will be lost.

   PARAMETERS
   - oiWave, oiVis2, oiVis, oiT3
   - tsplit=: should be an array of time interval in MJD
     [ [start1, end1], [start2, end2], ...]

   EXAMPLES
   > oiFitsSplitNight, oiWave, oiVis2, oiVis, oiT3,
       tsplit=56046 + [ [.0,0.1], [0.45,0.47], [0.8,.9] ];

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsSelectSequences()";
  local n;
  
  if (is_void(tsplit) || structof(tsplit)!=double)
    yocoError,"tsplit should be an array of double";

  /* Maximum number of subpart */
  n = dimsof(tsplit)(3);

  /* Default */
  if (is_void(idsplit)) idsplit = swrite(format="_%i",indgen(n));

  /* Check idsplit */
  if ( n != numberof(idsplit)) {
    error,"tsplit and idsplit are not conformable.";
  }

  /* Multiplex the number of oiWave */
  oiWave = array(oiWave(*),n);
  oiWave.hdr.insName += idsplit(-,);
  oiWave = oiWave(*);

  /* Cut the vis2 */
  if (is_array(oiVis2))
  {
    allVis2 = tmpVis2 = [];
    for (i=1;i<=n;i++)
    {
      tmpVis2 = oiVis2(  where( oiVis2.mjd>tsplit(1,i) & oiVis2.mjd<tsplit(2,i))  );
      if ( is_void(tmpVis2) ) {
        yocoLogInfo,"No oiVis2 in selection #"+pr1(i);
        continue;
      }
      tmpVis2.hdr.insName += idsplit(i);
      allVis2 = grow(allVis2, tmpVis2);
    }

    oiVis2 = allVis2;
    if ( is_void(oiVis2) )
      yocoLogInfo,"all oiVis2 have been rejected";
  }

  /* Cut the oiT3 */
  if (is_array(oiT3))
  {
    allT3 = tmpT3 = [];
    for (i=1;i<=n;i++)
    {
      tmpT3 = oiT3(  where( oiT3.mjd>tsplit(1,i) & oiT3.mjd<tsplit(2,i))  );
      if ( is_void(tmpT3) ) {
        yocoLogInfo,"No oiT3 in selection #"+pr1(i);
        continue;
      }
      tmpT3.hdr.insName += idsplit(i);
      allT3 = grow(allT3, tmpT3);
    }

    oiT3 = allT3;
    if ( is_void(oiT3) )
      yocoLogInfo,"all oiT3 have been rejected";
  }


  /* Cut the oiVis */
  if (is_array(oiVis))
  {
    allVis = tmpVis = [];
    for (i=1;i<=n;i++)
    {
      tmpVis = oiVis(  where( oiVis.mjd>tsplit(1,i) & oiVis.mjd<tsplit(2,i))  );
      if ( is_void(tmpVis) ) {
        yocoLogInfo,"No oiVis in selection #"+pr1(i);
        continue;
      }
      tmpVis.hdr.insName += idsplit(i);
      allVis = grow(allVis, tmpVis);
    }

    oiVis = allVis;
    if ( is_void(oiVis) )
      yocoLogInfo,"all oiVis have been rejected";
  }

  yocoLogTrace,"oiFitsSelectSequences done";
  return 1;
}


func oiFitsSplitNight(&oiWave, &oiVis2, &oiVis, &oiT3, tsplit=, idsplit=)
/* DOCUMENT oiFitsSplitNight(&oiWave, &oiVis2, &oiVis, &oiT3, tsplit=)

   DESCRIPTION
   Split the night by defining different insName for different
   time part of the night. This will force the software to define
   an independent calibration for each part.

   PARAMETERS
   - oiWave, oiVis2, oiVis, oiT3
   - tsplit=: should be an array of time in MJD

   EXAMPLES
   > oiFitsSplitNight, oiWave, oiVis2, oiVis, oiT3,
       tsplit=[56046.0534,56046.0930,56046.1292];
*/
{
  yocoLogInfo,"oiFitsSplitNight()";
  local n;

  if (is_void(tsplit) || structof(tsplit)!=double)
    yocoError,"tsplit should be an array of double";

  /* Maximum number of subpart */
  n = numberof(tsplit) + 1;

  /* Default */
  if (is_void(idsplit)) idsplit = swrite(format="_%i",indgen(n));

  /* Check idsplit */
  if ( n != numberof(idsplit)) {
    error,"tsplit and idsplit are not conformable.";
  }

  /* Multiplex the number of oiWave */
  oiWaveNew = array(oiWave(*),n);
  oiWaveNew.hdr.insName += idsplit(-,);
  oiWave = grow(oiWave(*), oiWaveNew(*));

  /* Cut the vis2 */
  if (is_array(oiVis2)) {
    id = 1 + (oiVis2.mjd>=tsplit(-,))(,sum);
    oiVis2.hdr.insName += idsplit(id);
    yocoLogInfo,"oiVis2 split in "+pr1(numberof(yocoListClean(id)))+" parts";
  }

  /* Cut the oiVis */
  if (is_array(oiVis)) {
    id = 1 + (oiVis.mjd>=tsplit(-,))(,sum);
    oiVis.hdr.insName += idsplit(id);
    yocoLogInfo,"oiVis split in "+pr1(numberof(yocoListClean(id)))+" parts";
  }

  /* Cut the oiT3 */
  if (is_array(oiT3)) {
    id = 1 + (oiT3.mjd>=tsplit(-,))(,sum);
    oiT3.hdr.insName += idsplit(id);
    yocoLogInfo,"oiT3 split in "+pr1(numberof(yocoListClean(id)))+" parts";
  }

  // yocoListClean(oiT3.hdr.insName);

  yocoLogTrace,"oiFitsSplitNight done";
  return 1;
}


/* ----------------------------------------------------
   Routines to access the data inside the oiData
   ---------------------------------------------------- */

func oiFitsGetData(oiData,&amp,&ampErr,&phi,&phiErr,&flag,fakeWave,noCheck=)
/* DOCUMENT oiFitsGetData(oiData,&amp,&ampErr,&phi,&phiErr,&flag,fakeWave,noCheck=)

   DESCRIPTION
   Extract the amplitude and phase data-arrays from any
   kind of oiData (oiVis2, oiT3, oiVis), with the associated
   error bars.
   Also works with oiWave: amp is effWave and damp is effBand.
   
   Note that:
   - oiVis.visData (complex numbers) is not supported
   - oiVis2 will return phase of 0deg+/-pi since this quantity
     does not have phase information.

   PARAMETERS
   - oiData
   - fakeWave: see oiFitsGetStructData
 */
{
  local amp,ampErr,phi,phiErr;
  yocoLogTrace,"oiFitsGetData()";

  /* check parameters */
  if ( !oiFitsIsOiDataOrWave(oiData) )
    return yocoError("oiData not valid");

  /* check if data are conformable */
  if (anyof(oiData.hdr.insName != oiData(1).hdr.insName) && !noCheck)
    return yocoError("oiData.hdr.insName not conformable.\n All data should come from the same instrument.");
  
  if ( oiFitsIsOiVis2(oiData) ) {
    amp     = oiFitsGetStructData(oiData,"vis2Data",fakeWave);
    ampErr  = oiFitsGetStructData(oiData,"vis2Err",fakeWave);
    phi     = amp*0.0;
    phiErr  = amp*0.0 + pi;
    flag    = oiFitsGetStructData(oiData,"flag",fakeWave);
  } else if ( oiFitsIsOiVis(oiData) ) {
    amp     = oiFitsGetStructData(oiData,"visAmp",fakeWave);
    ampErr  = oiFitsGetStructData(oiData,"visAmpErr",fakeWave);
    phi     = oiFitsGetStructData(oiData,"visPhi",fakeWave);
    phiErr  = oiFitsGetStructData(oiData,"visPhiErr",fakeWave);    
    flag    = oiFitsGetStructData(oiData,"flag",fakeWave);
  } else if ( oiFitsIsOiT3(oiData) ) {
    amp     = oiFitsGetStructData(oiData,"t3Amp",fakeWave);
    ampErr  = oiFitsGetStructData(oiData,"t3AmpErr",fakeWave);
    phi     = oiFitsGetStructData(oiData,"t3Phi",fakeWave);
    phiErr  = oiFitsGetStructData(oiData,"t3PhiErr",fakeWave);
    flag    = oiFitsGetStructData(oiData,"flag",fakeWave);
  } else if ( oiFitsIsOiWave(oiData) ){
    amp     = oiFitsGetStructData(oiData,"effWave",fakeWave) * 1e6;
    ampErr  = oiFitsGetStructData(oiData,"effBand",fakeWave) * 1e6;
    phi     = amp*0.0;
    phiErr  = amp*0.0 + pi;
    flag    = array(char(0),dimsof(amp));
  } else {
    return yocoError("unknown oiData");
  }

  /* FIXME: use this nasty trick for the flags. This is the simplest way
     to not consider the flagged data in the analysis (for instance TF computation) */
  phiErr  +=   1e15 * (flag!=char(0));
  ampErr  +=   1e15 * (flag!=char(0));

  yocoLogTrace,"oiFitsGetData done";
  return data;
}

/* --- */

func oiFitsWrapAngle(phi)
/* DOCUMENT oiFitsWrapAngle(phi)

   DESCRIPTION
   Wrap the angle so that it is defined from
   -180 to 180 deg. Input angle should be defined
   from -3600 to infinit.
 */
{
  phi  = (phi+3600) % 360.0;
  phi -= 360.0 * (phi>180);
  return phi;
}

func oiFitsSetData(&oiData, i, amp, ampErr, phi, phiErr, flag, nowrap=)
/* DOCUMENT oiFitsSetData(&oiData, i, amp, ampErr, phi, phiErr, flag,
                          nowrap=)

   DESCRIPTION
   Put back the amplitude and phase data (with associated error) into
   the array of oiData. See oiFitsGetData.
   Also works with oiWave: amp is effWave and damp is effBand.

   Only a single instance of oiData can be modified
   at a time with this function: oiData(i), so
   data array cannot have more than 1 dimension (which is
   the spectral dimension).

   It is the responsability of the user to ensure the
   size is compatible with the associated insName.

   PARAMETERS
   - oiData(i): element that will be overwriten.
   - amp, ampErr: amplitude data with associated errors
     (vis2Data, visAmp or t3Amp).
   - phi, phiErr: phase data with associated errors
     (visPhi or t3Phi).
*/
{  
  /* check parameters */
  if ( !oiFitsIsOiDataOrWave(oiData) )
    return yocoError("oiData not valid");
  if ( !yocoTypeIsIntegerScalar(i) )
    return yocoError("i should be integer scalar");
  if ( (is_array(amp)    && dimsof(amp)(1)>2) ||
       (is_array(ampErr) && dimsof(ampErr)(1)>2) ||
       (is_array(phi)    && dimsof(phi)(1)>2) ||
       (is_array(phiErr) && dimsof(phiErr)(1)>2) )
    return yocoError("Data cannot have more than 2 dim.");

  /* Wrap phase within the -180,+180 range */
  if (is_array(phi) && nowrap!=1) {
    phi = oiFitsWrapAngle(phi);
  }

  /* Set the data in place */
  if ( oiFitsIsOiVis2(oiData) ) {
    oiFitsSetStructDataScalar, oiData, i, "vis2Data", amp;
    oiFitsSetStructDataScalar, oiData, i, "vis2Err",  ampErr;
    oiFitsSetStructDataScalar, oiData, i, "flag",     max(char(flag),char(ampErr>0.75));
  } else if ( oiFitsIsOiVis(oiData) ) {
    oiFitsSetStructDataScalar, oiData, i, "visPhi",    phi;
    oiFitsSetStructDataScalar, oiData, i, "visPhiErr", phiErr;    
    oiFitsSetStructDataScalar, oiData, i, "visAmp",    amp;
    oiFitsSetStructDataScalar, oiData, i, "visAmpErr", ampErr;    
    oiFitsSetStructDataScalar, oiData, i, "visData",   amp * 0.0i;
    oiFitsSetStructDataScalar, oiData, i, "visErr",    ampErr *0.0i;    
    oiFitsSetStructDataScalar, oiData, i, "flag",      max(char(flag),char(phiErr>100.0));
  } else if ( oiFitsIsOiT3(oiData) ) {
    oiFitsSetStructDataScalar, oiData, i, "t3Phi",    phi;
    oiFitsSetStructDataScalar, oiData, i, "t3PhiErr", phiErr;
    oiFitsSetStructDataScalar, oiData, i, "t3Amp",    amp;
    oiFitsSetStructDataScalar, oiData, i, "t3AmpErr", ampErr;
    oiFitsSetStructDataScalar, oiData, i, "flag",     max(char(flag),char(phiErr>100.0));
  } else if ( oiFitsIsOiWave(oiData) ){
    oiFitsSetStructDataScalar, oiData, i, "effWave",  amp * 1e-6;
    oiFitsSetStructDataScalar, oiData, i, "effBand",  ampErr * 1e-6;
  } else {
    return yocoError("unknown oiData");
  }

  return 1;
}

/* --- */

func oiFitsSetDataArray(&oiData, i, amp, ampErr, phi, phiErr, flag, nowrap=)
/* DOCUMENT oiFitsSetData(&oiData, i, amp, ampErr, phi, phiErr, flag,
            nowrap=)

   DESCRIPTION
   Same as oiFitsSetData, but can deal with several oiData
   element simultaneously (i can be a list of index or void in
   case you want to work on all element of oiData).

   It is the responsability of the user to ensure the
   size are compatible with the associated insName.
*/
{
  /* check parameters */
  if ( !oiFitsIsOiDataOrWave(oiData) )
    return yocoError("oiData not valid");
  if ( dimsof(amp)(1)>2 || dimsof(ampErr)(1)>2 ||
       dimsof(phi)(1)>2 || dimsof(phiErr)(1)>2 )
    return yocoError("Data cannot have more than 2 dim.");

  /* Wrap phase within the -180,+180 range */
  if (is_array(phi) && nowrap!=1) {
    phi = oiFitsWrapAngle(phi);
  }

  /* Set the data in place */
  if ( oiFitsIsOiVis2(oiData) ) {
    oiFitsSetStructDataArray, oiData, i, "vis2Data", amp;
    oiFitsSetStructDataArray, oiData, i, "vis2Err",  ampErr;
    oiFitsSetStructDataArray, oiData, i, "flag",     max(char(flag),char(ampErr>0.75));
  } else if ( oiFitsIsOiVis(oiData) ) {
    oiFitsSetStructDataArray, oiData, i, "visPhi",    phi;
    oiFitsSetStructDataArray, oiData, i, "visPhiErr", phiErr;    
    oiFitsSetStructDataArray, oiData, i, "visAmp",    amp;
    oiFitsSetStructDataArray, oiData, i, "visAmpErr", ampErr;    
    oiFitsSetStructDataArray, oiData, i, "flag",      max(char(flag),char(phiErr>100.0));
  } else if ( oiFitsIsOiT3(oiData) ) {
    oiFitsSetStructDataArray, oiData, i, "t3Phi",    phi;
    oiFitsSetStructDataArray, oiData, i, "t3PhiErr", phiErr;
    oiFitsSetStructDataArray, oiData, i, "t3Amp",    amp;
    oiFitsSetStructDataArray, oiData, i, "t3AmpErr", ampErr;
    oiFitsSetStructDataArray, oiData, i, "flag",     max(char(flag),char(phiErr>100.0));
  } else if ( oiFitsIsOiWave(oiData) ){
    oiFitsSetStructDataArray, oiData, i, "effWave",  amp * 1e-6;
    oiFitsSetStructDataArray, oiData, i, "effBand", damp * 1e-6;
  } else {
    return yocoError("unknown oiData");
  }
  
  return 1;
}



/* -----------------------------------------------------------------------
               Small manipulation
   ----------------------------------------------------------------------- */

func oiFitsSwapBaseline(&oiVis2, &oiVis, &oiT3, base=)
/* DOCUMENT oiFitsSwapBaseline(&oiVis2, &oiVis, &oiT3, base=)

   DESCRIPTION
   Swap the baseline description in a consistent manner:
   name of baseline, uv plane, sign of differential phase
   and closure phase. Operation is performed inplace.

   PARAMETERS

   EXAMPLES
   > oiFitsSwapBaseline, oiVis2, base="E0-G0";

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsSwapBaseline()";
  local i, ids, tel, u1, u2, v1, v2;
  if ( !yocoTypeIsString(base) )  return yocoError("base should be a string array");
  
  /* Swap the oiVis2 */
  if ( is_array( oiVis2 ) &&
       is_array( (ids = where( oiFitsGetBaseName(oiVis2, oiArray)==base )) ) )
  {
    oiVis2(ids).staIndex = oiVis2(ids).staIndex([2,1],);
    oiVis2(ids).uCoord *= -1;
    oiVis2(ids).vCoord *= -1;
  }

  /* Swap the oiVis */
  if ( is_array(oiVis) &&
       is_array( (ids = where( oiFitsGetBaseName(oiVis, oiArray)==base )) ) )
  {
    oiVis(ids).staIndex = oiVis(ids).staIndex([2,1],);
    oiVis(ids).uCoord *= -1;
    oiVis(ids).vCoord *= -1;
    /* FIXME: invert the complex data */
    oiFitsOperandStructDataArray, oiVis, ids, "visPhi", -1.0, "*";
  }

  /* Swap the oiT3 FIXME: check it better */
  if ( is_array(oiT3) )
  {
    tel = oiFitsGetStationName(oiT3,oiArray);
    u1  = oiT3.u1Coord; u2  = oiT3.u2Coord;
    v1  = oiT3.u1Coord; v2  = oiT3.v2Coord;
    
    /* If first baseline */
    if (is_array((ids = where( tel(1,)+"-"+tel(2,)==base)))) {
      oiT3(ids).staIndex = oiT3(ids).staIndex([2,1,3],);
      oiT3(ids).u1Coord  = -u1(ids);
      oiT3(ids).v1Coord  = -v1(ids);
      oiT3(ids).u2Coord  = +u1(ids)+u2(ids);
      oiT3(ids).v2Coord  = +v1(ids)+v2(ids);
      oiFitsOperandStructDataArray, oiT3, ids, "t3Phi", -1.0, "*";
    }
      
    /* If second baseline */
    if (is_array((ids = where( tel(2,)+"-"+tel(3,)==base)))) {
      oiT3(ids).staIndex = oiT3(ids).staIndex([1,3,2],);
      oiT3(ids).u1Coord  = +u1(ids)+u2(ids);
      oiT3(ids).v1Coord  = +v1(ids)+v2(ids);
      oiT3(ids).u2Coord  = -u2(ids);
      oiT3(ids).v2Coord  = -v2(ids);
      oiFitsOperandStructDataArray, oiT3, ids, "t3Phi", -1.0, "*";
    }

    /* If third baseline */
    if (is_array((ids = where( tel(3,)+"-"+tel(1,)==base)))) {
      error,"no implemented yet";
    }
  }

  yocoLogTrace,"oiFitsSwapBaseline done";
  return 1;
}

func oiFitsRotateUV(&oiVis2, &oiVis, &oiT3, phi)
/* DOCUMENT oiFitsRotateUV(&oiVis2, &oiVis, &oiT3, phi)

   DESCRIPTION
   Rotate the u/v of the oiData. Operation is performed in place.

   PARAMETERS
   - oiVis2, oiVis, oiT3:
   - phi: angle, in radian.
 */
{
  yocoLogInfo,"oiFitsRotateUV()";
  local u, v, w;
  local cosPhi, sinPhi;
  cosPhi = cos(phi);
  sinPhi = sin(phi);

  /* Rotate the oiVis2 */
  if (is_array(oiVis2) && oiFitsIsOiVis2(oiVis2)) {
    u = oiVis2.uCoord;
    v = oiVis2.vCoord;
    oiVis2.uCoord = u*cosPhi + v*sinPhi;
    oiVis2.vCoord = v*cosPhi - u*sinPhi;
  }

  /* Rotate the oiVis */
  if (is_array(oiVis) && oiFitsIsOiVis(oiVis)) {
    u = oiVis.uCoord;
    v = oiVis.vCoord;
    oiVis.uCoord = u*cosPhi + v*sinPhi;
    oiVis.vCoord = v*cosPhi - u*sinPhi;
  }

  /* Rotate the oiT3 */
  if (is_array(oiT3) && oiFitsIsOiT3(oiT3)) {
    u = oiT3.u1Coord;
    v = oiT3.v1Coord;
    oiT3.u1Coord = u*cosPhi + v*sinPhi;
    oiT3.v1Coord = v*cosPhi - u*sinPhi;
    u = oiT3.u2Coord;
    v = oiT3.v2Coord;
    oiT3.u2Coord = u*cosPhi + v*sinPhi;
    oiT3.v2Coord = v*cosPhi - u*sinPhi;
  }

  yocoLogTrace,"oiFitsRotateUV done";
  return 1;
}

/* --- */

func oiFitsRenameInsName(&oiVis2, &oiVis, &oiT3, &oiWave, oldName=, newName=)
/* DOCUMENT oiFitsRenameInsName(&oiVis2, &oiVis, &oiT3, &oiWave, oldName=, newName=)

   DESCRIPTION
   Renamce the insName of some observations to have them match with another
   oiWave.

   EXAMPLES
   > oiFitsRenameInsName, oiVis2, oiVis, oiT3,
   >   oldName="PIONIER_Pnat(1.5986703/1.7694443)",
   >   newName="PIONIER_Pnat(1.5934566/1.7673803)";
*/
{
  yocoLogInfo,"oiFitsRenameInsName()";

  if (is_array(oiVis2))
    if (is_array((id=where(oiVis2.hdr.insName==oldName))) )
      oiVis2(id).hdr.insName = newName;

  if (is_array(oiVis))
    if (is_array((id=where(oiVis.hdr.insName==oldName))) )
      oiVis(id).hdr.insName = newName;

  if (is_array(oiT3))
    if (is_array((id=where(oiT3.hdr.insName==oldName))) )
      oiT3(id).hdr.insName = newName;

  yocoLogTrace,"oiFitsRenameInsName done";
  return 1;
}

/* --- */

func oiFitsUpdateOiWave(&oiWave, oldName=, effWave=, effBand=)
/* DOCUMENT oiFitsUpdateOiWave(&oiWave, oldName=, effWave=, effBand=)

   DESCRIPTION
   Update the effWave and effBand of a given oiWave. Only works
   if the number of spectral channel is the same.

   CAUTIONS: You should use oiFitsUpdateInsName after.

   EXAMPLES
   > oiFitsUpdateOiWave, oiWave,
     oldName="PIONIER_Pnat(1.5986703/1.7694443)",
     effWave=[1.595e-6,1.678e-6,1.768e-6],
     effBand=[9.35e-8,9.35e-8,9.35e-8];
   >
   > oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;
   > 
 */
{
  yocoLogInfo,"oiFitsUpdateOiWave()";

  /* Search for the oiWave to update */
  id = where(oiWave.hdr.insName == oldName);
  if (!is_array(id)) {
    yocoLogInfo,"No oiWave with this insName.";
    return 1;
  }

  id = id(1);
  if (numberof(*oiWave(id).effWave)!=numberof(effWave) ||
      numberof(effWave) != numberof(effBand)) {
    yocoError,"oiWave has a different number of channel than effWave.";
    return 0;
  }

  /* Replace the data */
  oiWave( id ).effWave = &effWave;
  oiWave( id ).effBand = &effBand;

  yocoLogTrace,"oiFitsUpdateOiWave done";
  return 1;
}

/* --- */


func oiFitsUpdateInsName(&oiWave, &oiVis2, &oiVis, &oiT3)
/* DOCUMENT oiFitsUpdateInsName(&oiWave, &oiVis2, &oiVis, &oiT3)

   DESCRIPTION
   Change the insName, by adding the first and last spectral wavelength
   bin, so that the insName becomes perfectly unique for each
   wavelegnth table.

   PARAMETERS
   - oiWave, oiVis2, oiVis, oiT3: 
 */
{
  yocoLogTrace,"oiFitsUpdateInsName()";
  local i,insNameOld,id,lbd;
  local s1,d1,d2,s2;
  
  /* Loop on the oiWave -> oiData without oiWave will not be updated */
  for ( i=1; i<=numberof(oiWave); i++ ) {
    s1 = s2 = "";
    d1 = d2 = 0.0;
    
    /* Extract the wavelength and create the new insName */
    insNameOld = oiWave(i).hdr.insName;
    lbd = oiFitsGetLambda(oiWave(i));

    /* If AMBER, add the lbd in the insName */
    if ( strmatch(insNameOld, "AMBER") || strmatch(insNameOld, "PIONIER") || strmatch(insNameOld, "SPECTRO_")) {
      sread, insNameOld, format="%[^(](%f/%f)%s",s1,d1,d2,s2;
      oiWave(i).hdr.insName = swrite(format="%s(%.7f/%.7f)%s",s1,lbd(1),lbd(0),s2);
    } else {
      continue;
    }

    /* Refill the structures corresponding to this oiWave */
    if( is_array(oiT3) && is_array((id=where(oiT3.hdr.insName==insNameOld))) )
      oiT3(id).hdr.insName   = oiWave(i).hdr.insName;
    if( is_array(oiVis2) && is_array((id=where(oiVis2.hdr.insName==insNameOld))) )
      oiVis2(id).hdr.insName = oiWave(i).hdr.insName;
    if( is_array(oiVis) && is_array((id=where(oiVis.hdr.insName==insNameOld))) )
      oiVis(id).hdr.insName  = oiWave(i).hdr.insName;
  }

  /* Clean in case redundant */
  oiWave = yocoListClean(oiWave,oiWave.hdr.insName);

  yocoLogTrace,"oiFitsUpdateInsName done";
  return 1;
}

/* --- */

func oiFitsDataWaveWorker(&oiData,oiWave,action,param)
/* DOCUMENT oiFitsDataWaveWorker(&oiData,oiWave,action,param)

   DESCRIPTION
   PRIVATE FUNCTION
 */
{
  yocoLogTrace,"oiFitsDataWaveWorker()";
  local i,lbd, lbdTmp,_oiData, id;
  local amp,damp,dphi,phi,plocal;

  /* check param */
  if (is_void(oiData)) return 1;
  if (!oiFitsIsOiDataOrWave(oiData)) return yocoError("oiData not valid");
  if (!oiFitsIsOiWave(oiWave))       return yocoError("oiWave not valid");

  /* Prepare output */
  _oiData = [];

  /* Loop on oiData */
  for (i=1; i<= numberof(oiData);i++) {
    
    /* Get data */
    lbd = oiFitsGetLambda(oiData(i),oiWave);
    oiFitsGetData, oiData(i), amp, damp, phi, dphi, flag, 1;

    /* Manipulate the data */
    if (action=="interp") {

      /* check if anyof is inside the interval */
      lbdTmp = param( oiFitsGetIntervId([min(lbd),max(lbd)], param) );
      if ( !is_array(lbdTmp) ) continue;

      lbdTmp = param;
      amp  = interp(amp,lbd,lbdTmp);
      damp = interp(damp,lbd,lbdTmp);
      phi  = interp(phi,lbd,lbdTmp);
      dphi = interp(dphi,lbd,lbdTmp);
      flag = flag(min(digitize(lbdTmp, lbd),numberof(lbd)));
      
    } else if (action=="spline") {
      
      /* check if anyof is inside the interval */
      lbdTmp = param( oiFitsGetIntervId([min(lbd),max(lbd)], param) );
      if ( !is_array(lbdTmp) ) continue;
      
      lbdTmp = param;
      amp  = spline(amp,lbd,lbdTmp);
      damp = spline(damp,lbd,lbdTmp);
      phi  = spline(phi,lbd,lbdTmp);
      dphi = spline(dphi,lbd,lbdTmp);
      flag = flag(min(digitize(lbdTmp, lbd),numberof(lbd)));
      
    } else if (action=="cut") {

      id = oiFitsGetIntervId(param, lbd);
      if ( !is_array(id) ) continue;
      amp  = amp(id);
      damp = damp(id);
      phi  = phi(id);
      dphi = dphi(id);
      flag = flag(id);

    } else if (action=="flag") {

      id = oiFitsGetIntervId(param, lbd);
      if ( is_array(id) ) flag(id) += 1;

    } else if (action=="unflag") {

      id = oiFitsGetIntervId(param, lbd);
      if ( is_array(id) ) flag(id) = char(0);

    } else if (action=="sort") {
      
      id = sort(lbd);
      amp  = amp(id);
      damp = damp(id);
      phi  = phi(id);
      dphi = dphi(id);
      flag = flag(id)
        
    } else if (action=="average") {
      
      oiFitsAverageData, amp, damp, lbd, param, noX=1, phase=0;
      oiFitsAverageData, phi, dphi, lbd, param, noX=1, phase=1;
      flag = array(char(0),dimsof(amp));
        
    } else if (action=="shift") {
      
      plocal = _get_param(param,i);
      amp  = roll(amp,  plocal);
      damp = roll(damp, plocal);
      phi  = roll(phi,  plocal);
      dphi = roll(dphi, plocal);
      flag = roll(flag, plocal);
        
    } else {
      yocoError,"action not coded yet !";
    }

    /* Fill output */
    grow, _oiData, oiData(i);
    oiFitsSetData, _oiData, 0, amp, damp, phi, dphi, flag;
    
  } /* end loop on oiData */

  /* Put back the resulting array */
  oiData = _oiData;

  yocoLogTrace,"oiFitsDataWaveWorker done";
  return _oiData;
}


/* --- */

func oiFitsKeepWave(&oiWave,&oiVis2,&oiVis,&oiT3,wlimit=)
/* DOCUMENT oiFitsKeepWave(&oiWave,&oiVis2,&oiVis,&oiT3,wlimit=)

   DESCRIPTION
   Cut the wavelength dimention. Cut is done in all
   oiData passed in argument, as well as in oiWave.

   Only works with 'pointer' data.

   PARAMETERS
   - oiVis2, oiVis, oiT3, oiWave:
   - wlimit: limit of the cut, in mum (10-6m), with possible format:
             [start,end] -or-
             [[s1,e1],[s2,e2],...,[sN,eN]]
 */
{
  local lbd,_oiVis2,_oiVis,_oiT3,_oiWave,i;
  _oiVis2 = _oiVis = _oiT3 = _oiWave = [];
  yocoLogTrace,"oiFitsKeepWave()  --  info: to be used only with 'pointer' data";

  /* Check the mode */
  if ( oiFitsStructNumMode(oiWave)!=-1 ) {
    return yocoError("oiFitsKeepWave can only be used with 'pointer' data",
                     "reload your data using: \"oiFitsLoadFiles,...,readMode=-1\"");
  }
  
  /* Check for arguments */
  if( !oiFitsIsOiWave(oiWave) )
    return yocoError("oiWave not valid");

  /* default values */
  if (is_void(wlimit)) wlimit = [0,10.0];
  
  /* Execute the action */
  oiFitsDataWaveWorker, oiVis2, oiWave, "cut", wlimit;
  oiFitsDataWaveWorker, oiVis,  oiWave, "cut", wlimit;
  oiFitsDataWaveWorker, oiT3,   oiWave, "cut", wlimit;
  oiFitsDataWaveWorker, oiWave, oiWave, "cut", wlimit;

  /* Update the insName with the these news cuts */
  oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;
  
  yocoLogTrace,"oiFitsKeepWave done";
  return 1;
}

/* --- */

func oiFitsFlagWave(&oiVis2,&oiVis,&oiT3,wlimit=)
/* DOCUMENT oiFitsFlagWave(&oiVis2,&oiVis,&oiT3,wlimit=)

   DESCRIPTION
   Cut the wavelength dimention. Flag is done in all
   oiData passed in argument.

   Only works with 'pointer' data.

   PARAMETERS
   - oiVis2, oiVis, oiT3:
   - wlimit: limit of the cut, in mum (10-6m), with possible format:
             [start,end] -or-
             [[s1,e1],[s2,e2],...,[sN,eN]]
 */
{
  yocoLogTrace,"oiFitsFlagWave()  --  info: to be used only with 'pointer' data";

  /* default values */
  if (is_void(wlimit)) wlimit = [0,10.0];
  
  /* Execute the action */
  oiFitsDataWaveWorker, oiVis2, oiWave, "flag", wlimit;
  oiFitsDataWaveWorker, oiVis,  oiWave, "flag", wlimit;
  oiFitsDataWaveWorker, oiT3,   oiWave, "flag", wlimit;

  yocoLogTrace,"oiFitsFlagWave done";
  return 1;
}

/* --- */

 func oiFitsInterpWave(&oiWave,&oiVis2,&oiVis,&oiT3,lbdNew=,mode=)
/* DOCUMENT oiFitsInterpWave(&oiWave,&oiVis2,&oiVis,&oiT3,lbdNew=,mode=)

   DESCRIPTION
   Interp the spectral direction at lbdNew (in mum).
   Works only with 'pointer' data.

   FIXME: flag parameter is not interp, since this crash.

   PARAMETERS:
   - oiWave:
   - oiVis2, oiVis, oiT3:
   - mode :  can be "interp" (default) or "spline"
 */
{
  local lbd,_oiVis2,_oiVis,_oiT3,_oiWave,i;
  _oiVis2 = _oiVis = _oiT3 = _oiWave = [];
  yocoLogInfo,"oiFitsInterpWave()  --  info: will change the wavelength table.";

  /* Check the mode */
  if ( oiFitsStructNumMode(oiWave)!=-1 ) {
    return yocoError("oiFitsInterpWave can only be used with 'pointer' data",
                     "reload your data using: \"oiFitsLoadFiles,...,readMode=-1\"");
  }
  
  /* Check for arguments */
  if( !oiFitsIsOiWave(oiWave) )
    return yocoError("oiWave not valid");

  /* default values */
  if (is_void(lbdNew)) lbdNew = [1.3,1.8,2.3];
  if (is_void(mode))   mode   = "interp";

  /* Check lbdNew */
  if (dimsof(lbdNew)(1)>1) {
    return yocoError("lbdNew should be a 1D array");
  }

  /* Execute the action */
  oiFitsDataWaveWorker, oiVis2, oiWave, mode, lbdNew;
  oiFitsDataWaveWorker, oiVis,  oiWave, mode, lbdNew;
  oiFitsDataWaveWorker, oiT3,   oiWave, mode, lbdNew;
  oiFitsDataWaveWorker, oiWave, oiWave, mode, lbdNew;

  /* Update the insName with the these news cuts */
  oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;

  yocoLogTrace,"oiFitsInterpWave done";
  return 1;
}

/* --- */

func oiFitsSortWave(&oiWave, &oiVis2, &oiVis, &oiT3)
/* DOCUMENT oiFitsSortWave(&oiWave, &oiVis2, &oiVis, &oiT3)

   DESCRIPTION
   Resort the oiWave structure to be monotony increasing.
   Sample is so re-sorted on all oiFitss.

   FIXME: flag parameter is not sorted, since this crash.

   PARAMETERS:
   - oiWave:
   - oiVis2, oiVis, oiT3:
   
   EXAMPLES
   > oiFitsSortWave, oiWave, oiVis2, oiVis, oiT3;
 */
{
  yocoLogTrace,"oiFitsSortWave() ";
  local i, w;

  /* Check parameters */
  if( !oiFitsIsOiWave(oiWave) )                    return yocoError("oiWave not valid");
  if( is_array(oiVis2) && !oiFitsIsOiVis2(oiVis2)) return yocoError("oiVis2 not valid");
  if( is_array(oiVis) && !oiFitsIsOiVis(oiVis))    return yocoError("oiVis not valid");
  if( is_array(oiT3) && !oiFitsIsOiT3(oiT3))       return yocoError("oiT3 not valid");

  /* Execute the action */
  oiFitsDataWaveWorker, oiVis2, oiWave, "sort", lbdNew;
  oiFitsDataWaveWorker, oiVis,  oiWave, "sort", lbdNew;
  oiFitsDataWaveWorker, oiT3,   oiWave, "sort", lbdNew;
  oiFitsDataWaveWorker, oiWave, oiWave, "sort", lbdNew;

  /* Update the insName with the these news cuts */
  oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;

  yocoLogTrace,"oiFitsSortWave done";
  return 1;
}

/* --- */

func oiFitsAverageWave(&oiWave, &oiVis2, &oiVis, &oiT3, Avg=)
/* DOCUMENT oiFitsAverageWave(&oiWave, &oiVis2, &oiVis, &oiT3, Avg=)

   DESCRIPTION
   Average the oiWave structure.
   For Avg parameter see oiFitsAverageData.

   PARAMETERS:
   - oiWave:
   - oiVis2, oiVis, oiT3:
   
   EXAMPLES
   > oiFitsAverageWave, oiWave, oiVis2, oiVis, oiT3;
 */
{
  yocoLogInfo,"oiFitsAverageWave() ";
  local i, w;

  /* Check parameters */
  if( !oiFitsIsOiWave(oiWave) )                    return yocoError("oiWave not valid");
  if( is_array(oiVis2) && !oiFitsIsOiVis2(oiVis2)) return yocoError("oiVis2 not valid");
  if( is_array(oiVis) && !oiFitsIsOiVis(oiVis))    return yocoError("oiVis not valid");
  if( is_array(oiT3) && !oiFitsIsOiT3(oiT3))       return yocoError("oiT3 not valid");

  /* Execute the action */
  oiFitsDataWaveWorker, oiVis2, oiWave, "average", Avg;
  oiFitsDataWaveWorker, oiVis,  oiWave, "average", Avg;
  oiFitsDataWaveWorker, oiT3,   oiWave, "average", Avg;
  oiFitsDataWaveWorker, oiWave, oiWave, "average", Avg;

  /* Update the insName with the these news cuts */
  oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;

  yocoLogTrace,"oiFitsAverageWave done";
  return 1;
}

/* --- */

func oiFitsShiftWave(&oiWave,shift=)
/* DOCUMENT oiFitsShiftWave(&oiWave,shift=)

   DESCRIPTION
   Shift the oiWave by a spectral offset, defined
   in micron (10-6m). Default shift is -0.01mum.

   PARAMETERS
   - shift: double, can be a scalar or an array of the
            same dimention than oiWave.
 */
{
  local i;
  yocoLogTrace,"oiFitsShiftWave()";

  /* Check for arguments */
  if( !oiFitsIsOiWave(oiWave) ) yocoError("oiWave not valid");

  /* default values */
  if (is_void(shift)) shift = -0.01;
  
  /* Loop on the oiWave */
  for (i=1; i<= numberof(oiWave) ; i++) {
    _ofSSDs, oiWave, i, "effWave", _ofGSD(oiWave(i),"effWave") + _get_param(shift,i) * 1e-6;
  }
  
  yocoLogTrace,"oiFitsShiftWave done";
  return 1;
}

/* --- */

func oiFitsAverageSample(&x,&dx,errMode=,which=,phase=)
/* DOCUMENT oiFitsAverageSample(&x,&dx,errMode=,which=,phase=)

   DESCRIPTION
   Average the array x over the WHICH dimension, taking into
   account the dx error.

   PARAMETERS
   - x, dx: input/output
   - which= dimension on which the average should be done
   - phase=1 means the data are phases
   - errMode=
     0: Err = sqrt(variance * chi2 * correctif), so that
        if chi2~1 Err=sqrt(variance) and if
        chi2>>1 Err=Rms(x)
        
     1: Err = sqrt(variance * chi2), so that if chi2>>1
        Err = Rms(x)/sqrt(n)
        
     2: Err = sqrt(variance), so standar error.

     3: Err = sqrt( 1 / Avg(1/dx2) ), so it return the
        'typical error' within the sample.

     4: Err = Rms(x)

     Default is errMode=0 since this is sort of 'adaptive'
     conservative assumption.
 */
{
  local out, dout, n, chi2, xp, op;
  if (is_void(errMode)) errMode=0;
  
  /* If which is specified, we transpose to the first dim */
  if (is_array(which)) {
    x  = transpose(x,indgen(which));
    dx = transpose(dx,indgen(which));
  }
  /* Found the number of sample
     keep only sample with decent error bars */
  n  = dimsof(dx)(2);
  if (n==1) {x=x(1,); dx=dx(1,);return;}

  /* keep only non-dummy samples when computing chi2r */
  n  = (dx<1e5)(sum,);
  
  /* Avoid zero dx when computing the average */
  dx += 1.e-20;
  idx2 = dx^-2;

  /* Standar variance of the average, considering dx*/
  dout2 = (idx2)(sum,)^-1;
  
  /* Compute average. In case of phase we use phasors */
  if (phase==1) {
    /* Compute phasors */
    xp  = exp(1.i*pi/180.0*x);
    op  = (xp*idx2)(sum,);
    /* Average */
    out = oiFitsArg( op ) / pi * 180.0;
    /* Recenter x and compute reduced Chi2 */
    x = oiFitsArg( xp * conj(op)(-,) ) / pi * 180.0;
    chi2  = max( (x^2 * idx2 )(sum,) / (n-1+(n==1)),  1.0);
  }
  else {
    /* Average */
    out = ( (x*idx2)(sum,) ) / ( idx2(sum,) );
    /* Reduced Chi2 */
    chi2  = max( ((x-out(-,))^2 * idx2 )(sum,) / (n-1+(n==1)),  1.0);
  }

  
  /* Compute the error bars */
  if (errMode==0) {
    /* Increase error because of dispersion, non-standar:
       error = sqrt(chi2 * variance * correctif)
       Because of last therm, if chi2>>1, this tends to:
       error = RMS(x)         */
    dout  = sqrt( chi2 * dout2 * (n-1.)^(1.-1./chi2^2) );
  }
  else if (errMode==1) {
    /* Increase error because of dispersion, standar:
       error = sqrt(chi2 * variance)
       If chi2>>1, this tends to
       error = RMS(x)/sqrt(n)    */
    dout = sqrt( chi2 * dout2 );
  }
  else if (errMode==2) {
    /* Standar: error = sqrt(variance) */
    dout = sqrt( dout2 );
  }
  else if (errMode==3) {
    /* error = averaged_error
       In case you don't want to really average by to have
       an 'average' overview of the sample accuracy */
    dout = sqrt( (idx2)(avg,)^-1 );
  }
  else if (errMode==4) {
    dout = x(rms,);
  }
  else if (errMode==5) {
    /* Conservative approach: quadratic sum of the
       rms and the average error */
    dout = sqrt( x(rms,)^2. + dx(avg,)^2 );
  }
  else if(errMode==-2) {
    /* Standar: error = sqrt(variance),
       but deal with phases for the average (FIXME: deprecated) */
    yocoError,"FIXME: deprecated.";
    return 0;
  }
  else {
    yocoError,"errMode not valid.";
  }
  
  /* Return it */
  x  = out;
  dx = dout;
  return 1;
}

/* --- */

func oiFitsAverageData(&y,&dy,&x,Avg,noX=,phase=)
/* DOCUMENT oiFitsAverageData(&y,&dy,&x,Avg,noX=,phase=)

   DESCRIPTION
     Perform an average on the data

   PARAMETERS
   - y, dy, x: Arrays containing data. They should have a single dimention,
           on which the average will be performed.

   - if noX=1, the X array is not modified.

   - Avg : Parameter to define the average type: interval, all samples,
           moving average.

   ** All samples (Avg=1):
      x  = x(avg)
      y  = (y/dy2)(sum) / (1/dy2)(sum);
      dy =  sqrt( 1 / (1/dy2)(sum) );

   ** Moving average (Avg>1):
      x = yocoMathMovingAvg(x,Avg)
      y = yocoMathMovingAvg(y,Avg,dy)

   ** Interval (Avg is an array):
      Avg is an array of double, defining interval in the x-dimension:
      Avg = [Start,End], or [[Start1,End1], [Start2,End2], ..., [Starti,Endi]]
      All sample inside the interval are averaged.
*/
{
  local id, xRef;
  
  /* default for y */
  if ( is_void(x) )  x  = indgen(numberof(y));
  if ( is_void(dy) ) dy = 1. + 0.*indgen(numberof(y));
  dy = max(dy,1e-10);
  xRef = x;

  /* Average depending on the case */
  if (typeof(Avg)=="double" && numberof(Avg)>=2) {
    id = oiFitsGetIntervId(Avg,wave);
    if (is_array(id)) {
      x = x(avg)(*);
      y = y(id)(,-); dy = dy(id)(,-);
      oiFitsAverageSample, y, dy, which=1, errMode=3,phase=phase;
    } else {
      x = [0.0]; y = [0.0]; dy = [0.0];
    }
  }
  else if (Avg>1 ) {
    x  = yocoMathMovingAvg(x,Avg);
    y  = yocoMathMovingAvg(y,Avg,dy);
  }
  else if (Avg==1 ) {
    x  = avg(x);
    y  = sum( y*dy^-2. ) / sum(dy^-2.) ;
    dy = 1./ sqrt( sum(dy^-2.) );
    x = [x]; y = [y]; dy = [dy];
  }
  else if (Avg==-1 ) {
    id = numberof(y)/2 + indgen(-3:+3);
    x  = x(id)(avg);
    y  = sum( y(id)*dy(id)^-2. ) / sum(dy(id)^-2.);
    dy = 1./ sqrt( sum(dy(id)^-2.) );
    x = [x]; y = [y]; dy = [dy];
  }
  else if (Avg==-2 ) {
    x  = x(avg);
    dy = (min(y) - max(y) ) /2.0;
    y  = (min(y) + max(y) ) /2.0;
    x = [x]; y = [y]; dy = [dy];
  }

  /* eventually restore x */
  if (noX) x = xRef;

  return 1;
}

/* --- */

func oiFitsAverageOiData(oiData,&oiOut,errMode=)
/* DOCUMENT oiFitsAverageOiData(oiData,&oiOut,errMode=)

   DESCRIPTION
   Average the set of oiData into a single oiData. The
   oiData.hdr.insName should all be identical to ensure
   the data set have same wavelength table.
   The header-data of the first obs are copied into the output:
   oiOut.hdr = oiData(1).hdr;

   WARNING
   The following data are not taken into account:
   oiT3.oit3Amp, oiVis.visData, oiVis.visAmp

   PARAMETERS
   - oiData oiOut: input / output
   
   - errMode= see oiFitsAverageSample
*/
{
  yocoLogTrace,"oiFitsAverageOiData()";
  local y, dy;
  
  /* Data should have the same insName */
  if (!oiFitsIsOiData(oiData))
    return yocoError("oiData not valid");
  if (anyof(oiData.hdr.insName!=oiData(1).hdr.insName))
    return yocoError("oiData should all have the same insName");

  /* Prepare the output, the hdr is the one of the first oiData */
  oiOut = oiData(1);
  oiOut.time = oiData.time(avg);
  oiOut.mjd  = oiData.mjd(avg);
  oiOut.intTime = oiData.intTime(sum);

  /* FIXME: hard to be fixed, but normaly in ESO convention the DATE-OBS and MJD-OBS
     are updated according to the averaging of files */
  
  /* UV plane */
  if (oiFitsIsOiT3(oiData)) {
    oiOut.u1Coord = oiData.u1Coord(avg);
    oiOut.v1Coord = oiData.v1Coord(avg);
    oiOut.u2Coord = oiData.u2Coord(avg);
    oiOut.v2Coord = oiData.v2Coord(avg);
  } else {
    oiOut.uCoord = oiData.uCoord(avg);
    oiOut.vCoord = oiData.vCoord(avg);
  }

  /* Get data*/
  oiFitsGetData, oiData(*), amp, damp, phi, dphi, flag, 1;

  /* Average data */
  oiFitsAverageSample, amp, damp, errMode=errMode, which=2, phase=0;
  oiFitsAverageSample, phi, dphi, errMode=errMode, which=2, phase=1;

  /* FIXME: Flag is not really deal with.
     Trick: data with huge errors
     will be flagged by oiFistSetData. */
  flag = array(char(0), dimsof(amp));

  /* Fill output structure */
  oiFitsSetData, oiOut, 1, amp, damp, phi, dphi, flag;

  yocoLogTrace,"oiFitsAverageOiData done";
  return 1;
}

/* --- */

func oiFitsGroupAllOiData(&oiVis2, &oiVis, &oiT3, oiLog, funcSetup=, dtime=, errMode=)
/* DOCUMENT oiFitsGroupAllOiData(&oiVis2, &oiVis, &oiT3, oiLog, funcSetup=, dtime=, errMode=)

   DESCRIPTION
   Same as oiFitsGroupOiData but:
   - in place (structure are replaced by grouped one)
   - all oiVis2, oiVis and oiT3 at the same time

   PARAMETERS
   - oiVis2, oiVis, oiT3, oiLog : standart oiStructures
   - funcSetup, dtime, errMode  : see oiFitsGroupOiData
 */
{
  yocoLogTrace,"oiFitsGroupAllOiData()";

  /* Perform the action inplace */
  if (is_array(oiVis2))
    oiFitsGroupOiData, oiVis2, oiLog, oiVis2, funcSetup=funcSetup, dtime=dtime, errMode=errMode;
  if (is_array(oiVis))
    oiFitsGroupOiData, oiVis,  oiLog, oiVis,  funcSetup=funcSetup, dtime=dtime, errMode=errMode;
  if (is_array(oiT3))
    oiFitsGroupOiData, oiT3,   oiLog, oiT3,   funcSetup=funcSetup, dtime=dtime, errMode=errMode;
  
  yocoLogTrace,"oiFitsGroupAllOiData done";
  return 1;
}

func oiFitsFindGroupOiData(oiData, oiLog, oiAll, funcSetup=, dtime= )
{
  local tmp, setup, grpId;
  yocoLogTrace,"oiFitsFindGroupOiData()";

  /* Default parameters */
  if (is_void(oiAll)) oiAll=oiData;
  if (is_void(dtime)) dtime = 6./24./60.;
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;
  
  /* Find the groups */
  tmp = oiData.mjd +
    100.*oiFitsGetTargetId( oiData ) +
    10000.*oiFitsGetSetupId(oiData, oiLog, oiAll) +
    1000000.*oiFitsGetBaseId( oiData, oiAll);
  setup = oiFitsFindGroupId( tmp, dtime );
  grpId = yocoListUniqueId( setup );
  
  yocoLogTrace,"oiFitsFindGroupOiData done";
  return grpId;
}

func oiFitsGroupOiData(oiData, oiLog, &oiOut, funcSetup=, dtime=, errMode=)
/* DOCUMENT oiFitsGroupOiData(oiData, oiLog, &oiOut, funcSetup=, dtime=, errMode=)

   DESCRIPTION
   Find group of conformable, consecutive data: same setup, same baseline,
   same target and close in time (less than dtime between consecutive files).
   Then average each group into a single oiData, with command
   oiFitsAverageOiData.

   PARAMETERS
   - oiData, oiLog: input
   - oiOut: output
   
   - dtime= maximum difference of mjd between files so that they
     are considered to be member of the same group. Default is 6min.
            
   - errMode= see oiFitsAverageOiData
   
   - funcSetup= (optional) temporary override 'oiFitsDefaultSetup'
     see the help of 'oiFitsDefaultSetup' for more information
 */
{
  yocoLogInfo,"oiFitsGroupOiData()";

  /* Check the parameters */
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;
  if (!oiFitsIsOiLog(oiLog)) return yocoError("oiLog not valid");
  if (is_void(dtime)) dtime = 6./24./60.;
  
  /* Prepare outputs */
  local oiTmp, oiOutTmp, i, id, grpId, setup;
  oiOutTmp =  [];
  
  /* Found the groups */
  tmp = oiData.mjd +
    100.*oiFitsGetTargetId( oiData ) +
    10000.*oiFitsGetSetupId(oiData, oiLog, funcSetup=funcSetup) +
    1000000.*oiFitsGetBaseId( oiData );
  setup = oiFitsFindGroupId( tmp, dtime );
  grpId = yocoListUniqueId( setup );

  /* Average consecutive oiData */
  for (i=1 ; i<=max(grpId) ; i++) {
    /* Get oiData for this group */
    id = where(grpId==i);
    
    /* Average them */
    oiFitsAverageOiData, oiData(id), oiTmp, errMode=errMode;
    /* grow the output array */
    grow, oiOutTmp, oiTmp;
  }

  /* Fill the output structure (necessary to do so because
     structure are passed as pointers). */
  oiOut = oiOutTmp;
    
  yocoLogTrace,"oiFitsGroupOiData done";
  return 1;
}

/* --- */

func _oiFitsCont(&y,&dy,lbd,cont0,add=,order=)
/* DOCUMENT _oiFitsCont(&y,&dy,lbd,cont0,add=,order=)

   DESCRIPTION
   Worker for oiFitsNormalizeContinuum
   
 */
{
  local id,cont,tmp,i;
  /* compute the continuum */
  if (is_void(dy) )    dy=y*0.+1;
  if (is_void(order))  order=2;
  id  = oiFitsGetIntervId(cont0,lbd);

  /* Prepare and execute the regression */
  for (tmp=[],i=0;i<=order;i++) grow,tmp,[lbd]^i;
  poly = regress(y(id), tmp(id,), sigy=dy(id)+1e-10);
  
  /* Prepare and execute the regression */
  for (cont=0,i=1;i<=numberof(poly);i++) cont += poly(i)*lbd^(i-1);
  
  /* Normalize */
  if (add) {
    y = y - cont;
  } else {
    dy   = dy / (cont + (cont==0));
    y    = y  / (cont + (cont==0));
  }
  
  return 1;
}

/* --- */

func oiFitsNormalizeContinuum(&oiData,oiWave,cont=,order=,checkPlot=)
/* DOCUMENT oiFitsNormalizeContinuum(&oiData,oiWave,cont=,order=,checkPlot=)

   DESCRIPTION
   Self-normalize of the oiData so that the continuum has:
   vis2=1, t3phi=0, visPhi=0. Note that others quantities
   are not normalized yet.

   Continuum is estimated within the intervals 'cont', and is
   fitted by a polynomial law of order 'order'.

   PARAMETERS
   - oiWave, oiData:
   - cont= interval where estimating the continuum, in mum,
           can use the following syntaxes:
           [start, end] or [ [Starta,Enda],...,[Starti,Endi] ]
   - checkPlot= optional window number to visualy check the
           calibration.
   - order= of the polynomial law to be fitted.
*/
{
  local i,amp,amp0,damp, phi,phi0,dphi, lbd,add;
  yocoLogTrace,"oiFitsNormalizeCont()";

  /* Default values */
  if ( is_void(cont) ) cont = [0,10.0];

  /* Check parameters */
  if( !oiFitsIsOiWave(oiWave) ) return yocoError("oiWave not valid");
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");

  /* Loop on the oiData */
  for (i=1; i<= numberof(oiData);i++) {
    
    /* Extract data */
    lbd = oiFitsGetLambda(oiData(i),oiWave);
    oiFitsGetData, oiData(i), amp, damp, phi, dphi, flag, 1;

    /* Store original data in case a plot if needed */
    amp0 = amp; phi0 = phi;
    
    /* Compute and normalize the continuum */
    _oiFitsCont, amp, damp, lbd, cont, add=0, order=order;
    _oiFitsCont, phi, dphi, lbd, cont, add=1, order=order;
    
    /* Put back data */
    oiFitsSetData, oiData, i, amp, damp, phi, dphi, flag;
    
    /* optional plot checking */
    if (checkPlot) {
      /* Prepare window */
      yocoNmCreate,check,1,2,dy=0.1,fx=1; fma;
      yocoNmMainTitle,"Check continuum. order="+pr1(order);
      /* Plot direct space */
      plsys,1;
      plg,amp0,lbd,width=3;
      plg,amp, lbd,color="red";
      yocoPlotVertLine, cont, color="green",type=3;
      xytitles,"lbd (mum)","data";
      /* Prompt to wait for user */
      rdline,prompt="Check cleaning in window "+pr1(checkPlot)+
        ", and Press enter to continue...";
    }
  }
  
  yocoLogTrace,"oiFitsNormalizeCont done";
  return 1;
}

/* --- */

func _oiFitsFilter(&y,&dy,nbPix,&ft,&ftclean)
/* DOCUMENT _oiFitsFilter(&y,&dy,nbPix,&ft,&ftclean)

   DESCRIPTION
   Worker for oiFitsCleanSocks
   
 */
{
  local n;
  n = numberof(y);
  
  /* Fourier Transform */
  ftclean = ft = fft(y,1) / sqrt(n);
  
  /* Clean low frequencies, but keep the 0-frequency level */
  if( numberof(nbPix)>1 ) {
    ftclean *= nbPix;
  } else {
    ftclean(2:nbPix)    = 0.0;
    ftclean(-nbPix+1:0) = 0.0;
  }

  /* Fourier back */
  y = fft(ftclean,-1).re / sqrt(n);
  
  return 1;
}

/* --- */

func oiFitsCleanSocks(&oiData, oiWave, nbPix=, checkPlot=)
/* DOCUMENT oiFitsCleanSocks(&oiData, oiWave, nbPix=, checkPlot=)

   DESCRIPTION
   Apply a high-pass filter to data(lbd), that is remove all frequencies
   bellow nbPix in the FFT of the data. Usefull to remove the 'socks'
   of AMBER in medium- and high-resolution modes.

   Note that the average value (0-frequency) is not removed. Anyway this
   function cannot be used if absolute calibration of the data is required.

   PARAMETERS
   - oiData, oiWave:
   - nbPix: frequency cut-off, defined on pixel of the FFT
     Generally of the order of ~5.
   - checkPlot= if defined (and non-0), then a visual inspection
     will be proposed during the process.
 */
{
  yocoLogInfo,"oiFitsCleanSocks()";
  local name,i,w,y,yclean,ft,ftclean,id;

  /* Check parameters */
  if (!oiFitsIsOiData(oiData)) return yocoError("oiData not valid");
  if (!oiFitsIsOiWave(oiWave)) return yocoError("oiWave not valid");

  /* Loop on the data */
  for (i=1;i<=numberof(oiData);i++) {

    /* Extract the data */
    w = oiFitsGetLambda(oiData(i),oiWave);
    oiFitsGetData, oiData(i), amp, damp, phi, dphi, flag, 1;
    phi0 = phi;
    amp0 = amp;

    /* Filter the data */
    _oiFitsFilter, phi, dphi, nbPix, ftphi, ftphiclean;
    _oiFitsFilter, amp, damp, nbPix, ftamp, ftampclean;
      
    /* Put back data */
    oiFitsSetData, oiData, i, amp, damp, phi, dphi, flag;

    /* optional plot checking */
    if (checkPlot) {
      /* Prepare window */
      yocoNmCreate,check,2,2,dy=0.1,fx=1; fma;
      yocoNmMainTitle,"Check cleaning. nbPix="+pr1(nbPix);
      /* Plor direct space */
      plsys,1; plg,phi0,w,width=3; plg,phi,w,color="red";
      plsys,2; plg,amp0,w,width=3; plg,amp,w,color="red";
      //      xytitles,"lbd (mum)","data";
      /* Plot Fourier space */
      plsys,3; plg,abs(ftphi),width=3; plg,abs(ftphiclean),color="red",type=2;
      plsys,4; plg,abs(ftamp),width=3; plg,abs(ftampclean),color="red",type=2;
      //      xytitles,"lbd^-1^ (pixel)","TF";
      /* Prompt to way for user */
      rdline,prompt="Check cleaning in window "+pr1(checkPlot)+
        ", and Press enter to continue...";
    }
    
  }

  yocoLogTrace,"oiFitsCleanSocks done";
  return 1;
}

/* -----------------------------------------------------------------------
                    Routine for calibration
   ----------------------------------------------------------------------- */

func oiFitsLoadOiDiamManual(oiTarget,names,diam,isCal,&oiDiam)
/* DOCUMENT oiFitsLoadOiDiamManual(oiTarget,names,diam,isCal,&oiDiam)

   DESCRIPTION
   Create manually the structure oiDiam by provinding the
   information

   PARAMETERS
   - oiTarget:
   - names: names of the stars, should match the names defined
     in the string oiTarget.target.
   - diam: target diameter in mas. It should be well-known
     for the calibrators.
   - isCal: 0/1, defining if the defined star should be considered
     as a calibrator or not, i.e to compute the transfer function.
   - oiDiam: output parameter

   EXAMPLES
   > oiFitsLoadOiDiamManual, oiTarget, ["Betelgeuse","HD-10","SAO-124"], \
   [30.0, 2.34, 5.78], [0,1,1], oiDiam;
 */
{
  yocoLogInfo, "oiFitsLoadOiDiamManual()";
  local oiDiam, id;

  /* Some check */
  if ( !yocoTypeIsString(names) )  return yocoError("names should be a string array");
  if ( !yocoTypeIsReal(diam) )     return yocoError("diam should be a numerical, real array");
  if ( !yocoTypeIsInteger(isCal) ) return yocoError("isCal should be a numerical, integer array");
  if (numberof(names) != numberof(diam)  ||  numberof(names) != numberof(isCal))
    return yocoError("names, diam and iCal should be compatible !");

  /* Associate with oiTarget */
  names = strtrim(names);
  id = yocoListId( oiTarget.target, names );

  /* Some check */
  if ( max(id)==0 ) return yocoError( "No diameters for your target");
  if ( min(id)==0 ) yocoLogWarning,"Some targets have no diameter","-> check all calibrators have a diameter!";

  /* Fill the structure */
  oiDiam = array(struct_oiDiam, numberof(oiTarget) );
  oiDiam.targetId = oiTarget.targetId;
  oiDiam.diam     = grow(0.0,diam)(id+1);
  oiDiam.isCal    = grow(0,isCal)(id+1);

  yocoLogTrace, "oiFitsLoadOiDiamManual done";
  return 1;
}

/* --- */

func oiFitsWriteOiDiam(file, oiDiam, oiTarget, overwrite=)
/* DOCUMENT oiFitsWriteOiDiam(file, oiDiam, oiTarget, overwrite=)

   DESCRIPTION
   Write the oiDiam structure into a FITS HDU table called OIU_DIAM.
   oiTarget is used to filled the column TARGET, that contains the
   target name.

   PARAMETERS
   - file: FITS file name.
   - oiDiam:
   - oiTarget:
   - overwrite=1 : remove existing FITS file, otherwise append a new table.
   
   SEE ALSO
*/
{
  yocoLogInfo,"oiFitsWriteOiDiam()";
  local fh, name;
  
  /* Catch possible errors when writting */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    remove,file;
    yocoLogWarning, "Cannot write the oiDiam into a file.";
    return 0;
  }

  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file,"w",overwrite=overwrite) : file );
  
  /* Eventually add the target name */
  if( is_array(oiTarget) )
  {
    oiDiam.target = oiFitsGetTargetName(oiDiam, oiTarget)(*);
  }

  /* Write the data */
  oiFitsWriteStructTable, fh, oiDiam, "OIU_DIAM";
  
  /* Verbose */
  yocoLogInfo,"oiDiam written in:",cfitsio_file_name(fh);
  
  /* eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;
  
  yocoLogTrace,"oiFitsWriteOiDiam done";
  return 1;
}

/* --- */

func oiFitsSetTargetAsScience(&oiDiam, oiTarget, target=)
/* DOCUMENT oiFitsSetTargetAsScience(&oiDiam, oiTarget, target=)

   DESCRIPTION
   Set a target (or list of target) as SCIENCE in the oiDiam file.

   PARAMETERS
   - oiDiam, oiTarget
   - target: list of target name (string) as in the oiTarget

   EXAMPLES
   > oiFitsSetTargetAsScience, oiDiam, oiTarget, target="ANTARES";
 */
{
  yocoLogInfo,"oiFitsSetTargetAsScience()";

  if (is_array(oiTarget))
    names = oiFitsGetTargetName(oiDiam,oiTarget);
  else
    names = oiDiam.target;
  
  for (i=1;i<=numberof(target);i++) {
    if (!is_array((id = where( names == target(i) )))) {
      yocoLogWarning,"Cannot make this target a SCIENCE", target(id);
      continue;
    }
    oiDiam(id).isCal = 0;
  }
  
  yocoLogTrace,"oiFitsSetTargetAsScience done";
  return 1;
}

/* --- */

func oiFitsSetTargetAsCalib(&oiDiam, oiTarget, target=, diam=, diamErr=)
/* DOCUMENT oiFitsSetTargetAsCalib(&oiDiam, oiTarget, target=, diam, diamErr=)

   DESCRIPTION
   Set a target (or list of target) as CALIB in the oiDiam file.

   PARAMETERS
   - oiDiam, oiTarget
   - target: list of target name (string) as in the oiTarget
   - diam: list of diameter (mas)
   - diamErr: list of diameter errors (mas)

   EXAMPLES
   > oiFitsSetTargetAsCalib, oiDiam, oiTarget, target="HD123", diam=2.0, diamErr=0.2;
 */
{
  yocoLogInfo,"oiFitsSetTargetAsCalib()";

  if (is_array(oiTarget))
    names = oiFitsGetTargetName(oiDiam,oiTarget);
  else
    names = oiDiam.target;
  
  for (i=1;i<=numberof(target);i++) {
    if (!is_array((id = where( names == target(i) )))) {
      yocoLogWarning,"Cannot make this target a CALIB", target(id);
      continue;
    }
    oiDiam(id).isCal = 1;
    oiDiam(id).diam = diam(i);
    oiDiam(id).diamErr = diamErr(i);
  }
  
  yocoLogTrace,"oiFitsSetTargetAsCalib done";
  return 1;
}



func oiFitsLoadOiDiam(file, &oiDiam, oiTarget)
/* DOCUMENT oiFitsLoadOiDiam(file, &oiDiam, oiTarget)

   DESCRIPTION
   Read the oiDiam structure from the FITS HDU table called OIU_DIAM.
   oiTarget is used to filled the cross-referencing oiDiam.targetId
   from the column TARGET of the OIU_DIAM table.

   PARAMETERS
   - file: FITS file name.
   - oiDiam:
   - oiTarget:
   
   SEE ALSO
*/
{
  yocoLogInfo,"oiFitsLoadOiDiam()";
  local fh, name, id;
  oiDiam = [];
  
  /* Catch possible errors when writting */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    yocoLogWarning, "Cannot read the oiDiam from the file.";
    return 0;
  }

  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file,"r") : file );
  
  /* Load the data */
  cfitsio_goto_hdu, fh, "OIU_DIAM";
  oiDiam = oiFitsLoadOiTable(fh, struct_oiDiam);

  /* Eventually add the targetId */
  if( !is_array(oiTarget) ) return 1;
  
  id   = oiFitsGetId(oiDiam.target, oiTarget.target);
  oiDiam = oiDiam( where(id) );
  id     = id(where(id));

  if (numberof(id)<1)
  {
    yocoLogWarning,"No target diameter could be retrieved.";
    return 0;
  }

  /* Fill the target id */
  oiDiam.targetId = oiTarget.targetId( id );
  oiDiam = oiDiam(*);
  oiTarget = oiTarget(*);
  
  yocoLogTrace,"oiFitsLoadOiDiam done";
  return 1;
}

/* --- */

func oiFitsLoadCatalog(inputCatalogFile, &dcat, &ecat, &Vcat, &Hcat, &racat, &decat, &idcat, dname, ename, Vname, Hname, id)
    /* DOCUMENT oiFitsLoadCatalog(inputCatalogFile, &dcat, &ecat, &Vcat, &Hcat, &racat, &decat, &idcat, dname, ename, Vname, Hname, id)

       DESCRIPTION
       Load the binary table contains in FITS file name+".fits[2]" and grows the arrays.

       PARAMETERS
       - inputCatalogFile  : filename of the catalog (J_AA434_1201).
       - dname : name of the colomne containing the diameter (in mas)
       - ename : name of the colomne containing the diameter error (in mas)
       - Vname : name of the colomne for the magnitude
       - Hname : name of the colomne for the magnitude
       - id    : integer that will reference the catalog.
       - dcat  : diameter (mas)
       - ecat  : diameter error (mas)
       - Vcat  : magnitude
       - Hcat  : magnitude
       - racat : RA (deg)
       - decat : DEC (deg)
       - idcat : the same as 'id'

       If the diameter error is not specified, or egal to 0, then the
       error will be arbitrarely set to 30% of the diameter.

       EXAMPLES

       SEE ALSO
    */
{
    yocoLogTrace,"oiFitsLoadCatalog()";
    local fh, name;

    /* Protect from failure */
    if (catch(-1)) return yocoError("Failed to load catalog",inputCatalogFile,1);
    
    /* Open the file and go to the first binary table HDU */
    yocoLogInfo,"Load local catalog:",inputCatalogFile;
    fh = cfitsio_open(inputCatalogFile);
    cfitsio_goto_hdu,fh,2;

    /* Load diameter */
    unit = cfitsio_get(fh,"TUNIT"+pr1(cfitsio_get_colnum(fh,,dname)));
    if (unit=="mas") {
        fact = 1.0;
    } else if (unit=="arcsec"){
        fact = 1e3;
    } else {
        yocoError,"Cannot recognise the unit (correct unit in catalog file).";
        return 0.0;
    }
    grow, dcat, cfitsio_read_column (fh,dname) * fact;

    /* Load RA coordinates */
    raname = "RAJ2000"
    unit = cfitsio_get(fh,"TUNIT"+pr1(cfitsio_get_colnum(fh,,raname)));
    if (unit=="deg") {
        yocoLogInfo, "RAJ2000 in deg";
        grow, racat, cfitsio_read_column (fh,raname);
    } else if (unit=="rad") {
        yocoLogInfo, "RAJ2000 in rad";
        grow, racat, cfitsio_read_column(fh,raname) / pi * 180;
    } else if (unit=="h:m:s") {
        yocoLogInfo, "RAJ2000 in h:m:s";
        grow, racat, yocoStrTime (cfitsio_read_column(fh,raname)) / 12. * 180;
    } else {
        yocoLogInfo, "Assume RAJ2000 in h:m:s";
        grow, racat, yocoStrTime (cfitsio_read_column(fh,raname)) / 12. * 180;

    }
    
    /* Load DEC coordinates */
    decname = "DEJ2000"
    unit = cfitsio_get(fh,"TUNIT"+pr1(cfitsio_get_colnum(fh,,decname)));
    if (unit=="deg") {
        yocoLogInfo, "DEJ2000 in deg";
        grow, decat, cfitsio_read_column(fh,decname);
    } else if (unit=="rad") {
        yocoLogInfo, "DEJ2000 in rad";
        grow, decat, cfitsio_read_column(fh,decname) / pi * 180;
    } else if (unit=="d:m:s") {
        yocoLogInfo, "DEJ2000 in d:m:s";
        grow, decat, yocoStrAngle (cfitsio_read_column(fh,decname));
    } else {
        yocoLogInfo, "Assume DEJ2000 in d:m:s";
        grow, decat, yocoStrAngle (cfitsio_read_column(fh,decname));
    }
    
    /* Eventually load the error. If not given or 0, the error
       will be set to 30% */
    tmp = cfitsio_read_column(fh,dname) * fact * 0.3;
    err = ( (is_array(ename) && ename!="") ? cfitsio_read_column(fh,ename) * fact : tmp*0.0 );
    grow, ecat, err + tmp*(err==0);

    /* Eventually load the magnitude, default +99 */
    tmp = cfitsio_read_column(fh,dname) * 0.0 + 99;
    Vmag = ( (is_array(Vname) && Vname!="") ? cfitsio_read_column(fh,Vname) : tmp );
    grow, Vcat, Vmag;
    Hmag = ( (is_array(Hname) && Hname!="") ? cfitsio_read_column(fh,Hname) : tmp );
    grow, Hcat, Hmag;
    
    /* Eventually load the id */
    if ( is_array(id) ) grow, idcat, int(racat*0.0 + id);

    /* close file */
    cfitsio_close,fh;
  
    yocoLogTrace,"oiFitsLoadCatalog done.";
    return 1;
}

/* ------------------------------------------------------------------------ */

func oiFitsLoadOiDiamFromCatalogs(oiTarget, &oiDiam, catalogsDir=, overwrite=, catalogFile=)
/* DOCUMENT oiFitsLoadOiDiamFromCatalogs

   Priorite:
   - Borde, Merand, JSDC, Richichi, CHARM2, cadar

   Alternative call, if catalogFile is given (for ESPO):
   - assume catalogFile points to the JSDC FAINT
   - only query this catalog.

   SEE ALSO:
 */
{
    yocoLogInfo,"oiFitsLoadOiDiamFromCatalogs()"; 
    local racat, decat, diamcat, errcat, Hcat, Vcat, data, titles;
    local diam, diamerr, ra, dec, message, tab, tit;

    if ( is_void(overwrite) ) overwrite=0;

    /* Reset */
    if (overwrite) oiDiam = [];
    
    /* FIXME: Deal with the UD and LDD:
       - add a keyword: band
       - read the diameters in the correct band (default H for PIONIER)
       - eventually, convert the LDD in UD
    */
    

    if ( is_void(catalogFile) )
    {
      /* Default for catalogs location */
      if ( is_void(catalogsDir) ) catalogsDir=get_env("INTROOT")+"/catalogs";
      /* Prepare the info to load the default catalogs */
      catname   = ["J_AA_433_1155","J_AA_393_183","II_300_jsdc","J_AA_434_1201","J_AA_431_773","II_224_cadars","JBLB"];
      diamName  = ["UDdiamH", "UDDH", "UDDH", "Diam", "UD", "Diam", "LDD"];
      errName   = ["e_UDdiam", "e_UDDH", "e_LDD", "e_Diam", "e_UD", "", "e_LDD"];
      VmagName  = ["Vmag", "Vmag", "Rmag", "", "", "", ""];
      HmagName  = ["Hmag", "Hmag", "Hmag", "", "", "", ""];
      catfiles = catalogsDir + "/" + catname + ".fits";
    }
    else
    {
      /* Prepare the info to load the JSDC faint.
         This is for the static ESO calibration catalog */
      catname  = ["faint_jsdc"];
      diamName = ["UDDH"];
      errName  = ["e_LDD"];
      VmagName = ["Rmag"];
      HmagName = ["Hmag"];
      catfiles = [catalogFile];
    }

    /* Read the catalogs */
    diamcat = errcat = Vcat = Hcat = racat = decat = idcat = [];
    for ( i=1 ; i<=numberof(catname) ; i++)
      oiFitsLoadCatalog, catfiles(i),diamcat,errcat,Vcat,Hcat,racat,decat,idcat,diamName(i),errName(i),VmagName(i),HmagName(i),i;

    /* If nonw was available */
    if ( is_void(diamcat) )
      return yocoError("Cannot load any local catalogs");
    
    /* Fix the Nan and Inf, replace the diameter by -1.0 */
    diamcat = oiFitsCorrectNansInfs(diamcat,-1.0);

    /* Loop on stars */
    catname = grow(catname,"none");
    for ( i=1 ; i<=numberof(oiTarget) ; i++)
    {
        /* Get id (deal with the case oiTarget is indeed an oiLog) */
        idTarget = ( oiFitsIsOiLog(oiTarget) ? 0 : oiTarget(i).targetId );

        /* Do not process existing */
        id = where(struct_oiDiam(oiDiam).target == oiTarget(i).target);
        if ( numberof(id)>0 ) {
          id = id(1);
          yocoLogInfo,oiTarget(i).target+" is already in oiDiam with "+
            swrite(format="diam=%.2fmas and isCal=%i",oiDiam(id).diam, oiDiam(id).isCal);
          continue;
        }

        /* Do not process "INTERNAL" */
        if ( oiTarget(i).target == "INTERNAL" ) {
          yocoLogInfo,"Skip target "+oiTarget(i).target;
          grow, oiDiam, struct_oiDiam( target   = oiTarget(i).target,
                                       targetId = idTarget, diam = 0.0, diamErr = 0.0, isCal = 0,
                                       Vmag = 0.0, Hmag = 0,
                                       info     = "No diameter found" );
          continue;
        }

	/* Compute spherical distance in seconds */
	dist = sin(oiTarget(i).decEp0*pi/180) * sin(decat*pi/180) +
	  cos(oiTarget(i).decEp0*pi/180) * cos(decat*pi/180) * cos((oiTarget(i).raEp0-racat)*pi/180);
	dist = acos (dist) / pi * 180. * 60 * 60;

	/* Alternate dist */
	// sin2p = sin((oiTarget(i).decEp0-decat)*pi/180/2.0)^2;
	// sin2l = sin((oiTarget(i).raEp0-racat)*pi/180/2.0)^2;
	// dist  = sin2p + cos(oiTarget(i).decEp0*pi/180) * cos(decat*pi/180) * sin2l;
	// dist  = 2. * asin (sqrt(dist)) / pi * 180. * 60 * 60;
        // dist = abs(oiTarget(i).raEp0-racat, abs(oiTarget(i).decEp0-decat) )*60.*60;
	
        /* Look for the stars by matching the coordinates (seconds) */
        ids = id = where( dist < 5.0 & diamcat > 0.0 );

        /* If no diameter found, search larger */
        if ( numberof(id)<1 )
        {
          yocoLogWarning,oiTarget(i).target+" has no diameter found with 5', enlarge to 10'";
	  ids = id = where( dist < 10.0 & diamcat > 0.0 );
	}
	
        /* If no diameter found  */
        if ( numberof(id)<1 )
	{
          yocoLogWarning,oiTarget(i).target+" has no diameter found with 10'";
          grow, oiDiam, struct_oiDiam( target   = oiTarget(i).target,
                                       targetId = idTarget,
                                       diam     = 0.0,
                                       diamErr  = 0.0,
                                       Vmag     = 0.0,
                                       Hmag     = 0.0,
                                       isCal    = 0,
                                       info     = "No diameter found" );
          continue;
        }

        /* Keep the diameter of the catalog with the best confidence,
           that is of minimum value of idcat */
        ids = ids( sort(idcat(ids)) );
        id = id( where(idcat(ids)==min(idcat(ids))) )(1);
    
        /* Fill the diameter as the weighted average */
        diam    = diamcat(id);
        diamerr = errcat(id);
        Vmag    = Vcat(id);
        Hmag    = Hcat(id);

        /* Fill the list of catalogs */
        catalog = catname(idcat(id));

        /* isCal==1 only if the catalog has good confidence */
        isCal = (idcat(id)<4);

        /* Fill the distance */
        distance = swrite(format="%.1f:",dist(id)(*))(sum);
    
        /* Verbose information */
        main = swrite(format="%s has diameter of %.2f+-%.2fmas (isCal=%i) from values",
                      oiTarget(i).target,diam,diamerr,isCal);
        info = swrite(format="%.2f+-%.2f (%.1f\") in %s\t",diamcat(ids),errcat(ids),
                      dist(ids),catname(idcat(ids)));
        yocoLogInfo,main,info;

        /* Fill the structure */
        grow, oiDiam, struct_oiDiam( target   = oiTarget(i).target,
                                     targetId = idTarget,
                                     diam     = diam,
                                     diamErr  = diamerr,
                                     isCal    = isCal,
                                     Vmag     = Vmag,
                                     Hmag     = Hmag,
                                     info     = distance + " " + catalog );
    }
    /* End loop on stars */
  
    yocoLogTrace,"oiFitsLoadOiDiamFromCatalogs done";
    return 1;
}

/* --- */

func oiFitsCalibrateDiam(&oiVis2,oiWave,oiDiam)
/* DOCUMENT oiFitsCalibrateDiam(&oiVis2,oiWave,oiDiam)

   DESCRIPTION
   oiVis2 are calibrated from the target diameters
   stored in the structure oiDiam.

   PARAMETERS
   - oiVis2 (input/output), oiWave, oiDiam:
 */
{
  local i,y,w,l,diam,vis2, vis2err, phi, phiErr;
  yocoLogTrace,"oiFitsCalibrateDiam()";

  /* check inputs */
  if( !oiFitsIsOiVis2(oiVis2) ) return yocoError("oiVis2 not valid");
  if( !oiFitsIsOiWave(oiWave) ) return yocoError("oiWave not valid");
  

  for (i=1;i<=numberof(oiVis2);i++) {

    /* Get the diameter and its error */
    diam    = oiFitsGetOiDiam(oiVis2(i), oiDiam).diam;
    diamErr = oiFitsGetOiDiam(oiVis2(i), oiDiam).diamErr;

    /* if not a known diameter, skip */
    if (diam<=0) continue;
    
    /* get the data */
    oiFitsGetData,oiVis2(i),vis2,vis2Err;
    w = oiFitsGetLambda(oiVis2(i),oiWave) * 1e-6;

    /* calibrating factors */
    vis2m = abs( yocoMathAiry( abs( oiVis2(i).uCoord, oiVis2(i).vCoord) * diam * yocoAstroSI.mas / w ) )^2.0;
    ya = abs( yocoMathAiry( abs( oiVis2(i).uCoord, oiVis2(i).vCoord) * (diam+diamErr) * yocoAstroSI.mas / w ) )^2.0;
    yb = abs( yocoMathAiry( abs( oiVis2(i).uCoord, oiVis2(i).vCoord) * (diam-diamErr) * yocoAstroSI.mas / w ) )^2.0;
    vis2mErr = abs(ya-yb) / 2.0;

    /* Calibrate */
    vis2c  = vis2 / vis2m;
    
    /* Propagate errors (add variances)*/
    vis2  += 1e-10;
    vis2m += 1e-10;
    vis2cErr  = abs( vis2Err/vis2*vis2c, vis2mErr/vis2m*vis2c );
    
    /* Put the data back */
    _ofSSDs, oiVis2, i, "vis2Data", vis2c;
    _ofSSDs, oiVis2, i, "vis2Err",  vis2cErr;

    /* Put statistical error if structure is defined */
    oiFitsStrReadMembers, oiVis2(i), name;
    if (anyof(name=="vis2ErrSys")) {
      yocoLogInfo,"Fill vis2ErrSys";
      _ofSSDs, oiVis2, i, "vis2ErrSys",  vis2mErr/vis2m*vis2c;
    }
  }
  
  yocoLogTrace,"oiFitsCalibrateDiam done";
  return 1;
}

func oiFitsCalibrateDiamOiT3(&oiT3,oiWave,oiDiam)
{
  local i,y,w,l,diam,vis2, vis2err, phi, phiErr, amp, ampErr;
  yocoLogInfo,"oiFitsCalibrateDiamOiT3()";

  /* check inputs */
  if( !oiFitsIsOiT3(oiT3) ) return yocoError("oiT3 not valid");
  if( !oiFitsIsOiWave(oiWave) ) return yocoError("oiWave not valid");

  for (i=1;i<=numberof(oiT3);i++) {

    /* Get the diameter and its error */
    diam    = oiFitsGetOiDiam(oiT3(i), oiDiam).diam;
    diamErr = oiFitsGetOiDiam(oiT3(i), oiDiam).diamErr;

    /* if not a known diameter, skip */
    if (diam<=0) continue;
    
    /* get the data */
    oiFitsGetData,oiT3(i),amp,ampErr,phi,phiErr;
    w = oiFitsGetLambda(oiT3(i),oiWave) * 1e-6;

    /* calibrating factors */
    vis1 = yocoMathAiry( abs( oiT3(i).u1Coord, oiT3(i).v1Coord) * diam * yocoAstroSI.mas / w );
    vis2 = yocoMathAiry( abs( oiT3(i).u2Coord, oiT3(i).v2Coord) * diam * yocoAstroSI.mas / w );
    vis3 = yocoMathAiry( abs(-oiT3(i).u1Coord -oiT3(i).u2Coord,
                             -oiT3(i).v1Coord -oiT3(i).v2Coord) * diam * yocoAstroSI.mas / w );
    phical = oiFitsArg(complex(vis1 * vis2 * vis3));
    ampcal = abs( vis1 * vis2 * vis3 );
    
    /* Calibrate */
    phic  = oiFitsArg( exp(1.i * (phi/180*pi - phical)) )/pi*180;
    ampc  = amp / ampcal;

    /* Propagate errors (add variances)...
       FIXME: to be done */
    // amp  += 1e-10;
    // ampc += 1e-10;
    // vis2cErr  = abs( ampErr/vis2*vis2c, ampErr/vis2m*vis2c );
    
    /* Put the data back */
    _ofSSDs, oiT3, i, "t3Phi", phic;
    _ofSSDs, oiT3, i, "t3Amp", ampc;
  }
  
  yocoLogTrace,"oiFitsCalibrateDiamOiT3 done";
  return 1;
}

/* -- */

func oiFitsExtractTf(oiData, oiWave, oiDiam, &oiDataTfpt)
/* DOCUMENT oiFitsExtractTf(oiData, oiWave, oiDiam, &oiDataTfpt)

   DESCRIPTION
   Extract all observation of calibration star from oiData and
   store them into oiDataTfpt. Then oiData is calibrated from
   the stellar diameter, to give an estimation of the TF.

   Calibration stars are found by looking at the flag oiDiam.isCal

   PARAMETERS
   - oiData, oiWave, oiDiam:
   - &oiDataTfpt:

   EXAMPLES:
   > oiFitsLoadOiDiamFromFile,"~/calib.txt", oiTarget, oiDiam;
   > oiFitsExtractTf, oiVis2, oiWave, oiDiam, oiVis2Tf;
*/
{
  yocoLogTrace,"oiFitsExtractTf()";
  local calId, uvId, diam, idTf;
  oiDataTfpt = [];

  /* Check parameters */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if( !oiFitsIsOiDiam(oiDiam) ) return yocoError("oiDiam not valid");
  diam  = oiFitsGetOiDiam( oiData, oiDiam );

  
  /* If oiVis2, look for the calibrator and correct from the diameter size.
     Ohterwise just find the calibrators (no need to calibrate) */
  if ( oiFitsIsOiVis2(oiData) ) {

    /* Check if the UV-plane looks corrupted
       (it wouls screw-up the computation of the theoretical vis2) */
    flag = ( oiFitsGetBaseLength(oiData) == 0 );
    if ( anyof(flag) ) {
      yocoLogWarning,pr1(numberof(where(flag)))+" observations with abs(u,v)==0 "+
        "have been removed from possible oiVis2 calibrators.";
    }
    
    /* Found the calibrators */
    calId = where( diam.isCal==1 & flag==0);

    /* Extract the observation of calibration stars */  
    oiDataTfpt = oiData(calId);
    if ( numberof(oiDataTfpt)==0 ) {yocoLogInfo, "No calibrator found for oiVis2."; return 1;}
    
    /* Need a correct wavelength table */
    if( !oiFitsIsOiWave(oiWave) )  return yocoError("oiWave not valid, cannot compute theoretical oiVis2 for calibrators.");

    /* Calibrate from the diameter size */
    oiFitsCalibrateDiam, oiDataTfpt, oiWave, oiDiam;
    
  } else if (oiFitsIsOiT3(oiData) ) {
    
    /* Found the calibrators */
    calId = where( diam.isCal==1 );

    /* Extract the observation of calibration stars */  
    oiDataTfpt = oiData(calId);
    if ( numberof(oiDataTfpt)==0 ) {yocoLogInfo, "No calibrator found for oiT3."; return 1;}

    /* Calibrate from the diameter size */
    oiFitsCalibrateDiamOiT3, oiDataTfpt, oiWave, oiDiam;
  }
  
  yocoLogTrace,"oiFitsExtractTf done";
  return 1;
}

/* --- */

local oiFitsTfInterp, oiFitsTfSmoothLength;
local oiFitsTfAverageFit, oiFitsTfLinearFit, oiFitsTfQuadraticFit;
/* DOCUMENT oiFitsTfInterp
            oiFitsTfSmoothLength
            oiFitsTfAverageFit
            oiFitsTfLinearFit
            oiFitsTfQuadraticFit

   DESCRIPTION
   Function used to interpolate the TF at the time
   of observations. See 'oiFitsApplyTf'
*/

/* -- */

func oiFitsTfInterp(oTf,&oDat,oiLog,errMode=,param=)
{
  local s, ampTf, dampTf, phiTf, dphiTf, flagTf;

  /* Get time */
  x  = oTf.mjd;
  x0 = oDat.mjd;

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* Sort the TF estimation for the interp */
  s = sort(x); x = x(s); flagTf = flagTf(,s);
  ampTf = ampTf(,s); dampTf = dampTf(,s);
  phiTf = phiTf(,s); dphiTf = dphiTf(,s);
  
  /* Loop on spectral channels to avoid flagged TF points */
  nc = numberof(ampTf(,1));
  dampD = ampD = phiD = dphiD = array(0.0,nc,dimsof(x0));
  for (c=1;c<=nc;c++) {
    id = where(flagTf(c,)==char(0));
    ampD(c,)  = interp(ampTf(c,id),  x(id), x0);
    dampD(c,) = interp(dampTf(c,id), x(id), x0);
    phiD(c,)  = interp(phiTf(c,id),  x(id), x0);
    dphiD(c,) = interp(dphiTf(c,id), x(id), x0);
  }

  // /* interp both the value and error. */
  // ampD  = interp(ampTf,  x, x0, 2);
  // dampD = interp(dampTf, x, x0, 2);
  // phiD  = interp(phiTf,  x, x0, 2);
  // dphiD = interp(dphiTf, x, x0, 2);

  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  /* Ack for EXOZODI */
  if ( oiFitsStrHasMembers(oTf,"vis2ErrSys") ) {
    statTf = oiFitsGetStructData(oTf,"vis2ErrSys",1);
    statD  = interp(statTf(,s), x(s), x0, 2);
    oiFitsSetStructDataArray,oDat,,"vis2ErrSys",statD;
  }

  return 1;
}

/* -- */

func oiFitsTfAverage(oTf,&oDat,oiLog,errMode=,param=)
{
  local n, s, ampTf, dampTf, phiTf, dphiTf, flagTf;

  /* Get time */
  x  = oTf.mjd;
  x0 = oDat.mjd;
  n  = numberof(x0);

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;
  
  /* Average data*/
  oiFitsAverageSample, ampTf, dampTf, which=2, errMode=errMode, phase=0;
  oiFitsAverageSample, phiTf, dphiTf, which=2, errMode=errMode, phase=1;

  /* Enlarge into arrays */
  ampD  =  ampTf(,-:1:n);
  phiD  =  phiTf(,-:1:n);
  dampD =  dampTf(,-:1:n);
  dphiD =  dphiTf(,-:1:n);
    
  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;

  /* Ack for EXOZODI */
  if ( oiFitsStrHasMembers(oTf,"vis2ErrSys") ) {
    statTf = oiFitsGetStructData(oTf,"vis2ErrSys",1);
    statD  = statTf(,avg);
    oiFitsSetStructDataArray,oDat,,"vis2ErrSys",statD;
  }
  
  return 1;
}

/* -- */

func oiFitsTfSmoothLength(oTf,&oDat,oiLog,&chi2,param=,errMode=,length=)
{
  local s, ampTf, dampTf, phiTf, dphiTf, flagTf;
  local wts,wtR,sy2,chi2,dout2,res2;
  
  /* Extract from code in IDL from John Monnier
     weight is based on distance (length) */
    
  /* Default for length is ~1.5h */
  if ( is_void(errMode) ) errMode=0;
  if ( is_array(param) )  length=param(1);
  if ( is_void(length) )  length = 1./24. * 0.8;

  /* Get time */
  x  = oTf.mjd;
  x0 = oDat.mjd;

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* Don't give added advantage for <2% percent error.
     or 0.1deg for phase, Idea from John Monnier */
  dphiTf2 = max( dphiTf, 0.1 )^-2;
  dampTf2 = max( dampTf, abs(0.02*ampTf)+1e-10 )^-2;
  
  /* Compute the distance weight */
  wts = exp( - ( x-x0(-,) )^2 / length^2 )(-,);
  
  /* Weightened average by distance and sy2 */
  ampD = (wts*dampTf2*ampTf) (,sum,) / (wts*dampTf2)(,sum,);
  // phiD = (wts*dphiTf2*phiTf) (,sum,) / (wts*dphiTf2)(,sum,);
  phiD = oiFitsArg( (wts*dphiTf2*exp(1.i*pi/180*phiTf)) (,sum,) )*180/pi;
  
  /* Same as previous but at the time of measurements */
  wtR = exp( - ( x-x(-,) )^2 / length^2 )(-,);
  ampR = (wtR*dampTf2*ampTf) (,sum,) / (wtR*dampTf2)(,sum,);
  // phiR = (wtR*dphiTf2*phiTf) (,sum,) / (wtR*dphiTf2)(,sum,);
  phiR = oiFitsArg( (wtR*dphiTf2*exp(1.i*pi/180*phiTf))(,sum,) )*180/pi;
  
  /* Compute the variance of average, the chi2
     and the variance of residuals */
  ampo2   = (wts * dampTf2)(,sum,)^-1;
  ampchi2 = max( ( (ampTf-ampR)^2 * dampTf2 * wts)(,sum,) / (wts)(,sum,),  1.0);
  ampres2 = ( (ampTf-ampR)^2 * dampTf2 * wts)(,sum,) / (wts*dampTf2)(,sum,);
  
  /* Same for phases */
  phio2   = (wts * dphiTf2)(,sum,)^-1;
  phidiff = oiFitsArg( exp(1.i*pi/180*(phiTf-phiR)) )*180/pi;
  // phichi2 = max( ( (phiTf-phiR)^2 * dphiTf2 * wts)(,sum,) / (wts)(,sum,),  1.0);
  // phires2 = ( (phiTf-phiR)^2 * dphiTf2 * wts)(,sum,) / (wts*dphiTf2)(,sum,);
  phichi2 = max( ( phidiff^2 * dphiTf2 * wts)(,sum,) / (wts)(,sum,),  1.0);
  phires2 = ( phidiff^2 * dphiTf2 * wts)(,sum,) / (wts*dphiTf2)(,sum,);

  if (errMode==0) {
    /* Increase error because of dispersion, non-standar:
       error = sqrt(chi2 * variance * correctif)
       Because of last therm, if chi2>>1, this tends to:
       error = RMS(x)         */
    dampD  = sqrt( ampchi2 * ampo2 * (wts)(,sum,)^(1.-1./ampchi2^2) );
    dphiD  = sqrt( phichi2 * phio2 * (wts)(,sum,)^(1.-1./phichi2^2) );
  }
  else if (errMode==1) {
    /* Error as sqrt(chi2 * variance) */
    dampD = sqrt( ampchi2 * ampo2 );
    dphiD = sqrt( phichi2 * phio2 );
  }
  else if (errMode==2) {
    /* Standar: error = sqrt(variance) */
    dampD = sqrt( ampo2 );
    dphiD = sqrt( phio2 );
  }
  else if (errMode==3) {
    /* Error as RMS of residuals */
    dampD = sqrt( ampres2 );
    dphiD = sqrt( phires2 );
  }

  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  return 1;
}

/* -- */

func oiFitsTfSmoothTimeSky(oTf,&oDat,oiLog,&chi2,param=,errMode=,length=)
{
  yocoLogInfo,"oiFitsTfSmoothTimeSky()";
  local s, ampTf, dampTf, phiTf, dphiTf, flagTf;
  local wts,wtR,sy2,chi2,dout2,res2;
  
  /* Extract from code in IDL from John Monnier
     weight is based on distance (length) both
     in sky and time */
    
  /* Default for length is ~1.5h */
  if ( is_void(errMode) ) errMode=0;
  if ( is_array(param) )  length=param(1);
  if ( is_void(length) )  length = 1./24. * 0.8; // day
  if ( is_array(param) )  lengthSky = param(2);
  if ( is_void(lengthSky) ) lengthSky = 10.0; // deg

  /* Get separation in RAD */
  lengthSky *= pi / 180.0;

  /* Get altaz and time */
  x   = oTf.mjd;
  alt = oiFitsGetAlt(oTf,oiLog) * pi/180;
  az  = oiFitsGetAz(oTf,oiLog) * pi/180;
  x0   = oDat.mjd;
  alt0 = oiFitsGetAlt(oDat,oiLog) * pi/180;
  az0  = oiFitsGetAz(oDat,oiLog) * pi/180;

  /* Compute separation in DAYS and RADIANS */
  sepTime0 = x-x0(-,);
  sepTime  = x-x(-,);
  sepSky0 = 2.*asin(sqrt(  sin((alt-alt0(-,))/2)^2 + cos(alt)*cos(alt0(-,))*sin((az-az0(-,))/2)^2 ));
  sepSky  = 2.*asin(sqrt(  sin((alt-alt(-,))/2)^2 + cos(alt)*cos(alt(-,))*sin((az-az(-,))/2)^2 ));

  /* Compute the weight related to distance. Note that the sky distance is ^4
     to reduce the influence of further calibration stars */
  wts = exp( -(sepTime0/length)^2 -(sepSky0/lengthSky)^4 )(-,);
  wtR = exp( -(sepTime/length)^2 -(sepSky/lengthSky)^4 )(-,);

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* Don't give added advantage for <2% percent error.
     or 0.1deg for phase, Idea from John Monnier */
  dphiTf2 = max( dphiTf, 0.1 )^-2;
  dampTf2 = max( dampTf, abs(0.02*ampTf)+1e-10 )^-2;
  
  /* Weightened average by distance and sy2 */
  ampD = (wts*dampTf2*ampTf) (,sum,) / (wts*dampTf2)(,sum,);
  phiD = (wts*dphiTf2*phiTf) (,sum,) / (wts*dphiTf2)(,sum,);
  ampR = (wtR*dampTf2*ampTf) (,sum,) / (wtR*dampTf2)(,sum,);
  phiR = (wtR*dphiTf2*phiTf) (,sum,) / (wtR*dphiTf2)(,sum,);
  
  /* Compute the variance of average, the chi2
     and the variance of residuals */
  ampo2   = (wts * dampTf2)(,sum,)^-1;
  ampchi2 = max( ( (ampTf-ampR)^2 * dampTf2 * wts)(,sum,) / (wts)(,sum,),  1.0);
  ampres2 = ( (ampTf-ampR)^2 * dampTf2 * wts)(,sum,) / (wts*dampTf2)(,sum,);
  
  /* Same for phases */
  phio2   = (wts * dphiTf2)(,sum,)^-1;
  phichi2 = max( ( (phiTf-phiR)^2 * dphiTf2 * wts)(,sum,) / (wts)(,sum,),  1.0);
  phires2 = ( (phiTf-phiR)^2 * dphiTf2 * wts)(,sum,) / (wts*dphiTf2)(,sum,);

  if (errMode==0) {
    /* Increase error because of dispersion, non-standar:
       error = sqrt(chi2 * variance * correctif)
       Because of last therm, if chi2>>1, this tends to:
       error = RMS(x)         */
    dampD  = sqrt( ampchi2 * ampo2 * (wts)(,sum,)^(1.-1./ampchi2^2) );
    dphiD  = sqrt( phichi2 * phio2 * (wts)(,sum,)^(1.-1./phichi2^2) );
  }
  else if (errMode==1) {
    /* Error as sqrt(chi2 * variance) */
    dampD = sqrt( ampchi2 * ampo2 );
    dphiD = sqrt( phichi2 * phio2 );
  }
  else if (errMode==2) {
    /* Standar: error = sqrt(variance) */
    dampD = sqrt( ampo2 );
    dphiD = sqrt( phio2 );
  }
  else if (errMode==3) {
    /* Error as RMS of residuals */
    dampD = sqrt( ampres2 );
    dphiD = sqrt( phires2 );
  }

  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  return 1;
}

/* -- */

func oiFitsTfLinearFit(oTf,&oDat,oiLog,errMode=,param=)
{
  yocoLogTrace,"oiFitsTfLinearFit()";
  local i,c2,a,v,c;
  local ampTf, dampTf, phiTf, dphiTf, flagTf;
  
  /* Get time */
  x  = oTf.mjd;
  x0 = oDat.mjd;

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* Prepare outputs */
  nL  = dimsof(ampTf)(2);
  ampD = dampD = array(0.0, nL, dimsof(x0));
  phiD = dphiD = array(0.0, nL, dimsof(x0));

  /* Normalise to help numerical regression */
  x0 = (x0 - x(avg)) / x(rms);
  x  = (x  - x(avg)) / x(rms);

  /* Loop on the wavelength bins */
  for ( i=1 ; i<=nL ; i++) {
    /* execute the regression and compute the covariance for amp */
    out = regress(ampTf(i,), [1., x], a, v, c2, sigy=dampTf(i,));
    c   = max(c2,1.0) * regress_cov(a, v);
    ampD(i,) = [1., x0](,+) * out(+);
    dampD(i,) = sqrt( c(1,1) + c(2,2)*x0^2 + 2.*c(1,2)*x0 );
    /* execute the regression and compute the covariance for phi */
    out = regress(phiTf(i,), [1., x], a, v, c2, sigy=dphiTf(i,));
    c   = max(c2,1.0) * regress_cov(a, v);
    phiD(i,) = [1., x0](,+) * out(+);
    dphiD(i,) = sqrt( c(1,1) + c(2,2)*x0^2 + 2.*c(1,2)*x0 );
  }

  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  yocoLogTrace,"oiFitsTfLinearFit done";
  return 1;
}

/* -- */

func oiFitsTfQuadraticFit(oTf,&oDat,oiLog,errMode=,param=)
{
  yocoLogTrace,"oiFitsTfQuadraticFit()";
  local i,c2,a,v,c;
  local ampTf, dampTf, phiTf, dphiTf, flagTf;
  
  /* Get time */
  x  = oTf.mjd;
  x0 = oDat.mjd;

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* Prepare outputs */
  nL  = dimsof(ampTf)(2);
  ampD = dampD = array(0.0, nL, dimsof(x0));
  phiD = dphiD = array(0.0, nL, dimsof(x0));
  
  /* Loop on the wavelength bins */
  for ( i=1 ; i<=nL ; i++) {
    /* execute the regression and compute the covariance */
    out = regress(ampTf(i,), [1., x, x^2], a, v, c2, sigy=dampTf(i,));
    c   = max(c2,1.0) * regress_cov(a, v);
    ampD(i,)  = [1., x0, x0^2](,+) * out(+);
    dampD(i,) = sqrt( c(1,1) + c(2,2)*x0^2 + c(3,3)*x0^4 +
                      2.*c(1,2)*x0 + 2.*c(1,3)*x0^2 + 2.*c(2,3)*x0^3 );
    /* execute the regression and compute the covariance */
    out = regress(phiTf(i,), [1., x, x^2], a, v, c2, sigy=dphiTf(i,));
    c   = max(c2,1.0) * regress_cov(a, v);
    phiD(i,)  = [1., x0, x0^2](,+) * out(+);
    dphiD(i,) = sqrt( c(1,1) + c(2,2)*x0^2 + c(3,3)*x0^4 +
                      2.*c(1,2)*x0 + 2.*c(1,3)*x0^2 + 2.*c(2,3)*x0^3 );
  }

  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  yocoLogTrace,"oiFitsTfQuadraticFit done";
  return 1;
}

/* -- */

func oiFitsTfAltAzFit(oTf,&oDat,oiLog, errMode=,param=)
{
  local l;
  local ampTf, dampTf, phiTf, dphiTf, flagTf;
  yocoLogTrace, "oiFitsTfAltAzFit()";
  
  /* Get altAz */
  x  = oiFitsGetAltAz(oTf,oiLog)/180.*pi;
  x0 = oiFitsGetAltAz(oDat,oiLog)/180.*pi;

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* Prepare outputs */
  nL  = dimsof(ampTf)(2);
  ampD = dampD = array(0.0, nL, dimsof(x0));
  phiD = dphiD = array(0.0, nL, dimsof(x0));

  /* Fit by a fonction of the form a + b.cos(2x + phi),
     independently for the each spectral channel */
  for (l=1 ; l<=nL ; l++) {
    fit = regress(ampTf(l,), [1,cos(2.*x),sin(2.*x)], sigy=dampTf(l,));
    ampD(l,)  = fit(+) * [1,cos(2.*x0),sin(2.*x0)](..,+);
    dampD(l,) = array(0.,dimsof(x0));
    // yocoLogTrace, "ch"+pr1(l)+" alt-az best fit (a,b.cos(2.altaz)): "+pr1(fit);
    fit = regress(phiTf(l,), [1,cos(2.*x),sin(2.*x)], sigy=dphiTf(l,));
    phiD(l,)  = fit(+) * [1,cos(2.*x0),sin(2.*x0)](..,+);
    dphiD(l,) = array(0.,dimsof(x0));
  }
  
  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  yocoLogTrace, "oiFitsTfAltAzFit done";
  return 1;
}

func oiFitsTfAltAzFreeFit(oTf, &oDat, oiLog, errMode=,param=)
{
  local l;
  yocoLogTrace, "oiFitsTfAltAzFreeFit()";

  /* Get alt and az */
  alt  = oiFitsGetAlt(oTf,oiLog)/180.*pi;
  alt0 = oiFitsGetAlt(oDat,oiLog)/180.*pi;
  az   = oiFitsGetAz(oTf,oiLog)/180.*pi;
  az0  = oiFitsGetAz(oDat,oiLog)/180.*pi;
  x    = oiFitsGetAltAz(oTf,oiLog)/180.*pi;
  x0   = oiFitsGetAltAz(oDat,oiLog)/180.*pi;

  /* Get data */
  oiFitsGetData, oTf, ampTf, dampTf, phiTf, dphiTf, flagTf, 1;

  /* output arrays */
  nL = dimsof(ampTf)(2);
  ampD = dampD = array(0.0, nL, dimsof(x0));
  phiD = dphiD = array(0.0, nL, dimsof(x0));

  /* Fit by a fonction of the form a + b.cos(2x) + c.sin(2x),
     independently for the each spectral channel */
  for (l=1;l<=nL;l++) {
    yocoLogTrace," proceed with channel"+pr1(l);
    fit = regress(ampTf(l,), [1,cos(2.*x),sin(2.*x),cos(alt)*cos(2.*az),cos(alt)*sin(2.*az)], sigy=dampTf(l,));
    ampD(l,)  = fit(+) * [1,cos(2.*x0),sin(2.*x0),cos(alt0)*cos(2.*az0),cos(alt0)*sin(2.*az0)](..,+);
    dampD(l,) = array(0.,dimsof(x0));
    yocoLogTrace, "ch"+pr1(l)+" alt-az best fit (a,b.cos(2.altaz),c.sin(2.altaz)): "+pr1(fit);
    fit = regress(phiTf(l,), [1,cos(2.*x),sin(2.*x),cos(alt)*cos(2.*az),cos(alt)*sin(2.*az)], sigy=dphiTf(l,));
    phiD(l,)  = fit(+) * [1,cos(2.*x0),sin(2.*x0),cos(alt0)*cos(2.*az0),cos(alt0)*sin(2.*az0)](..,+);
    dphiD(l,) = array(0.,dimsof(x0));
  }
  
  /* Set data */
  oiFitsSetDataArray, oDat, ,ampD, dampD, phiD, dphiD;
  
  yocoLogTrace, "oiFitsTfAltAzFreeFit done";
  return 1;
}

/* -- */

func oiFitsApplyTf( oiDataRaw, oiDataTfp, oiArray, oiLog, &oiDataCal, &oiDataTfe, oiTarget, 
                    funcSetup=, tdelta=, tfMode=, errMode=, onTime=,
                    minAmpErr=, minPhiErr=, param=)
/* DOCUMENT oiFitsApplyTf(oiDataRaw, oiDataTfp, oiArray, oiLog,
                          &oiDataCal, &oiDataTfe,
                          funcSetup=, tdelta=, tfMode=, errMode=, onTime=,
                          minAmpErr=, minPhiErr=, param=)

   DESCRIPTION
   Convert 'oiDataRaw' into 'oiDataCal' by interpolating the transfer-function
   points 'oiDataTfp'. This is done setup-by-setup, to ensure the oiDataRaw are
   calibrated by the TF estimation obtained with same setup.

   PARAMETERS
   inputs:
   - oiDataRaw, oiDataTfp: raw oiData and TF data points
   - oiArray, oiLog:
   
   outputs:
   - &oiDataCal: calibrated oiData
   - &oiDataTfe: interpolation of the Transfer-function over the
     period of time spaned by the data set. Usefull for plot and
     check purposes. If onTime=1, then this value are only provided
     for the same mjdtime as oiDataRaw.

   - tfMode=0: interp. closest TF-points
          1: smooth-length     (>1pt)
          2: average           (>1pt)  (default)
          3: linear fit        (>2pt)
          4: quadratic fit     (>3pt)
          5: 1+b.cos2(alt+az)  (>3pt)
          If the number of points is not enought, then
          the TF is averaged only.

     5: need the following functions to be defined:
        oiFitsGetAltAz(oiData, oiLog)
          
   - tdelta= time-step for computing the output oiDataTfe.
     This has no influence on the calibrated oiDataCal since
     oiDataTfe is only computed for plot/check purpose.
     
   - funcSetup= (optional) temporary override 'oiFitsDefaultSetup'
     see the help of 'oiFitsDefaultSetup' for more information

   - minAmpErr= (optional) the relative error of Amp is forced
     to be larger (or equal) than this value. Default is 0.1  (10%).

   - minPhiErr= (optional) same as previous but for the absolute
     error on the phase (default is 0.1deg).

   FIXME:
   - better handle the correlated errors !
   - maximum accuracy of vis2Tf is fixed to +/-1% (AMBER perfo) !

   EXAMPLES
   > oiFitsExtractTf, oiVis2, oiWave, oiDiam, oiDataTfp;
   > oiFitsApplyTf, oiVis2, oiDataTfp, oiArray, oiLog, oiDataCal;

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsApplyTf ("+string(oiFitsStructRoot(oiDataRaw))+", tfmode="+pr1(tfMode)+")";
  
  /* Local variable and clean outputs */
  local thisSetup, setIdRaw, setupRaw, setupTfp, nTfe, nTfp;
  local i, idTfp, idRaw, thisSetup, errCal, datCal, errRaw, datRaw;
  local errTfo, datTfo, errTfe, datTfe, mjdRef;
  local ampRaw, dampRaw, phiRaw, dphiRaw, flagRaw, 
    ampTfi, dampTfi, phiTfi, dphiTfi, flagTfe, 
    ampTfe, dampTfe, phiTfe, dphiTfe, flagTfe  
  oiDataCal = oiDataTfe = [];
  
  
  /* Check arguments */
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;
  if (is_void(tdelta))    tdelta = 1./288.;
  if (is_void(tfMode))    tfMode = 2;
  if (is_void(minAmpErr)) minAmpErr = 0.02;
  if (is_void(minPhiErr)) minPhiErr = 0.1;
  if( !oiFitsIsOiData(oiDataRaw) ) return yocoError("oiDataRaw not valid");
  if( !oiFitsIsOiData(oiDataTfp) ) return yocoError("oiDataTfp not valid");
  if( !oiFitsIsOiArray(oiArray) )  return yocoError("oiArray not valid");

  /* Prepare output and sort */
  oiDataCal = oiDataTfe = [];
  oiDataRaw = oiDataRaw(sort(oiDataRaw.mjd));
  oiDataTfp = oiDataTfp(sort(oiDataTfp.mjd));

  /* Found the different setup, add the baseline so discriminate them */
  setupTfp = funcSetup(oiDataTfp, oiLog) + " - " + oiFitsGetBaseName(oiDataTfp, oiArray);
  setupRaw = funcSetup(oiDataRaw, oiLog) + " - " + oiFitsGetBaseName(oiDataRaw, oiArray);
  setIdRaw = oiFitsUniqueIdLoop(setupRaw);

  
  /* --- Loop on the setup, to calibrate them individually */
  for (i=1 ; i<=max(setIdRaw) ; i++) {

    /* Found the TF and Obs estimations for this setup */    
    thisSetup = setupRaw( where(setIdRaw==i) )(1);
    oDataTfp  = oiDataTfp( where( setupTfp == thisSetup) );
    oDataRaw  = oiDataRaw( where( setupRaw == thisSetup) );
    nTfp      = numberof(oDataTfp);

    /* Some verbose information in case the setup is uncalibratable
       but contains some real information (not INTERNAL source) */
    if ( nTfp==0 ) {
      /* get the target names if possible */
      target = yocoListClean( ( is_array(oiTarget) ? oiFitsGetTargetName(oDataRaw,oiTarget) : oDataRaw.targetId ) );
      if ( anyof( (target!="INTERNAL")*(target!="UNKNOWN") ) ) {
        yocoLogWarning,"No TF estimation for setup:", thisSetup;
        yocoLogInfo,"   average mjd="+pr1(oDataRaw.mjd(avg))+"; targets=" + pr1( target );
      }
      continue;
    }

    /* Extract TF */
    yocoLogTest,"Found TF-points for setup: "+thisSetup;

    /* Prepare the output of calibrated data and tf-estimation data */
    oDataCal = oDataInt = oDataTfe = [];
    oDataTfe = oDataRaw(*);
    oDataTfi = oDataRaw(*);


    _tffunc = [];
    if ( is_func(tfMode) ) {
      /* CASE: tfMode is a user function */
      _tffunc = tfMode;
    } else if ( (tfMode==0 || tfMode=="interp") && nTfp>1 ) {
      /* CASE: point-to-point interpolation (need 2 points) */
      _tffunc = oiFitsTfInterp;
    } else if ( (tfMode==1 || tfMode=="smooth") && nTfp>=2 ) {
      /* CASE: temporal weithing (need 2 points) */
      _tffunc = oiFitsTfSmoothLength;
    } else if ( (tfMode==2 || tfMode=="average") && nTfp>=2) {
      /* CASE: average value of the Tf (need 2 points) */
      _tffunc = oiFitsTfAverage;
    } else if ( (tfMode==3 || tfMode=="linear") && nTfp>=3) {
      /* CASE: linear fit (need 3 points) */
      _tffunc = oiFitsTfLinearFit;
    } else if ( (tfMode==4 || tfMode=="quadratic") && nTfp>=4) {
      /* CASE: quadratic fit (need 4 points) */
      _tffunc = oiFitsTfQuadraticFit;
    } else if ( (tfMode==5 || tfMode=="altaz") && nTfp>=4) {
      /* CASE:  Alt-Az fit (need 4 points) */
      _tffunc = oiFitsTfAltAzFit;
    } else if ( (tfMode==6 || tfMode=="altazfree") && nTfp>=5) {
      /* CASE:  Alt-Az fit (need 3 points) */
      _tffunc = oiFitsTfAltAzFreeFit;
    } else if ( (tfMode==7 || tfMode=="smoothtimedist") && nTfp>=2) {
      /* CASE:  smooth in time and distance (need 3 points) */
      _tffunc = oiFitsTfSmoothTimeSky;
    }

    /* Check if still void */
    if ( is_void(_tffunc) ) {
      yocoLogTrace,"Too few TF-datapoints ("+pr1(nTfp)+") to allow"+
        "tfMode "+pr1(tfMode)+" (replaced by a simple average): ",thisSetup;
      _tffunc = oiFitsTfAverage;
    }

    /* Enlarge oDataTfe, larger than the time spanned by the data, so that the
       display is smooth */
    if ( !onTime && _tffunc != oiFitsTfSmoothTimeSky) {
      nTfe    = long( abs(oDataRaw.mjd(ptp)) / tdelta ) + 2;
      grow, oDataTfe, array( oDataTfe(1), nTfe);
      oDataTfe(-nTfe+1:0).mjd = span(min(oDataRaw.mjd)-tdelta, max(oDataRaw.mjd)+tdelta, nTfe);
    }
    
    /* We consider a maximum accuracy on the measurement of the TF estimation */
    oiFitsGetData, oDataTfp, ampTfp, dampTfp, phiTfp, dphiTfp, flagTfp, 1;    
    dampTfp = max(dampTfp,abs(minAmpErr*ampTfp));
    dphiTfp = max(dphiTfp, minPhiErr);
    oiFitsSetDataArray, oDataTfp, ,ampTfp, dampTfp, phiTfp, dphiTfp, flagTfp;

    /* Compute and interpolate the TF, with the previously defined function */
    _tffunc, oDataTfp, oDataTfi, oiLog, errMode=errMode, param=param;
    _tffunc, oDataTfp, oDataTfe, oiLog, errMode=errMode, param=param;

    /* Get the TF values */
    oiFitsGetData, oDataRaw, ampRaw, dampRaw, phiRaw, dphiRaw, flagRaw, 1;
    oiFitsGetData, oDataTfi, ampTfi, dampTfi, phiTfi, dphiTfi, flagTfe, 1;
    oiFitsGetData, oDataTfe, ampTfe, dampTfe, phiTfe, dphiTfe, flagTfe, 1;
    
    /* Avoid null values in the TF */
    ampTfi  += 1e-10;
    dampTfi += 1e-10;
    ampRaw  += 1e-10;
    
    /* We consider a maximum accuracy on the calibration */
    dampTfe = max(dampTfe, abs(minAmpErr*ampTfe));
    dampTfi = max(dampTfi, abs(minAmpErr*ampTfi));
    dphiTfe = max(dphiTfe, minPhiErr);
    dphiTfi = max(dphiTfi, minPhiErr);
    
    /* Now apply the TF and propagate it to Amplitude data */
    ampCal  = ampRaw  / ampTfi;
    dampCal = abs( dampRaw/ampRaw*ampCal , dampTfi/ampTfi*ampCal);

    /* Now apply the TF and propagate it to Phase data */
    phiCal  = phiRaw - phiTfi;
    dphiCal = abs(dphiRaw, dphiTfi);

    /* FIXME: flag is not handled */
    flagCal = array(char(0),dimsof(ampCal));
    flagTfe = array(char(0),dimsof(ampTfe));
    
    /* Put the data back */
    oDataCal = oDataTfi(*);
    oiFitsSetDataArray, oDataCal,, ampCal, dampCal, phiCal, dphiCal, flagCal;
    oiFitsSetDataArray, oDataTfe,, ampTfe, dampTfe, phiTfe, dphiTfe, flagTfe;

    /* Ack for EXOZODI */
    if ( oiFitsStrHasMembers(oDataTfi,"vis2ErrSys") ) {
      statTi  = oiFitsGetStructData(oDataTfi,"vis2ErrSys",1);
      statCal = statTi / ampTfi * ampCal;
      oiFitsSetStructDataArray,oDataCal,,"vis2ErrSys",statCal;
    }

    /* Grow the output arrays */
    grow, oiDataCal, oDataCal;
    grow, oiDataTfe, oDataTfe;
    
  } /* --- End loop on setup */

  /* Sort by time */
  oiDataCal = oiDataCal(sort(oiDataCal.mjd));
  oiDataTfe = oiDataTfe(sort(oiDataTfe.mjd));

  yocoLogTrace,"oiFitsApplyTf done";
  return 1;
}

/* ---------------------------------------------------------------------------
   Sort-of high level routine
   --------------------------------------------------------------------------- */

func oiFitsCalibrateNight(oiVis2, oiT3, oiVis, oiWave, oiArray, oiTarget,
                          oiLog, oiDiam,
                          &oiVis2Cal, &oiVisCal, &oiT3Cal,
                          &oiVis2Tfp,&oiVisTfp,&oiT3Tfp,
                          &oiVis2Tfe,&oiVisTfe,&oiT3Tfe,
                          vis2TfMode=, t3TfMode=, visTfMode=,
                          vis2TfErrMode=,t3TfErrMode=,visTfErrMode=,
                          vis2TfParam=,t3TfParam=,visTfParam=,
                          overwrite=, fileRoot=)
/* DOCUMENT oiFitsCalibrateNight(oiVis2, oiT3, oiVis, oiWave, oiArray,
                          oiTarget, oiLog, oiDiam,
                          &oiVis2Cal, &oiVisCal, &oiT3Cal,
                          &oiVis2Tfe, &oiVisTfe, &oiT3Tfe,
                          vis2TfMode=, t3TfMode=, visTfMode=,
                          overwrite=, fileRoot=)

   DESCRIPTION
   Calibrate from the transfer function of the night by computing the TF
   on the calibrators and removing it from all data (from both science and cal)
   
   Execute the following functions on oiVis2, oiT3, and oiVis:
   - oiFitsExtractTf    : extract the TF-estimations
   - oiFitsApplyTf      : interpolate TF-estimations and calibrate the data
                          (opt: tfMode)

   The calibrated oiData are stores into proper OIFITS files, one
   per 'insName' setup during the night, using oiFitsWriteFiles
   (opt: fileRoot, overwrite).

   Note that points obtained on the calibration stars are also calibrated
   and written into the file. So that: if the calibration star is unresolved,
   its vis2 is ~1, but if the calibration star is resolved its vis2 is <1.

   PARAMETERS
   - vis2TfMode, t3TfMode, visTfMode : see oiFitsApplyTf

   - fileRoot, overwrite : files where to write the calibrated data
     this file is eventually overwriten if overwrite=1
*/
{
  yocoLogInfo,"oiFitsCalibrateNight()";
  yocoLogInfo," dimsof(oiVis2)="+pr1(dimsof(oiVis2));
  yocoLogInfo," dimsof(oiVis) ="+pr1(dimsof(oiVis));
  yocoLogInfo," dimsof(oiT3)  ="+pr1(dimsof(oiT3));

  /* Init and reset outputs */
  oiT3Tfp = oiT3Tfa = oiT3Cal = oiT3Tfe =[];
  oiVis2Tfp = oiVis2Tfa = oiVis2Cal = oiVis2Tfe = [];
  oiVisTfp = oiVisTfa = oiVisCal = oiVisTfe = [];

  /* Check parameter */
  if( !oiFitsIsOiArray(oiArray) )   return yocoError("oiArray not valid");
  if( !oiFitsIsOiWave(oiWave) )     return yocoError("oiWave not valid");
  if( !oiFitsIsOiTarget(oiTarget) ) return yocoError("oiTarget not valid");
  if( !oiFitsIsOiLog(oiLog) )       return yocoError("oiLog not valid");
  if( !oiFitsIsOiDiam(oiDiam) )     return yocoError("oiDiam not valid");

  /* Default parameters */
  if ( is_void(fileRoot))  fileRoot=0;
  if ( is_void(overwrite)) overwrite=1;     // overwrite
  
  /* Extract the TF estimation over the night,
     Group them if possible, and calibrate the night */
  if (is_array(oiT3)) {
    if( !oiFitsIsOiT3(oiT3) ) return yocoError("oiT3 not valid");
    oiFitsExtractTf, oiT3, oiWave, oiDiam, oiT3Tfp;
    oiFitsApplyTf, oiT3, oiT3Tfp, oiArray, oiLog, oiT3Cal, oiT3Tfe, oiTarget,
      tfMode=t3TfMode, errMode=t3TfErrMode, param=t3TfParam;
  }

  /* Extract the TF estimation over the night */
  if (is_array(oiVis2)) {
    if( !oiFitsIsOiVis2(oiVis2) ) return yocoError("oiVis2 not valid");
    oiFitsExtractTf, oiVis2, oiWave, oiDiam, oiVis2Tfp;
    oiFitsApplyTf, oiVis2, oiVis2Tfp, oiArray, oiLog, oiVis2Cal, oiVis2Tfe, oiTarget,
      tfMode=vis2TfMode, errMode=vis2TfErrMode, param=vis2TfParam;
  }

  /* Extract the TF estimation over the night */
  if (is_array(oiVis)) {
    if( !oiFitsIsOiVis(oiVis) ) return yocoError("oiVis not valid");
    oiFitsExtractTf, oiVis, oiWave, oiDiam, oiVisTfp;
    oiFitsApplyTf, oiVis, oiVisTfp, oiArray, oiLog, oiVisCal, oiVisTfe, oiTarget,
      tfMode=visTfMode, errMode=visTfErrMode, param=visTfParam;
  }
  
  /* Write the calibrated OIFITS */
  if ( fileRoot!=0 ) {
    oiFitsWriteFiles, fileRoot, oiTarget, oiWave, oiArray, oiVis2Cal,
      oiVisCal, oiT3Cal, oiLog, overwrite=overwrite;
  }
  
  yocoLogTrace,"oiFitsCalibrateNight done";
  return 1;
}

func oiFitsPlotCalibratedNight(oiWave, oiArray, oiLog, oiTarget, oiDiam,
                               oiVis2, oiVis2Cal, oiVis2Tfe, oiVis2Tfp,
                               oiT3, oiT3Cal, oiT3Tfe, oiT3Tfp,
                               oiVis, oiVisCal, oiVisTfe, oiVisTfp,
                               Avg=, win=, fileRoot=, plotBase=, nameCal=,
                               X0=, X=)
/* DOCUMENT oiFitsPlotCalibratedNight(oiWave, oiArray, oiLog, oiTarget, oiDiam,
                               oiVis2, oiVis2Cal, oiVis2Tfe, oiVis2Tfp,
                               oiT3, oiT3Cal, oiT3Tfe, oiT3Tfp,
                               oiVis, oiVisCal, oiVisTfe, oiVisTfp,
                               Avg=, win=, fileRoot=,
                               nameCal=, X0=, X=)

   DESCRIPTION
   Function to plot the result of the calibration process.
   This function is more for internal use than really user-oriented.
   (very few tests are performed).

   PARAMETERS
   The parameters are the same as oiFitsCalibrateNight.

   SEE ALSO
 */
{
  local dy, nc, nv, col, color, x;
  local vName, cName, port, Min, Max, name;
  yocoLogInfo,"oiFitsPlotCalibratedNight()";

  /* Default for X is the time */
  if( is_void(X) ) X="mjd";
  Xtitle = (is_string(X) ? strcase(1,X) : pr1(X) );
  
  
  /* reference time */
  if ( is_void(X0) && (X=="mjd") )
    X0 = int ( median( grow( ( is_array(oiVis2) ? median(oiVis2.mjd) : 1e9 ),
                             ( is_array(oiVis)  ? median(oiVis.mjd)  : 1e9 ),
                             ( is_array(oiT3)   ? median(oiT3.mjd)   : 1e9 ) )) );
  if ( is_void(X0) ) X0 = 0.0;
    
  /* Default */
  if ( is_void(Avg))       Avg=[[1.641,1.71233],[2.04,2.06]];
  if ( is_void(fileRoot))  fileRoot=0;
  if ( is_void(win) )      win=1;
  if ( is_void(nameCal) )  nameCal = 0;

  /* Prepare the number of base of be ploted */
  nv2 = nv = nc = 2;
  if (is_array(oiVis2)) nv2  = max( (bvId = oiFitsGetBaseId(oiVis2, oiVis2, oiArray, v2Name)));
  if (is_array(oiVis))  nv   = max( (bvId = oiFitsGetBaseId(oiVis, oiVis, oiArray,  vName)));
  if (is_array(oiT3))   nc   = max( (bcId = oiFitsGetBaseId(oiT3,   oiT3, oiArray, cName)));

  /* Define the colors */
  color = 1+(!oiFitsGetIsCal(oiTarget()(*),oiDiam))(*)(psum);
  color = int(double(color) / max(color+1) * 200);
  color = color - oiFitsGetIsCal(oiTarget()(*),oiDiam)*(color + 3);
  isSci = where(!oiFitsGetIsCal(oiTarget,oiDiam));
  
  /* ---- Prepare the plot */
  yocoLogTrace,"Plot the oiVis2";
  winkill, win;
  if (nv2<=4) yocoNmCreate, win, 1, nv2,   dy=0.01, fx=-1;
  else        yocoNmCreate, win, 2, int(ceil(double(nv2)/2)), dy=0.01, dx=0.01, fx=-1;

  /* Plot the TF-interpolation and TF-estimates in black */
  if ( is_array(oiVis2Tfp) ) {
    oiFitsPlotTfTime, oiVis2Tfe, oiWave, X, oiArray, oiLog,
      Avg=Avg, X0=X0, color="black",
      tosys = oiFitsGetBaseId(oiVis2Tfe, oiVis2);
    oiFitsPlotOiData, oiVis2Tfp, oiWave, X, oiLog,
      Avg=Avg, fill=1, color="black", X0=X0,
      tosys = oiFitsGetBaseId(oiVis2Tfp, oiVis2),
      symbol= oiFitsGetSetupId(oiVis2Tfp, oiLog, oiVis2);
  }

  /*  Plot the raw points on science target,
      Plot the raw points on calib in small and black, with no errors */
  if ( is_array(oiVis2) ) {
    oiFitsPlotOiData, oiVis2, oiWave, X, oiLog, 
      Avg=Avg, fill=1, X0=X0,
      tosys = oiFitsGetBaseId(oiVis2,oiVis2), symbol= oiFitsGetSetupId(oiVis2, oiLog),
      color = color(yocoListId(oiVis2.targetId, oiTarget.targetId)),
      size  = 0.15^oiFitsGetIsCal(oiVis2,oiDiam),
      errFlag = (!oiFitsGetIsCal(oiVis2,oiDiam)),
      label = (nameCal ? oiFitsFindBestLabel(oiVis2, oiTarget, oiLog) : []),
      labelorient=1, labeljustify="RH", labelheight=8;
  }
  
  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);

  /* finalize this plot */
  yocoNmXytitles,Xtitle+" - "+pr1(X0),,[0.02,0.02];
  for (Min=1,Max=0,xMin=1e10,xMax=-1e10,i=1;i<=nv2;i++) {
    plsys,i; port= viewport();
    plt, v2Name(i), port(zcen:1:2)(1), port(4)-0.03, font=pltitle_font, justify="CB", height=pltitle_height;
    limits;
    Min = min(Min,limits()(3));
    Max = max(Max,limits()(4));
    xMin = min(xMin,limits()(1));
    xMax = max(xMax,limits()(2));
  }
  yocoNmRange,max(0),min(1.1,1.1*Max);
  yocoNmRangex,xMin - 0.05*(xMax-xMin), xMax + 0.05*(xMax-xMin);
  
  yocoNmMainTitle,"Transfer-Function vis2 (black) and Scientific vis2 (colors)" +
    "\naveraged in the range "+pr1(Avg)+"!mm",-0.02;
  palette,"rainbow.gp";
  plt,"+",0.798,1.03,tosys=0,height=5;


  /* ----  Prepare the second plot */
  yocoLogInfo,"Plot the oiT3";
  winkill,win+2;
  yocoNmCreate, win+2, 1, nc, dy=0.01, fx= ( nc==1 ? 1 : -1);

  /* Plot the TF interpolation and the TF-estimates in black */
  if ( is_array(oiT3Tfp) ) {
    oiFitsPlotTfTime, oiT3Tfe, oiWave, X, oiArray, oiLog,
      Avg=Avg,X0=X0,color="black",
      tosys = oiFitsGetBaseId(oiT3Tfe, oiT3);
    oiFitsPlotOiData, oiT3Tfp, oiWave, X, oiLog,
      Avg=Avg,fill=1,color="black",X0=X0,
      tosys = oiFitsGetBaseId(oiT3Tfp, oiT3), symbol= oiFitsGetSetupId(oiT3Tfp, oiLog, oiT3);
  }

  /*  Plot the raw points on science target,
      Plot the raw points on calib in small and black, with no errors */
  if ( is_array(oiT3) ) {
    oiFitsPlotOiData, oiT3, oiWave, X, oiLog, 
      Avg=Avg, fill=1, X0=X0,
      tosys = oiFitsGetBaseId(oiT3,oiT3), symbol= oiFitsGetSetupId(oiT3, oiLog),
      color = color(yocoListId(oiT3.targetId, oiTarget.targetId)),
      size  = 0.15^oiFitsGetIsCal(oiT3,oiDiam),
      errFlag = (!oiFitsGetIsCal(oiT3,oiDiam)),    
      label = (nameCal ? oiFitsFindBestLabel(oiT3, oiTarget, oiLog) : []),
      labelorient=1, labeljustify="RH", labelheight=8;
  }
  
  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);

  /* finalize this plot */
  yocoNmXytitles,Xtitle+" - "+pr1(X0),cName,[0.02,0.02];
  for (Min=180,Max=-180,xMin=1e10,xMax=-1e10,i=1;i<=nc;i++) {
    plsys,i;limits;
    range, max(-190, limits()(3)), min(190, limits()(4));
    xMin = min(xMin,limits()(1));
    xMax = max(xMax,limits()(2));
  }
  yocoNmRangex,xMin - 0.05*(xMax-xMin), xMax + 0.05*(xMax-xMin);
  yocoNmMainTitle,"Transfer-Function t3Phi (black) and Scientific t3Phi (colors)" +
    "\naveraged in the range "+pr1(Avg)+"!mm",-0.02;
  palette,"rainbow.gp";
  plt,"+",0.798,1.03,tosys=0,height=5;


  /* ---- Prepare the fourth plot */
  yocoLogInfo,"Plot the oiVisPhi";
  winkill,win+4;
  if (nv<=4) yocoNmCreate, win+4, 1, nv,   dy=0.01, fx=-1;
  else       yocoNmCreate, win+4, 2, int(ceil(double(nv)/2)), dy=0.01, dx=0.01, fx=-1;

  /* Plot the TF-interpolation and TF-estimates in black */
  if ( is_array(oiVisTfp) ) {
    oiFitsPlotTfTime, oiVisTfe, oiWave, X, oiArray, oiLog,
      Avg=Avg, X0=X0, color="black",
      tosys = oiFitsGetBaseId(oiVisTfe, oiVis);
    oiFitsPlotOiData, oiVisTfp, oiWave, X, oiLog, 
      Avg=Avg, fill=1, color="black", X0=X0,
      tosys = oiFitsGetBaseId(oiVisTfp, oiVis),
      symbol= oiFitsGetSetupId(oiVisTfp, oiLog, oiVis);
  }
  /*  Plot the raw points on science target,
      Plot the raw points on calib in small and black, with no errors */
  if ( is_array(oiVis) ) {
    oiFitsPlotOiData, oiVis, oiWave, X, oiLog, 
      Avg=Avg, fill=1, X0=X0, 
      tosys = oiFitsGetBaseId(oiVis,oiVis), symbol= oiFitsGetSetupId(oiVis, oiLog),
      color = color(yocoListId(oiVis.targetId, oiTarget.targetId)),
      size  = 0.15^oiFitsGetIsCal(oiVis,oiDiam),
      errFlag = (!oiFitsGetIsCal(oiVis,oiDiam)),    
      label = (nameCal ? oiFitsFindBestLabel(oiVis, oiTarget, oiLog) : []),
      labelorient=1, labeljustify="RH", labelheight=8;
  }
  
  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);
  
  /* finalize this plot */
  yocoNmXytitles,Xtitle+" - "+pr1(X0),,[0.02,0.02];
  if ( is_array(oiVis) ) {
  for (Min=180,Max=-180,xMin=1e10,xMax=-1e10,i=1;i<=nv;i++) {
    plsys,i; port= viewport();
    plt, vName(i), port(zcen:1:2)(1), port(4)-0.03, font=pltitle_font, justify="CB", height=pltitle_height;
    limits;
    Min = min(Min,limits()(3));
    Max = max(Max,limits()(4));
    xMin = min(xMin,limits()(1));
    xMax = max(xMax,limits()(2));
  }
  yocoNmRange, max(-190, Min), min(190, Max);
  yocoNmRangex,xMin - 0.05*(xMax-xMin), xMax + 0.05*(xMax-xMin);
  yocoNmMainTitle,"Transfer-Function visPhi (black) and Scientific visPhi (colors)" +
    "\naveraged in the range "+pr1(Avg)+"!mm",-0.02;
  palette,"rainbow.gp";
  plt,"+",0.798,1.03,tosys=0,height=5;
  }

  /* ---- Prepare the plot */
  yocoLogInfo,"Plot the oiVisAmp";
  winkill, win+7;
  if (nv2<=4) yocoNmCreate, win+7, 1, nv2,   dy=0.01, fx=-1;
  else        yocoNmCreate, win+7, 2, int(ceil(double(nv2)/2)), dy=0.01, dx=0.01, fx=-1;

  /* Plot the TF-interpolation and TF-estimates in black */
  if ( is_array(oiVisTfp) ) {
    oiFitsPlotTfTime, oiVisTfe, oiWave, X, oiArray, oiLog,
      Avg=Avg, X0=X0, color="black", data="visAmp",
      tosys = oiFitsGetBaseId(oiVisTfe, oiVis);
    oiFitsPlotOiData, oiVisTfp, oiWave, X, oiLog,
      Avg=Avg, fill=1, color="black", X0=X0, data="visAmp",
      tosys = oiFitsGetBaseId(oiVisTfp, oiVis),
      symbol= oiFitsGetSetupId(oiVisTfp, oiLog, oiVis);
  }

  /*  Plot the raw points on science target,
      Plot the raw points on calib in small and black, with no errors */
  if ( is_array(oiVis) ) {
    oiFitsPlotOiData, oiVis, oiWave, X, oiLog, 
      Avg=Avg, fill=1, X0=X0, data="visAmp",
      tosys = oiFitsGetBaseId(oiVis,oiVis), symbol= oiFitsGetSetupId(oiVis, oiLog),
      color = color(yocoListId(oiVis.targetId, oiTarget.targetId)),
      size  = 0.15^oiFitsGetIsCal(oiVis,oiDiam),
      errFlag = (!oiFitsGetIsCal(oiVis,oiDiam)),
      label = (nameCal ? oiFitsFindBestLabel(oiVis, oiTarget, oiLog) : []),
      labelorient=1, labeljustify="RH", labelheight=8;
  }
  
  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);

  /* finalize this plot */
  yocoNmXytitles,Xtitle+" - "+pr1(X0),,[0.02,0.02];
  for (Min=1,Max=0,xMin=1e10,xMax=-1e10,i=1;i<=nv2;i++) {
    plsys,i; port= viewport();
    plt, v2Name(i), port(zcen:1:2)(1), port(4)-0.03, font=pltitle_font, justify="CB", height=pltitle_height;
    limits;
    Min = min(Min,limits()(3));
    Max = max(Max,limits()(4));
    xMin = min(xMin,limits()(1));
    xMax = max(xMax,limits()(2));
  }
  yocoNmRange,max(0),min(1.1,1.1*Max);
  yocoNmRangex,xMin - 0.05*(xMax-xMin), xMax + 0.05*(xMax-xMin);
  
  yocoNmMainTitle,"Transfer-Function visAmp (black) and Scientific visAmp (colors)" +
    "\naveraged in the range "+pr1(Avg)+"!mm",-0.02;
  palette,"rainbow.gp";
  plt,"+",0.798,1.03,tosys=0,height=5;
  


  /* ---- Prepare the third plot */
  yocoLogInfo,"Plot the UV";
  winkill,win+3;
  if (nv2<=4) yocoNmCreate, win+3, 1, nv2,   dy=0.01, fx=-1;
  else        yocoNmCreate, win+3, 2, int(ceil(double(nv2)/2)), dy=0.01, dx=0.01, fx=-1;

  if (is_array(oiVis2Tfp)) {
    x = oiFitsGetXAxis(X, oiVis2Tfp, oiLog) - X0;
    yocoPlotPlpMulti, oiVis2Tfp.uCoord(-,),  x(-,),
      color = "black", fill=1, 
      tosys = oiFitsGetBaseId(oiVis2Tfp, oiVis2), symbol= oiFitsGetSetupId(oiVis2Tfp, oiLog, oiVis2);
    yocoPlotPlpMulti, oiVis2Tfp.vCoord(-,),  x(-,),
      color = "black", fill=1, 
      tosys = oiFitsGetBaseId(oiVis2Tfp, oiVis2), symbol= oiFitsGetSetupId(oiVis2Tfp, oiLog, oiVis2);
  }
  
  x = oiFitsGetXAxis(X, oiVis2, oiLog) - X0;
  yocoPlotPlpMulti, oiVis2.uCoord(-,),  x(-,),
    tosys = oiFitsGetBaseId(oiVis2, oiVis2), symbol= oiFitsGetSetupId(oiVis2, oiLog),
    color = color(yocoListId(oiVis2.targetId, oiTarget.targetId)),
    hide  = oiFitsGetIsCal(oiVis2,oiDiam);
  yocoPlotPlpMulti, oiVis2.vCoord(-,),  x(-,),
    tosys = oiFitsGetBaseId(oiVis2, oiVis2), symbol= oiFitsGetSetupId(oiVis2, oiLog),
    color = color(yocoListId(oiVis2.targetId, oiTarget.targetId)),
    hide  = oiFitsGetIsCal(oiVis2,oiDiam);
  yocoNmLimits;

  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);

  /* finalize this plot */
  yocoNmXytitles,Xtitle+" - "+pr1(X0),,[0.02,0.02];
  yocoNmMainTitle,"U and V for all observations, for test purpose",-0.02;
  palette,"rainbow.gp";
  plt,"+",0.798,1.03,tosys=0,height=5;

  /* ---- Prepare the fourth plot */
  winkill,win+5;
  yocoNmCreate, win+5, 1, 1, dy=0.01, fx=1, square=1;

  if ( is_func(oiFitsGetAlt) ) {

    /* Plot stellar trace */
    alt = oiFitsGetAlt(oiVis2, oiLog);
    az  = oiFitsGetAz(oiVis2, oiLog);
    
    yocoPlotPlpMulti,
      -((90-alt) * cos(az/180.*pi))(-,),
      ((90-alt) * sin(az/180.*pi))(-,),
      symbol= oiFitsGetSetupId(oiVis2, oiLog),
      color = color(yocoListId(oiVis2.targetId, oiTarget.targetId));
    
    /* Add altitude circles */
    pts = exp(2.i*pi * span(0,1,1000)) * span(0,90,10)(-,);
    yocoPlotPlgMulti, pts.im, pts.re, type=3;

    /* Add HA traces */
    dec = span(-90,+90,19)/180*pi;
    ha  = span(-12,12,25)/12*pi - pi/2;
    xyz = [ cos(dec(-,))*cos(ha), cos(dec(-,))*sin(ha), sin(dec(-,)) ];
    ang = -24.0/180.0*pi - pi/2;
    xyz = xyz(,,+) * [[1.0,0,0],[0,cos(ang),sin(ang)],[0,-sin(ang),cos(ang)]](,+);
    norm = abs(xyz(,,2),xyz(,,1));
    alt  = 90. - atan(xyz(,,3),norm)/pi*180;
    xx   = xyz(,,1)*alt / norm;
    yy   = xyz(,,2)*alt / norm;
    for (i=1;i<=numberof(dec);i++) {
      if ( numberof((id = where(xyz(,i,3)>0)))<1 ) continue;
      yocoPlotPlpMulti,yy(id,i),xx(id,i),symbol=4,size=0.3,fill=1,color=;
    }
    
    yocoNmLimits,-90,90,-90,90;
  }
  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);
  
  /* finalize this plot */
  yocoNmXytitles,"<- East","North ->",[0.02,0.02];
  yocoNmMainTitle,"Trace of observations on Sky (obs at -24deg)",-0.02;
  palette,"rainbow.gp";
  plt,"+",0.798,1.03,tosys=0,height=5;

  /* Eventually exit now */
  if (plotBase!=1) return 1;

  /* store the ps */
  if ( fileRoot!=0 ) {
    window,win;
    pdf,fileRoot+"_TFvis2_"+pr1(Avg(min))+"-"+pr1(Avg(max))+".pdf";
    window,win+2;
    pdf,fileRoot+"_TFt3phi_"+pr1(Avg(min))+"-"+pr1(Avg(max))+".pdf";
    window,win+3;
    pdf,fileRoot+"_TFuv.pdf";
    window,win+4;
    pdf,fileRoot+"_TFvis_"+pr1(Avg(min))+"-"+pr1(Avg(max))+".pdf";
  }
  
  /* --- Plot the vis2 and closure-phase versus baseline --- */
  winkill, win+1;
  yocoNmCreate, win+1, 1, 2, dy=0.05, fx=-1;

  /* Plot the vis2 on science data only */
  if ( is_array(oiVis2Cal) ) {
    oiFitsPlotOiData, oiVis2Cal,  oiWave, "lambda", fill=1, tosys=1,
      symbol= oiFitsGetSetupId(oiVis2Cal, oiLog, oiVis2),
      color = color(yocoListId(oiVis2.targetId, oiTarget.targetId)),
      hide  = oiFitsGetIsCal(oiVis2Cal,oiDiam), link=1;
  }
  
  /* Plot the t3Phi on science data only */
  if ( is_array(oiT3Cal) ) {
    oiFitsPlotOiData, oiT3Cal,  oiWave, "lambda", fill=1, tosys=2,
      symbol= oiFitsGetSetupId(oiT3Cal, oiLog,oiT3),
      color = color(yocoListId(oiT3.targetId, oiTarget.targetId)),
      hide  = oiFitsGetIsCal(oiT3Cal,oiDiam), link=1;
  }
  
  /* Add the target names */
  oiFitsPlotColoredTargetList, oiTarget(isSci), color(isSci);

  /* final plots */
  yocoNmXytitles,"!l  (!mm)",["Calibrated vis2","Calibrated Closure-phase (deg)"];
  yocoNmMainTitle,"Scientific Obs. versus wavelength",-0.02;
  yocoNmRangex;
  yocoNmRange,[0.,-60],[1.4,+60];
  yocoNmLimits, individual=1;
  palette,"rainbow.gp";

  /* store the ps */
  if ( fileRoot!=0 ) {
    pdf,fileRoot+"_Blambda_"+pr1(Avg(min))+"-"+pr1(Avg(max))+".pdf";
    yocoLogInfo,"oiFitsCalibrateNight done, inspect results in files:", fileRoot+"*.pdf and "+fileRoot+"*.fits";
  }

  yocoLogTrace,"oiFitsPlotCalibratedNight done";
  return 1;
}

func oiFitsPlotColoredTargetList(oiTarget, color)
{
  yocoLogTrace,"oiFitsPlotColoredTargetList()";
  if (!is_array(oiTarget)) return 0;
  
  yocoPlotPltMulti, yocoStrReplace(oiTarget.target,"_","!_"),
    span(0.07,0.8,numberof(oiTarget)+1)(zcen),
    [0.97,0.955](1+indgen(numberof(oiTarget))%2),
    tosys=0,justify="CH",font="timesB",
    color=color,height=12;

  yocoLogTrace,"oiFitsPlotColoredTargetList done";
  return 1;
}

func oiFitsFindBestLabel(oiData, oiTarget, oiLog, oiAll)
{
  local grpId, label, found;
  yocoLogTrace,"oiFitsFindBestLabel()";

  /* Find the groups and the default label */
  grpId = oiFitsFindGroupOiData(oiData, oiLog, oiAll);
  label = yocoStrReplace(oiFitsGetTargetName(oiData,oiTarget),"_","!_")+"         ";

  for (found=[],i=1;i<=numberof(grpId);i++) {
    if   (anyof(found==grpId(i))) label(i) = " ";
    else grow, found, grpId(i);
  }
  
  yocoLogTrace,"oiFitsFindBestLabel done";
  return label;
}



/* --------------------------------------------------------------------------- 
   Plot data contained into any OiData
   --------------------------------------------------------------------------- */

func oiFitsGraphicDpi(dpi=,ratio=,landscape=)
/* DOCUMENT oiFitsGraphicDpi(dpi=,ratio=,landscape=)

   DESCRIPTION
   Change the default size of the ploting windows.

   PARAMETERS
   - dpi= window size, default is 50.
   - ratio= fraction of the window that will be visible
     (can then be changed with mouse).
   - landscape=
 */
{
  yocoLogTrace,"oiFitsGraphicDpi()";
  
  /* Default and cast */
  dpi   = ( is_void(dpi) ? 50 : int(dpi)(1) );
  ratio = ( is_void(ratio) ? 1 : double(ratio)(1) );

  /* Size of the window */
  height = ( landscape ? 638. : 825.);
  width  = ( landscape ? 825. : 638.);
    
  /* Apply it */
  pldefault,dpi=dpi;
  for(i=0;i<=20;i++) {
    winkill,i;
    window,i,height=int(height/75.*dpi*ratio),
      width=int(width/75.*dpi*ratio),display="";
  }

  yocoLogTrace,"oiFitsGraphicDpi done";
  return 1;
}

func oiFitsGetXAxis(X, oiData, oiLog)
{
  /* Get the x-axis */
  if ( is_numerical(X) ) return X;
  else if ( X=="mjd" )   return oiData.mjd;
  else if ( X=="time" )  return oiData.time;
  else if ( X=="id" )    return oiFitsGetObsId(oiData);
  else if ( X=="altaz")  return oiFitsGetAltAz(oiData, oiLog);
  else if ( is_func(X) ) return X(oiData,oiLog);
  else return yocoError("X is not known!");
}

/* --- */

func oiFitsPlotTfTime(oiData, oiWave, X, oiArray, oiLog, Avg=, funcSetup=,
                      color=, type=, typeErr=, hide=, width=, tosys=, X0=)
/* DOCUMENT oiFitsPlotTfTime(oiData, oiWave, X, oiArray, oiLog, funcSetup=,
                             Avg=, color=, type=, typeErr=, hide=,
                             width=, tosys=)

   DESCRIPTION
   Plot the data versus time, with curve linking all points obtained
   in a given setup (all setups are plotted sequencially). Mainly
   used to plot the TF-interpolation versus time.

   PARAMETERS
   - oiData, oiWave, oiArray, oiLog:
   
   - X: numerical array of same dimension of oiData, or string:
     "mjd" or "time".
     
   - Avg: considered wavelength range (spectral bins are averaged together)
     Should be in mum and of the form:
     [Start, End] -or- [[S1,E1],...,[Si,Ei]]
     See oiFitsAverageSample to use the 'errMode' keyword.
     
   - color, type, typeErr, hide, width, tosys=: see 'plg'. They can be arrays
     of same dimension than oiData. For a considered setup, let's say the one
     corresponding to observations oiData([4,5,8,9]), the curves will be ploted
     with parameters: color(4), width(4)... that is the one of the first
     observation of this setup.

   - funcSetup: see oiFitsApplyTf

   EXAMPLES
   > oiFitsPlotTfTime, oiVis2Tf, oiWave, "mjd", oiArray, oiLog,
     Avg=[2.2,2.3], color = "black", tosys = oiFitsGetBaseId(oiVis2Tf);

 */
{
  local x,y,dy,i,lbd,id,idl,obsId,phase;
  yocoLogTrace,"oiFitsPlotTfTime()";
  
  /* Check for arguments */
  if (is_void(wlimit))  wlimit = [0.,10.];
  if (is_void(Avg))     Avg = 1;
  if (is_void(tosys))   tosys = 1;
  if (is_void(type))    type = 1;
  if (is_void(typeErr)) typeErr = 4;
  if (is_void(X0))      X0 = 0.0;
  

  if( !oiFitsIsOiWave(oiWave) ) return yocoError("oiWave not valid");
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if (is_void(funcSetup)) funcSetup = oiFitsDefaultSetup;

  /* Get the setups, UniqueIdLoop is more efficient on long string array */
  setup = funcSetup(oiData, oiLog) + " - " + oiFitsGetBaseName(oiData, oiArray);
  setId = oiFitsUniqueIdLoop(setup);

  /* Get the x-axis */
  X = oiFitsGetXAxis(X, oiData, oiLog);
  
  /* --- Loop on the setup, to plot them individually */
  for (i=1 ; i<=max(setId) ; i++) {
    id  = where( setId == i);
    oiD = oiData(id);
    
    /* Get the wavelength bin concerned */
    wave = oiFitsGetLambda(oiD(1), oiWave);
    idl  = oiFitsGetIntervId(Avg,wave);

    /* if none, continue*/
    if ( !is_array(idl) ) {
      yocoLogTrace,"Some oiData are out of the wavelength range!";
      continue;
    }

    /* Extract data */
    if (oiFitsIsOiVis(oiD)) {
      phase = 1;
      oiFitsGetData,oiD,,,y,dy,flag, 1;
    } else if (oiFitsIsOiT3(oiD)) {
      phase = 1;
      oiFitsGetData,oiD,,,y,dy,flag, 1;
    } else if (oiFitsIsOiVis2(oiD)) {
      phase = 0;
      oiFitsGetData,oiD,y,dy,,,flag, 1;
    } else {
      return yocoError("yocoPlotTfTime can only handle oiVis, oiVis2 and oiT3.");
    }
    
    /* Keep only the good sample */
    y  =  y(idl,);
    dy = dy(idl,);

    /* Average over the wavelength */
    oiFitsAverageSample, y, dy, errMode=3, which=1, phase=phase;

    /* Define the x-axis and sort it */
    x = X(id) - _get_param(X0, id);
    s = sort(x);
       
    /* Plot the data */
    plsys, _get_param(tosys, id(1));
    plg, y(s), x(s),
      color = (_col = _get_param(color,id(1))),
      type  = (_typ = _get_param(type,id(1))),
      width = (_wid = _get_param(width,id(1))),
      marks = (_mar = _get_param(marks,id(1))),
      hide  = (_hid = _get_param(hide,id(1)));
    
    /* Plot error bars */
    plg, (y+dy)(s), x(s),
      type  = (_tyE = _get_param(typeErr,id(1))),
      color = _col, width=_wid, marks=_mar, hide=_hid;
    plg, (y-dy)(s), x(s),
      type  = (_tyE = _get_param(typeErr,id(1))),
      color = _col, width=_wid, marks=_mar, hide=_hid;

  } /* --- end loop on setup */

  yocoLogTrace,"oiFitsPlotTfTime done";
  return 1;
}

/* --- */

func oiFitsPlotOiData(oiData,oiWave,X,oiLog,
                      Avg=,X0=,Y0=,Xm=,wlimit=,
                      color=,type=, symbol=, width=, tosys=,
                      size=,fill=,hide=,link=,
                      multiCal=,addCal=,errFlag=,
                      maxErr=,
                      label=, labelheight=, labelorient=,
                      labeljustify=, labelfont=,
                      lbdcol=, data=)
/* DOCUMENT oiFitsPlotOiData(oiData,oiWave,X,oiLog,
                    Avg=,X0=,Y0,Xm=,wlimit=,
                    color=,type=, symbol=, width=, tosys=,
                    size=,fill=,hide=,link=,errFlag=,maxErr=)

   DESCRIPTION
   Plot an oiData array (oiVis,oiVis2,oiT3). Phases are ploted in deg,
   and vis2 is ploted in 0-1. By default, the following quantities are ploted:
   - oiVis2 -> vis2Data (absolute square visibility)
   - oiVis  -> visPhi (differential phase)
   - oiT3   -> t3Phi (closure phase)

   
   PARAMETERS
   - oiData   : oiVis, oiT3 or oiVis2 (can be arrays)
   
   - oiWave   : oiWave (can be array)
   
   - X        : string, X axis of the plot, can be:
                "mjd", "time", "angle", "base" (B/lbd),
                "lambda", "velocity" or "none".
                "baseline (m)".
                If X="velocity", the X0 keyword is used as central
                wavelength to compute the Doppler shift.
            Example:
            > oiFitsPlotOiData, oiVis2, oiWave, "mjd";
            > oiFitsPlotOiData, oiVis2, oiWave, "velocity", X0=2.176;

                
   - X0, Y0=: offset of the X and Y axes. Should be scalar
            or have same dimension than the oiFits. Can be used
            to offset differently each oiData.
            Example:
            > oiFitsPlotOiData, oiVis2, oiWave, "mjd", X0=54993.2;
            
   - Xm=    : multiplicative factor for X dimension, usefull
            to change units for instance.
            Example (time in hours):
            > oiFitsPlotOiData, oiVis2, oiWave, "mjd", X0=54993.2, Xm=24;
            
   - wlimit: Spectral range of the oiFits data to be plotted,
            in microns. Default is [0,10].
            Example:
            > oiFitsPlotOiData, oiVis2, oiWave, "lambda", wlimit=[2.15,2.19];

   - Avg= : Perform an average over the spectral dimension with
            function 'oiFitsAverageData' (see its help)
            Example:
            > oiFitsPlotOiData, oiVis2, oiWave, "time", wlimit=[2.1,2.15], Avg=1;

   - maxErr= : Do not plot the points with error larger than maxErr.
            Note that points with flag!=char(0) will not be plotted anyway.

   - color, type, symbol with, tosys, size, fille, hide=:
            Standart ploting parameters. Should be scalar
            or same dimension than the oiFits.
            Example (symbol for the target and color for the base):
            > oiFitsPlotOiData, oiVis2, oiWave, "time",
              symbol=oiVis2.targetId, color=-4-oiFitsGetBaseId(oiVis2);

   - link=: Use as the 'type' keyword of function 'plg'
            (solid, dash, dot...). If set to zero (default), no
            lines are plotted between the data points.

   - errFlag=1: error bars will not be plotted.

   - lbdcol=: define a wavelength-specific color by defining
            [ [lbdMin, lbdMax], [colorMin, colorMax] ].

   CAUTIONS
   - multiCal, addCal=: ** Not Tested Yet **
     
   SEE ALSO:
 */
{
  local i,x,y,dy, vt, phase;
  local _color,_type,_sizebar,_width,_Y0,_wave, X0i, flag;
  local oiA, pY, pYErr, aBAse, conv;
  yocoLogTrace,"oiFitsPlotOiData()";
  
  /* Check for arguments */
  if( !oiFitsIsOiWave(oiWave) ) return yocoError("oiWave not valid");
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  
  /* default values */
  if (is_void(Avg))     Avg = 0;
  if (is_void(X0))      X0 = 0.0;
  if (is_void(Y0))      Y0 = 0.0;
  if (is_void(Xm))      Xm = 1.0;
  if (is_void(tosys))   tosys = plsys();
  if (is_void(width))   width  = 1.0;
  if (is_void(link))    link   = 0;
  if (is_void(maxErr))  maxErr = 180.0;

  /* Some measures */
  aBase = oiFitsGetBaseLength(oiData);
  aAng  = oiFitsGetBaseAngle(oiData);

  /* load the data and errors */
  if (oiFitsIsOiVis2(oiData)) {
    phase = 0;
    pY    = "vis2Data";
    pYErr = "vis2Err";
  }
  else if (oiFitsIsOiT3(oiData)) {
    phase = 1;
    pY    = "t3Phi";
    pYErr = "t3PhiErr";
  }
  else if (oiFitsIsOiVis(oiData)) {
    if (data=="visAmp") {
      phase = 0;
      pY    = "visAmp";
      pYErr = "visAmpErr";
    }
    else {
      phase = 1;
      pY    = "visPhi";
      pYErr = "visPhiErr";
    }
  }
  else {
    return yocoError("This oiData is not knwon!");
  }

  /* Compute the obs id */
  obsId = oiFitsGetObsId(oiData);

  /* Loop on the oiA array */
  for ( i=1 ; i<=numberof(oiData) ; i++) {

  /* get the parameters for this oiA */
  oiA = oiData(i);

  /* Load the data from the structure.
     Should better use oiFitsGetData (to deal with the flags),
     although not critical because flag is explicitely handle by
     this function. */
  wave = oiFitsGetLambda(oiA,oiWave);
  y    = _ofGSD( oiA, pY    );
  dy   = _ofGSD( oiA, pYErr );
  flag = _ofGSD( oiA, "flag" );

  /* Load the x-data */
  x    = 0.*wave + i;
  X0i  = _get_param(X0,i);
  if      (X=="base")     x = aBase(i) / wave - X0i;
  else if (X=="freq")     x = aBase(i) / (wave*1e-6) * yocoAstroSI.as;
  else if (X=="baseline") x = aBase(i) + 0.*wave - X0i;
  else if (X=="angle")    x = aAng(i) + 0.*wave - X0i;
  else if (X=="lambda")   x = wave - X0i;
  else if (X=="time")     x = oiA.time + 0.*wave - X0i;
  else if (X=="mjd")      x = oiA.mjd + 0.*wave - X0i;
  else if (X=="id")       x = obsId(i) + 0.*wave - X0i;
  else if (X=="velocity") {
    x  = wave - X0i;
    x  = x/wave(avg,)(-,) * yocoAstroSI.c / 1e3;
  }
  else if (X=="altaz") {
    x = oiFitsGetAltAz(oiA, oiLog) + 0.*wave - X0i;
  }
  else if ( is_numerical(X) ) {
    x = _get_param(X,i) + 0.*wave - X0i;
  }
  else if ( is_func(X) ) {
    x = X(oiA, oiLog) + 0.*wave - X0i;
  }

  /* get the wlimits */
  if (is_array(wlimit) && is_array(( ids = _get_array(wlimit,i)))) {
    id    = oiFitsGetIntervId(ids,wave);
    y     = y(id);
    dy    = dy(id);
    x     = x(id);
    wave  = wave(id);
    flag  = flag(id);
  }

  /* Check the limits */
  if ( !is_array(x) ) {
    yocoLogTrace,"oiData("+pr1(i)+") has been skiped... no data inside the lbd range.";
    continue;
  }
  
  /* Check the data quality */
  id = where(flag==char(0) & dy<maxErr );
  if ( !is_array(x) || !is_array(id) ) {
    yocoLogTrace,"oiData("+pr1(i)+") has been skiped... no valid.";
    continue;
  } else {
    y     = y(id);
    dy    = dy(id);
    x     = x(id);
    wave  = wave(id);
    flag  = flag(id);
  }
  
  /* Some check */
  dy += 1e-10 * (dy==0);

  /* Deal with the case where Avg is an interval
     and no data in */
  if ( numberof(Avg)>1 && noneof(oiFitsIsInsideInterv(Avg,wave)) ) {
    yocoLogTrace,"oiData("+pr1(i)+") has been skiped... no valid data inside the range.";
    continue;
  }

  /* Make the average */
  oiFitsAverageData, y, dy, x, Avg, phase=phase;

  /* Use the Xm */
  if (is_array(Xm) && is_array((vt=_get_param(Xm,i,1)))) {
    x *= vt;
  }

  /* Use the specified calibration: Multiplicative*/
  if ( is_array(prodCal) && is_array((vt=_get_param(prodCal,i,1)))) {
    y  /= vt;
    dy /= vt;
  }

  /* Use the specified calibration: Sum */
  if (is_array(addCal) && is_array((vt=_get_param(addCal,i,1)))) {
    y  -= vt;
  }

  /* Plot the data */
  plsys,_get_param(tosys,i);
  if (_get_param(errFlag,i)==0) dy=[];
  
  /* Plot the curve */
  if (_get_param(link,i)) {
  plg,
    y - _get_param(Y0,i),
    x,
    color=_get_param(color,i),
    type=_get_param(link,i),
    width=_get_param(width,i),
    marks=0,
    hide=_get_param(hide,i);
  }

  if ( is_array(lbdcol) ) {
    yocoPlotPlpMulti,
      y(-,) - _get_param(Y0,i),
      x(-,),
      dy = dy(-,),
      type=_get_param(type,i),
      symbol=_get_param(symbol,i),
      fill=_get_param(fill,i),
      size=_get_param(size,i),
      width=_get_param(width,i),
      hide=_get_param(hide,i),
      color = int( interp(lbdcol(,2), lbdcol(,1), wave) );
  }
  else {
    yocoPlotPlp,
      y - _get_param(Y0,i),
      x,
      dy = dy,
      color=_get_param(color,i),
      type=_get_param(type,i),
      symbol=_get_param(symbol,i),
      fill=_get_param(fill,i),
      size=_get_param(size,i),
      width=_get_param(width,i),
      hide=_get_param(hide,i);
  }

  if (is_array(label)) {
    yocoPlotPltMulti, label(i), x, y - _get_param(Y0,i),
      color=_get_param(color,i),
      tosys=_get_param(tosys,i),
      hide=_get_param(hide,i),
      height=labelheight,
      orient=labelorient,
      justify=labeljustify,
      font=labelfont;
  }
  
  }
  
  /* if wlimit is define, also set the limits */
  if ( is_array(wlimit) && X=="lambda") { yocoNmRangex,min(wlimit),max(wlimit); }
  
  yocoLogTrace,"oiFitsPlotOiData done";
  return 1;
}

/* --- */

func oiFitsPlotUV(oiData,oiWave,wlimit=,tosys=,color=,symbol=,fill=,size=,width=,hide=,unit=,lbdcol=)
/* DOCUMENT oiFitsPlotUV(oiData,oiWave,wlimit=,tosys=,color=,
                         symbol=,fill=,size=,width=,hide=,
                         unit=,lbdcol=)

   DESCRIPTION
   Plot the UV plane of the observations contained into oiData.
   The plot is in meters.

   PARAMETERS
   - oiData:
   - tosys=, color=, symbol=, fill=, size=, width=, hide=:
     format of the plot, can be arrays of same length of oiData.
   - unit= "m" or "mum".

   NOTE:
   - wlimit are currently not used.
 */
{
  yocoLogInfo,"oiFitsPlotUV()";
  local i;

  /* some check */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if( !oiFitsIsOiWave(oiWave) ) return yocoError("oiWave not valid");

  /* some default */
  if (is_void(tosys))    tosys  = plsys();
  if (is_void(symbol))   symbol = 4;
  if (is_void(fill))     fill = 1;
  if (is_void(unit))     unit ="m";

  /* Loop on the oiA array */
  for ( i=1 ; i<=numberof(oiData) ; i++) {

    /* Get the data */
    flag = _ofGSD( oiData(i), "flag" );
    uCoord = oiData(i).uCoord;
    vCoord = oiData(i).vCoord;
    lbd    = oiFitsGetLambda(oiData(i),oiWave);

    /* Get the units */
    if (unit=="m") {
      uCoord = uCoord;
      vCoord = vCoord;
      flag = min(flag);
    } else if (unit=="mum") {
      uCoord = uCoord / lbd;
      vCoord = vCoord / lbd;
    } else {
      error,"unit is not known";
    }

  /* get the wlimits */
  if (is_array(wlimit) && is_array(( ids = _get_array(wlimit,i)))) {
    id = oiFitsGetIntervId(ids,lbd);
    uCoord = uCoord(id);
    vCoord = vCoord(id);
    lbd  = lbd(id);
    flag = flag(id);
  }

  /* Check flag for valid data only */
    id = where(flag==char(0));
    if ( is_array(id) ) {
      uCoord = uCoord(id);
      vCoord = vCoord(id);
      lbd    = lbd(id);
    } else {
      continue;
    }

    /* Go into the relevant system */
    plsys,_get_param(tosys,i);
    
    /* Plot the data */
    if ( is_array(lbdcol) ) {
      yocoPlotPlpMulti, vCoord(-,) ,  uCoord(-,),
        type=_get_param(type,i),
        symbol=_get_param(symbol,i),
        fill=_get_param(fill,i),
        size=_get_param(size,i),
        width=_get_param(width,i),
        hide=_get_param(hide,i),
        color = int( interp(lbdcol(,2), lbdcol(,1), lbd) );
      
      yocoPlotPlpMulti, -vCoord(-,), -uCoord(-,),
        type=_get_param(type,i),
        symbol=_get_param(symbol,i),
        fill=_get_param(fill,i),
        size=_get_param(size,i),
        width=_get_param(width,i),
        hide=_get_param(hide,i),
        color = int( interp(lbdcol(,2), lbdcol(,1), lbd) );
    } else {
      yocoPlotPlp, vCoord ,  uCoord,
        color=_get_param(color,i),
        type=_get_param(type,i),
        symbol=_get_param(symbol,i),
        fill=_get_param(fill,i),
        size=_get_param(size,i),
        width=_get_param(width,i),
        hide=_get_param(hide,i);
      
      yocoPlotPlp, -vCoord, -uCoord,
        color=_get_param(color,i),
        type=_get_param(type,i),
        symbol=_get_param(symbol,i),
        fill=_get_param(fill,i),
        size=_get_param(size,i),
        width=_get_param(width,i),
        hide=_get_param(hide,i);
    }
  }

  yocoLogTrace,"oiFitsPlotUV done";
  return 1;
}

/* --------------------------------------------------------------- */

func oiFitsCleanDataFromDummy(&oiVis2, &oiT3, &oiVis,
                              maxVis2Err=,
                              maxT3PhiErr=,
                              minBaseLength=)
/* DOCUMENT oiFitsCleanDataFromDummy(&oiVis2, &oiT3, &oiVis)

   DESCRIPTION
   Experimental: clean the data, so that they can be used for
   mira or LITpro software.

   Mainly put negative value for dummy point and make sure
   they are properly flaged.

   PARAMETERS
   maxVis2Err=
   minVis2Err=
   minBaseLength=

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsCleanDataFromDummy()";

  if (is_void(maxVis2Err))    maxVis2Err  = 0.75;
  if (is_void(maxT3PhiErr))   maxT3PhiErr = 140.0;
  if (is_void(minBaseLength)) minBaseLength = 0.0;

  /* Put bad data out-of-range (-1), to be sure
     they are flagged by MIRA and LITpro */
  for (i=1;i<=numberof(oiVis2);i++) {
    oiFitsGetData, oiVis2(i),amp,ampErr,phi,phiErr,flag;
    if (!is_array( (id = where(ampErr>maxVis2Err | flag!=char(0)) ))) continue;
    amp(id)    = -1.0;
    ampErr(id) =  0.0;
    flag(id) = char(1);
    oiFitsSetData, oiVis2,i,amp,ampErr,phi,phiErr,flag;
  }

  /* Put bad data out-of-range (-200deg), to be sure
     they are flagged by MIRA and LITpro */
  for (i=1;i<=numberof(oiT3);i++) {
    oiFitsGetData, oiT3(i),amp,ampErr,phi,phiErr,flag;
    if (!is_array( (id = where(phiErr>maxT3PhiErr | flag!=char(0)) ))) continue;
    phi(id)    = -200.0;
    phiErr(id) = 0.0;
    flag(id) = char(1);
    oiFitsSetData, oiT3,i,amp,ampErr,phi,phiErr,flag,nowrap=1;
  }

  /* Remove points with abs(u,v)==0 */
  if ( is_array(oiVis2) ) {
    id = where(oiFitsGetBaseLength(oiVis2)>minBaseLength);
    oiVis2 = oiVis2(id);
  }
  if ( is_array(oiVis) ) {
    id = where(oiFitsGetBaseLength(oiVis)>minBaseLength);
    oiVis = oiVis(id);
  }
  if ( is_array(oiT3) ) {
    id = where(oiFitsGetBaseLength(oiT3)>minBaseLength);
    oiT3 = oiT3(id);
  }
  
  yocoLogTrace,"oiFitsCleanDataFromDummy done";
  return 1;
}

/* --------------------------------------------------------------- */

func oiFitsArg(x)
/* DOCUMENT oiFitsArg(x)

   DESCRIPTION
   Return the argument of x in rad.
 */
{
  return structof(x)==complex ? atan(x.im,x.re) : x*0.0;
}

func oiFitsConvertSimpleFileToAscii(file, output)
/* DOCUMENT oiFitsConvertSimpleFileToAscii(file, output)

   DESCRIPTION
   Convert a simple OIFITS file (containing a single OI_WAVELENGTH table)
   into an ASCII file with well-defined columns. The output file contains:
   - lbd [mum], u [m], v [m], basename
   - all oiVis2.vis2 and errors
   - all oiVis.visPhi and errors
   - all oiT3.t3phi and errors

   PARAMETERS

   EXAMPLES
   cd, "/Volumes/Datas/Datas/deltaScoData/deltaScoData_SVN_20110819_11161_OIDATA_APP_AVG_SPEC_CAL";
   f = "AMBER.2010-05-10T08:02:24.857_-9:40.712_OIDATA_CAL_SPEC.fits";
   oiFitsConvertSimpleFileToAscii, f;
   
   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsConvertSimpleFileToAscii()";
  
  /* Load the file */
  oiFitsLoadFiles, file, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;

  /* Deal with simple files only */
  if ( numberof(oiWave) > 1) error,"Cannot deal with OIFITS file containing several OI_WAVELENGTH tables";

  /* Clean the output arrays */
  titles = "lbd [mum]";
  bname  = "basename";
  uCoord = "u [m]";
  vCoord = "v [m]";
  data   = swrite(format="%.6f", oiFitsGetLambda(oiWave(1)))(,-);
  
  /* Loop on data to build the output array */
  for ( i=1 ; i<=numberof(oiVis2) ;i++ )
    {
      oiFitsGetData, oiVis2(i), amp, ampErr;
      grow, data, swrite(format="%.3f", amp);
      grow, data, swrite(format="%.3f", ampErr);
      grow, titles, ["vis2","vis2Err"];
      grow, bname, oiFitsGetBaseName(oiVis2(i), oiArray)(-:1:2);
      grow, uCoord, swrite(format="%+.3f",oiVis2(i).uCoord)(-:1:2);
      grow, vCoord, swrite(format="%+.3f",oiVis2(i).vCoord)(-:1:2);
    }

   /* Loop on data to build the output array */
  for ( i=1 ; i<=numberof(oiVis) ;i++ )
    {
      oiFitsGetData, oiVis(i), ,, phi, phiErr;
      grow, data, swrite(format="%.3f", phi);
      grow, data, swrite(format="%.3f", phiErr);
      grow, titles, ["visPhi","visPhiErr"];
      grow, bname, oiFitsGetBaseName(oiVis(i), oiArray)(-:1:2);
      grow, uCoord, swrite(format="%+.3f",oiVis(i).uCoord)(-:1:2);
      grow, vCoord, swrite(format="%+.3f",oiVis(i).vCoord)(-:1:2);
    }

  /* Loop on data to build the output array */
  for ( i=1 ; i<=numberof(oiT3) ;i++ )
    {
      oiFitsGetData, oiT3(i), , ,phi, phiErr;
      grow, data, swrite(format="%.3f", phi);
      grow, data, swrite(format="%.3f", phiErr);
      grow, titles, ["t3Phi","t3PhiErr"];
      grow, bname, oiFitsGetBaseName(oiT3(i), oiArray)(-:1:2);
      grow, uCoord, swrite(format="%.3f,%.3f",oiT3(i).u1Coord, oiT3(i).u2Coord)(-:1:2);
      grow, vCoord, swrite(format="%.3f,%.3f",oiT3(i).v1Coord, oiT3(i).v2Coord)(-:1:2);
    }

  /* Attach the titles, bname and uv on top of
     the data into a common array */
  str = grow( [titles], bname, uCoord, vCoord, transpose(data) );

  /* Format them so that they have same length */
  for ( i=1 ; i<=numberof(titles) ; i++)
    {
      length  = strlen(str(i,))(max);
      str(i,) = swrite(format="%-"+pr1(length)+"s",str(i,));
    }

  /* Add a tabular between colum and compress them */
  str = strpart( (str+" \t")(sum,), 1:-2);

  /* Default for output file */
  if ( is_void(output) ) {
    local d,f,e;
    yocoFileSplitName,file,d,f,e;
    output = d+"/"+f+".txt";
  }

  /* Write the output file */
  yocoLogInfo,"Write ASCI file:", output;
  output = open(output,"w+");
  write,output,str;
  close,output;
  
  yocoLogTrace,"oiFitsConvertSimpleFileToAscii done";
  return 1;
}

func oiFitsCropOiData(&oiVis2, &oiVis, &oiT3, v2Max=,v2Min=)
{
  yocoLogInfo,"oiFitsCropOiData()";
  local amp, ampErr, phi, phiErr, flag, fakeWave;
  
  if (is_void(v2Min)) v2Min = -1e3;
  if (is_void(v2Max)) v2Max = 1e3;

  if (is_array(oiVis2))
    for ( i=1 ; i<=numberof(oiVis2) ; i++) {
      oiFitsGetData, oiVis2(i), amp, ampErr, phi, phiErr, flag, fakeWave;
      flag += (amp>v2Max) | (amp<v2Min);
      oiFitsSetData, oiVis2, i, amp, ampErr, phi, phiErr, flag;
    }


  yocoLogTrace,"oiFitsCropOiData done";
  return 1;
}

func oiFitsCropAccuracy(&oiVis2, &oiVis, &oiT3,
                        t3PhiErrMin=,v2RelErrMin=,v2ErrMin=)
/* DOCUMENT oiFitsCropAccuracy(&oiVis2, &oiVis, &oiT3, t3PhiErrMin=,v2RelErrMin=,v2ErrMin=)

   DESCRIPTION

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsCropAccuracy()";
  local amp, ampErr, phi, phiErr, flag, fakeWave;

  if (is_void(t3PhiErrMin)) t3PhiErrMin = 1.5;
  if (is_void(v2RelErrMin)) v2RelErrMin = 0.025;
  if (is_void(v2ErrMin))    v2ErrMin = 0.0005;
  
  if (is_array(oiT3))
    oiFitsOperandStructDataArray, oiT3, ,"t3PhiErr", t3PhiErrMin, "max";

  if (is_array(oiVis2))
    for ( i=1 ; i<=numberof(oiVis2) ; i++) {
      oiFitsGetData, oiVis2(i), amp, ampErr, phi, phiErr, flag, fakeWave;
      ampErr = max(ampErr, amp*v2RelErrMin, v2ErrMin);
      oiFitsSetData, oiVis2, i, amp, ampErr, phi, phiErr, flag;
    }

  if (is_array(oiVis))
    yocoLogWarning,"Not yet implemented.";  
  
  yocoLogTrace,"oiFitsCropAccuracy done";
  return 1;
}


/* ----------------------------------------------------------------------
   Data analysis functions
   ---------------------------------------------------------------------- */


func oiFitsAddNoise(&oiVis2, &oiT3)
/* DOCUMENT oiFitsAddNoise(&oiVis2, &oiT3)

   DESCRIPTION
   Add noise on the data with amplitude egual to the
   uncertainty. Usefull for bootstraping for instance.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"oiFitsAddNoise()";
  local i, amp, damp, phi, dphi;
  
  for (i=1;i<=numberof(oiVis2);i++) {
    oiFitsGetData, oiVis2(i), amp, damp, phi, dphi, flag, 1;
    amp += damp * random_n(numberof(damp));
    phi += dphi * random_n(numberof(dphi));
    oiFitsSetData, oiVis2, i, amp, damp, phi, dphi, flag;
  }
  
  for (i=1;i<=numberof(oiT3);i++) {
    oiFitsGetData, oiT3(i), amp, damp, phi, dphi, flag, 1;
    amp += damp * random_n(numberof(damp));
    phi += dphi * random_n(numberof(dphi));
    oiFitsSetData, oiT3, i, amp, damp, phi, dphi, flag;
  }
  
  yocoLogTrace,"oiFitsAddNoise done";
  return 1;
}

func oiFitsSearchOiT3ForCompanion(oiTarget, oiWave, oiArray, oiT3, oiVis2, oiLog,
                                  &P0, &Smed, &bestFit, &oiT3m,
                                  &P1, &Det, &nobs, &Smap,
                                  size=, n=, saveFile=, restoreFile=,
                                  gui=, Ps=, info=, saveLimitInText=, useOiVis2=)
/* DOCUMENT oiFitsSearchOiT3ForCompanion(oiTarget, oiWave, oiArray, oiT3, oiVis2, oiLog,
                           size=, n=, saveFile=, restoreFile=,
                           gui=, Ps=, saveLimitInText=)

   DESCRIPTION
    Using the approximation of LeBouquin and Abil, chi2 is defined by:
    chi2 = Sum[  (rho.m - phi)^2 / sigPhi^2   ]
  
    Therefore the chi2 can be writen as a quadratic function:
    chi2 = rho^2.A - 2.rho.B + C
  
    where
    A = Sum[ m^2/sigPhi^2]
    B = Sum[ m*phi/sigPhi^2]
    C = Sum[ phi^2/sigPhi^2]
  
    The coeficients A, B, A3 are of size (x,y). The computation of the large
    cube (x,y,rho) is therefore replaced by the computation of three maps.
  
    For each point in space (x,y), the best fit contrast is given by B/A,
    and the corresponding chi2 value is B^2 - 2*B^2/A + C
  
    The chi2 of purely photospheric model is C.

   PARAMETERS
   - oiTarget, oiWave, oiArray, oiT3, oiLog...
   - size: search region is size-by-size in mas (default 100)
   - n: search region is sampled with n-by-n pixels (detault 512)
   - gui plots
   - saveFile, restoreFile: file name to store/restore the map

   EXAMPLES

   SEE ALSO
 */
{
  local x, y, xy, uv, lbd, m, i, nobs, sig2;
  local nobs, chi2A, chi2B, chi2C, nOiT3;
  local Smap, Sdist, P0;
  yocoLogInfo,"oiFitsSearchOiT3ForCompanion()";

  /* Default */
  if (is_void(n)) n=1024;
  if (is_void(size))  size = 100.0;
  if (is_void(gui) )  gui=0;
  if (is_void(Ps)) Ps = 0.27/100; // 3-sigma detection
  if (is_void(useOiVis2)) useOiVis2=1;
  
  /* Search region is defined as a n-by-n
   of dimension size-by-size mas */
  x = span(-0.5,0.5,n) * size;
  x = x(,-:1:n);
  y = transpose(x);
  xy = [x,y];

  nOiT3   = numberof(oiT3);
  nOiVis2 = numberof(oiVis2);
  nobs    = chi2A = chi2B = chi2C = 0;

  /* Eventually restore existing data instead
     of computing the maps */
  if ( is_array(restoreFile) && yocoTypeIsFile(restoreFile+".bin")) {
    yocoLogInfo,"Restore binary file",restoreFile+".bin";
    restore,openb(restoreFile+".bin"),chi2A,chi2B,chi2C,nobs,x,y,n,size;
    restoreFile=1;
  }
  
  /* Loop on observations */
  for ( i=1 ; i<=nOiT3 * (restoreFile!=1); i++) {
    
    /* Get data */
    oiFitsGetData,oiT3(i),,,phi,phiErr,flag;
    lbd = - oiFitsGetLambda(oiT3(i), oiWave)  * 1e-6 / yocoAstroSI.mas / (2*pi);
    write,format="\r oiT3 %i over %i  (nlbd=%i)",i,nOiT3,numberof(lbd);
    
    /* Remove bad points */
    if( !is_array((id = where(!flag))) ) {
      yocoLogInfo,"no good data, skip";
      continue;
    }
    else { lbd=lbd(id); phi=phi(id); phiErr=phiErr(id);}
  
    /* Compute magnification factor in deg, several normalisation factors
       are already included in lbd (see before) */
    uv = [[oiT3(i).u1Coord,oiT3(i).v1Coord],
          [oiT3(i).u2Coord,oiT3(i).v2Coord],
          [-oiT3(i).u1Coord-oiT3(i).u2Coord,-oiT3(i).v1Coord-oiT3(i).v2Coord]];
  
    uv  = uv / lbd(-,-,);
    uv  = xy(,,+)*uv(+,,);
    // uv  = xy(,,+)*uv(+,);
    // uv  = uv / lbd(-,-,-,);
    
    m   = sin(uv)(,,sum,) * 180.0/pi; // m is in deg
  
    /* Compute the maps A(x,y), B(x,y) and C(x,y) */
    sig2  = phiErr^-2;
    chi2A = chi2A + (m^2*sig2(-,-,))(,,sum);
    chi2B = chi2B + (m*phi(-,-,)*sig2(-,-,))(,,sum);
    chi2C = chi2C + (phi^2*sig2)(sum);
    nobs  = nobs  + numberof(phi);
  }
  write,"";

  /* Loop on observations */
  for ( i=1 ; i<=nOiVis2 * (restoreFile!=1) * useOiVis2; i++) {
    
    /* Get data */
    write,format="\r oiVis2 %i over %i",i,nOiVis2;
    oiFitsGetData,oiVis2(i),v2,v2Err,,,flag;
    lbd = - oiFitsGetLambda(oiVis2(i), oiWave)  * 1e-6 / yocoAstroSI.mas / (2*pi);

    /* Remove bad points */
    if( !is_array((id = where(!flag))) ) {
      yocoLogInfo,"no good data, skip";
      continue;
    }
    else { lbd=lbd(id); v2=v2(id); v2Err=v2Err(id);}

    /* Compute magnification factor, several normalisation factors
       are already included in lbd (see before) */
    uv = [oiVis2(i).uCoord,oiVis2(i).vCoord];
    
    uv  = uv / lbd(-,-,);
    uv  = xy(,,+)*uv(+,,);
    // uv  = xy(,,+)*uv(+);
    // uv  = uv / lbd(-,-,);
    
    m   = 2.*(cos(uv)-1.0); // m is in 'v2'
    
    /* Compute the maps A(x,y), B(x,y) and C(x,y) */
    sig2  = v2Err^-2;
    chi2A = chi2A + (m^2*sig2(-,-,))(,,sum);
    chi2B = chi2B + (m*(v2-1)(-,-,)*sig2(-,-,))(,,sum);
    chi2C = chi2C + ((v2-1)^2*sig2)(sum);
    nobs  = nobs  + numberof(v2);
  }
  write,"";

  /*
    Vm  = 1+r*(cos(uv)-1)
    V2m = 1 + 2r(cos(uv)-1) + ..
    Critere: |r(cos-1)|<<1

    chi2 = (V2 - 1 + 2r(cos(uv)-1) )^2

    chi2 = rho^2.A - 2.rho.B + C
    
    m = 2(cos-1)
    A = Sum[ m^2/sigPhi^2]
    B = Sum[ m*(V2-1)/sigPhi^2]
    C = Sum[ (V2-1)^2/sigPhi^2]
  */
  

  if (nobs>1000) {
    yocoLogWarning,"Too many observation, cannot compute statistics (nobs="+pr1(nobs)+")";
    return 0;
  }

  /* Eventually save */
  if (is_array(saveFile)) {
    yocoLogInfo,"Save binary file",saveFile+".bin";
    remove,saveFile+".bin";
    save,createb(saveFile+".bin"),chi2A,chi2B,chi2C,nobs,x,y,n,size;
  }

  /* Find the chi2 associated to Ps probability
     detection with N-degres of freedom */
  chi2P = span(nobs/10.0,nobs*10,1000);
  Pchi2 = gammq(0.5*nobs, 0.5*chi2P);
  if (Ps<min(Pchi2) || Ps>max(Pchi2)) error,"Check cdfInv";
  chi2cdf = interp(chi2P, Pchi2, Ps);
  
  /* Map of best fit contrast. It consists into finding the
     position and value for extrema of A.rho^2 - 2.B.rho + C */
  rhoBestFit  = min(max(0.0,chi2B/chi2A),0.2);
  chi2BestFit = chi2A*rhoBestFit^2 - 2.*chi2B*rhoBestFit + chi2C;

  /* Best fit position */
  id = chi2BestFit(*)(mnx);
  posBF  = [x(*)(id), y(*)(id) ];
  rhoBF  = rhoBestFit(*)(id);
  chi2BF = chi2BestFit(*)(id);
  bestFit = [chi2BF/nobs,rhoBF,
             abs(posBF(1),posBF(2)),
             atan(posBF(1),posBF(2))/pi*180];
  
  /* Compute fake model */
  yocoLogInfo,"Compute best fit model";
  oiT3m = [oiT3](*);
  for (i=1;i<=numberof(oiT3m);i++) {
    lbd  = - oiFitsGetLambda(oiT3m(i), oiWave)  * 1e-6 / yocoAstroSI.mas / (2*pi);
    uv = [[oiT3(i).u1Coord,oiT3(i).v1Coord],
          [oiT3(i).u2Coord,oiT3(i).v2Coord],
          [-oiT3(i).u1Coord-oiT3(i).u2Coord,-oiT3(i).v1Coord-oiT3(i).v2Coord]];
    uv  = posBF(+)*uv(+,) / lbd(-,);
    phi = rhoBF * sin(uv)(sum,) * 180.0/pi;
    oiFitsSetStructDataScalar, oiT3m, i, "t3Phi", phi;
    oiFitsSetStructDataScalar, oiT3m, i, "t3PhiErr", phi*0.0;
  }

  oiVis2m = [oiVis2](*);
  for (i=1;i<=numberof(oiVis2m);i++) {
    lbd  = - oiFitsGetLambda(oiVis2m(i), oiWave)  * 1e-6 / yocoAstroSI.mas / (2*pi);
    uv = [oiVis2m(i).uCoord,oiVis2m(i).vCoord];
    uv  = posBF(+)*uv(+) / lbd;
    vis2 = abs( (1.+rhoBF*exp( 1.i * uv ))/(1.+rhoBF) )^2;
    oiFitsSetStructDataScalar, oiVis2m, i, "vis2Data", vis2;
    oiFitsSetStructDataScalar, oiVis2m, i, "vis2Err", vis2*0.0;
  }

  /* Compute P0 (Sec 3.2) */
  yocoLogInfo,"Compute probabilities";
  chi2det  = (nobs * chi2C) / chi2cdf;
  chi2norm = (nobs * chi2C) / max(chi2BF,nobs);
  P0 = gammq(0.5*nobs, 0.5 * chi2norm);
  P1 = gammq(0.5*nobs, 0.5 * chi2det);
  yocoLogInfo,"Probability of single (raw chi2): "+pr1(P1*100)+"%";
  yocoLogInfo,"Probability of single (norm. chi2): "+pr1(P0*100)+"%";

  /* Compute sensitivity map Smap, as the value for which
     the modified chi2 (Sec 3.3) equal the required chi2
     for 3-sigma detection.
     It consist into solving the equation:
     A.rho^2 - 2.B.rho + C = chi2ref
     where chi2ref is the (renomalized) chi2 that
     gives the threshold probability (0.27%) */
  chi2ref = chi2cdf* chi2C/nobs;
  Smap = ( chi2B + sqrt(chi2B^2-chi2A*(chi2C-chi2ref)) ) / chi2A;
  Smap = min(max(0.0,Smap),0.2) + 1e-10*random(dimsof(Smap));
  Smed = median(Smap(*));
  yocoLogInfo,"Median sensitivity: "+pr1(Smed*100)+"%";

  
  /* Compute the annular sensitivity (quick and durty)
     Compute the median and 80% completness */
  d = abs(x,y);
  s = sort(d(*));
  sdis = Smap(*)(s);
  dist = d(*)(s);
  Dist = spanl(0.01,1,25)*size/2;
  for (Sdis=[],i=1;i<=numberof(Dist);i++) {
    id = where(dist>=grow(0.0,Dist)(i) & dist<Dist(i));
    tmp = sdis(id);
    tmp = tmp(sort(tmp));
    grow,Sdis,[tmp(int(numberof(tmp)*[0.5,0.8]))];
  }

  /* Compute the completeness of the entire FOV */
  Det0 = Smap(sort(Smap(*)));
  Det  = Det0(int(numberof(Det0)*[0.5,0.8]));
  DetI = interp(span(0,1,numberof(Smap)), Smap(*)(sort(Smap(*))), span(0,0.2,100));

  if (is_array(saveFile)) {
    yocoLogInfo,"Update binary file";
    save,updateb(saveFile+".bin"),Smap, Det0, DetI, bestFit, P0, P1, nobs, Sdis, Dist;
  }

  if (is_array(saveLimitInText)) {
    f = create(saveLimitInText);
    write, f, "# D (mas)\tf_50\%     \tf_80\%";
    write, f, format="%f\t%f\t%f\n",Dist,Sdis(1,),Sdis(2,);
    close,f;
  }
  
  /* Plot results */
  winkill,gui;
  // yocoNmCreate,gui,2,3,square=1,dy=0.07,dx=0.11;
  yocoNmCreate,gui,2,3,square=1,dy=0.07,dx=0.11, V=[0.,0.85,0.06,1.02];
  /* Plot map */
  plsys,3;
  pli, chi2BestFit,-size/2,-size/2,size/2,size/2;
  plc, chi2BestFit, y, x, levs=chi2det, color="red", width=3;
  limits,size/2,-size/2; gridxy,2;
  xytitles,"<- East (mas)","North (mas) ->",[0,0.018];

  /* Plot sensitivity vs radius */
  plsys,4;
  yocoPlotPlgMulti,transpose(Sdis),Dist,type=[1,2];
  yocoPlotHorizLine,Smed,color="red";
  plt,swrite(format="%.2f%%",Smed*100),1,Smed,tosys=2,justify="LB",height=10,color="red";
  logxy,1,0; limits,.7,,0,max(0.05,Smed*2);
  xytitles,"separation (mas)","contrast (%)",[0,0.018];

  /* Plot UV */
  oiFitsPlotUV, oiVis2, oiWave, unit="mum", tosys=1, size=0.25;
  limits,80,-80,square=1; gridxy,2;
  r = exp(2.i*pi*span(0,1,100)) * [20,40,60,80,100](-,);
  yocoPlotPlgMulti,r.im,r.re,type=3;
  xytitles,"<- East (m/!mm)","North (m/!mm) ->",[0,0.018];

  /* Plot best fit */
  oiFitsPlotOiData, oiT3,  oiWave, "base", symbol=4, size=0.5, tosys=6;
  oiFitsPlotOiData, oiT3m, oiWave, "base", symbol=6, size=0.75, tosys=6, color="red";
  gridxy,0,2;  l = limits(); limits,l(1)-1,l(2)+1;
  xytitles,"baselength (m/!mm)","t3phi (deg)",[0,0.018];

  /* Plot Vis2 */
  oiFitsPlotOiData, oiVis2,  oiWave, "base", symbol=4, size=0.5, tosys=5;
  oiFitsPlotOiData, oiVis2m, oiWave, "base", symbol=6, size=0.75, tosys=5, color="red";
  gridxy,0,2;  l = limits(); limits,l(1)-1,l(2)+1,0,1.2;
  xytitles,"baselength (m/!mm)","vis2",[0,0.018];

  plt, swrite(format="X2single=%.2f\nP1 = %.3g%%    P0= %.3g%% \n\n",
              chi2C/nobs, P1*100, P0*100) + 
    swrite(format="X2bin=%.2f\n  %.2f%% (%.2f,%.2f)mas \n\n",
           chi2BF/nobs,rhoBF*100,posBF(1),posBF(2)) + string(info),
    0.44, 0.99, tosys=0, justify="LT";

  yocoLogInfo,"oiFitsSearchOiT3ForCompanion done";
  return 1;
}

/* ----------------------------------------------------------------------
   Instrument-related function: here AMBER functions,
   which serves as default
   ---------------------------------------------------------------------- */

/* Correspondency table for ESO header -> oiLog */
local table_oiLogAmberName;
table_oiLogAmberName = 
  [["orgFileName",     "ORIGFILE",""],
   ["dit",             "HIERARCH ESO DET DIT",""],
   ["ndit",            "HIERARCH ESO DET NDIT",""],
   ["nditSkip",        "HIERARCH ESO DET NDITSKIP",""],
   ["nrow",            "HIERARCH ESO DET NROW",""],
   ["insMode",         "HIERARCH ESO INS MODE",""],
   ["objName",         "HIERARCH ESO OBS TARG NAME",""],
   ["obsName",         "HIERARCH ESO OBS NAME",""],
   ["tplNo",           "HIERARCH ESO OBS TPLNO",""],
   ["ObsId",           "HIERARCH ESO OBS ID",""],
   ["p2vmId",          "HIERARCH ESO OCS P2VM ID",""],
   ["dprType",         "HIERARCH ESO DPR TYPE",""],
   ["dprCatg",         "HIERARCH ESO DPR CATG",""],
   ["proCatg",         "HIERARCH ESO PRO CATG",""],
   ["ftSensor",        "HIERARCH ESO DEL FT SENSOR",""],
   ["delFntPhaRmsCh1", "HIERARCH ESO DEL FNT PHA_RMS_CH1",""],
   ["delFntPhaRmsCh2", "HIERARCH ESO DEL FNT PHA_RMS_CH2",""],
   ["delFntLockCh1",   "HIERARCH ESO DEL FNT LOCKR_CH1",""],
   ["delFntLockCh2",   "HIERARCH ESO DEL FNT LOCKR_CH2",""],
   ["opdcAlgoType",    "HIERARCH ESO ISS OPDC ALGOTYPE",""],
   ["issFntDitCh1",    "HIERARCH ESO ISS FNT DIT_CH1",""],
   ["issFntDitCh2",    "HIERARCH ESO ISS FNT DIT_CH2",""],
   ["parangStart",     "HIERARCH ESO ISS PARANG START",""],
   ["parangEnd",       "HIERARCH ESO ISS PARANG END",""],
   ["airmassStart",    "HIERARCH ESO ISS AIRM START",""],
   ["airmassEnd",      "HIERARCH ESO ISS AIRM END",""],
   ["alt",             "HIERARCH ESO ISS ALT",""],
   ["az",              "HIERARCH ESO ISS AZ",""],
   ["dateObs", "DATE-OBS",""],
   ["issStation1","HIERARCH ESO ISS CONF STATION1",""],
   ["issStation2","HIERARCH ESO ISS CONF STATION2",""],
   ["issStation3","HIERARCH ESO ISS CONF STATION3",""]];

func oiFitsAmberReadLog(file)
/* DOCUMENT oiLog = oiFitsAmberReadLog(file)

   DESCRIPTION
   Read the first header of the AMBER FITS file
   and extract several information, stored into
   the oiLog structure.

   This is mainly to be used with the oiFitsLoadFile
   function.

   PARAMETERS
   - file: file-name
   - oiLog: filled oiLog structure.
 */
{
  local fh;
  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file) : file );
  /* Read the first header */
  cfitsio_goto_hdu,fh,1;
  oiLog = oiFitsLoadOiHdr(fh, struct_oiLog, table_oiLogAmberName);
  /* Do the "filename" manually */
  oiLog.fileName = cfitsio_file_name(fh);
  /* Close file and return the log */
  if( structof(file)==string ) cfitsio_close,fh;
  return oiLog;
}

/* --- */

func oiFitsAmberWriteLog(file,oiLog)
/* DOCUMENT oiFitsAmberWriteLog(file,oiLog)

   DESCRIPTION
   See "oiFitsAmberReadLog" and "oiFitsDefaultReadLog"
 */
{
  local fh;
  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file,"a") : file );
  /* Write the data */ 
  cfitsio_goto_hdu,fh,1;
  oiFitsWriteOiHdr, fh, oiLog, table_oiLogAmberName;
  /* eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;
  return 1;
}

/* --- */

func oiFitsAmberSetup(oiData, oiLog)
/* DOCUMENT oiFitsAmberSetup(oiData, oiLog)

   DESCRIPTION
   Return the AMBER setup used of the observation.
   A setup is defined so that it is 'calibratable', so for AMBER:
   - if oiData is oiVis2, the function returns:
     "oiData.insName +  oiLog.dit + oiLog.ndit + oiLog.ftSensor + oiLog.issFntDitCh1"
   - if oiData is oiT3:
     "oiData.insName"

   PARAMETERS
   - oiData, oiLog
   
   EXAMPLES
   // List all setup used for oiVis2
   > setup = oiFitsAmberSetup(oiVis2, oiLog);
 */
{
  local setup,dit,log;

  /* Check inputs */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if( !oiFitsIsOiLog(oiLog) )   return yocoError("oiLog not valid");

  /* Recover the log */
  log = oiFitsGetOiLog(oiData,oiLog);

  if ( oiFitsIsOiVis2(oiData) ) {
    /* case oiVis2: */
    /* TRICK: put the dit close the 25ms at 25ms exactly */
    dit = int( log.dit * 1000.0 );
    dit += ( dit==24 );
    dit -= ( dit==26 );
    dit += ( dit==49 );
    dit -= ( dit==51 );
    setup = swrite(format="%s - %ix%i - %s - %.1f",oiData.hdr.insName,
                   dit, log.ndit, log.ftSensor+log.opdcAlgoType,
                   log.issFntDitCh1*1000.0);
  } else if ( oiFitsIsOiT3(oiData) || oiFitsIsOiVis(oiData) ) {
    /* case oiT3: */
    setup = swrite(format="%s",oiData.hdr.insName);
  } else {
    /* case unknown: */
    return yocoError("No setup defined for this oiData");
  }

  /* return the string */
  return setup;
}

/* --- */

func oiFitsAmberSetupNoNDIT(oiData, oiLog)
/* DOCUMENT oiFitsAmberSetupNoNDIT(oiData, oiLog)

   DESCRIPTION
   Return the AMBER setup used of the observation.
   A setup is defined so that it is 'calibratable', so for AMBER:
   - if oiData is oiVis2, the function returns:
     "oiData.insName +  oiLog.dit + oiLog.ndit + oiLog.ftSensor"
   - if oiData is oiT3:
     "oiData.insName"

   PARAMETERS
   - oiData, oiLog
   
   EXAMPLES
   // List all setup used for oiVis2
   > setup = oiFitsAmberSetup(oiVis2, oiLog);
 */
{
  local setup,dit,log;

  /* Check inputs */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if( !oiFitsIsOiLog(oiLog) )   return yocoError("oiLog not valid");

  /* Recover the log */
  log = oiFitsGetOiLog(oiData,oiLog);

  if ( oiFitsIsOiVis2(oiData) ) {
    /* case oiVis2: */
    /* TRICK: put the dit close the 25ms at 25ms exactly */
    dit = int( log.dit * 1000.0 );
    dit += ( dit==24 );
    dit -= ( dit==26 );
    setup = swrite(format="%s - %ix - %s - %.1f",oiData.hdr.insName,
                   dit, log.ftSensor,
                   log.issFntDitCh1*1000.0);
  } else if ( oiFitsIsOiT3(oiData) || oiFitsIsOiVis(oiData) ) {
    /* case oiT3: */
    setup = swrite(format="%s",oiData.hdr.insName);
  } else {
    /* case unknown: */
    return yocoError("No setup defined for this oiData");
  }

  /* return the string */
  return setup;
}

/* --- */

func oiFitsAmberSetupNoDIT(oiData, oiLog)
/* DOCUMENT oiFitsAmberSetupNoDIT(oiData, oiLog)

   DESCRIPTION
   Alternative function to compute the setup of AMBER.
   Return the AMBER setup used of the observation.
   A setup is defined so that it is 'calibratable', so for AMBER:
   - the function returns:
     "oiData.insName +  oiLog.dit + oiLog.ndit + oiLog.ftSensor"
 */
{
  local setup,dit,log;

  /* Check inputs */
  if( !oiFitsIsOiData(oiData) ) return yocoError("oiData not valid");
  if( !oiFitsIsOiLog(oiLog) )   return yocoError("oiLog not valid");

  /* Recover the log */
  log = oiFitsGetOiLog(oiData,oiLog);

  /* TRICK: put the dit close the 25ms at 25ms exactly */
  dit = int( log.dit * 1000.0 );
  dit += ( dit==24 );
  dit -= ( dit==26 );
  setup = swrite(format="%s",oiData.hdr.insName);

  /* return the string */
  return setup;
}

/* ------------------------------------------------------
   Default for instrument-specific functions.
   This may be overwriten when including an additional
   yorick-file, for another instrument for instance.
   ------------------------------------------------------ */

local oiFitsDefaultReadLog, oiFitsDefaultWriteLog, oiFitsDefaultSetup;
/* DOCUMENT oiFitsDefaultReadLog
            oiFitsDefaultWriteLog
            oiFitsDefaultSetup
            ... other instrument-related functions
    
   DESCRIPTION
   
   - oiLog = oiFitsDefaultReadLog(filename):
     is called by "oiFitsLoadFiles" to fill the oiLog structure,
     since oiLog contains non-standart and instrument-specific
     informations. See oiFitsAmberReadLog for example.

   - oiFitsDefaultWriteLog, filename, oiLog;
     is called by "oiFitsWriteFile" to write the oiLog structure.

   - setupString = oiFitsDefaultSetup(oiData, oiLog):
     is called each time the instrumental-setup is required. A setup
     is defined as a "homogenous" set of observation, that are
     calibratable (same spectral config, same dit...). The setup
     rules can depend on the oiData type of data (oiVis2, oiT3).
     It should not contain the baseline (will be added anyway).
     See oiFitsAmberSetup for example.

   DEFAULT
   When including "oiFitsUtils.i", these functions are set to the
   AMBER functions: oiFitsAmvberReadLog, oiFitsAmberWriteLog
   and oiFitsAmberSetup. Yet, they can be overwriten at any time
   by other instrument-related functions (assuming these functions
   uses the same syntax).
 */
oiFitsDefaultReadLog  = oiFitsAmberReadLog;
oiFitsDefaultWriteLog = oiFitsAmberWriteLog;
oiFitsDefaultSetup    = oiFitsAmberSetup;
  
