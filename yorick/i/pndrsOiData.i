/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsOiData(void)
/* DOCUMENT pndrsOiData(void)

   FUNCTIONS:
   - pndrsDefaultOiWaves
   - pndrsDefaultOiArray
   - pndrsDefaultOiTarget
   - pndrsDefaultOiLog
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.18 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsOiData;
    }   
    return version;
}

func pndrsDefaultOiArray(imgLog, &oiArray, &oiVis2, &oiT3, &oiVis)
/* DOCUMENT pndrsDefaultOiArray(imgLog, &oiArray, &oiVis2, &oiT3, &oiVis)

   DESCRIPTION
   Build a default OI_ARRAY structure.
   staIndex in oiVis2, oiT3, oiVis are updated accordingly.
   staIndex refers to PIONIER beams.
   
   PARAMETERS
   - imgLog : should be scalar

   EXAMPLES

   SEE ALSO
 */
{
  local uCoord, vCoord, u1Coord, v1Coord, u2Coord, v2Coord, issBeam;
  
  /* Prepare the oiArray */
  oiArray = array(struct_oiArray, 4);
  
  if (numberof(imgLog)>1) {
    error,"Cannot deal with array!!";
  }

  /* If ISS is not available, then use dummy station and telescope name */
  if (imgLog.issStation1 == imgLog.issStation2  &&
      imgLog.issStation3 == imgLog.issStation4 ) {
    yocoLogInfo, "ISS keyword not available: use fake station name";
    oiArray.staIndex = indgen(4);
    oiArray.telName = swrite(format="T%i",indgen(4));
    oiArray.staName = swrite(format="S%i",indgen(4));
    oiArray.hdr.arrName = "NONE";
  } else {

  /* Fill the oiArray for the 4 PIONIER arms. For each arm we found the corresponding ISS number
     and fill the station and telescope name from the ISS header. */
  for (i=1;i<=4;i++) {
    oiArray(i).staIndex = i;
    issBeam = pndrsPionierToIss(imgLog,i);

    /* Deal with the case the ISS beam is 0, for
       instance in the 3T case */
    if (issBeam == 0) {
      oiArray(i).telName  = " ";
      oiArray(i).staName  = " ";
    } else {
      oiArray(i).telName  = get_member(imgLog(1), swrite(format="issTelName%i",issBeam));
      oiArray(i).staName  = get_member(imgLog(1), swrite(format="issStation%i",issBeam));
    }
    
    oiArray(i).hdr.arrName = "VLTI";
    oiArray(i).hdr.frame   = "GEOCENTRIC";
    oiArray(i).hdr.arrayX  = 1945458.40719;
    oiArray(i).hdr.arrayY  =-5464447.67009;
    oiArray(i).hdr.arrayZ  =-2658804.58123;
  }

  }

  
  /* Fill the UV plan of oiVis2 */
  if (is_array(oiVis2)) {
    pndrsGetUVCoordIss, imgLog(1), oiVis2.staIndex(1,), oiVis2.staIndex(2,), uCoord, vCoord;
    oiVis2.uCoord   = uCoord;
    oiVis2.vCoord   = vCoord;
    oiVis2.hdr.arrName  = oiArray(1).hdr.arrName
  }

  /* Fill the UV plan of oiVis */
  if (is_array(oiVis)) {
    pndrsGetUVCoordIss, imgLog(1), oiVis.staIndex(1,), oiVis.staIndex(2,), uCoord, vCoord;
    oiVis.uCoord   = uCoord;
    oiVis.vCoord   = vCoord;
    oiVis.hdr.arrName  = oiArray(1).hdr.arrName
  }

  /* Fill the UV plan of oiT3 */
  if ( is_array(oiT3) ) {
    pndrsGetUVCoordIss, imgLog(1), oiT3.staIndex(1,), oiT3.staIndex(2,), u1Coord, v1Coord;
    pndrsGetUVCoordIss, imgLog(1), oiT3.staIndex(2,), oiT3.staIndex(3,), u2Coord, v2Coord;
    oiT3.u1Coord = u1Coord;
    oiT3.v1Coord = v1Coord;
    oiT3.u2Coord = u2Coord;
    oiT3.v2Coord = v2Coord;
    oiT3.hdr.arrName   = oiArray(1).hdr.arrName;
  }

  return 1;
}

func pndrsDefaultOiTarget(imgLog, &oiTarget, &oiVis2, &oiT3, &oiVis)
/* DOCUMENT pndrsDefaultOiTarget(imgLog, &oiTarget, &oiVis2, &oiT3, &oiVis)

   DESCRIPTION
   Build a default OI_TARGET structure.
   targetId in oiVis2, oiT3, oiVis are updated accordingly.

   PARAMETERS
   - imgLog : should be scalar

   EXAMPLES

   SEE ALSO
 */
{
  /* Prepare the name */
  local name;
  name = strtrim( imgLog.target );
  name = (strlen(name)==0 ? "UNKNOWN" : name );

  /* Prepare the oiTarget */
  oiTarget = struct_oiTarget();
  oiTarget.target   = name;
  oiTarget.raEp0    = imgLog.raEp0;
  oiTarget.decEp0   = imgLog.decEp0;
  oiTarget.equinox  = 2000;
  oiTarget.velDef   = "OPTICAL";
  oiTarget.velTyp   = "UNKNOWN";
  oiTarget.targetId = 1;

  /* Fill the structures */
  if ( is_array(oiVis) )  oiVis.targetId  = oiTarget.targetId;
  if ( is_array(oiVis2) ) oiVis2.targetId = oiTarget.targetId;
  if ( is_array(oiT3) )   oiT3.targetId   = oiTarget.targetId;
  
  return 1;
}

func pndrsDefaultOiLog(imgLog, &oiLog, &oiVis2, &oiT3, &oiVis)
{
  /* Prepare the oiLog */
  oiLog = [];
  oiLog = imgLog(1);

  /* Force to match the DPR.CATG of the OB name, for
     observations taken prior than 2015-03-01 */
  if (oiLog.mjdObs < 57084.0) {
    if ( strpart(oiLog.obsName,1:4)=="CAL_" ) { yocoLogInfo,"Force DPR.CATG to CALIB"; oiLog.dprCatg="CALIB"; }
    if ( strpart(oiLog.obsName,1:4)=="SCI_" ) { yocoLogInfo,"Force DPR.CATG to SCIENCE"; oiLog.dprCatg="SCIENCE"; }
  }
  
  /* Associate */
  if ( is_array(oiVis) )  oiVis.hdr.logId  = oiLog.logId;
  if ( is_array(oiVis2) ) oiVis2.hdr.logId = oiLog.logId;
  if ( is_array(oiT3) )   oiT3.hdr.logId   = oiLog.logId;
}

func pndrsDefaultInsName(imgLog, pol)
{
  //  return "PIONIER_"+pndrsGetWindows(,imgLog)+"_"+pol;
  return "PIONIER_"+pol;
}


func pndrsDefaultOiWaves(imgLog, &oiWave)
/* DOCUMENT pndrsDefaultOiWaves(imgLog, &oiWave)

   DESCRIPTION
   Build a default for OI_WAVE structure, dealing with the different
   polarisation in imgLog.correlation.

   PARAMETERS
   - imgLog : should be scalar

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsDefaultOiWaves()";
  local insNames, ny, lbd, pol, map;
  oiWave = [];
  
  /* Build the default wavelength array */
  pndrsGetDefaultWave,imgLog(1),lbd,lbdB;
  
  /* Get the number of polars */
  map = *imgLog(1).correlation;
  pol = yocoListClean(map.pol);

  /* If 2 polars, then also produce the combined oiWave */
  if ( numberof(pol)==2 ) {
    grow, pol, map.pol(1)+map.pol(0); 
  } else if ( numberof(pol)>2 ) {
    yocoError, "Cannot deal with more than 2 polars!";
  }

  /* Prepare the oiWaves */
  oiWave = array( oiFitsGetOiStruct("oiWavelength", -1), numberof(pol) );
  oiWave.hdr.logId = imgLog.logId;
  oiWave.effWave   = &( lbd );
  oiWave.effBand   = &( lbdB );
  
  /* Build the default insName */
  insNames = pndrsDefaultInsName(imgLog, pol);
  oiWave.hdr.insName = insNames;

  /* Verbose */
  yocoLogInfo, " channels in mum:", lbd*1e6;
  
  yocoLogTrace,"pndrsDefaultOiWaves done";
  return 1;  
}



/* ************************************************************************** */
local pndrsIssToPionier, pndrsPionierToIss;
/* DOCUMENT issBeam = pndrsPionierToIss(imgLog, pnrBeam)
            pnrBeam = pndrsIssToPionier(imgLog, issBeam)
            issBeam = pndrsStationToIss(imgLog, staName)

   DESCRIPTION
   Convert the number pnrBeam (1,2,3,4) into the corresponding ISS arm number.
   We assume that PIONIER 1,2,3,4 are in IP1,IP3,IP5,IP7.
 */

func pndrsIssToPionier(imgLog,i)
{
  local s, issInput, pnrInput;
  if (numberof(imgLog)>1) error;
  
  /* Get the IP of the four ISS arm */
  issInput = [];
  for (s=1;s<=4;s++) {
    grow, issInput, get_member(imgLog(1), swrite(format="issInput%i",s));
  }

  /* Deal with the case where all are 0,
     that is if ISS is not available.
     Otherwise keep the issInput of the requested beam */
  if (allof(issInput==0)) {
    issInput = [1,3,5,7](i);
    if (imgLog(1).target != "INTERNAL")
      yocoLogInfo,"ISS seems to be ignored: no info about the IP.";
  } else {
    issInput = issInput(i);
  }
    
  /* Convert it in PIONIER beam assuming IP1357 are PIONIER1234.
     This is the physical mapping in the lab... should not change. */
  pnrInput = int( 0.5+issInput/2.);

  /* Check it and eventually put a warning */
  if ( min(pnrInput)<1 || max(pnrInput)>4 ) {
    yocoLogInfo,"Non-standart ISS/PIONIER configuration: "+pr1(pnrInput);
  }

  return pnrInput; 
}

func pndrsPionierToIss(imgLog,i)
{
  local ips, issInput, pnrInput;
  if (numberof(imgLog)>1) error;
  
  /* Get the PIONIER numbering of the 4 ISS arms */
  ips = pndrsIssToPionier(imgLog,[1,2,3,4]);
  
  /* Get the position of the PIONIER beam in this list */
  return yocoListId(i,ips);
}

func pndrsStationToIss(imgLog,staName)
{
    output = array(0, dimsof(staName));
    for (i = 1; i <= numberof(staName); i++) {
        if (imgLog(1).issStation1 == staName(i)) output(i) = 1;
        if (imgLog(1).issStation2 == staName(i)) output(i) = 2;
        if (imgLog(1).issStation3 == staName(i)) output(i) = 3;
        if (imgLog(1).issStation4 == staName(i)) output(i) = 4;
    }
    return output;
}

func pndrsSetLogInfo(&imgLog,name,ids,values)
{
  if (is_void(ids)) ids=indgen(numberof(values));

  /* Build member names */
  str = strtrim( swrite(format=name,ids) );

  for (i=1;i<=numberof(ids);i++) {
      if ( catch(-1) ) {
        yocoLogWarning,"Cannot set the variable"+str(i);
        continue;
      }
    get_member( imgLog, str(i) ) = values(i);
  }
  
  return 1;
}

func pndrsSetLogInfoArray(&imgLog,id,name,ids,values)
{
  if (is_void(ids)) ids=indgen(numberof(values));

  /* Build member names */
  str = strtrim( swrite(format=name,ids) );

  for (i=1;i<=numberof(ids);i++) {
      if ( catch(-1) ) {
        yocoLogWarning,"Cannot set the variable"+str(i);
        continue;
      }
      get_member( imgLog(id), str(i) ) = values(i);
  }
  
  return 1;
}

func pndrsGetLogInfo(imgLog,name,i)
/* DOCUMENT pndrsGetLogInfo(imgLog,name,i)

   DESCRIPTION
   Return information from log.

   PARAMETERS
   - i refers to the PIONIER beam (as defined in "map").

   EXAMPLES

   SEE ALSO
 */
{
  local output,iss,j;
  if (numberof(imgLog)>1) error;
  if (is_void(name)) name="issTelName%i";
  
  iss = pndrsPionierToIss(imgLog,i);
  output = [];

  /* Loop on the beams */
  for (j=1;j<=numberof(iss);j++) {
    
    /* Fill with the value in log. 
       Check if 0 (can be because of a 3T configuration).
       Fill with an empty value of same type */
    if (iss(j)==0) {
      grow, output, structof( get_member(imgLog(1), swrite(format=name,1)))();
    } else {
      grow, output, get_member(imgLog(1), swrite(format=name,iss(j)));
    }
    
  }

  output = reform(output,dimsof(i));
  
  return output;
}

func pndrsGetUVCoordIss(imgLog, t1, t2, &uCoord, &vCoord, &sta1, &sta2)
/* DOCUMENT pndrsGetUVCoordIss(imgLog, t1, t2, &uCoord, &vCoord, &sta1, &sta2)

   DESCRIPTION
   Return the UV coordinates from the ISS for the PIONIER beams t1 and t2.
   It makes use of the function pndrsPionierToIss to convert the PIONIER
   beams into ISS beams.

   PARAMETERS
   - imgLog
   - t1, t2: PIONIER beams (numbering of the structure "map" and of PIONIER itself)
   - uCoord, vCoord:  returned corrdinates in meters
   - sta1, sta2: corresponding station names.
 */
{
  local A, B, lenISS, angISS, sign, base;
  sta1 = sta2 = uCoord= vCoord = [];
  
  /* Init */
  if (numberof(imgLog)>1) error;

  /* Convert t1 and t2 in ISS numbers in header */
  t1 = pndrsPionierToIss(imgLog,t1);
  t2 = pndrsPionierToIss(imgLog,t2);
  
  /* Loop on the telescope pairs since impossible to vector's */
  for (i=1;i<=numberof(t1);i++) {
    lenISS1 = lenISS2 = lenISS = angISS1 = angISS2 = angISS = 0.0;
    
    /* The ISS sign are always define from lowest to highest ISS numbers,
       therefore we will swap the sign of the uv-plan for our
       baselines defined the other way */
    A = min(t1(i),t2(i));
    B = max(t1(i),t2(i));

    /* Fill the station name */
    if (t1(i)==0) {
      grow, sta1, " ";
    } else {
      grow, sta1, get_member(imgLog(1), swrite(format="issStation%i",t1(i)));
    }
    
    /* Fill the station name */
    if (t2(i)==0) {
      grow, sta2, " ";
    } else {
      grow, sta2, get_member(imgLog(1), swrite(format="issStation%i",t2(i)));
    }

    /* get a name */
    issn = swrite(format="%i%i",A,B);
    
    /* Read angle and length of baselines, deal
       with the case when one beam is 0 (3T case).
       Return Baseline at start and end in a
       complex way. */
    if ( A==0 || B==0 ) {
      Base1 = complex(0.0);
      Base2 = complex(0.0);
      Base0 = complex(0.0);
    } else {
      lenISS1 = get_member(imgLog(1),"issPbl"+issn+"Start");
      lenISS2 = get_member(imgLog(1),"issPbl"+issn+"End");
      angISS1 = get_member(imgLog(1),"issPba"+issn+"Start");
      angISS2 = get_member(imgLog(1),"issPba"+issn+"End");
      Base1 = lenISS1 * exp(2.i*pi*angISS1/360.);
      Base2 = lenISS2 * exp(2.i*pi*angISS2/360.);
      Base0 = pndrsGetIssBaseFromTel(imgLog(1), A, B);
    }

    /* Replace ISS computation by my own computation. Apparently
       this has less dummy values than the ISS computation. */
    if (Base0 != 0.0) {
      Base1 = Base0;
      Base2 = Base0;
    } else if (imgLog(1).target != "INTERNAL") {
      yocoLogInfo,"Computation of baseline is 0. Use the ISS baseline.";
    }

    /* Average baseline start and end.
       Check if one baseline is screw-up,
       and so use the other one only */
    if ( abs(Base1)==0 && abs(Base2)!=0 ) {
      yocoLogInfo,"ISS baseline "+issn+"start is 0.0, use only baseline end";
      Base = Base1 = Base2;
    }
    else if ( abs(Base1)!=0 && abs(Base2)==0 ) {
      yocoLogInfo,"ISS baseline "+issn+"end is 0.0, use only baseline start";
      Base = Base2 = Base1;
    }
    else {
      Base = (Base1 + Base2) / 2.0;
    }
      
    
    /* Check if the baseline is screw-up while it should not be */
    if ( pndrsIsOnSky(imgLog(1)) && abs(Base)==0 && A!=0) {
      yocoLogWarning,"ISS baseline "+issn+" is 0.0";
    }

    /* Check if the difference between baseline is more than
       10% of the baseline length. If so make base=0 */
    if ( abs(Base1-Base2) / abs(Base+0.0001) > 0.1) {
      yocoLogWarning,"ISS baseline "+issn+" |start-end|>10% -> force 0";
      Base = complex(0.0);
    }
    
    /* Version 1: Phase sign seems to be wrong: binaries observed with PIONIER,
       reduced with this software and fitted with LITpro give 180deg
       inversion in position.
       
       Version 2+: revers the UV-plane. */
    sign   = [-1,1]( 1+(t1(i)<t2(i)) );
    
    /* This formula has been checked with aspro2 and gives similar
       results */
    grow, uCoord, sign * Base.im;
    grow, vCoord, sign * Base.re;
  }
  
  return 1;
}

func pndrsGetIssBaseFromTel(imgLog, iss1, iss2)
{
  geolat = -24.62743941 / 180. * pi;
  cl = cos(geolat);
  sl = sin(geolat);
  dec = imgLog(1).decEp0 / 180. *pi;
  cd = cos(dec);
  sd = sin(dec);

  /*axes x and y seem reverted wrt the aspro convention. I use aspro sign:*/
  x = get_member(imgLog(1), swrite(format="issT%ix",iss1)) -
      get_member(imgLog(1), swrite(format="issT%ix",iss2));
  y = get_member(imgLog(1), swrite(format="issT%iy",iss1)) -
      get_member(imgLog(1), swrite(format="issT%iy",iss2));
  z = get_member(imgLog(1), swrite(format="issT%iz",iss2)) -
      get_member(imgLog(1), swrite(format="issT%iz",iss1));
  
  /* convert to equatorial local */
  xx = 0*x - sl*y + cl*z;
  yy =   x +  0*y +  0*z;
  zz = 0*x + cl*y + sl*z;

  /* Check LST */
  if ( imgLog(1).lst==0 ) return 0. + 0.i;

  /* relative hour angle start */
  ha = imgLog(1).lst /(12*3600) *pi - imgLog(1).raEp0 /180 *pi;
  ch = cos(ha);
  sh = sin(ha);

  /* project onto star direction */
  u =     sh*xx +    ch*yy;
  v = -sd*ch*xx + sd*sh*yy + cd*zz;
  w =  cd*ch*xx - cd*sh*yy + sd*zz;

  /* Update */
  return v + 1.i*u;
}
