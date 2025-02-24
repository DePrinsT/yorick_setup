/*******************************************************************************
* PIONIER Data Reduction Software
*/

require,"textload.i";

func pndrsCalibrate(void)
/* DOCUMENT pndrsCalibrate

   FUNCTIONS:
   - pndrsSearchCalibrator
   - pndrsShowNight
   
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.12 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsCalibrate;
    }   
    return version;
}

func pndrsGetAllSetup(oiLog, oiVis2, oiT3)
{
  yocoLogTrace,"pndrsGetAllSetup()";
  local lstSetup;

  lstSetup = grow((is_array(oiVis2) ? oiFitsGetSetup(oiVis2, oiLog) : []) ,
                  (is_array(oiT3)   ? oiFitsGetSetup(oiT3,   oiLog) : []));

  if (is_void(lstSetup)) return [];
  return lstSetup( yocoListCleanId(lstSetup) );
}

func pndrsPlotTfForAllSetups(oiWave, oiTarget, oiArray, oiLog,
                             oiVis2, oiT3, oiVis,
                             oiVis2Cal, oiT3Cal, oiVisCal,
                             oiVis2Tfe, oiT3Tfe, oiVisTfe,
                             oiVis2Tfp, oiT3Tfp, oiVisTfp,
                             strRoot=, X=)
{
  yocoLogInfo,"pndrsPlotTfForAllSetups()";
  local lstSetup, o, i, bins, oWave, oVis2, oVis, oT3;
  local oWave, oVis2, oVis2Cal, oVis2Tfe, oVis2Tfp, oT3, oT3Cal, oT3Tfe, oT3Tfp;
  
  /* Loop on the setup to plot the TF per setup and per bins.
     This is the best to assess the data quality precisely. */
  lstSetup = pndrsGetAllSetup(oiLog, oiVis2, oiT3);

  for (o=1;o<=numberof(lstSetup);o++) {
    yocoLogInfo,"Plot TF for setup #"+pr1(o)+" over "+pr1(numberof(lstSetup)),lstSetup(o);

    /* Copy arrays and keep only this setup */
    oiFitsCopyArrays, oiWave, oWave,
      oiVis2, oVis2, oiVis2Cal, oVis2Cal, oiVis2Tfe, oVis2Tfe, oiVis2Tfp, oVis2Tfp,
      oiT3, oT3, oiT3Cal, oT3Cal, oiT3Tfe, oT3Tfe, oiT3Tfp, oT3Tfp;
    oiFitsKeepSetup, oiLog, oVis2, oT3, oVis2Cal, oVis2Tfe, oVis2Tfp,
      oT3Cal, oT3Tfe, oT3Tfp, setupList=lstSetup(o);

    /* Clean for this setup, we assume that only one oiWave will remain.
       (assume insName is contained in the setup string)  */
    oiFitsCleanUnused, , oWave, , oVis2, oVis, oT3;
    if (is_void(oWave)) {
      yocoLogInfo,"No obs in this setup.";
      continue;
    }
    if (is_void(oVis2)) {
      // FIXME: plot even if no V2
      yocoLogInfo,"No V2 obs in this setup.";
      continue;
    }

    /* Loop on bins for this oiWave */
    bins = oiFitsGetLambda(oWave(1));  
    for (i=1;i<=numberof(bins);i++) {
      yocoLogTrace," plot bin "+pr1(i)+" over "+pr1(numberof(bins));

      /* Plot the TF for this bin */
      Avg1 = [bins(i), bins(i)];
      oiFitsPlotCalibratedNight, oWave, oiArray, oiLog, oiTarget, oiDiam, 
        oVis2, oVis2Cal, oVis2Tfe, oVis2Tfp,
        oT3, oT3Cal, oT3Tfe, oT3Tfp, Avg=Avg1, win=1, plotBase=0,
        nameCal=1, X=X;
      
      /* Write the PDF */
      if ( is_array(strRoot) ) {
        pndrsSavePdf,1,strRoot+"_vis2_setup"+swrite(format="%02d",o)+"_bin"+swrite(format="%02d",i)+".pdf", autoRotation=0;
        pndrsSavePdf,3,strRoot+"_t3phi_setup"+swrite(format="%02d",o)+"_bin"+swrite(format="%02d",i)+".pdf", autoRotation=0;
      }
    }
  }

  yocoLogTrace,"pndrsPlotTfForAllSetups done.";
  return 1;
}

/* ************************************************************ */

func pndrsPlotTfForAllChannels(oiWave, oiTarget, oiArray, oiLog,
                             oiVis2, oiT3, oiVis,
                             oiVis2Cal, oiT3Cal, oiVisCal,
                             oiVis2Tfe, oiT3Tfe, oiVisTfe,
                             oiVis2Tfp, oiT3Tfp, oiVisTfp,
                             strRoot=, X=, strInfo=)
/* DOCUMENT pndrsPlotTfForAllChannels
   
   Make a summary plot of calibration for each wavelength bin independently,
   Assume data are all from the same setup...
   
   SEE ALSO:
 */
{
  yocoLogInfo,"pndrsPlotTfForAllChannels()";
  local lstSetup, o, i, bins, oWave, oVis2, oVis, oT3;
  local oWave, oVis2, oVis2Cal, oVis2Tfe, oVis2Tfp, oT3, oT3Cal, oT3Tfe, oT3Tfp;

  /* Loop on the setup to plot the TF per setup and per bins.
     This is the best to assess the data quality precisely. */
  lstSetup = pndrsGetAllSetup(oiLog, oiVis2, oiT3);
  
  if (numberof(lstSetup)<1) { yocoLogInfo,"No data."; return 0;}
  if (numberof(lstSetup)>1) { yocoLogInfo,"Cannot deal with multiple setup"; return 0;}

  /* Loop on bins for this oiWave */
  oWave = oiFitsGetOiWave(oiVis2(1),oiWave);
  bins = oiFitsGetLambda(oWave(1));

  /* Loop on bins */
  for (i=1;i<=numberof(bins);i++) {
    yocoLogTrace," plot bin "+pr1(i)+" over "+pr1(numberof(bins));

    /* Plot the TF for this bin */
    Avg1 = [bins(i), bins(i)];
    oiFitsPlotCalibratedNight, oWave, oiArray, oiLog, oiTarget, oiDiam, 
      oiVis2, oiVis2Cal, oiVis2Tfe, oiVis2Tfp,
      oiT3, oiT3Cal, oiT3Tfe, oiT3Tfp, Avg=Avg1, win=1, plotBase=0,
      nameCal=1, X=X;
    
    /* Write the PDF */
    if ( is_array(strRoot) ) {
      pndrsSavePdf,1,strRoot+"vis2_"+strInfo+"_bin"+swrite(format="%02d",i)+".pdf", autoRotation=0;
      pndrsSavePdf,3,strRoot+"t3phi_"+strInfo+"_bin"+swrite(format="%02d",i)+".pdf", autoRotation=0;
    }
  }

  yocoLogTrace,"pndrsPlotTfForAllChannels done.";
  return 1;
}


/* ************************************************************ */

func pndrsShowNight(&oiVis2, &oiT3, &oiWave, &oiLog, keepTime=, keepLbd=, symbol=, inputDir=)
{
  yocoLogInfo,"pndrsShowNight()";

  if (is_void(keepLbd))  keepLbd = [1.0,3.0];
  if (is_void(keepTime)) keepTime = [-1,348.0];

  if ( !pndrsCheckDirectory(inputDir,2) ) {
    yocoError,"Check argument of pndrsShowNight";
    return 0;
  }

  /* Loop on all OBS_OBS_*fits files */
  cd,inputDir;
  files = oiFitsListFiles("PION*_oidata.fits");

  /* Load them */
  oiFitsLoadFiles, files, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog, readMode=;
  
  /* Prepare the plot */
  mjdRef  = int(min(min(oiVis2.mjd),min(oiT3.mjd)));
  dateRef = oiVis2(1).hdr.dateObs;

  /* Define the colors */
  color = int(span(2,200,numberof(oiTarget)+1));

  /* Make the selections */
  oiFitsKeepTime, oiVis2, ,oiT3, tlimit=mjdRef+keepTime/24.;

  /* Plot oiVis2, averaged over all lambda */
  yocoNmCreate,1,2,3,dy=0.0, dx=0.0;
  yocoNmXytitles,"Time (h)","Vis2";
  yocoNmMainTitle,dateRef+" "+pr1(lbd);

  oiFitsPlotOiData, oiVis2, oiWave, "mjd", Avg=keepLbd,
    tosys=oiFitsGetBaseId(oiVis2,,oiArray,name),X0=mjdRef,
    size=0.5,fill=1,Xm=24,color=color(oiVis2.targetId),
    symbol=symbol;
  for(i=1;i<=numberof(name);i++){plsys,i; pltitle,name(i);}
  yocoNmRange,0,2;
  
  /* Plot oiT3, averaged over all lambda */
  yocoNmCreate,2,2,2,dy=0.0, dx=0;
  yocoNmXytitles,"Time (h)","T3Phi (deg)";
  yocoNmMainTitle,dateRef+" "+pr1(lbd);
  oiFitsPlotOiData, oiT3, oiWave, "mjd",
    Avg=keepLbd,tosys=oiFitsGetBaseId(oiT3,,oiArray,name),X0=mjdRef,
    size=0.5,fill=1,Xm=24,color=color(oiT3.targetId),symbol=symbol;
  for(i=1;i<=numberof(name);i++){plsys,i; pltitle,name(i);}
  limits; yocoNmRange,-180,+180;

  yocoLogInfo,"pndrsShowNight done";
  return 1;
}

/* ------------------------------------------------------------------------ */

func pndrsSearchCalibrator(raEp0, decEp0, Hmag, Vmag=, Dmax=, size=, catalogs=, catalogsDir=)
/* DOCUMENT pndrsSearchCalibrator(raEp0, decEp0, Hmag, Vmag=, Dmax=, size=,
            catalogs=, catalogsDir=)

   DESCRIPTION
   Search for possible calibration star in the Borde, Merand, JSDC catalogs
   (installed locally).
   
   PARAMETERS
   - raEp0, decEp0: coordinates as string (Simbad like)
   - Hmag: H magnitude, or interval [min,max].
   - Vmax= V magnitude, or interval [min, max].
   - Dmax= maximum diameter size in mas.
   - size= maximum distance to search for.
   - catalogs="B","M","J", "BM", "JM"... select the catalogs,
     default is all ("BMJ").

   EXAMPLES
   > pndrsSearchCalibrator, "22 57 39.0465", "-29 37 20.050", 3.0, Dmax=3.0;
   > pndrsSearchCalibrator, "11 01 51.9063", "-34 42 17.021", [5.55,9.55];

   SEE ALSO:
 */
{
    yocoLogInfo,"pndrsSearchCalibratorFromCatalogs()"; 
    local racat, decat, diamcat, errcat, data, titles;
    local diam, diamerr, ra, dec, message, tab, tit;

    /* Default for catalogs location */
    if ( is_void(catalogsDir) ) catalogsDir=get_env("INTROOT")+"/catalogs";
    if ( is_void(overwrite) ) overwrite=0;
    if ( is_void(size) ) size = 20.0;
    if ( is_void(Vmag) ) Vmag = [0,11.0];
    if ( is_void(Dmax) ) Dmax = 7.0;
    if ( is_void(catalogs) ) catalogs="BMJ";
    

    /* Some verbose */
    yocoLogInfo,"-------------------------";
    yocoLogInfo,raEp0+" "+decEp0+"  Hmag="+pr1(Hmag);

    /* Some other default */
    if ( numberof(Hmag)==1 ) Hmag = [Hmag-2,Hmag+.5];
    if ( numberof(Vmag)==1 ) Vmag = [Vmag-2,Vmag+2];

    /* Prepare an array for the catalog id */
    catname  = ["J_AA_433_1155","J_AA_393_183","jsdc_2015-04-30.fits","II_300_jsdc"];
    dname = [["UDdiamH","e_UDdiam","SpType","HD"],["UDDH","e_UDDH","SpType","HD"],["UDDH","e_LDD","SpType","Name"]];
    
    catfiles = catalogsDir + "/" + catname + ".fits";
    catid   = ["M","B","J"];
   
    /* Read the catalogs */
    dcat = errcat = racat = decat = idcat = Hcat = Vcat = namecat = Spcat = [] ;
    for (i=1;i<=3;i++) {
      if (!strmatch(catalogs,catid(i))) continue;
      fh = cfitsio_open(catfiles(i));
      cfitsio_goto_hdu,fh,2;
      /* Load coordinates and magnitude */
      grow, racat, yocoStrTime(  cfitsio_read_column(fh,"RAJ2000") ) / 12. * 180;
      grow, decat, yocoStrAngle( cfitsio_read_column(fh,"DEJ2000") );
      grow, Hcat,  double( cfitsio_read_column(fh,"Hmag") );
      grow, Vcat,  double( cfitsio_read_column(fh,"Vmag") );
      grow, dcat,   cfitsio_read_column(fh,dname(1,i));
      grow, errcat, cfitsio_read_column(fh,dname(2,i));
      grow, Spcat, strpart(strtrim(cfitsio_read_column(fh,dname(3,i)),3),1:8);
      tmp = cfitsio_read_column(fh,dname(4,i));
      grow, namecat, ( structof(tmp)==string ? tmp : dname(4,i)+swrite(format="  %i",tmp) );
      grow, idcat, array(catid(i),dimsof(tmp));
      /* close file */
      cfitsio_close,fh;
    }
         
    /* Look for the stars by matching the coordinates (deg) */
    ra  = yocoStrTime(raEp0) / 12 * 180;
    dec = yocoStrAngle(decEp0);
    dist = abs(ra-racat, abs(dec-decat) );
    ids = id = where( dist>1/60.0 & dist < size & dcat > 0.0 &
                      Hcat>Hmag(1) & Hcat<Hmag(2) &
                      Vcat>Vmag(1) & Vcat<Vmag(2) &
                      dcat<Dmax );
    
    /* If no calibrator found */
    if ( numberof(ids)<1 ) {
      yocoLogWarning,"No calibrator found";
      return 1;
    }

    /* Sort and keep closest */
    ids = ids( sort(dist(ids)) );
    if (numberof(ids)>15) {
      yocoLogWarning,"Keep only the 15th closest candidates";
      ids = ids(1:15);
    }

    /* Write output */
    write,"Dist\tUD_H\t(err)\tHmag\tVmag\tSptype     Cat\tName";
    write,format=" %.1f\t%.2f\t%.2f\t%.1f\t%.1f\t%-11s%-2s\t%s\n",dist(ids),dcat(ids),errcat(ids),Hcat(ids),Vcat(ids),Spcat(ids),idcat(ids),namecat(ids);

    yocoLogTrace,"pndrsSearchCalibratorFromCatalogs done";
    return 1;
}

func pndrsScriptTestLoadFiles(rk)
{
  /* For test purpose (load the file manually to
     by-pass the full pndrsCalibrate procedure):
     
     include,"pndrs.i",1;
     pndrsScriptTestLoadFiles;
  */

  extern oiVis2, oiVis, oiT3, oiTarget, oiWave, oiArray, oiLog, oiDiam;

  files = oiFitsListFiles("PION*oidata.fits")(rk);
  oiFitsLoadFiles,files, oiTarget, oiWave, oiArray,
    oiVis2, oiVis, oiT3, oiLog, shell=1, readMode=-1;
  
  oiTarget.target = pndrsCheckTargetInList(oiTarget.target);
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
  
  oiFitsCleanDataFromDummy, oiVis2, oiT3, oiVis;
  
  oiFitsLoadOiDiam, oiFitsListFiles("*oiDiam.fits")(1), oiDiam, oiTarget;
}

func pndrsCorrectEffectiveWavelength(&oiVis2, oiWave, oiArray, oiLog, inputFile=, gui=)
/* DOCUMENT pndrsCorrectEffectiveWavelength(&oiVis2, oiWave, oiArray, oiLog, inputFile=)

   DESCRIPTION

   Load the file containing the TF slopes and apply the corresponding correction
   in the oiVis2.

   PARAMETERS

   EXAMPLES
   > pndrsCorrectEffectiveWavelength, oiVis2, oiWave, oiArray, oiLog;

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsCorrectEffectiveWavelength()";
  require,"textload.i";

  /* File with the slopes */
  if ( is_void(inputFile) )
    inputFile = "/data/pionier/Exozodi/tf_slopes.txt";

  /* Read file [3 x V2 + 3 x eV2, bases, dates] */
  lines = text_lines(inputFile)(2:);
  lines = strpart(lines,strword(lines,"\t",44));
  dates = lines(1,);
  lines = (reform(lines(2:-1,),[3,7,6,numberof(dates)]));
  bases = lines(1,,);
  data  = tonum(lines(2:,,));

  if(gui) {
    winkill,gui;
    yocoNmCreate,gui,2,3,dx=0.01,dy=0.01;
  }
  
  /* Some arrays */
  lm = span(1.45,1.9,100);
  bid = oiFitsGetBaseId( oiVis2(i), oiVis2 );
  
  /* Loop on data */
  for (i=1;i<=numberof(oiVis2);i++) {
    write,format="%i\r",i;
    
    /* Extract spectra and wave table */
    include,["n2="+oiFitsGetOiLog(oiVis2(i),oiLog).n2arr+";"],1;
    f0 = sqrt(n2);
    l0 = *oiFitsGetOiWave(oiVis2(i),oiWave).effWave * 1e6;
    w0 = *oiFitsGetOiWave(oiVis2(i),oiWave).effBand * 1e6;
  
    /* Fit spectra and get effective lbds */
    m  = pndrsRegress(f0,[1,l0,l0^2]) ;
    fm = max(m(+)*[1,lm,lm^2](,+),0);
    mask = ( lm>(l0-w0/2)(-,) & lm<(l0+w0/2)(-,));
    leff = (fm*lm*mask)(sum,) / (fm*mask)(sum,);
  
    /* Found slopes in array */
    dd = strpart( yocoAstroJulianDayToESOStamp(oiVis2(i).mjd-0.42,modified=1), 1:10);
    bb = oiFitsGetBaseName(oiVis2(i),oiArray);
    slope = data(,where(bb==bases)(1),where(dd==dates)(1));
  
    /* Correct V2 -- correction slopes are relatives */
    oiFitsGetData, oiVis2(i), v2, ev2, , ,flag;
    v2  *= 1. - slope([1,3,5]) * (leff - l0);
    ev2  = abs( ev2, v2*slope([2,4,6])*(leff - l0) );
    oiFitsSetData,oiVis2, i, v2, ev2, , ,flag;

    if (gui) {
      plsys, bid(i); 
      yocoPlotPlp, f0, l0;
      plg,fm,lm;
      yocoPlotVertLine,leff,color="green";
    }
  }

  /* Finalize plots */
  if (gui) {
    range,0;
    yocoPlotVertLine,l0-w0/2,color="red";
    yocoPlotVertLine,l0+w0/2,color="red";
  }
  
  yocoLogTrace,"pndrsCorrectEffectiveWavelength done";
  return 1;
}

func pndrsUpdateOiDiamFromOBsName(&oiDiam, oiTarget, oiData, oiLog)
/* DOCUMENT pndrsUpdateOiDiamFromOBsName(&oiDiam, oiTarget, oiData, oiLog)

   DESCRIPTION
   Update the oiDiam.isCal parameters based on the ASPRO convention
   of ESO OB name. CAL_* -> CAL and SCI_* -> SCI.

   Also update the oiDiam.isCal parameters based on the DPR.CATG
   from ESO.
 */
{
  yocoLogInfo,"pndrsUpdateOiDiamFromOBsName()";

  for (i=1;i<=numberof(oiDiam);i++) {

    /* Target name */
    name = oiFitsGetTargetName(oiDiam(i), oiTarget);

    /* Find the first observation of the target (suppose all of them are identical) */
    id = where(oiData.targetId == oiDiam(i).targetId);
    if (!is_array(id)) continue;

    /* Find the OBs name */
    oLog = oiFitsGetOiLog(oiData(id(1)), oiLog);
    obs  = strpart(oLog.obsName,1:4);
    catg = oLog.proCatg;
    
    /* Change the SCI/CAL */
    if ( catg=="CALIB_OIDATA_RAW" && oiDiam(i).diam>0.0 ) {
      oiDiam(i).isCal = 1;
      yocoLogInfo,"Force "+name+" to CAL (PRO.CATG=='CALIB_OIDATA_RAW')";
    }
    else if (catg=="TARGET_OIDATA_RAW") {
      oiDiam(i).isCal = 0;
      yocoLogInfo,"Force "+name+" to SCI (PRO.CATG=='TARGET_OIDATA_RAW')";
    }
    else if ( obs=="CAL_" && oiDiam(i).diam>0.0 ) {
      oiDiam(i).isCal = 1;
      yocoLogInfo,"Force "+name+" to CAL (OB name start with 'CAL_')";
    }
    else if (obs=="SCI_") {
      oiDiam(i).isCal = 0;
      yocoLogInfo,"Force "+name+" to SCI (OB name start with 'SCI_')";
    }
    else {
      yocoLogInfo,"Let "+name+" be "+(oiDiam(i).isCal ? "CAL" : "SCI");
    }
    
  }

  yocoLogTrace,"pndrsUpdateOiDiamFromOBsName done";
  return 1;
}


func pndrsUpdateOiDiamFromGetStar(&oiDiam,oiTarget)
/* DOCUMENT pndrsUpdateOiDiamFromGetStar(&oiDiam,oiTarget)

   DESCRIPTION
   Try to fill the missing diameters in oiDiam by query
   to the JMMC getstar service.
*/
{
  yocoLogInfo,"pndrsUpdateOiDiamFromGetStar()";
  
  local diamH, ediamH;

  /* Loop on star */
  for (i=1;i<=numberof(oiDiam);i++) {
    name = oiFitsGetTargetName(oiDiam(i), oiTarget);

    /* If already a diameter, then skip */
    if ( oiDiam(i).diam>0 ) continue;

    /* If INTERNAL, then skip */
    if ( name == "INTERNAL" ) continue;

    /* If getstar failed, then skip */
    pndrsGetstarFromJMMC, name, diamH, ediamH;
    if (diamH==0.0) continue;

    /* Update the diameter */
    oiDiam(i).diam    = diamH;
    oiDiam(i).diamErr = max(ediamH,0.1);
    oiDiam(i).info = "JMMC_getstar";
    yocoLogInfo," Find diameter for "+name+": "+pr1(diamH)+"mas";
  }

  yocoLogTrace,"pndrsUpdateOiDiamFromGetStar done";
  return 1;
}


func pndrsGetstarFromJMMC (name,&diamH,&ediamH)
/* DOCUMENT pndrsGetstarFromJMMC(name,&diamH,&ediamH)
 */
{
  yocoLogInfo,"pndrsGetstarFromJMMC()";
  diamH = ediamH = 0.0;

  /* test if wget and xsltproc exists */
  if ( !rdline( popen("which wget",0) ) ) {
    yocoLogInfo," Cannot find wget";
    return 0;
  }
  
  allnames = name;
  if (numberof(allnames)>1) allnames = strpart((allnames+",")(sum),1:-1);

  /* Unique filename */
  file = "output_getstar_"+pr1(int((pndrsBatchTime()%1)*24*36001000));
  
  /* Query get star */
  system,"wget \"http://jmmc.fr/~sclws/getstar/sclwsGetStarProxy.php?star="+allnames+"&format=tsv\" -O ~/"+file+".tsv -o ~/"+file+".log";
  
  data = text_cells("~/"+file+".tsv", "\t");

  if (is_void(data)) {
    yocoLogInfo," Cannot find diameter for "+allnames;
    yocoLogInfo,"pndrsGetstarFromJMMC done";
    yocoLogTrace,"Clean up tmp files";
    remove,"~/"+file+".tsv";
    remove,"~/"+file+".log";
    return 0;
  }

  /* Clean tmp files */
  yocoLogTrace,"Clean up tmp files";
  remove,"~/"+file+".tsv";
  remove,"~/"+file+".log";
  yocoLogTrace,"Clean up tmp files done";

  /* Remove comments */
  yocoLogTrace,"Remove comments";
  data = data(,where(!strmatch(data(1,),"#")));
  title = data(,1);
  data  = data(,2:);

  /* Search the column for uncertainties */
  if (is_array(where( title == "e_diam_mean" ))) {
      yocoLogInfo,"Use e_diam_mean for uncertainty";
      ediamH = tonum(data(where( title == "e_diam_mean" )(1), ),nan=0.0);
  } else if (is_array(where( title == "e_diam_weighted_mean" ))) {
      yocoLogInfo,"Use e_diam_weighted_mean for uncertainty";
      ediamH = tonum(data(where( title == "e_diam_weighted_mean" )(1), ),nan=0.0);
  } else if (is_array(where( title == "e_LDD" ))) {
      yocoLogInfo,"Use e_LDD for uncertainty";
      ediamH = tonum(data(where( title == "e_LDD" )(1), ),nan=0.0);
  }
  else {
      yocoLogInfo,"Cannot find uncertainty, force 0.5mas";
      ediamH = 0.5;
  }

  yocoLogTrace,"Set H-band";
  diamH  = tonum(data(where( title == "UD_H" )(1), ),nan=0.0);

  if (dimsof(name)(1)==0) { diamH=diamH(1); ediamH=ediamH(1); }

  yocoLogInfo,"pndrsGetstarFromJMMC done";
  return 1;
}

func pndrsComputeInternalPhases(&phases, &phasesErr, &dataC, inputScienceFile=, gui=)
/* DOCUMENT pndrsComputeInternalPhases(&phases, &phasesErr, inputScienceFile=)

   DESCRIPTION
   Measure the relative phases A-B, A-C, A-D
   Need the photometric fluctuations to be well
   separated from the fringe power
*/
{

  /* Check the input files */
  if ( !pndrsCheckFile(inputScienceFile,2,[1],"inputScienceFile") ) {
    return 0;
  }

  /* Process RAW file */
  if( !pndrsReadRawFiles(inputScienceFile, imgData, imgLog) ) return 0;
  if( !pndrsCheckOiLog(imgLog) ) return 0;
  if( !pndrsProcessDetector(imgData, imgLog) ) return 0;
  if( !pndrsReformData(imgData, imgLog) ) return 0;
  if( !pndrsProcessOversampling(imgData, imgLog) ) return 0;

  /* Get data */
  pndrsGetData, imgData, imgLog, data, opd, map, olog;
  nlbd  = dimsof(data)(2);
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nwin  = dimsof(data)(5);
  nbase = max(map.base);
  ntel  = max(max(map.t1),max(map.t2));

  /* Fourier Transform */
  pndrsSignalFourierTransform, data, opd, ft, freq;

  /* Filter around fringe frequency (assume H-band) */
  ff = abs(freq(,1,)) / 1e6;
  ftf = ft * (ff>0.5 & ff<0.7)(-,,-,);
  dataf = fft(ftf,[0,-1,0,0]);
  
  // winkill; fma;
  // yocoPlotPlgMulti, abs(ft(avg,))(,avg,), ff;
  // yocoPlotPlgMulti, abs(ftf(avg,))(,avg,), ff, color="red";
  // dimsof(dataf);

  /* Prepare outputs */
  phases    = array(0.0, 6, 24);
  phasesErr = array(0.0, 6, 24);
  
  /* Loop on base */
  for (i=1;i<=max(map.base);i++) {

    id = where(map.base == i);
    datat = dataf(..,id);

    phasor = datat(..,1) * conj(datat);
    phasor = phasor(,avg,,);

    pndrsSignalComputePhase, phasor,
      phase, phaseErr, gui=0;

    phases(,id) = phase;
    phasesErr(,id) = phaseErr;
  }

  /* In unit of pi */
  tmp = (( phases / 180 + 4) % 2);
  yocoLogInfo,"Measured phases in unit of pi:";
  write,format="%.2f  %.2f\n", tmp(2,), tmp(5,);

  /* In radians */
  phases    = phases / 180 * pi;
  phasesErr = phasesErr / 180 * pi;

  /* Correct */
  dataC = complex(dataf) * exp( 1.i * (phases +2.*pi))(,-,-,);

  /* Plot */
  if (gui && pndrsBatchPlotLevel) {
    sta  = pndrsPlotGetBaseName(imgLog(0));
    main = swrite(format="%s - %.4f", imgLog(0).target, (*imgData.time)(*)(avg));
    
    winkill, gui;
    yocoNmCreate,gui,2,nbase/2,dx=0.05,dy=0.05;
    yocoPlotPlgMulti,dataC(avg,,10,).re,color=,type=1,tosys=map.base;
    yocoPlotPlgMulti,dataC(avg,,10,).im,color=,type=2,tosys=map.base;
  }

  return 1;
}

/* ************************************************************ */

func pndrsCopyDataForSci(targets=,inputDir=, outputDir=)
/* DOCUMENT pndrsCopyDataForSci(targets=,inputDir=, outputDir=)

   Caopy reduced data for given science, as well as all calibration
   star of the night. To perform dedicated calibration.
   
   Add progId filtering and so on.
   Add loop on dates.
*/
{
  yocoLogInfo, "pndrsCopyDataForSci()";

  /* Default */
  if (is_void(inputDir)) inputDir="./";
  if (is_void(outputDir)) outputDir="targetExtracted/";

  if ( !pndrsReadLog(inputDir, oiLogDir, overwrite=overwrite) ) {
    yocoError,"Cannot read the logFile.";
    return 0;
  }

  /* Get RAW science data on these targets */
  targetDir = pndrsCheckTargetInList(oiLogDir.target);
 
  id = where( strmatch( oiLogDir.fileName, "oidata.fits") *
              (targetDir != "INTERNAL") *
              (yocoListId(targetDir, targets) |
               oiLogDir.dprCatg=="CALIB" ) );
  oiLogCp = oiLogDir(id);

  /* Test id */
  if ( numberof(oiLogCp) ==0 ) {
    yocoLogInfo,"No match, stop";
    return 1;
  }

  /* Build output dir */
  mkdirp, outputDir;

  /* Copy files */
  yocoLogInfo,"Copy "+pr1(numberof(oiLogCp))+ " files into "+outputDir;
  for (i=1;i<=numberof(oiLogCp);i++) {
    system, "cp -rf "+inputDir+"/"+oiLogCp.fileName(i)+" "+outputDir; 
  }

  yocoLogTrace, "pndrsCopyDataForSci done";
  return 1;
}

/* ************************************************************ */

func pndrsCopyDataForSciForNights(inputDir=, nights=, outputDir=, targets=)
{
  yocoLogInfo,"pndrsCopyDataForSciForNights()";

  if (is_void(inputDir))  inputDir="./";
  if (is_void(outputDir)) outputDir="extracted/";
  if (is_void(nights)) error;

  for (i=1;i<=numberof(nights);i++) {
    yocoLogInfo,"Night: "+nights(i);

    /* Found reduction */
    dirs = oiFitsListFiles("-d "+inputDir+"/"+nights(i)+"* | grep _v | grep -v -e calib -e vt");
    if (numberof(dirs)>1) { yocoLogWarning,"Too many dirs:",dirs; continue;}
    if (numberof(dirs)<1) { yocoLogWarning,"No reduction."; continue;}

    /* Verbose */
    dirs = yocoStrrtok( dirs(1), "/")(2);
    yocoLogInfo,"Found directory: "+dirs;

    /* Copy data and calibration stars */
    pndrsCopyDataForSci, targets=targets, inputDir=inputDir+"/"+dirs, outputDir=outputDir+"/"+dirs;

    /* Copy scripts and oiDiam */
    system,"cp "+inputDir+"/"+dirs+"/*.i "+outputDir+"/"+dirs;
    system,"cp "+inputDir+"/"+dirs+"/*oiDiam.fits "+outputDir+"/"+dirs;
  }
  

  yocoLogInfo,"pndrsCopyDataForSciForNights done";
  return 1;
}

/* ************************************************************ */

func pndrsComputeSingleTf (void, inputOiDataFiles=, inputCatalogFile=,
                           outputOiDataTfFile=, averageFiles=)
{
  yocoLogInfo,"pndrsComputeSingleTf()";

  /* Check the input files */
  if ( !pndrsCheckFile(inputOiDataFiles,2,indgen(20),"inputOiDataFiles") ||
       !pndrsCheckFile(inputCatalogFile,2,[1],"inputCatalogFile")) {
    return 0;
  }

  /* Load all the OIDATA files. Note: do not load the oiVis
     because this quantity is not understood so far */
  oiFitsLoadFiles,inputOiDataFiles, oiTarget, oiWave, oiArray,
    oiVis2, , oiT3, oiLog, shell=1, readMode=-1;

  /* Search for the diameters in catalogs. Note that only stars not
     already in oiDiam will be updated. */
  oiFitsLoadOiDiamFromCatalogs, oiTarget, oiDiam, overwrite=0,
    catalogFile=inputCatalogFile;

  /* If cannot find diameter */
  if ( !is_array(oiDiam) ) return 1;

  /* Set all target as calibration star */
  oiDiam.isCal = 1;
  
  /*  Add these information in QC parameters */
  pndrsCleanQC, oiLog;
  oiLog.qcDbDiam    = oiDiam(1).diam;
  oiLog.qcDbDiamErr = oiDiam(1).diamErr;
  oiLog.qcDbHmag    = oiDiam(1).Hmag;

  /* Average files if needed -- would prefer to not do that */
  if (averageFiles) {
    oiFitsGroupAllOiData, oiVis2, oiVis, oiT3, oiLog, dtime=10./24./60.;
  }

  /* Compute the TF */
  if (is_array(oiT3)) oiFitsExtractTf, oiT3, oiWave, oiDiam, oiT3Tfp;
  if (is_array(oiVis2)) oiFitsExtractTf, oiVis2, oiWave, oiDiam, oiVis2Tfp;

  /* Add these information in QC parameters */
  for (i=1;i<=numberof(oiVis2Tfp);i++) {
      iss = pndrsStationToIss (oiLog, oiFitsGetStationName (oiVis2Tfp(i), oiArray));
      iss = totxt(iss(sort(iss)))(sum);
      pndrsSetLogInfo, oiLog, "qcTfVis%sAvg", iss, average(*oiVis2Tfp(i).vis2Data,1);
  }
  
  /* Clean (this will also modify all internal cross-referencing) */
  oiFitsClean, oiTarget, oiWave, oiArray, oiVis2, oiVis, oiT3, oiLog;
  oiFitsCleanUnused,oiTarget,oiWave,oiArray,oiVis2,oiVis,oiT3,oiLog;

  /* Set the PRO.CATG for ESO */
  oiLog.proCatg = "OIDATA_TF";

  /* Write file, this will dump the header keywords from
     the input science file (oiLog.fileName) */
  oiFitsWriteFile, outputOiDataTfFile, oiTarget, oiWave, oiArray,
    oiVis2Tfp, , oiT3Tfp, oiLog, overwrite=1, funcLog=pndrsWritePnrLog;

  /* Change permission of all these newly created files */
  system,"chmod ug+w  "+outputOiDataTfFile+" > /dev/null 2>&1";

  yocoLogInfo,"pndrsComputeSingleTf done";
  return 1;
}

/* ************************************************************ */

func pndrsCleanQC (oiLog)
{
  yocoLogInfo,"pndrsCleanQC()";

  /* Load members */
  oiFitsStrReadMembers, oiLog, name, type;
  type = type(where(strpart(name,1:2) == "qc"));
  name = name(where(strpart(name,1:2) == "qc"));

  for (i=1; i<=numberof(name); i++) {
      if (type(i) == "string")
          get_member (oiLog, name(i)) = string (0);
      else
          get_member (oiLog, name(i)) = 0.0;
  }
  
  yocoLogInfo,"pndrsCleanQC done";
}


func pndrsCalibrateSingleOiData (void, inputOiDataFiles=,
                                 inputOiDataTfFiles=,
                                 outputOiDataCalibratedFile=,
                                 outputOiDataTfeFile=,
                                 averageFiles=)
{
  yocoLogInfo,"pndrsCalibrateSingleOiData()";

  /* Check the input files */
  if ( !pndrsCheckFile(inputOiDataFiles,2,indgen(20),"inputOiDataFiles") ||
       !pndrsCheckFile(inputOiDataTfFiles,2,indgen(50),"inputOiDataTfFiles")) {
    return 0;
  }

  /* Load all the OIDATA files. Note: do not load the oiVis
   * because this quantity is not understood so far. It is mandatory
   * to load all together to obtain correct oiLog... */
  oiFitsLoadFiles,inputOiDataFiles, oiTarget, oiWave, oiArray,
    oiVis2, , oiT3, oiLog, shell=1, readMode=-1;

  oiFitsLoadFiles,inputOiDataTfFiles, oiTarget, oiWave, oiArray,
    oiVis2, , oiT3, oiLog, shell=1, readMode=-1, append=1;

  /* Average files if needed */
  if (averageFiles) {
    oiFitsGroupAllOiData, oiVis2, oiVis, oiT3, oiLog, dtime=10./24./60.;
  }
  
  /* Some cleaning */
  maxVis2Err  = 0.25; maxT3PhiErr = 20.0;
  
  oiFitsCleanDataFromDummy, oiVis2, oiT3, , maxVis2Err=maxVis2Err,
      maxT3PhiErr=maxT3PhiErr, minBaseLength=-1;
  
  /* Recovers calibration files */
  oiVis2Tfp = oiVis2 (where(yocoListId(oiFitsGetOiLog(oiVis2,oiLog).fileName, inputOiDataTfFiles)));
  oiT3Tfp   = oiT3 (where(yocoListId(oiFitsGetOiLog(oiT3,oiLog).fileName, inputOiDataTfFiles)));
  
  /* Recovers science files */
  oiVis2 = oiVis2 (where(yocoListId(oiFitsGetOiLog(oiVis2,oiLog).fileName, inputOiDataFiles)));
  oiT3   = oiT3 (where(yocoListId(oiFitsGetOiLog(oiT3,oiLog).fileName, inputOiDataFiles)));
  
  /* Default */
  vis2TfMode  = 1;
  t3TfMode    = 1;

  /* Init and reset outputs */
  oiT3Cal = oiT3Tfe = oiVis2Cal = oiVis2Tfe = [];

  if (is_array(oiT3)) {
    oiFitsApplyTf, oiT3, oiT3Tfp, oiArray, oiLog, oiT3Cal, oiT3Tfe, oiTarget,
      tfMode=t3TfMode, errMode=t3TfErrMode, param=t3TfParam, onTime=1;
  }

  if (is_array(oiVis2)) {
    oiFitsApplyTf, oiVis2, oiVis2Tfp, oiArray, oiLog, oiVis2Cal, oiVis2Tfe, oiTarget,
      tfMode=vis2TfMode, errMode=vis2TfErrMode, param=vis2TfParam, onTime=1;
  }

  /* Clean data from dummies. */
  oiFitsCleanDataFromDummy, oVis2Cal, oT3Cal, ,
      maxVis2Err=maxVis2Err, maxT3PhiErr=maxT3PhiErr;

  /* Write calibrated files, this will dump the header keywords from
     the first input science file (oiLog.fileName) */
  oiLogCal = oiFitsGetOiLog (oiVis2Cal, oiLog)(1);
  oiLogCal.proCatg = "TARGET_OIDATA_CALIBRATED";
  pndrsCleanQC, oiLogCal;

  /*  Add QC parameters about TF interpolation */
  for (i=1;i<=numberof(oiVis2Cal);i++) {
      iss = pndrsStationToIss (oiLogCal, oiFitsGetStationName (oiVis2Cal(i), oiArray));
      iss = totxt(iss(sort(iss)))(sum);
      pndrsSetLogInfo, oiLogCal, "qcTfVis%sAvg", iss, average(*oiVis2Tfe(i).vis2Data,1);
      pndrsSetLogInfo, oiLogCal, "qcTfVis%sErr", iss, average(*oiVis2Tfe(i).vis2Err,1);
  }

  /*  Add QC parameters about data */
  for (i=1;i<=numberof(oiVis2Cal);i++) {
      iss = pndrsStationToIss (oiLogCal, oiFitsGetStationName (oiVis2Cal(i), oiArray));
      iss = totxt(iss(sort(iss)))(sum);
      pndrsSetLogInfo, oiLogCal, "qcVis%sAvg", iss, average(*oiVis2Cal(i).vis2Data,1);
      pndrsSetLogInfo, oiLogCal, "qcVis%sErr", iss, average(*oiVis2Cal(i).vis2Err,1);
  }
  
  oiFitsWriteFile, outputOiDataCalibratedFile, oiTarget, oiWave, oiArray,
      oiVis2Cal, , oiT3Cal, oiLogCal,
      overwrite=1, funcLog=pndrsWritePnrLog;

  arcFile = yocoListClean (oiFitsGetOiLog (oiVis2, oiLog).arcFile);
  pndrsUpdateFileWithPhase3, outputOiDataCalibratedFile, arcFile;
  
  /* Write tf estimate files, this will dump the header
     keywords from first input TF file */
  oiLogTfe = oiFitsGetOiLog (oiVis2Tfe, oiLog)(1);
  oiLogTfe.proCatg = "OIDATA_TF_ESTIMATE";
  pndrsCleanQC, oiLogTfe;

  /*  Add QC parameters about TF interpolation */
  for (i=1;i<=numberof(oiVis2Tfe);i++) {
      iss = pndrsStationToIss (oiLogTfe, oiFitsGetStationName (oiVis2Tfe(i), oiArray));
      iss = totxt(iss(sort(iss)))(sum);
      pndrsSetLogInfo, oiLogTfe, "qcTfVis%sAvg", iss, average(*oiVis2Tfe(i).vis2Data,1);
      pndrsSetLogInfo, oiLogTfe, "qcTfVis%sErr", iss, average(*oiVis2Tfe(i).vis2Err,1);
  }
  
  oiFitsWriteFile, outputOiDataTfeFile, oiTarget, oiWave, oiArray,
      oiVis2Tfe, , oiT3Tfe, oiLogTfe,
      overwrite=1, funcLog=pndrsWritePnrLog;
  
  /* Change permission of all these newly created files */
  system,"chmod ug+w  "+outputOiDataTfeFile+" > /dev/null 2>&1";
  system,"chmod ug+w  "+outputOiDataCalibratedFile+" > /dev/null 2>&1";
  
  yocoLogTrace,"pndrsCalibrateSingleOiData done";
  return 1;
}
