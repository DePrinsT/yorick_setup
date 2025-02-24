/*******************************************************************************
 PIONIER Data Reduction Software
*/

func pndrsProcess(void)
/* DOCUMENT pndrsProcess(void)

   FUNCTIONS:
   - pndrsProcessDetector
   - pndrsReformData
   - pndrsGetData
   - pndrsProcessOversampling
   
   - pndrsComputeDark
   - pndrsRemoveDark
   - pndrsComputeMatrix
   - pndrsFlatField
   - pndrsComputeInputFlux
   - pndrsRemoveContinuum
   - pndrsComputeCoherentFlux
   - pndrsCalibrateCoherentFlux
   - pndrsComputeCoherentNorm2
   
   - pndrsScanCropOpd
   - pndrsScanSquareFiltering
   - pndrsScanComputePolarDiffPhases
   - pndrsScanComputeClosurePhases
   - pndrsScanComputeAmp2PerScan
   - pndrsScanComputeAmp2DirectSpace

   - pndrsComputeOiWave
   - pndrsGetDefaultWave

   - pndrsComputeAirDisp
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.64 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsProcess;
    }   
    return version;
}

/* ******************************************************** */

func pndrsProcessDetector(&imgData, &imgLog, removeFirstLine=)
/* DOCUMENT 

   DESCRIPTION
   SIMPLE: nsampix are averaged
   DOUBLE: nsampix are averaged, then the 2 read are substrated
   FOWLER: nsampix are averaged, reads between 2 resets are diff
           first read after reset has same value as 2nd.

   input data are of dimensions:
   - simple: (x, y,   nspx, nimage, nwin)
   - double: (x, y, 2.nspx, nimage, nwin)
   - fowler: (x, y,   nspx, nimage, nwin)

   output data are of dimensions:
   - (x, y, nimage, nwin)

   in case of scanned data, nimage is defined by
   nstep x nscan

   PARAMETERS
   - imgData, imgLog

   SEE ALSO
 */
{
  yocoLogInfo, "pndrsProcessDetector()";
  local data, dataOut, i, log;
  local nscan, nstep, dim, flag, dx, dy;

  /* Loop on data */
  for (i=1;i<=numberof(imgData);i++) {

    /* Extract data and associated log */
    data  = float(*imgData(i).regdata);
    log   = oiFitsGetOiLog(imgData(i), imgLog);
    ndim  = dimsof(data)(1)
    dim   = dimsof(data)(2:);
    nnd   = log.detNdreads;
    pndrsParseSubwin, log.detSubwin1, dx, dy;
    
    /* Replace saturated sampix by nan (32767)
       so that saturated data (or scan) can be recovered
       in the following part of the DRS. */
    if ( numberof(data)>(235929600/2) ) {
      yocoLogInfo,"Saturation test skipped (array is too big).";
    } else {
      flag = where( data>32000 );
      if ( is_array(flag) ) data(flag) = 1e30;
    }
    
    /* FIXME: deal with saturation in RAPID.
       - Saturation can be done only in
         DARK-substracted images.
       - Pixel 20 in FREE saturates at 800adu !!
       - Others saturated a ~5000adu */

    /* Check if the low voltage is out of converter */
    if (log.detName != "RAPID" &&  log.detMode == "DOUBLE") {
      minData = min(data(*));
      if ( minData < -32700 )
        yocoLogWarning,"Voltage seems to be out of DAC: "+pr1(minData)+" < -32700";
      else
        yocoLogTrace,"Voltage seems to be well inside DAC: "+pr1(minData)+" > -32700";
    }

    /* RAPID ADU start at -16384. Here we force the data
       to be positive, to ease the visual inspection. */
    if (log.detName == "RAPID") {
      data += 16384;
    }

    /* Check the dimension of data because CPL may
       remove some of them */
    if ( ndim==3 ) {
      yocoLogInfo, " dimensions of DATA# lost, read dimension in header.";
      dim = [ dx, dy, dim(1)/(dx*dy), dim(2), dim(3) ];
    }
    else if ( ndim==2 ) {
      yocoLogInfo, " dimensions of DATA# lost, assume (1,1,1).";
      dim = [ 1, 1, 1, dim(1), dim(2) ];
    }
    else if ( ndim!=5 ) {
      yocoError, " dimensions of DATA# lost, cannot recognise dimensions.";
      return 0;
    }
    
    /* Deal with the detector mode: average the sampix,
       make the difference of double-read, make the
       differences of fowler */
    if (log.detMode == "SIMPLE" ) {
      yocoLogTrace," reform for SIMPLE";
      dataOut = reform(data,[5, dim(1), dim(2), dim(3), dim(4), dim(5)]);
      dataOut = dataOut(,,avg,,);
    }

    /* If mode DOUBLE, the two reads are recorded so we substract them */
    if ( log.detMode == "DOUBLE" ) {
      yocoLogTrace," reform for DOUBLE";
      dataOut = reform(data,[6, dim(1), dim(2), dim(3)/2, 2, dim(4), dim(5)]);
      dataOut = dataOut(,,avg,,,);
      dataOut = dataOut(,,2,,) - dataOut(,,1,,);
    }

    /* If mode FOWLER, integration is non-destructive */
    if (log.detMode == "FOWLER" ) {
      yocoLogTrace," reform for FOWLER";
      dataOut = reform(data,[6, dim(1), dim(2), dim(3), nnd, dim(4)/nnd, dim(5)]);
      dataOut = dataOut(,,avg,,);
      dataOut(,,2:,,) = dataOut(,,dif,,);
      dataOut(,,1,,)  = dataOut(,,2,,);
      dataOut = dataOut(,,*,);
    }

    /* Remove first line (when detector screw up)
       FIXME: change correctly the detSubwin1 label */
    if (removeFirstLine) {
      dataOut = dataOut(,2:,,,,);
      id = yocoListId( imgData(i).hdr.logId, imgLog.logId );
      imgLog(id).detSubwin1 = "1x5+2+29";
    }
    
    /* Put data back */
    imgData(i).regdata = &dataOut;
  }

  yocoLogTrace, "ProcessDetector done";
  return 1;
}

/* ******************************************************** */

func pndrsProcessOversampling(&imgData, imgLog, gui=)
/* DOCUMENT pndrsProcessOversampling(&imgData, imgLog, gui=)

   DESCRIPTION
   Average the consecutives samples when the fringes
   are oversampled. Currently, the fringes are supposed
   to be oversampled when the nstep per scan is larger
   than 512.

   Actually, the average is performed as a low-pass
   filter in the Fourier space, and then a ::n.
   This is *mandatory* to avoid the aliasing of the high
   frequency noise inside the new frequency region.
 */
{
  yocoLogInfo, "pndrsProcessOversampling()";
  
  local data, dataOut, i, log, opd, opdOut, map, opd0, lopd;
  local nscan, nstep, dim, flag, dt, dataf;

  /* Loop on data */
  for (i=1;i<=numberof(imgData);i++) {

    /* Get the data and the associated log */
    pndrsGetData, imgData(i), imgLog, data, opd, map, olog;

    /* Extract the OPDs manually since we want the
       OPD per beam and not per baseline.
       Same for time */
    opd0   = *imgData(i).opd;
    lopd0  = *imgData(i).localopd;
    time   = *imgData(i).time;

    /* Check the number of step in scan */
    nstep = dimsof(data)(3);
    nwin  = dimsof(data)(0);
    x     = indgen(nstep);

    /* If no need to process, continue */
    if (nstep<=512) continue;

    /* Check the current sampling  */
    pndrsGetDefaultWave, olog, lbd;
    sampling = lbd(min) / abs(opd(17,1,) - opd(18,1,))(max);
    yocoLogTrace," sampling="+pr1(sampling);

    /* Make a warning if data are undersampled */
    if (sampling<3.5) yocoLogWarning,"Data are undersampled.";

    /* If no need to process, continue */
    if (sampling<6.5) continue;
    
    /* Define new sampling value:
       - should be a power of 2
       - fringes should still be well sampled
       - scan should have at least 512 steps */
    n = [1,2,4,8,16];
    n = n( where(sampling/n>=3.25 & nstep/n>=512)(mxx) );

    /* Check if something has to be done */
    if ( n<2 ) continue;
    yocoLogTrace," n="+pr1(n);
    yocoLogTrace," newsampling="+pr1(sampling/n);
    
    /* Perform the runnning average as a filter, to
       avoid the noise aliasing */
    mask  = abs(pndrsSignalFftIndgen(nstep)) <= (nstep/2/n);
    ft    = fft(data,[0,1,0,0]) * mask(-,);
    dataf = fft(ft,[0,-1,0,0]).re / nstep;

    /* Keep only one sample over the running average.
       Multiply by n since it corresponds to an
       increased integration time. */
    dataOut  = dataf(,1::n,) * n;
    opdOut   = opd0(1::n,);
    lopdOut  = lopd0(1::n,);
    time     = time(1::n,);
      
    /* Put the data back */
    imgData(i).regdata  = &dataOut;
    imgData(i).opd      = &opdOut;
    imgData(i).localopd = &lopdOut;
    imgData(i).time     = &time;
  }

  /* Some plot verbose */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data(1,,1:3,)(*,), tosys=indgen(nwin);
    yocoPlotPlgMulti, dataf(1,,1:3,)(*,), color="red", tosys=indgen(nwin);
    winkill,gui+1;
    yocoNmCreate,gui+1,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, power( fft(data(avg,,,), [1,0,0,0]) )(15:,avg,), tosys=indgen(nwin);
    yocoPlotPlgMulti, power( fft(dataf(avg,,,), [1,0,0,0]) )(15:,avg,), tosys=indgen(nwin), color="red";
    yocoPlotPlgMulti, power( fft(dataOut(avg,,,), [1,0,0,0]) )(15:,avg,), tosys=indgen(nwin), color="green";
  }
  
  yocoLogTrace, "pndrsProcessOversampling done";
  return 1;
}

/* ******************************************************** */

func pndrsGetData(imgData, imgLog, &data, &opd, &map, &olog, &time)
/* DOCUMENT pndrsGetData(imgData, imgLog, &data, &opd, &map, &olog, &time)

   DESCRIPTION
   Return the data and opd contain into imgData(1). The OPD
   is computed for each WIN based on imgLog.correlation.
   The imgLog.correlation is returned in "map".

   PARAMETERS
   - imgData : should be scalar
   - data(x,y,nstep,nscan,nwin)
   - opd(nstep,nscan,ntel)
   - map(nwin): correlation map

   EXAMPLES

   SEE ALSO
 */
{
  local opd;
  yocoLogTrace,"pndrsGetData()";
  
  data = (*imgData(1).regdata);
  opd  = float(*imgData(1).localopd);
  olog = oiFitsGetOiLog(imgData(1), imgLog);
  map  = *olog.correlation;
  time = double(*imgData(1).time) * 3600*24;

  /* The return OPD correspond to the local OPD */
  if( is_array(map) )
  {
    opd = opd(..,map.t2) - opd(..,map.t1);
  }
  
  yocoLogTrace,"pndrsGetData done";
  return 1;
}

func pndrsGetMap(imgData, imgLog)
{
  yocoLogTrace,"pndrsGetMap()";
  
  return *oiFitsGetOiLog(imgData(1), imgLog).correlation;
}

/* ******************************************************** */

func pndrsCheckBadPixelConsistency(&imgLog, &matrix, &imgData1, &imgData2)
{
  yocoLogInfo, "pndrsCheckBadPixelConsistency()";
  local data1, data2, oLog;

  /* Bad pixels of matrix == pixels with no illumination at all */
  gp_matrix = ( matrix(,,sum) != 0 );

  /* Good pixels of data1 */
  pndrsGetData, imgData1, imgLog, data1,,, oLog;
  gp_1 = ( data1(,sum,sum,) != 0 );

  /* Good pixels of data2 */
  pndrsGetData, imgData2, imgLog, data2,,, oLog;
  gp_2 = ( data2(,sum,sum,) != 0 );

  /* Check consistency */
  if ( anyof(gp_matrix != gp_1) || anyof(gp_matrix != gp_2) ) {
    yocoError,"Inconsistencies in bad-pixel map...";
    return 0;
  }

  yocoLogTrace, "pndrsCheckBadPixelConsistency done";
  return 1;
}

/* *** */

func pndrsReformData(&imgData, &imgLog, useDarkWin=)
/* DOCUMENT pndrsReformData(&imgData, imgLog, useDarkWin=)

   DESCRIPTION
   Reform the data in arrays of scans:
   data(x,y,nopd,nwin)  ->  data(x,y,nstep,nscan,nwin)
   opd(ntel,nopd)       ->  opd(nstep,nscan,ntel)

   If the data are not scanned, then nstep=1.

   SEE ALSO
 */
{
  yocoLogInfo, "pndrsReformData()";
  local i, data, olog, dim, nopd, opl, map, nstep, lopl, time;
  local flag;

  if ( is_void(useDarkWin) ) useDarkWin=1;
  
  /* Loop on imgdata */
  for (i=1;i<=numberof(imgData);i++) {

    /* Get the data */
    data = float(*imgData(i).regdata);
    opl  = float(*imgData(i).opd);
    lopl = float(*imgData(i).localopd);
    olog  = oiFitsGetOiLog(imgData(i), imgLog);
    time = double(*imgData(i).time);

    /* Find the number of point per scan
       if SCAN if OFF, this number is 1 */
    nopd = ( olog.scanStatus==1 ? olog.scanNreads : 1 );

    /* check if scanned */
    if ( nopd==1 ) {
      yocoError, "Cannot find scans in data:", olog.fileName,1;
      return 0;
    }

    /* Reform the data. We average the other direction
       than the dispersion. The definition of the RAPID orientation
       is different than the PICNIC */
    dim  = dimsof(data)(2:);
    if ( olog.detName=="RAPID" )
      data = reform(data(,sum,..), [4, dim(1), nopd, dim(3)/nopd, dim(4)]);
    else
      data = reform(data, [4, dim(2), nopd, dim(3)/nopd, dim(4)]);

    /* Reform the opd */
    opl  = transpose(opl);
    lopl = transpose(lopl);
    dim  = dimsof(opl)(2:);
    opl  = reform(opl, [3, nopd, dim(1)/nopd, dim(2)]);
    lopl = reform(lopl, [3, nopd, dim(1)/nopd, dim(2)]);
    time = reform(time,[2,nopd,dim(1)/nopd]);

    /* Check and remove saturated scans.
       FIXME: implement saturation test for RAPID */
    flag = abs(data)(avg,avg,,avg);
    flag = flag>32000;
    if ( anyof(flag) )
      {
        str = swrite(format="%i over %i saturated scans flaged.",flag(sum),numberof(flag));

        /* Print warning or error */
        if ( flag(sum)/numberof(flag) > 0.25 )
          yocoLogWarning, str;
        else
          yocoLogInfo, str;

        /* Put saturated scans at 0 */
        data = data * (!flag)(-,-,,);
      }

    /* FIXME: Deal with a proper badpixelmap, which may be time
       and setup dependend, to have better flexibility.
       Actually this had not moved from Dec2014 to Fev2105.
       To be checked after relocation and warm-up.
       FIXME: Pixel (1,20) saturates ~600adu while other
       are more than 3000adu. Actually it depends on the
       DIT apparently (don't saturate for longer DITs,
       only for 0.5ms). May have some side effect in FREE,
       where some faint programs would use the
       INTERNAL kappa-matrix.
       {channel 5, output 19} and {channel 5, output 25}
    */
    win = pndrsGetWindows(,olog);
    nlbd = dimsof(data)(2);
    if ( strmatch(olog.detName,"RAPID") &&
         win=="[6x1+248+58]x26" ) {
      yocoLogInfo," discard pixels: (5,19) and (5,25)";
      data(5,,,19) = 0.0;
      data(5,,,25) = 0.0;
      // data(3,,,2)  = 0.0;
      // data(2,,,23) = 0.0;
      // data(3,,,10) = 0.0;
    }
    if ( strmatch(olog.detName,"RAPID") &&
         win=="[6x1+248+58]x26" &&
         olog.detDit<10e-3 ) {
        yocoLogInfo," discard pixels: (1,20)";
        data(1,,,20) = 0.0;
    }

    /* Determine the number of DARK window,
       in the case of RAPID detector generaly
       This dark is averaged over
       the opds and the channels, but not over the scans.
       FIXME: Maybe it should not be averaged over the channels
       since it seems there is an effect of flux.
       Note that I average only over the non-zero pixels so
       that the DARK has some physical sens */
    nd = olog.nbDarkWins;
    if ( olog.detName=="RAPID" && nd>0 && useDarkWin) {
      yocoLogInfo," substract the DARK windows (RAPID)";
      bpm  = (data(,avg,avg,)!=0);
      dark = data(,,,-nd+1:0)(sum,avg,,sum) / bpm(,-nd+1:0)(sum,sum);
      data = data(,,,1:-nd) - dark(-,-,,-);
      data *= bpm(,-,-,1:-nd);
    }

    /* Put data back*/
    imgData(i).regdata  = &data;
    imgData(i).opd      = &opl;
    imgData(i).localopd = &lopl;
    imgData(i).time     = &time;
  }
  
  yocoLogTrace, "pndrsReformData done";
  return 1;
}

/* ******************************************************** */

func pndrsComputeDark(imgData, &imgLog, &dark, &sig2Dark)
/* DOCUMENT pndrsComputeDark(imgData, imgLog, &dark, &sig2Dark)

   DESCRIPTION
   Compute the DARK signal as an average over the scan:
   dark(x,y,nopd,1,nwin)

   PARAMETERS:
   - imgData, imgLog

   SEE ALSO pndrsRemoveDark
 */
{
  yocoLogInfo, "pndrsComputeDark()";
  local data, data0, nscan, nopd, oLog, id;

  /* Search for the shutter sequence */
  id = where( pndrsGetShutters(imgData,imgLog) == "0000" );
  if ( numberof(id)!=1 ) {
    yocoError,"Check that data contain a single DARK.";
    return 0;
  }

  /* Get data */
  pndrsGetData, imgData(id(1)), imgLog, data,,, oLog;
  nscan = dimsof(data)(4);
  nopd  = dimsof(data)(3);

  /* Prepare info for QC parameters */
  dark  = data(,*,)(,avg,);
  noise = data(,*,)(,rms,);
  stab  = data(,avg,,)(,rms,);

  /* The log is the one of the first file */
  yocoLogInfo," add QC parameters";
  id = oiFitsGetId(oLog.logId, imgLog.logId);
  imgLog(id).qcDarkMed    = median( dark(*) );
  imgLog(id).qcDarkRmsMed = median( stab(*) );
  imgLog(id).qcDarkRmsMax = max( stab(*) );
  imgLog(id).qcNoiseMed = median( noise(*) );
  imgLog(id).qcNoiseMax = max( noise(*) );

  /* Compute the dark as an average over the scans. */
  if ( oLog.detName=="RAPID" ) {
    /* The DARK value is stable, so we first average
       all points of the scan */
    yocoLogInfo," assume DARK is stable in opd";
    data     = data(,avg,,)(,-:1:nopd,,);
    dark     = average( data, 3)(,,-,);
    sig2Dark = data(,,rms,-,)^2 / nscan;
  } else {
    /* The DARK value depends on the position on scan */
    yocoLogInfo," assume DARK depends on opd";
    dark     = average( data, 3)(,,-,);
    sig2Dark = data(,,rms,-,)^2 / nscan;
  }

  yocoLogTrace, "pndrsComputeDark done";
  return 1;
}

/* ******************************************************** */

func pndrsRemoveDark(&imgData, &imgLog, dark)
/* DOCUMENT pndrsRemoveDark(&imgData, &imgLog, dark)

   DESCRIPTION
   Remove the DARK signal from all data in imgData.
   imgData = imgData - dark

   PARAMETERS
   - imgData, imgLog
   - dark

   SEE ALSO pndrsComputeDark
 */
{
  yocoLogInfo, "pndrsRemoveDark()";
  local i, data, log, dim, nopd, id;
  
  /* Loop on imgdata and remove the DARK */
  for (i=1;i<=numberof(imgData);i++) {

    /* Get the data, remove the dark */
    data = *imgData(i).regdata;

    /* Remove the dark. Not remove the DARK from saturated scans
       to keep them at zero. */
    data = (data - dark) * (abs(data(,avg,-,))>1e-5);

    /* Put data back */
    imgData(i).regdata = &data;
  }

  yocoLogTrace, "pndrsRemoveDark done";
  return 1;
}

/* ******************************************************** */

func pndrsComputeMatrix(imgData, &imgLog, &matrix, &sig2matrix,
                        &matrixRaw, &sig2matrixRaw, gui=)
/* DOCUMENT pndrsComputeMatrix(imgData, imgLog, &matrix, &sig2matrix, gui=)

   DESCRIPTION
   Compute the photometric transmission matrix. The first 40 elements
   of the scans are discarded and all values of the scans are averaged.
   Return:
   matrix(lbd,nwin,ntel)

   Normalize by the average over the outputs (may be the sum??).
   Force theoretical matrix: small elements (<0.3) are forced to be zero.

   PARAMETERS
   - imgData: sould contain shutter sequence: 1000,0100,0010,0001
              not matter the order.

   - matrix, sig2matrix:
              
   SEE ALSO pndrsFlatField
 */
{
  yocoLogInfo,"pndrsComputeMatrix()";
  local data, id, i, Min, dim;
  local line, sig2line, norm, ntel, nwin,olog;
  matrix = matrixRaw = sig2matrixRaw = sig2matrix = fluxPsd = [];
  
  local shutterSequence;
  shutterSequence = ["1000","0100","0010","0001"];

  /* Compute the matrix line by line */
  ntel = 4;
  for (i=1 ; i<=ntel ; i++) {

    /* Search for the shutter sequence */
    id = where( pndrsGetShutters(imgData,imgLog) == shutterSequence(i) );
    if ( numberof(id)<1 ) {
      yocoLogWarning,"No data for shutter:",shutterSequence(i);
      continue;
    }

    /* Get data */
    pndrsGetData, imgData(id(1)), imgLog, data,, map, olog;
    nstep = dimsof(data)(3);
    nscan = dimsof(data)(4);
    nwin  = dimsof(data)(5);
    
    /* Remove the 40 first sample of the PICNIC
       in scan (if data contains scan long enough).
       Then average over the scan length */
    if ( olog.detName=="RAPID" ) {
      data = data(,avg,,);
    } else {
      yocoLogInfo," skip the first 40 sample in scan";
      Min  = ( nstep>50 ? 40 : 1 );
      data = data(,Min:,,)(,avg,,);
    }

    /* Average the scans */
    line = average(data, 2);
    sig2line = data(,rms,)^2.0 / nscan;

    // /* Test with RAPID: use the non-illuminated outputs to
    //    estimate the dark of the camera */
    // if ( olog.detName=="RAPID_TEST" ) {
    //   yocoLogInfo," use the non-illuminated outputs to guess the dark";
    //   empty = where( (map.t1!=i) & (map.t2!=i) );
    //   line -= median(line(,,,empty)(*));
    // }

    /* Grow the injection PSD */

    /* Grow the raw matrix */
    grow, matrixRaw, [line];
    grow, sig2matrixRaw, [sig2line];
  }

  /* Eventually plot the raw matrix */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui+1;
    pndrsPlotMatrix, gui+1, matrixRaw, olog;
  }

  /* Number of polarisation */
  pol   = yocoListClean (map.pol)(*);
  npol  = numberof (pol);  

  /* Loop again on telescope to normalise the matrix */
  for (i=1 ; i<=ntel ; i++) {

    /* Get the line */
    line = matrixRaw(..,i);
    sig2line = sig2matrixRaw(..,i);
    
    /* Expected transmission */
    theory = ( (map.t1==i) | (map.t2==i) );

    /* Force theoretical elements to be at zero */
    yocoLogInfo," force theoretical elements at 0.0";
    line     *= theory(-,);
    sig2line *= theory(-,);

    /* Deal with less than 3 telescope matrixes.
       FIXME: This may have side effect when changing
       during the night */
    if ( pndrsIsOnSky(olog) && (pndrsIssToPionier(olog,i)==0) )
    {
      yocoLogWarning,"This is a on-sky observation with missing beam "+pr1(i);
      // The matrix is forced with transmissive values
      line     = line*0 + 1.0*theory(-,);
      sig2line = sig2line*0 + 0.5 * theory(-,);
    } /* else check for low flux */
    else if ( (olog.detName=="RAPID") &&
         anyof((line<8.0) & (line!=0.0) & theory(-,)) )
    {
      yocoLogWarning,"This matrix has flux<8adu in beam "+pr1(i);
      yocoLogWarning,"QC quality flag set to T";
      imgLog.qcQualityFlag = char('T');
    }

    /* Normalize the average flux of each telescope,
       normalisation is done per spectral channel, so the
       relative flux between the channels is kept.
       For practical reason, the average of the kappa
       elements is set to 1 (explaining the factor 2,
       because each telescope illuminate half of the
       pixels). FIXME: what about polarisation */
    yocoLogInfo, " normalise the average flux of each telescope";
    for (p = 1; p <= npol; p++)
    {
        idp = where (map.pol == pol(p));
        norm = line(,idp,)(,*)(,avg) * 2   + 1e-10;
        line(,idp,)     /= norm;
        sig2line(,idp,) /= norm^2.0;
    }
    
    /* Check poor matrix quality */
    if ( anyof( (line(*)>2.5) | (line(*)<-0.2) ) ) {
      yocoLogWarning, "Bad Matrix on tel "+pr1(i)+": contains elements>2.5 or <0.4";
      yocoLogWarning, "QC quality flag set to T";
      imgLog.qcQualityFlag = char('T');
    }

    /* Grow the normalized matrix */
    yocoLogInfo, " grow the normalized matrix";
    grow,     matrix, [line];
    grow, sig2matrix, [sig2line];
  }

  /* QC parameters: RMS of kappa for each telescope,
     and average of 2sqrt(kappa1xkappa2)/(kappa1+kappa2) for each baseline */
  yocoLogInfo, " qc as rms of kappa matrix";
  Rms = array(0.0, 4);
  Avg = array(0.0, 4);
  for (b=1;b<=4;b++) {
    id = where(matrix(*,b));
    Rms(b) = matrix(*,b)(id)(rms);
    Avg(b) = matrixRaw(*,b)(id)(avg);
  }
    
  yocoLogInfo, " qc as equivalent vis";
  Vis = array(0.0, max(map.base));
  for (b=1;b<=max(map.base);b++) {
    id = where(map.base==b);
    prod = matrix(,id,map(id(1)).t1) *  matrix(,id,map(id(1)).t2);
    tmp = 2.*sign(prod)*sqrt(abs(prod)) /
      (matrix(,id,map(id(1)).t1) +  matrix(,id,map(id(1)).t2) + 1e-10);
    Vis(b) = tmp(*)(sum) / (tmp!=0)(*)(sum);
  }

  /* Write these parameters */
  yocoLogInfo," add QC parameters";
  id = oiFitsGetId(imgData(1).hdr.logId, imgLog.logId);
  tel = indgen(ntel);
  pndrsSetLogInfoArray, imgLog, id, "qcKappa%iRms", tel, Rms;
  pndrsSetLogInfoArray, imgLog, id, "qcKappaRaw%iAvg", tel, Avg;
  iss = totxt( pndrsPionierToIss(imgLog(id), [map.t1,map.t2]) )(,sum);
  iss = yocoListClean(iss);
  pndrsSetLogInfoArray, imgLog, id, "qcKappa%sAvg", iss, Vis;
  

  /* Check if polarisation matrix, in this case we reform the matrix
     to have the correct size for independent flux in polarisations.
     FIXME: Make sure this is compatible with 'pndrsGetPolTelInMap' */
  if ( anyof(map.pol=="Pup") && anyof(map.pol=="Pdown") ) {
    yocoLogInfo,"Reform matrix because it is 2-pol";
    matrix = grow(matrix,matrix);
    matrix(..,where(map.pol==map(1).pol),ntel+1:) *= 0;
    matrix(..,where(map.pol!=map(1).pol),1:ntel)  *= 0;
  }

  /* Eventually plot the matrix */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui;
    pndrsPlotMatrix, gui, matrix, olog;
    yocoNmRange,-0.2,3;    
  }

  yocoLogTrace,"pndrsComputeMatrix done";
  return 1;
}

/* ******************************************************** */

func pndrsFlatField(&imgData, imgLog, &matrix, flatMatrix=, checkFlat=)
/* DOCUMENT pndrsFlatField(&imgData, imgLog, &matrix, flatMatrix=, checkFlat=)

   DESCRIPTION
   Perform the interferometric FLAT-FIELD of all data in imgData.
   ff = vis * sqrt(k1.k2)
   imgData = imgData / ff

   For consistency, and if flatMatrix=1,
   the matrix is also FLAT-FIELDED:
   matrix = matrix / ff

   PARAMETERS
   - imgData, imgLog
   - matrix

   SEE ALSO pndrsComputeMatrix
 */
{
  yocoLogInfo, "pndrsFlatField()";
  local i, data, ff, dim, nopd, nwin, map;
  local t1, t2;

  /* Default */
  if ( is_void(checkFlat) ) checkFlat=1;

  /* get the map from the first imgData,
     assume to the the same for all data */
  map  = *oiFitsGetOiLog(imgData(1), imgLog).correlation;

  /* 1) Compute the normalisation factor:
     ff = vis * sqrt(k1*k2).
     ff(nlbd, nopd, nscan, nwin) */
  ff = matrix(..,1) * 0.0;
  for ( i=1 ; i<=max(map.win) ; i++) {
    t1 = pndrsGetPolTelInMap(map,i,1);
    t2 = pndrsGetPolTelInMap(map,i,2);
    ff(..,i) = map(i).vis * sqrt( max(matrix(,i,t1) *
                                      matrix(,i,t2), 0) );
  }

  /* Avoid zero. */
  if ( anyof(ff(*)==0) && checkFlat) yocoLogWarning,"FF has 0.0 elements... impossible ?";
  ff = ff + (ff==0);
  
  /* 2) Apply this FLAT-FIELD to all data */
  for (i=1;i<=numberof(imgData);i++) {

    /* Get the data and flat-field */
    data = ( *imgData(i).regdata ) / ff(,-,-,);

    /* Put data back */
    imgData(i).regdata = &data;
  }

  /* 3) Apply this FLAT-FIELD to the matrix itself */
  if (flatMatrix==1) matrix = matrix / ff;
  
  yocoLogTrace, "pndrsFlatField done";
  return 1;
}

/* ******************************************************** */

func pndrsComputeInputFlux(imgData, imgLog, matrix, &flux, gui=)
/* DOCUMENT pndrsComputeInputFlux(imgData, imgLog, matrix, &flux, gui=)

   DESCRIPTION
   Compute the flux at the input of the instrument, based on the
   kappa-matrix and the real-time data in imgData.
   
   Hypothesis to compute separately flux and fringes:
   - we have only one fringe system per output
   - fringes fully cancel once summed over the windows related to a baseline
   - a 'full' kappa is still manageable.
   
   ** Step A:
   hypothesis: fringes cancel once summed over all the pixels
   of a given baseline (matrix M63). To ensure this, one should
   first perform the interferometric flat-field with
   pndrsFlatField.
   
   flux = inv(M63 * matrixf) *  (M63 * dataf)
   
   ** Step B:
   Solve the system, that is recover A,B,C.
   Now we should decide the dimension of flux:
   is (x,y,nopd,nscan,ntel) or (1,1,1,nscan,ntel)
   for instance for bright and faint case.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsComputeInputFlux()";
  local i, data, norm, dim, ff, id, map, opd, olog;
  ff = datab = kapab = dataf = kapaf = [];

  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }

  /* Get the data */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  nbase = max(map.base);
  ntel  = dimsof(matrix)(0);
  nlbd  = dimsof(data)(2);
  nopd  = dimsof(data)(3);

  /* Prepare some arrays */
  dim    = dimsof(data)(2:);
  datab  = data(,,,1:nbase) * 0.0;
  kapab  = matrix(,1:nbase,) * 0.0;
  flux   = data(,,,1:ntel) * 0.0;

  /*  A) Now sum over the windows for each baseline.
      The hypothesis is that the fringe signal should
      cancel (couplers are loss-less).
      - datab (y,nopd,nscan,nbase)
      - kapab (y,nopd,nscan,nbase,ntel)
  */
  yocoLogTrace,"Sum over the windows";
  for ( idm=[],i=1 ; i<=nbase ; i++)
  {
    id = where( map.base == i );
    datab(,,,i)  = data(,,,id)(,,,sum);
    kapab(,i,) = matrix(,id,)(,sum,);
    grow,idm,id(1);
  }

  /* If gui, plot the spectra */
  if ( gui && pndrsBatchPlotLevel ) {

    yocoLogTrace,"Make some plots";
    winkill,gui+3;
    nwin  = dimsof(datab)(0);
    psd = power(fft(datab,[0,1,0,0]))(,:nopd/2,,);
    yocoNmCreate,gui+3,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, psd(0,,avg,),tosys=indgen(nwin);
    yocoPlotPlgMulti, psd(1,,avg,),tosys=indgen(nwin),color="red";
    yocoNmLogxy,0,1;
    sta  = pndrsPlotGetBaseName(olog)(idm);
    main = swrite(format="%s - %.4f", olog.target, (*imgData.time)(*)(avg));
    pndrsPlotAddTitles,sta,main;
  }  

  /*  B) Now solve the system.
      Put datab in the forme
      (nbase,y,nodp,scan) */
  yocoLogTrace,"Solve the system";
  datab = transpose( datab, 2);

  /* Case bright target, we solve independently for each
     opd position and lambda (y):
     flux(i,k,l,) = QRsolve( kappaff(i,,), dataff(,i,k,l,) ) */
  for ( i=1 ; i<=dim(1) ; i++)
    {
      solve = QRsolve( kapab(i,,), datab(,i,,) );
      flux(i,,,) = transpose( solve, 0 );
    }

  /* If gui, plot the spectra */
  if ( gui && pndrsBatchPlotLevel ) {
    nwin  = dimsof(flux)(0);
    winkill,gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, flux(,avg,avg,),tosys=indgen(nwin);
    yocoPlotPlpMulti, flux(,avg,avg,),tosys=indgen(nwin),symbol=4,fill=1;
    yocoNmRange;
    yocoNmRange,0;
    yocoNmRangex,0.5,nlbd+0.5;
    titles = pndrsGetLogInfo(olog,"issStation%i",[1,2,3,4]);
    main   = swrite(format="%s - %.4f", olog.target, (*imgData.time)(*)(avg));
    pndrsPlotAddTitles,titles,main,"Average telescope flux","spec. channel","flux";

    psd = power(fft(flux,[0,1,0,0]))(,:nopd/2,,);
    winkill,gui+1;
    yocoNmCreate,gui+1,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, psd(0,,avg,),tosys=indgen(nwin);
    yocoPlotPlgMulti, psd(1,,avg,),tosys=indgen(nwin),color="red";
    yocoNmLogxy,0,1;
    pndrsPlotAddTitles,titles,main;

    winkill,gui+2;
    yocoNmCreate,gui+2,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, flux(0,1:nopd/2,[1],)(*,),tosys=indgen(nwin);
    yocoPlotPlgMulti, flux(1,1:nopd/2,[1],)(*,),tosys=indgen(nwin),color="red";
    yocoNmRange; yocoNmRange,0;
    pndrsPlotAddTitles,titles,main;
  }
  
  yocoLogTrace,"pndrsComputeInputFlux done";
  return 1;
}

/* ******************************************************** */

func pndrsRemoveContinuum(&imgData, imgLog, matrix, flux, gui=)
/* DOCUMENT pndrsRemoveContinuum(&imgData, imgLog, matrix, flux, gui=)

   DESCRIPTION
   Remove the continuum (a1.A + b1.B + c1.C) from the data. The continuum
   is estimated with flux * matrix.
   
   PARAMETERS

   EXAMPLES

   SEE ALSO pndrsScan
 */
{
  yocoLogInfo, "pndrsRemoveContinuum()";
  local i, data, dim, opd, map, nbase, cont, olog;
  
  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }

  /* Get the data */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  nbase = dimsof(data)(0);
  nlbd  = dimsof(data)(2);
  

  /* Get the photometric continuum and remove it,
     no filtering at this stage since this would
     change the PSD shape. */
  dim = dimsof(data)(2:);
  cont = data*0.0;
  for ( i=1 ; i<=dim(1) ; i++)
    {
      cont(i,,,)  = flux(i,,,+) * matrix(i,,+);
    }

  
  /* Put data back */
  datac = data - cont;
  imgData(1).regdata = &datac;
  
  /* if gui */
  if (gui && pndrsBatchPlotLevel) {
    main = swrite(format="%s - %.4f", olog.target, (*imgData.time)(*)(avg));
    
    winkill,gui;
    yocoNmCreate,gui,2,nbase/2,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,data(avg,,1:3,)(*,),tosys=indgen(nbase);
    yocoPlotPlgMulti,cont(avg,,1:3,)(*,),tosys=indgen(nbase),color="red";
    yocoNmRange;
    sta = pndrsPlotGetBaseName(olog);
    pndrsPlotAddTitles,sta,main;

    winkill,gui+1;
    yocoNmCreate,gui+1,nbase,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,average(datac(,avg,,),2),tosys=indgen(nbase);
    yocoPlotPlpMulti,average(datac(,avg,,),2),tosys=indgen(nbase),symbol=4,fill=1;
    yocoNmRange;
    yocoNmLimits,0.5,nlbd+0.5;
    sta = pndrsPlotGetBaseName(olog);
    pndrsPlotAddTitles,sta,main;

    winkill,gui+2;
    yocoNmCreate,gui+2,2,nbase,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,datac(avg,,1:3,)(*,),tosys=indgen(nbase);
    yocoNmRange;
    sta = pndrsPlotGetBaseName(olog);
    pndrsPlotAddTitles,sta,main;
  }
 
  yocoLogTrace, "pndrsRemoveContinuum done";
  return 1;
}

/* ******************************************************** */

func pndrsComputeCoherentFluxMatrix(imgData, matrix, &imgLog, &coherData, &flux, &cont, &coher, gui=)
/* DOCUMENT pndrsComputeCoherentFluxMatrix(imgData, matrix, &imgLog, &coherData,
            &flux, &cont, &coher, gui=, check=)

   DESCRIPTION
   Compute the coherent flux per baseline and the photometric flux
   per input beam by combining the ABCD outputs.

   Data are stored in new structure coherData.

   PARAMETERS
   - imgData : should be scalar
   - imgLog
*/
{
  yocoLogInfo,"pndrsComputeCoherentFluxMatrix()";
  local i, data, id, nbase, opd, map, out;
  local dataC, dataI, coher, incoh, olog, t1, t2;
  extern pndrsFilterWide;

  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }
  /* Get data */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  nlbd  = dimsof(data)(2);
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nwin  = dimsof(data)(5);
  nbase = max(map.base);
  ntel  = pndrsGetPolNtelInMap(map); //max(max(map.t1),max(map.t2));

  v2pm = array(0.0, nlbd, nwin, ntel + 2*nbase);

  /* FIXME: use the matrixError to compute the
     relative weight of each output. These errors could be
     hardcoded so that they are the same for all files.
     Or use a "bad pixel map". */
  dataAvg = data(,avg,avg,);
  fluxAvg = array(0.0,nlbd,ntel);
  resAvg = array(0.0,nlbd,nwin);
  for(i=1;i<=nlbd;i++) {
    fluxAvg(i,) = QRsolve(matrix(i,,),dataAvg(i,),which=0);
    resAvg(i,)  = dataAvg(i,) - matrix(i,,+) * fluxAvg(i,+);
  }
  yocoLogInfo," residuals in ADUs:";
  for (i=1;i<=nwin;i++)
    yocoLogInfo,swrite(format="%+9.2f ",resAvg(,i))(sum);

  /* Put pk => photometries */
  v2pm(,,1:ntel) = matrix;

  /* Put ck and dk => fringes */
  for ( i=1; i<=nbase; i++ )
  {
    id = where(map.base==i);
    t1 = pndrsGetPolTelInMap(map,id(1),1);
    t2 = pndrsGetPolTelInMap(map,id(1),2);
    V  = ( map(id).vis * exp(1.i*map(id).phi) )(-,) * sqrt( max( matrix(,id,t1) * matrix(,id,t2), 0) );
    v2pm(,id,ntel+i)       = V.re;
    v2pm(,id,ntel+nbase+i) = V.im;
  }

  /* Solve to estimate telescopes fluxes and coherent fluxes.
     This is done independently for each channel */
  out  = array(0.0,nlbd,nstep,nscan,ntel+2*nbase);
  for(i=1;i<=nlbd;i++) {
    out(i,) = QRsolve(v2pm(i,,),data(i,),which=0);
  }

  /* Get telescope fluxes and coherent fluxes.
     These are part of the output vector */
  flux  = out(..,1:ntel);
  coher = ( out(..,ntel+1:ntel+nbase) + 1.i * out(..,ntel+nbase+1:) ) / 2.0;

  /* Build coherData */
  coherData = imgData(*)(1);
  coherData.regdata = &coher;
  coherData.hdr.logId = max(imgLog.logId) + 1;

  /* Build the associated imgLog */
  imgLog = grow( imgLog, oiFitsGetOiLog(imgData, imgLog) );
  imgLog(0).logId = max(imgLog.logId) + 1;
  imgLog(0).correlation = &( yocoListClean(map,map.base) );
  mapCoher = *imgLog(0).correlation;

  /* Computation of the flux per win by
     re-injecting the input fluxes into the v2pm */
  cont = array(0.0,nlbd,nstep,nscan,nwin);
  for(i=1;i<=nlbd;i++)
    cont(i,) = flux(i,,,+) * (v2pm(i,,1:ntel))(,+);

  /* Default gui */
  if (gui && pndrsBatchPlotLevel) {
    nbase = dimsof(coher)(0);
    sta  = pndrsPlotGetBaseName(imgLog(0));
    main = swrite(format="%s - %.4f", imgLog(0).target, (*imgData.time)(*)(avg));
    
    winkill, gui;
    yocoNmCreate,gui,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(coher.re(,avg,,),2),tosys=indgen(nbase);
    yocoPlotPlpMulti, average(coher.re(,avg,,),2),tosys=indgen(nbase),symbol=4, fill=1;
    yocoPlotPlgMulti, average(coher.im(,avg,,),2),tosys=indgen(nbase), color="red";
    yocoPlotPlpMulti, average(coher.im(,avg,,),2),tosys=indgen(nbase),symbol=4, fill=1, color="red";
    yocoNmRange,-3,3;
    yocoNmLimits,0.5,nlbd+0.5;
    pndrsPlotAddTitles,sta,main,"Average coherent flux (black=real part, red=imag. part)","spec. channel","flux";

    winkill,gui+1;
    yocoNmCreate,gui+1,2,nwin/2,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,data(avg,,1:3,)(*,),tosys=indgen(nwin);
    yocoPlotPlgMulti,cont(avg,,1:3,)(*,),tosys=indgen(nwin),color="red";
    yocoNmRange;
    sta = pndrsPlotGetBaseName(olog);
    pndrsPlotAddTitles,sta,main,"data and continuum (all channels collapsed)","opd step (3 scans)","flux";

    datac = data - cont;
    
    winkill,gui+2;
    yocoNmCreate,gui+2,2,nwin/2,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,average(datac(,avg,,),2),tosys=indgen(nwin);
    yocoPlotPlpMulti,average(datac(,avg,,),2),tosys=indgen(nwin),symbol=4,fill=1;
    yocoNmRange;
    yocoNmLimits,0.5,nlbd+0.5;
    sta = pndrsPlotGetBaseName(olog);
    pndrsPlotAddTitles,sta,main,"Average data-continuum","spec. channel","flux";

    winkill,gui+3;
    yocoNmCreate,gui+3,2,nwin/2,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,datac(avg,,1:3,)(*,),tosys=indgen(nwin);
    yocoNmRange;
    sta = pndrsPlotGetBaseName(olog);
    pndrsPlotAddTitles,sta,main,"data-continuum (all channels collapsed)","opd step (3 scans)","flux";

    winkill,gui+4;
    yocoNmCreate,gui+4,2,nbase/2,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,flux(avg,,1:3,mapCoher.t1)(*,),tosys=indgen(nwin),color="blue";
    yocoPlotPlgMulti,flux(avg,,1:3,mapCoher.t2)(*,),tosys=indgen(nwin),color="cyan";
    yocoNmRange;
    sta = pndrsPlotGetBaseName(imgLog(0));
    pndrsPlotAddTitles,sta,main,"Telescope flux (all channels collapsed)","opd step (3 scans)","flux";
    
    winkill,gui+5;
    nwin  = dimsof(flux)(0);
    yocoNmCreate,gui+5,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(flux(,avg,,),2),tosys=indgen(nwin);
    yocoPlotPlpMulti, average(flux(,avg,,),2),tosys=indgen(nwin),symbol=4,fill=1;
    yocoNmRange;
    yocoNmRange,0;
    yocoNmRangex,0.5,nlbd+0.5;
    titles = pndrsGetLogInfo(olog,"issStation%i",[1,2,3,4]);
    main   = swrite(format="%s - %.4f", olog.target, (*imgData.time)(*)(avg));
    pndrsPlotAddTitles,titles,main,"Average telescope flux","spec. channel","flux";

    winkill,gui+6;
    nwin  = dimsof(flux)(0);
    yocoNmCreate,gui+6,1,nwin,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, flux(avg,,1:3,)(*,), tosys=indgen(nwin);
    yocoNmRange;
    yocoNmRange,0;
    titles = pndrsGetLogInfo(olog,"issStation%i",[1,2,3,4]) + " / " + pndrsGetLogInfo(olog,"issTelName%i",[1,2,3,4]);
    main   = swrite(format="%s - %.4f", olog.target, (*imgData.time)(*)(avg));
    pndrsPlotAddTitles, titles, main, "Telescope flux (averaged over lbd)","opd step (3 scans)","flux";
  }
  
  return 1;
}


func pndrsComputeCoherentFlux(imgData, &imgLog, &coherData, gui=, check=)
/* DOCUMENT pndrsComputeCoherentFlux(imgData, &imgLog, &coherData, gui=, check=)

   DESCRIPTION
   Compute the coherent flux per baseline by combining the ABCD
   outputs. Practically, each output (ABCD) is multiplied by the
   associated phase-shift in imgLog.correlation, and the ABCD
   outputs are then summed.

   Data are stored in new structure coherData.

   PARAMETERS
   - imgData : should be scalar
   - imgLog

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsComputeCoherentFlux()";
  local i, data, id, nbase, opd, map;
  local dataC, dataI, coher, incoh, olog;
  extern pndrsFilterWide;
  
  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }

  /* Get the data and the correlation map */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  nbase = max(map.base);
  nlbd  = dimsof(data)(2);

  /* Apply the relative phase shift between the windows */
  dataC = complex(data) * exp( 1.i * (map.phi +2.*pi))(-,-,-,);

  /* Now AVERAGE over the windows for each baseline. So that we get:
     ( 2.AB.fringes + 2.AB.fringes ) / 2
     ( 2.AC.fringes + 2.AC.fringes ) / 2
     ( 2.BC.fringes + 2.BC.fringes ) / 2
  */
  coher  = dataC(,,,1:nbase) * 0.0i;
  for ( i=1 ; i<=nbase ; i++)
  {
    id = where( map.base == i );
    coher(,,,i) = dataC(,,,id)(,,,avg);
  }
    
  /* Build coherData */
  coherData = imgData(*)(1);
  coherData.regdata = &coher;
  coherData.hdr.logId = max(imgLog.logId) + 1;

  /* Build the associated imgLog */
  imgLog = grow( imgLog, oiFitsGetOiLog(imgData, imgLog) );
  imgLog(0).logId = max(imgLog.logId) + 1;
  imgLog(0).correlation = &( yocoListClean(map,map.base) );
  
  /* If asked to plot the phase check.
     Note that that Fourier Transform is very time-consuming here,
     because the ABCD are still not averaged. */
  if (check && pndrsBatchPlotLevel) {
    yocoLogInfo,"Current phases: ",map.phi/pi;
    winkill, check;
    yocoNmCreate,check,1,nbase,dy=0;
    pndrsSignalSquareFiltering, dataC, opd, pndrsFilterWide, dataf;
    dataf = dataf(avg,,3,)(*,);
    for ( i=1 ; i<=nbase ; i++)
    {
        id = where( map.base == i );
        yocoPlotPlgMulti,dataf(,id).re, opd(,3,id), tosys=i;  
        yocoPlotPlgMulti,dataf(,id).im, opd(,3,id), color="red", tosys=i;
    }
    pause,10;
  }

  /* Default gui */
  if (gui && pndrsBatchPlotLevel) {
    nwin = dimsof(coher)(0);
    sta  = pndrsPlotGetBaseName(imgLog(0));
    main = swrite(format="%s - %.4f", imgLog(0).target, (*imgData.time)(*)(avg));
    
    winkill, gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(coher.re(,avg,,),2),tosys=indgen(nwin);
    yocoPlotPlpMulti, average(coher.re(,avg,,),2),tosys=indgen(nwin),symbol=4, fill=1;
    yocoNmRange,-3,3;
    yocoNmLimits,0.5,nlbd+0.5;
    pndrsPlotAddTitles,sta,main;
  }
  
  yocoLogTrace,"pndrsComputeCoherentFlux done";
  return 1;
}

func pndrsComputeCoherentNull(imgData, &imgLog, &coherData, gui=, check=)
/* DOCUMENT pndrsComputeCoherentNull(imgData, &imgLog, &coherData, gui=, check=)

   DESCRIPTION

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsComputeCoherentNull()";
  local i, data, id, nbase, opd, map;
  local dataC, dataI, coher, incoh, olog;
  extern pndrsFilterWide;
  
  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }

  /* Get the data and the correlation map */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  nbase = max(map.base);
  nlbd  = dimsof(data)(2);
  nwin  = dimsof(data)(0);

  phi = map.phi + [0.,pi](,-:1:nwin/2)(*);

  /* Apply the relative phase shift between the windows */
  dataC = complex(data) * exp( 1.i * (phi +2.*pi))(-,-,-,);

  /* Now AVERAGE over the windows for each baseline. So that we get:
     ( 2.AB.fringes + 2.AB.fringes ) / 2
     ( 2.AC.fringes + 2.AC.fringes ) / 2
     ( 2.BC.fringes + 2.BC.fringes ) / 2
  */
  coher  = dataC(,,,1:nbase) * 0.0i;
  for ( i=1 ; i<=nbase ; i++)
  {
    id = where( map.base == i );
    coher(,,,i) = dataC(,,,id)(,,,avg);
  }
    
  /* Build coherData */
  coherData = imgData(*)(1);
  coherData.regdata = &coher;
  coherData.hdr.logId = max(imgLog.logId) + 1;

  /* Build the associated imgLog */
  imgLog = grow( imgLog, oiFitsGetOiLog(imgData, imgLog) );
  imgLog(0).logId = max(imgLog.logId) + 1;
  imgLog(0).correlation = &( yocoListClean(map,map.base) );
  
  /* If asked to plot the phase check.
     Note that that Fourier Transform is very time-consuming here,
     because the ABCD are still not averaged. */
  if (check && pndrsBatchPlotLevel) {
    yocoLogInfo,"Current phases: ",map.phi/pi;
    winkill, check;
    yocoNmCreate,check,1,nbase,dy=0;
    pndrsSignalSquareFiltering, dataC, opd, pndrsFilterWide, dataf;
    dataf = dataf(avg,,1:3,)(*,);
    for ( i=1 ; i<=nbase ; i++)
    {
        id = where( map.base == i );
        yocoPlotPlgMulti,dataf(,id).re, tosys=i;  
        yocoPlotPlgMulti,dataf(,id).im,color="red", tosys=i;
        yocoNmRangex,500,550;
    }
    pause,10;
  }

  /* Default gui */
  if (gui && pndrsBatchPlotLevel) {
    nwin = dimsof(coher)(0);
    sta  = pndrsPlotGetBaseName(imgLog(0));
    main = swrite(format="%s - %.4f", imgLog(0).target, (*imgData.time)(*)(avg));
    
    winkill, gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(coher.re(,avg,,),2),tosys=indgen(nwin);
    yocoPlotPlpMulti, average(coher.re(,avg,,),2),tosys=indgen(nwin),symbol=4, fill=1;
    yocoNmRange,-3,3;
    yocoNmLimits,0.5,nlbd+0.5;
    pndrsPlotAddTitles,sta,main;
  }
  
  yocoLogTrace,"pndrsComputeCoherentNull done";
  return 1;
}

/* ************************************************************* */

func pndrsScan(void)
/* DOCUMENT pndrsScan -- basic utilities to reduce scan data

   hypothesis to compute separately flux and fringes:
   - we have only one fringe system per output (equations of step A)
   - fringes fully cancel once summed over the windows related to a baseline
   - a 'full' kappa is still manageable.
   
   Here is an example with IOTA-3 like data:
   data =  (a1.A  + b1.B + c1.C )  +  2.(v1.a1b1).AB.fringes + dark1
           (a2.A  + b2.B + c2.C )  -  2.(v2.a2b2).AB.fringes + dark2
           (a3.A  + b3.B + c3.C )  +  2.(v3.a3c3).AC.fringes + dark3
           (a4.A  + b4.B + c4.C )  -  2.(v4.a4c4).AC.fringes + dark4
           (a5.A  + b5.B + c5.C )  +  2.(v5.b5c5).BC.fringes + dark5
           (a6.A  + b6.B + c6.C )  -  2.(v6.b6c6).BC.fringes + dark6

   Step 1:
   Remove the dark
   data = data - dark
   

   Step 2:
   Compute the photometric matrix
   matrix =  [a1,b1,c1
              a2,b2,c2
              ...
              a6,b6,c6]

              
   Step 3:
   Flat-field the data
   ff = [v1.a1b1, v2.a2b2, v3.a3c3, ..., v6.b6c6] 
   dataf   = data / ff
   matrixf = matrix / ff

   dataf   = (a1.A  + b1.B + c1.C )/(v1.a1b1)  +  2.AB.fringes
   matrixf = [a1,b1,c1]/(v1.a1b1)


   Step 4:
   Compute the input flux [A,B,C]
   We assume that fringes cancel once summed over all the pixels
   of a given baseline (matrix M63 for the IOTA-3).
   flux = inv(M63 * matrixf) *  (M63 * dataf)
   flux = [A,B,C]

   
   Step 5:
   Remove the continuum
   datafc = dataf  -  matrixf * flux
   datafc = 2.AB.fringes

   
   Step 6:
   Compute the coherent flux by averaging over all the outputs
   of a given baseline, taking into account the phase shift:
   coher  = ( 2.AB.fringes1.phasor1 + 2.AB.fringes2.phasor2 + 2.AB.fringes3.phasor3 + 2.AB.fringes4.phasor4 ) / 4

   -------------------
   Case we need to perform the substraction of un-flat-fielded data,
   for instance because we want to remove electronics contamination.
   
   Step5'
   datatest = data - matrix * flux
   datatest = 2.(v1.a1b1).AB.fringes

   Step6'
   Hypothesis is that the fringes are in phase opposite
   datatestCleanX = 2.AB.fringes (v1.a1b1 + v2.a2b2)    => here the common-mode perfectly cancels
   datatestCleanX = 2.AB.fringes (v3.a3b3 + v4.a4b4)    => here the common-mode perfectly cancels
   coherClean = (datatestCleanX.phasorX + datatestCleanY.phasorY ) / 4



   ----------------------------------------------------------------
   Notes:
   I though the step 5 would introduce additional noise in the data, and therefore
   I tested several solution (after dark-removal):
   a) pndrsComputeCoherentFlux
   b) pndrsFlatField + pndrsComputeCoherentFlux
   c) pndrsFlatField + pndrsComputeInputFlux + pndrsRemoveContinuum + pndrsComputeCoherentFlux

   It appears that the continuum is well removed in all 3 cases (slightly better with c),
   but that the noise is also the same in the final coherentFlux product.


   After matrix inversion, for the poor baseline, I use the AC trick:
   datac = data - matrix * flux = 2.(v1.a1b1).AB.fringes
   datacX = datac(,1) - datac(,2) = 2.AB.fringes.(v1.a1b1 + v2.a2b2)
   datacY = datac(,3) - datac(,4) = 2.AB.fringes.(v3.a3b3 + v4.a4b4)
   coher  = (datacX.phasorX + datacY.phasorY) / 4

   FFT(coher), replace negative frequencies by average bias
   value measured at the highest frequencies only.
   
*/
{
  help,pndrsScan;
}


/* ******************************************************** */

func pndrsScanComputeClosurePhases(coherData, imgLog, norm2, pos, &oiT3, &clo, &cloErr, gui=)
/* DOCUMENT pndrsScanComputeClosurePhases(coherData, imgLog, &oiT3, &clo, &cloErr, gui=)

   DESCRIPTION
   Perform an estimate of the closure-phase with the following method:
   - filter the data
   - compute the bispectrum in the direct space (coherData should be complex)
   - average the bispectrum over the nopd
   - bootstrap the bispectrum over the nscan
   - take the phase
   - average/rms over the nboot

   PARAMETERS
   - coherData: should contain complex scans

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanComputeClosurePhases()";
  local i, data, opd, nbase, bispectrum, map, ntel, dx, polId, staId, l;
  local nscan, boot, pol, npol, baseId, filt, predWidth, lbd0, sig0, lbdB;
  local t3Amp, t3AmpErr, clo, cloErr;
  
  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;
  nbase = dimsof(data)(0);
  nstep = dimsof(data)(3);
  ntel  = pndrsGetNtelInMap(map); 
  pol   = yocoListClean(map.pol)(*);
  npol  = numberof(pol);
  nlbd  = dimsof(data)(2);

  /* Default Wave */
  pndrsGetDefaultWave, oLog, lbd0, lbdB, sig0;

  /* Filter the data */
  // if (strmatch( pndrsGetBand(oLog(1)), "K") ) filt = pndrsFilterKClo;
  // if (strmatch( pndrsGetBand(oLog(1)), "H") ) filt = pndrsFilterHClo;
  // pndrsSignalSquareFiltering, data, opd, filt, dataf;

  /* Compute the predicted width of the pic based on
     the tau0 and scanning speed */
  predWidth = pndrsGetPicWidth(oLog, checkUTs=1);
  
  /* Filter around the expected frequency with expected width.
     Force the filter the very low frequencies. FIXME: this could
     probably be improved with a Gaussian-cut filter */
  pndrsSignalFourierTransform, data, opd, ft, freq;
  ft *= ((indgen(nstep) > 15) & (indgen(nstep) < (nstep/2-5)))(-,) &
    ( abs(abs(freq)(-,)-sig0) < predWidth(,-,-,) );

  /* Come back in direct space */
  pndrsSignalFourierBack, ft, freq, dataf;
  
  /* Loop over all the possible 3T closure phase,
     hypothesis is that the map has t1<t2. Closure phases
     are in the order 123, 124, 134, 234 */
  for (p=1 ; p<=npol ;p++)
    for( i=1 ; i<=ntel-2 ; i++)
      for( j=i+1 ; j<=ntel-1 ; j++)
        for( k=j+1 ; k<=ntel ; k++)
          {
            grow, baseId, 
              [[where(map.t1==i & map.t2==j & map.pol==pol(p))(1),
                where(map.t1==j & map.t2==k & map.pol==pol(p))(1),
                where(map.t1==i & map.t2==k & map.pol==pol(p))(1)]];
            grow, staId, [ [i,j,k] ];
            grow, polId, p;
          }

  /* Compute the bispectrum (x,y,nopd,nscan,closure) */
  d = dimsof(data);
  bispectrum = dataf(,,,baseId(1,)) * dataf(,,,baseId(2,)) * conj( dataf(,,,baseId(3,)) );

  /* Average over the opds. Now dimension is
     [lbd, scan, bispectrum]   */
  bispectrum  = bispectrum(,avg,,);

  /* Compute the phase average and errors */
  pndrsSignalComputePhase, bispectrum,
    clo, cloErr, gui=gui;

  /* Compute the expected amplitude of the bispectrum */
  opd = opd - opd(avg,-,) - pos(-,);
  env = exp(- (pi*opd(-,)/lbd0^2*lbdB)^2 / 5.0);
  norm2env = env^2 * norm2;
  bispnorm = sqrt(abs(norm2env(,,,baseId(1,)) * norm2env(,,,baseId(2,)) *
                      norm2env(,,,baseId(3,))));
  bispnorm = bispnorm(,avg,,);

  /* Use a coherent estimator for the bispectrum */
  bispectrum_re = ( bispectrum * exp( -2.i*pi * clo(,-,) / 360.0 ) ).re;
  pndrsSignalComputeAmp2Ratio, bispectrum_re, bispnorm,
    t3Amp, t3AmpErr, gui=gui+2, square=0;
  
  /* build the oiT3 */
  oiT3 = [];
  nclo = dimsof(baseId)(0);
  log  = oiFitsGetOiLog(coherData, imgLog);
  oiT3 = array( oiFitsGetOiStruct("oiT3", -1), nclo);
  oiT3.hdr.logId   = log.logId;
  oiT3.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiT3.mjd         = (*coherData.time)(*)(avg);
  oiT3.intTime     = (*coherData.exptime)(sum);
  oiT3.staIndex    = staId;

  /* Fill the data */
  flag = char(cloErr>30.0);
  oiFitsSetDataArray, oiT3,,t3Amp, t3AmpErr, clo, cloErr, flag;

  /* Build the default insName */
  oiT3.hdr.insName = pndrsDefaultInsName(log, pol(polId));

  /* Add QC parameters */
  yocoLogInfo," add QC parameters";
  id = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  iss = totxt( pndrsPionierToIss(imgLog(id), staId) )(sum,);
  pndrsSetLogInfoArray, imgLog, id, "qcPhi%sAvg", iss, averagePhase(clo,1);
  pndrsSetLogInfoArray, imgLog, id, "qcPhi%sErr", iss, average(cloErr,1);

  /* Plot the gui */
  if (gui && pndrsBatchPlotLevel) {
    sta  = (pndrsGetLogInfo(oLog,"issStation%i",staId)+["-","-",""])(sum,);
    if (allof(sta=="--"))
      sta  = (totxt(staId)+["-","-",""])(sum,);
    main = swrite(format="%s - %.4f", oLog.target, (*coherData.time)(*)(avg));
    
    window,gui;
    pndrsPlotAddTitles,sta,main,"Complex bispectrum for all scans (first, middle, last channels)",
      "Re{bispectrum}", "Im{bispectrum}";

    window,gui+2;
    pndrsPlotAddTitles,sta,main,"Computation of t3amp", "Normalisation amplitude","Re{bispectrum}";
    
    winkill,gui+1;
    yocoNmCreate,gui+1,nclo,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,clo,tosys=indgen(nclo),symbol=0,dy=cloErr;
    yocoPlotPlgMulti,clo,tosys=indgen(nclo);
    yocoNmLimits,0.5,nlbd+0.5,max(-180,min(clo-5)),min(180,max(clo+5));
    pndrsPlotAddTitles,sta,main,"Final closure phases","spec. channel","closures";
  }

  yocoLogInfo,"pndrsScanComputeClosurePhases done";
  return 1;
}

/* ******************************************************** */

func pndrsScanComputePolarDiffPhases(imgData, imgLog, &oiVis, &phases, &phasesErr, gui=)
/* DOCUMENT pndrsScanComputePolarDiffPhases(imgData, imgLog, &oiVis, &phases, &phasesErr, gui=)

   DESCRIPTION
   Compute the differential phase between the polarisations.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanComputePolarDiffPhases()";
  local i, data, opd, nbase, bispectrum, map, dataf;
  local pol, npol, lbd, lbdb, olog;
  oiVis = [];

  /* Get the data and the opds */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  pol  = yocoListClean(map.pol)(*);
  npol = numberof(pol);
  nbase = dimsof(data)(0);
  nlbd  = dimsof(data)(2);
  nopd  = dimsof(data)(3);

  /* Check the number of baseline */
  if ( nbase%2!=0 || npol!=2)
  {
    yocoLogInfo,"Supports only pair number of baseline with 2 pols...";
    return 1;
  }
  
  /* Filter the data */
  if (strmatch( pndrsGetBand(olog(1)), "K") ) filt = pndrsFilterKClo;
  if (strmatch( pndrsGetBand(olog(1)), "H") ) filt = pndrsFilterHClo;
  pndrsSignalSquareFiltering, data, opd, filt, dataf;
  
  /* Compute the bispectrum between the polars */
  bispectrum = dataf(,,,1:nbase/2) * conj(dataf(,,,nbase/2+1:));

  /* Average over the opds.  bispectrum(lbd,scan,base) */
  bispectrum  = bispectrum(,avg,,);

  /* Compute the sampling opd(scan,base).
     FIXME: check the sign with the polarisation up/down */
  if (olog.detMode == "FOWLER" ) {
    pndrsGetDefaultWave, olog, lbd, lbdB;
    dx = opd(-1,,:nbase/2) - opd(-2,,:nbase/2);
    dx = dx(-,)/lbd * double(nopd) / olog.scanNreads;
    bispectrum *= exp(2.i*pi * dx / 2); 
  }
  
  /* Compute the phase average and errors */
  pndrsSignalComputePhase, bispectrum, phases, phasesErr, gui=gui;

  /* build the oiVis */
  log = oiFitsGetOiLog(coherData, imgLog);
  oiVis = array( oiFitsGetOiStruct("oiVis", -1), nbase/2);
  oiVis.hdr.logId   = log.logId;
  oiVis.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiVis.mjd         = (*coherData.time)(*)(avg);
  oiVis.intTime     = (*coherData.exptime)(sum);
  oiVis.staIndex    = transpose([map(1:nbase/2).t1, map(1:nbase/2).t2]);
  

  /* Fill the data */
  flag = char(phasesErr>70.0);
  oiFitsSetDataArray, oiVis, ,phases*0+1.0, phases*0.0, phases, phasesErr, flag;

  /* Build the default insName */
  pol  = ( (map(1:nbase/2).pol + map(nbase/2+1:).pol) )(1);
  oiVis.hdr.insName = pndrsDefaultInsName(log, pol);

  /* Eventually plots */
  if (gui && pndrsBatchPlotLevel) {
    sta  = pndrsPlotGetBaseName(olog)(1:nbase/2);
    main = swrite(format="%s - %.4f", olog.target, (*coherData.time)(*)(avg));

    window,gui;
    pndrsPlotAddTitles,sta,main;
  
    winkill,gui+1;
    yocoNmCreate,gui+1,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,phases,tosys=indgen(nbase/2),symbol=0,dy=phasesErr,color="red";
    yocoPlotPlgMulti,phases,tosys=indgen(nbase/2),color="red";
    yocoNmLimits,0.5,nlbd+0.5,max(-180,min(phases-5)),min(180,max(phases+5));
    pndrsPlotAddTitles,sta,main;
  }

  yocoLogTrace,"pndrsScanComputePolarDiffPhases done";
  return 1;
}

/* ******************************************************** */

func pndrsScanComputeOpd(imgData, darkData, &imgLog, &pos, &snr, &snr0, gui=)
/* DOCUMENT pndrsScanComputeOpd(imgData, darkData, &imgLog, filtIn, &pos, &snr, &snr0, gui=)

   DESCRIPTION
   Compute the OPD and the SNR of the scans with the IOTA methode:
   - spectral channels are averaged together
   - OPD is computed by the Pedretii method, one per baseline
   - SNR is computed as the ratio between the power IN and OUT the filter
   - SNR0 is SNR per baseline without bootstraping
   - SNR is SNR per baseline with bootstraping

   PARAMETERS
   - imgData, imgLog
   - filterIn, filterOut
   
   EXAMPLES

   SEE ALSO
 */
{
  local dark, opdd, ftd;
  local data, opd, map, ft, freq, df, nbase, posAvg, olog;
  local snr0, pos0, id, i, b, b1, b2, b3, x, y, dist, id0, filtIn;
  yocoLogInfo,"pndrsScanComputeOpd()";
  
  /* Currently not support arrays */
  if ( numberof(imgData)>1 || numberof(darkData)>1 ) {
    yocoError,"Accept only scalar imgData.";
    return 0;
  }

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd,  map, olog;
  pndrsGetData, darkData,  imgLog, dark, opdd;
  nbase = dimsof(data)(0);
  nstep = dimsof(data)(3);

  /* Even if unnecessary */
  opdd -= opdd(avg,-,,);
  opdRef = opd(avg,,);
  opd   -= opdRef(-,,);

  /* Fourier Transform */
  pndrsSignalFourierTransform, data, opd,  ft,  freq;
  pndrsSignalFourierTransform, dark, opdd, ftd;

  /* Get the frequencies step and direction, then norm only
     We use abs(df) and not df because FFT is "re-ordered".
     That is ft is always expressed in positive frequencies,
     Freq being negative does not mean that the frequencies
     of ft are actually negative, it is only a record that
     the array is reversed with respect to real scan  */
  df   = abs( freq(-1,) - freq(-2,) );
  freq = abs(freq)(,1,);
  

  /* Use the same input filter for all baseline: the baselines at the lowest
     frequencies are enlarged because of turbulence... this is hardcoded.
     Actually we enlarge very few because we want to reject the scans
     with weird turbulence that enlarge the pic (especially toward 0) */
  if (strmatch( pndrsGetBand(olog(1)), "K") ) filtIn = pndrsFilterKSnr;
  if (strmatch( pndrsGetBand(olog(1)), "H") ) filtIn = pndrsFilterHSnr;
  expo   = freq(0,)/freq(0,min) - 1;
  filtIn = filtIn*([0.98,1.1])^expo(-,);
  
  /* Get the index inside and outside the filters */
  filtInP  = (freq>filtIn(1,-,))  & (freq<filtIn(2,-,));
  
  /* Average the lambda. So the SNR and POS are
     the same for all channels */
  ft  = ft(avg,,,);
  ftd = ftd(avg,,,);
  
  /* Filtered FFT */
  fftIn = ft*filtInP(,-,);

  /* Piston with the IOTA method (validated) */
  pos = -(fftIn(1:-1,,) * conj(fftIn(2:0,,)))(sum,,);
  pos = oiFitsArg(pos) / (2.*pi * df);
  
  /* PSD of signal and dark */
  psd   = power(ft);
  psdd  = power(ftd);

  /* Add the photon noise */
  for (i=1;i<=nbase;i++) {

    /* average PSD of the data and of the dark */
    x = average( psd(:nstep/2,,i), 2 );
    y = average( psdd(:nstep/2,,i), 2 );
    
    /* Compute the frequencies where to measure the photon noise */
    mask = filtInP(:nstep/2,i);
    id0  = where(mask)(avg);
    mask(1:3) = 1;
    id = pndrsSignalFindBackgroundId(abs(x-y), mask,id0);

    /* measure and add it */
    psdd(,,i) += median( x-y );

  }

  /* Power in the signal and in the noise.
     For the noise, we use the average power as it seems
     to stabilise the SNR at low flux */
  in  = (psd*filtInP(,-,))(sum,,);
  out = average( (psdd*filtInP(,-,))(sum,), 1)(-,);

  /* SNR as averaged power ratio */
  snr = in / (out + 1e-10);


  /* Add QC parameters */
  yocoLogInfo," add QC parameters";
  id  = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  iss = totxt( pndrsPionierToIss(imgLog(id), [map.t1,map.t2]) )(,sum);
  pndrsSetLogInfoArray, imgLog, id, "qcSnru%sAvg", iss, average(in,1);
  pndrsSetLogInfoArray, imgLog, id, "qcSnrl%sAvg", iss, average(out,1);
  pndrsSetLogInfoArray, imgLog, id, "qcSnr%sAvg", iss, snr(avg,);
  pndrsSetLogInfoArray, imgLog, id, "qcSnr%sRms", iss, snr(rms,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpd%sAvg", iss, pos(avg,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpd%sRms", iss, pos(rms,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpdf%sRms", iss, (pos+opdRef)(rms,);

  /* put pos=0 when snr=0 */
  pos *= (snr!=0) ;
  
  /* Use the redondancy to recover more baselines */
  pos0 = pos; snr0 = snr;
  for ( b=1 ; b<=max(map.base) ; b++)
  {
    
    /* Get the possibles 2 baselines to bootstrap */
    for( i=1 ; i<=max(map.t1) ; i++) {
      b1 = pndrsConfigGetBase(map,map(b).t1, i, map(b).pol);
      b2 = pndrsConfigGetBase(map,i, map(b).t2, map(b).pol);
      if ( !is_array(b1) | !is_array(b2) ) continue;

      /* Find the corresponding pos and SNR */
      posN = sign(b1)*pos(,abs(b1)) + sign(b2)*pos(,abs(b2));
      snrN = min(snr(,abs(b1)), snr(,abs(b2)));

      /* Eventually use this bootstrapped */
      use = snrN > snr(,b);
      pos(,b) = pos(,b) * !use  +  posN * use;
      snr(,b) = snr(,b) * !use  +  snrN * use;
    }

    /* Get the possibles 3 baselines to bootstrap */
    for( i=1 ; i<=max(map.t1) ; i++) 
      for( j=1 ; j<=max(map.t1) ; j++) {
        b1 = pndrsConfigGetBase(map, map(b).t1, i, map(b).pol);
        b2 = pndrsConfigGetBase(map, i, j, map(b).pol);
        b3 = pndrsConfigGetBase(map, j, map(b).t2, map(b).pol);
        if ( !is_array(b1) | !is_array(b2) | !is_array(b3) ) continue;
        
        /* Find the corresponding pos and SNR */
        posN = sign(b1)*pos(,abs(b1)) + sign(b2)*pos(,abs(b2)) + sign(b3)*pos(,abs(b3));
        snrN = min(snr(,abs(b1)), snr(,abs(b2)), snr(,abs(b3)));
    
        /* Eventually use this bootstrapped */
        use = snrN > snr(,b);
        pos(,b) = pos(,b) * !use  +  posN * use;
        snr(,b) = snr(,b) * !use  +  snrN * use;
      }
    
  }

  /* If gui, plot it */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui;
    yocoNmCreate,gui,2,nbase,dx=0.05,dy=0.01;
    yocoPlotPlgMulti, snr0, tosys=indgen(nbase)*2-1;
    yocoPlotPlgMulti, snr,  tosys=indgen(nbase)*2-1,color="red";
    yocoPlotPlgMulti, pos0*1e6, tosys=indgen(nbase)*2;
    yocoPlotPlgMulti, pos*1e6,  tosys=indgen(nbase)*2,color="red";
    yocoNmTitle,["SNR","position (!mm)"];
    yocoNmRange,0,,,1;
    yocoNmRange,-30,30,,2;

    main = swrite(format="%s - %.4f", olog.target, (*imgData.time)(*)(avg));
    sta  = pndrsPlotGetBaseName(olog)(-:1:2,)(*);
    pndrsPlotAddTitles,sta,main;
  }
  
  /* If gui, plot it */
  // if (gui && pndrsBatchPlotLevel) {
  //   winkill,gui+1;
  //   yocoNmCreate,gui+1,2,nbase/2,dx=0.06,dy=0.01;
  //   yocoPlotPlgMulti, average(psdbias,2), freq, tosys=indgen(nbase), color="green";
  //   yocoPlotPlgMulti, average(psd0,2),    freq, tosys=indgen(nbase);
  //   yocoPlotPlgMulti, average(psd0,2)*filtInP,    freq, tosys=indgen(nbase),color="red";
  //   for (i=1;i<=nbase;i++) { plsys,i; limits,0,1.8*max(filtIn),restrict=1; }
  //   pndrsPlotAddTitles,sta,main;
  // }  
  
  yocoLogTrace,"pndrsScanComputeOpd done";
  return 1;
}

/* ******************************************************** */

func pndrsScanComputeOpdAbcd(coherData, &imgLog, &pos, &snr, &snr0, gui=, useFilter=, weight=)
/* DOCUMENT pndrsScanComputeOpdAbcd(coherData, &imgLog, filtIn, &pos, &snr, gui=)

   DESCRIPTION
   Compute the OPD and the SNR of the scans with the IOTA methode:
   - spectral channels are averaged together
   - OPD is computed by the Pedretii method, one per baseline
   - SNR is computed as the ratio between the power IN and OUT the filter
   - SNR0 is SNR per baseline without bootstraping
   - SNR is SNR per baseline with bootstraping

   PARAMETERS
   - coherData, imgLog
   - filterIn, filterOut
   - weight= for each channel
   
   EXAMPLES

   SEE ALSO
 */
{
  local data, opd, map, ft, freq, df, nbase, posAvg, olog, delta;
  local snr0, pos0, id, i, b, b1, b2, b3, x, y, dist, id0, filtIn, opdRef;
  yocoLogInfo,"pndrsScanComputeOpdAbcd()";
  
  /* Currently not support arrays */
  if ( numberof(coherData)>1 ) {
    yocoError,"Accept only scalar coherData.";
    return 0;
  }

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd,  map, olog;
  nbase = dimsof(data)(0);
  nstep = dimsof(data)(3);
  nlbd  = dimsof(data)(2);

  /* Even if unnecessary */
  opdRef = opd(avg,,);
  opd   -= opdRef(-,,);

  /* Fourier Transform and PSD. Average the lambda. So the SNR and POS are
     the same for all channels */
  pndrsSignalFourierTransform, data, opd,  ft,  freq;
  // ft   = ft(avg,,,);

  /* Weighted average */
  if ( is_void(weight) ) weight = array(1.0,nlbd);
  weight /= weight(sum);
  yocoLogInfo," weighted average over lbd", weight;
  ft = (ft*weight)(sum,);
  
  /* PSD */
  psd0 = power(ft);

  /* The PSD of the BIAS is estimated with the opposite frequencies */
  psdbias = psd0;
  psdbias(2:,,) = psdbias(:2:-1,,);

  /* Get the frequencies step and direction, then norm only
     We use abs(df) and not df because FFT is "re-ordered".
     That is ft is always expressed in positive frequencies,
     Freq being negative does not mean that the frequencies
     of ft are actually negative, it is only a record that
     the array is reversed with respect to real scan  */
  df   = abs( freq(-1,) - freq(-2,) );
  freq = abs(freq)(,1,);

  /* Default wave */
  pndrsGetDefaultWave, olog, lbd0, lbdB, sig0;
    
  if (useFilter==0) {

    /* Compute the predicted width of the pic based on
       the tau0 and scanning speed */
    predWidth = pndrsGetPicWidth(olog, checkUTs=0) * 0.5;
    
    /* Compute the filtering mask (0/1), has shape */
    filtInP = (indgen(nstep) > 10) & (indgen(nstep) < (nstep/2-5)) &
      ( freq > (sig0(avg)-predWidth(avg,))(-,) ) &
      ( freq < (sig0(avg)+predWidth(avg,))(-,) ) ;
    
  } else {
    
  /* Use the same input filter for all baseline: the baselines at the lowest
     frequencies are enlarged because of turbulence... this is hardcoded.
     Actually we enlarge very few because we want to reject the scans
     with weird turbulence that enlarge the pic (especially toward 0). */
    if (strmatch( pndrsGetBand(olog(1)), "K") ) filtIn = pndrsFilterKSnr;
    if (strmatch( pndrsGetBand(olog(1)), "H") ) filtIn = pndrsFilterHSnr;
    expo   = freq(0,)/freq(0,min) - 1;
    filtIn = filtIn*([0.98,1.03])^expo(-,);

    delta = abs(filtIn-sig0(avg)) / sig0(avg);
    yocoLogInfo,"Predicted bandwidth (max,min)  = "+
      swrite(format="%.0f%% ",[max(delta),min(delta)]*100)(sum)+"of sig0";
    
    /* Get the index inside and outside the filters */
    filtInP  = (freq>filtIn(1,-,))  & (freq<filtIn(2,-,));
  }
  
  /* Piston with the IOTA method (validated), using integration of
     cross-spectrum of filtered FFT */
  fftIn = ft*filtInP(,-,);
  pos   = -(fftIn(1:-1,,) * conj(fftIn(2:0,,)))(sum,,);
  pos   = oiFitsArg(pos) / (2.*pi * df);
  
  /* Power in the signal and in the noise.
     For the noise, we use the average power as it seems
     to stabilise the SNR at low flux */
  in  = (psd0*filtInP(,-,))(sum,,);
  out = average( (psdbias*filtInP(,-,))(sum,), 1)(-,);

  /* SNR as averaged power ratio */
  snr = in / (out + 1e-10);

  /* Add QC parameters */
  yocoLogInfo," add QC parameters";
  id  = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  iss = totxt( pndrsPionierToIss(imgLog(id), [map.t1,map.t2]) )(,sum);
  pndrsSetLogInfoArray, imgLog, id, "qcSnru%sAvg", iss, average(in,1);
  pndrsSetLogInfoArray, imgLog, id, "qcSnrl%sAvg", iss, average(out,1);
  pndrsSetLogInfoArray, imgLog, id, "qcSnr%sAvg", iss, snr(avg,);
  pndrsSetLogInfoArray, imgLog, id, "qcSnr%sRms", iss, snr(rms,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpd%sAvg", iss, pos(avg,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpd%sRms", iss, pos(rms,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpdf%sRms", iss, (pos+opdRef)(rms,);
  
  /* put pos=0 when snr=0 */
  pos *= (snr!=0) ;
  
  /* Use the redondancy to recover more baselines */
  pos0 = pos; snr0 = snr;
  for ( b=1 ; b<=max(map.base) ; b++)
  {
    
    /* Get the possibles 2 baselines to bootstrap */
    for( i=1 ; i<=max(map.t1) ; i++) {
      b1 = pndrsConfigGetBase(map,map(b).t1, i, map(b).pol);
      b2 = pndrsConfigGetBase(map,i, map(b).t2, map(b).pol);
      if ( !is_array(b1) | !is_array(b2) ) continue;

      /* Find the corresponding pos and SNR */
      posN = sign(b1)*pos(,abs(b1)) + sign(b2)*pos(,abs(b2));
      snrN = min(snr(,abs(b1)), snr(,abs(b2)));

      /* Eventually use this bootstrapped */
      use = snrN > snr(,b);
      pos(,b) = pos(,b) * !use  +  posN * use;
      snr(,b) = snr(,b) * !use  +  snrN * use;
    }

    /* Get the possibles 3 baselines to bootstrap */
    for( i=1 ; i<=max(map.t1) ; i++) 
      for( j=1 ; j<=max(map.t1) ; j++) {
        b1 = pndrsConfigGetBase(map, map(b).t1, i, map(b).pol);
        b2 = pndrsConfigGetBase(map, i, j, map(b).pol);
        b3 = pndrsConfigGetBase(map, j, map(b).t2, map(b).pol);
        if ( !is_array(b1) | !is_array(b2) | !is_array(b3) ) continue;
        
        /* Find the corresponding pos and SNR */
        posN = sign(b1)*pos(,abs(b1)) + sign(b2)*pos(,abs(b2)) + sign(b3)*pos(,abs(b3));
        snrN = min(snr(,abs(b1)), snr(,abs(b2)), snr(,abs(b3)));
    
        /* Eventually use this bootstrapped */
        use = snrN > snr(,b);
        pos(,b) = pos(,b) * !use  +  posN * use;
        snr(,b) = snr(,b) * !use  +  snrN * use;
      }
    
  }

  /* If gui, plot it */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui;
    yocoNmCreate,gui,2,nbase,dx=0.05,dy=0.01;
    yocoPlotPlgMulti, snr0, tosys=indgen(nbase)*2-1;
    yocoPlotPlgMulti, snr,  tosys=indgen(nbase)*2-1,color="red";
    yocoPlotPlgMulti, pos0*1e6, tosys=indgen(nbase)*2;
    yocoPlotPlgMulti, pos*1e6,  tosys=indgen(nbase)*2,color="red";
    yocoNmRange,0,,,1;
    yocoNmRange,-30,30,,2;

    main = swrite(format="%s - %.4f", olog.target, (*coherData.time)(*)(avg));
    sta  = pndrsPlotGetBaseName(olog)(-:1:2,)(*);
    pndrsPlotAddTitles,sta,main,"SNR (left) and position !mm (right) (black:raw, red:bootstraped)","scan number";
  }

  /* If gui, plot it */
  // if (gui && pndrsBatchPlotLevel) {
  //   winkill,gui+1;
  //   yocoNmCreate,gui+1,2,nbase/2,dx=0.06,dy=0.01;
  //   yocoPlotPlgMulti, average(psdbias,2), freq, tosys=indgen(nbase), color="green";
  //   yocoPlotPlgMulti, average(psd0,2),    freq, tosys=indgen(nbase);
  //   yocoPlotPlgMulti, average(psd0,2)*filtInP,    freq, tosys=indgen(nbase),color="red";
  //   for (i=1;i<=nbase;i++) { plsys,i; limits,0,1.8*max(filtIn),restrict=1; }
  //   pndrsPlotAddTitles,sta,main;
  // }  
  
  yocoLogTrace,"pndrsScanComputeOpdAbcd done";
  return 1;
}

/* ******************************************************** */

func pndrsScanComputeOpdAbcdPhasor(coherData, &imgLog, &pos, &snr, &snr0, gui=, useFilter=)
/* DOCUMENT pndrsScanComputeOpdAbcdPhasor(coherData, &imgLog, filtIn, &pos, &snr, gui=)

   DESCRIPTION
   Compute the OPD and the SNR of the scans with the IOTA methode:
   - spectral channels are averaged together
   - OPD is computed by the Pedretii method, one per baseline
   - SNR is computed as the ratio between the power IN and OUT the filter
   - SNR0 is SNR per baseline without bootstraping
   - SNR is SNR per baseline with bootstraping

   PARAMETERS
   - coherData, imgLog
   - filterIn, filterOut
   
   EXAMPLES

   SEE ALSO
 */
{
  local data, opd, map, ft, freq, df, nbase, posAvg, olog, delta;
  local snr0, pos0, id, i, b, b1, b2, b3, x, y, dist, id0, filtIn;
  yocoLogInfo,"pndrsScanComputeOpdAbcdPhasor()";
  
  /* Currently not support arrays */
  if ( numberof(coherData)>1 ) {
    yocoError,"Accept only scalar coherData.";
    return 0;
  }

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd,  map, olog;
  opd -= opd(avg,-,,);
  nbase = dimsof(data)(0);
  nstep = dimsof(data)(3);

  pndrsGetDefaultWave, olog, lbd0, lbdB, sig0;
  dataIn  = data * exp(-2.i*pi*sig0*opd(-,,,)); // = exp(2.i*pi*pos) * exp(i.phi(t))
  dataOut = data * exp(+2.i*pi*sig0*opd(-,,,)); // = exp(2.i*pi*pos) * exp(i.phi(t))

  /* Low-pass filter: Should be the same
     for both channels */
  freq = abs(pndrsSignalFftIndgen(nstep));
  filter = abs(freq)<40;
  dataIn  = fft(fft(dataIn,[0,1,0,0])*filter(-,),[0,-1,0,0]) / nstep;
  dataOut = fft(fft(dataOut,[0,1,0,0])*filter(-,),[0,-1,0,0]) / nstep;
 
  /* Compute-cross-spectrum */
  CIn  = ( dataIn(1:-1,,,) * conj(dataIn(2:,,,)) )(avg,,,);
  COut = ( dataOut(1:-1,,,) * conj(dataOut(2:,,,)) )(avg,,,);
  
  /* Cross-power in the signal and in the noise.
     For the noise, we use the average power as it seems
     to stabilise the SNR at low flux */
  in  = abs( CIn(avg,) );
  out = average( abs(COut(avg,)), 1)(-,);

  /* SNR as averaged power ratio */
  snr = in / (out + 1e-10);

  /* Piston with the IOTA method (validated), using integration of
     cross-spectrum of filtered FFT. */
  yocoLogWarning, "SIGN is not validated";
  df = sig0(dif)(avg);
  pos = oiFitsArg(CIn(avg,)) / (2.*pi * df);

  /* FIXME: the position suffer from range capture ambiguity.
     Surely possible to stabilite this. */
  // opd0 = span(-60e-6,60e-6,128); // step_search
  // CRef = exp( 2.i*pi*df*opd0(-,-,-,) ) * exp(- (pi* (opd-opd0(-,-,-,)) /lbd0(avg)^2*lbdB(avg) )^2 / 5.0); // step,scan,base,search
  // chi2 = (CIn * CRef)(sum,,,); // scan,base,search
  // pos  = opd0( abs(chi2)(,,mxx) );

  /* Add QC parameters */
  yocoLogInfo," add QC parameters";
  id  = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  iss = totxt( pndrsPionierToIss(imgLog(id), [map.t1,map.t2]) )(,sum);
  pndrsSetLogInfoArray, imgLog, id, "qcSnru%sAvg", iss, average(in,1);
  pndrsSetLogInfoArray, imgLog, id, "qcSnrl%sAvg", iss, average(out,1);
  pndrsSetLogInfoArray, imgLog, id, "qcSnr%sAvg", iss, snr(avg,);
  pndrsSetLogInfoArray, imgLog, id, "qcSnr%sRms", iss, snr(rms,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpd%sAvg", iss, pos(avg,);
  pndrsSetLogInfoArray, imgLog, id, "qcOpd%sRms", iss, pos(rms,);

  /* put pos=0 when snr=0 */
  pos *= (snr!=0) ;
  
  /* Use the redondancy to recover more baselines */
  pos0 = pos; snr0 = snr;
  for ( b=1 ; b<=max(map.base) ; b++)
  {
    
    /* Get the possibles 2 baselines to bootstrap */
    for( i=1 ; i<=max(map.t1) ; i++) {
      b1 = pndrsConfigGetBase(map,map(b).t1, i, map(b).pol);
      b2 = pndrsConfigGetBase(map,i, map(b).t2, map(b).pol);
      if ( !is_array(b1) | !is_array(b2) ) continue;

      /* Find the corresponding pos and SNR */
      posN = sign(b1)*pos(,abs(b1)) + sign(b2)*pos(,abs(b2));
      snrN = min(snr(,abs(b1)), snr(,abs(b2)));

      /* Eventually use this bootstrapped */
      use = snrN > snr(,b);
      pos(,b) = pos(,b) * !use  +  posN * use;
      snr(,b) = snr(,b) * !use  +  snrN * use;
    }

    /* Get the possibles 3 baselines to bootstrap */
    for( i=1 ; i<=max(map.t1) ; i++) 
      for( j=1 ; j<=max(map.t1) ; j++) {
        b1 = pndrsConfigGetBase(map, map(b).t1, i, map(b).pol);
        b2 = pndrsConfigGetBase(map, i, j, map(b).pol);
        b3 = pndrsConfigGetBase(map, j, map(b).t2, map(b).pol);
        if ( !is_array(b1) | !is_array(b2) | !is_array(b3) ) continue;
        
        /* Find the corresponding pos and SNR */
        posN = sign(b1)*pos(,abs(b1)) + sign(b2)*pos(,abs(b2)) + sign(b3)*pos(,abs(b3));
        snrN = min(snr(,abs(b1)), snr(,abs(b2)), snr(,abs(b3)));
    
        /* Eventually use this bootstrapped */
        use = snrN > snr(,b);
        pos(,b) = pos(,b) * !use  +  posN * use;
        snr(,b) = snr(,b) * !use  +  snrN * use;
      }
  }
  
  /* If gui, plot it */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui;
    yocoNmCreate,gui,2,nbase,dx=0.05,dy=0.01;
    yocoPlotPlgMulti, snr0, tosys=indgen(nbase)*2-1;
    yocoPlotPlgMulti, snr,  tosys=indgen(nbase)*2-1,color="red";
    yocoPlotPlgMulti, pos0*1e6, tosys=indgen(nbase)*2;
    yocoPlotPlgMulti, pos*1e6,  tosys=indgen(nbase)*2,color="red";
    yocoNmTitle,["SNR","pos (!mm)"];
    yocoNmRange,0,,,1;
    yocoNmRange,-30,30,,2;
    //for (i=1;i<=6;i++) {plsys,i*2-1; range,0.1,1e3;}

    main = swrite(format="%s - %.4f", olog.target, (*coherData.time)(*)(avg));
    sta  = pndrsPlotGetBaseName(olog)(-:1:2,)(*);
    pndrsPlotAddTitles,sta,main;
  }

  yocoLogTrace,"pndrsScanComputeOpdAbcdPhasor done";
  return 1;
}

/* ******************************************************** */

func pndrsComputeCoherentNorm2(coherData, imgLog, flux, &norm2, gui=)
/* DOCUMENT pndrsComputeCoherentNorm2(coherData, imgLog, flux, &norm2, gui=)

   DESCRIPTION
   Compute the normalization signal for each baseline from the flux of
   the associated telescopes: norm2 = 4.*flux1 * flux2
 */
{
  yocoLogInfo,"pndrsComputeCoherentNorm2()";
  local data, opd, freq, map, shape, i, t1, t2, nlbd, idm, time;
  if (numberof(coherData)>1) { error,"Accept only scalar."; return 0; }

  /* Prepare the array */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog, time;
  nlbd = dimsof(data)(2);
  idm  = nlbd/2+1;

  /* Frequency resolution */
  df = 1./(time(0,1)-time(1,1));
  
  /* Use the same signal for each spectral channel.
     But keep the global shape of the spectra per baseline.
     I dislike this idea because it creates correlation
     amoung spectral channel. Do that only for longuer DITs,
     that is for faint object. Indeed the setup depends on DIT,
     so this would be "safe" */
  if (oLog.detName=="RAPID" && oLog.detDit<1e-3 ) {
    yocoLogInfo," don't average over lbd";
    flux0 = flux;
  } else {
    yocoLogInfo," average over lbd";
    shape = average(flux(,avg,,),2)(,-,-,);
    flux0  = flux(sum,,,)(-,,,) * shape / shape(sum,,,)(-,,,);
  }

  /* Wiener filter the data (no signal anyway at highest frequencies) */
  pndrsSignalWienerFiltering, flux0, flux, gui=(is_array(gui) ? gui+1 : []);

  /* Compute the normalization signal */
  norm2 = array(structof(flux), dimsof(data) );
  for ( i=1 ; i<=max(map.base) ; i++)
    {
      id = where( map.base == i )(1);
      t1 = pndrsGetPolTelInMap(map,id(1),1);
      t2 = pndrsGetPolTelInMap(map,id(1),2);
      norm2(,,,i) = 4.* flux(,,,t1) * flux(,,,t2);
    }

  
  /* Plot the first 3 scans to get a data estimate */
  if (gui && pndrsBatchPlotLevel) {
    nbase = max(map.base);
    winkill,gui;
    yocoNmCreate,gui,2,nbase/2,dy=0.01,dx=0.06;
    if (nlbd>2) {
      yocoPlotPlgMulti,norm2(1,,1:3,)(*,),tosys=indgen(nbase),color="red";
      yocoPlotPlgMulti,norm2(0,,1:3,)(*,),tosys=indgen(nbase),color="green";
    }
    yocoPlotPlgMulti,norm2(idm,,1:3,)(*,),tosys=indgen(nbase);

    sta  = pndrsPlotGetBaseName(oLog);
    main = swrite(format="%s - %.4f", oLog.target, (*coherData.time)(*)(avg));
    pndrsPlotAddTitles,sta,main,"Normalisation norm2 (first, middle and last channels)","opd step (3 scans)","flux1 x flux2";
    yocoNmRange; yocoNmRange,0;

    window, gui+1;
    titles = pndrsGetLogInfo(oLog,"issStation%i",[1,2,3,4]) + " / " +
      pndrsGetLogInfo(oLog,"issTelName%i",[1,2,3,4]);    
    xtit   = swrite(format="freq. in unit of %.3f Hz",df);
    pndrsPlotAddTitles,titles,main,"PSD of tel. flux and its filtering",xtit,"Power";
  }

  yocoLogTrace,"pndrsComputeCoherentNorm()";
  return 1;
}

func pndrsComputeCoherentNorm2Faint(coherData, imgLog, flux, &norm2, gui=)
/* DOCUMENT pndrsComputeCoherentNormFaint(coherData, imgLog, flux, &norm2, gui=)

   DESCRIPTION
   Compute the normalization signal for each baseline from the flux of
   the associated telescopes: norm2 = 4 * flux1 * flux2
*/
{
  yocoLogInfo,"pndrsComputeCoherentNorm2Faint()";
  local data, opd, freq, map, shape, i, nbase, olog;
  if (numberof(coherData)>1) error,"Accept only scalar.";

  /* Prepare the array */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;

  /* Use the same signal for each spectral channel.
     But keep the global shape of the spectra per baseline. */ 
  yocoLogInfo," average over lbd";
  shape = average(flux(,avg,),2)(,-,-,);
  flux  = flux(sum,,,)(-,,,) * shape / shape(sum,,,)(-,,,);

  /* Compute the normalization signal */
  norm2 = array(structof(flux), dimsof(data) );
  for ( i=1 ; i<=max(map.base) ; i++)
    {
      id = where( map.base == i )(1);
      t1 = pndrsGetPolTelInMap(map,id(1),1);
      t2 = pndrsGetPolTelInMap(map,id(1),2);
      norm2(,,,i) = 4. * flux(,60:,,t1)(,avg,-,) * flux(,60:,,t2)(,avg,-,);
    }
  
  /* Plot the first 3 scans to get a data estimate */
  if (gui && pndrsBatchPlotLevel) {
    nbase = max(map.base);
    winkill,gui;
    yocoNmCreate,gui,2,nbase/2,dy=0.01,dx=0.06;
    yocoPlotPlgMulti,norm2(1,,1:3,)(*,),tosys=indgen(nbase),color="red";
    yocoPlotPlgMulti,norm2(0,,1:3,)(*,),tosys=indgen(nbase),color="green";
    pndrsPlotDefaultTitles, oLog;
    yocoNmRange; yocoNmRange,0;

    winkill,gui+1;
    window,gui+1;
    pltitle,"FIXME";
  }

  yocoLogTrace,"pndrsComputeCoherentNormFaint()";
  return 1;
}


/* ******************************************************** */

func pndrsCalibrateCoherentFlux(&coherData, &imgLog, norm)
/* DOCUMENT pndrsCalibrateCoherentFlux(&coherData, &imgLog, flux)

   DESCRIPTION
   Perform the normalisation of the coherent flux "coherData" by the
   normalisation signal "norm" (this is a simple division!!)

   coherData is calibrated inplace.

   PARAMETERS
   - coherData:
   - imgLog:
   - flux:
 */
{
  yocoLogTrace,"pndrsCalibrateCoherentFlux()";
  local i, data, norm, dim, ff, id, map, opd;
  if (numberof(coherData)>1) error,"Accept only scalar.";

  /* Get the data */
  pndrsGetData, coherData, imgLog, data, opd, map;

  /* Calibrate point by point */
  data = data / norm;
  
  /* Put the data back */
  coherData.regdata =  &data;

  yocoLogTrace,"pndrsCalibrateCoherentFlux done";
  return 1;
}

/* ******************************************************** */

func pndrsScanCropOpd(&coherData, imgLog, pos, delta, &crop)
/* DOCUMENT pndrsScanCropOpd(&coherData, imgLog, pos, delta, &crop)

   DESCRIPTION
   Crop the data in coherData: put all steps in scan that
   are not within [pos-delta, pos+delta].
   pos and delta should be in microns (10-6m).

   PARAMETERS
   - coherData, imgLog
   - pos:   array(double, nscan, nwin);
   - delta: scalar or array(double, nscan, nwin);

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanCropOpd()";
  local data, opd, freq, map, pos, nscan, npos;
  if (numberof(coherData)>1) error,"Accept only scalar.";

  /* Default for delta is +/-40mum */
  if (is_void(delta)) delta = 40e-6;

  /* Get data. OPD is put at 0 in the middle of the scan */
  pndrsGetData, coherData,  imgLog, data, opd, map;
  opd -= opd(avg,-,,);

  /* Deal with the case where pos has more scan than the
     data. When data is a dark for instance. */
  nscan = dimsof(data)(4);
  npos  = dimsof(pos)(2);
  if ( nscan > npos ) {
    yocoLogTrace,"more scan than pos";
    pos = pos((indgen(0:nscan-1)%npos)+1, );
  } else if ( nscan < npos ) {
    yocoLogTrace,"more pos than scan";
    pos = pos(1:nscan,);
  }

  /* Crop scan. We use a heavy-side function for the crop to avoid
     second lobes in the PSD */
  crop = exp( -(opd - pos(-,,))^6 / delta^6 )(-,,,);
  data *= crop;

  /* Put the data back */
  coherData(1).regdata  = &data;

  yocoLogTrace,"pndrsScanCropOpd done";
  return 1;
}

func pndrsScanComputeDiffPhase(coherData, imgLog, pos, &oiVis, gui=)
/* DOCUMENT pndrsScanComputeDiffPhase(coherData, imgLog, pos, &oiVis, gui=)

   DESCRIPTION
   Compute the spectral differential phases. Use the algorithm from Millour et al.
   that is the "reference channel" is all the channel except the running one.
   
   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanComputeDiffPhase()";
  local oLog, data, opd, map, phasor;
  
  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;
  ntel = pndrsGetNtelInMap(map); 
  pol  = yocoListClean(map.pol)(*);
  npol = numberof(pol);

  /* Some dimension */
  nlbd  = dimsof(data)(2);
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nbase = dimsof(data)(5);

  /* Check number of spectral channels */
  if (nlbd<6) {
    yocoLogInfo,"No differential phase (nlbd="+pr1(nlbd)+")";
    return 1;
  }

  /* Perform filtering */
  if (strmatch( pndrsGetBand(oLog(1)), "K") ) filt = pndrsFilterKClo;
  if (strmatch( pndrsGetBand(oLog(1)), "H") ) filt = pndrsFilterHClo;
  pndrsSignalSquareFiltering, data, opd, filt, dataf;

  /* Remove global OPD and scanning phase */
  opd -= opd(avg,-,) + pos(-,);
  pndrsGetDefaultWave, oLog, lbd, lbdB;
  bisp  = dataf * exp(-2.i*pi * opd(-,)/lbd);
  bisp0 = bisp;

  /* Remove the air dispersion. FIXME: version 2 change the sign
     of phase in pndrs... most probably this sign
     should also be changed in compureairdisp.*/
  yocoLogInfo,"Remove the air dispersion.";
  vis = pndrsComputeAirDisp(oLog,map.t1,map.t2,lbd);
  bisp *= conj(vis(,-,-,));

  /* Remove group-delay step by step in scan is not possible
     because it strongly biases the result (additive real nb)*/
  yocoLogInfo,"Remove the average group-delay per scan.";
  b0 = oiFitsArg( (bisp(1:-1,,,)*conj(bisp(2:0,,,)))(avg,,)(avg,-,) );
  bisp *= exp( 1.i * b0(-,) * span(-0.5*nlbd+.5,+0.5*nlbd-.5,nlbd) );

  /* Remove the average phase step by step in scan. The reference channel (b0)
     is the sum of all channel except the working one (see Millour et al.)
     This sounds necessary to avoid biases. */
  diag = array(1.0,nlbd,nlbd);
  diag(indgen(nlbd)+nlbd*indgen(0:nlbd-1)) = 0.0;
  b0 = (bisp(-,) * diag)(,avg,,,);
  bisp *= conj(b0);
  
  /* Average over the step in scan and compute
     the final differential phase and error */
  bisp  = bisp(,avg,,);
  pndrsSignalComputePhase, bisp,  dPhi,  dPhiErr,  gui=gui;

  /* If I remove the working channel from the reference channel,
     I should multiply by the Millour's coeficient */
  dPhi *= double(nlbd-1.0)/nlbd;

  
  /* Perform the same operation without cleaning t
     he air dispersion.
     This is just for analysis purpose via the PDF print */
  b0 = oiFitsArg( (bisp0(1:-1,,,)*conj(bisp0(2:0,,,)))(avg,,)(avg,-,) );
  bisp0 *= exp( 1.i * b0(-,) * span(-0.5*nlbd+.5,+0.5*nlbd-.5,nlbd) );
  bisp0 *= conj( (bisp0(-,) * diag)(,avg,,,) );
  dPhi0 = oiFitsArg(bisp0(,avg,avg,)) /pi*180.0 * double(nlbd-1.0)/nlbd;

  
  /* Build the oiVis2. Note that the staIndex refer to the
     PIONIER arms (1234 of the correlation map) */
  log = oiFitsGetOiLog(coherData, imgLog);
  oiVis = array( oiFitsGetOiStruct("oiVis", -1), nbase);
  oiVis.hdr.logId   = log.logId;
  oiVis.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiVis.mjd         = (*coherData.time)(*)(avg);
  oiVis.intTime     = (*coherData.exptime)(sum);
  oiVis.staIndex    = transpose([map.t1, map.t2]);

  /* Fill the data */
  flag = char(dPhiErr>30.0);
  oiFitsSetDataArray, oiVis,,dPhi*0+1.0, dPhiErr*0+1e10, dPhi, dPhiErr, flag;

  /* Build the default insName */
  oiVis.hdr.insName = pndrsDefaultInsName(log, map.pol);
  

  /* Eventually plots */
  if (gui && pndrsBatchPlotLevel) {
    sta  = pndrsPlotGetBaseName(oLog);
    main = swrite(format="%s - %.4f", oLog.target, (*coherData.time)(*)(avg));
    
    window,gui;
    pndrsPlotAddTitles,sta,main;
    
    winkill,gui+1;
    yocoNmCreate,gui+1,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,dPhi,tosys=indgen(nbase),symbol=0,dy=dPhiErr,color="red";
    yocoPlotPlgMulti,dPhi,tosys=indgen(nbase),color="red";
    yocoNmLimits,0.5,nlbd+0.5,max(-180,min(dPhi-5)),min(180,max(dPhi+5));
    pndrsPlotAddTitles,sta,main;

//    winkill,gui+2;
//    yocoNmCreate,gui+2,2,nbase/2,dx=0.06,dy=0.01;
//    yocoPlotPlpMulti,dPhi0,tosys=indgen(nbase),symbol=0,dy=dPhiErr,color="red";
//    yocoPlotPlgMulti,dPhi0,tosys=indgen(nbase),color="red";
//    yocoNmLimits,0.5,nlbd+0.5,max(-180,min(dPhi0-5)),min(180,max(dPhi0+5));
//    pndrsPlotAddTitles,sta,main;
  }
  
  yocoLogTrace,"pndrsScanComputeDiffPhase done";
}

func pndrsScanComputeAmp2PerScan(coherData, darkData, &imgLog, norm2, pos, &oiVis2, &amp2, &amp2Err, gui=)
/* DOCUMENT pndrsScanComputeAmp2PerScan(coherData, darkData, imgLog, norm2, &oiVis2, &amp2, &amp2Err, gui=)

   DESCRIPTION
   Compute a value of amp2 (unbiased power of the fringes) and n2 (power of the normalisation flux)
   per scan and then compute the final vis2 by  v2 = <amp2> / <n2>.
   Statistical errors are estimated by bootstrating.

   The unbiased power amp2 is computed in the Fourier space. The bias is estimated and removed
   scan by scan. The average PSD is also plotted to check the bias removed on the display
   at high SNR.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanComputeAmp2PerScan()";
  local i, data, opd, nbase, nstep, map, ntel, dx, ft, psd, freq, tau0, fwhm;
  local boot, nIn, log, npol, pol, x, y, yf, sta, lbd0, lbdB, env;
  local psd0, psddark, crop, n2, isRejected, mask, time, vel, tauB, predWidth;
  oiVis2 = [];

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;
  ntel = pndrsGetNtelInMap(map); 
  pol  = yocoListClean(map.pol)(*);

  /* Some dimension */
  nlbd  = dimsof(data)(2);
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nbase = dimsof(data)(5);
  npol  = numberof(pol);

  /* Default Wave */
  pndrsGetDefaultWave, oLog, lbd0, lbdB, sig0;

  /* Get the dark */
  if (is_array(darkData)) {
    pndrsGetData, darkData, imgLog, dark, opdd;
  } else {
    dark = data(,,1,) * 0.0;
  }
  
  /* Perform FFT and PSD */
  pndrsSignalFourierTransform, data, opd, ft, freq;
  pndrsSignalFourierTransform, dark, opdd, ftdark;
  psd0    = power(ft);
  psddark = average(power(ftdark),3)(,,-,);
  freq    = abs(freq)(,1,);
  id0     = abs(freq(-,) - sig0)(,mnx,);

  /* Remove the PSD of the dark.
     Keep the null scans at 0 */
  psd  = psd0 - psddark;
  psd *= (abs(data)(sum,sum,-,-,)!=0);


  /* Compute the predicted width of the pic based on
     the tau0 and scanning speed */
  predWidth = pndrsGetPicWidth(oLog, checkUTs=1);
  
  /* Load the filter corresponding to the band */
  if (strmatch( pndrsGetBand(oLog(1)), "K") ) {
    filtIn  = pndrsFilterKIn;
    filtOut = pndrsFilterKOut;
  }
  if (strmatch( pndrsGetBand(oLog(1)), "H") ) {
    filtIn  = pndrsFilterHIn;
    filtOut = pndrsFilterHOut;
  }
  
  /* If the same input filter is used for all baseline: the lowest
     frequencies are enlarged because of turbulence... this is hardcoded */
  if (pndrsOptionUseFindBackground && dimsof(filtIn)(1)==1) {
    yocoLogInfo,"Enlarge filter for slow scanning baseline.";
    expo    = freq(0,)/freq(0,min) - 1;
    filtIn  = filtIn*([0.9,1.1])^expo(-,);
  }

  /* Check size */
  if (dimsof(filtIn)(1)==1) {
    filtIn = filtIn(,-:1:nbase);
  }
  if (dimsof(filtOut)(1)==1) {
    filtOut = filtOut(,-:1:nbase);
  }

  /* Some verbose */
  yocoLogTrace,"Acceptance filter is:";
  yocoLogTrace,filtIn;
  yocoLogTrace,"Background filter is:";
  yocoLogTrace,filtOut;
  
  /* Get the index inside and outside the filters */
  filtInP  = (abs(freq)>filtIn(1,-,))  & (abs(freq)<filtIn(2,-,));
  filtOutP = (abs(freq)>=filtOut(1,-,)) & (abs(freq)<=filtOut(2,-,)) &
    !filtInP & (abs(freq)<freq(max,-,,)/2.0);

  /* Init an array for the bias and loop on
     wavelength, scans and bases */
  if (pndrsOptionBiasMethod==1) 
    yocoLogInfo,"Compute bias with routine 'pndrsSignalFindBackgroundId' (filtOut ignored)";
  else if (pndrsOptionBiasMethod==2)
    yocoLogInfo,"Compute bias with expected width of the pic";
  else
    yocoLogInfo,"Compute bias with interval between filterIn and filterOut";

  bias = psd * 0.0;
  idsb = array(0,nlbd,nstep,nbase);
  idsi = array(0,nlbd,nstep,nbase);
  for (w=1;w<=nbase;w++)  {
    
    /* Check if baseline is fully rejected */
    if ( data(sum,sum,sum,w) == 0.0 ) continue;
    
    for (l=1;l<=nlbd;l++) {
      yocoLogTrace,"Compute Bias and Energy for base "+pr1(w)+" and lbd "+pr1(l);

      /* Compute the frequencies where to measure the bias level
         and where to integrate the energy of fringes */
      if (pndrsOptionBiasMethod==1) {
        dist = average( psd(l,:nstep/2,,w), 2);
        mask = filtInP(:nstep/2,w);
        mask(1:3) = 1;
        mask(nstep/2-5:) = 1;
        ko = pndrsSignalFindBackgroundId( abs(dist), mask, id0(l,w));
        ok = where( filtInP(,w) );
      } else if (pndrsOptionBiasMethod==2) {
        yocoLogTrace,"Compute where...";
        ko = where ( (indgen(nstep) > 12 & indgen(nstep) <= 18 ) | 
                     (indgen(nstep) > 12 &
                     !(freq(,w) > (sig0(l)-predWidth(l,w)) & freq(,w) < (sig0(l)+predWidth(l,w)) ) &
                      indgen(nstep) < nstep/2-5) );
        ok = where ( indgen(nstep) > 18 &
                    (freq(,w) > (sig0(l)-predWidth(l,w)) & freq(,w) < (sig0(l)+predWidth(l,w)) ) &
                     indgen(nstep) < nstep/2-5 );
      }
      else {
        ko = where( filtOutP(,w) );
        ok = filtInP(,w);
      }

      /* Check if a valid integration domain for the bias and
         for the fringe energy could be found */
      if ( !is_array(ko) || !is_array(ok)) {
        yocoError,"No valid domain found for the bias or the energy... stop.";
        return 0;
      }

      /* Store this array for later display,
         ko is where the bias is estimated
         ok is where the fringe energy is estimated */
      idsb(l,ko,w) = 1;
      idsi(l,ok,w) = 1;
      
      /* Variance is the level of power (before dark substraction). This is used in the fitting
         procedure to give adequate weight to each points in the bias. Note that this will also
         slightly reduce the effect of vibration pics */
      sy = sqrt( psd0(l,,avg,w)(zcen)(pcen)(zcen)(pcen)(zcen)(pcen)(zcen)(pcen)(zcen)(pcen)(zcen)(pcen)(ko) );
    
      for (s=1;s<=nscan;s++) {
        /* Check if scan is rejected */
        if ( data(l,sum,s,w) == 0.0 ) continue;
        
        /* Compute the bias with a fit with a shape (a + b.x).
           Use a constant (a) when no point on both side of id0. */
        y = psd(l,ko,s,w);
        if ( min(ko)<id0(l,w) & max(ko)>id0(l,w)) {
          b  = regress(y, [1., freq(ko,w)], sigy=sy);
          bias(l,,s,w) = b(1) + b(2)*freq(,w);
        } else {
          bias(l,,s,w) = y(avg);
        }
      }
    }
  }
  
  /* Remove this bias level. Keep the null scans at 0.
     FIXME: to check if psdClean */
  psdClean  = psd - bias;
  psdClean *= (abs(data)(sum,sum,-,-,)!=0);

  /* Compute the unbiased amplitude per scan. */
  amp2 = 4 * ( psdClean * idsi(,,-,) )(,sum,,);
  
  /* Check the pos array */
  if (is_void(pos) || allof(pos==0)) {
    yocoLogInfo," enveloppe is computed centered";
    pos = array(0.0, nscan, nbase);
  }

  /* Compute the theoretical enveloppe of fringes.
     gaussien or yocoMathSinc(pi*opd(,-)/lbd^2*lbdB)*/
  opd = opd - opd(avg,-,) - pos(-,);
  env = exp(- (pi*opd(-,)/lbd0^2*lbdB)^2 / 5.0);
  norm2env = env^2 * norm2;
  
  /* FIXME: Check the possible bias at low SNR. No bias detected in the
     simulation mode of pndrs... to be investigated more. */
  n2 = norm2env(,sum,,);
 
  /* Compute the visibility average and errors by using <amp2>/<n2>,
     and a bootstraping methode to compute the error. This naturally
     gives a weight proportional to the signal itself. */
  pndrsSignalComputeAmp2Ratio, amp2, n2, vis2, vis2Err, gui=(is_array(gui)? gui+1: []);
  // pndrsSignalComputeAmp2RatioTest, amp2, n2, vis2, vis2Err, gui=(is_array(gui)? gui+1: []);

  /* We also compute the vis2 per scan, for the plot */
  vis2perscan = amp2 / (n2+1e-10);


  /* Build the oiVis2. Note that the staIndex refer to the
     PIONIER arms (1234 of the correlation map) */
  log = oiFitsGetOiLog(coherData, imgLog);
  oiVis2 = array( oiFitsGetOiStruct("oiVis2", -1), nbase);
  oiVis2.hdr.logId   = log.logId;
  oiVis2.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiVis2.mjd         = (*coherData.time)(*)(avg);
  oiVis2.intTime     = (*coherData.exptime)(sum);
  oiVis2.staIndex    = transpose([map.t1, map.t2]);

  /* Fill the data */
  flag = char(vis2Err>1);
  oiFitsSetDataArray, oiVis2,, vis2, vis2Err, vis2*0 + 1, vis2Err*0, flag;

  /* Add QC parameters */
  yocoLogInfo," add QC parameters";
  id = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  iss = totxt( pndrsPionierToIss(imgLog(id), [map.t1,map.t2]) )(,sum);
  pndrsSetLogInfoArray, imgLog, id, "qcNorm%sAvg", iss, average(n2(avg,,),1);
  pndrsSetLogInfoArray, imgLog, id, "qcAmp%sAvg", iss, average(amp2(avg,,),1);
  pndrsSetLogInfoArray, imgLog, id, "qcVis%sAvg", iss, average(vis2,1);
  pndrsSetLogInfoArray, imgLog, id, "qcVis%sErr", iss, average(vis2Err,1);

  /* Build the default insName */
  oiVis2.hdr.insName = pndrsDefaultInsName(log, map.pol);
  
  /* Plot the outputs PSD to have a data quality estimate */
  if (gui && pndrsBatchPlotLevel) {
    window,gui+1;
    sta  = pndrsPlotGetBaseName(oLog);
    main = swrite(format="%s - %.4f", oLog.target, (*coherData.time)(*)(avg));
    pndrsPlotAddTitles,sta,main;

    winkill,gui+2;
    yocoNmCreate,gui+2,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,vis2perscan(0,),tosys=indgen(nbase);
    yocoPlotHorizLine,vis2(0,),tosys=indgen(nbase);
    yocoPlotPlpMulti,vis2perscan(1,),tosys=indgen(nbase),color="red";
    yocoPlotHorizLine,vis2(1,),tosys=indgen(nbase),color="red";
    yocoNmRange,0,1;
    pndrsPlotAddTitles,sta,main;
 
    winkill,gui+3;
    yocoNmCreate,gui+3,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,vis2,tosys=indgen(nbase),dy=vis2Err,symbol=0;
    yocoPlotPlgMulti,vis2,tosys=indgen(nbase);
    yocoNmLimits,0.5,nlbd+0.5,0,1;
    pndrsPlotAddTitles,sta,main;
 
    winkill,gui+4;
    yocoNmCreate,gui+4,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti,average(amp2,2),tosys=indgen(nbase);
    yocoPlotPlgMulti,average(n2,2),tosys=indgen(nbase),type=2;
    yocoPlotPlpMulti,average(amp2,2),tosys=indgen(nbase),symbol=3,fill=1;
    yocoPlotPlpMulti,average(n2,2),tosys=indgen(nbase),symbol=4,fill=1;
    yocoNmLimits,0.5,nlbd+0.5,0;
    pndrsPlotAddTitles,sta,main;

    winkill,gui+5;
    yocoNmCreate,gui+5,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(psddark(avg,),2), freq, tosys=indgen(nbase), color="green";
    yocoPlotPlgMulti, average(psd0(avg,),2),    freq, tosys=indgen(nbase);
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,1.8*max(filtIn),restrict=1;
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, filtOut(,i),color="red",type=2;
      yocoPlotHorizLine, 0.0;
    }
    pndrsPlotAddTitles,sta,main;

    /* psdIdMax */
    winkill,gui+6;
    yocoNmCreate,gui+6,2,nbase/2,dx=0.06,dy=0.05;
    yocoPlotPlgMulti,average(psdClean(0,),2), freq, tosys=indgen(nbase);
    yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=2;
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,3.*sig0(avg);
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, filtOut(,i),color="red",type=2;
      yocoPlotVertLine, sig0(0)+[-1,0,1]*predWidth(0,i), color="green",type=[2,3,2];
      yocoPlotPlp,(x=where(idsb(0,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
      yocoPlotPlp,(x=where(idsi(0,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
    }
    yocoPlotPlgMulti,average(psdClean(0,),2), freq, tosys=indgen(nbase);
    pndrsPlotAddTitles,sta,main;

    /* psdIdMin */
    winkill,gui+7;
    yocoNmCreate,gui+7,2,nbase/2,dx=0.06,dy=0.05;
    yocoPlotPlgMulti,average(psdClean(1,),2), freq, tosys=indgen(nbase);
    yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=3;
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,3.*sig0(avg);
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, filtOut(,i),color="red",type=2;
      yocoPlotVertLine, sig0(1)+[-1,0,1]*predWidth(1,i), color="green",type=[2,3,2];
      yocoPlotPlp,(x=where(idsb(1,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
      yocoPlotPlp,(x=where(idsi(1,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
    }
    yocoPlotPlgMulti,average(psdClean(1,),2), freq, tosys=indgen(nbase);
    pndrsPlotAddTitles,sta,main;
    
    winkill,gui+9;
    yocoNmCreate,gui+9,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data.re(1,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, data.im(1,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, max(norm2env(1,,2:3,)(*,),0)^0.5, tosys=indgen(nbase), color="red", width=3;
    pndrsPlotAddTitles,sta,main;

    winkill,gui+10;
    yocoNmCreate,gui+10,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data.re(0,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, data.im(0,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, max(norm2env(0,,2:3,)(*,),0)^0.5, tosys=indgen(nbase), color="red", width=3;
    pndrsPlotAddTitles,sta,main;

    for (cen=1;cen<=nlbd;cen++) {
      winkill,gui+10+cen;
      yocoNmCreate,gui+10+cen,2,nbase/2,dx=0.06,dy=0.05;
      yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=2;
      for (i=1;i<=nbase;i++) {
        plsys,i;
        limits,0,3.*sig0(avg);
        yocoPlotVertLine, filtIn(,i),color="blue",type=2;
        yocoPlotVertLine, filtOut(,i),color="red",type=2;
        yocoPlotVertLine, sig0(cen)+[-1,0,1]*predWidth(cen,i), color="green",type=[2,3,2];
        yocoPlotPlp,(x=where(idsb(cen,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
        yocoPlotPlp,(x=where(idsi(cen,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
      }
      yocoPlotPlgMulti,average(psdClean(cen,),2), freq, tosys=indgen(nbase);
      // yocoPlotPlgMulti, average(psdbias(cen,),2), freq, tosys=indgen(nbase), color="green";
      // yocoPlotPlgMulti, average(psd0(cen,),2),    freq, tosys=indgen(nbase);
      pndrsPlotAddTitles,sta,main;
    }
     
  }
  
  yocoLogTrace,"pndrsScanComputeAmp2PerScan done";
  return 1;
}

func pndrsScanComputeAmp2PerScanAbcd(coherData, &imgLog, norm2, pos, &oiVis2, &amp2, &amp2Err, gui=)
/* DOCUMENT pndrsScanComputeAmp2PerScanAbcd(coherData, imgLog, norm2, &oiVis2, &amp2, &amp2Err, gui=)

   DESCRIPTION
   Compute a value of amp2 (unbiased power of the fringes) and n2 (power of the normalisation flux)
   per scan and then compute the final vis2 by  v2 = <amp2> / <n2>.
   Statistical errors are estimated by bootstrating.

   The unbiased power amp2 is computed in the Fourier space. The bias is estimated and removed
   scan by scan. The average PSD is also plotted to check the bias removed on the display
   at high SNR.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanComputeAmp2PerScanAbcd()";
  local i, data, opd, nbase, nstep, map, ntel, dx, ft, psd, freq, tau0, fwhm, idm;
  local boot, psdbias, nIn, log, npol, pol, x, y, yf, sta, lbd0, lbdB, env;
  local psd0, crop, n2, isRejected, mask, time, vel, tauB, predWidth, time;
  oiVis2 = [];

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;
  ntel = pndrsGetNtelInMap(map); 
  pol  = yocoListClean(map.pol)(*);
  

  /* Some dimension */
  nlbd  = dimsof(data)(2);
  idm   = nlbd/2+1;
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nbase = dimsof(data)(5);
  npol  = numberof(pol);

  /* Default Wave */
  pndrsGetDefaultWave, oLog, lbd0, lbdB, sig0;

  /* Perform FFT and PSD */
  pndrsSignalFourierTransform, data, opd, ft, freq;
  psd0    = power(ft);
  freq    = abs(freq)(,1,);
  id0     = abs(freq(-,) - sig0)(,mnx,);

  /* The PSD of the BIAS is estimated with the opposite frequencies */
  psdbias = psd0;
  psdbias(,2:,,) = psdbias(,:2:-1,,);

  /* Compute the predicted width of the pic based on
     the tau0 and scanning speed */
  predWidth = pndrsGetPicWidth(oLog, checkUTs=1);
  
  /* Load the filter corresponding to the band */
  if (strmatch( pndrsGetBand(oLog(1)), "K") ) {
    filtIn  = pndrsFilterKIn;
  }
  if (strmatch( pndrsGetBand(oLog(1)), "H") ) {
    filtIn  = pndrsFilterHIn;
  }
  
  /* Check size */
  if (dimsof(filtIn)(1)==1) {
    filtIn = filtIn(,-:1:nbase);
  }

  /* Get the index inside and outside the filters */
  filtInP  = (abs(freq)>filtIn(1,-,))  & (abs(freq)<filtIn(2,-,));

  /* Some verbose */
  if (pndrsOptionBiasMethod!=2)
    yocoLogInfo,"Acceptance filter is:",filtIn;
  
  idsi = array(0,nlbd,nstep,nbase);
  for (w=1;w<=nbase;w++)  {
    
    for (l=1;l<=nlbd;l++) {
      yocoLogTrace,"Compute Bias and Energy for base "+pr1(w)+" and lbd "+pr1(l);

      /* Compute the frequencies where to measure the bias level
         and where to integrate the energy of fringes */
      if (pndrsOptionBiasMethod==2) {
        ok = where ( indgen(nstep) > 15 &
                     (freq(,w) > (sig0(l)-predWidth(l,w)) & freq(,w) < (sig0(l)+predWidth(l,w)) ) &
                     indgen(nstep) < nstep/2-5 );
      }
      else {
        ok = where( filtInP(,w) );
      }

      /* Check if a valid integration domain for the fringe energy could be found */
      if ( !is_array(ok) ) {
        yocoError,"No valid domain found for the integration... ";
        return 0;
      }

      /* Store this array for later display,
         ok is where the fringe energy is estimated */
      idsi(l,ok,w) = 1;
    }
  }

  /* Remove the PSD of the BIAS. Keep the null scans at 0 */
  psdClean  = psd0 - psdbias;
  psdClean *= (abs(data)(sum,sum,-,-,)!=0);

  /* Compute the unbiased amplitude per scan. */
  amp2 = 4 * ( psdClean * idsi(,,-,) )(,sum,,);
  
  /* Check the pos array */
  if (is_void(pos) || allof(pos==0)) {
    yocoLogInfo," enveloppe is computed centered";
    pos = array(0.0, nscan, nbase);
  }

  /* Compute the theoretical enveloppe of fringes.
     gaussien or yocoMathSinc(pi*opd(,-)/lbd^2*lbdB)*/
  opd = opd - opd(avg,-,) - pos(-,);
  env = exp(- (pi*opd(-,)/lbd0^2*lbdB)^2 / 5.0);
  norm2env = env^2 * norm2;
  
  /* FIXME: Check the possible bias at low SNR. No bias detected in the
     simulation mode of pndrs... to be investigated more. */
  n2 = norm2env(,sum,,);
 
  /* Compute the visibility average and errors by using <amp2>/<n2>,
     and a bootstraping methode to compute the error. This naturally
     gives a weight proportional to the signal itself. */
  pndrsSignalComputeAmp2Ratio, amp2, n2, vis2, vis2Err, gui=(is_array(gui)? gui+1: []);
  // pndrsSignalComputeAmp2RatioTest, amp2, n2, vis2, vis2Err, gui=(is_array(gui)? gui+1: []);

  /* We also compute the vis2 per scan, for the plot */
  vis2perscan = amp2 / (n2+1e-10);


  /* Build the oiVis2. Note that the staIndex refer to the
     PIONIER arms (1234 of the correlation map) */
  log = oiFitsGetOiLog(coherData, imgLog);
  oiVis2 = array( oiFitsGetOiStruct("oiVis2", -1), nbase);
  oiVis2.hdr.logId   = log.logId;
  oiVis2.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiVis2.mjd         = (*coherData.time)(*)(avg);
  oiVis2.intTime     = (*coherData.exptime)(sum);
  oiVis2.staIndex    = transpose([map.t1, map.t2]);

  /* Fill the data */
  flag = char(vis2Err>1);
  oiFitsSetDataArray, oiVis2,, vis2, vis2Err, vis2*0 + 1, vis2Err*0, flag;

  /* Add QC parameters */
  yocoLogInfo," add QC parameters";
  id = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  iss = totxt( pndrsPionierToIss(imgLog(id), [map.t1,map.t2]) )(,sum);
  pndrsSetLogInfoArray, imgLog, id, "qcNorm%sAvg", iss, average(n2(avg,,),1);
  pndrsSetLogInfoArray, imgLog, id, "qcAmp%sAvg", iss, average(amp2(avg,,),1);
  pndrsSetLogInfoArray, imgLog, id, "qcVis%sAvg", iss, average(vis2,1);
  pndrsSetLogInfoArray, imgLog, id, "qcVis%sErr", iss, average(vis2Err,1);
  
  /* Build the default insName */
  oiVis2.hdr.insName = pndrsDefaultInsName(log, map.pol);

  /* Plot the outputs PSD to have a data quality estimate */
  if (gui && pndrsBatchPlotLevel) {
    window,gui+1;
    sta  = pndrsPlotGetBaseName(oLog);
    main = swrite(format="%s - %.4f", oLog.target, (*coherData.time)(*)(avg));
    pndrsPlotAddTitles,sta,main,"Amp2/n2 per scan (red is fist channel, green middle and black last)",
      "Norm. power (n2)", "Coherent power (Amp2)";

    winkill,gui+2;
    yocoNmCreate,gui+2,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,vis2perscan(1,),tosys=indgen(nbase),color="red";
    yocoPlotHorizLine,vis2(1,),tosys=indgen(nbase),color="red";
    yocoPlotPlpMulti,vis2perscan(0,),tosys=indgen(nbase), color="green";
    yocoPlotHorizLine,vis2(0,),tosys=indgen(nbase), color="green";
    yocoPlotPlpMulti,vis2perscan(idm,),tosys=indgen(nbase);
    yocoPlotHorizLine,vis2(idm,),tosys=indgen(nbase);
    yocoNmRange,0,1;
    pndrsPlotAddTitles,sta,main,"V2 per scan (not the true estimator)","scan number","V2";
 
    winkill,gui+3;
    yocoNmCreate,gui+3,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,vis2,tosys=indgen(nbase),dy=vis2Err,symbol=0;
    yocoPlotPlgMulti,vis2,tosys=indgen(nbase);
    yocoNmLimits,0.5,nlbd+0.5,0,1;
    pndrsPlotAddTitles,sta,main,"Final vis2","spec. channel","V2";
    
    winkill,gui+4;
    yocoNmCreate,gui+4,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti,average(amp2,2),tosys=indgen(nbase);
    yocoPlotPlgMulti,average(n2,2),tosys=indgen(nbase),type=2;
    yocoPlotPlpMulti,average(amp2,2),tosys=indgen(nbase),symbol=3,fill=1;
    yocoPlotPlpMulti,average(n2,2),tosys=indgen(nbase),symbol=4,fill=1;
    yocoNmLimits,0.5,nlbd+0.5,0;
    pndrsPlotAddTitles,sta,main,"Average fringe power amp2 and normalisation n2","spec. channel","Power";

    winkill,gui+5;
    yocoNmCreate,gui+5,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(psdbias(1,),2), freq, tosys=indgen(nbase), color="green";
    yocoPlotPlgMulti, average(psd0(1,),2),    freq, tosys=indgen(nbase);
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,1.8*max(filtIn),restrict=1;
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotHorizLine, 0.0;
    }
    pndrsPlotAddTitles,sta,main,"PSD of coherent flux and PSD of bias for channel 1","freq. [m^-1^]","PSD";

    /* psdIdMax */
    winkill,gui+6;
    yocoNmCreate,gui+6,2,nbase/2,dx=0.06,dy=0.05;
    yocoPlotPlgMulti,average(psdClean(0,),2), freq, tosys=indgen(nbase);
    yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=2;
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,3.*sig0(avg);
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, sig0(0)+[-1,0,1]*predWidth(0,i), color="green",type=[2,3,2];
      yocoPlotPlp,(x=where(!idsi(0,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
      yocoPlotPlp,(x=where(idsi(0,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
    }
    yocoPlotPlgMulti,average(psdClean(0,),2), freq, tosys=indgen(nbase);
    pndrsPlotAddTitles,sta,main, "Unbiased PSD of coherent flux for last channel",
        "freq. [m^-1^]","PSD";

    /* psdIdMin */
    winkill,gui+7;
    yocoNmCreate,gui+7,2,nbase/2,dx=0.06,dy=0.05;
    yocoPlotPlgMulti,average(psdClean(1,),2), freq, tosys=indgen(nbase);
    yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=3;
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,3.*sig0(avg);
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, sig0(1)+[-1,0,1]*predWidth(1,i), color="green",type=[2,3,2];
      yocoPlotPlp,(x=where(!idsi(1,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
      yocoPlotPlp,(x=where(idsi(1,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
    }
    yocoPlotPlgMulti,average(psdClean(1,),2), freq, tosys=indgen(nbase);
    pndrsPlotAddTitles,sta,main, "Unbiased PSD of coherent flux for first channel",
        "freq. [m^-1^]","PSD";
    
    winkill,gui+9;
    yocoNmCreate,gui+9,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data.re(1,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, data.im(1,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, max(norm2env(1,,2:3,)(*,),0)^0.5, tosys=indgen(nbase), color="red", width=3;
    pndrsPlotAddTitles,sta,main,"Coherent flux and normalisation norm2 (first channel)","opd step (2 scans)","flux";

    winkill,gui+10;
    yocoNmCreate,gui+10,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data.re(0,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, data.im(0,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, max(norm2env(0,,2:3,)(*,),0)^0.5, tosys=indgen(nbase), color="red", width=3;
    pndrsPlotAddTitles,sta,main,"Coherent flux and normalisation norm2 (last channel)","opd step (2 scans)","flux";

    for (cen=1;cen<=nlbd;cen++) {
      winkill,gui+10+cen;
      yocoNmCreate,gui+10+cen,2,nbase/2,dx=0.06,dy=0.05;
      yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=2;
      for (i=1;i<=nbase;i++) {
        plsys,i;
        limits,0,3.*sig0(avg);
        yocoPlotVertLine, filtIn(,i),color="blue",type=2;
        yocoPlotVertLine, sig0(cen)+[-1,0,1]*predWidth(cen,i), color="green",type=[2,3,2];
        yocoPlotPlp,(x=where(!idsi(cen,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
        yocoPlotPlp,(x=where(idsi(cen,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
      }
      yocoPlotPlgMulti,average(psdClean(cen,),2), freq, tosys=indgen(nbase);
      // yocoPlotPlgMulti, average(psdbias(cen,),2), freq, tosys=indgen(nbase), color="green";
      // yocoPlotPlgMulti, average(psd0(cen,),2),    freq, tosys=indgen(nbase);
      pndrsPlotAddTitles,sta,main, swrite(format="Unbiased PSD of coherent flux for channel %02d",cen),
        "freq. [m^-1^]","PSD";
    }
  }
  
  yocoLogTrace,"pndrsScanComputeAmp2PerScanAbcd done";
  return 1;
}

func pndrsScanComputeAmp2PerScanAbcdWeighted(coherData, &imgLog, norm2, pos, &oiVis2, &amp2, &amp2Err, gui=)
/* DOCUMENT pndrsScanComputeAmp2PerScanAbcdWeighted(coherData, imgLog, norm2, &oiVis2, &amp2, &amp2Err, gui=)

   DESCRIPTION
   Compute a value of amp2 (unbiased power of the fringes) and n2 (power of the normalisation flux)
   per scan and then compute the final vis2 by  v2 = <amp2> / <n2>.
   Statistical errors are estimated by bootstrating.

   The unbiased power amp2 is computed in the Fourier space. The bias is estimated and removed
   scan by scan. The average PSD is also plotted to check the bias removed on the display
   at high SNR.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsScanComputeAmp2PerScanAbcdWeighted()";
  local i, data, opd, nbase, nstep, map, ntel, dx, ft, psd, freq, tau0, fwhm;
  local boot, psdbias, nIn, log, npol, pol, x, y, yf, sta, lbd0, lbdB, env;
  local psd0, crop, n2, isRejected, mask, time, vel, tauB, predWidth;
  oiVis2 = [];

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;
  ntel = pndrsGetNtelInMap(map); 
  pol  = yocoListClean(map.pol)(*);

  /* Some dimension */
  nlbd  = dimsof(data)(2);
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nbase = dimsof(data)(5);
  npol  = numberof(pol);

  /* Default Wave */
  pndrsGetDefaultWave, oLog, lbd0, lbdB, sig0;

  /* Check the pos array */
  if (is_void(pos) || allof(pos==0)) {
    yocoLogInfo," enveloppe is computed centered";
    pos = array(0.0, nscan, nbase);
  }

  /* Perform photometric normalisation */
  data /= sqrt(max(norm2,0.25));

  /* Perform FFT and PSD */
  pndrsSignalFourierTransform, data, opd, ft, freq;
  psd0    = power(ft);
  freq    = abs(freq)(,1,);
  id0     = abs(freq(-,) - sig0)(,mnx,);

  /* The PSD of the BIAS is estimated with the opposite frequencies */
  psdbias = psd0;
  psdbias(,2:,,) = psdbias(,:2:-1,,);

  /* Compute the predicted width of the pic based on
     the tau0 and scanning speed */
  predWidth = pndrsGetPicWidth(oLog, checkUTs=1);
  
  /* Load the filter corresponding to the band */
  if (strmatch( pndrsGetBand(oLog(1)), "K") ) {
    filtIn  = pndrsFilterKIn;
  }
  if (strmatch( pndrsGetBand(oLog(1)), "H") ) {
    filtIn  = pndrsFilterHIn;
  }
  
  /* Check size */
  if (dimsof(filtIn)(1)==1) {
    filtIn = filtIn(,-:1:nbase);
  }

  /* Get the index inside and outside the filters */
  filtInP  = (abs(freq)>filtIn(1,-,))  & (abs(freq)<filtIn(2,-,));

  /* Some verbose */
  if (pndrsOptionBiasMethod!=2)
    yocoLogInfo,"Acceptance filter is:",filtIn;
  
  idsi = array(0,nlbd,nstep,nbase);
  for (w=1;w<=nbase;w++)  {
    
    for (l=1;l<=nlbd;l++) {
      yocoLogTrace,"Compute Bias and Energy for base "+pr1(w)+" and lbd "+pr1(l);

      /* Compute the frequencies where to measure the bias level
         and where to integrate the energy of fringes */
      if (pndrsOptionBiasMethod==2) {
        ok = where ( indgen(nstep) > 15 &
                     (freq(,w) > (sig0(l)-predWidth(l,w)) & freq(,w) < (sig0(l)+predWidth(l,w)) ) &
                     indgen(nstep) < nstep/2-5 );
      }
      else {
        ok = where( filtInP(,w) );
      }

      /* Check if a valid integration domain for the fringe energy could be found */
      if ( !is_array(ok) ) {
        yocoError,"No valid domain found for the integration... ";
        return 0;
      }

      /* Store this array for later display,
         ok is where the fringe energy is estimated */
      idsi(l,ok,w) = 1;
    }
  }

  /* Remove the PSD of the BIAS. Keep the null scans at 0 */
  psdClean  = psd0 - psdbias;
  psdClean *= (abs(data)(sum,sum,-,-,)!=0);

  /* Compute the unbiased amplitude per scan. */
  amp2 = 4 * ( psdClean * idsi(,,-,) )(,sum,,);

  /* FIXME: found this factor */
  amp2 /= [8,4,12,4,4,8](-,-,) * 20;

  /* Weight each scan by the expected power */
  opd = opd - opd(avg,-,) - pos(-,);
  env = exp(- (pi*opd(-,)/lbd0^2*lbdB)^2 / 5.0);
  norm2env = env^2 * norm2;
  n2       = norm2env(,sum,,);
  
  /* Compute the visibility average and errors by
     bootstraping methode. */
  pndrsSignalComputeAmp2Ratio, amp2*n2, n2, vis2, vis2Err, gui=(is_array(gui)? gui+1: []);
  // pndrsSignalComputeAmp2RatioTest, amp2, n2, vis2, vis2Err, gui=(is_array(gui)? gui+1: []);

  /* We also compute the vis2 per scan, for the plot */
  vis2perscan = amp2;

  /* Build the oiVis2. Note that the staIndex refer to the
     PIONIER arms (1234 of the correlation map) */
  log = oiFitsGetOiLog(coherData, imgLog);
  oiVis2 = array( oiFitsGetOiStruct("oiVis2", -1), nbase);
  oiVis2.hdr.logId   = log.logId;
  oiVis2.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiVis2.mjd         = (*coherData.time)(*)(avg);
  oiVis2.intTime     = (*coherData.exptime)(sum);
  oiVis2.staIndex    = transpose([map.t1, map.t2]);

  /* Fill the data */
  flag = char(vis2Err>1);
  oiFitsSetDataArray, oiVis2,, vis2, vis2Err, vis2*0 + 1, vis2Err*0, flag;

  /* Fill the log with the values for the flux */
  id = oiFitsGetId(coherData.hdr.logId, imgLog.logId);
  yocoLogInfo, "Add n2arr into imgLog: "+pr1(n2(,avg,avg));
  imgLog(id).n2arr   = pr1(n2(,avg,avg));
  imgLog(id).amp2arr = pr1(amp2(,avg,avg));
  
  /* Build the default insName */
  oiVis2.hdr.insName = pndrsDefaultInsName(log, map.pol);

  /* Plot the outputs PSD to have a data quality estimate */
  if (gui && pndrsBatchPlotLevel) {
    window,gui+1;
    sta  = pndrsPlotGetBaseName(oLog);
    main = swrite(format="%s - %.4f", oLog.target, (*coherData.time)(*)(avg));
    pndrsPlotAddTitles,sta,main;

    winkill,gui+2;
    yocoNmCreate,gui+2,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,vis2perscan(0,),tosys=indgen(nbase);
    yocoPlotHorizLine,vis2(0,),tosys=indgen(nbase);
    yocoPlotPlpMulti,vis2perscan(1,),tosys=indgen(nbase),color="red";
    yocoPlotHorizLine,vis2(1,),tosys=indgen(nbase),color="red";
    yocoNmRange,0,1;
    pndrsPlotAddTitles,sta,main;
 
    winkill,gui+3;
    yocoNmCreate,gui+3,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlpMulti,vis2,tosys=indgen(nbase),dy=vis2Err,symbol=0;
    yocoPlotPlgMulti,vis2,tosys=indgen(nbase);
    yocoNmLimits,0.5,nlbd+0.5,0,1;
    pndrsPlotAddTitles,sta,main;
 
    winkill,gui+4;
    yocoNmCreate,gui+4,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti,average(amp2,2),tosys=indgen(nbase);
    yocoPlotPlgMulti,average(n2,2),tosys=indgen(nbase),type=2;
    yocoPlotPlpMulti,average(amp2,2),tosys=indgen(nbase),symbol=3,fill=1;
    yocoPlotPlpMulti,average(n2,2),tosys=indgen(nbase),symbol=4,fill=1;
    yocoNmLimits,0.5,nlbd+0.5,0;
    pndrsPlotAddTitles,sta,main;

    winkill,gui+5;
    yocoNmCreate,gui+5,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, average(psdbias(1,),2), freq, tosys=indgen(nbase), color="green";
    yocoPlotPlgMulti, average(psd0(1,),2),    freq, tosys=indgen(nbase);
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,1.8*max(filtIn),restrict=1;
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotHorizLine, 0.0;
    }
    pndrsPlotAddTitles,sta,main;

    /* psdIdMax */
    winkill,gui+6;
    yocoNmCreate,gui+6,2,nbase/2,dx=0.06,dy=0.05;
    yocoPlotPlgMulti,average(psdClean(0,),2), freq, tosys=indgen(nbase);
    yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=2;
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,3.*sig0(avg);
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, sig0(0)+[-1,0,1]*predWidth(0,i), color="green",type=[2,3,2];
      yocoPlotPlp,(x=where(!idsi(0,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
      yocoPlotPlp,(x=where(idsi(0,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
    }
    yocoPlotPlgMulti,average(psdClean(0,),2), freq, tosys=indgen(nbase);
    pndrsPlotAddTitles,sta,main;

    /* psdIdMin */
    winkill,gui+7;
    yocoNmCreate,gui+7,2,nbase/2,dx=0.06,dy=0.05;
    yocoPlotPlgMulti,average(psdClean(1,),2), freq, tosys=indgen(nbase);
    yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=3;
    for (i=1;i<=nbase;i++) {
      plsys,i;
      limits,0,3.*sig0(avg);
      yocoPlotVertLine, filtIn(,i),color="blue",type=2;
      yocoPlotVertLine, sig0(1)+[-1,0,1]*predWidth(1,i), color="green",type=[2,3,2];
      yocoPlotPlp,(x=where(!idsi(1,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
      yocoPlotPlp,(x=where(idsi(1,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
    }
    yocoPlotPlgMulti,average(psdClean(1,),2), freq, tosys=indgen(nbase);
    pndrsPlotAddTitles,sta,main;
    
    winkill,gui+9;
    yocoNmCreate,gui+9,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data.re(1,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, data.im(1,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, max(norm2env(1,,2:3,)(*,),0)^0.5, tosys=indgen(nbase), color="red", width=3;
    pndrsPlotAddTitles,sta,main;

    winkill,gui+10;
    yocoNmCreate,gui+10,2,nbase/2,dx=0.06,dy=0.01;
    yocoPlotPlgMulti, data.re(0,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, data.im(0,,2:3,)(*,), tosys=indgen(nbase);
    yocoPlotPlgMulti, max(norm2env(0,,2:3,)(*,),0)^0.5, tosys=indgen(nbase), color="red", width=3;
    pndrsPlotAddTitles,sta,main;

    for (cen=1;cen<=nlbd;cen++) {
      winkill,gui+10+cen;
      yocoNmCreate,gui+10+cen,2,nbase/2,dx=0.06,dy=0.05;
      yocoPlotPlgMulti,average(psdClean(cen,),2), freq, tosys=indgen(nbase);
      yocoPlotHorizLine,[0], tosys=indgen(nbase), color="red", type=2, width=2;
      for (i=1;i<=nbase;i++) {
        plsys,i;
        limits,0,3.*sig0(avg);
        yocoPlotVertLine, filtIn(,i),color="blue",type=2;
        yocoPlotVertLine, sig0(cen)+[-1,0,1]*predWidth(cen,i), color="green",type=[2,3,2];
        yocoPlotPlp,(x=where(!idsi(cen,,i)))*0,freq(x,i), color="red",symbol=4,size=0.5,fill=1;
        yocoPlotPlp,(x=where(idsi(cen,,i)))*0,freq(x,i), color="green",symbol=2,size=0.5,fill=1;
      }
      yocoPlotPlgMulti,average(psdClean(cen,),2), freq, tosys=indgen(nbase);
      pndrsPlotAddTitles,sta,main;
    }
  }
  
  yocoLogTrace,"pndrsScanComputeAmp2PerScanAbcdWeighted done";
  return 1;
}


/* ******************************************************** */

func pndrsScanComputeAmp2DirectSpace(coherData, imgLog, filtIn, filtOut, norm, &oiVis2, &amp2, &amp2Err, gui=)
/* DOCUMENT pndrsScanComputeAmp2DirectSpace(coherData, imgLog, filtIn, filtOut, &oiVis2, &amp2, &amp2Err, gui=)

   DESCRIPTION
   Compute the amp2 with the following method:
   - filter
   - take the maximum of the enveloppe
   - average over the scans
 */
{
  yocoLogInfo,"pndrsScanComputeAmp2DirectSpace()";
  local i, data, opd, nbase, map, ntel, dx, ft, psd, freq;
  local boot, nIn, log, npol, pol;
  oiVis2 = [];

  /* Get the data and the opds */
  pndrsGetData, coherData, imgLog, data, opd, map;
  ntel = pndrsGetNtelInMap(map); 
  pol  = yocoListClean(map.pol)(*);
  npol = numberof(pol);

  /* Filter the data and mulitply by 2 since
     the negative frequencies have been lost */
  pndrsSignalSquareFiltering, data, opd, filtIn, dataf;
  dataf *= 2.0;

  /* Divide by the photometrie */
  dataf = dataf / (norm + 1e-10);

  /* Visibility in the direct space */
  vis2perscan   = abs(dataf)(,max,,)^2;
  
  /* Compute the final amplitude */
  vis2Err = vis2perscan(,rms,);
  vis2    = average(vis2perscan,2);

  /* Build the oiVis2. Note that the staIndex refer to the
     PIONIER arms (1234 of the map) */
  log = oiFitsGetOiLog(coherData, imgLog);
  oiVis2 = array( oiFitsGetOiStruct("oiVis2", -1), nbase);
  oiVis2.hdr.logId   = log.logId;
  oiVis2.hdr.dateObs = strtok(log.dateObs,"T")(1);
  oiVis2.mjd         = (*coherData.time)(*)(avg);
  oiVis2.intTime     = (*coherData.exptime)(sum);
  oiVis2.staIndex    = transpose([map.t1, map.t2]);

  /* Fill the data */
  flag = char(vis2Err>1);
  oiFitsSetDataArray, oiVis2,, vis2, vis2Err, vis2*0 + 1, vis2Err*0, flag;

  /* Build the default insName */
  oiVis2.hdr.insName = pndrsDefaultInsName(log, map.pol);

  /* Some plot */
  nbase = dimsof(vis2)(0);
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui+2;
    yocoNmCreate,gui+2,2,nbase/2;
    yocoPlotPlpMulti,vis2perscan(0,),tosys=indgen(nbase);
    yocoPlotHorizLine,vis2(0,),tosys=indgen(nbase);
    yocoPlotPlpMulti,vis2perscan(1,),tosys=indgen(nbase),color="red";
    yocoPlotHorizLine,vis2(1,),tosys=indgen(nbase),color="red";
    yocoNmRange,0,1;

    winkill,gui+3;
    yocoNmCreate,gui+3,2,nbase/2;
    yocoPlotPlpMulti,vis2,tosys=indgen(nbase),dy=vis2Err,symbol=0;
    yocoPlotPlgMulti,vis2,tosys=indgen(nbase);
    yocoNmRange,0,1;
  }
  
  yocoLogTrace,"pndrsScanComputeAmp2DirectSpace done";
  return 1;
}

/* ******************************************************************* */
func pndrsGetDefaultWave(olog,&lbd,&lbdB,&sig)
/* DOCUMENT pndrsGetDefaultWave(olog,&lbd,&lbdB,&sig)

   DESCRIPTION
   Get the default value for the wavelength calibration
   beased on the instrumental setup defined in olog.

   PARAMETERS
   - olog : an single oiLog structure
   - &lbd : wavelength array (m)
   - &lbdB: 

   EXAMPLES

   SEE ALSO
 */
{
  local mjd;
  mjd = olog.mjdObs;

  if ( olog.detName == "RAPID" )
    return pndrsGetDefaultWaveRapidH(olog,lbd,lbdB,sig);
  else if ( mjd > 56021 )
    return pndrsGetDefaultWaveHK(olog,lbd,lbdB,sig);
  else
    return pndrsGetDefaultWaveH(olog,lbd,lbdB,sig);
}

func pndrsGetDefaultWaveRapidH(olog,&lbd,&lbdB,&sig,&ids)
{
  local ny,nx,x0,y0;

  /* Parse the information */
  pndrsParseSubwin, olog.detSubwin1, nx, ny, x0, y0;
  prism  = pndrsGetPrism(olog);
  woll   = pndrsGetWoll(olog);

  /* FIXME:
     Weird that the outputs seems to have different dispersion.
     Surely an issue with one piezo scanner...
     loi du GRISM: 50nm/pixel, lineaire en lambda */
  if (prism=="FREE" )
    {
      lbd  = [1.64e-06];
      lbdB = [3.0e-07];
    }
  else if (prism=="GRISM" && woll=="FREE")
    {
      x = x0 + indgen(0:nx-1);
      lbd = 1.725e-6 + 4.8e-08 * (x - olog.detXref - 4);
      lbdB = lbd*0 + 4.8e-08;
    }
  else if (prism=="GRISM" && woll=="WOLL")
    {
      x = x0 + indgen(0:nx-1);
      lbd = 1.725e-6 + 4.8e-08 * (x - olog.detXref - 4 + 5);
      lbdB = lbd*0 + 4.8e-08;
    }
  else {
      nx; prism;
      yocoError, "default oiWave is not supported";
      return 0;
    }

  /* Hack to keep only H-band */
  // yocoLogInfo,"RAPID hack to keep only the H-band";
  // ids = where( (lbd>1.58e-6) & (lbd<1.9e-6));
  // ids = where( (lbd>1.e-6) & (lbd<2.1e-6));
  // lbd  = lbd(ids);
  // lbdB = lbdB(ids);

  //2: 0.7364  1.358
  //9: 0.6227  1.606

  // yocoLogInfo, lbd*1e6;
  
  /* loi du GRISM: 50nm/pixel, lineaire en lambda */
  sig = 1./lbd;
  return 1;
}

func pndrsGetDefaultWaveHK(olog,&lbd,&lbdB,&sig)
{
  local ny;
  ny = int( tonum( strpart(olog.detSubwin1,3:3) ) );
  prism  = pndrsGetPrism(olog);
  filter = pndrsGetBand(olog);

  if (filter=="H" && ny==1 && prism=="FREE" )
    {
      lbd  = [1.68108e-06];
      lbdB = [2.45e-07];
    }
  else if (filter=="H" && ny==3 && prism=="SMALL" )
    {
      lbd = [1.59e-06,1.678e-06,1.768e-06];
      lbdB = lbd*0 + 9.35e-08;
    }
  else if ( filter=="H" && ny==7 && prism=="LARGE" )
    {
      lbd = [1.81373,1.77345,1.72029,1.66879,1.61622,1.56531,1.52855] *1e-6;
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( filter=="H" && ny==5 && prism=="LARGE" )
    {
      lbd = [1.77345,1.72029,1.66879,1.61622,1.56531] *1e-6;
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( filter=="H" && ny==3 && prism=="LARGE" )
    {
      lbd = [1.72029,1.66879,1.61622] *1e-6;
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( (filter=="K" || filter=="Kp") && ny==1 && prism=="FREE" )
    {
      lbd  = [2.051e-06];
      lbdB = [1.75e-07]; 
    }
  else if ( (filter=="K" || filter=="Kp") && ny==7 && prism=="LARGE" )
    {
      // COM-K numero 1 (depend on ref-pix and geometry)
      // Probably biased because it was done in the internal light
      lbd = [2.17433,2.13937,2.09438,2.04813,2.00948,1.9702,1.935] *1e-6;  
      // COM-K numero 2: REFpix = 45  // 1x7+2+43 Sub-window geometry
      // This is based on MARCELL fringes
      lbd = [2.30947,2.26757,2.22222,2.18341,2.13675,2.09644,2.04918] *1e-6;
      lbdB = lbd*0 + 3.5e-08; 
    }
  else if ( (filter=="K" || filter=="Kp") && ny==5 && prism=="LARGE" )
    {
      lbd = [2.26757,2.22222,2.18341,2.13675,2.09644] *1e-6;
      lbdB = lbd*0 + 3.5e-08; 
    }
  else if ( (filter=="K" || filter=="Kp") && ny==3 && prism=="LARGE" )
    {
      lbd = [2.22222,2.18341,2.13675] *1e-6;
      lbdB = lbd*0 + 3.5e-08; 
    }
  else
    {
      ny;
      prism;
      yocoError, "default oiWave is not supported";
      return 0;
    }

  sig = 1./lbd;
  return 1;
}

func pndrsGetDefaultWaveH(olog,&lbd,&lbdB,&sig)
{
  local ny, mjd, prism;
  ny    = int( tonum( strpart(olog.detSubwin1,3:3) ) );
  prism = pndrsGetPrism(olog);
  mjd   = olog.mjdObs;

  if ( ny==6 && prism=="LARGE" )
    {
      lbd = [1.80358e-06,1.76275e-06,1.72192e-06,
           1.68108e-06,1.64025e-06,1.59942e-06];
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( ny==7 && prism=="LARGE" )
    {
      lbd = [1.80358e-06,1.76275e-06,1.72192e-06,1.68108e-06,
             1.64025e-06,1.59942e-06,1.55858e-06];
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( ny==3 && prism=="LARGE" )
    {
      lbd = [1.72192e-06,1.68108e-06,1.64025e-06];
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( ny==2 && prism=="LARGE" )
    {
      lbd = [1.72192e-06,1.68108e-06];
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( ny==1 && prism=="LARGE" )
    {
      lbd = [1.68108e-06];
      lbdB = lbd*0 + 4.08333e-08;
    }
  else if ( ny==1 && prism=="FREE" )
    {
      lbd  = [1.68108e-06];
      lbdB = [2.45e-07];
    }
  else if ( ny==5 && prism=="SMALL" )
    {
      lbd = [1.8535e-06,1.76e-06,1.67e-06,1.59e-06,1.4965e-06];
      lbdB = lbd*0 + 9.35e-08;
    }
  else if ( ny==3 && prism=="SMALL" )
    {
      lbd = [1.768e-06,1.678e-06,1.59e-06];
      lbdB = lbd*0 + 9.35e-08;
    }
  else if ( ny==1 && prism=="SMALL" )
    {
      lbd = [1.67e-06];
      lbdB = lbd*0 + 9.35e-08;
    }
  else
    {
      ny;
      prism;
      yocoError, "default oiWave is not supported";
      return 0;
    }

  /* Hack to deal with the bad position of the prism SMALL
     encountered during two nights in August 2011 */
  isIn = (mjd>55778   & mjd<55779.25) ||
         (mjd>55771.9 & mjd<55772.2);
  if ( isIn && prism=="SMALL" )
  {
      yocoLogInfo,"HACK: Inverse wavelength table (prism SMALL inverted)";
      lbd = lbd(::-1);
  }

  /* Hack to deal with the bad alignement 2010-12-06 */
  if ( mjd>55537.0 & mjd<55537.5 )
  {
      yocoLogInfo,"HACK: Displace wavelength table (wrong alignement)";
      lbd -= 6.7e-8;
  }

  /* Deal with the reversal of dispersion that occured with the installation
     of the motorisation of the prisms */
  if ( mjd > 55842.0 )
  {
      yocoLogTrace,"Inverse wavelength table (data obtained with motorized prisms)";
      lbd = lbd(::-1);
  }

  sig = 1./lbd;
  return 1;
}

func pndrsComputeOiWave(specData, &specLog, &oiWave, &sigEff0, nres=, delta=, gui=)
/* DOCUMENT pndrsComputeOiWave(specData, specLog, &oiWave, &sigEff0, nres=, delta=, gui=)

   DESCRIPTION
   Compute the effective wavelength of the channels. A first guess is
   computed from the setup, and the optimized from the data by computing
   the position of the maximum of the PSD.

   PARAMETERS
   - specData should contain coherent flux data at high SNR with the
              enveloppe properly resolved in each baseline.
   - specLog
   - nres:    number of point in the DFT
   - delta: 

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsComputeOiWave()";
  if ( numberof(specData)>1 ) error,"Accept only scalar imgData.";
  local data, opd, map, pol, npol, id;
  local ny, lbd, nres, sigEff, sigBand, success;
  oiWave = [];
  success = 1;

  /* Default for the number of points and the spectral size of the DFT */
  if (is_void(nres))  nres  = 100;
  if (is_void(delta)) delta = 2.0;

  /* Get the data and the opds */
  pndrsGetData, specData, specLog, data, opd, map, olog;
  nbase = dimsof(data)(5);
  pol  = yocoListClean(map.pol)(*);
  npol = numberof(pol);

  /* Build the default wavelength array, that will be used as a first guess */
  pndrsGetDefaultWave, olog, lbd, lbdB;
  ny = numberof(lbd);

  /* Make all in mum to avoid numerical issues */  
  opd  *= 1e6;
  lbd  *= 1e6;
  lbdB *= 1e6; 

  /* Build the wavenumber array */
  sigEff  = (1./lbd);
  sigBand = lbdB / lbd^2;
  sigEff0 = array(double,ny,nbase);

  /* if gui */
  if (gui && pndrsBatchPlotLevel) {
    winkill, gui;
    yocoNmCreate,gui,2,nbase/2,dx=0.06,dy=0.04;
    winkill, gui+2;
    yocoNmCreate,gui+2,2,nbase/2,dx=0.06,dy=0.04;
  }

  /* Loop on the wavelength bin */
  for (l=1 ; l<=ny ; l++) {
    freq  = sigEff(l) + sigBand(l)*delta*span(-1,1,nres);
    freq0 = sigEff(l) + sigBand(l)*delta*span(-1,1,nres*100);
   
    /* Loop on the bases */
    for (k=1 ; k<=nbase ; k++) {
      
      /* Compute DFT */
      dft = (data(l,,,k) * exp(2.i*pi*opd(,,k)*freq(-,-,)) )(sum,,);
      dft = abs(dft)(avg,,);

      /* Plot raw dft */
      if ( gui && pndrsBatchPlotLevel ) {
        window,gui+2;
        yocoPlotPlgMulti,dft,freq,tosys=k;
        logxy,0,1;limits; //range,0;
        yocoPlotVertLine,sigEff(l),color="red",type=2,
          tosys=k,width=3;
      }

      /* Remove the backgroud level */
      dft -= dft(sort(dft))( int(nres/4) );

      /* Look for the position of the maximum and
         the width around the maximum */
      cnt = dft(mxx);
      ok  = (dft>max(dft)/3.0);
      x0 = where(!ok(cnt:1:-1));
      x1 = where(!ok(cnt:));

      /* Check if badly centered */
      if ( cnt>0.9*nres  || cnt<0.1*nres ||
           !is_array(x0) || !is_array(x1) ) {
        success = 0;
        continue;
      }

      /* Compute the interval around the maximum */
      ok = cnt+1-x0(min) : cnt-1+x1(min);
      
      /* Simple barycenter */
      sigEff0(l,k) = (freq * dft)(ok)(sum) / dft(ok)(sum);
      
      if (gui && l==1 && pndrsBatchPlotLevel) {
        window,gui;
        yocoPlotPlpMulti,dft,freq,color="red",tosys=k,size=0.5;
        yocoPlotPlpMulti,dft(ok),freq(ok),color="red",
          tosys=k,symbol=4,fill=1,size=0.5;
        limits; range,0;
        yocoPlotVertLine,sigEff0(l,k),color="red",type=2,
          tosys=k,width=3;
      }
      if (gui && l==ny && pndrsBatchPlotLevel) {
        window,gui;
        yocoPlotPlpMulti,dft,freq,color="green",tosys=k,size=0.5;
        yocoPlotPlpMulti,dft(ok),freq(ok),color="green",
          tosys=k,symbol=4,fill=1,size=0.5;
        limits; range,0;
        yocoPlotVertLine,sigEff0(l,k),color="green",type=2,
          tosys=k,width=3;
      }
    }
  }

  /* Average over the baselines.
     Actually take the median, more robust */
  lbd0 = 1./(median(sigEff0,2));
  yocoLogInfo,"Found spectral bins (mum):", pr1(lbd0);

  /* Add QC parameters: Average effective wavelength,
     average effective band, and variation between baselines */
  yocoLogInfo," add QC parameters";
  specLog.qcEffwave = lbd0(avg)*1e-6;
  specLog.qcEffband = ( numberof(lbd0)>1 ? abs(lbd0(dif))(avg) : lbdB(1) )*1e-6;
  specLog.qcEffwavePtp = abs( (1./(sigEff0+1e-15))(avg,)(ptp) )*1e-6;

  /* Check the difference with expected wavelength */
  if ( max(abs(lbd-lbd0)) > 0.1 ) {
    yocoLogWarning, "Difference with expected wavelength is too hight.";
    yocoLogWarning,"QC quality flag set to T";
    specLog.qcQualityFlag = char('T');
    // return 0;
  }

  /* Loop on the polarisation */
  for ( p=1 ; p<=npol ; p++) {
    grow, oiWave, oiFitsGetOiStruct("oiWavelength", -1)();
    id = where(map.pol==pol(p));
    oiWave(0).effWave     = &( 1./(median(sigEff0(,id),2))*1e-6 );
    oiWave(0).effBand     = &( lbdB*1e-6 );
    oiWave(0).hdr.insName = pndrsDefaultInsName(olog, pol(p));
  }

  /* If 2 polars, then also produce the combined oiWave */
  if ( numberof(pol)==2 ) {
    grow, oiWave, oiFitsGetOiStruct("oiWavelength", -1)();
    oiWave(0).effWave     = &( 1./(median(sigEff0,2))*1e-6 );
    oiWave(0).effBand     = &( lbdB*1e-6 );
    oiWave(0).hdr.insName = pndrsDefaultInsName(olog, pol(1)+pol(2));
  }

  /* If more than 2 polars... */
  if ( numberof(pol)>2 ) error,"Cannot deal with more than 2 polar.";

  
  /* if gui */
  if (gui && pndrsBatchPlotLevel) {
    winkill,gui+1; yocoNmCreate,gui+1,1,1,dx=0.06,fx=1,fy=1;
    yocoPlotPlgMulti,median(sigEff0,2),color="blue",width=5;
    yocoPlotPlpMulti,median(sigEff0,2),color="blue",symbol=4,fill=1;
    yocoPlotPlgMulti,sigEff, color="red",width=5,type=2;
    yocoPlotPlgMulti,sigEff0;
    limits; pause,10;
    main = swrite(format="%s - %.4f", olog.target, olog.mjdObs);
    pndrsPlotAddTitles,,main,"Spectral calibration table (red=expected, blue=computed, black=all baselines)",
      "spec. channel","freq. [!mm^-1^]";

    /* Add the computed value on the plot */
    window,gui;
    yocoPlotVertLine,1./lbd0(1),color="red",type=3,tosys=indgen(nbase),width=3;
    yocoPlotVertLine,1./lbd0(0),color="green",type=3,tosys=indgen(nbase),width=3;
    sta  = pndrsPlotGetBaseName(olog);
    main = swrite(format="%s - %.4f", olog.target, olog.mjdObs);
    pndrsPlotAddTitles,sta,main,"PSD of first and last channel","freq. [!mm^-1^]","Power";
    
    /* Add the computed value on the plot */
    window,gui+2;
    for (k=1;k<=nbase;k++) {
      yocoLogTrace,"add in plot";
      plsys,k;
      yocoPlotVertLine,median(sigEff0,2),color="blue",width=5;
      yocoPlotVertLine,sigEff0(,k),color="green",width=5;
    }
    sta  = pndrsPlotGetBaseName(olog);
    main = swrite(format="%s - %.4f", olog.target, olog.mjdObs);
    pndrsPlotAddTitles,sta,main,"PSD of each channel","freq. [!mm^-1^]","Power";
  }
  
  yocoLogTrace,"pndrsComputeOiWave done";
  return 1;
}

/* ******************************************************************* */

func pndrsComputeAirDisp(oLog,i,j,lbd)
/* DOCUMENT pndrsComputeAirDisp(oLog,i,j,lbd)

   DESCRIPTION
   Compute the dispersion from air in the VLDI DLs
   with zero-opd in the middle of the wavelength range.

   The total OPL of beams i and j is read from header
   by issConfAiL + 0.5*(issDliOplStart + issDliOplEnd)
   
   PARAMETERS
   - oLog: PIONIER oiLog.
   - i,j:  the PIONIER beams
   - lbd:  wavelength array

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogTrace,"pndrsComputeAirDisp()";
  local opli, oplj, opd, lbd;
  local P,T,F,n,phasor,bisp;
  P = 56.47 * 1.333224e+03;
  T = 273.16+12.;
  F = 0.24 * 1.333224e+03;
  
  /* Get the OPL of this baseline */
  opli =  pndrsGetLogInfo(oLog,"issConfA%iL",i) +
    0.5 * pndrsGetLogInfo(oLog,"issDl%iOplStart",i) +
    0.5 * pndrsGetLogInfo(oLog,"issDl%iOplEnd",i);
  oplj =  pndrsGetLogInfo(oLog,"issConfA%iL",j) +
    0.5 * pndrsGetLogInfo(oLog,"issDl%iOplStart",j) +
    0.5 * pndrsGetLogInfo(oLog,"issDl%iOplEnd",j);
  opd = oplj - opli;

  /* Get the lambda array */
  if (is_void(lbd)) pndrsGetDefaultWave, oLog, lbd;

  /* Compute the air index, with zero group-delay
     in the middle of the band */
  n = yocoAstroAirIndex(lbd, T, P)*1.e-8 + 1.;
  n = n - ( (n/lbd)(dif) / (1/lbd)(dif) )(avg);
  
  /* Get the phasor */
  phasor = exp(2.i *pi * opd(-,)/lbd * n);

  yocoLogTrace,"pndrsComputeAirDisp done";
  return phasor;
}

func pndrsRegress(y, x, sigy=, rcond=)
/* DOCUMENT pndrsRegress(y, x, sigy=, rcond=)

   'regress' function but without reduced chi2 computation.

   DESCRIPTION

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
   y = double(y(*));
   x = double(x(*,));
   dims = dimsof(x);
   n = numberof(y);
   if (dims(1)!=2 || dims(2)!=n) error, "bad x dimensions";
   if (is_void(sigy)) sigy = 1. + 0.*y;
   else sigy = 1./sigy;
   if (is_void(rcond)) rcond = 1.e-9;
   else rcond = min(max(rcond,1.e-13),0.5);
   x *= sigy;
   y *= sigy;
   local u;
   vals = SVdec(x, u, axes);
   u = y(+) * u(+,);
   mask = vals > rcond*vals(1);
   np = sum(mask);
   rvals = mask / (vals + !mask);
   if (np < numberof(mask)) vals(where(!mask)) *= -1.;
   u *= rvals;
   model = u(+) * axes(+,);
   return model;
}


func pndrsHackForThePoorBaseline(&coherData, &matrix, &imgData, imgLog, base=)
/* DOCUMENT pndrsHackForThePoorBaseline(&coherData, &matrix, &imgData, imgLog, base=)

   DESCRIPTION:
   this is a hack for the poor baseline.
   Replace the fringe by the AC mode. Deal with bias by
   putting the negative frequencies of ABCD, rescaled.
   Closure phase checked, apparently no issue.
   Efficiency can be improved a lot.
 */
{
  yocoLogInfo,"pndrsHackForThePoorBaseline()";

  local imgData0, matrix0;
  if (is_void(base)) base=4;

  /* Get the base to hack */
  map = pndrsGetMap(coherData, imgLog);
  idBase = where(map.base==base);

  /* Check base */
  if ( numberof(idBase)<1 ) {
    yocoLogInfo," base "+totxt(base)+" not in data.";
    return 1;
  }

  /* Extract data */
  pndrsGetData, coherData, imgLog, data, opd, map, oLog;
  pndrsSignalFourierTransform, data, opd, ft, freq;

  /* Get the frequencies to use for the hack */
  nstep = dimsof(data)(3);
  ff = abs(freq(,1,idBase))*1e-6;
  tmp = where( ff>1.2 & ff<(max(ff)-1.2) );

  /* Test if enough frequencies to do the hack */
  if ( numberof(tmp)<5 ) {
    yocoLogInfo,"Cannot do the hack, frequency range too small";
    return 1;
  }

  /* Copy data */
  imgData0 = imgData(*);
  matrix0 = matrix;

  /* Process these copies with AC-algo to get a higher SNR,
     but both positive and negative frequencies */
  pndrsFlatField, imgData0,  imgLog, matrix0, flatMatrix=1, checkFlat=0;
  pndrsComputeInputFlux, imgData0,  imgLog,  matrix0, flux0;
  pndrsRemoveContinuum, imgData0,  imgLog,  matrix0, flux0;
  pndrsComputeCoherentFlux, imgData0,  imgLog,  coherData0;

  /* Extract the reduced copied data */
  pndrsGetData, coherData0, imgLog, data0, opd0, map, oLog;
  pndrsSignalFourierTransform, data0, opd0, ft0, freq0;

  /* Replace the fringe power by the higher SNR version,
     for the idBase only.
     Keep the reciprocal frequencies (no fringe), but adjust
     their power to match the one of the data */
  bias = median( abs(ft0)(,tmp,avg,idBase),2 );
  ref  = median( abs(ft)(,tmp,avg,idBase),2 );
  ft( ,1:nstep/2,,idBase ) = ft0( ,1:nstep/2,,idBase );
  ft( ,nstep/2+1:,,idBase ) *= bias/ref;

  /* Put the data back */
  pndrsSignalFourierBack,ft, freq, data, opd;
  coherData.regdata = &data;

  yocoLogInfo, "pndrsHackForThePoorBaseline done";
  return 1;
}
  
