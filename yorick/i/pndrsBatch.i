/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsBatch(void)
/* DOCUMENT pndrsBatch(void)

   FUNCTIONS:
   - pndrsComputeAllMatrix
   - pndrsComputeAllSpecCal
   - pndrsComputeAllOiData
   - pndrsCalibrateAllOiData
   - pndrsComputeAllUnstablePixelMap

   - pndrsCheckSingleDark
   - pndrsComputeSingleOiData
   - pndrsComputeSingleMatrix
   - pndrsComputeSingleSpecCal
   - pndrsComputeSingleUnstablePixelMap

   - pndrsSummaryAllOiData
   - pndrsCheckAllObject
   - pndrsRemoveAllInspection
   - pndrsRenameAllRawData

   - pndrsBatchFindBestDark
   - pndrsBatchFindBestMatrix
   - pndrsBatchFindBestSpecCal

   - pndrsBatchMakeSilentGraphics
   - pndrsBatchProductDir
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.67 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsBatch;
        
    }   
    return version;
}


/* ************************************************************ */

func pndrsBatchGetMd5(file)
{
    md5 = yocoStrSplit(rdline(popen("md5sum "+file,0))," ")(1);
    // yocoLogInfo,"md5sum of "+file+" = "+md5;
    return md5;
}

func pndrsBatchCreateDir(dir)
{
  yocoLogTrace,"pndrsBatchCreateDir()";
  
  /* Otherwise build it */
  if (catch(-1)) {
    return 0;
  }
  mkdirp,dir;
  
  yocoLogTrace,"pndrsBatchCreateDir done";
  return 1;
}

func pndrsBatchTime(void)
{
  return yocoAstroESOStampToJulianDay (rdline(popen("date -u +%FT%T",0)),modified=1);
}

func __pndrsBatchWinKillNormal(i) { window,i,hcp="",display=""; }

func __pndrsBatchWinKillBatch(i) { window,i,hcp="",display="";  window,i,display="",hcp=pr1(i); }

func pndrsBatchMakeSilentGraphics(on)
/* DOCUMENT pndrsBatchMakeSilentGraphics, 0/1/2

   DESCRIPTION
   0: nothing
   1: pdf only (nothing display on the screen)
   2: plots and pdf

   Actually this function re-define the "winkill" yorick function.
*/
{
  yocoLogTrace,"pndrsBatchMakeSilentGraphics()";
  extern winkill, pndrsBatchPlotLevel;
  
  if (on==0) {
    pndrsBatchPlotLevel = 0;
    winkill = __pndrsBatchWinKillBatch;
    yocoLogInfo,"No plot at all";
  } else if (on==1) {
    winkill = __pndrsBatchWinKillBatch;
    pndrsBatchPlotLevel = 1;
    yocoLogInfo,"Graphical outputs in batch mode (PDF only)";
  } else {
    winkill = __pndrsBatchWinKillNormal;
    pndrsBatchPlotLevel = 2;
    yocoLogInfo,"Graphical outputs in normal mode (display and PDF)";
  }

  yocoGuiWinKill;
  yocoLogTrace,"pndrsBatchMakeSilentGraphics done";
  return 1;
}

/* ************************************************************ */
func pndrsBatchProductDir(inputDir, &productDir, app=, create=)
{
  yocoLogTrace,"pndrsBatchProductDir()";
   local here, vx;
   extern pndrsVersion;
   extern pndrsDefaultRootOutput;

   /* Go to the directory to get his real name ,
      then go back. Leave trace for test */
   here = get_cwd(".");
   inputDirReal = cd(inputDir);
   cd, here;

   /* possible root directories */
   possibleDirs = grow(pndrsDefaultRootOutput,
                       inputDirReal+"/../",
                       get_home());
   for ( i=1 ; i<=numberof(possibleDirs) ; i++) {
     productRoot = possibleDirs(i);
     if (pndrsBatchCreateDir(productRoot)) break;
   }

   /* check if pndrs version already in */
   v = "_v"+pndrsVersion;
   v = ( strmatch(inputDirReal,v) ? "" : v );

   /* check app */
   app = ( yocoTypeIsStringScalar(app) ? "_"+app : "" );

   /* compute the directory name */
   productDir = productRoot + "/" + yocoStrrtok(inputDirReal, "/")(2) + v + app + "/";

   if (create) pndrsBatchCreateDir(productDir);
     
   yocoLogTrace, "Constructed productDir name:", productDir;
   yocoLogTrace,"pndrsBatchProductDir done";
   return 1;
}


func pndrsBatchProductDirOld(inputDir, &productDir, app=, up=)
/* DOCUMENT pndrsBatchProductDir(inputDir, &productDir, app=, up=)

   DESCRIPTION
   Get the product directory, as:
   up=0: inputDir/inputDir_version_app/
   up=1: inputDir/../inputDir_version_app/
   up=2: inputDir/../../inputDir_version_app/

   where "app" is the (optional) extension you want to append,
   and "version" is the version number of pndrs.

   EXAMPLES
   pndrsBatchProductDir,".", productDir, up=0;
   ./src_pndrs_v0.1/
   pndrsBatchProductDir,".", productDir, app="test", up=1;
   ./../src_pndrs_v0.1_test/

   SEE ALSO
 */
{
    local here, vx;
    extern pndrsVersion;
    extern pndrsDefaultRootOutput;
    if(is_void(up))  up = 1;
    
    /* Go to the directory to get his real name ,
       then go back. Leave trace for test */
    here = get_cwd(".");
    inputDirReal = cd(inputDir);
    cd, here;
      
    /* check if pndrs version already in */
    v = "_v"+pndrsVersion;
    v = ( strmatch(inputDirReal,v) ? "" : v );

    /* check app */
    app = ( yocoTypeIsStringScalar(app) ? "_"+app : "" );

    /* compute the directory name */
    productDir = yocoStrrtok(inputDirReal, "/")(2) + v + app + "/";
  
    /* If the external variable is set, then we use it */
    if ( !is_void(pndrsDefaultRootOutput) ) {
       productDir = pndrsDefaultRootOutput + "/" + productDir;
    } else if ( up==0 ) {
      productDir = inputDir + "/" + productDir;
    } else if ( up==1 ) {
      productDir = inputDir + "/../" + productDir;
    } else if ( up==2 ) {
      productDir = inputDir + "/../../" + productDir;
    }

    yocoLogTrace, "Constructed productDir name:", productDir;
    return 1;
}

/* ************************************************************ */

func pndrsBatchFindObject(imgData, imgLog, &sciData, scalar=, required=)
{
  yocoLogTrace,"pndrsBatchFindObject()";
  local id;
  if (is_void(required)) required="1111";

  /* Look for the sciences */
  id = where( pndrsGetShutters(imgData,imgLog) == required );

  /* If user want a single observation */
  if (scalar) {
    if ( numberof(id)!=1 ) {
      yocoError,"Should contain a single obs with shutters: "+required;
      return 0;
    }
    id = id(1);
  }

  /* Get the observation */
  sciData = imgData(id);
  
  yocoLogTrace,"pndrsBatchFindObject done";
  return 1;
}

/* *********************************************************** */

func pndrsBatchFindBestMatrix(sciLog, allLog, &idm)
/* DOCUMENT pndrsBatchFindBestMatrix(sciLog, allLog, &idm)

   DESCRIPTION
   Find the best matrix file (KAPPA_MATRIX) in allLog
   for the science file sciLog.

   PARAMETERS
   - allLog: array of oiLog
   - sciLog: should be a scalar oiLog
 */
{
  yocoLogTrace,"pndrsBatchFindBestMatrix()";
  idm = [];

  if ( numberof(sciLog)>1 ) { error,"accept only scalars"; }
  sciLog=sciLog(1);

  /* Look for compatible spectral calib */
  setupRef = pndrsGetSetupMatrix(,sciLog);
  setupAll = pndrsGetSetupMatrix(,allLog);

  idm = where( setupAll == setupRef &
               allLog.proCatg=="KAPPA_MATRIX" &
               allLog.qcQualityFlag==0);
  
  if ( !is_array(idm) ) { idm=[]; return 0; }

  /* Favor the same OBS.ID if any */
  idp = where(allLog(idm).progId == sciLog.progId);
  if ( is_array(idp) ) idm = idm(idp);

  /* Select the closest one in time */
  mjdRef = yocoAstroESOStampToJulianDay(sciLog.dateObs,modified=1);
  mjdAll = yocoAstroESOStampToJulianDay(allLog.dateObs,modified=1);
  idm = idm( abs(mjdAll(idm)-mjdRef)(mnx) );
  
  yocoLogTrace,"pndrsBatchFindBestMatrix done";
  return 1;
}

/* *********************************************************** */

func pndrsBatchFindBestSpecCal(sciLog, allLog, &idm)
/* DOCUMENT pndrsBatchFindBestSpecCal(sciLog, allLog, &idm)

   DESCRIPTION
   Find the best spectral calibration file (PRO.CATG==SPECTRAL_CALIBRATION)
   in allLog for the science file sciLog.

   PARAMETERS
   - allLog: array of oiLog
   - sciLog: should be a scalar oiLog
 */
{
  yocoLogTrace,"pndrsBatchFindBestSpecCal()";
  idm = [];

  if ( numberof(sciLog)>1 ) { error,"accept only scalars"; }
  sciLog=sciLog(1);

  /* Look for compatible spectral calib */
  setupRef = pndrsGetSetupSpectralCalib(,sciLog);
  setupAll = pndrsGetSetupSpectralCalib(,allLog);
  idm = where( setupAll == setupRef &
               allLog.proCatg=="SPECTRAL_CALIBRATION" &
               allLog.qcQualityFlag==0 );

  if ( !is_array(idm) ) {idm = []; return 0;}

  mjdRef = yocoAstroESOStampToJulianDay(sciLog.dateObs,modified=1);
  mjdAll = yocoAstroESOStampToJulianDay(allLog.dateObs,modified=1);

  /* Select the closest one in time, with preference for
     one taken before (if any) */
  delta = abs(mjdAll(idm)-mjdRef) + 1.0*sign(mjdAll(idm)-mjdRef);
  idm = idm( delta(mnx) );
  
  yocoLogTrace,"pndrsBatchFindBestSpecCal done";
  return 1;
}

/* ********************************************************************* */

func pndrsBatchFindBestDark(sciLog, allLog, &ids)
/* DOCUMENT pndrsBatchFindBestDark(sciLog, allLog, &ids)

   DESCRIPTION
   Find the best calibration dark (0000)
   for the science observation (1111). Dark is chosen:
   - same setup as returned by pnrsGetSetupDark
   - shutter sequence
   - minimal time difference

   PARAMETERS
   - sciLog: log of the science observation (should be scalar)
   - allLog: all logs to be ocnsidered.
   - ids: position of the best dark file in allLog
 */
{
  local setupRef, setups, required, i, id;
  yocoLogTrace,"pndrsBatchFindBestDark()";
  ids = [];

  if ( numberof(sciLog)>1 ) { error,"accept only scalars"; }
  sciLog=sciLog(1);

  /* Setup for the reference */
  setupRef = pndrsGetSetupDark(,sciLog);
  setupAll = pndrsGetSetupDark(,allLog);
  shutters = pndrsGetShutters(,allLog);

  /* Find the possible dark file */
  id = where( shutters=="0000" & setupRef==setupAll );

  /* If not existing */
  if ( numberof(id)<1 ) { id =[]; return 0; }

  /* Take the closest */
  mjdRef = yocoAstroESOStampToJulianDay(sciLog.dateObs,modified=1);
  mjdAll = yocoAstroESOStampToJulianDay(allLog.dateObs,modified=1);
  ids = id(  abs(mjdRef-mjdAll(id))(mnx)  );

  yocoLogTrace,"pndrsBatchFindBestDark done";
  return 1;
}

/* *********************************************************** */

func pndrsGetCkSum(inputScriptFile)
{
  return strtok( rdline(popen("cksum "+inputScriptFile,0),1)(1), " ", 3)(1);  
}
  
/* *********************************************************** */

func pndrsGetFileWithExt(file, &d)
{
  local d,f,e;
  yocoFileSplitName, file, d,f,e;
  return f+e;
}

func pndrsIsCompress(file)
{
  return (strpart(file,-1:0)==".Z") |
    (strpart(file,-2:0)==".gz");
}


/* *********************************************************** */

func pndrsCheckSingleDark(&dark,
                          inputDarkFile=,
                          outputDarkFile=,
                          outputFile=)
/* DOCUMENT pndrsCheckSingleDark(&dark,
                          inputDarkFile=,
                          outputDarkFile=)

   DESCRIPTION
   Check the DARK and copy it as a product to allow it uses for various
   fringes and kappa files.
   
   PARAMETERS
   - inputDarkFile=
   - outputFile=

   SEE ALSO pndrsCheckAllDark -- TBD if needed
 */
{
  yocoLogInfo,"pndrsCheckSingleDark()";
  pndrsPdfCounter = 0;

  /* Check default outputs files */
  if ( is_void(outputFile) ) outputFile="outputFile";
  if ( is_void(outputDarkFile) ) outputDarkFile=outputFile+"_dark.fits"

  /* Check the input files */
  if ( !pndrsCheckFile(inputDarkFile,2,[1],"inputDarkFile") ) {
    return 0;
  }

  /* Init the plots and the browser */
  yocoGuiWinKill;

  /* Read and process data */
  darkLog = dark = darkData = sig2dark = [];
  if( !pndrsReadRawFiles(inputDarkFile, darkData, darkLog) ) return 0;
  if( !pndrsCheckOiLog(darkLog) ) return 0;
  if( !pndrsProcessDetector(darkData, darkLog) ) return 0;
  if( !pndrsReformData(darkData, darkLog) ) return 0;
  if( !pndrsProcessOversampling(darkData, darkLog) ) return 0;
  
  /* Make a summary of the average flux in scan position */
  pndrsPlotRaw,1, darkData(1), darkLog, color=, lbd=avg, scan=avg, which=::1, legend="Average value of dark";
  pndrsSavePdf,1,outputFile,"darkScanAvg.pdf";
  
  /* Compute the dark, and thus the QC parameters */
  if( !pndrsComputeDark(darkData, darkLog, dark, sig2dark) ) return 0;
  
  /* Copy the dark as a calibration product */
  yocoLogInfo,"Write the DARK_CALIBRATION into FITS file:", outputDarkFile;
  remove,outputDarkFile;
  if ( pndrsIsCompress(inputDarkFile) )
    system,"gunzip -c "+inputDarkFile+" > "+outputDarkFile;
  else
    system,"cp -rf "+inputDarkFile+" "+outputDarkFile;

  /* Add the log (and thus the QC parameters) */
  fh = cfitsio_open(outputDarkFile,"a");
  pndrsWritePnrLog, fh, darkLog;
  cfitsio_close,fh;

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+outputFile+"_* "+outputDarkFile+" > /dev/null 2>&1";
  
  /* Add the workflow parameters */
  fh = cfitsio_open(outputDarkFile,"a");
  cfitsio_goto_hdu, fh,1;
  cfitsio_set,fh,"HIERARCH ESO OCS DRS VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO OCS DRS NAME","pndrs","DRS for PIONIER";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 ID","pndrsCheckSingleDark";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW1 NAME",pndrsGetFileWithExt(inputDarkFile);
  cfitsio_set,fh,"HIERARCH ESO PRO CATG ","DARK_CALIBRATION";
  cfitsio_close,fh;
  
  yocoLogTrace,"pndrsCheckSingleDark done";
  return 1;
}

/* *********************************************************** */

func pndrsComputeSingleMatrix(&matrix, &matLog,
                              inputMatrixFiles=,
                              inputDarkFile=,
                              outputFile=,
                              outputMatrixFile=)
/* DOCUMENT pndrsComputeSingleMatrix(&matrix, inputMatrixFiles=, inputDarkFile=,
                              outputFile=,outputMatrixFile=)

   DESCRIPTION
   Compute a single matrix file from the raw DARK and the four raw KAPPA.

   PARAMETERS
   - inputMatrixFiles (4 files)
   - inputDarkFile (1 file)
   - outputFile
   - outputMatrixFile

   SEE ALSO pndrsComputeAllMatrix
 */
{
  yocoLogInfo,"pndrsComputeSingleMatrix()";
  pndrsPdfCounter = 0;

  /* Check default outputs files */
  if ( is_void(outputFile) ) outputFile="outputFile";
  if ( is_void(outputMatrixFile) ) outputMatrixFile=outputFile+"_kappaMatrix.fits"

  /* Check the input files */
  if ( !pndrsCheckFile(inputMatrixFiles,2,[4],"inputMatrixFiles") ||
       !pndrsCheckFile(inputDarkFile,2,[1],"inputDarkFile") ) {
    return 0;
  }

  /* Init the plots and the browser */
  yocoGuiWinKill;
    
  /* Put all files together, put the DARK
     at the end to avoid having its header */
  inputMatrixFiles = grow(inputMatrixFiles, inputDarkFile);

  matrixRaw = matrix = matData = matLog = dark = [];
  sig2matrix = sig2matrixRaw = [];
  if( !pndrsReadRawFiles(inputMatrixFiles, matData, matLog) ) return 0;
  if( !pndrsCheckOiLog(matLog) ) return 0;
  if( !pndrsProcessDetector(matData, matLog) ) return 0;
  if( !pndrsReformData(matData, matLog) ) return 0;
  if( !pndrsProcessOversampling(matData, matLog) ) return 0;

  /* Plot RAW PSD for testing the telescope injection */
  for (i=1;i<=5;i++) {
    pndrsPlotPsdOfPixels, 1, matData(i), matLog;
    pndrsSavePdf, 1, outputFile,"pixelPsd.pdf";
  }

  /* Make a summary of the average flux in scan position */
  pndrsPlotRaw, 1, matData(1), matLog, color=, lbd=avg, scan=avg, legend="Average value of data and dark (all chanels collapsed)";
  pndrsPlotRaw, 1, matData(2), matLog, color=, lbd=avg, scan=avg, kill=0;
  pndrsPlotRaw, 1, matData(3), matLog, color=, lbd=avg, scan=avg, kill=0;
  pndrsPlotRaw, 1, matData(4), matLog, color=, lbd=avg, scan=avg, kill=0;
  pndrsPlotRaw, 1, matData(5), matLog, color="red", lbd=avg, scan=avg, kill=0, allLimits=1;
  pndrsSavePdf, 1, outputFile,"kappaMatrixScanAvg.pdf";

  /* Remove the dark */
  if( !pndrsComputeDark(matData, matLog, dark) ) return 0;
  if( !pndrsRemoveDark(matData, matLog, dark) ) return 0;

  /* Build custom graphic */
  yocoLogInfo,"Plot the graphic...";
  winkill,0;
  yocoNmCreate,0,2,4,dx=0.06,dy=0.06,fx=1,fy=1;
  for (i=1;i<=4;i++) {
    pndrsGetData, matData(i), matLog, data, opd, map, oLog, time;
    df = 1./(time(0,1) - time(1,1));
    data = data(avg,,,avg);
    yocoPlotPlgMulti, data(,1:3)(*), tosys=(i*2)-1;
    ft = power( fft(data,[1,0]) )(,avg);
    nopd = numberof(ft);
    yocoPlotPlgMulti, ft(5:nopd/2), indgen(5:nopd/2)*df, tosys=(i*2);
    logxy,0,1;
  }
  main   = swrite(format="%s - %.4f", oLog.target, (*matData(1).time)(*)(avg));
  titles = pndrsGetLogInfo(oLog,"issStation%i",[1,2,3,4]) + " / " +
    pndrsGetLogInfo(oLog,"issTelName%i",[1,2,3,4]);
  titles = transpose( [titles,titles] )(*);
  pndrsPlotAddTitles, titles, main, "Flux (left, 3 scans) and PSD (right), all pixels average", ["OPD step","Frequencies [Hz]"];
  pndrsSavePdf, 0, outputFile,"injectionTimePsd.pdf";

  /* Make a summary of the average flux in scan position */
  pndrsPlotRaw, 1, matData(1), matLog, lbd=avg, scan=1:3, color=-5, legend="data-dark for 3 scans (all channels collapsed)";
  pndrsPlotRaw, 1, matData(2), matLog, lbd=avg, scan=1:3, color=-6, kill=0;
  pndrsPlotRaw, 1, matData(3), matLog, lbd=avg, scan=1:3, color=-7, kill=0;
  pndrsPlotRaw, 1, matData(4), matLog, lbd=avg, scan=1:3, color=-8, kill=0, allLimits=1;
  pndrsSavePdf, 1, outputFile,"kappaMatrixScan.pdf";

  /* Compute the matrix */
  status = pndrsComputeMatrix(matData, matLog, matrix, sig2matrix, matrixRaw, sig2matrixRaw, gui=1);

  /* Save raw plot */
  pndrsSavePdf,2,outputFile,"kappaMatrixRaw.pdf";

  /* Escape if failure */
  if (status==0) return 0;
  
  /* Save plots */
  pndrsSavePdf,1,outputFile,"kappaMatrix.pdf";

  /* The log is the one of the first file */
  matLog = matLog(1);

  /* QC parameters:
     FLUX_Ti: flux of beam i sum over channels and outputs
     = matrixRaw(sum,1,1,sum,i)

     For the following computation, I should keep only the theoreticals
     outputs, not the zero ones.
     
     KAPPA_Ti_Cj_MIN beam i, channel j, kappa min
     KAPPA_Ti_Cj_MAX beam i, channel j, kappa max
     = min( matrix(j,1,1,i,) )
     = max( matrix(j,1,1,i,) )

     KAPPA_MIN
     KAPPA_MAX

     Maybe the more 'integrated' parameter would be RMS(kappa-1) for
     the illuminated baselines. Or maybe RMS(kappa-ref) which include
     the component behavior... but this is hard.
     Or maybe not so hard if the component is caracterised versus
     lambda.
  */
    

  /* Write the kappa matrix into a FITS file */
  yocoLogInfo,"Write the matrix into FITS file:", outputMatrixFile;
  remove,outputMatrixFile;
  fh = cfitsio_open(outputMatrixFile,"w");
  pndrsWritePnrLog, fh, matLog;
  cfitsio_add_image, fh, matrix, "PNDRS_MATRIX";
  cfitsio_add_image, fh, sig2matrix, "PNDRS_MATRIX_ERR";
  cfitsio_add_image, fh, matrixRaw, "PNDRS_MATRIX_RAW";
  cfitsio_add_image, fh, sig2matrixRaw, "PNDRS_MATRIX_RAW_ERR";
  cfitsio_close,fh;

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+outputFile+"_* "+outputMatrixFile+" > /dev/null 2>&1";
  
  /* Add the workflow parameters */
  fh = cfitsio_open(outputMatrixFile,"a");
  cfitsio_goto_hdu, fh,1;
  cfitsio_set,fh,"HIERARCH ESO OCS DRS VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO OCS DRS NAME","pndrs","DRS for PIONIER";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 ID","pndrsComputeSingleMatrix";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW1 NAME",pndrsGetFileWithExt(inputMatrixFiles(1));
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW2 NAME",pndrsGetFileWithExt(inputMatrixFiles(2));
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW3 NAME",pndrsGetFileWithExt(inputMatrixFiles(3));
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW4 NAME",pndrsGetFileWithExt(inputMatrixFiles(4));
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW5 NAME",pndrsGetFileWithExt(inputMatrixFiles(5));
  cfitsio_set,fh,"HIERARCH ESO PRO CATG ","KAPPA_MATRIX";
  cfitsio_close,fh;
  
  yocoLogTrace,"pndrsComputeSingleMatrix done";
  return 1;
}

/* *********************************************************** */

func pndrsComputeAllMatrix(inputDir=, overwrite=)
/* DOCUMENT pndrsComputeAllMatrix(inputDir=, overwrite=)

   DESCRIPTION
   Compute all the kappa-matrix in inputDir.
   The function look for the time sequence:
   "0000","1000","0100","0010","0001"

   Results are stored in file: xxx_kappaMatrix.fits
   in an HDU called PNDRS_MATRIX.
 */
{
  yocoLogInfo,"pndrsComputeAllMatrix()";
  local oiLogDir, outputDir, mjd, shutters, i;
  local tmp;
  
  /* Default */
  if ( is_void(overwrite) ) overwrite=0;

  /* Check the argument */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
     yocoError,"Check argument of pndrsComputeAllMatrix";
     return 0;
  }
  
  /* Prepare the output Dir */
  pndrsBatchProductDir, inputDir, outputDir, app="calib";
  pndrsCheckDirectory, outputDir, 1, chmode="ug+w";

  /* Read the FITS log */
  if ( !pndrsReadLog(inputDir, oiLogDir, overwrite=overwrite) ) {
    yocoError,"Cannot read the logFile.";
    return 0;
  }

  /* If nothing to be done */
  if ( numberof(oiLogDir)<5 ) {
    yocoLogWarning,"No data in this directory";
    return 1;
  }
  /* Keep only the KAPPA files, only for data taken after the
     implentation of the DPR.TYPE parameters. */
  if (oiLogDir.mjdObs(avg)>56512) {
    oiLogDir = oiLogDir( where( strmatch(oiLogDir.dprType,"KAPPA") |
                                strmatch(oiLogDir.dprType,"DARK") ));
  } else {
    yocoLogInfo,"Old data, cannot check DPR.TYPE";
  }

  /* If nothing to be done */
  if ( numberof(oiLogDir)<5 ) {
    yocoLogWarning,"No KAPPA data in this directory";
    return 1;
  }

  /* Sort the oiLogDir by mjd. Critical for the matrix */
  mjd = yocoAstroESOStampToJulianDay(oiLogDir.dateObs,modified=1);
  oiLogDir = oiLogDir(sort(mjd));
  shutters = pndrsGetShutters(,oiLogDir);


  /* Build a flag array to look for valid matrix sequence.
   We suppose the sequence is always taken in the same order
   and we don't consider fragments */
  // required = ["0000","1000","0100","0010","0001"];
  // nall = numberof(oiLogDir);
  // nr   = numberof(required);
  // flag = array(1, nall - nr + 1);
  // for (i=1 ; i<=nr ; i++) {
  //   flag *= ( shutters(i:nall-nr+i)==required(i) );
  // }
  // id = where(flag);

  required = ["1000","0100","0010","0001"];
  nall = numberof(oiLogDir);
  nr   = numberof(required);
  flag = array(1, nall - nr + 1);
  for (i=1 ; i<=nr ; i++) {
    flag *= ( shutters(i:nall-nr+i)==required(i) );
  }
  id = where(flag);

  /* Loop on matrix sequences */
  iMax = numberof(id);
  yocoLogInfo,"Number of matrix to be computed: "+pr1(iMax);
  for ( i=1 ; i<=iMax ; i++)
    {
      /* Matrix files */
      ids = id(i) + indgen(0:nr-1);
      inputMatrixFiles = inputDir + oiLogDir(ids).fileName;

      /* Catch errors */
      yocoLogInfo,"****";
      if ( catch(0x01+0x02+0x08) ) {
         yocoError,"pndrsComputeAllMatrix catch: "+catch_message,,1;
         yocoLogSetFile;
         continue;
      }

      /* Verbose */
      str = swrite(format="pndrsComputeAllMatrix is now working on sequence (%i over %i):",i, iMax);
      yocoLogInfo, str, inputMatrixFiles;

      /* Find the dark */
      if ( pndrsBatchFindBestDark( oiLogDir(ids(3)), oiLogDir, idm) ) {
        yocoLogInfo,"Found DARK:",oiLogDir(idm).fileName;
        inputDarkFile = inputDir + oiLogDir(idm).fileName;
      }
      else {
        yocoLogWarning, "no DARK... skip this matrix.";
        yocoLogSetFile;
        continue;
      }

      /* Prepare the outputFile name, with no-extension  */
      yocoFileSplitName, inputMatrixFiles(1), ,outputFile;
      outputFile   = outputDir + "/" + outputFile;

      /* Skip if outputFile is already existing */
      if ( overwrite==0 && yocoTypeIsFile( outputFile+"_kappaMatrix.fits" ) ) {
        yocoLogInfo,"reduced KAPPA_MATRIX file already exists... skipped.";
        continue;
      }

      /* Set the log File and put some info */
      yocoLogSetFile, outputFile + "_log.txt", overwrite=1;

      yocoLogInfo,"------------- calibration info --------------";
      yocoLogInfo,"target:  "+oiLogDir(ids(1)).target;
      yocoLogInfo,"date:    "+oiLogDir(ids(1)).dateObs;
      yocoLogInfo,"mjd:     "+swrite(format="%.3f",oiLogDir(ids(1)).mjdObs);
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(ids(1)));
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(ids(2)));
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(ids(3)));
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(ids(4)));
      yocoLogInfo,"setupD:  "+pndrsGetSetup(,oiLogDir(idm));
      yocoLogInfo,"---------------------------------------------";
      
      if ( !pndrsComputeSingleMatrix(inputMatrixFiles=inputMatrixFiles,
                                     inputDarkFile=inputDarkFile,
                                     outputFile=outputFile) ) {
        yocoLogWarning,"Cannot compute this matrix... skip it.";
        continue;
      }

      /* End loop on kappa-matrix sequences */
      yocoLogInfo,"****";
      yocoLogSetFile;
    }
  
  yocoLogTrace,"pndrsComputeAllMatrix done";
  return 1;
}

/* *********************************************************** */

func pndrsComputeSingleSpecCal(&oiWave, &specLog,
                               inputSpecCalFile=,
                               outputFile=,
                               outputSpecCalFile=)
/* DOCUMENT pndrsComputeSingleSpecCal(inputSpecCalFile=)

   DESCRIPTION
   Compute the spectral calibration table (OI_WAVELENGTH)
   using the Fourier Transform Spectrometry of the fringes.

   PARAMETERS
   - inputSpecCalFile= input FRINGE file
   - outputFile= ouput SPECTRAL_CALIBRATION file
   
   SEE ALSO pndrsComputeAllSpecCal
*/
{
  yocoLogInfo,"pndrsComputeSingleSpecCal()";
  local coherData, oiWave, specData;
  pndrsPdfCounter = 0;

  /* Check default */
  if ( is_void(outputFile) ) outputFile="outputFile";
  if ( is_void(outputSpecCalFile) ) outputSpecCalFile=outputFile+"_spectralCalib.fits";

  /* Check the input files */
  if ( !pndrsCheckFile(inputSpecCalFile,2,[1],"inputSpecCalFile")  ) {
    return 0;
  }

  /* Read data and prepare */
  oiWave = specData = specLog = [];
  if( !pndrsReadRawFiles(inputSpecCalFile, specData, specLog) ) return 0;
  if( !pndrsProcessDetector(specData, specLog) ) return 0;
  if( !pndrsReformData(specData, specLog) ) return 0;

  /* Check of injection PSD */
  pndrsPlotPsdOfPixels, 1, specData, specLog;
  pndrsSavePdf, 1, outputFile,"pixelPsd.pdf";  

  /* Compute coherent flux */
  if( !pndrsComputeCoherentFlux(specData, specLog, coherData) ) return 0;

  /* Make a summary of the average flux in scan position */
  pndrsPlotRaw, 1, specData(1), specLog, lbd=avg, scan=1:3, allLimits=1,
    legend="data for 3 scans (all channels collapsed)";
  pndrsSavePdf,1,outputFile,"spectralCalibScan.pdf";

  /* Compute the spectral calibration */
  success = pndrsComputeOiWave( coherData, specLog, oiWave, gui=50);
  pndrsSavePdf,52, outputFile,"spectralCalibPsd.pdf";

  /* Stop if failed */
  if (!success) return 0;

  /* Save plots */
  pndrsSavePdf,50,outputFile,"spectralCalibFit.pdf";
  pndrsSavePdf,51,outputFile,"spectralCalib.pdf";

  /* The log is the one of the first file */
  specLog = specLog(1)

  /* Write the SPECTRAL_CALIBRATION into a FITS file */
  yocoLogInfo,"Write the spectral calibration into FITS file:", outputSpecCalFile;
  remove,outputSpecCalFile;
  fh = cfitsio_open(outputSpecCalFile,"w");
  pndrsWritePnrLog, fh, specLog;
  for (j=1;j<=numberof(oiWave);j++)
    oiFitsWriteOiTable, fh, oiWave(j), "OI_WAVELENGTH";
  cfitsio_close,fh;

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+outputFile+"_* "+outputSpecCalFile+" > /dev/null 2>&1";

  /* Add the workflow parameters */
  fh = cfitsio_open(outputSpecCalFile,"a");
  cfitsio_goto_hdu, fh,1;
  cfitsio_set,fh,"HIERARCH ESO OCS DRS VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO OCS DRS NAME","pndrs","DRS for PIONIER";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 ID","pndrsComputeSingleSpecCal";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW1 NAME",pndrsGetFileWithExt(inputSpecCalFile);
  cfitsio_set,fh,"HIERARCH ESO PRO CATG ","SPECTRAL_CALIBRATION";
  cfitsio_close,fh;

  yocoLogTrace,"pndrsComputeSingleSpecCal done";
  return 1;
}

/* *********************************************************** */

func pndrsComputeAllSpecCal(inputDir=,overwrite=)
/* DOCUMENT pndrsComputeAllSpecCal(inputDir=,overwrite=)

   DESCRIPTION
   Compute all the spectral calibration files of the input directory.
*/
{
  yocoLogInfo,"pndrsComputeAllSpecCal()";
  local oiLogDir, outputDir, mjd, shutters, i;
  local tmp, success;

  /* Default */
  if ( is_void(overwrite) ) overwrite=0;

  /* Check the argument */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
     yocoError,"Check argument of pndrsComputeAllSpecCal";
     yocoLogSetFile;
     return 0;
  }
  
  /* Prepare the output Dir */
  pndrsBatchProductDir, inputDir, outputDir, app="calib";
  pndrsCheckDirectory, outputDir, 1, chmode="ug+w";

  /* Read the FITS log */
  if ( !pndrsReadLog(inputDir, oiLogDir, overwrite=overwrite) ) {
    yocoError,"Cannot read the logFile.";
    return 0;
  }

  /* If nothing to be done */
  if ( numberof(oiLogDir)<1 ) {
    yocoLogInfo,"No data in this directory";
    return 1;
  }

  /* Look for spectral calibration files */
  id = where( pndrsIsSpectralCalib(oiLogDir) );

  /* Loop on spectral calibration files */
  iMax = numberof(id);
  for ( i=1 ; i<=iMax ; i++)
    {
      /* Spectral calibration file */
      inputSpecCalFile = inputDir + oiLogDir(id(i)).fileName;

      /* Catch errors */
      yocoLogInfo,"****";
      if ( catch(0x01+0x02+0x08) ) {
         yocoError,"pndrsComputeSpecCal catch: "+catch_message,,2;
         yocoLogSetFile;
         continue;
      }

      /* Verbose */
      str = swrite(format="pndrsComputeSpecCal is now working on file (%i over %i):",i, iMax);
      yocoLogInfo, str, inputSpecCalFile;

      /* Prepare the outputFile name, with no-extension */
      yocoFileSplitName, inputSpecCalFile, ,outputFile;
      outputFile   = outputDir + "/" + outputFile;

      /* Skip if outputFile is already existing */
      if ( overwrite==0 && yocoTypeIsFile( outputFile+"_spectralCalib.fits" ) ) {
        yocoLogInfo,"reduced SPECTRAL_CALIBRATION file already exists... skipped.";
        continue;
      }

      /* Set the log File and put some info */
      yocoLogSetFile, outputFile + "_log.txt", overwrite=1;

      yocoLogInfo,"------------- calibration info --------------";
      yocoLogInfo,"target:  "+oiLogDir(id(i)).target;
      yocoLogInfo,"date:    "+oiLogDir(id(i)).dateObs;
      yocoLogInfo,"mjd:     "+swrite(format="%.3f",oiLogDir(id(i)).mjdObs);
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(id(i)));
      yocoLogInfo,"---------------------------------------------";

      if ( !pndrsComputeSingleSpecCal(inputSpecCalFile=inputSpecCalFile,
                                      outputFile=outputFile) ) {
        yocoLogWarning,"Cannot compute this specCal... skip it.";
        continue;
      }

      /* End loop on spectral calibs */
      yocoLogInfo,"****";
      yocoLogSetFile;
    }
  
  yocoLogTrace,"pndrsComputeAllSpecCal done";
  return 1;
}

/* *********************************************************** */

func pndrsComputeSingleOiData(&oiVis2, &oiT3, &oiVis, &oiWave,
                              &oiLog, &oiArray, &oiTarget,
                              mode=, outputFile=,
                              inspect=,
                              inputScienceFile=,
                              inputDarkFile=,
                              inputMatrixFile=,
                              inputSpecCalFile=,
                              inputScriptFile=,
                              inputScriptCkSum=,
                              checkPhase=,
                              snrThreshold=,
                              outputOiDataFile=,
                              inputCatalogFile=)
/* DOCUMENT pndrsComputeSingleOiData(&oiVis2, &oiT3, &oiVis, &oiWave,
                &oiLog, &oiArray, &oiTarget,
                mode=, outputFile=,
                inspect=, 
                inputScienceFile=,
                inputMatrixFile=,
                inputSpecCalFile=,
                inputDarkFile=,
                inputScriptFile=,
                inputScriptCkSum=,
                snrThreshold=)

   DESCRIPTION
   Perform the full data reduction on files.
   
   PARAMETERS
   Most of the parameters are self-explanatory.
   - mode can contain:
     abcd, ac: use
     ns: no scan selection
     nc: no crop of the scan lenght
     faint: averaging of the photometri (no Wienier filtering)

   EXAMPLES

   SEE ALSO
 */
{
  local imgData, imgLog, matrix, flux, coherData;
  local flux, matrix, tmp, fluxdark;
  local darkData;
  local nscandark, norm2;
  local outputDir, selTable, snrThreshold;
  local snr, snr0, trans;
  yocoLogInfo,"pndrsComputeSingleOiData()";
  pndrsPdfCounter = 0;

  /* Init the variables */
  local oiArray, oiLog, oiTarget, oiVis2, oiVis, oiT3, oiDiam;
  local oiVis2Tf, oiT3Tf;
  oiVis2 = oiVis = oiT3 = oiWave = oiLog = oiArray = oiTarget = [];
  coherData = matrix = tmp = flux = fluxdark = [];

  /* Check default */
  if ( is_void(outputFile) ) outputFile="outputFile";
  if ( is_void(outputOiDataFile) ) outputOiDataFile=outputFile+"_oidata.fits";
  if ( is_void(mode) ) mode="abcd";
  if ( is_void(inputScriptFile)) inputScriptFile=yocoStrReplace(inputScienceFile,[".fits"],[".i"]);
  if ( is_void(snrThreshold) ) snrThreshold = 1.75;
    
  /* Verbose */
  yocoLogInfo,"mode="+mode;

  /* Check the input files */
  if ( !pndrsCheckFile(inputMatrixFile,2,[1],"inputMatrixFile") ||
       !pndrsCheckFile(inputScienceFile,2,[1],"inputScienceFile") ||
       !pndrsCheckFile(inputDarkFile,2,[1],"inputDarkFile") ||
       !pndrsCheckFile(inputSpecCalFile,1,[0,1],"inputSpecCalFile") ) {
    return 0;
  }

  /* Init the plots and the browser */
  yocoGuiWinKill;

  /* Read the KAPPA_MATRIX file */
  if( !pndrsReadKappaMatrix(matrix, inputMatrixFile=inputMatrixFile, readExtension=0) ) return 0;

  /* Read the fringe file */
  yocoLogInfo,"Read the fringe file:", inputScienceFile;
  if( !pndrsReadRawFiles(inputScienceFile, imgData, imgLog) ) return 0;
  if( !pndrsCheckOiLog(imgLog) ) return 0;

  /* Check the abcd mode, change to ac if not possible */
  correl = ( *imgLog(1).correlation )(1).type;
  yocoLogInfo,"Correlation is: " + correl;
  if ( (strmatch(mode,"abcd") && correl!="abcd") ||
       !strmatch(imgLog(1).obc,"ABCD"))
  {
    mode = yocoStrReplace(mode,"abcd","ac");
    yocoLogInfo,"Change mode abcd->ac since no ABCD outputs";
  }

  /* Read the dark file */
  yocoLogInfo,"Read the dark file:", inputDarkFile;
  if( !pndrsReadRawFiles(inputDarkFile, darkData, darkLog) ) return 0;
  if( !pndrsCheckOiLog(darkLog) ) return 0;

  /* Associate the logs into a single array */
  darkLog.logId = darkData.hdr.logId = imgData.hdr.logId + 1;
  imgLog = grow(imgLog, darkLog);

  /* Include script file */
  if ( yocoTypeIsStringScalar(inputScriptFile) && yocoTypeIsFile(inputScriptFile) ) {
    inputScriptFile = inputScriptFile(*)(1);
    ckSumNow = pndrsGetCkSum(inputScriptFile);
    if ( is_array(inputScriptCkSum) && inputScriptCkSum!=ckSumNow) {
      /* Not a valid checksum */
      yocoError,"Check ",inputScriptFile(*)(1);
      return 0;
    } else {
      /* None or valid checksum, include script */
      yocoLogInfo,"Include script file:",inputScriptFile;
      include,inputScriptFile,3;
      inputScriptCkSum = ckSumNow;
    }
  } else {
    yocoLogInfo,"No script to load";
    inputScriptFile = [];
    inputScriptCkSum = [];
  }

  /* Process detector */
  if( !pndrsProcessDetector(imgData, imgLog) ) return 0;
  if( !pndrsProcessDetector(darkData, imgLog) ) return 0;

  /* Reform data */
  if( !pndrsReformData(imgData, imgLog) ) return 0;
  if( !pndrsReformData(darkData, imgLog) ) return 0;

  /* Keep minimum number of samples to have 3.5pix/fringes */
  if( !pndrsProcessOversampling(imgData, imgLog) ) return 0;
  if( !pndrsProcessOversampling(darkData, imgLog) ) return 0;

  /* Check the badpixels of kappa-matrix, darkData
     and imgData. Stop if inconsistent */
  if( !pndrsCheckBadPixelConsistency(imgLog, matrix, imgData, darkData) ) return 0;

  /* Check of injection PSD */
  pndrsPlotPsdOfPixels, 1, imgData, imgLog;
  pndrsSavePdf, 1, outputFile,"pixelPsd.pdf";  

  /* Make a summary of the average flux in scan position */
  pndrsPlotRaw,2, imgData,  imgLog, lbd=avg, scan=avg, legend="Average value of raw data and dark (all channels collapsed)";
  pndrsPlotRaw,2, darkData, imgLog, lbd=avg, scan=avg, color="red", kill=0, allLimits=1;
  pndrsSavePdf,2, outputFile,"dataScienceScanAvg.pdf";
  
  /* Plot all RAW data with the dark */
  for (i=1;i<=dimsof(matrix)(2);i++) {
    pndrsPlotRaw,2, imgData,  imgLog, lbd=i, scan=1:3,  legend=swrite(format="data and dark for channel %02d (3 scans)",i);
    pndrsPlotRaw,2, darkData, imgLog, lbd=i, color="red", scan=1:3, which=,kill=0,type=3;
    pndrsSavePdf,2, outputFile,"rawDataIdc"+swrite(format="%02d",i)+".pdf";
  }

  /* Remove the dark */
  pndrsComputeDark, darkData, imgLog, dark;
  pndrsRemoveDark,  imgData,  imgLog, dark;
  pndrsRemoveDark,  darkData, imgLog, dark;

  /* Plot the data without the dark */
  pndrsPlotRaw,2, imgData,  imgLog, color=, lbd=avg, scan=avg, legend="Average value of data-dark and dark-dark (all channels collapsed)";
  pndrsPlotRaw,2, darkData, imgLog, lbd=avg, scan=avg,kill=0, allLimits=1, color="red";
  pndrsSavePdf,2, outputFile,"dataNoDarkScanAvg.pdf";
  pndrsPlotAllSpectra, 2, imgData, imgLog, legend="Average data-dark per read";
  pndrsSavePdf,2, outputFile,"fluxLbd.pdf";
  
  /* Verbose */
  yocoLogInfo,"Compute coherent flux and telescope flux...";

  /* Mode is ABCD, we use the GRAVITY methode
     to get coherData and flux. Otherwise we use the
     classical methode */
  if ( strmatch(mode,"abcd") )
  {
    yocoLogInfo,"mode is abcd: use P2VM to estimate flux and coherent flux";
    // pndrsComputeCoherentFluxMatrix, darkData, matrix, imgLog, darkData,  fluxdark;
    pndrsComputeCoherentFluxMatrix, imgData,  matrix, imgLog, coherData, flux, cont, gui=10;
    
    // pndrsSavePdf,12,"CHECK.pdf";
    pndrsSavePdf,11,outputFile,"sciDataShowCont.pdf";
    pndrsSavePdf,13,outputFile,"sciDataNoCont.pdf";
    pndrsSavePdf,12,outputFile,"sciDataNoContLbd.pdf";
    pndrsSavePdf,10,outputFile,"coherDataLbd.pdf";
    pndrsSavePdf,15,outputFile,"inputFluxLbd.pdf";
    pndrsSavePdf,16,outputFile,"inputFluxScan.pdf";
    pndrsSavePdf,14,outputFile,"sciDataPhot.pdf";

    /* HACK for the poor baseline ABCD -> AC fringes */
    pndrsHackForThePoorBaseline, coherData, matrix, imgData, imgLog, base=4;
    pndrsHackForThePoorBaseline, coherData, matrix, imgData, imgLog, base=10;
  }
  else
  {
    yocoLogInfo,"mode is ac: use FLUOR to estimate flux and coherent flux";
    yocoLogInfo,"(process identically fringe and dark)";
    /* Flat-field the fringe, the dark and the matrix */
    pndrsFlatField, darkData, imgLog, matrix, flatMatrix=0;
    pndrsFlatField, imgData,  imgLog, matrix, flatMatrix=1;
    pndrsPlotMatrix, 5, matrix, imgLog(1);
    pndrsSavePdf,5,outputFile,"matrixFlat.pdf";
  
    /* Compute the input fluxes (flatfielded) */
    pndrsComputeInputFlux, darkData, imgLog,  matrix, fluxdark, gui=6;
    pndrsSavePdf,6,outputFile,"inputFluxLbdDark.pdf";
    pndrsSavePdf,7,outputFile,"inputFluxPsdDark.pdf";
    pndrsSavePdf,8,outputFile,"inputFluxScanDark.pdf";
    pndrsSavePdf,9,outputFile,"databPsdDark.pdf";
  
    pndrsComputeInputFlux, imgData,  imgLog,  matrix, flux, gui=6;
    pndrsSavePdf,6,outputFile,"inputFluxLbd.pdf";
    pndrsSavePdf,7,outputFile,"inputFluxPsd.pdf";
    pndrsSavePdf,8,outputFile,"inputFluxScan.pdf";
    pndrsSavePdf,9,outputFile,"databPsd.pdf";
  
    /* Remove the continuu */
    pndrsRemoveContinuum, darkData, imgLog, matrix, fluxdark;
    pndrsRemoveContinuum, imgData,  imgLog,  matrix, flux, gui=6;
    pndrsSavePdf,6,outputFile,"sciDataShowCont.pdf";
    pndrsSavePdf,7,outputFile,"sciDataNoContLbd.pdf";
    pndrsSavePdf,8,outputFile,"sciDataNoCont.pdf";
  
    /* Compute the coherent flux per baseline. Note that the check
       takes a lot of time (FFT over each outputs of IONIC) */
    pndrsComputeCoherentFlux, darkData, imgLog, darkData;
    checkPhase = 0;
    pndrsComputeCoherentFlux, imgData,  imgLog,  coherData, gui=10, check=checkPhase;
    if(checkPhase) {pndrsSavePdf,checkPhase,outputFile,"checkPhase.pdf";}
    pndrsSavePdf,10,outputFile,"coherDataLbd.pdf";
  }


  /* Plot the coherent flux */
  pndrsPlotRaw,11,coherData, imgLog, lbd=avg, scan=1:3, op=re_part, allLimits=1,
    legend="Real part of coherent flux for 3 scans (all channels collapsed)";
  pndrsSavePdf,11,outputFile,"coherData.pdf";

  /* Optional selection table in the data (done manually
     by pndrsInspectRawData) */
  pndrsApplySelectionTable, coherData, imgLog;
  
  
  /* Compute the normalisation signal n2, that is 4.Ta.Tb */
  yocoLogInfo,"Compute normalisation norm2 (mode="+mode+")...";
  
  if (strmatch(mode,"faint"))
    pndrsComputeCoherentNorm2Faint, coherData, imgLog, flux, norm2, gui=20;
  else
    pndrsComputeCoherentNorm2, coherData, imgLog, flux, norm2, gui=20;

  /* Save plots for norm */
  pndrsSavePdf,21,outputFile,"wfInputFlux.pdf";
  pndrsSavePdf,20,outputFile,"coherNorm2.pdf";

  
  /* Compute the OPDs and SNRs (2005ApOpt..44.5173P) */
  yocoLogInfo,"Compute OPDs and SNRs";
  
  if (strmatch(mode,"abcdnf"))
    pndrsScanComputeOpdAbcd, coherData, imgLog, pos, snr, snr0, gui=12, useFilter=0;
  else if (strmatch(mode,"abcd"))
    pndrsScanComputeOpdAbcd, coherData, imgLog, pos, snr, snr0, gui=12;
  else
    pndrsScanComputeOpd, coherData, darkData, imgLog, pos, snr, snr0, gui=12;

  /* Save plots for OPD and SNR */
  pndrsSavePdf,12,outputFile,"snr.pdf";
  // pndrsSavePdf,13,outputFile,"snrPsd.pdf";

  coherData0 = coherData(1);
  
  /* Crop the scan. */
  if (strmatch(mode,"nc")) {
    yocoLogInfo,"No crop of the scan (mode contains 'nc')";
  } else if (strmatch(mode,"abcd")) {
    pndrsScanCropOpd, coherData, imgLog, pos, 60e-6, crop;
    norm2 *= crop^2;
  } else {
    pndrsScanCropOpd, coherData, imgLog, pos, 60e-6, crop;
    pndrsScanCropOpd, darkData,  imgLog, pos, 60e-6;
    norm2 *= crop^2;
  }

  
  /* Scan selection. */
  if (strmatch(mode,"ns")) {
    yocoLogInfo,"No scan selection (mode contains 'ns')";
  } else {
    yocoLogInfo,"Simple scan selection: SNR>"+pr1(snrThreshold)+"";
    pndrsGetData, coherData, imgLog, data, opd, map;
    mask = (snr>snrThreshold);
    //mask(2:-1,) = max(mask(2:-1,),mask(:-2,)); 
    //mask(2:-1,) = max(mask(2:-1,),mask(3:,)); 
    data  *= mask(-,-,,);
    norm2 *= mask(-,-,,);
    coherData.regdata = &data;
  }

  /* Plot the data in waterfall */
  pndrsPlotRawWaterfall,12,coherData,imgLog,lbd=sum,op=abs,filter=pndrsFilterWide,reorder=1,
    legend="Coherent flux (waterfall, all channels collapsed)";
  pndrsSavePdf,12,outputFile,"coherDataWater.pdf";
  
  /* Plot the psd in waterfall */
  pndrsPlotFftWaterfall,13,coherData,imgLog,op=abs,lbd=avg,legend="PSD of coherent flux (waterfall, all channels collapsed)";
  pndrsSavePdf,13,outputFile,"coherPsdWater.pdf";


  /* Compute closure and differential phases */
  yocoLogInfo,"Compute the closure and differential phases...";
  pndrsScanComputeClosurePhases, coherData, imgLog, norm2, pos, oiT3, gui=30;
  if (is_array(oiT3)) {
    pndrsSavePdf,30,outputFile,"t3phiScan.pdf";
    pndrsSavePdf,31,outputFile,"t3phiLbd.pdf";
    pndrsSavePdf,32,outputFile,"t3ampScan.pdf";
  }

  yocoLogInfo,"Compute the polar-differential phases...";
  pndrsScanComputePolarDiffPhases, coherData, imgLog, oiVis, gui=35;
  if (is_array(oiVis)) {
    pndrsSavePdf,35,outputFile,"visPhiScan.pdf";
    pndrsSavePdf,36,outputFile,"visPhiLbd.pdf";
  }
  
  // yocoLogInfo,"Compute the specto-differential phases...";
  // pndrsScanComputeDiffPhase, coherData, imgLog, filterClo, pos, oiVis, gui=0;

  
  /* Compute the vis2 */
  if ( strmatch(mode,"abcd") )
  {
    yocoLogInfo,"Compute the visibilities (mode=abcd)...";
    pndrsScanComputeAmp2PerScanAbcd, coherData, imgLog, norm2, pos, oiVis2, gui=20;
  }
  else
  {
    yocoLogInfo,"Compute the visibilities (mode=ac)...";
    pndrsScanComputeAmp2PerScan, coherData, darkData, imgLog, norm2, pos, oiVis2, gui=20;
  }
  
  /* Print plots for vis2 */
  yocoLogInfo,"Print some plots...";
  pndrsSavePdf,29,outputFile,"envScanIdMin.pdf";
  pndrsSavePdf,30,outputFile,"envScanIdMax.pdf";
  pndrsSavePdf,25,outputFile,"psd0.pdf";
  pndrsSavePdf,26,outputFile,"psdIdMax.pdf";
  pndrsSavePdf,27,outputFile,"psdIdMin.pdf";
  for (i=1;i<=dimsof(matrix)(2);i++) pndrsSavePdf,30+i,outputFile,"psdIdc"+swrite(format="%02d",i)+".pdf";
  pndrsSavePdf,21,outputFile,"vis2amp2n2.pdf";
  pndrsSavePdf,22,outputFile,"vis2Scan.pdf";
  pndrsSavePdf,24,outputFile,"amp2Lbd.pdf";
  pndrsSavePdf,23,outputFile,"vis2Lbd.pdf";

  
  /* Cross-link in oiStructures */
  yocoLogInfo,"Cross-link oiStructures...";
  sciLog = oiFitsGetOiLog(coherData,imgLog);
  pndrsDefaultOiLog, sciLog, oiLog, oiVis2, oiT3, oiVis;
  pndrsDefaultOiTarget, sciLog, oiTarget, oiVis2, oiT3, oiVis;
  pndrsDefaultOiArray, sciLog, oiArray, oiVis2, oiT3, oiVis;

  /* Cross-link with spectral calibration, either from
     a spectral calibration file (OI_WAVE) or from the
     default according to the setup */
  if ( is_array(inputSpecCalFile) ) {
    yocoLogInfo,"Read SPECTRAL_CALIBRATION file:",inputSpecCalFile;
    
    /* Open file */
    fh   = cfitsio_open(inputSpecCalFile,"r");
    nHdu = cfitsio_get_num_hdus(fh);
    
    /* loop on HDUs and load the oiWavelength tables */
    for( oiWave=[], i=2 ; i<=nHdu ; i++) {
      cfitsio_goto_hdu,fh,i;
      if(cfitsio_get(fh,"EXTNAME") == "OI_WAVELENGTH" )
        grow, oiWave, oiFitsLoadWaveTable(fh, -1);
    }
    
    /* Close file */
    cfitsio_close,fh;
    
  } else {
    yocoLogInfo,"Compute default Spectral Calibration...";
    pndrsDefaultOiWaves, sciLog, oiWave;
  }

  /* Verbose of the result */
  yocoLogInfo,"Found "+pr1(numberof(oiWave))+" oiWave table(s)";

  /* Change the insName, by adding the first and last spectral wavelength
     bin, so that the insName becomes perfectly unique */
  oiFitsUpdateInsName, oiWave, oiVis2, oiVis, oiT3;

  /* Get diam and magnitude parameters, compute transfer function */
  // inputCatalogFile = "/data/pionier/Software/catalogs/jsdc_2015_04_30.fits";
  pndrsGetTransferFunction, oiTarget, oiLog, oiWave, oiVis2, catalogFile=inputCatalogFile;
  
  /* Computation QC parameter of flux and total transmission. */
  pndrsGetTransmission, flux, oiLog;
 
  /* Define the PRO.CATG */
  if (oiLog.dprCatg=="CALIB")  oiLog.proCatg="CALIB_OIDATA_RAW";
  else                         oiLog.proCatg="TARGET_OIDATA_RAW";
  yocoLogInfo,"Set PRO.CATG to "+oiLog.proCatg+"   (DPR.CATG=="+oiLog.dprCatg+")";
  
  /* Clean (this will also modify all internal cross-referencing) */
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
  oiFitsCleanUnused,oiTarget,oiWave,oiArray,oiVis2,oiVis,oiT3,oiLog;

  /* Write file, this will dump the header keywords from
     the input science file (oiLog.fileName) */
  oiFitsWriteFile, outputOiDataFile, oiTarget, oiWave, oiArray,
    oiVis2, oiVis, oiT3, oiLog, overwrite=1, funcLog=pndrsWritePnrLog;

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+outputFile+"_* "+outputOiDataFile+" > /dev/null 2>&1";

  /* Add the some info */
  fh = cfitsio_open(outputOiDataFile,"a");
  
  cfitsio_add_bintable, fh,
    [&transpose(snr),&transpose(pos)],
    ["SNR","POS"], ["power","m"], "PIONI_SCANDATA";

  ///* Add additional data in an non-OIFITS extension
  //   for QC plots. */
  //pndrsGetData, coherData0, imgLog, data, opd, map, oLog;
  //cfitsio_add_bintable, fh,
  //  [&transpose(data(1,,,),-1),&transpose(opd,-1)],
  //  ["COHER_DATA","OPD"], ["adu","m"], "PIONI_COHERDATA";
  
  /* Add the workflow parameters */
  cfitsio_goto_hdu, fh,1;
  cfitsio_set,fh,"HIERARCH ESO OCS DRS VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO OCS DRS NAME","pndrs","DRS for PIONIER";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 ID","pndrsComputeSingleOiData";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 VERSION",pndrsVersion,"pndrs version";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW1 NAME",pndrsGetFileWithExt(inputScienceFile);
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW2 NAME",pndrsGetFileWithExt(inputDarkFile);
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW3 NAME",pndrsGetFileWithExt(inputMatrixFile);
  if ( is_array(inputSpecCalFile) )
    cfitsio_set,fh,"HIERARCH ESO PRO REC1 RAW4 NAME",pndrsGetFileWithExt(inputSpecCalFile);
  /* Add the parameters. The checksum of the script is also
     given to verify calibration latter */
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 PARAM1 NAME","-mode";
  cfitsio_set,fh,"HIERARCH ESO PRO REC1 PARAM1 VALUE",mode;
  if ( is_array(inputScriptFile) ) {
      cfitsio_set,fh,"HIERARCH ESO PRO REC1 PARAM2 NAME","-inputScriptFile";
      cfitsio_set,fh,"HIERARCH ESO PRO REC1 PARAM2 VALUE",pndrsGetFileWithExt(inputScriptFile);
  }
  if ( is_array(inputScriptCkSum) ) {
      cfitsio_set,fh,"HIERARCH ESO PRO REC1 PARAM3 NAME","-inputScriptCkSum";
      cfitsio_set,fh,"HIERARCH ESO PRO REC1 PARAM3 VALUE",inputScriptCkSum;
  }

  /* close file */
  cfitsio_close,fh;
  
  yocoLogTrace,"pndrsComputeSingleOiData done";
  return 1;
}

/* ********************************************************************* */

func pndrsComputeAllOiData(inputDir=, overwrite=, mode=, inspect=, inputScriptFile=)
/* DOCUMENT pndrsComputeAllOiData(inputDir=, overwrite=, mode=, inspect=)

   DESCRIPTION
   Run pndrsComputeSingleOiData in loop over all the observations contained
   in directory 'inputDir':
   - read log and keep all files with 4 shutters open, then for each file:
   - find the matrix
   - run pndrsComputeSingleOiData
   - write the result into an OIFITS file.
   
   PARAMETERS
   - inputDir: scalar string
   - mode="abcd", "ac", "abcdfaint", "abcdfaintnc"...
   - overwrite=1: re-compute existing OIFITS, otherwise skip (default is 0).

   EXAMPLES
   > pndrsComputeAllOiData, ".", overwrite=0, mode="abcd";
 */
{
  yocoLogInfo,"pndrsComputeAllOiData()";
  local files, idSci, oiLog, outputDir, oiLogDir, ids, idd;
  local oiVis2, oiVis, oiT3, oiWave, oiLog, oiArray, oiTarget;
  local inputSpecCalFile, inputMatrixFiles, inputScienceFile;
  local oiLogCal, calibDir;
  local fwhm, tau0;
  if ( is_void(overwrite) ) overwrite=0;

  /* Mode: "faint, bright, test" */
  if ( is_void(mode) ) mode="abcd";

  /* Check the argument */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
     yocoError,"Check argument of pndrsComputeAllOiData";
    return 0;
  }

  /* Default for script file (note that it is "pndrsScript.i") */
  if (is_void(inputScriptFile)) inputScriptFile=inputDir+"pndrsScript.i";

  /* Prepare the output Dir */
  pndrsBatchProductDir, inputDir, outputDir, app=mode;
  pndrsCheckDirectory, outputDir, 1, chmode="ug+w";

  /* Build the name of the calibration dir */
  pndrsBatchProductDir, inputDir, calibDir, app="calib";
  calibDir = pndrsGetRealName(calibDir);
  
  /* Read the FITS log of inputDir */
  if ( !pndrsReadLog(inputDir, oiLogDir, overwrite=overwrite) ) {
    yocoError,"Cannot read the logFile.";
    return 0;
  }

  /* If nothing to be done */
  if ( numberof(oiLogDir)<1 ) {
    yocoLogInfo,"No data in this directory";
    return 1;
  }

  /* Sort the oiLogDir by mjd. */
  mjd = yocoAstroESOStampToJulianDay(oiLogDir.dateObs,modified=1);
  oiLogDir = oiLogDir(sort(mjd));

  /* Look for the science files to loop on them.
     They are defined as all shutter open and scaning on */
  idSci = where( pndrsGetShutters(,oiLogDir)=="1111" &
                 oiLogDir.scanStatus==1 );

  /* If nothing to be done */
  if ( numberof(idSci)<1 ) {
    yocoLogWarning,"No science data (shutter 1111), exit";
    return 1;
  }

  /* Read the FITS log of calibDir */
  if ( !pndrsReadLog(calibDir, oiLogCal, overwrite=overwrite) ) {
    yocoError,"Cannot read the logFile.";
    return 0;
  }

  
  /* Loop on science files */
  iMax = numberof(idSci);
  for ( i=1 ; i<=iMax ; i++)
    {

      /* Catch errors: report it, close logging file,
         and continue with next file */
      yocoLogInfo,"****";
      if ( catch(0x01+0x02+0x08) ) {
         yocoError,"pndrsComputeAllOiData catch: "+catch_message,,1;
         yocoLogSetFile;
         continue;
      }

      /* Some reset */
      ids = idSci(i);
      idm = [];
      onSky = pndrsIsOnSky(oiLogDir(ids));
      inputScienceFile = inputDir + oiLogDir(ids).fileName;
      inputSpecCalFile = [];
      inputMatrixFile  = [];
      inputDarkFile    = [];

      /* Just a log */
      str = swrite(format="pndrsComputeAllOiData is now working on file (%i over %i):",
                   i, numberof(idSci));
      yocoLogInfo, str, oiLogDir(ids).fileName;
      
      /* Prepare the outputFile name, with no-extension */
      yocoFileSplitName, oiLogDir(ids).fileName, ,outputFile;
      outputFile   = outputDir + "/" + outputFile;
      
      /* Skip if outputFile is already existing */
      if ( overwrite==0 && yocoTypeIsFile( outputFile+"_oidata.fits" ) ) {
        yocoLogInfo,"reduced TARGET_OIDATA_RAW already exists (oidata.fits)... skipped.";
        continue;
      }
      

      /* Set the log File and put some info */
      yocoLogSetFile, outputFile + "_log.txt", overwrite=1;
      pndrsGetAmbi, oiLogDir(ids), fwhm, tau0;
      yocoLogInfo,"------------- observation info --------------";
      yocoLogInfo,"file:    "+oiLogDir(ids).fileName;
      yocoLogInfo,"target:  "+oiLogDir(ids).target;
      yocoLogInfo,"date:    "+oiLogDir(ids).dateObs;
      yocoLogInfo,"mjd:     "+swrite(format="%.3f",oiLogDir(ids).mjdObs);
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(ids));
      yocoLogInfo,"ambi:    "+pr1(fwhm)+"'' / "+pr1(tau0)+"ms";
      // yocoLogInfo,"dateRed: "+pndrsBatchTime();
      yocoLogInfo,"pndrs:   "+pndrsVersion;
      yocoLogInfo,"mode:    "+mode;
      yocoLogInfo,"---------------------------------------------";
  
      /* Find the dark */
      if ( pndrsBatchFindBestDark( oiLogDir(ids), oiLogDir, idm) ) {
        yocoLogInfo,"Found DARK:",oiLogDir(idm).fileName;
        inputDarkFile = inputDir + oiLogDir(idm).fileName;
      }
      else {
        if ( onSky ) yocoLogWarning, "no DARK... skip this file.";
        else         yocoLogInfo, "no DARK.. skip this file (not on sky).";
        yocoLogSetFile;
        continue;
      }

      /* Look for KAPPA_MATRIX */
      if ( pndrsBatchFindBestMatrix(oiLogDir(ids), oiLogCal, idm) ){
        yocoLogInfo, "Found KAPPA_MATRIX:",  oiLogCal(idm).fileName;
        inputMatrixFile = calibDir + oiLogCal(idm).fileName;
      }
      else {
        if ( onSky ) yocoLogWarning, "no KAPPA_MATRIX... skip this file.";
        else         yocoLogInfo, "no KAPPA_MATRIX... skip this file (not on sky).";
        yocoLogSetFile;
        continue;
      }
      
      /* Look for SPECTRAL_CALIBRATION */
      if ( pndrsBatchFindBestSpecCal(oiLogDir(ids), oiLogCal, idm) ) {
        yocoLogInfo, "Found SPECTRAL_CALIBRATION:",  oiLogCal(idm).fileName;
        inputSpecCalFile = calibDir + oiLogCal(idm).fileName;
      }
      else {
        inputSpecCalFile = [];
      }
      
      /* Reduce these files */
      if ( !pndrsComputeSingleOiData(inputScienceFile=inputScienceFile,
                               inputMatrixFile=inputMatrixFile,
                               inputDarkFile=inputDarkFile,
                               inputSpecCalFile=inputSpecCalFile,
                               outputFile=outputFile,
                               mode=mode, inspect=inspect,
                               inputScriptFile=inputScriptFile) ) {
        yocoLogWarning,"Cannot reduce this file... skip it.";
        continue;
      }

      /* Stop logging in file */
      yocoLogInfo,"****";
      yocoLogSetFile;
    }

  yocoLogInfo,"pndrsComputeAllOiData done"; 
  return 1;

}

/* ********************************************************************* */

func pndrsCalibrateAllOiData(inputDir=,catalogsDir=,inputScriptFile=,inputScriptCkSum=,rmPdf=,averageFiles=,rmOiDiam=)
/* DOCUMENT pndrsCalibrateAllOiData(inputDir=,catalogsDir=,inputScriptFile=,rmPdf=,averageFiles=)

   DESCRIPTION
   Calibrate the oiData contained in inputDir and create:
   - PDF with the transfer function plot
   - a OIFITS file with all calibrated data (SCI and CAL)
   - several OIFITS, one per SCI, with calibrated data.

   PARAMETERS:
   - inputScriptFile is the (optional) name of the yorick script
   that will be executed by the function just before calling
   oiFitsCalibrateNight. It can be used to make some filtering,
   grouping, removing part of the night... or any advance
   operation on the structures oiVis2, oiT3, oiVis, oiArray and
   oiTarget.

   If inputScriptFile is not define, the function will load
   "pndrsScript.i" if it exists.
 */
{
  yocoLogInfo,"pndrsCalibrateAllOiData()";
  local strRoot,i,calibFile, name, l, allStars;
  local vis2TfMode, t3TfMode, vis2TfErrMode, t3TfErrMode, t3TfParam, vis2TfParam;
  local oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog, oiDiam;
  local Avg, maxVis2Err, maxT3PhiErr;
  
  /* Default */
  maxVis2Err  = 0.25;
  maxT3PhiErr = 20.0;
  vis2TfMode  = 1;
  t3TfMode    = 1;
  Avg0 = [[1.637,1.715],[2.04,2.25]];
  
  /* Check the argument and go into this directory */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
    yocoError,"Check argument of pndrsCalibrateAllOiData";
    return 0;
  }
  
  /* Find a root for the files that are created. Take the part of the
     input directory name that is before _ (if any) */
  strRoot0 = yocoStrSplit(yocoFileSplitName(strpart(inputDir,:-1)),"_")(1);
  strRoot  = inputDir+"/"+strRoot0;

  /* Default for file with calibration stars */
  calibFile = strRoot+"_oiDiam.fits";

  /* Set a logging file */
  yocoLogSetFile, strRoot+"_log.txt", overwrite=1;

  /* Catch errors */
  if ( catch(0x01+0x02+0x08) ) {
    yocoError,"pndrsCalibrateAllOiData catch: "+catch_message,,1;
    yocoLogSetFile;
    return 0;
  }

  /* Remove existing oiDiam */
  if (rmOiDiam) {
    yocoLogInfo,"Remove oiDiam.fits";
    system, "rm -rf "+calibFile+" > /dev/null 2>&1";
  }

  /* Load all the OIDATA files. FIXME: Actually would be better
     to use the DPR.CATG parameters. Note: do not load the oiVis
     because this quantity is not understood so far */
  oiFitsLoadFiles,inputDir+"/PION*oidata.fits", oiTarget, oiWave, oiArray,
    oiVis2, , oiT3, oiLog,
    shell=1, readMode=-1;

  /* Check if observations have been loaded */
  if ( !is_array(oiTarget) ) {
    yocoLogWarning,"No reduced TARGET_OIDATA_RAW (*oidata.fits)";
    yocoLogSetFile;
    return 1;
  }

  /* Some cleaning */
  oiFitsCleanDataFromDummy, oiVis2, oiT3, oiVis,
    maxVis2Err=maxVis2Err, maxT3PhiErr=maxT3PhiErr,
    minBaseLength=-1;

  /* This is a hack to deal with the fact that the star names may have changed:
     update the names in oiTarget */
  oiTarget.target = pndrsCheckTargetInList(oiTarget.target);
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
  
  
  /* This is a hack to deal with the fact that the star names may have changed:
     Open the calibFile, update names and re-write it... */
  if ( open(calibFile, "r", 1) )
  {
    oiFitsLoadOiDiam, calibFile, oiDiam;
    oiDiam.target = pndrsCheckTargetInList(oiDiam.target);
    oiFitsWriteOiDiam, calibFile, oiDiam, overwrite=1;
  }

  /* Load current oiLogFile if it exists */
  oiDiam = [];
  if ( open(calibFile, "r", 1) )
  {
    oiFitsLoadOiDiam, calibFile, oiDiam, oiTarget;
  }

  /* Search for the diameters in catalogs. Note that only stars not
     already in oiDiam will be updated. */
  oiFitsLoadOiDiamFromCatalogs, oiTarget, oiDiam, overwrite=0,
    catalogsDir=catalogsDir;

  /* Here I can run the getstar if needed, to avoid the
     JSDC faint catalog. Only for stars with no diameters so far. */
  // yocoLogInfo,"SKIP JMMC !!!";
  pndrsUpdateOiDiamFromGetStar, oiDiam, oiTarget;

  /* Update based on SCI/CAL in OBs name (taken from oiVis2).
     I run this hack only if file not existing so far (first run). */
  if ( !open(calibFile, "r", 1) )
  {
    pndrsUpdateOiDiamFromOBsName, oiDiam, oiTarget, oiVis2, oiLog;
  }
  
  /* Write results */
  oiFitsWriteOiDiam, calibFile, oiDiam, overwrite=1;

  /* Eventually remove PDF and past products */
  if (rmPdf==1) {
    yocoLogInfo,"Remove files from previous calibration (except oiDiam.fits)";
    system, "rm -rf *_SCI_* *_CAL_* *_TF_* *_effWaveCorr_* *_TFAAN_* *ummary*txt > /dev/null 2>&1";
    system, "rm -rf *oidataCalibrated* *oidataTf*> /dev/null 2>&1";
  }

  /* Write a full summary of the night */
  oiFitsListObs, oiVis2, oiTarget, oiArray, oiLog, oiDiam,
    dtime=1e-6, file=strRoot+"_summaryFull.txt",filename=1,nameOB=3;
  
  /* Write a short summary of the night */
  oiFitsListObs, oiVis2, oiTarget, oiArray, oiLog, oiDiam,
    file=strRoot+"_summaryShort.txt",filename=1,nameOB=3;
  
  /* Write a very short summary of the night */
  oiFitsListObs, oiVis2, oiTarget, oiArray, oiLog, oiDiam,
    dtime=1.0, file=strRoot+"_summaryList.txt",filename=1,nameOB=3;

  /* Search for all possible script files */
  if ( yocoTypeIsStringScalar(inputScriptFile) && yocoTypeIsFile(inputScriptFile) ) {
    inputScriptFile = inputScriptFile(*)(1);
  } else if ( yocoTypeIsFile(strRoot+"_pndrsScript.i") ) {
    inputScriptFile = strRoot+"_pndrsScript.i";
  } else if ( yocoTypeIsFile(inputDir+"pndrsScript.i") ) {
    inputScriptFile = inputDir+"pndrsScript.i";
  } else {
    inputScriptFile = [];
    inputScriptCkSum = [];
  }
  

  /* Include script file and define its ID */
  if ( is_array(inputScriptFile) ) {
    ckSumNow = pndrsGetCkSum(inputScriptFile);
    if ( is_array(inputScriptCkSum) && inputScriptCkSum!=ckSumNow) {
      /* Not a valid checksum */
      yocoError,"Check ",inputScriptFile(*)(1);
      return 0;
    } else {
      yocoLogInfo,"Include script file:",inputScriptFile;
      include,inputScriptFile,3;
      yocoLogInfo,"Script done.";
      inputScriptCkSum = ckSumNow;
    }
  } else {
    yocoLogInfo,"No script to load";
  }
  
  /* Remove observations for which all spectral channels are flagged */
  oiFitsCleanFlag, oiVis2, oiVis, oiT3;

  /* Remove Internal */
  yocoLogInfo,"Remove obs of INTERNAL source";
  oiFitsKeepTargets, oiTarget, oiVis2, oiVis, oiT3,
    trgList=["INTERNAL"],invers=1;

  /* Average files if needed */
  if (averageFiles) {
    oiFitsGroupAllOiData, oiVis2, oiVis, oiT3, oiLog, dtime=6./24./60.;
  }
  
  /* Calibrate the night setup by setup, so that the data and dependencies,
     can be better handled */
  lstSetup = pndrsGetAllSetup(oiLog, oiVis2, oiT3);
  oiVis2Cal = oiVis2Tfp = oiVis2Tfe = [];
  oiVisCal = oiVisTfp = oiVisTfe = [];
  oiT3Cal = oiT3Tfp = oiT3Tfe = [];

  
  /* Loop on setups */
  for (s=1;s<=numberof(lstSetup);s++) {
    yocoLogInfo,"****";
    yocoLogInfo,"Calibrate data for setup #"+pr1(s)+" over "+pr1(numberof(lstSetup)),lstSetup(s);

    /* Copy arrays and keep only this setup */
    oiFitsCopyArrays, oiVis2, oVis2, oiT3, oT3;
    oiFitsKeepSetup, oiLog, oVis2, oT3, setupList=lstSetup(s);

    if (numberof(oVis2)==0) { yocoLogInfo,"No data for this setup, continue...";continue; }
    
    /* Calibrate the data for this setup */
    oiFitsCalibrateNight, oVis2,oT3,oVis,oiWave,oiArray,oiTarget,oiLog,oiDiam,
      oVis2Cal,oVisCal,oT3Cal,oVis2Tfp,oVisTfp,oT3Tfp,oVis2Tfe,oVisTfe,oT3Tfe,
      vis2TfMode=vis2TfMode,t3TfMode=t3TfMode,visTfMode=visTfMode,
      vis2TfParam=vis2TfParam,t3TfParam=t3TfParam,visTfParam=visTfParam,
      vis2TfErrMode=vis2TfErrMode,t3TfErrMode=t3TfErrMode,visTfErrMode=visTfErrMode;
    
    /* Clean data from dummies. */
    oiFitsCleanDataFromDummy, oVis2Cal, oT3Cal, oVisCal,
      maxVis2Err=maxVis2Err, maxT3PhiErr=maxT3PhiErr;

    /* Grow to get the entire night somwhere */
    yocoLogTrace,"Grow...";
    grow, oiVis2Cal, oVis2Cal; grow, oiT3Cal, oT3Cal; grow, oiVisCal, oVisCal;
    grow, oiVis2Tfp, oVis2Tfp; grow, oiT3Tfp, oT3Tfp; grow, oiVisTfp, oVisTfp;
    grow, oiVis2Tfe, oVis2Tfe; grow, oiT3Tfe, oT3Tfe; grow, oiVisTfe, oVisTfe;
    
    /* Loop on the setup to plot the TF per setup and per bins.
       This is the best to assess the data quality precisely.
       The routine produces PDF. */
    pndrsPlotTfForAllChannels, oiWave, oiTarget, oiArray, oiLog, oVis2, oT3, oVis,
      oVis2Cal, oT3Cal, oVisCal, oVis2Tfe, oT3Tfe, oVisTfe, oVis2Tfp, oT3Tfp, oVisTfp,
      strRoot=strRoot+"_TF_",strInfo=swrite(format="setup%02d",s);

    yocoLogInfo,"Wait for 3s for plots to be written...";
    pause,3000;
    
    /* Write TF estimates according to OBs execution (TPL START) */
    pndrsWriteFilesAccordingToTplStart, inputDir+"/", oiTarget,oiWave,oiArray,oVis2Tfp,
      oVisTfp,oT3Tfp,oiLog,overwrite=1, append="Tf", proCatg="CALIB_OIDATA_TF",
      inputScriptFile=inputScriptFile, inputScriptCkSum=inputScriptCkSum;
    
    /* Build the list of files for this setup,
       to add in the output FITS */
    rawFiles = yocoListClean( pndrsGetFileWithExt( oiFitsGetOiLog(oVis2,oiLog).fileName ) );

    /* Build the list of association files for this setup,
       to add in the output FITS */
    channel  = max( numberof(*oVis2(1).vis2Data) / 2, 1);
    assFiles = pndrsGetFileWithExt( strRoot+["_TF_vis2_","_TF_t3phi_"]+swrite(format="setup%02d_bin%02d.pdf",s,channel) );
    yocoLogInfo,"AssFiles:", assFiles;
    
    /* Write SCIENCE calibrated science according to OBs execution (TPL START).
       Here I can easily make reference to the plots produced above...
       And I can have a list of calibration star used, or the list of calibration file
       used... */
    oiFitsKeepScience, oVis2Cal, oVisCal, oT3Cal, oiDiam;
    pndrsWriteFilesAccordingToTplStart, inputDir+"/", oiTarget,oiWave,oiArray,oVis2Cal,
      oVisCal,oT3Cal,oiLog,overwrite=1, append="Calibrated", proCatg="TARGET_OIDATA_CALIBRATED",
      inputScriptFile=inputScriptFile, inputScriptCkSum=inputScriptCkSum,
      rawFiles=rawFiles, assFiles=assFiles;
  }
  /* End loop on setups... */


  
  /* Write all the TF estimates into a single file too */
  oiFitsWriteFiles,strRoot+"_ALL_oidataTf.fits",oiTarget,oiWave,oiArray,
    oiVis2Tfp,oiVisTfp,oiT3Tfp,oiLog,overwrite=1;

  /* Write all the calibrated data into a single file */
  if ( is_array(oiVis2Cal) || is_array(oiT3Cal) )
    oiFitsWriteFiles,strRoot+"_ALL_oidataCalibrated.fits",oiTarget,oiWave,oiArray,
      oiVis2Cal,oiVisCal,oiT3Cal,oiLog,overwrite=1;
  else
    yocoLogInfo,"Cannot write oidataCalibrated.fits: no calibrated science stars";

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+inputDir+"/"+"*oidataCalibrated*fits > /dev/null 2>&1";
  system,"chmod ug+w "+inputDir+"/"+"*oidataTf*fits > /dev/null 2>&1";



  

  /* Write a summary with all science stars that
     have been properly calibrated */
  if ( is_array(oiVis2Cal) &&
       is_array((id = where( oiFitsGetIsCal(oiVis2Cal, oiDiam)==0 ))) )
    {
      oiFitsListObs, oiVis2Cal(id), oiTarget, oiArray, oiLog, oiDiam,
        dtime=1, file=strRoot+"_summaryScience.txt",date=1;
    }
  else
    yocoLogInfo,"Cannot write summaryScience.txt: no calibrated science stars";

  
  /* Plot the calibrated night in a spectral bin
     that should be shared by all possible setups, and write these PDF */
  oiFitsPlotCalibratedNight, oiWave, oiArray, oiLog, oiTarget, oiDiam,
    oiVis2, oiVis2Cal, oiVis2Tfe, oiVis2Tfp,
    oiT3, oiT3Cal, oiT3Tfe, oiT3Tfp,
    oiVis, oiVisCal, oiVisTfe, oiVisTfp,Avg=Avg0;
  if (is_array(oiVis2)) {pndrsSavePdf,1,strRoot+"_TF_vis2_lbdBinAvg.pdf";}
  if (is_array(oiT3))   {pndrsSavePdf,3,strRoot+"_TF_t3phi_lbdBinAvg.pdf";}
  if (is_array(oiVis2)) {pndrsSavePdf,4,strRoot+"_TF_uv.pdf";}
  if (is_array(oiVis))  {pndrsSavePdf,5,strRoot+"_TF_vis_lbdBinAvg.pdf";}
  if (is_array(oiVis2)) {pndrsSavePdf,6,strRoot+"_TF_altaz.pdf";}

  
  /* Loop on all stars to write all of them in a different file */
  allStars = oiTarget;
  // yocoLogInfo,"Skip the production of output per target";
  for ( i=1 ; i<=numberof(allStars) ; i++ ) {

    /* Get the name */
    name = allStars(i).target;
    yocoLogInfo,"Make a summary for target: "+name+" ("+pr1(i)+" over "+pr1(numberof(allStars))+")";

    /* This is most probably the internal source, so no need to
       produce the PDF for this one */
    if (name=="INTERNAL") continue;

    /* Copy arrays and keep only this target */
    oiFitsCopyArrays, oiTarget, oTarget, oiVis2Cal, oVis2, oiVisCal,
      oVis, oiT3Cal, oT3, oiArray, oArray, oiWave, oWave, oiLog, oLog;
    oiFitsKeepTargets, oTarget, oVis2, oVis, oT3, trgList=name;

    /* Clean the arrays and check if something remains */
    oiFitsCleanFlag, oVis2, oVis, oT3;
    if (is_void(oT3) && is_void(oVis2)) {
      yocoLogInfo,"No valid data for this target... skip.";
      continue;
    }

    /* Write the file */
    name  = ( oiFitsGetIsCal(allStars(i), oiDiam) ? "CAL_" : "SCI_" )+name;
    title = yocoStrReplace(strRoot0+"_"+name,["_"],["!_"]);
    oiFitsWriteFiles,strRoot+"_"+name+"_oidataCalibrated.fits",oTarget,oWave,oArray,oVis2,,oT3,oLog,overwrite=1;
    
    /* Plot the UV plane */
    if (is_array(oVis2)) {
      yocoLogTrace,"Plot all UV";
      winkill,10; window,10,style="boxed.gs";
      oiFitsPlotUV, oVis2, oiWave, symbol=4,size=0.75,color="red",fill=0,unit="mum";
      gridxy,2,2;
      limits,square=1;
      xytitles,"East (M!l) ->","North (M!l) -> ";
      pltitle,title;
      /* Add some circles */
      pts = exp(2.i*pi * span(0,1,1000)) * [10,20,40,60,80,100](-,);
      yocoPlotPlgMulti, pts.im, pts.re, type=3;
      pndrsSavePdf,10,strRoot+"_"+name+"_uv.pdf";
    }
    
    /* Plot the Vis2 */
    if (is_array(oVis2)) {
      yocoLogTrace,"Plot all oiVis2";
      winkill,10; yocoNmCreate,10,1,landscape=1,fx=1,fy=1;
      oiFitsPlotOiData, oVis2, oiWave, "base", symbol=0;
      oiFitsPlotOiData, oVis2, oiWave, "base", symbol=4,size=0.75,errFlag=0,color="red",fill=0;
      limits; l = limits();
      limits,0,1.05*l(2),0.0,1.1;
      gridxy,0,1;
      xytitles,"Base (M!l)","vis2 (%)";
      pltitle,title;
      plt,"+",1.03,0.72,tosys=0,height=1;
      pndrsSavePdf,10,strRoot+"_"+name+"_vis2_base.pdf";
    }
    
    /* Plot the t3 */
    if (is_array(oT3)) {
      yocoLogTrace,"Plot all oiT3";
      winkill,10; yocoNmCreate,10,1,landscape=1,fx=1,fy=1;
      oiFitsPlotOiData, oT3, oiWave, "base", symbol=0;
      oiFitsPlotOiData, oT3, oiWave, "base", symbol=4,size=0.75,errFlag=0,color="red",fill=0;
      xytitles,"Base (M!l)","t3phi (deg)";
      pltitle,title;
      limits; l = limits();
      limits, l(1)-0.05*(l(2)-l(1)), l(2)+0.05*(l(2)-l(1)), max(-200,l(3)-5),min(200,l(4)+5);
      gridxy,0,1,base60=2;
      plt,"+",1.03,0.72,tosys=0,height=1;
      pndrsSavePdf,10,strRoot+"_"+name+"_t3phi_base.pdf";
    }

    /* Change permission of all these newly created files */
    system,"chmod ug+w "+strRoot+"_* > /dev/null 2>&1";
  }
  
  yocoLogTrace,"pndrsCalibrateAllOiData done";
  yocoLogSetFile;
  return 1;
}

/* ********************************************************************* */

func pndrsCalibrateAllOiDataOrg(inputDir=,catalogsDir=,inputScriptFile=,inputScriptCkSum=,rmPdf=)
/* DOCUMENT pndrsCalibrateAllOiDataOrg(inputDir=,catalogsDir=,inputScriptFile=,rmPdf=)

   DESCRIPTION
   Calibrate the oiData contained in inputDir and create:
   - PDF with the transfer function plot
   - a OIFITS file with all calibrated data (SCI and CAL)
   - several OIFITS, one per SCI, with calibrated data.

   PARAMETERS:
   - inputScriptFile is the (optional) name of the yorick script
   that will be executed by the function just before calling
   oiFitsCalibrateNight. It can be used to make some filtering,
   grouping, removing part of the night... or any advance
   operation on the structures oiVis2, oiT3, oiVis, oiArray and
   oiTarget.

   If inputScriptFile is not define, the function will load
   "pndrsScript.i" if it exists.
 */
{
  yocoLogInfo,"pndrsCalibrateAllOiDataOrg()";
  local strRoot,i,calibFile, name, l, allStars;
  local vis2TfMode, t3TfMode, vis2TfErrMode, t3TfErrMode, t3TfParam, vis2TfParam;
  local oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog, oiDiam;
  local Avg, maxVis2Err, maxT3PhiErr;
  
  /* Default */
  maxVis2Err  = 0.25;
  maxT3PhiErr = 20.0;
  vis2TfMode  = 1;
  t3TfMode    = 1;
  Avg0 = [[1.637,1.715],[2.04,2.25]];
  
  /* Check the argument and go into this directory */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
    yocoError,"Check argument of pndrsCalibrateAllOiData";
    return 0;
  }
  
  /* Find a root for the files that are created. Take the part of the
     input directory name that is before _ (if any) */
  strRoot0 = yocoStrSplit(yocoFileSplitName(strpart(inputDir,:-1)),"_")(1);
  strRoot  = inputDir+"/"+strRoot0;

  /* Default for file with calibration stars */
  calibFile = strRoot+"_oiDiam.fits";
  
  /* Set a logging file */
  yocoLogSetFile, strRoot+"_log.txt", overwrite=1;

  /* Catch errors */
  if ( catch(0x01+0x02+0x08) ) {
    yocoError,"pndrsCalibrateAllOiData catch: "+catch_message,,1;
    yocoLogSetFile;
    return 0;
  }

  /* Load all the OIDATA files. FIXME: Actually would be better
     to use the DPR.CATG parameters. Note: do not load the oiVis
     because this quantity is not understood so far */
  oiFitsLoadFiles,inputDir+"/PION*oidata.fits", oiTarget, oiWave, oiArray,
    oiVis2, , oiT3, oiLog,
    shell=1, readMode=-1;

  /* Check if observations have been loaded */
  if ( !is_array(oiTarget) ) {
    yocoLogWarning,"No reduced TARGET_OIDATA_RAW (*oidata.fits)";
    yocoLogSetFile;
    return 1;
  }

  /* Some cleaning */
  oiFitsCleanDataFromDummy, oiVis2, oiT3, oiVis,
    maxVis2Err=maxVis2Err, maxT3PhiErr=maxT3PhiErr,
    minBaseLength=-1;

  /* This is a hack to deal with the fact that the star names may have changed:
     update the names in oiTarget */
  oiTarget.target = pndrsCheckTargetInList(oiTarget.target);
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
  
  
  /* This is a hack to deal with the fact that the star names may have changed:
     Open the calibFile, update names and re-write it... */
  if ( open(calibFile, "r", 1) )
  {
    oiFitsLoadOiDiam, calibFile, oiDiam;
    oiDiam.target = pndrsCheckTargetInList(oiDiam.target);
    oiFitsWriteOiDiam, calibFile, oiDiam, overwrite=1;
  }

  /* Load current oiLogFile if it exists */
  oiDiam = [];
  if ( open(calibFile, "r", 1) )
  {
    oiFitsLoadOiDiam, calibFile, oiDiam, oiTarget;
  }

  /* Search for the diameters in catalogs. Note that only stars not
     already in oiDiam will be updated. */
  oiFitsLoadOiDiamFromCatalogs, oiTarget, oiDiam, overwrite=0,
    catalogsDir=catalogsDir;

  /* Here I can run the getstar if needed, to avoid the
     JSDC faint catalog. Only for stars with no diameters so far. */
  pndrsUpdateOiDiamFromGetStar, oiDiam, oiTarget;

  /* Update based on SCI/CAL in OBs name (taken from oiVis2).
     I run this hack only if file not existing so far (first run). */
  if ( !open(calibFile, "r", 1) )
  {
    pndrsUpdateOiDiamFromOBsName, oiDiam, oiTarget, oiVis2, oiLog;
  }
  
  /* Write results */
  oiFitsWriteOiDiam, calibFile, oiDiam, overwrite=1;

  /* Eventually remove PDF and past products */
  if (rmPdf==1) {
    yocoLogInfo,"Remove files from previous calibration (except oiDiam.fits)";
    system, "rm -rf *_SCI_* *_CAL_* *_TF_* *_effWaveCorr_* *_TFAAN_* *ummary*txt > /dev/null 2>&1";
    system, "rm -rf *oidataCalibrated* *oidataTf*> /dev/null 2>&1";
  }

  /* Write a full summary of the night */
  oiFitsListObs, oiVis2, oiTarget, oiArray, oiLog, oiDiam,
    dtime=1e-6, file=strRoot+"_summaryFull.txt",filename=1,nameOB=3;
  
  /* Write a short summary of the night */
  oiFitsListObs, oiVis2, oiTarget, oiArray, oiLog, oiDiam,
    file=strRoot+"_summaryShort.txt",filename=1,nameOB=3;
  
  /* Write a very short summary of the night */
  oiFitsListObs, oiVis2, oiTarget, oiArray, oiLog, oiDiam,
    dtime=1.0, file=strRoot+"_summaryList.txt",filename=1,nameOB=3;

  /* Search for all possible script files */
  if ( yocoTypeIsStringScalar(inputScriptFile) && yocoTypeIsFile(inputScriptFile) ) {
    inputScriptFile = inputScriptFile(*)(1);
  } else if ( yocoTypeIsFile(strRoot+"_pndrsScript.i") ) {
    inputScriptFile = strRoot+"_pndrsScript.i";
  } else if ( yocoTypeIsFile(inputDir+"pndrsScript.i") ) {
    inputScriptFile = inputDir+"pndrsScript.i";
  } else {
    inputScriptFile = [];
    inputScriptCkSum = [];
  }
  

  /* Include script file and define its ID */
  if ( is_array(inputScriptFile) ) {
    ckSumNow = pndrsGetCkSum(inputScriptFile);
    if ( is_array(inputScriptCkSum) && inputScriptCkSum!=ckSumNow) {
      /* Not a valid checksum */
      yocoError,"Check ",inputScriptFile(*)(1);
      return 0;
    } else {
      yocoLogInfo,"Include script file:",inputScriptFile;
      include,inputScriptFile,3;
      yocoLogInfo,"Script done.";
      inputScriptCkSum = ckSumNow;
    }
  } else {
    yocoLogInfo,"No script to load";
  }
  
  /* Remove observations for which all spectral channels are flagged */
  oiFitsCleanFlag, oiVis2, oiVis, oiT3;

  /* Calibrate the data setup by setup */
  oiFitsCalibrateNight, oiVis2,oiT3,oiVis,oiWave,oiArray,oiTarget,oiLog,oiDiam,
    oiVis2Cal,oiVisCal,oiT3Cal,oiVis2Tfp,oiVisTfp,oiT3Tfp,oiVis2Tfe,oiVisTfe,oiT3Tfe,
    vis2TfMode=vis2TfMode,t3TfMode=t3TfMode,visTfMode=visTfMode,
    vis2TfParam=vis2TfParam,t3TfParam=t3TfParam,visTfParam=visTfParam,
    vis2TfErrMode=vis2TfErrMode,t3TfErrMode=t3TfErrMode,visTfErrMode=visTfErrMode;

  /* Clean data from dummies. */
  oiFitsCleanDataFromDummy, oiVis2Cal, oiT3Cal, oiVisCal,
    maxVis2Err=maxVis2Err, maxT3PhiErr=maxT3PhiErr;
  
  
  /* Write SCIENCE calibrated science according to OBs execution (TPL START) */
  oiFitsCopyArrays, oiTarget, oTarget, oiVis2Cal, oVis2, oiVisCal,
    oVis, oiT3Cal, oT3, oiArray, oArray, oiWave, oWave, oiLog, oLog;
  
  oiFitsKeepScience, oVis2, oVis, oT3, oiDiam;
  pndrsWriteFilesAccordingToTplStart, inputDir+"/", oiTarget,oiWave,oiArray,oVis2,
    oVis,oT3,oLog,overwrite=1, append="Calibrated", proCatg="TARGET_OIDATA_CALIBRATED",
    inputScriptFile=inputScriptFile, inputScriptCkSum=inputScriptCkSum;

  /* Write TF estimates according to OBs execution (TPL START) */
  pndrsWriteFilesAccordingToTplStart, inputDir+"/", oiTarget,oiWave,oiArray,oiVis2Tfp,
    oiVisTfp,oiT3Tfp,oiLog,overwrite=1, append="Tf", proCatg="CALIB_OIDATA_TF",
    inputScriptFile=inputScriptFile, inputScriptCkSum=inputScriptCkSum;

  /* Write all the TF estimates into a single file too */
  oiFitsWriteFiles,strRoot+"_ALL_oidataTf.fits",oiTarget,oiWave,oiArray,
    oiVis2Tfp,oiVisTfp,oiT3Tfp,oiLog,overwrite=1;

  /* Write all the calibrated data into a single file */
  if ( is_array(oiVis2Cal) || is_array(oiT3Cal) )
    oiFitsWriteFiles,strRoot+"_ALL_oidataCalibrated.fits",oiTarget,oiWave,oiArray,
      oiVis2Cal,oiVisCal,oiT3Cal,oiLog,overwrite=1;
  else
    yocoLogInfo,"Cannot write oidataCalibrated.fits: no calibrated science stars";

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+inputDir+"/"+"*oidataCalibrated*fits > /dev/null 2>&1";
  system,"chmod ug+w "+inputDir+"/"+"*oidataTf*fits > /dev/null 2>&1";

  

  /* Write a summary with all science stars that
     have been properly calibrated */
  if ( is_array(oiVis2Cal) &&
       is_array((id = where( oiFitsGetIsCal(oiVis2Cal, oiDiam)==0 ))) )
    {
      oiFitsListObs, oiVis2Cal(id), oiTarget, oiArray, oiLog, oiDiam,
        dtime=1, file=strRoot+"_summaryScience.txt",date=1;
    }
  else
    yocoLogInfo,"Cannot write summaryScience.txt: no calibrated science stars";

  
  /* Plot the calibrated night in a spectral bin
     that should be shared by all possible setups, and write these PDF */
  oiFitsPlotCalibratedNight, oiWave, oiArray, oiLog, oiTarget, oiDiam,
    oiVis2, oiVis2Cal, oiVis2Tfe, oiVis2Tfp,
    oiT3, oiT3Cal, oiT3Tfe, oiT3Tfp,
    oiVis, oiVisCal, oiVisTfe, oiVisTfp,Avg=Avg0;
  if (is_array(oiVis2)) {pndrsSavePdf,1,strRoot+"_TF_vis2_lbdBinAvg.pdf";}
  if (is_array(oiT3))   {pndrsSavePdf,3,strRoot+"_TF_t3phi_lbdBinAvg.pdf";}
  if (is_array(oiVis2)) {pndrsSavePdf,4,strRoot+"_TF_uv.pdf";}
  if (is_array(oiVis))  {pndrsSavePdf,5,strRoot+"_TF_vis_lbdBinAvg.pdf";}
  if (is_array(oiVis2)) {pndrsSavePdf,6,strRoot+"_TF_altaz.pdf";}

  /* Loop on the setup to plot the TF per setup and per bins.
     This is the best to assess the data quality precisely.
     The routine produces PDF */
  pndrsPlotTfForAllSetups, oiWave, oiTarget, oiArray, oiLog, oiVis2, oiT3, oiVis,
    oiVis2Cal, oiT3Cal, oiVisCal, oiVis2Tfe, oiT3Tfe, oiVisTfe, oiVis2Tfp, oiT3Tfp, oiVisTfp,
    strRoot=strRoot+"_TF";

  
  /* Loop on all stars to write all of them in a different file */
  allStars = oiTarget;
  for ( i=1 ; i<=numberof(allStars) ; i++ ) {

    /* Get the name */
    name = allStars(i).target;
    yocoLogInfo,"Make a summary for target: "+name+" ("+pr1(i)+" over "+pr1(numberof(allStars))+")";

    /* This is most probably the internal source, so no need to
       produce the PDF for this one */
    if (name=="INTERNAL") continue;

    /* Copy arrays and keep only this target */
    oiFitsCopyArrays, oiTarget, oTarget, oiVis2Cal, oVis2, oiVisCal,
      oVis, oiT3Cal, oT3, oiArray, oArray, oiWave, oWave, oiLog, oLog;
    oiFitsKeepTargets, oTarget, oVis2, oVis, oT3, trgList=name;

    /* Clean the arrays and check if something remains */
    oiFitsCleanFlag, oVis2, oVis, oT3;
    if (is_void(oT3) && is_void(oVis2)) {
      yocoLogInfo,"No valid data for this target... skip.";
      continue;
    }

    /* Write the file */
    name  = ( oiFitsGetIsCal(allStars(i), oiDiam) ? "CAL_" : "SCI_" )+name;
    title = yocoStrReplace(strRoot0+"_"+name,["_"],["!_"]);
    oiFitsWriteFiles,strRoot+"_"+name+"_oidataCalibrated.fits",oTarget,oWave,oArray,oVis2,,oT3,oLog,overwrite=1;
    
    /* Plot the UV plane */
    if (is_array(oVis2)) {
      yocoLogTrace,"Plot all UV";
      winkill,10; window,10,style="boxed.gs";
      oiFitsPlotUV, oVis2, oiWave, symbol=4,size=0.75,color="red",fill=0,unit="mum";
      gridxy,2,2;
      limits,square=1;
      xytitles,"East (M!l) ->","North (M!l) -> ";
      pltitle,title;
      /* Add some circles */
      pts = exp(2.i*pi * span(0,1,1000)) * [10,20,40,60,80,100](-,);
      yocoPlotPlgMulti, pts.im, pts.re, type=3;
      pndrsSavePdf,10,strRoot+"_"+name+"_uv.pdf";
    }
    
    /* Plot the Vis2 */
    if (is_array(oVis2)) {
      yocoLogTrace,"Plot all oiVis2";
      winkill,10; yocoNmCreate,10,1,landscape=1,fx=1,fy=1;
      oiFitsPlotOiData, oVis2, oiWave, "base", symbol=0;
      oiFitsPlotOiData, oVis2, oiWave, "base", symbol=4,size=0.75,errFlag=0,color="red",fill=0;
      limits; l = limits();
      limits,0,1.05*l(2),0.0,1.1;
      gridxy,0,1;
      xytitles,"Base (M!l)","vis2 (%)";
      pltitle,title;
      plt,"+",1.03,0.72,tosys=0,height=1;
      pndrsSavePdf,10,strRoot+"_"+name+"_vis2_base.pdf";
    }
    
    /* Plot the t3 */
    if (is_array(oT3)) {
      yocoLogTrace,"Plot all oiT3";
      winkill,10; yocoNmCreate,10,1,landscape=1,fx=1,fy=1;
      oiFitsPlotOiData, oT3, oiWave, "base", symbol=0;
      oiFitsPlotOiData, oT3, oiWave, "base", symbol=4,size=0.75,errFlag=0,color="red",fill=0;
      xytitles,"Base (M!l)","t3phi (deg)";
      pltitle,title;
      limits; l = limits();
      limits, l(1)-0.05*(l(2)-l(1)), l(2)+0.05*(l(2)-l(1)), max(-200,l(3)-5),min(200,l(4)+5);
      gridxy,0,1,base60=2;
      plt,"+",1.03,0.72,tosys=0,height=1;
      pndrsSavePdf,10,strRoot+"_"+name+"_t3phi_base.pdf";
    }

    /* Change permission of all these newly created files */
    system,"chmod ug+w "+strRoot+"_* > /dev/null 2>&1";
  }

  
  yocoLogTrace,"pndrsCalibrateAllOiDataOrg done";
  yocoLogSetFile;
  return 1;
}

func pndrsWriteFilesAccordingToTplStart(dir,oiTarget,oiWave,oiArray,oiVis2,oiVis,oiT3,oiLog,
                                        overwrite=, append=, proCatg=,
                                        inputScriptFile=,
                                        inputScriptCkSum=, rawFiles=, assFiles=)
/* DOCUMENT pndrsWriteFilesAccordingToTplStart(dir,oiTarget,oiWave,oiArray,oiVis2,oiVis,oiT3,oiLog,overwrite=)

   DESCRIPTION
   Write the data according to the TPL.START keyword (one output file per start time), so that the data
   are grouped per template execution. All the information about phase3 are also written, so this function
   is done to writte SCIENCE READY data, or should be adapted.

   NOTES:
   The PROV files (provenance ARC files) are all the oiLog.arcFile whith the same tplStart time than the
   observations. Thus, if the data have been merged but the oiLog remains complete, all original ARC
   files will be propagated.

   PARAMETERS
   - dir: directory to output the files
   ...
 */
{
  yocoLogInfo, "pndrsWriteFilesAccordingToTplStart()";
  
  local tplVis2, tplT3, tplVis;
  
  /* Found the groups of execution based on the starting time of the template */
  oiLog = oiLog( sort(oiLog.mjdObs) );
  tplStart = yocoListClean( oiLog.tplStart );

  if (numberof(oiVis2)==0) {
    yocoLogInfo,"No data to write";
    return 1;
  }
  
  /* To speed up */
  if ( is_array(oiVis2) ) tplVis2 = oiFitsGetOiLog(oiVis2, oiLog).tplStart;
  if ( is_array(oiT3) )   tplT3   = oiFitsGetOiLog(oiT3, oiLog).tplStart;
  if ( is_array(oiVis) )  tplVis  = oiFitsGetOiLog(oiVis, oiLog).tplStart;

  /* Loop on template */
  for ( i=1 ; i<=numberof(tplStart) ; i++) {
    
    /* The last header sorted by time */
    oVis2 = oT3 = oVis = [];
    oLog  = oiLog( where(oiLog.tplStart == tplStart(i) )(0) );

    /* This should be the PRO.CATG */
    oLog.proCatg = proCatg;

    /* Keep only data matching this tplStart */
    if ( is_array(tplVis2) ) oVis2 = oiVis2( where(tplVis2 == tplStart(i)) );
    if ( is_array(oVis2) )   oVis2.hdr.logId = oLog.logId;
    if ( is_array(tplVis) )  oVis = oiVis( where(tplVis == tplStart(i)) );
    if ( is_array(oVis) )    oVis.hdr.logId = oLog.logId;
    if ( is_array(tplT3) )   oT3 = oiT3( where(tplT3 == tplStart(i)) );
    if ( is_array(oT3) )     oT3.hdr.logId = oLog.logId;
    if ( is_void(oVis2) ) { yocoLogTrace,"No Vis2 data, continue"; continue; }

    /* Write the file with PHASE3 keywords.
     * Assume oVis2 does exist */
    yocoFileSplitName, oLog.fileName,, name;
    name  = dir + name + append + ".fits";

    oiFitsWriteFile,name,oiTarget,oiWave,oiArray,oVis2,oVis,oT3,oLog,
        overwrite=overwrite,clean=1, funcLog=pndrsWritePnrLog;
    
    /* Add PHASE3 info */
    arcFiles = oiLog( where(oiLog.tplStart == tplStart(i) ) ).arcFile;
    pndrsUpdateFileWithPhase3, name, arcFiles, assFiles;

    /* Re-open to update HEADER */
    fh = cfitsio_open(name,"a");
    cfitsio_goto_hdu, fh, 1;
    
    /* Add the DRS parameters, many assumption here !!! */
    yocoLogTrace,"Add the DRS keywords";
    cfitsio_set,fh,"HIERARCH ESO PRO REC2 ID","pndrsCalibrateAllOiData";
    cfitsio_set,fh,"HIERARCH ESO PRO REC2 VERSION",pndrsVersion,"pndrs version";
    for (f=1;f<=numberof(rawFiles);f++)
      cfitsio_set,fh,"HIERARCH ESO PRO REC2 RAW"+pr1(f)+" NAME", rawFiles(f);
    cfitsio_set,fh,"HIERARCH ESO PRO REC2 PARAM1 NAME","-mode";
    cfitsio_set,fh,"HIERARCH ESO PRO REC2 PARAM1 VALUE","global";
    if ( is_array(inputScriptFile) ) {
      cfitsio_set,fh,"HIERARCH ESO PRO REC2 PARAM2 NAME","-inputScriptFile";
      cfitsio_set,fh,"HIERARCH ESO PRO REC2 PARAM2 VALUE",pndrsGetFileWithExt(inputScriptFile);
    }
    if ( is_array(inputScriptCkSum) ) {
      cfitsio_set,fh,"HIERARCH ESO PRO REC2 PARAM3 NAME","-inputScriptCkSum";
      cfitsio_set,fh,"HIERARCH ESO PRO REC2 PARAM3 VALUE",inputScriptCkSum;
    }

    cfitsio_close,fh;
  }
  /* End loop on template */
  
  yocoLogTrace, "pndrsWriteFilesAccordingToTplStart done";
  return 1;
}

/* ************************************************************ */

func pndrsUpdateFileWithPhase3 (inputFile,arcFiles,assFiles)
{
  yocoLogInfo, "pndrsUpdateFileWithPhase3()";

  /* Load files */
  oiFitsLoadFiles, inputFile, , oiWave, , oVis2, ,oT3, oLog, clean=0;
  lbd  = *oiFitsGetOiWave(oVis2(1),oiWave).effWave * 1e9;
  elbd = *oiFitsGetOiWave(oVis2(1),oiWave).effBand * 1e9;
  oLog = oLog(1);

  /* Get the directory of the file */
  yocoFileSplitName, inputFile, dir;
  
  /* Re-open to update HEADER */
  fh = cfitsio_open(inputFile,"a");
  cfitsio_goto_hdu, fh, 1;

  /* Add the PHASE-3 keywords -- rely on existing oiVis2 */
  yocoLogTrace,"Add the phase-3 keywords";
  cfitsio_set,fh,"REFERENC","2011A&A...535A..67L","Description of software";
  cfitsio_set,fh,"INSMODE", pndrsGetPrism(oLog)+"_"+pndrsGetBand(oLog),"Instrument mode";
  cfitsio_set,fh,"TIMESYS", "UTC";
  cfitsio_set,fh,"EXPTIME", (oVis2.intTime)(avg),"[s] Integration time";
  cfitsio_set,fh,"TEXPTIME", (oVis2.intTime)(max),"[s] Integration time";
  cfitsio_set,fh,"M_EPOCH", char(0), "TRUE if multiple epochs";
  cfitsio_set,fh,"MJD-OBS", min(oVis2.mjd-oVis2.intTime/(2*3600*24)),"Start time of observations";
  cfitsio_set,fh,"MJD-END", max(oVis2.mjd+oVis2.intTime/(2*3600*24)),"End of observations";
  cfitsio_set,fh,"PROG_ID", oLog.progId,"ESO programme identification";
  cfitsio_set,fh,"OBID1", oLog.obsId,"Observation block ID";
  cfitsio_set,fh,"PROCSOFT", "pndrs_v"+pndrsVersion,"Data reduction software and version";
  if (strmatch(oLog.proCatg,"TARGET")) cfitsio_set,fh,"PRODCATG", "SCIENCE.VISIBILITY","Data product category";
  else cfitsio_set,fh,"PRODCATG", "CALIB.VISIBILITY","Data product category";
  cfitsio_set,fh,"OBSTECH", "INTERFEROMETRY";
  base = oiFitsGetBaseLength(oVis2);
  cfitsio_set,fh,"BASE_MIN", min(base),"[m] Minimum baseline lenght";
  cfitsio_set,fh,"BASE_MAX", max(base),"[m] Maximum baseline lenght";
  cfitsio_set,fh,"WAVELMIN", min(lbd)-0.5*avg(elbd),"[nm] Minimum wavelength";
  cfitsio_set,fh,"WAVELMAX", max(lbd)+0.5*avg(elbd),"[nm] Maximum wavelength";
  cfitsio_set,fh,"SPECSYS", "TOPOCENT","Reference frame for spectral coordinates";
  cfitsio_set,fh,"SPEC_RES", avg(lbd) / avg(elbd),"Spectral resolution";
  cfitsio_set,fh,"SPEC_BIN", (numberof(lbd)>1?avg(lbd(dif)):0.0),"[nm] Average spectral coordinate bin size";
  cfitsio_set,fh,"SPEC_ERR", 0.005 * avg(lbd),"[nm] Statistical error in spectral coordinate";
  cfitsio_set,fh,"SPEC_SYE", 0.010 * avg(lbd),"[nm] Systematic error in spectral coordinate";
  cfitsio_set,fh,"NUM_CHAN", numberof(lbd),"Number of spectral channels";
  cfitsio_set,fh,"CONTENT", "OIFITS1";
  if ( is_array(oVis2) ) {
      v2err = oiFitsGetStructData(oVis2,"vis2Err")(where(oiFitsGetStructData(oVis2,"flag")==char(0)));
      v2err = ( is_array(v2err) ? median(v2err) : 9999.0);
      cfitsio_set,fh,"VIS2ERR", v2err, "Square Visibility error (median)";
  }
  if ( is_array(oT3)) {
      t3err = oiFitsGetStructData(oT3,"t3PhiErr")(where(oiFitsGetStructData(oT3,"flag")==char(0)));
      t3err = ( is_array(t3err) ? median(t3err) : 9999.0);
      cfitsio_set,fh,"T3PHIERR", t3err, "[deg] Closure phase error (median)";
  }

  /* Update arcFiles if provided */
  if ( is_array(arcFiles)) {
      cfitsio_set,fh,"NCOMBINE", numberof(arcFiles), "Number of combined raw science";
      for (f=1;f<=numberof(arcFiles);f++)
          cfitsio_set,fh,"PROV"+pr1(f), pndrsGetFileWithExt(arcFiles(f)), "Originating science ARCFILE";
  }

  /* Add the ASSON files */
  if ( is_array(assFiles)) {
      for (f=1;f<=numberof(assFiles);f++) {
          if (!yocoTypeIsFile (dir + assFiles(f))) {
              yocoLogInfo,"Following ASSON file doesn't exist:", assFiles(f);
              continue;
          }
          cfitsio_set,fh,"ASSON"+pr1(f), assFiles(f);
          cfitsio_set,fh,"ASSOC"+pr1(f), "ANCILLARY.PREVIEW";
          cfitsio_set,fh,"ASSOM"+pr1(f), pndrsBatchGetMd5(dir + assFiles(f)),"MD5 checksum";
      }
  }

  /* Check the MD5 of existing ASSON files */
  assFiles = cfitsio_get (fh, "ASSON*");
  if ( is_array(assFiles)) {
      for (f=1;f<=numberof(assFiles);f++) {
          if (!yocoTypeIsFile (dir + assFiles(f))) {
              yocoLogWarning,"Following ASSON file doesn't exist:", assFiles(f);
              continue;
          }
          md5 = pndrsBatchGetMd5(dir + assFiles(f));
          if (md5 != cfitsio_get (fh,"ASSOM"+pr1(f),default="0")) {
              yocoLogWarning,"MD5 of ASSON file doesn't match:", assFiles(f);
              cfitsio_set,fh,"ASSOM"+pr1(f), md5, "MD5 checksum";
          }
      }
  }

  /* Update header of OI_ARRAY */
  yocoLogInfo, "Update OI_ARRAY header";
  cfitsio_goto_hdu, fh, "OI_ARRAY";
  cfitsio_set,fh,"ARRAYX", 1945458.40719, "[m] array center";
  cfitsio_set,fh,"ARRAYY",-5464447.67009, "[m] array center";
  cfitsio_set,fh,"ARRAYZ",-2658804.58123, "[m] array center";

  /* Update CHECKSUM of every HDU */
  for (hdu=1; hdu<=cfitsio_get_num_hdus (fh); hdu++)
  {
      cfitsio_movabs_hdu, fh, hdu;
      cfitsio_write_chksum, fh;
  }
  
  cfitsio_close,fh;
  
  yocoLogInfo, "pndrsUpdateFileWithPhase3 done";
  return 1;
}

/* ********************************************************************* */

func pndrsRenameAllRawData(voidinputDir=)
/* DOCUMENT pndrsRenameAllRawData(inputDir=)

   DESCRIPTION
   Rename all raw observation data (PIONIER_OBS*fits) with a name
   based on the DATE-OBS:
   PIONIER_OBS_OBS210_0001.fits  ->  PIONIER.2011-07-29T18p56p43.414.fits

   This is similar than the ESO name accept that the
   ":" is replaced by "p".
 */
{
  /* Go in dir and list FILES */
  cd,inputDir;
  files = oiFitsListFiles("PIONIER_OBS*fits");

  /* Loop on files and rename them */
  for (i=1;i<=numberof(files);i++) {

    yocoFileSplitName, files(i),, name, ext;
    yocoLogInfo,"Rename "+name+" ("+pr1(i)+" over "+pr1(numberof(files))+")";

    /* Read the DATE */
    fh = cfitsio_open(name+ext);
    date = cfitsio_get(fh,"DATE-OBS");
    cfitsio_close,fh;

    input  = name+ext;
    output = "PIONIER."+strpart(date,:23)+ext;
    output = yocoStrReplace( output, ":", "p");

    /* Rename files */
    system,"mv "+input+" "+output;
    system,"chmod a-w "+output+" > /dev/null 2>&1";
  }

  return 1;
}

/* ********************************************************************* */

 func pndrsCheckAllObject(inputDir=)
/* DOCUMENT pndrsCheckAllObject(inputDir=)

   DESCRIPTION
   This is a faster version of pndrsCheckOiLog that works on FITS file
   directly. Usefull to check a directory. Actually it will display
   the possible errors in the FITS header but will not update the
   files.

   SEE ALSO: pndrsCheckOiLog
 */
{
  yocoLogInfo,"pndrsCheckAllObject()";
  extern pndrsTARGET_REPLACEMENT;
  
  /* Check the argument */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
     yocoError,"Check argument of pndrsCheckAllObjectName";
     return 0;
  }

  /* Go in dir and list FILES */
  files = oiFitsListFiles(inputDir+"/PION*fits");

  /* Start the loggin into a file */
  yocoLogSetFile, inputDir + "/pndrsCheckHeader_log.txt", overwrite=1;

  
  /* Loop on files and rename them */
  for (i=1;i<=numberof(files);i++) {
    
    /* Read the OBJECT */
    fh = cfitsio_open(files(i));
    object = strtrim( string(cfitsio_get(fh,"OBJECT")) );
    target = strtrim( string(cfitsio_get(fh,"HIERARCH ESO OBS TARG NAME")) );
    ra     = double(cfitsio_get(fh,"RA"));
    coura  = double(cfitsio_get(fh,"HIERARCH ESO COU GUID RA"));
    issra  = double(cfitsio_get(fh,"HIERARCH ESO ISS REF RA"));
    opti1  = strtrim(string(cfitsio_get(fh,"HIERARCH ESO INS OPTI1 NAME")));
    cfitsio_close,fh;
    old = target;

    /* If no name or internal calib, continue */
    if (object==string(0) && target==string(0)) continue;
    if (opti1 == "MIRROR") continue;

    /* Convert the ISS RA into degrees */
    issra = (["00000","0000","000","00","0",""])(strlen(pr1(int(issra)))) + swrite(format="%.5f",issra);
    issra = strpart(issra, 1:2)+":"+strpart(issra, 3:4)+":"+strpart(issra, 5:);
    issra = yocoStrTime(issra) / 12 * 180.0;

    /* If the RA difference is larger than 2min of angle */
    if ( abs(issra-ra)*60 > 2.0 ) {
      yocoLogWarning,"RA ("+pr1(ra)+") and ISS.REF.RA ("+pr1(issra)+") are inconsistent for TARG.NAME ("+target+"):", files(i);
    }

    /* Check consistency */
    if (object != target) {
      yocoLogWarning,"Inconsistency between OBJECT ("+object+") and TARG.NAME ("+target+"):", files(i);
    }

    /* Check if in the list */
    id = where(target==pndrsTARGET_REPLACEMENT(1,));
    if ( numberof(id)>0 ) {
      target = pndrsTARGET_REPLACEMENT(2,id(1));
      yocoLogInfo,"Object "+old+" should be written "+target+":", files(i);
    }
  }
  
  yocoLogInfo,"pndrsCheckAllObject done.";
  yocoLogSetFile;
  return 1;
}

/* ********************************************************************* */

func pndrsRemoveAllInspection(inputDir=)
{
  local i, inputRawFile, noinit;
  if ( is_void(overwrite) ) overwrite=0;
  yocoLogInfo,"pndrsRemoveAllInspection()";

  /* Check the argument */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
     yocoError,"Check argument of pndrsRemoveAllInspection";
    return 0;
  }

  /* Read the log */
  if ( !pndrsReadLog(inputDir, oiLogDir, overwrite=overwrite) ) {
    yocoError,"Cannot read the logFile.";
    return 0;
  }

  /* Look for the science files only to loop on them */
  idSci = where( pndrsGetShutters(,oiLogDir)=="1111" &
                 oiLogDir.scanStatus==1 &
                 oiLogDir.detSubwins<=24 );

  /* If nothing to be done */
  if ( numberof(idSci)<1 ) {
    yocoLogWarning,"No science (1111) data, exit";
    return 1;
  }

  /* Loop on science files */
  for ( i=1 ; i<=numberof(idSci) ; i++)
    {
      /* Some init */
      sel = answer = [];
      ids = idSci(i);
      inputRawFile = inputDir+"/"+oiLogDir(ids).fileName;
      
      /* Just a log */
      yocoLogInfo,"****";
      str = swrite(format="pndrsRemoveAllInspection is now working on file (%i over %i):",
                   i, numberof(idSci));
      yocoLogInfo, str, inputRawFile;

      /* Change permission (raw data are generally protected) */
      system,"chmod u+w "+inputRawFile;

      /* Open file and find number of hdu */
      fh = cfitsio_open(inputRawFile,"a");
  
      /* Find number of hdu */
      hdu = pndrsAsPnrSelTable(fh);
      if ( !is_array(hdu) ) {
        yocoLogInfo,"No PNDRS_SEL in file";
        continue;
      } else {
        yocoLogInfo,"Remove PNDRS_SEL in file";
        cfitsio_goto_hdu, fh, hdu;
        cfitsio_delete_hdu, fh;
      }

      /* Close the file */
      cfitsio_close,fh;

      /* Change permission (restore protection) */
      system,"chmod a-w "+inputRawFile+" > /dev/null 2>&1";
    }

  yocoLogInfo,"pndrsRemoveAllInspection done";
  return 1;
}

/* ********************************************************************* */

func pndrsSummaryAllOiData(inputFiles=,file=,dtime=)
/* DOCUMENT pndrsSummaryAllOiData(inputFiles=,file=,dtime=)

   DESCRIPTION
   Make a summary of all oiVis2.
   
   PARAMETERS

   EXAMPLES
   pndrsSummaryAllOiData,inputFiles="/data/pionier/*_v1.9_bright/*SCI*oidataCalibrated.fits",file="/data/pionier/Summary/summaryAll.org";

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsSummaryAllOiData()";
  local setup, id, diam, cal, s, str, time, grpId, com;

  /* Load files */
  oiFitsLoadFiles, inputFiles, oiTarget, oiWave, oiArray,
    oiVis2, oiVis, oiT3, oiLog;

  /* Replace the target names */
  yocoLogInfo,"Replace target name (pndrsCheckTargetInList)";
  oiTarget.target = pndrsCheckTargetInList(oiTarget.target);
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;

  /* Check arguments */
  if(is_void(dtime)) dtime = 6./24.0; // 6h

  /* Found the groups */
  yocoLogInfo,"Find the groups";
  tmp = double(oiVis2.mjd) - min(oiVis2.mjd);
  tmp += 1000.*oiFitsGetTargetId( oiVis2 );
  tmp += 1000000.*oiFitsGetSetupId(oiVis2, oiLog);
  grpId = oiFitsFindGroupId(tmp, dtime);
  grpId = yocoListUniqueId(grpId);

  yocoLogInfo,"Loop on groups";
  /* Loop on the group to build */
  for (str=time=[],i=1 ; i<=max(grpId) ; i++ ) {

    /* Get the obs */
    id  = where(grpId==i);
    oiTmp = oiVis2(id);
    grow, time, oiTmp.mjd(avg);
    oLog = oiFitsGetOiLog(oiTmp, oiLog);
    nw = numberof( oiFitsGetLambda(oiTmp(1),oiWave) );

    /* get the bases */
    bases = (yocoListClean(oiFitsGetStationName(oiTmp,oiArray)(*))+" ")(*)(sum);

    /* build the setup */
    setup = swrite(format="nSpec=%i",nw); //,oiTmp(1).hdr.insName);

    /* build the quality */
    oiFitsGetData, oiTmp, amp, ampErr,,,,1;
    v2 = median(amp(*))*100;
    e2 = min( median(ampErr(*))*100, 100);
    data = swrite(format="v2~%5.1f +-%5.1f%%", v2, e2);
        
    /* build the prev (that is first part of the filename) */
    prev = strtok(yocoFileSplitName(oLog(1).fileName),"_")(1,);

    /* Write the line */
    grow, str, swrite( format="| %s |%13s | %2ipts | %12s| %s | %s |",
                       prev,
                       oiFitsGetTargetName(oiTmp(1),oiTarget),
                       numberof(oiTmp)/6,
                       bases,
                       data,
                       setup);
  }

  /* Sort by time */
  str = str( sort(time) );

  /* write the list */
  if (is_void(file)) {
    write,str+"\n", linesize=strlen(str)(max)+2;
  } else {
    yocoLogInfo,"Write the list in ASCII file",file;
    remove,file;
    file=open(file,"w");
    write,file,str+"\n", linesize=strlen(str)(max)+2;
    close,file;
  }
  
  yocoLogInfo,"pndrsSummaryAllOiData done";
  return 1;
}

/* ********************************************************************* */

func pndrsSummaryAllOiDataPerTarget(inputFiles=,strRoot=)
/* DOCUMENT pndrsSummaryAllOiDataPerTarget(inputFiles=,strRoot=)

   DESCRIPTION

   PARAMETERS

   EXAMPLES
   pndrsSummaryAllOiDataPerTarget, inputFiles="/data/pionier/*v1.9_bright/*SCI*oidata*fits", strRoot="/data/pionier/Summary/";
   
   SEE ALSO
 */
{
  yocoLogInfo,"pndrsSummaryAllOiDataPerTarget()";

  /* Default */
  if (is_void(strRoot)) strRoot = "pdf/";

  /* Load the data */
  oiFitsLoadFiles, inputFiles,
    oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;

  /* Replace the target names */
  yocoLogInfo,"Replace target name (pndrsCheckTargetInList)";
  oiTarget.target = pndrsCheckTargetInList(oiTarget.target);
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
  
  /* Clean the data */
  oiFitsCleanDataFromDummy, oiVis2,oiT3,oiVis,maxVis2Err=0.1,maxT3PhiErr=10.0;
  oiFitsCleanFlag, oiVis2, oiVis, oiT3;
  oiFitsCleanUnused, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;

  /* Loop on targets */
  for (i=1;i<=numberof(oiTarget);i++) {
    
    /* Get the name */
    name = oiTarget(i).target;
    yocoLogInfo,"Make a summary for target: "+name+" ("+pr1(i)+" over "+pr1(numberof(oiTarget))+")";

    /* Copy arrays and keep only this target */
    oiFitsCopyArrays, oiTarget, oTarget, oiVis2, oVis2, oiVis, oVis,
      oiT3, oT3, oiArray, oArray, oiWave, oWave, oiLog, oLog;
    oiFitsKeepTargets, oTarget, oVis2, oVis, oT3, trgList=name;

    /* Check if something remains */
    if (is_void(oT3) && is_void(oVis2)) {
      yocoLogInfo,"No valid data for this target... skip";
      continue;
    }
    
    /* Write the data, no oiVis as not validated */
    oiFitsWriteFiles,strRoot+name+"_oidataCalibrated.fits",oTarget,oWave,oArray,oVis2,,oT3,oLog,overwrite=1;
    
    /* Plot the UV plane */
    if (is_array(oVis2)) {
      yocoLogInfo,"Plot the UV map for this target";
      winkill,10; window,10,style="boxed.gs";
      oiFitsPlotUV, oVis2, oiWave, symbol=4,size=0.75,color="red",fill=0,unit="mum";
      gridxy,2,2;
      limits,square=1;
      xytitles,"East (M!l) ->","North (M!l) -> ";
      /* Add some circles */
      pts = exp(2.i*pi * span(0,1,1000)) * [10,20,40,60,80,100](-,);
      yocoPlotPlgMulti, pts.im, pts.re, type=3;
      pndrsSavePdf,10,strRoot+name+"_uv.pdf";
    }
    
    /* Plot the Vis2 */
    if (is_array(oVis2)) {
      yocoLogInfo,"Plot all calibrated oiVis2 for this target";
      winkill,10; yocoNmCreate,10,1,landscape=1,fx=1,fy=1;
      oiFitsPlotOiData, oVis2, oiWave, "base", symbol=0;
      oiFitsPlotOiData, oVis2, oiWave, "base", symbol=4,size=0.75,errFlag=0,color="red",fill=0;
      limits; l = limits();
      limits,0,l(2)+5,0.0,1.1;
      gridxy,0,1;
      xytitles,"Base (M!l)","vis2 (%)";
      plt,"+",1.03,0.72,tosys=0,height=1;
      pndrsSavePdf,10,strRoot+name+"_vis2_base.pdf";
    }
    
    /* Plot the t3 */
    if (is_array(oT3)) {
      yocoLogInfo,"Plot all calibrated oiT3 for this target";
      winkill,10; yocoNmCreate,10,1,landscape=1,fx=1,fy=1;
      oiFitsPlotOiData, oT3, oiWave, "base", symbol=0;
      oiFitsPlotOiData, oT3, oiWave, "base", symbol=4,size=0.75,errFlag=0,color="red",fill=0;
      xytitles,"Base (M!l)","t3phi (deg)";
      limits; l = limits();
      limits,l(1)-5,l(2)+5,max(-200,l(3)-5),min(200,l(4)+5);
      gridxy,0,1,base60=2;
      plt,"+",1.03,0.72,tosys=0,height=1;
      pndrsSavePdf,10,strRoot+name+"_t3phi_base.pdf";
    }
  }
  
  yocoLogInfo,"pndrsSummaryAllOiDataPerTarget done";
  return 1;
}

func pndrsCheckNiobate(&oiVis,inputFile=)
{
  yocoLogInfo,"pndrsCheckNiobate()";
  local imgData, imgLog, coherData;

  /* Check the input files */
  if ( !pndrsCheckFile(inputFile,2,[1],"inputFile") ) {
    return 0;
  }
  
  /* Init the plots and the browser */
  yocoGuiWinKill;

  /* Read the fringe file */
  yocoLogInfo,"Read the fringe file:", inputFile;
  if( !pndrsReadRawFiles(inputFile, imgData, imgLog) ) return 0;
  if( !pndrsCheckOiLog(imgLog) ) return 0;

  /* Process detector and reform data into scans */
  if( !pndrsProcessDetector(imgData, imgLog) ) return 0;
  if( !pndrsReformData(imgData, imgLog) ) return 0;
  if( !pndrsProcessOversampling(imgData, imgLog) ) return 0;

  /* Compute the average level per output and remove it */
  pndrsGetData, imgData(1), imgLog, data, opd, map, olog;
  cont = data(,avg,avg,)(,-,-,);
  pndrsRemoveDark,  imgData,  imgLog, cont;

  /* Compute coherent flux and the polar diff phases */
  yocoLogInfo,"Compute the polar-differential phases...";
  pndrsComputeCoherentFlux, imgData,  imgLog,  coherData, gui=10, check=1;
  pndrsScanComputePolarDiffPhases, coherData, imgLog, oiVis, gui=35;
  
  yocoLogInfo,"pndrsCheckNiobate done";
  return 1;
}

func pndrsArgvSetLogLevel(&argv)
{
  yocoLogTrace,"pndrsArgvSetLogLevel()";
  local logLevel;
  
  /* get logLevel (info,warning,trace...) */
  logLevel = pndrsGetArgument(argv,"--logLevel=", default="info");
  logLevel = "yocoLOG_"+strcase(1,logLevel);
  
  yocoLogInfo,"Log level set to:",logLevel;
  yocoLogSet, 1, symbol_def(logLevel);
  
  yocoLogTrace,"pndrsArgvSetLogLevel done";
  return 1;
}

func pndrsGetArgument(&argv,argname, default=)
/* DOCUMENT pndrsGetArgument(&argv,argname)

   Process the argv string return by get_argv and
   extract the string corresponding to the argument
   argname.

   EXAMPLES:

   > argv = ["yorick","--kappa-file=f.fits","--output=test.fits"];
   > pndrsGetArgument(argv,"--kappa-file=")
   "f.fits"

   > argv = ["yorick","--kappa-file=f.fits,f2.fits","--output=test.fits"];
   > pndrsGetArgument(argv,"--kappa-file=")
   ["f.fits","f2.fits"]
     
   SEE ALSO:
 */
{
  yocoLogTrace,"pndrsGetArgument()";
  
  /* Get the matching argument */
  id = strmatch(argv,argname);
  noid = where(!id);
  id = where(id);

  /* If none, return default or void */
  if (!is_array(id)) return (is_array(default) ? default : []);
  else output = strpart( argv(id(1)), strlen(argname)+1: );

  /* If comma, then slit in array */
  if ( strmatch(output,",") ) {
    output = strpart(output,strword(output, ",",15));
    output = output(where(output));
  }

  /* Remove argument from argv */
  // argv=argv(noid);

  /* Return the argument */
  yocoLogTrace,"pndrsGetArgument done";
  return output;
}

/* --- */

func pndrsComputeAllUnstablePixelMap(inputDir=, overwrite=)
{
  yocoLogInfo,"pndrsComputeAllUnstablePixelMap()";
  local outputDir, oiLog;

  /* Default */
  if ( is_void(overwrite) ) overwrite=0;
  if (is_void(inputDir)) inputDir="./";

  /* Prepare the output Dir */
  pndrsBatchProductDir, inputDir, outputDir, app="calib";
  pndrsCheckDirectory, outputDir, 1, chmode="ug+w";

  /* Read Log */
  pndrsReadLog, inputDir, oiLogDir;

  /* Keep only the DARKs taken in PTC,BIAS,PIXCHAR */
  oiLogDir = oiLogDir( where(pndrsGetShutters(,oiLogDir)=="0000" &
                             oiLogDir.dprType=="PTC,BIAS,PIXCHAR" ));

  /* Check how many */
  if (numberof(oiLogDir)<5) {
    yocoLogInfo,"Not enough PTC,BIAS,PIXCHAR with shutter closed in this directory...";
    return 1;
  }

  /* Define all DARK setups. Add the obsStart,
     to be sure they come from the same sequence */
  setup = pndrsGetSetupDark(,oiLogDir)+" "+oiLogDir.obsStart;
  setups = yocoListClean(setup);

  /* Loop on setup */
  iMax = numberof(setups);
  for (i=1;i<=iMax;i++) {
    ids = where( setup==setups(i) );

    /* Verbose */
    str = swrite(format="pndrsComputeAllUnstablePixelMap is now working on sequence (%i over %i):",i, iMax);
    yocoLogInfo, str, oiLogDir(ids).fileName;

    /* Check number of files */
    if ( numberof(ids)<4 ) { yocoLogInfo,"Not enough files in sequence... continue."; continue; }

    /* Prepare the outputFile name, with no-extension */
    yocoFileSplitName, oiLogDir(ids(1)).fileName, ,outputFile;
    outputFile   = outputDir + "/" + outputFile;

    /* Skip if outputFile is already existing */
    if ( overwrite==0 && yocoTypeIsFile( outputFile+"_unstablePixelsMap.fits" ) ) {
      yocoLogInfo,"reduced UNSTABLE_PIXEL file already exists... skipped.";
      continue;
    }

    /* Set the log File and put some info */
    yocoLogSetFile, outputFile + "_log.txt", overwrite=1;

    yocoLogInfo,"------------- calibration info --------------";
    yocoLogInfo,"target:  "+oiLogDir(ids(1)).target;
    yocoLogInfo,"date:    "+oiLogDir(ids(1)).dateObs;
    yocoLogInfo,"mjd:     "+swrite(format="%.3f",oiLogDir(ids(1)).mjdObs);
    yocoLogInfo,"setup:   "+setups(i);
    yocoLogInfo,"---------------------------------------------";
    
    /* Compute the map */
    pndrsComputeSingleUnstablePixelMap, inputFiles=oiLogDir(ids).fileName, outputFile=outputFile;
    
    yocoLogInfo,"****";
    yocoLogSetFile;
  } /* End loop on setup */

  yocoLogInfo,"pndrsComputeAllUnstablePixelMap done";
}

/* --- */

func pndrsComputeSingleUnstablePixelMap(&map,inputFiles=, outputFile=, outputMapFile=)
{
  yocoLogInfo,"pndrsComputeSingleUnstablePixelMap()";
  local imgData, imgLog;
  yocoGuiWinKill;

  /* Check default */
  if ( is_void(outputFile) ) outputFile="outputFile";
  if ( is_void(outputMapFile) ) outputMapFile=outputFile+"_unstablePixelsMap.fits"

  /* Load data */
  pndrsReadRawFiles, inputFiles, imgData, imgLog;

  /* Accumulate  */
  for (data=[],f=1;f<=numberof(imgData);f++)
    grow, data, [*imgData(f).regdata];
  
  /* Reform data into pseudo scans of 512 points */
  dim = dimsof(data)(2:);
  data = reform(data,[5,dim(1)*dim(2),512,dim(4)/512,dim(5),dim(6)]);

  /* Average over step in scans, and
     Variance of the average over 512 points
     (should be ~1adu) */
  Mean = data(,avg,,,);
  Var = transpose(Mean,[2,3])(,,*)(,,rms);

  /* Get the title */
  setup = pndrsGetSetupDark(,imgLog(1));
  nwin = dimsof(Var)(0);

  yocoNmCreate,1,2,nwin/2,dx=0.04,dy=0.01;
  yocoPlotPlgMulti, Var, tosys=indgen(nwin),color="red";
  yocoPlotPlpMulti, Var, tosys=indgen(nwin),color="red";
  yocoNmRange,0,10;
  yocoNmMainTitle,setup;
  pndrsSavePdf,1,outputFile+"_unstablePixels.pdf";

  yocoNmCreate,2,1,1;
  pli, Var, cmin=0, cmax=10;
  yocoNmMainTitle,setup;
  pndrsSavePdf,2,outputFile+"_unstablePixelsMap.pdf";

  /* Write the output file */
  yocoLogInfo,"Write the unstablePixelsMap into FITS file:", outputMapFile;
  remove,outputMapFile;
  fh = cfitsio_open(outputMapFile,"w");
  pndrsWritePnrLog, fh, imgLog(1);
  cfitsio_add_image, fh, Var, "PNDRS_UNSTABLEPIXELS";
  cfitsio_close,fh;

  /* Change permission of all these newly created files */
  system,"chmod ug+w "+outputFile+"_* "+outputMapFile+" > /dev/null 2>&1";
  
  yocoLogInfo,"pndrsComputeSingleUnstablePixelMap done";
  return 1;
}

func pndrsApplySelectionTable(&coherData, imgLog, &selTable)
{
  yocoLogInfo,"pndrsApplySelectionTable()";
  local sciFile, selTable;
    
  /* Read the RAW file */
  sciFile  = oiFitsGetOiLog(coherData, imgLog).fileName;
  selTable = pndrsReadPnrSelTable(sciFile);
  
  if ( is_array(selTable) ) {
    yocoLogInfo," accepted scans: "+pr1(selTable(sum,))+" over ("+pr1(numberof(selTable(,1)))+")";
    *coherData.regdata *= selTable(-,-,,);
  } else {
    yocoLogInfo," no selection table";
  }

  yocoLogTrace,"pndrsApplySelectionTable done";
  return 1;
}

func pndrsComputeStaticMask(inputFile=, outputFile=)
/* DOCUMENT pndrsComputeStaticMask(inputFile=, outputFile=)

   DESCRIPTION:
   Compute the mask corresponding to the illumintated pixels
   for the given subwindowing of inputFile.
   To be used for detector monitoring.
     
   SEE ALSO:
 */
{
  yocoLogInfo,"pndrsComputeStaticMask()";
  local image, nx, ny, nX, nY, x, y;

  yocoLogInfo,"Read header from file", inputFile;
  fh = cfitsio_open(inputFile);

  /* Read image size */
  nX = cfitsio_get(fh,"HIERARCH ESO DET CHIP NX");
  nY = cfitsio_get(fh,"HIERARCH ESO DET CHIP NY");
  image = array(1,nX,nY);

  /* Read subwins, parse them, update the mask */
  n = cfitsio_get(fh,"HIERARCH ESO DET SUBWINS");
  for (i=1;i<=n;i++) {
    x=y=nx=ny=0;
    sub = cfitsio_get(fh,"HIERARCH ESO DET SUBWIN"+pr1(i)+" GEOMETRY");
    yocoLogInfo," find window: "+sub;
    sread,sub,format="%ix%i+%i+%i",nx,ny,x,y;
    image(x+1:x+nx,y+1:y+ny) = 0;
  }

  /* Read the entire HEADER */
  value = cfitsio_get(fh, "*", , names,point=1);
  cfitsio_close, fh;

  /* Create outputFile with its HEADER */
  remove, outputFile;
  fh = cfitsio_open(outputFile,"c");
  for (i=1;i<=numberof(value);i++) {
    if (*value(i)=='F') value(i) = &char(0);
    cfitsio_set,fh, names(i), *value(i);
  }
  cfitsio_set,fh,"HIERARCH ESO PRO CATG","STATIC_MASK";
  cfitsio_set,fh,"HIERARCH ESO PRO TECH","IMAGE";
  cfitsio_set,fh,"HIERARCH ESO PRO TYPE","CALIB";

  /* Write the static mask with bitpix of 8 */
  cfitsio_create_img, fh, 8, dimsof(image);
  cfitsio_write_key, fh, "EXTNAME", "STATIC_MASK", "name of HDU";
  dim       = dimsof(image);
  fpixels   = array(1,dim(1));
  nelements = numberof(image);
  __ffppx, fh, TBYTE, fpixels, nelements, &char(image);

  /* Close file */
  cfitsio_close,fh;

  yocoLogTrace,"pndrsComputeStaticMask done";
  return 1;
}
  
