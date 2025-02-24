/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsArchive(void)
/* DOCUMENT pndrsArchive(void)

   FUNCTIONS:
   - pndrsArchiveGetFilesFromSaf
   - pndrsArchiveGetSaf
   - pndrsArchiveCleanSafFromExisting
   - pndrsArchiveGetDownloadScript
   - pndrsArchiveLoadDownloadScript
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.67 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsArchive;
        
    }   
    return version;
}

/* ************************************************************ */

func pndrsArchiveCheckNightContent(inputDirs)
{
  for (i=1;i<=numberof(inputDirs);i++) {
    yocoLogInfo,"Check dir: "+inputDirs(i);
    
    files = oiFitsListFiles(inputDirs(i)+"/PIO*fits*");
    if (numberof(files)==0) {yocoLogInfo,"No files..."; continue;}

    mjd = yocoAstroESOStampToJulianDay( strpart(yocoFileSplitName(files),7:), modified=1);
    mjdMin = yocoAstroESOStampToJulianDay(inputDirs(i)+"T12:00:00.00", modified=1);
    ids = ( (mjd<mjdMin) | (mjd>mjdMin+1));

    yocoLogInfo,"Check files:",["ok: ","KO: "](ids+1)+files;
    if (anyof(ids)) {
      yocoLogWarning,"--------------";
      yocoLogWarning,"Bad files "+pr1(numberof(where(ids)));
      yocoLogWarning,"--------------";
    }
  }
  return 1;
}

func pndrsArchiveBuildPhase3(inputDirs,outputDir=)
/* DOCUMENT pndrsArchive(void)

  > cd /data/pionier
  > dirs = oiFitsListFiles("-d 201*abcd | grep -e 2015-10 -e 2015-11 -e 2015-12 -e 2016 | grep -v vt | grep -v b_");
  > pndrsArchiveBuildPhase3, dirs,outputDir="phase3_P96";
*/
{
  yocoLogInfo,"pndrsArchiveBuildPhase3()";

  mkdir, outputDir;
  ndir = numberof(inputDirs);

  /* Loop on dirs */
  for (d=1;d<=numberof(inputDirs);d++) {
    yocoLogInfo,"Now in dir "+inputDirs(d);

    /* List calirbrated files */
    files = oiFitsListFiles(inputDirs(d)+"/PIO*oidataCalibrated.fits");

    /* Loop on files */
    for (asson=[],f=1;f<=numberof(files);f++) {

        /* Search for ASSON files and PROG.ID */
        fh = cfitsio_open(files(f));
        asson  = cfitsio_get(fh,"ASSON*");
        progId = cfitsio_get(fh,"HIERARCH ESO OBS PROG ID");

        /* Verify OI_T3 and OI_VIS2 */
        hasV2 = hasT3 = 0;
        hdunum  = cfitsio_get_num_hdus(fh);
        for(i=2;i<=cfitsio_get_num_hdus(fh);i++) {
            cfitsio_goto_hdu,fh,i;
            if (cfitsio_get(fh,"EXTNAME") == "OI_T3") hasT3++;
            if (cfitsio_get(fh,"EXTNAME") == "OI_VIS2") hasV2++;
        }
        cfitsio_close,fh;

        /* Checks */
        if (hasV2 == 0 || hasT3 == 0) {
            yocoLogWarning,"Missing OI_VIS2 or OI_T3 for: "+files(f);
            continue;
        }
        if (tonum(yocoStrSplit(progId,".")(1)) == 60) {
            yocoLogWarning,"Program ID is 60.XXXXX for: "+files(f);
            continue;
        }

        /* Update phase3 */
        pndrsUpdateFileWithPhase3, files(f);

        /* Copy files */
        system,"cp "+files(f)+" "+outputDir;
        if (numberof(asson)==0) {yocoLogWarning,"No ASSON files for: "+files(f);}
        system,"cp "+files(f)+" "+outputDir;
        for (a=1;a<=numberof(asson);a++) system,"cp "+inputDirs(d)+"/"+asson(a)+" "+outputDir;
    }
  }
  
  yocoLogInfo,"pndrsArchiveBuildPhase3 done";
  return 1;
}

/* ************************************************************ */

func pndrsArchiveLoadDownloadScript(files,&Saf,&Get)
/* DOCUMENT pndrsArchiveLoadDownloadScript(files,&Saf,&Get)

   Load downloadRequestXXXXXscript.sh file(s) into a list
   of saf and a list of wget command.
 */
{
  yocoLogInfo,"pndrsArchiveLoadDownloadScript()";
  local i,get,saf;

  /* Define the pwd and login in a configuration file */
  local user, password, strget;
  include,"~/.pndrs_profil",3;

  /* Check user and password */
  if (!yocoTypeIsStringScalar(user) || !yocoTypeIsStringScalar(password)) {
    yocoLogError,"USER/PASSWORD not valid. exit.";
    return 0;
  }
  
  strget = "wget  --auth-no-challenge --no-check-certificate --http-user="+user+
    " --http-password="+password+" ";

  Saf = Get = [];
  for (i=1;i<=numberof(files);i++) {
    saf = get = [];
    
    /* Read all download line */
    get = text_lines(files(i));
    get = get(where( strmatch(get,"https") & strmatch(get,"PIO") &
                     strmatch(get,".fits")  & !strmatch(get,".NL")));
    if (is_void(get)) continue;

    /* Deal with the various version of the download script */
    for (j=1;j<=numberof(get);j++)
      get(j) = strget + "  \"https"+yocoStrSplit( get(j) ,"\"https")(2);
    get;
    
    /* Grow */
    saf = yocoFileSplitName(yocoStrReplace(get,"\"",""));
    grow,Saf,saf;
    grow,Get,get;
  }
  
  yocoLogTrace,"pndrsArchiveLoadDownloadScript done";
  return 1;
}

func pndrsArchiveGetDownloadScript(saf, &script)
/* DOCUMENT pndrsArchiveGetDownloadScript(saf, &script)

   Do a request to the ESO archive for the SAF and get
   the corresponding downloadRequestXXXXXscript.sh

   The name of the script is also returned as argument.
*/
{
  yocoLogInfo,"pndrsArchiveGetDownloadScript()";
  local user, password, str;
  script = [];

  /* parameters */
  safId = ("SAF\%2B"+saf+",")(sum);
  state="SEND";

  /* Define the pwd and login in a configuration file */
  include,"~/.pndrs_profil",3;

  /* Check user and password */
  if (!yocoTypeIsStringScalar(user) || !yocoTypeIsStringScalar(password)) {
    yocoLogError,"USER/PASSWORD not valid. exit.";
    return 0;
  }

  /* Build request to get requestId */
  str = "wget -O - -q --auth-no-challenge --no-check-certificate --post-data=\"requestDescription=PIONIER_PHASE3&dataset="+safId+"\" --header=\"Accept:text/plain\" --http-user="+user+" --http-password="+password+" https://dataportal.eso.org/rh/api/requests/"+user+"/submission";

  /* Send request and read output */
  yocoLogInfo,"send request: "+str;
  requestId = rdline(popen(str,0))(0);
  yocoLogInfo,"requestId is "+requestId;

  if ( tonum(requestId)<1 ) {
    yocoLogWarning,"Unvalid request ID, exit";
    return 0;
  }
      
  /* Wait for complete */
  while (state!="COMPLETE") {
    str = "wget -O - -q --auth-no-challenge --no-check-certificate --http-user="+user+
      " --http-password="+password+" https://dataportal.eso.org/rh/api/requests/"+user+
      "/"+requestId+"/state";
    yocoLogInfo,"send request:",str;
    state = rdline(popen(str,0))(0);
    yocoLogInfo,"Request now in: "+state;
    pause,3000;
  }

  /* Download the download script */
  str = "wget -O downloadRequest"+requestId+"script.sh -q --auth-no-challenge --no-check-certificate --http-user="+user+
    " --http-password="+password+" https://dataportal.eso.org/rh/api/requests/"+user+"/"+requestId+"/script";
  yocoLogInfo,"send request:",str;
  system,str;

  /* Script name */
  script = "downloadRequest"+requestId+"script.sh";

  yocoLogTrace,"pndrsArchiveGetDownloadScript done";
  return 1;
}



/* ************************************************************ */

func pndrsArchiveGetSaf(date)
/* DOCUMENT pndrsArchiveGetSaf(date)

   Get all SAF from the PIONIER file of a given night,
   from the ESO archive.

   FIXME: Remove the PTC, PIXCHAR, BIAS...
*/
{
  yocoLogInfo,"pndrsArchiveGetSaf()";
  local date2, mjd, nfile;
  nfile=0;
  datasetId=[];

  /* Date in MJD */
  mjd = yocoAstroESOStampToJulianDay(date+"T01:00:00.0");
  if (!mjd) {
    yocoLogError,"Cannot search for date: "+pr1(date);
    return 0;
  }
  
  /* Define date2 for the search D to D+1 */
  date2 = strtok(yocoAstroJulianDayToESOStamp(mjd+1),"T")(1);

  /* Run the query to archive -- the file ID is the nb of ms since start of this day */
  file = "output_query_"+pr1(int((pndrsBatchTime()%1)*24*36001000))+".csv";
  yocoLogInfo,"Use file:", file;
  
  str = "wget -O "+file+" -q \"http://archive.eso.org/wdb/wdb/eso/eso_archive_main/query?tab_object=on&tab_prog_id=on&tab_instrument=on&instrument=PIONIER&stime="+date+"&starttime=12&etime="+date2+"&endtime=12&top=10000&wdbo=csv&requestCommand=SELECTIVE_HOTFLY\"";
  yocoLogInfo,"send request:",str;
  system, str;

  /* Read the output */
  data = text_cells(file);
  // data = data (,where ( (strtrim(data(1,))!="#") & (strtrim(data(2,))!=string())));
  data = data (, where(strlen(strtrim(data(1,)))>3));

  /* Check the number of files */
  sread, data(1,0),format="# A total of %i ",nfile;
  yocoLogInfo,"A total of "+pr1(nfile)+" files in ESO archive for "+date;

  /* Create a list of file_ids out of the csv.
     Remove the PTC */
  if (nfile>0) {
    datasetId   = data((where(data(,1)=="Dataset ID")(1)),2:);
    datasetType = data((where(data(,1)=="Type")(1)),2:);
    datasetId = datasetId(where(datasetId!=string() & !strmatch(datasetType,"PTC")));
    datasetId = datasetId(sort(datasetId));
  }

  yocoLogInfo,"Found "+pr1(numberof(datasetId))+" data files (no PTC) for "+date;
  yocoLogInfo,"pndrsArchiveGetSaf done";
  return datasetId;
}

/* ************************************************************ */

func pndrsArchiveCleanSafFromExisting(saf,inputDir=)
/* DOCUMENT pndrsArchiveCleanSafFromExisting(saf,inputDir=)

   Clean a list of SAF from existing files in
   the current directory.
     
   SEE ALSO:
 */
{
  yocoLogInfo,"pndrsArchiveCleanSafFromExisting()";
  local currentId;
  
  if (is_void(inputDir)) inputDir="./"

  /* List all existing files in the current dir */
  currentId = yocoFileSplitName( oiFitsListFiles(inputDir+"PIO*fit*") );
  
  /* Look for files that don't match (missing files) */
  if (is_void(currentId)) {
    noid = indgen(numberof(saf));
  } else {
    noid = where( yocoListId(saf,currentId) == 0);
  }

  yocoLogTrace,"pndrsArchiveCleanSafFromExisting done";
  return saf(noid);
}

/* ************************************************************ */

func pndrsArchiveGetFilesFromSaf(saf)
/* DOCUMENT pndrsArchiveGetFilesFromSaf(saf)

   FIXME: Buggy !!!!

   Download a set of SAF from the ESO archive.

   First check existing in the current directory,
   and skip them.
   
   Then browse downloadRequestXXXXscript.sh
   in the current directory. Use these past
   request if possible.

   If needed, perform a proper request to ESO
   for the SAF which were never requested.
*/
{
  yocoLogInfo,"pndrsArchiveGetFilesFromSaf()";
  local scripts, allSaf, get, allRequestedSaf;
  nsaf = numberof(saf);

  /* Check and remove existing */
  saf = pndrsArchiveCleanSafFromExisting(saf);

  /* Check how many are missing */
  nrequest = numberof(saf);
  yocoLogInfo,"Missing files: "+pr1(nrequest)+" over "+pr1(nsaf);
  if ( nrequest<1 ) { return 1; }

  /* Read the existing downloadRequest, to avoid requesting
     again the same data to ESO */
  scripts = oiFitsListFiles("./downloadRequest*sh");
  pndrsArchiveLoadDownloadScript, scripts, allSaf, allGet;
  allSaf = grow(allSaf,"");
  
  /* Search a wget line for each requested saf */
  id = where( !yocoListId(saf, allSaf) );
  yocoLogInfo,"Files in previous request(s): "+
    pr1(nrequest-numberof(id))+" over "+pr1(nrequest);

  /* If missing wget, download the script for these saf */
  if ( is_array(id) ) {
    pndrsArchiveGetDownloadScript, saf(id);
    scripts = oiFitsListFiles("./downloadRequest*sh");
    pndrsArchiveLoadDownloadScript, scripts, allSaf, allGet;
  }
  
  /* Search a wget line for each requested saf */
  id  = yocoListId(saf, allSaf);
  id  = id( where(id) );
  get = allGet(id);

  /* Download them */
  nget = numberof(get);
  for (i=1;i<=nget;i++) {
    yocoLogInfo,"*** \n File "+pr1(i)+" over "+pr1(nget);
    yocoLogInfo, get(i);
    system, get(i);
  }

  /* Verify that we download the same number as requested */
  if ( nget != nrequest)
    yocoLogWarning,pr1(nrequest-nget)+" files were not in the download list.";
  
  yocoLogInfo,"pndrsArchiveGetFilesFromSaf done";
  return 1;
}
