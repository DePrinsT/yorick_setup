/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsFiles(void)
/* DOCUMENT pndrsFiles(void)

   USER ORIENTED FUNCTIONS:
   - pndrsReadRawFiles
   - pndrsReadClockPattern

   SPECIFIC FUNCTIONS:
   - pndrsGetLogName
   - pndrsReadLog

   - pndrsGetSetup
   - pndrsGetShutters
   - pndrsGetWindows
   - pndrsGetAltAz
   
   - pndrsCheckfile
   - pndrsCheckDirectory
   - pndrsReadPnrLog
   - pndrsWritePnrLog

   - pndrsGetPicWidth
   - pndrsGetPicWidthFromTau0
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.29 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsFiles;
    }   
    return version;
}

/* Structure definition for the LOG */
struct struct_oiLog {
  long   logId;
  string fileName;
  string dateObs;
  double mjdObs;
  double raEp0, decEp0;
  string instrument,insMode;
  string obsName, progId, obsStart;
  long   obsContId, obsId;
  string arcFile;
  double detDit;
  long   detPolar,detNdit,detNdreads,detNspx,nbDarkWins;
  string detName;
  double issAlt;
  double issAz;
  double lst;
  string tplStart;
  string dprCatg, dprType, dprTech, proCatg;
  string obc, origin;
  char   shut1, shut2, shut3, shut4;
  char   scanStatus;
  string opti1Name, opti2Name;
  double dl1Stroke,dl2Stroke,dl3Stroke,dl4Stroke;
  double dl1Vel,dl2Vel,dl3Vel,dl4Vel;
  double ttm1Xref, ttm2Xref, ttm3Xref, ttm4Xref;
  double ttm1Yref, ttm2Yref, ttm3Yref, ttm4Yref;
  double ttm1Xpos, ttm2Xpos, ttm3Xpos, ttm4Xpos;
  double ttm1Ypos, ttm2Ypos, ttm3Ypos, ttm4Ypos;
  long   scanNreads;
  string detMode;
  long   detSubwins;
  string detSubwin1;
  string target;
  string opti3Name, opti4Name, fil1Name, fil2Name;
  long   detXref, detYref;
  pointer correlation;
  double issRefRa, issRefDec;
  double issFwhmStart, issFwhmEnd, issTau0Start, issTau0End;
  string issStation1, issStation2, issStation3, issStation4;
  string issTelName1, issTelName2, issTelName3, issTelName4;
  double issPbl12End, issPbl12Start, issPbl13End, issPbl13Start;
  double issPbl14End, issPbl14Start, issPbl23End, issPbl23Start;
  double issPbl24End, issPbl24Start, issPbl34End, issPbl34Start;  
  double issPba12End, issPba12Start, issPba13End, issPba13Start;
  double issPba14End, issPba14Start, issPba23End, issPba23Start;
  double issPba24End, issPba24Start, issPba34End, issPba34Start;
  long   issInput1,issInput2,issInput3,issInput4;
  double issT1x, issT1y, issT1z, issT2x, issT2y, issT2z;
  double issT3x, issT3y, issT3z, issT4x, issT4y, issT4z;
  double sts1Drpos,sts2Drpos,sts3Drpos,sts4Drpos;
  double detTrk1, detTrk2, detTrk3, detTrk4;
  double issDl1OplStart,issDl2OplStart,issDl3OplStart,issDl4OplStart;
  double issDl1OplEnd,issDl2OplEnd,issDl3OplEnd,issDl4OplEnd;
  double issConfA1L,issConfA2L,issConfA3L,issConfA4L;
  double parangStart, parangEnd;
  string pndrsVersion;
  double qcSnr12Avg,qcSnr13Avg,qcSnr14Avg,qcSnr23Avg,qcSnr24Avg,qcSnr34Avg;
  double qcSnru12Avg,qcSnru13Avg,qcSnru14Avg,qcSnru23Avg,qcSnru24Avg,qcSnru34Avg;
  double qcSnrl12Avg,qcSnrl13Avg,qcSnrl14Avg,qcSnrl23Avg,qcSnrl24Avg,qcSnrl34Avg;
  double qcSnr12Rms,qcSnr13Rms,qcSnr14Rms,qcSnr23Rms,qcSnr24Rms,qcSnr34Rms;
  double qcOpd12Avg,qcOpd13Avg,qcOpd14Avg,qcOpd23Avg,qcOpd24Avg,qcOpd34Avg;
  double qcOpd12Rms,qcOpd13Rms,qcOpd14Rms,qcOpd23Rms,qcOpd24Rms,qcOpd34Rms;
  double qcOpdf12Rms,qcOpdf13Rms,qcOpdf14Rms,qcOpdf23Rms,qcOpdf24Rms,qcOpdf34Rms;
  string qcFlux1P1,qcFlux2P1,qcFlux3P1,qcFlux4P1;
  string qcFlux1P2,qcFlux2P2,qcFlux3P2,qcFlux4P2;
  double qcFlux1Avg,qcFlux2Avg,qcFlux3Avg,qcFlux4Avg;
  double qcFlux1Rms,qcFlux2Rms,qcFlux3Rms,qcFlux4Rms;
  double qcFlux1Max,qcFlux2Max,qcFlux3Max,qcFlux4Max;
  string qcFlux1Histo,qcFlux2Histo,qcFlux3Histo,qcFlux4Histo;
  double qcFlux1P05,qcFlux2P05,qcFlux3P05,qcFlux4P05;
  double qcFlux1P50,qcFlux2P50,qcFlux3P50,qcFlux4P50;
  double qcFlux1P95,qcFlux2P95,qcFlux3P95,qcFlux4P95;
  double qcFlux1P05P95,qcFlux2P05P95,qcFlux3P05P95,qcFlux4P05P95;
  double qcTrans1, qcTrans2, qcTrans3, qcTrans4;
  double qcVis12Avg,qcVis13Avg,qcVis14Avg,qcVis23Avg,qcVis24Avg,qcVis34Avg;
  double qcVis12Err,qcVis13Err,qcVis14Err,qcVis23Err,qcVis24Err,qcVis34Err;
  double qcPhi123Avg, qcPhi124Avg, qcPhi134Avg, qcPhi234Avg; 
  double qcPhi123Err, qcPhi124Err, qcPhi134Err, qcPhi234Err;
  double qcTfVis12Avg,qcTfVis13Avg,qcTfVis14Avg,qcTfVis23Avg,qcTfVis24Avg,qcTfVis34Avg;
  double qcTfVis12Err,qcTfVis13Err,qcTfVis14Err,qcTfVis23Err,qcTfVis24Err,qcTfVis34Err;
  double qcNorm12Avg,qcNorm13Avg,qcNorm14Avg,qcNorm23Avg,qcNorm24Avg,qcNorm34Avg;
  double qcAmp12Avg,qcAmp13Avg,qcAmp14Avg,qcAmp23Avg,qcAmp24Avg,qcAmp34Avg;
  double qcDarkMed, qcDarkRmsMax, qcDarkRmsMed, qcNoiseMed, qcNoiseMax;
  double qcKappa1Rms,  qcKappa2Rms, qcKappa3Rms, qcKappa4Rms;
  double qcKappaRaw1Avg,  qcKappaRaw2Avg, qcKappaRaw3Avg, qcKappaRaw4Avg;
  double qcKappa12Avg, qcKappa13Avg, qcKappa14Avg, qcKappa23Avg, qcKappa24Avg, qcKappa34Avg;
  double qcDbDiam, qcDbDiamErr, qcDbHmag, qcDbRmag;
  double qcEffwave,qcEffband, qcEffwavePtp;
  double sens9Stat,sens12Stat;
  char   qcQualityFlag;
};

extern struct_oiLogEntries;
struct_oiLogEntries = [["dateObs",       "DATE", ""],
                       ["mjdObs",        "MJD-OBS", ""],
                       ["detDit",        "HIERARCH ESO DET DIT",""],
                       ["detName",       "HIERARCH ESO DET NAME",""],
                       ["detNdit",       "HIERARCH ESO DET NDIT",""],
                       ["detNdreads",    "HIERARCH ESO DET READOUT NDREADS",""],
                       ["detMode",       "HIERARCH ESO DET READOUT MODE",""],
                       ["detNspx",       "HIERARCH ESO DET READOUT NSAMPPIX",""],
                       ["detPolar",      "HIERARCH ESO DET POLAR",""],
                       ["insMode",       "HIERARCH ESO INS MODE",""],
                       ["issAlt",        "HIERARCH ESO ISS ALT",""],
                       ["issAz",         "HIERARCH ESO ISS AZ",""],
                       ["tplStart",      "HIERARCH ESO TPL START",""],
                       ["raEp0",         "RA",""],
                       ["decEp0",        "DEC",""],
                       ["lst",           "LST",""],
                       ["obc",           "HIERARCH ESO INS OBC TYPE",""],
                       ["shut1",         "HIERARCH ESO INS SHUT1 ST",""],
                       ["shut2",         "HIERARCH ESO INS SHUT2 ST",""],
                       ["shut3",         "HIERARCH ESO INS SHUT3 ST",""],
                       ["shut4",         "HIERARCH ESO INS SHUT4 ST",""],
                       ["dprCatg",       "HIERARCH ESO DPR CATG",""],
                       ["dprType",       "HIERARCH ESO DPR TYPE",""],
                       ["dprTech",       "HIERARCH ESO DPR TECH",""],
                       ["proCatg",       "HIERARCH ESO PRO CATG",""],
                       ["dl1Vel",        "HIERARCH ESO DET SCAN DL1 VEL","m/s"],
                       ["dl2Vel",        "HIERARCH ESO DET SCAN DL2 VEL","m/s"],
                       ["dl3Vel",        "HIERARCH ESO DET SCAN DL3 VEL","m/s"],
                       ["dl4Vel",        "HIERARCH ESO DET SCAN DL4 VEL","m/s"],
                       ["dl1Stroke",     "HIERARCH ESO DET SCAN DL1 STROKE","m"],
                       ["dl2Stroke",     "HIERARCH ESO DET SCAN DL2 STROKE","m"],
                       ["dl3Stroke",     "HIERARCH ESO DET SCAN DL3 STROKE","m"],
                       ["dl4Stroke",     "HIERARCH ESO DET SCAN DL4 STROKE","m"],
                       ["scanNreads",    "HIERARCH ESO DET SCAN NREADS",""],
                       ["detSubwin1",    "HIERARCH ESO DET SUBWIN1 GEOMETRY",""],
                       ["detSubwins",    "HIERARCH ESO DET SUBWINS",""],
                       ["nbDarkWins",    "HIERARCH ESO DET NBDARKWINS",""],
                       ["instrument",    "INSTRUME",""],
                       ["target",        "HIERARCH ESO OBS TARG NAME",""],
                       ["obsName",       "HIERARCH ESO OBS NAME",""],
                       ["obsStart",      "HIERARCH ESO OBS START",""],
                       ["progId",        "HIERARCH ESO OBS PROG ID",""],
                       ["obsId",         "HIERARCH ESO OBS ID",""],
                       ["obsContId",     "HIERARCH ESO OBS CONTAINER ID",""],
                       ["fil1Name",      "HIERARCH ESO INS FILT1 NAME",""],
                       ["fil2Name",      "HIERARCH ESO INS FILT2 NAME",""],
                       ["opti1Name",     "HIERARCH ESO INS OPTI1 NAME",""],
                       ["opti2Name",     "HIERARCH ESO INS OPTI2 NAME",""],
                       ["opti3Name",     "HIERARCH ESO INS OPTI3 NAME",""],
                       ["opti4Name",     "HIERARCH ESO INS OPTI4 NAME",""],
                       ["detXref",       "HIERARCH ESO DET SUBWIN XREF",""],
                       ["detYref",       "HIERARCH ESO DET SUBWIN YREF",""],
                       ["detTrk1",       "HIERARCH ESO DET TRK DL1 OPD",""],
                       ["detTrk2",       "HIERARCH ESO DET TRK DL2 OPD",""],
                       ["detTrk3",       "HIERARCH ESO DET TRK DL3 OPD",""],
                       ["detTrk4",       "HIERARCH ESO DET TRK DL4 OPD",""],
                       ["sens9Stat",     "HIERARCH ESO INS SENS9 STAT", "V"],
                       ["sens12Stat",    "HIERARCH ESO INS SENS12 STAT", "A"],
                       ["ttm1Xref",      "HIERARCH ESO INS TTM1 XREF", "rad"],
                       ["ttm2Xref",      "HIERARCH ESO INS TTM2 XREF", "rad"],
                       ["ttm3Xref",      "HIERARCH ESO INS TTM3 XREF", "rad"],
                       ["ttm4Xref",      "HIERARCH ESO INS TTM4 XREF", "rad"],
                       ["ttm1Yref",      "HIERARCH ESO INS TTM1 YREF", "rad"],
                       ["ttm2Yref",      "HIERARCH ESO INS TTM2 YREF", "rad"],
                       ["ttm3Yref",      "HIERARCH ESO INS TTM3 YREF", "rad"],
                       ["ttm4Yref",      "HIERARCH ESO INS TTM4 YREF", "rad"],
                       ["ttm1Xpos",      "HIERARCH ESO INS TTM1 XPOS", "rad"],
                       ["ttm2Xpos",      "HIERARCH ESO INS TTM2 XPOS", "rad"],
                       ["ttm3Xpos",      "HIERARCH ESO INS TTM3 XPOS", "rad"],
                       ["ttm4Xpos",      "HIERARCH ESO INS TTM4 XPOS", "rad"],
                       ["ttm1Ypos",      "HIERARCH ESO INS TTM1 YPOS", "rad"],
                       ["ttm2Ypos",      "HIERARCH ESO INS TTM2 YPOS", "rad"],
                       ["ttm3Ypos",      "HIERARCH ESO INS TTM3 YPOS", "rad"],
                       ["ttm4Ypos",      "HIERARCH ESO INS TTM4 YPOS", "rad"],
                       ["scanStatus",    "HIERARCH ESO DET SCAN ST",""],
                       ["issRefRa",      "HIERARCH ESO ISS REF RA",""],
                       ["issRefDec",     "HIERARCH ESO ISS REF DEC",""],
                       ["issFwhmStart",  "HIERARCH ESO ISS AMBI FWHM START",""],
                       ["issFwhmEnd",    "HIERARCH ESO ISS AMBI FWHM END",""],
                       ["issTau0Start",  "HIERARCH ESO ISS AMBI TAU0 START",""],
                       ["issTau0End",    "HIERARCH ESO ISS AMBI TAU0 END",""],
                       ["issStation1",   "HIERARCH ESO ISS CONF STATION1",""],
                       ["issStation2",   "HIERARCH ESO ISS CONF STATION2",""],
                       ["issStation3",   "HIERARCH ESO ISS CONF STATION3",""],
                       ["issStation4",   "HIERARCH ESO ISS CONF STATION4",""],
                       ["issTelName1",   "HIERARCH ESO ISS CONF T1NAME",""],
                       ["issTelName2",   "HIERARCH ESO ISS CONF T2NAME",""],
                       ["issTelName3",   "HIERARCH ESO ISS CONF T3NAME",""],
                       ["issTelName4",   "HIERARCH ESO ISS CONF T4NAME",""],
                       ["issPbl12End",   "HIERARCH ESO ISS PBL12 END",""],
                       ["issPbl12Start", "HIERARCH ESO ISS PBL12 START",""],
                       ["issPbl13End",   "HIERARCH ESO ISS PBL13 END",""],
                       ["issPbl13Start", "HIERARCH ESO ISS PBL13 START",""],
                       ["issPbl14End",   "HIERARCH ESO ISS PBL14 END",""],
                       ["issPbl14Start", "HIERARCH ESO ISS PBL14 START",""],
                       ["issPbl23End",   "HIERARCH ESO ISS PBL23 END",""],
                       ["issPbl23Start", "HIERARCH ESO ISS PBL23 START",""],
                       ["issPbl24End",   "HIERARCH ESO ISS PBL24 END",""],
                       ["issPbl24Start", "HIERARCH ESO ISS PBL24 START",""],
                       ["issPbl34End",   "HIERARCH ESO ISS PBL34 END",""],
                       ["issPbl34Start", "HIERARCH ESO ISS PBL34 START",""],
                       ["issPba12End",   "HIERARCH ESO ISS PBLA12 END",""],
                       ["issPba12Start", "HIERARCH ESO ISS PBLA12 START",""],
                       ["issPba13End",   "HIERARCH ESO ISS PBLA13 END",""],
                       ["issPba13Start", "HIERARCH ESO ISS PBLA13 START",""],
                       ["issPba14End",   "HIERARCH ESO ISS PBLA14 END",""],
                       ["issPba14Start", "HIERARCH ESO ISS PBLA14 START",""],
                       ["issPba23End",   "HIERARCH ESO ISS PBLA23 END",""],
                       ["issPba23Start", "HIERARCH ESO ISS PBLA23 START",""],
                       ["issPba24End",   "HIERARCH ESO ISS PBLA24 END",""],
                       ["issPba24Start", "HIERARCH ESO ISS PBLA24 START",""],
                       ["issPba34End",   "HIERARCH ESO ISS PBLA34 END",""],
                       ["issPba34Start", "HIERARCH ESO ISS PBLA34 START",""],
                       ["issInput1",     "HIERARCH ESO ISS CONF INPUT1",""],
                       ["issInput2",     "HIERARCH ESO ISS CONF INPUT2",""],
                       ["issInput3",     "HIERARCH ESO ISS CONF INPUT3",""],
                       ["issInput4",     "HIERARCH ESO ISS CONF INPUT4",""],
                       ["issT1x",        "HIERARCH ESO ISS CONF T1X",""],
                       ["issT1y",        "HIERARCH ESO ISS CONF T1Y",""],
                       ["issT1z",        "HIERARCH ESO ISS CONF T1Z",""],
                       ["issT2x",        "HIERARCH ESO ISS CONF T2X",""],
                       ["issT2y",        "HIERARCH ESO ISS CONF T2Y",""],
                       ["issT2z",        "HIERARCH ESO ISS CONF T2Z",""],
                       ["issT3x",        "HIERARCH ESO ISS CONF T3X",""],
                       ["issT3y",        "HIERARCH ESO ISS CONF T3Y",""],
                       ["issT3z",        "HIERARCH ESO ISS CONF T3Z",""],
                       ["issT4x",        "HIERARCH ESO ISS CONF T4X",""],
                       ["issT4y",        "HIERARCH ESO ISS CONF T4Y",""],
                       ["issT4z",        "HIERARCH ESO ISS CONF T4Z",""],
                       ["sts1Drpos",     "HIERARCH ESO ISS PRI STS1 DERPOS START","deg"],
                       ["sts2Drpos",     "HIERARCH ESO ISS PRI STS2 DERPOS START","deg"],
                       ["sts3Drpos",     "HIERARCH ESO ISS PRI STS3 DERPOS START","deg"],
                       ["sts4Drpos",     "HIERARCH ESO ISS PRI STS4 DERPOS START","deg"],
                       ["issDl1OplStart","HIERARCH ESO DEL DLT1 OPL START",""],
                       ["issDl1OplEnd",  "HIERARCH ESO DEL DLT1 OPL END",""],
                       ["issDl2OplStart","HIERARCH ESO DEL DLT2 OPL START",""],
                       ["issDl2OplEnd",  "HIERARCH ESO DEL DLT2 OPL END",""],
                       ["issDl3OplStart","HIERARCH ESO DEL DLT3 OPL START",""],
                       ["issDl3OplEnd",  "HIERARCH ESO DEL DLT3 OPL END",""],
                       ["issDl4OplStart","HIERARCH ESO DEL DLT4 OPL START",""],
                       ["issDl4OplEnd",  "HIERARCH ESO DEL DLT4 OPL END",""],
                       ["issConfA1L",    "HIERARCH ESO ISS CONF A1L",""],
                       ["issConfA2L",    "HIERARCH ESO ISS CONF A2L",""],
                       ["issConfA3L",    "HIERARCH ESO ISS CONF A3L",""],
                       ["issConfA4L",    "HIERARCH ESO ISS CONF A4L",""],
                       ["pndrsVersion",  "HIERARCH ESO OCS DRS VERSION",""],
                       ["parangStart",   "HIERARCH ESO ISS PARANG START",""],
                       ["parangEnd",     "HIERARCH ESO ISS PARANG END",""],
                       ["qcDbDiam",     "HIERARCH ESO QC DB DIAM","mas"],
                       ["qcDbDiamErr",  "HIERARCH ESO QC DB DIAM ERR","mas"],
                       ["qcDbHmag",     "HIERARCH ESO QC DB HMAG",""],
                       ["qcDbRmag",     "HIERARCH ESO QC DB RMAG",""],
                       ["qcSnr12Avg",  "HIERARCH ESO QC SNR12 AVG",""],
                       ["qcSnr13Avg",  "HIERARCH ESO QC SNR13 AVG",""],
                       ["qcSnr14Avg",  "HIERARCH ESO QC SNR14 AVG",""],
                       ["qcSnr23Avg",  "HIERARCH ESO QC SNR23 AVG",""],
                       ["qcSnr24Avg",  "HIERARCH ESO QC SNR24 AVG",""],
                       ["qcSnr34Avg",  "HIERARCH ESO QC SNR34 AVG",""],
                       ["qcSnr12Rms",  "HIERARCH ESO QC SNR12 RMS",""],
                       ["qcSnr13Rms",  "HIERARCH ESO QC SNR13 RMS",""],
                       ["qcSnr14Rms",  "HIERARCH ESO QC SNR14 RMS",""],
                       ["qcSnr23Rms",  "HIERARCH ESO QC SNR23 RMS",""],
                       ["qcSnr24Rms",  "HIERARCH ESO QC SNR24 RMS",""],
                       ["qcSnr34Rms",  "HIERARCH ESO QC SNR34 RMS",""],
                       ["qcSnru12Avg", "HIERARCH ESO QC SNRU12 AVG",""],
                       ["qcSnru13Avg", "HIERARCH ESO QC SNRU13 AVG",""],
                       ["qcSnru14Avg", "HIERARCH ESO QC SNRU14 AVG",""],
                       ["qcSnru23Avg", "HIERARCH ESO QC SNRU23 AVG",""],
                       ["qcSnru24Avg", "HIERARCH ESO QC SNRU24 AVG",""],
                       ["qcSnru34Avg", "HIERARCH ESO QC SNRU34 AVG",""],
                       ["qcSnrl12Avg", "HIERARCH ESO QC SNRL12 AVG",""],
                       ["qcSnrl13Avg", "HIERARCH ESO QC SNRL13 AVG",""],
                       ["qcSnrl14Avg", "HIERARCH ESO QC SNRL14 AVG",""],
                       ["qcSnrl23Avg", "HIERARCH ESO QC SNRL23 AVG",""],
                       ["qcSnrl24Avg", "HIERARCH ESO QC SNRL24 AVG",""],
                       ["qcSnrl34Avg", "HIERARCH ESO QC SNRL34 AVG",""],
                       ["qcOpd12Avg", "HIERARCH ESO QC OPD12 AVG","m"],
                       ["qcOpd13Avg", "HIERARCH ESO QC OPD13 AVG","m"],
                       ["qcOpd14Avg", "HIERARCH ESO QC OPD14 AVG","m"],
                       ["qcOpd23Avg", "HIERARCH ESO QC OPD23 AVG","m"],
                       ["qcOpd24Avg", "HIERARCH ESO QC OPD24 AVG","m"],
                       ["qcOpd34Avg", "HIERARCH ESO QC OPD34 AVG","m"],
                       ["qcOpd12Rms", "HIERARCH ESO QC OPD12 RMS","m"],
                       ["qcOpd13Rms", "HIERARCH ESO QC OPD13 RMS","m"],
                       ["qcOpd14Rms", "HIERARCH ESO QC OPD14 RMS","m"],
                       ["qcOpd23Rms", "HIERARCH ESO QC OPD23 RMS","m"],
                       ["qcOpd24Rms", "HIERARCH ESO QC OPD24 RMS","m"],
                       ["qcOpd34Rms", "HIERARCH ESO QC OPD34 RMS","m"],
                       ["qcOpdf12Rms", "HIERARCH ESO QC OPDF12 RMS","m"],
                       ["qcOpdf13Rms", "HIERARCH ESO QC OPDF13 RMS","m"],
                       ["qcOpdf14Rms", "HIERARCH ESO QC OPDF14 RMS","m"],
                       ["qcOpdf23Rms", "HIERARCH ESO QC OPDF23 RMS","m"],
                       ["qcOpdf24Rms", "HIERARCH ESO QC OPDF24 RMS","m"],
                       ["qcOpdf34Rms", "HIERARCH ESO QC OPDF34 RMS","m"],
                       ["qcOpd34Rms", "HIERARCH ESO QC OPD34 RMS","m"],
                       ["qcFlux1P1", "HIERARCH ESO QC FLUX1P1",""],
                       ["qcFlux2P1", "HIERARCH ESO QC FLUX2P1",""],
                       ["qcFlux3P1", "HIERARCH ESO QC FLUX3P1",""],
                       ["qcFlux4P1", "HIERARCH ESO QC FLUX4P1",""],
                       ["qcFlux1P2", "HIERARCH ESO QC FLUX1P2",""],
                       ["qcFlux2P2", "HIERARCH ESO QC FLUX2P2",""],
                       ["qcFlux3P2", "HIERARCH ESO QC FLUX3P2",""],
                       ["qcFlux4P2", "HIERARCH ESO QC FLUX4P2",""],
                       ["qcFlux1Avg", "HIERARCH ESO QC FLUX1 AVG","adu"],
                       ["qcFlux2Avg", "HIERARCH ESO QC FLUX2 AVG","adu"],
                       ["qcFlux3Avg", "HIERARCH ESO QC FLUX3 AVG","adu"],
                       ["qcFlux4Avg", "HIERARCH ESO QC FLUX4 AVG","adu"],
                       ["qcFlux1Max", "HIERARCH ESO QC FLUX1 MAX","adu"],
                       ["qcFlux2Max", "HIERARCH ESO QC FLUX2 MAX","adu"],
                       ["qcFlux3Max", "HIERARCH ESO QC FLUX3 MAX","adu"],
                       ["qcFlux4Max", "HIERARCH ESO QC FLUX4 MAX","adu"],
                       ["qcFlux1Rms", "HIERARCH ESO QC FLUX1 RMS","adu"],
                       ["qcFlux2Rms", "HIERARCH ESO QC FLUX2 RMS","adu"],
                       ["qcFlux3Rms", "HIERARCH ESO QC FLUX3 RMS","adu"],
                       ["qcFlux4Rms", "HIERARCH ESO QC FLUX4 RMS","adu"],
                       ["qcFlux1Histo", "HIERARCH ESO QC FLUX1 HISTO",""],
                       ["qcFlux2Histo", "HIERARCH ESO QC FLUX2 HISTO",""],
                       ["qcFlux3Histo", "HIERARCH ESO QC FLUX3 HISTO",""],
                       ["qcFlux4Histo", "HIERARCH ESO QC FLUX4 HISTO",""],
                       ["qcFlux1P05", "HIERARCH ESO QC FLUX1 P05","adu"],
                       ["qcFlux2P05", "HIERARCH ESO QC FLUX2 P05","adu"],
                       ["qcFlux3P05", "HIERARCH ESO QC FLUX3 P05","adu"],
                       ["qcFlux4P05", "HIERARCH ESO QC FLUX4 P05","adu"],
                       ["qcFlux1P95", "HIERARCH ESO QC FLUX1 P95","adu"],
                       ["qcFlux2P95", "HIERARCH ESO QC FLUX2 P95","adu"],
                       ["qcFlux3P95", "HIERARCH ESO QC FLUX3 P95","adu"],
                       ["qcFlux4P95", "HIERARCH ESO QC FLUX4 P95","adu"],
                       ["qcFlux1P50", "HIERARCH ESO QC FLUX1 P50","adu"],
                       ["qcFlux2P50", "HIERARCH ESO QC FLUX2 P50","adu"],
                       ["qcFlux3P50", "HIERARCH ESO QC FLUX3 P50","adu"],
                       ["qcFlux4P50", "HIERARCH ESO QC FLUX4 P50","adu"],
                       ["qcFlux1P05P95", "HIERARCH ESO QC FLUX1 P05P95",""],
                       ["qcFlux2P05P95", "HIERARCH ESO QC FLUX2 P05P95",""],
                       ["qcFlux3P05P95", "HIERARCH ESO QC FLUX3 P05P95",""],
                       ["qcFlux4P05P95", "HIERARCH ESO QC FLUX4 P05P95",""],
                        ["qcKappa1Rms", "HIERARCH ESO QC KAPPA1 RMS",""],
                       ["qcKappa2Rms", "HIERARCH ESO QC KAPPA2 RMS",""],
                       ["qcKappa3Rms", "HIERARCH ESO QC KAPPA3 RMS",""],
                       ["qcKappa4Rms", "HIERARCH ESO QC KAPPA4 RMS",""],
                       ["qcKappaRaw1Avg", "HIERARCH ESO QC KAPPARAW1 AVG",""],
                       ["qcKappaRaw2Avg", "HIERARCH ESO QC KAPPARAW2 AVG",""],
                       ["qcKappaRaw3Avg", "HIERARCH ESO QC KAPPARAW3 AVG",""],
                       ["qcKappaRaw4Avg", "HIERARCH ESO QC KAPPARAW4 AVG",""],
                       ["qcKappa12Avg", "HIERARCH ESO QC KAPPA12 AVG",""],
                       ["qcKappa13Avg", "HIERARCH ESO QC KAPPA13 AVG",""],
                       ["qcKappa14Avg", "HIERARCH ESO QC KAPPA14 AVG",""],
                       ["qcKappa23Avg", "HIERARCH ESO QC KAPPA23 AVG",""],
                       ["qcKappa24Avg", "HIERARCH ESO QC KAPPA24 AVG",""],
                       ["qcKappa34Avg", "HIERARCH ESO QC KAPPA34 AVG",""],
                       ["qcTrans1", "HIERARCH ESO QC TRANS1",""],
                       ["qcTrans2", "HIERARCH ESO QC TRANS2",""],
                       ["qcTrans3", "HIERARCH ESO QC TRANS3",""],
                       ["qcTrans4", "HIERARCH ESO QC TRANS4",""],
                       ["qcVis12Avg", "HIERARCH ESO QC VIS12 AVG",""],
                       ["qcVis13Avg", "HIERARCH ESO QC VIS13 AVG",""],
                       ["qcVis14Avg", "HIERARCH ESO QC VIS14 AVG",""],
                       ["qcVis23Avg", "HIERARCH ESO QC VIS23 AVG",""],
                       ["qcVis24Avg", "HIERARCH ESO QC VIS24 AVG",""],
                       ["qcVis34Avg", "HIERARCH ESO QC VIS34 AVG",""],
                       ["qcVis12Err", "HIERARCH ESO QC VIS12 ERR",""],
                       ["qcVis13Err", "HIERARCH ESO QC VIS13 ERR",""],
                       ["qcVis14Err", "HIERARCH ESO QC VIS14 ERR",""],
                       ["qcVis23Err", "HIERARCH ESO QC VIS23 ERR",""],
                       ["qcVis24Err", "HIERARCH ESO QC VIS24 ERR",""],
                       ["qcVis34Err", "HIERARCH ESO QC VIS34 ERR",""],
                       ["qcPhi123Avg", "HIERARCH ESO QC PHI123 AVG",""],
                       ["qcPhi124Avg", "HIERARCH ESO QC PHI124 AVG",""],
                       ["qcPhi134Avg", "HIERARCH ESO QC PHI134 AVG",""],
                       ["qcPhi234Avg", "HIERARCH ESO QC PHI234 AVG",""],
                       ["qcPhi123Err", "HIERARCH ESO QC PHI123 ERR",""],
                       ["qcPhi124Err", "HIERARCH ESO QC PHI124 ERR",""],
                       ["qcPhi134Err", "HIERARCH ESO QC PHI134 ERR",""],
                       ["qcPhi234Err", "HIERARCH ESO QC PHI234 ERR",""],
                       ["qcTfVis12Avg", "HIERARCH ESO QC TFVIS12 AVG",""],
                       ["qcTfVis13Avg", "HIERARCH ESO QC TFVIS13 AVG",""],
                       ["qcTfVis14Avg", "HIERARCH ESO QC TFVIS14 AVG",""],
                       ["qcTfVis23Avg", "HIERARCH ESO QC TFVIS23 AVG",""],
                       ["qcTfVis24Avg", "HIERARCH ESO QC TFVIS24 AVG",""],
                       ["qcTfVis34Avg", "HIERARCH ESO QC TFVIS34 AVG",""],
                       ["qcTfVis12Err", "HIERARCH ESO QC TFVIS12 ERR",""],
                       ["qcTfVis13Err", "HIERARCH ESO QC TFVIS13 ERR",""],
                       ["qcTfVis14Err", "HIERARCH ESO QC TFVIS14 ERR",""],
                       ["qcTfVis23Err", "HIERARCH ESO QC TFVIS23 ERR",""],
                       ["qcTfVis24Err", "HIERARCH ESO QC TFVIS24 ERR",""],
                       ["qcTfVis34Err", "HIERARCH ESO QC TFVIS34 ERR",""],
                       ["qcNorm12Avg", "HIERARCH ESO QC NORM12 AVG",""],
                       ["qcNorm13Avg", "HIERARCH ESO QC NORM13 AVG",""],
                       ["qcNorm14Avg", "HIERARCH ESO QC NORM14 AVG",""],
                       ["qcNorm23Avg", "HIERARCH ESO QC NORM23 AVG",""],
                       ["qcNorm24Avg", "HIERARCH ESO QC NORM24 AVG",""],
                       ["qcNorm34Avg", "HIERARCH ESO QC NORM34 AVG",""],
                       ["qcAmp12Avg",  "HIERARCH ESO QC AMP12 AVG",""],
                       ["qcAmp13Avg",  "HIERARCH ESO QC AMP13 AVG",""],
                       ["qcAmp14Avg",  "HIERARCH ESO QC AMP14 AVG",""],
                       ["qcAmp23Avg",  "HIERARCH ESO QC AMP23 AVG",""],
                       ["qcAmp24Avg",  "HIERARCH ESO QC AMP24 AVG",""],
                       ["qcAmp34Avg",  "HIERARCH ESO QC AMP34 AVG",""],
                       ["qcDarkMed",   "HIERARCH ESO QC DARK MED","adu"],
                       ["qcDarkRmsMed",   "HIERARCH ESO QC DARKRMS MED","adu"],
                       ["qcDarkRmsMax",   "HIERARCH ESO QC DARKRMS MAX","adu"],
                       ["qcNoiseMed",   "HIERARCH ESO QC NOISE MED","adu"],
                       ["qcNoiseMax",   "HIERARCH ESO QC NOISE MAX","adu"],
                       ["qcQualityFlag", "HIERARCH ESO QC QUALITY FLAG",""],
                       ["qcEffwave",    "HIERARCH ESO QC EFFWAVE","m"],
                       ["qcEffband",    "HIERARCH ESO QC EFFBAND","m"],
                       ["qcEffwavePtp", "HIERARCH ESO QC EFFWAVE PTP","m"]];

/* ********************************************************* */

func pndrsCheckTargetInList(str)
{
  extern pndrsTARGET_REPLACEMENT;
  strout = str;

  for (i=1;i<=numberof(str);i++) {

    /* If inlist */
    id = where(str(i)==pndrsTARGET_REPLACEMENT(1,));
    if ( numberof(id)>0 ) {
      strout(i) = pndrsTARGET_REPLACEMENT(2,id(1));
    }

    /* If HD_???? */
    if ( strglob("HD_[0-9]*",str(i)) ) {
      strout(i) = "HD"+strpart(str(i),4:);
    }

    /* If HD ???? */
    if ( strglob("HD [0-9]*",str(i)) ) {
      strout(i) = "HD"+strpart(str(i),4:);
    }
    
    /* If HR ???? */
    if ( strglob("HR [0-9]*",str(i)) ) {
      strout(i) = "HR"+strpart(str(i),4:);
    }
    
    /* If HIP_???? */
    if ( strglob("HIP_[0-9]*",str(i)) ) {
      strout(i) = "HIP"+strpart(str(i),5:);
    }

    /* If Hip ???? */
    if ( strglob("Hip [0-9]*",str(i)) ) {
      strout(i) = "HIP"+strpart(str(i),5:);
    }

    /* If HR_???? */
    if ( strglob("HR_[0-9]*",str(i)) ) {
      strout(i) = "HR"+strpart(str(i),4:);
    }

    /* If MWC_???? */
    if ( strglob("MWC_[0-9]*",str(i)) ) {
      strout(i) = "MWC"+strpart(str(i),5:);
    }

    /* If CPD_???? */
    if ( strglob("CPD_*",str(i)) ) {
      strout(i) = "CPD"+strpart(str(i),5:);
    }

    /* If GL_???? */
    if ( strglob("GL_[0-9]*",str(i)) ) {
      strout(i) = "GL"+strpart(str(i),4:);
    }

    /* If GLIESE_???? */
    if ( strglob("GLIESE_[0-9]*",str(i)) ) {
      strout(i) = "GL"+strpart(str(i),8:);
    }

    /* If GLIESE???? */
    if ( strglob("GLIESE[0-9]*",str(i)) ) {
      strout(i) = "GL"+strpart(str(i),7:);
    }

    /* If HD-???? */
    if ( strglob("HD-[0-9]*",str(i)) ) {
      strout(i) = "HD"+strpart(str(i),4:);
    }

    /* If HIP-???? */
    if ( strglob("HIP-[0-9]*",str(i)) ) {
      strout(i) = "HIP"+strpart(str(i),5:);
    }
    
    /* If HR-???? */
    if ( strglob("HR-[0-9]*",str(i)) ) {
      strout(i) = "HR"+strpart(str(i),4:);
    }
  }

  /* Remove space */
  strout = yocoStrReplace(strout," ","_");
  strout = strtrim (strout);

  return strout;
}

extern pndrsTARGET_REPLACEMENT;
pndrsTARGET_REPLACEMENT = [["EM__SR_21","EM__SR21"],
                           ["EM_SR_21","EM__SR21"],
                           ["EM_SR21","EM__SR21"],
                           ["V_1000SCO","V1000_SCO"],
                           ["V_709_CRA","V709_CRA"],
                           ["V*-eps-Peg","EPS_PEG"],
                           ["EM_SR_9","V2129_OPH"],
                           ["EM__SR9","V2129_OPH"],
                           ["EM_SR9","V2129_OPH"],
                           ["SAO-206462","SAO206462"],
                           ["SAO_206462","SAO206462"],
                           ["HD-69830-Debris","HD69830"],
                           ["HD135344B", "SAO206462"],
                           ["AS205", "AS_205A"],
                           ["kap01-Cet", "KAP01_CET"],
                           ["SS-Lep",    "SS_LEP"],
                           ["kap-Phe",   "KAP_PHE"],
                           ["T-Cha",     "T_CHA"],
                           ["HIP6867",   "GAM_PHE"],
                           ["HD9053",    "GAM_PHE"],
                           ["IDS-15544-2220","DELTA_SCO"],
                           ["beta-pic",  "BETA_PIC"],
                           ["fomalhaut", "FOMALHAUT"],
                           ["del-Aqr",   "DELTA_AQR"],
                           ["Canopus",   "CANOPUS"],
                           ["AP-Psc",    "AP_PSC"],
                           ["wezen",     "WEZEN"],
                           ["TW-Hya",    "TW_HYA"],
                           ["WW-Cha",    "WW_CHA"],
                           ["V380-Ori",  "V380_ORI"],
                           ["sig-pup",   "SIGMA_PUP"],
                           ["*-gam-Pav", "GAM_PAV"],
                           ["*-gam-Gru", "GAM_GRU"],
                           ["TAU_CETII", "TAU_CETI"],
                           ["TAU_CETIII","TAU_CETI"],
                           ["TAU_CET",   "TAU_CETI"],
                           ["TAU_CET",   "TAU_CETI"],
                           ["Tau-ceti",  "TAU_CETI"],
                           ["TAU_CET",   "TAU_CETI"],                           
                           ["TWA-3a",    "TWA_3a"],
                           ["TWA-3b",    "TWA_3b"],
                           ["V__V856_SCO","V856_SCO"],
                           ["vy-cma",    "VY_CMA"],
                           ["regulus",   "REGULUS"],
                           ["WY-Vel",    "WY_VEL"],
                           ["FU-Ori",    "FU_ORI"],
                           ["eps-eri",   "EPS_ERI"],
                           ["del-Cap",   "DELTA_CAP"],
                           ["MWC-158",   "MWC158"],
                           ["MWC_158",   "MWC158"],
                           ["*-48-Lib",  "48_LIB"],
                           ["HR_8254",   "HR8254"],
                           ["T-Tau-N",   "T_TAU_N"],
                           ["LTT-1059",  "ALF_HYI"],
                           ["Alf-Hyi",   "ALF_HYI"],
                           ["HR_8809",   "HR8809"],
                           ["iot_Psc",   "IOT_PSC"],
                           ["MWC_863",   "MWC863"],
                           ["V_2508 Oph","V2508_OPH"],
                           ["V_2508_OPH","V2508_OPH"],
                           ["HD152404",  "AK_SCO"],
                           ["HD_152404", "AK_SCO"],
                           ["HD-152404", "AK_SCO"],
                           ["TZ_For",    "TZ_FOR"],
                           ["HD 18955",  "HIP14157"],
                           ["HD18955",  "HIP14157"],
                           ["V884SCO",   "V884_SCO"]
                           ];

/* ********************************************************* */

func pndrsReadPnrLog(file)
/* DOCUMENT pndrsReadPnrLog(file)

   DESCRIPTION
   Read the Log from a PIONIER FITS file.

   PARAMETERS
   - file: input string
   - return oiLog, or 0 for an error

   EXAMPLES
   oiLog = pndrsReadPnrLog(file);
   if(oiLog==0) error,"Cannot read log for this file";

   SEE ALSO
 */
{
  yocoLogTrace,"pndrsReadPnrLog()";
  local fh;

  /* catch possible errors */
  if ( catch(0x01+0x02+0x08+0x10) ) {
      yocoLogError,"pndrsReadPnrLog catch: "+catch_message;
      yocoError, "Cannot read log for file:",file;
      return 0;
  }
  
  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file) : file );
  
  /* Read the first header */
  cfitsio_goto_hdu, fh, 1;
  oiLog = oiFitsLoadOiHdr(fh, struct_oiLog, struct_oiLogEntries);

  /* Do the "filename" manually */
  oiLog.fileName = cfitsio_file_name(fh);

  /* Check the coordinates 
     FIXME: try to correct the coordinates from the ISS ones.
     The ESO string is hard to parse. */

  /* Check if calibration OB */
  
  /* Close file and return the log */
  if( structof(file)==string ) cfitsio_close,fh;

  yocoLogTrace,"pndrsReadPnrLog done";
  return oiLog;
}

func pndrsWritePnrLog(file,oiLog)
/* DOCUMENT pndrsWritePnrLog(file,oiLog)

*/
{
  local fh, inFh, val, com, nam;

  /* Open the file and go to first HDU */
  fh = ( structof(file)==string ? cfitsio_open(file,"a") : file );
  cfitsio_goto_hdu,fh,1;

  /* Try to dump the existing keyword of the file */
  if ( yocoTypeIsFile(oiLog.fileName) ) {
    
    /* read all keywords */
    inFh  = cfitsio_open(oiLog.fileName, "r");
    cfitsio_goto_hdu,inFh,1;
    val = cfitsio_get( inFh, "*", com, nam, point=1);

    /* Write all keywords and close file.
       Deal with boolean keywords */
    for (k=1;k<=numberof(com);k++) {
      if (*val(k)=='F' && structof(*val(k))==char) {
        val(k) = &char(0);
      }

      /* Avoid propagating QC */
      if ( (strpart(nam(k),1:16) != "HIERARCH ESO QC "))          
          cfitsio_set, fh, nam(k), *val(k), com(k);
    }

    /* close file */
    cfitsio_close_file, inFh;
  }

  /* Update the data with the oiLog structure */ 
  //oiFitsWriteOiHdr, fh, oiLog, struct_oiLogEntries;

  /* Read the content of the log */
  local name, type, strName, nameUpper, units;
  oiFitsStrReadMembers, oiLog, name, type, strName;

  /* Convert to header names */
  nameUpper = oiFitsConvertOiMemberToFile(name, struct_oiLogEntries, units);

  /* loop in the structure */
  for ( i=1 ; i<=numberof(name) ; i++ ) {
    /* skip the filename */
    if ( anyof(name(i)==["logId","fileName","hdr"]) ) continue;
    /* skip if pointer */
    if ( anyof(type(i)==["pointer","struct_instance"]) ) continue;
    /* get value */
    value = get_member(oiLog,name(i));
    /* skip if exactly 0.0 or 0x0, this is to avoid
       writting all the empty stuff such as void
       QC parameters... not very clean */
    if ( anyof(type(i)==["float","double","string"]) && !value ) continue;
    /* write the value */
    cfitsio_set, fh, nameUpper(i), value,, units(i);
  }
  
  /* Eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;
  return 1;
}

/* ********************************************************* */

func pndrsWriteKappaMatrix(file,matrix,oiLog,overwrite=)
{
  yocoLogInfo,"pndrsWriteKappaMatrix()";
  if (is_void(overwrite)) overwrite=1;

  /* Open file */
  if (overwrite) remove,file;
  fh = cfitsio_open(file,"w");

  remove,file;
  fh = cfitsio_open(file,"w");
  cfitsio_add_image, fh, matrix, "KAPPA";
  cfitsio_close,fh;
  
  /* close the file */
  yocoLogTrace,"close the file";
  cfitsio_close,fh;
  
  yocoLogTrace,"pndrsWriteKappaMatrix done";
  return 1;
}

/* ********************************************************* */

func pndrsCheckFile(&file,opt,dim,msg)
/* DOCUMENT pndrsCheckFile(&file,opt,dim,msg)

   DESCRIPTION
   Private function to test a string to be a file.

   PARAMETERS
   opt=0 if file does not exist, return 0
   opt=1 if file does not exist, return 1
   opt=2 if file is void, ask the browser (should exist)

   dim=number of file:
   0: nothing is OK (return void)
   1: only 1 is OK
   [3,5]: 3 and 5 files are OK
   [-1,0]: every number is OK (max of 100), including 0

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogTrace,"pndrsCheckFile()";
  local exist, n, i;

  if (is_void(opd)) opd=2;
  if (is_void(dim)) dim=1;
  if (is_void(msg)) msg = "";
  if (anyof(dim==-1)) grow, dim, indgen(100);
  
  /* Eventually call the browser, only if plot allowed */
  if ( opt==2 && is_void(file) && pndrsBatchPlotLevel!=0 ) {
    pndrsFileChooser, msg, file;
  }

  /* test if existing */
  exist=[];
  for (i=1;i<=numberof(file);i++) grow,exist,!(!open(file(i), "r", 1));
  exist = allof(exist);

  /* error if not existing */
  if ( !exist && opt != 0 && noneof(dim==0))
  {
    yocoError, msg+" should be an exising file";
    return 0;
  }

  /* now check the dims */
  n = numberof(file);
  if ( noneof(n==dim) )
  {
    yocoError, msg+" should be "+pr1(dim)+" file(s).";
    return 0;
  }
  
  yocoLogTrace,"pndrsCheckFile done";
  return 1;
}

/* ********************************************************* */

func pndrsCheckDirectory(&dir,opt,msg,chmode=)
/* DOCUMENT pndrsCheckDirectory(&dir,opt,msg,chmode=)

   DESCRIPTION
   Private function to test a string to be a directory.
   
   PARAMETERS
   opt=0 if dir does not exist, return 0
   opt=1 if dir does not exist it is created and return 1
   opt=2 if dir is void, ask the browser (should exist)

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogTrace,"pndrsCheckDirectory()";
  local tmp;
  
  /* Eventually call the browser */
  if ( opt==2 && is_void(dir) ) {
    pndrsFileChooser, msg, dir;
    opt = 0;
  }
    
  /* if not defined properly */
  if ( !yocoTypeIsStringScalar(dir) )
  {
    yocoLogInfo, "String is incorrect";
    return 0;
  }

  /* test is existing */
  exist = open(dir, "r", 1)

  /* error or create it */
  if ( !exist && opt == 0 )
  {
    yocoLogInfo, "Directory does not exist:",dir;
    return 0;
  }
  else if ( !exist )
  {
      tmp = mkdir(dir);
      hasBeenCreated = 1;
  }

  /* replace by the real name */
  here = get_cwd(".");
  dir = cd(dir);
  cd,here;

  /* change the mode */
  if (chmode) {
    system,"chmod "+chmode+" "+dir+" > /dev/null 2>&1";
  }
  
  yocoLogTrace,"pndrsCheckDirectory done";
  return 1;
}

/* ********************************************************* */

func pndrsGetLogName(inputDir, &logName)
{
  logName = "pnlog.fits";
  return 1;
}

func pndrsGetOiDiamFileName(inputDir, &logName)
{
  logName = "calibDiam.fits";
  return 1;
}

/* ********************************************************* */

func pndrsReadLog(inputDir, &oiLog, overwrite=, save=)
/* DOCUMENT pndrsReadLog(inputDir, &oiLog, overwrite=, save=)

   DESCRIPTION
   Read the PIONIER logs contained into a logFile.

   PARAMETERS
   - inputDir : directory you want to read the logFile
   - oiLog : returned oiLog structure
   - overwrite=1: remove the existing log if any and re-read
     all FITS files, otherwise just update with new files.

   EXAMPLES

   SEE ALSO
 */
{
  local fh, logName, here, files, n, i, tmp, id, dir, m;
  n = m = 0;
  oiLog = [];

  /* Default */
  if ( is_void(overwrite) ) overwrite=0;
  if ( is_void(save) )      save=1;
  
  /* Verbose output */
  yocoLogInfo, "pndrsReadLog() for:", inputDir;

  /* Check arguments */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
    yocoError,"Check arguments.";
    return 0;
  }

  /* Get the name */
  if ( !pndrsGetLogName(inputDir, logName)) return 0;

  /* Change to the directory */
  here = get_cwd(".");
  if ( !cd(inputDir) )
  {
    yocoError,"Could not access directory:", inputDir, 1;
    return 0;
  }
  
  /* List and sort the files by name */
  files = lsdir(".", dir);
  files = files(where(strmatch(files,"fits")));
  if( is_void(files) ) { cd,here; return 1; }  
  files = files( sort(files) );

  /* Remove invisible files */
  files = files( where(files!=logName & strpart(files,1:1)!=".") );

  /* Do not process already known files */
  if ( overwrite==0 && open(logName, "r", 1) )
  {
    /* Read existing */
    oiFitsReadOiLog, logName, oiLog;

    /* Remove log entries that have no more real files */
    id = (files == oiLog.fileName(-,))(max,);
    oiLog = oiLog( where(id!=0) );
    m     = anyof( id==0 );
    
    /* Do not process existing */
    id = (files == oiLog.fileName(-,))(,max);
    files = files( where(id==0) );
  }
  
  /* Read the missing logs */
  n = numberof(files);
  for ( i=1 ; i<=n ; i++)
  {
    /* Verbose count */
    if (_yocoLogLevel>1) write,format="\r read header for FITS file %i over %i",i,n;

    /* If fails, then build a void entry */
    if ( !(tmp = pndrsReadPnrLog(files(i))) ) {
      tmp = struct_oiLog(fileName=files(i));
    }
    
    /* Grow the array*/
    grow, oiLog, tmp;
  }
  if (_yocoLogLevel>1 && n>0) write,"";

  /* If asked to not write, or if the existing log is OK */
  if ( save==0 || (n==0 && m==0) ) {
    cd,here;
    return 1;
  }

  /* Write the log, give write access the current dir to make
     this operation happen, even if directory is write protected
     (for raw data) */
  chmode = (strpart(rdline(popen("ls -l -d .",0)),3:3)!="w");
  if (chmode) system,"chmod  u+w . > /dev/null 2>&1";
  oiFitsWriteOiLog, logName, oiLog, overwrite=1;
  if (chmode) system,"chmod  u-w . > /dev/null 2>&1";

  cd,here;
  yocoLogTrace,"pndrsReadLog done";
  return 1;
}

/* ********************************************************* */

func pndrsCheckOiLog(&oiLog)
/* DOCUMENT pndrsCheckOiLog(&oiLog)

   DESCRIPTION
   This function serves to implement a check of the FITS HEADER.
 */
{
  yocoLogInfo,"pndrsCheckOiLog()";
  extern pndrsTARGET_REPLACEMENT;

  /* Loop on logs */
  for (i=1 ; i<=numberof(oiLog); i++) {

    /* Get coordinates */
    target = oiLog(i).target;
    issra  = oiLog(i).issRefRa;
    ra     = oiLog(i).raEp0;
    
    /* If on the internal source */
    if (oiLog(i).opti1Name=="MIRROR") {
      yocoLogTrace,"Internal lamp: replace "+target+" by INTERNAL";
      oiLog(i).target = "INTERNAL";
      continue;
    }

    /* If no target name, continue */
    if (target==string(0)) continue;

    /* Convert the ISS RA into degrees */
    issra = (["00000","0000","000","00","0",""])(strlen(pr1(int(issra)))) + swrite(format="%.5f",issra);
    issra = strpart(issra, 1:2)+":"+strpart(issra, 3:4)+":"+strpart(issra, 5:);
    issra = yocoStrTime(issra) / 12 * 180.0;

    /* Remove ?? */
    target = yocoStrReplace(target,"-??","");

    /* Check the distance between ISS reference and actual pointing.
       If larger than 2min of angle, issue a warning */
    if ( abs(issra-ra)*60 > 2.0 ) {
      target = ( strmatch(target,"_bad") ? target : target+"_bad" );
      yocoLogWarning,"RA and ISS.REF.RA are inconsistent in FITS HEADER","Change target name into: "+target;
      oiLog(i).target = target;
    }

    /* Check if in the list */
    id = where(target==pndrsTARGET_REPLACEMENT(1,));
    if ( numberof(id)>0 ) {
      new = pndrsTARGET_REPLACEMENT(2,id(1));
      yocoLogTrace,"Replace "+target+" by "+new;
      oiLog(i).target = new;
    }
    
    if ( strglob("HD_[0-9]*",target) ) {
      new = "HD"+strpart(target,4:);
      yocoLogTrace,"Replace "+target+" by "+new;
      oiLog(i).target = new;
    }

    if ( strglob("HIP_[0-9]*",target) ) {
      new = "HIP"+strpart(target,5:);
      yocoLogTrace,"Replace "+target+" by "+new;
      oiLog(i).target = new;
    }
    
    if ( strglob("HD-[0-9]*",target) ) {
      new = "HD"+strpart(target,4:);
      yocoLogTrace,"Replace "+target+" by "+new;
      oiLog(i).target = new;
    }

    if ( strglob("HIP-[0-9]*",target) ) {
      new = "HIP"+strpart(target,5:);
      yocoLogTrace,"Replace "+target+" by "+new;
      oiLog(i).target = new;
    }
    
         
  }

  yocoLogTrace,"pndrsCheckOiLog done";
  return 1;
}

/* ********************************************************* */

func pndrsReadRawFiles(files, &imgData, &imgLog, append=, processDetector=)
/* DOCUMENT pndrsReadRawFiles(files, &imgData, &imgLog, append=, processDetector=)

   DESCRIPTION
   Read a RAW PIONIER FITS file and fill the structures imgData and
   imgLog.

   PARAMETERS:
   - files : list of files to be read
   - append=1, append the data to the already existing imgData and imgLog
     structures, otherwise overwrite them.
   - imgData and imgLog: returned structures.

   SEE ALSO
*/
{
  yocoLogInfo,"pndrsReadRawFiles()";
  local _imgData, _imgLog, n, i, y0, mjd, lbd, ids;

  if ( !pndrsCheckFile(files,2,[-1]) ) {
    yocoError,"Check arguments of pndrsReadRawFiles.";
    return 0;
  }

  /* if append if nil, we erase the current data */
  if (!append) {
    imgData = imgLog = [];
    addRef=0;
  } else {
    yocoLogInfo,"New data will be append to previous one.";
  }

  /* Loop on the files */
  n = numberof(files)
  for ( i=1 ; i<=n ; i++ ) {

    /* catch possible errors */
    // if (catch(0x01+0x02+0x08+0x10)) {
    //   yocoLogError,"pndrsReadRawFiles catch: "+catch_message;
    //   yocoLogError,"Cannot load file:",files(i);
    //   continue;
    // }
    
    /* if verbose */
    if (_yocoLogLevel>1 && n>1)
    write,format="\r read file %i over %i",i,n;

    /* read the file  */
    fh = cfitsio_open( files(i) );
    _imgLog  = pndrsReadPnrLog(fh);
    _imgData = imgFitsReadImgData(fh,force_array=1);
    cfitsio_close_file, fh;

    /* If MJD-OBS available in header, recompute the MJD
       Recombpute MJD for data (FIXME: bug in PIONIER OS) */
    if ( _imgData.mjdObs > 55000.0 ) {
      mjd = *_imgData.time;
      // mjd = ( mjd - median(mjd) ) + _imgData.mjdObs;
      mjd = ( mjd - mjd(1) ) + _imgData.mjdObs;
      _imgData.time = &(mjd);
    }

    /* eventually already process the detector, to save memory space */
    if (processDetector) {
      pndrsProcessDetector, _imgData, _imgLog;
    }

    /* ensure logId is unique and grow */
    _imgLog.logId  = ( is_array(imgLog) ? max(imgLog.logId) : 0 ) + 1;
    _imgData.hdr.logId  = _imgLog.logId;

    /* Find the correlation map,
       Case ABCD or AC beam combiner in H-band
       Also deal with the polarisation. */
    y0   = pndrsParseSubwin(_imgLog.detSubwin1)(0);
    woll = pndrsGetWoll(_imgLog);

    /* Determine the number of DARK window,
       in the case of RAPID detector generaly */
    nd = (_imgLog.detSubwins % 12);
    yocoLogTrace,"Number of DARK window: "+pr1(nd);
    _imgLog.nbDarkWins = nd;
    
    if ( _imgLog.obc == string() || _imgLog.obc == "" ||
         strmatch(_imgLog.obc,"ABCD-H") ) {
      if (_imgLog.detSubwins == (24+nd) && woll=="FREE") {
        _imgLog.correlation = &mapABCD_H; }
      else if (_imgLog.detSubwins == (48+nd) && woll=="WOLL")
        _imgLog.correlation = &mapABCD_Hpol;
      else if (_imgLog.detSubwins == (24+nd) && woll=="WOLL" && y0 >= _imgLog.detYref)
        _imgLog.correlation = &mapABCD_Hup;
      else if (_imgLog.detSubwins == (24+nd) && woll=="WOLL" && y0 < _imgLog.detYref)
        _imgLog.correlation = &mapABCD_Hdown;
      else if (_imgLog.detSubwins == (12+nd) && woll=="FREE")
        _imgLog.correlation = &mapABCD_H_AC;
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && y0 >= _imgLog.detYref)
        _imgLog.correlation = &mapABCD_H_ACup;
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && y0 < _imgLog.detYref)
      _imgLog.correlation = &mapABCD_H_ACdown;
    }
    else if ( strmatch(_imgLog.obc,"AC-H") &&
              strmatch(_imgLog.detName,"RAPID") ) {
      x0   = pndrsParseSubwin(_imgLog.detSubwin1)(0);
      if (_imgLog.detSubwins == (12+nd) && woll=="FREE")
        _imgLog.correlation = &(mapACbeti_H);
      else if (_imgLog.detSubwins == (24+nd) && woll=="WOLL")
        _imgLog.correlation = &(mapACbeti_Hpol);
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && x0 >= _imgLog.detXref)
        _imgLog.correlation = &(mapACbeti_Hup);
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && x0 < _imgLog.detXref)
        _imgLog.correlation = &(mapACbeti_Hdown);
    }
    else if ( strmatch(_imgLog.obc,"AC-H") ) {
      if (_imgLog.detSubwins == (12+nd) && woll=="FREE")
        _imgLog.correlation = &mapAC_H;
      else if (_imgLog.detSubwins == (24+nd) && woll=="WOLL")
        _imgLog.correlation = &mapAC_Hpol;
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && y0 >= _imgLog.detYref)
        _imgLog.correlation = &mapAC_Hup;
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && y0 < _imgLog.detYref)
        _imgLog.correlation = &mapAC_Hdown;
    }
    else if ( strmatch(_imgLog.obc,"ABCD-K") ) {
      if (_imgLog.detSubwins == (24+nd) && woll=="FREE")
        _imgLog.correlation = &mapABCD_K;
      else if (_imgLog.detSubwins == (48+nd) && woll=="WOLL")
        _imgLog.correlation = &mapABCD_Kpol;
      else if (_imgLog.detSubwins == (24+nd) && woll=="WOLL" && y0 >= _imgLog.detYref)
        _imgLog.correlation = &mapABCD_Kup;
      else if (_imgLog.detSubwins == (24+nd) && woll=="WOLL" && y0 < _imgLog.detYref)
        _imgLog.correlation = &mapABCD_Kdown;
      else if (_imgLog.detSubwins == (12+nd) && woll=="FREE")
        _imgLog.correlation = &mapABCD_K_AC;
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && y0 >= _imgLog.detYref)
        _imgLog.correlation = &mapABCD_K_ACup;
      else if (_imgLog.detSubwins == (12+nd) && woll=="WOLL" && y0 < _imgLog.detYref)
      _imgLog.correlation = &mapABCD_K_ACdown;
    }

    /* If correlation in not known */
    if (is_void( *_imgLog.correlation )) {
      yocoLogWarning,"Cannot recover the correlation map.";
      yocoLogInfo,"detSubwins="+pr1(_imgLog.detSubwins);
      yocoLogInfo,"nDarkWin="+pr1(nd);
      yocoLogInfo,"obc="+pr1(_imgLog.obc);
      yocoLogInfo,"detName="+pr1(_imgLog.detName);
    }

    /* Hack for the case of observation with SMALL but with
       the 7-channels, not SMALL-3 */
    prism = pndrsGetPrism(_imgLog);
    dy = pndrsParseSubwin(_imgLog.detSubwin1)(2);
    if (prism=="SMALL" && dy==7) {
      yocoLogWarning,"SMALL prism with 7 channels -> replaced by SMALL-3";
      _imgData.regdata = &( (*_imgData.regdata)(,3:5,) );
    }

    /* Hack for the data from IPAG */
    if ( strmatch(_imgLog.detName,"RAPID") && _imgLog.origin=="TEST"  ) {
      yocoLogInfo,"Change target to INTERNAL";
      _imgLog.target="INTERNAL";
    }

    /* Hack the LOCALOPD which was stored in OPD before 2015-08-25.
       Thus swap them. The correct place is LOCALOPD. */
    if ( _imgLog.mjdObs < 57261.9 || _imgLog.instrument == "BETI") {
      yocoLogTrace,"LOCALOPD was stored in OPD";
      lopd = _imgData.localopd;
      opd  = _imgData.opd;
      _imgData.localopd = opd;
      _imgData.opd = lopd;
    } else {
      yocoLogTrace,"LOCALOPD is now stored in LOCALOPD";
    }

    /* Test LOCALOPD */
    if ( max(*_imgData.localopd)==0 )
      yocoLogWarning,"LOCALOPD is zero.";
    
    /* Simulate DATA */
    if ( strmatch( pndrsVersion,"sim") ) {
      yocoLogWarning,"!!! SIMULATE DATA !!!";
      pndrsSimImgData, _imgData, _imgLog;
    }

    /* Append to already load data */
    grow, imgLog, _imgLog;
    grow, imgData, _imgData;
  }
  /* Add a line */
  if (_yocoLogLevel>1 && n>1)  write,"";

  /* If nothing could be read, return 0 */
  if (!is_array(imgData)) {
    yocoError,"Cannot load files.";
    return 0;
  }

  /* if scalar, return scalar */
  if (dimsof(files)(1)==0 && !append) { imgLog = imgLog(1); imgData = imgData(1); }

  /* end functions */
  yocoLogTrace,"pndrsReadRawFiles done";
  return 1;
}
/* ********************************************************* */

func pndrsReadKappaMatrix(&matrix, &sig2matrix, &matrixRaw, &sig2matrixRaw,
                          inputMatrixFile=, readExtension=)
{
  yocoLogTrace,"pndrsReadKappaMatrix()";
  
  /* Init */
  matrix = sig2matrix = matrixRaw = sig2matrixRaw = [];
  
  /* Verbose */
  yocoLogInfo,"Read the KAPPA_MATRIX file:", inputMatrixFile;

  /* Open and load data */
  fh = cfitsio_open(inputMatrixFile,"r");
  cfitsio_goto_hdu, fh, "PNDRS_MATRIX";
  cfitsio_read_image, fh, matrix;

  /* Eventually load extensions */
  if (readExtension) {
    yocoLogTrace," read extensions";
    cfitsio_goto_hdu, fh, "PNDRS_MATRIX_ERR";
    cfitsio_read_image, fh, sig2matrix;
    cfitsio_goto_hdu, fh, "PNDRS_MATRIX_RAW";
    cfitsio_read_image, fh, matrixRaw;
    cfitsio_goto_hdu, fh, "PNDRS_MATRIX_RAW_ERR";
    cfitsio_read_image, fh, sig2matrixRaw;
  }

  /* Close file */
  cfitsio_close, fh;

  /* Check if old format */
  dim = dimsof(matrix);
  if ( dim(1)== 3) {
    yocoLogTrace,"New format for matrix";
  }
  else if ( dim(1)==5 && dim(3)==1 && dim(4)==1 ) {
    yocoLogTrace,"Old format for matrix, update";
    matrix = matrix(,1,1,,);
    if (is_array(sig2matrix))    sig2matrix = sig2matrix(,1,1,,);
    if (is_array(matrixRaw))     matrixRaw = matrixRaw(,1,1,,);
    if (is_array(sig2matrixRaw)) sig2matrixRaw = sig2matrixRaw(,1,1,,);
  }
  else {
    yocoError,"Unknown format for matrix !!";
    return 0;
  }
  
  yocoLogTrace,"pndrsReadKappaMatrix done";
  return 1;
}

/* ********************************************************* */

func pndrsReadClockPattern(file, &time, &pattern, &colName)
/* DOCUMENT pndrsReadClockPattern(file, &time, &pattern, &colName)

   DESCRIPTION
   Read the clock_pattern file generated by the PICNINC detector
   at each new setup. The pattern contains the clocks:
   RST, READ, DPIX, CONV, FSYNC, LSYNC, LINE, PIX

   PARAMETERS
   - file: scalar string
   - time(t)         : time in mus (double)
   - pattern(t,ncol) : pattern (int)
   - colName(ncol)   : titles of each clock (string)

   EXAMPLES
   > pndrsReadClockPattern,,time, pattern, titles;
   > yocoPlotPlgMulti, pattern, time;
   > titles;
 */
{
  yocoLogInfo,"pndrsReadClockPattern()";
  require,"textload.i";
  local cells;

  /* Select the file */
  if ( !pndrsCheckFile(file,2,1,"Select clock_pattern file")) {
    yocoError,"Check arguments of pndrsReadClockPattern.";
    return 0;
  }
  
  /* Read the file */
  cells = strtrim(text_cells(file,"\t"));

  /* Extract data and titles */
  colName = cells(2:,1);
  time    = tonum( cells(1,2:) );
  pattern = transpose( int( tonum( cells(2:,2:)) ) );
  
  yocoLogTrace,"pndrsReadClockPattern done";
  return 1;
}

/* ********************************************************* */

local pndrsGetSetupDark;
local pndrsGetSetupMatrix;
local pndrsGetSetup;
local pndrsGetShutters;
local pndrsGetWindows;     
/* DOCUMENT pndrsGetSetupDark(imgData, imgLog)  
            pndrsGetSetupMatrix(imgData, imgLog)
            pndrsGetSetup(imgData, imgLog)
            pndrsGetShutters(imgData, imgLog)
            pndrsGetWindows(imgData, imgLog)

   pndrsGetSetup:
   define the files that can be associated for visibility calibration.
   
   pndrsGetSetupDark:
   define the files that can be associated for detector calibration
   
   pndrsGetSetupMatrix:
   define the files that can be associated for kappa matrix calibration

   FIXME: add a capability to put the progId in the setup,
   so that Paranal can classify on CAL-SCI-CAL... sequence.
            
   DESCRIPTION
   Return string that define some setups.
*/

func pndrsGetSetup(oiData,oiLog)
{
  local log, insName;

  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) )     return yocoError("oiLog not valid");

  /* Look for the log and the insName. */
  if ( is_array(oiData) ) {
    if( oiFitsIsOiData(oiData)        ) insName = oiData.hdr.insName;
    else if ( oiFitsIsImgData(oiData) ) insName = oiData.instrument;
    else return yocoError("oiData not valid");
    log = oiFitsGetOiLog(oiData,oiLog);
    } else {
    log = oiLog;
    insName = log.instrument;
  }

  /* Recover the log */
  setup = swrite(format="%s-%s-%s-%s %s %.2fms %dmV %i %s:%dx%d %.0f,%.0f,%.0f,%.0f C:%i",
                 insName,
                 pndrsGetPrism(log),
                 pndrsGetWoll(log),
                 pndrsGetFilter(log),
                 pndrsGetWindows(,log),
                 log.detDit * 1000.0,
                 log.detPolar,
                 log.scanStatus,
                 log.detMode,
                 log.detNspx,
                 log.scanNreads,
                 log.dl1Stroke*1e6,log.dl2Stroke*1e6,log.dl3Stroke*1e6,log.dl4Stroke*1e6,
                 log.obsContId);

  /* Add some information about the ISS config */
  setup+=  swrite(format=" %s%s%s%s",log.issStation1,log.issStation2,log.issStation3,log.issStation4);

  /* return the string */
  return setup;
}

func pndrsGetSetupSimple(oiData,oiLog)
{
  local log, insName;
  yocoLogInfo, "pndrsGetSetupSimple()";

  setup = array("PIONIER_no_setup",dimsof(oiData));

  /* return the string */
  return setup;
}

func pndrsGetSetupDark(oiData,oiLog)
{
  local log, insName;
  local detmode, win;

  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) )     return yocoError("oiLog not valid");

  if ( is_array(oiData) ) {
    if( oiFitsIsOiData(oiData)        ) insName = oiData.hdr.insName;
    else if ( oiFitsIsImgData(oiData) ) insName = oiData.hdr.instrument;
    else return yocoError("oiData not valid");
    log = oiFitsGetOiLog(oiData,oiLog);
    } else {
    log = oiLog;
    insName = log.instrument;
  }

  /* detector windowing */
  win = pndrsGetWindows(,log);

  /* Recover the log */
  setup = swrite(format="%s %s %.2fms %dmV %i %s:%dx%d",
                 insName, win,
                 log.detDit * 1000.0,
                 log.detPolar,
                 log.scanStatus,
                 log.detMode,
                 log.detNspx,
                 log.scanNreads);

  /* return the string */
  return setup;
}

func pndrsGetSetupMatrix (oiData,oiLog)
{
  local log, insName, win;

  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) ) return yocoError("oiLog not valid");

  if ( is_array(oiData) ) {
    if( oiFitsIsOiData(oiData)        ) insName = oiData.hdr.insName;
    else if ( oiFitsIsImgData(oiData) ) insName = oiData.hdr.instrument;
    else return yocoError("oiData not valid");
    log = oiFitsGetOiLog(oiData,oiLog);
    } else {
    log = oiLog;
    insName = log.instrument;
  }

  /* detector windowing */
  win = pndrsGetWindows(,log);

  /* Recover the log */
  setup = swrite(format="%s-%s-%s-%s %s %dmV %i %s",
                 insName,
                 pndrsGetPrism(log),
                 pndrsGetWoll(log),
                 pndrsGetFilter(log),
                 win,
                 log.detPolar,
                 // (log.detDit<1e-3),
                 log.scanStatus,
                 log.detMode);
  
  /* return the string */
  return setup;
}

func pndrsGetSetupSpectralCalib(oiData,oiLog)
{
  local log, insName;

  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) ) return yocoError("oiLog not valid");

  /* Look for the log and the insName. */
  if ( is_array(oiData) ) {
    if( oiFitsIsOiData(oiData)        ) insName = oiData.hdr.insName;
    else if ( oiFitsIsImgData(oiData) ) insName = oiData.hdr.instrument;
    else return yocoError("oiData not valid");
    log = oiFitsGetOiLog(oiData,oiLog);
    } else {
    log = oiLog;
    insName = log.instrument;
  }

  /* Recover the log */
  setup = swrite(format="%s-%s-%s-%s %s",
                 insName,
                 pndrsGetPrism(log),
                 pndrsGetWoll(log),
                 pndrsGetFilter(log),
                 pndrsGetWindows(,log));
  
  /* return the string */
  return setup;
}

func pndrsIsSpectralCalib(oiLog)
{
  local strokeMax, strokeMin, spx;
  
  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) ) return yocoError("oiLog not valid");

  /* Just read the DPR */
  isValidNew = strmatch(oiLog.dprType,"WAVE");

  /* Compute the sampling and the stoke */
  strokeMax = abs(max(oiLog.dl1Stroke,oiLog.dl2Stroke,oiLog.dl3Stroke,oiLog.dl4Stroke));
  strokeMin = abs(min(oiLog.dl1Stroke,oiLog.dl2Stroke,oiLog.dl3Stroke,oiLog.dl4Stroke));
  spx       = oiLog.scanNreads / (max(strokeMax,1e-6) / 1.5e-6);

  isValidOld = (oiLog.opti1Name=="MIRROR") &
    (pndrsGetShutters(,oiLog) == "1111") &
    (oiLog.scanStatus==1) &
    (strokeMin>40e-6) &
    (spx>4.0);

  /* Look for files that can be used as spectral calibrations */
  return isValidOld * (oiLog.mjdObs<57280.5) + isValidNew * (oiLog.mjdObs>=57280.5);
}


func pndrsIsOnSky(oiLog)
{
  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) ) return yocoError("oiLog not valid");
  
  return (oiLog.opti1Name!="MIRROR");
}

func pndrsGetWoll(oiLog)
{
  /* Note that we changed from OPTI3 to OPTI2 in 57263*/
  woll = ( ( (oiLog.opti4Name=="WOLL") +
             (oiLog.opti3Name=="WOLL") +
             (oiLog.opti3Name=="GRI+WOL") ) * (oiLog.instrument != "BETI" & oiLog.mjdObs<=57263) +
           ( (oiLog.opti2Name=="WOLL") +
             (oiLog.opti2Name=="GRI+WOL") ) * (oiLog.instrument != "BETI" & oiLog.mjdObs>57263) +
           ( (oiLog.opti1Name=="WOLL") +
             (oiLog.opti1Name=="PRI+WOL") ) * (oiLog.instrument == "BETI") );
  
  return ["FREE","WOLL"](1+woll);
}

func pndrsGetPrism(oiLog)
{
  /* Note that we changed from OPTI3 to OPTI2 in 57263*/
  prism = ( ( 1*(oiLog.opti3Name=="FREE") +
              2*(oiLog.opti3Name=="SMALL") +
              3*(oiLog.opti3Name=="LARGE") + 
              4*(oiLog.opti3Name=="GRISM") +
              4*(oiLog.opti3Name=="GRI+WOL") ) * (oiLog.instrument != "BETI" & oiLog.mjdObs<=57263) +
            ( 1*(oiLog.opti2Name=="FREE") +
              4*(oiLog.opti2Name=="GRISM") +
              4*(oiLog.opti2Name=="GRI+WOL") ) * (oiLog.instrument != "BETI" & oiLog.mjdObs>57263) +
            ( 1*(oiLog.opti1Name=="FREE") +
              4*(oiLog.opti1Name=="GRISM") +
              4*(oiLog.opti1Name=="GRI+WOL") ) * (oiLog.instrument == "BETI") );
  
  return ["UNKNOWN","FREE","SMALL","LARGE","GRISM"](1+prism);
}

func pndrsGetBand(oiLog)
{
  // FIXME: deal with the filter directly in the OS
  return merge2(array("H",dimsof(oiLog)), oiLog.fil1Name,
                oiLog.detName=="RAPID");
}

func pndrsGetFilter(oiLog)
{
  // FIXME: deal with the filter directly in the OS
  return merge2(array("H",dimsof(oiLog)), oiLog.fil1Name+"-"+oiLog.fil2Name,
                oiLog.detName=="RAPID");
}

func pndrsGetShutters(oiData,oiLog)
{
  local log;

  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) )     return yocoError("oiLog not valid");

  /* Recover the log */
  if ( is_array(oiData) ) {
    if( !oiFitsIsOiDataOrImgData(oiData) ) return yocoError("oiData not valid");
    log = oiFitsGetOiLog(oiData,oiLog);
  } else {
    log = oiLog;
  }

  /* Return the string of the shutters*/
  return swrite(format="%i%i%i%i",log.shut1,log.shut2,log.shut3,log.shut4);
}

func pndrsGetWindows(oiData,oiLog)
{
  local log;

  /* Check parameters */
  if( !oiFitsIsOiLog(oiLog) )     return yocoError("oiLog not valid");

  /* Recover the log */
  if ( is_array(oiData) ) {
    if( !oiFitsIsOiDataOrImgData(oiData) ) return yocoError("oiData not valid");
    log = oiFitsGetOiLog(oiData,oiLog);
  } else {
    log = oiLog;
  }
  
  /* Return the string */
  return swrite(format="[%s]x%d",log.detSubwin1,log.detSubwins);
}

func pndrsParseSubwin(subwin,&dx,&dy,&x0,&y0)
{
  dx=dy=x0=y0=array(long,dimsof(subwin));
  sread, subwin, format="%ix%i+%i+%i",dx,dy,x0,y0;
  return [dx,dy,x0,y0];
}

func pndrsTimeMjdToWsUtc( mjd )
/* DOCUMENT utc = pndrsTimeMjdToWsUtc( mjd )

   Convert back the MJD time stored in the column TIME of the RAW DATA
   in the UTC of the WS machine. This is the exact invers function as
   the one coded in the WS:

   mjd =  2440587.5 + (t->tv_sec + (t->tv_usec/1000000.0) ) /86400.0 ;
   mjd -= 2400000.5;
   return mjd;

   By default, it return UTC in seconds since 1970-01-01T00:00:00.000.

   FIXME:
   The WS is supposed to be aligned to true UTC within ~20ms.
   However the mess of the leap second in unclear.
*/
{
  yocoLogTrace,"pndrsTimeMjdToWsUtc()";
  local utc;

  /* UTC in seconds since 1970-01-01T00:00:00.000 */
  utc = ( double(mjd) + 2400000.5 - 2440587.5 ) * 86400.0;

  yocoLogTrace,"pndrsTimeMjdToWsUtc done";
  return utc;
}

func pndrsGetTransferFunction(oiTarget, &oiLog, oiWave, oiVis2, catalogFile=)
/* DOCUMENT pndrsGetTransferFunction(oiTarget, &oiLog, oiWave, oiVis2, catalogFile=)

   Browse the catalog to search Hdiam and Hmag, fill the QC parameters.
   Then compute Transfer Function and fill the QC parameters.
*/
{
  yocoLogInfo,"pndrsGetTransferFunction()";
  local oiVis2Tf, oiDiam;

  /* Get diameter and Hmag from catalog */
  oiFitsLoadOiDiamFromCatalogs, oiTarget, oiDiam, catalogFile=catalogFile;

  /* If cannot find diameter */
  if ( !is_array(oiDiam) ) return 1;

  /*  Add these information in QC parameters */
  oiLog.qcDbDiam    = oiDiam(1).diam;
  oiLog.qcDbDiamErr = oiDiam(1).diamErr;
  oiLog.qcDbHmag    = oiDiam(1).Hmag;
  oiLog.qcDbRmag    = oiDiam(1).Vmag;

  /* Verbose */
  yocoLogInfo," numberof oiVis2="+totxt(numberof(oiVis2));

  /* Compute transfer function */
  oiFitsExtractTf, oiVis2, oiWave, oiDiam, oiVis2Tf;
    
  /*  Add these information in QC parameters */
  for (i=1;i<=numberof(oiVis2Tf);i++) {
    iss = pndrsPionierToIss(oiLog, oiVis2Tf(i).staIndex);
    iss = totxt(iss(sort(iss)))(sum);
    pndrsSetLogInfo, oiLog, "qcTfVis%sAvg", iss, (*oiVis2Tf(i).vis2Data)(avg);
  }
    
  yocoLogTrace,"pndrsGetTransferFunction done.";
  return 1;
}  

func pndrsGetTransmission(flux, &oiLog, &trans, &inputNormFlux)
/* DOCUMENT pndrsGetTransmission, flux, oiLog, trans, inputNormFlux

   Compute the qc parameters qcTrans

   PARAMETER
   - flux
   - inputNormFlux is the input flux in e/s/m2
   - trans is the corresponding transmission computed with the
     oiLog.qcDbHmag values
*/
{
  yocoLogInfo,"pndrsGetTransmission()";
  local dit, nopd, iss, diam,flux0;
  trans = 0.0;

  /* Get iss numbers */
  
  iss = totxt( pndrsPionierToIss(oiLog, [1,2,3,4]) );

  /* Compute mean flux. Sum-up both
     polarisation */
  flux0  = flux(avg,*,);
  if (dimsof(flux0)(0) > 4)
    flux0 = flux0(,1:4) + flux0(,5:8);
    
  /* Flux adu/pixel/read/tel */
  yocoLogInfo," add QC parameters about flux in adu";
  pndrsSetLogInfo, oiLog, "qcFlux%sAvg", iss, flux0(avg,);
  pndrsSetLogInfo, oiLog, "qcFlux%sRms", iss, flux0(rms,);
  pndrsSetLogInfo, oiLog, "qcFlux%sMax", iss, flux0(max,);

  /* If two polarisation, we save the spectrum */
  if (dimsof(flux)(0) > 4) {
    yocoLogInfo," set polarised flux in header";
    fp1 = flux(,avg,avg,1:4) / flux0(avg,-,);
    fp2 = flux(,avg,avg,5:8) / flux0(avg,-,);
    for (t=1;t<=4;t++) {
      tmp = strpart(sum(totxt(fp1(,t),"%.4f")+","),1:-1);
      yocoLogInfo, "qcFluxP1 = "+tmp;
      pndrsSetLogInfo, oiLog, "qcFlux%sP1", iss(t), tmp;
      tmp = strpart(sum(totxt(fp2(,t),"%.4f")+","),1:-1);
      yocoLogInfo, "qcFluxP2 = "+tmp;
      pndrsSetLogInfo, oiLog, "qcFlux%sP2", iss(t), tmp;
    }
  }

  /* Compute decile */
  n = dimsof(flux0)(2);
  for (t=1;t<=4;t++) {
    f = boxcar(flux0(,t),2);
    s = sort (f);
    p05 = f(s(int(n*0.05)));
    p95 = f(s(int(n*0.95)));
    pndrsSetLogInfo, oiLog, "qcFlux%sP05", iss(t), p05;
    pndrsSetLogInfo, oiLog, "qcFlux%sP95", iss(t), p95;
    pndrsSetLogInfo, oiLog, "qcFlux%sP05P95", iss(t), p05 / p95;
    pndrsSetLogInfo, oiLog, "qcFlux%sP50", iss(t), f(s(int(n*0.5)));

    f = max(f,0) / max(f(max,-,),0.01) * 100;
    h = swrite(format="%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f",
	       f(s(int(n*0.1))), f(s(int(n*0.2))), f(s(int(n*0.3))), f(s(int(n*0.4))), f(s(int(n*0.5))), 
	       f(s(int(n*0.6))), f(s(int(n*0.7))), f(s(int(n*0.8))), f(s(int(n*0.9))));

    yocoLogInfo,"Set histogram in header";
    pndrsSetLogInfo, oiLog, "qcFlux%sHisto", iss(t), h;
 }

  /* inputFlux adu/read/tel */
  inputFlux = flux(sum,avg,avg,)*12;

  /* Get effective DIT */
  dit  = oiLog.detDit;
  nopd = dimsof(flux)(3);
  dit  = (oiLog.detMode=="FOWLER" ? dit/nopd : dit );
  
  /* Get GAIN */
  if (oiLog.detName=="RAPID")
    gain = interp([7.69,2.86,1.11],[7100,5000,3000.0],oiLog.detPolar);
  else
    gain = 0.4;

  /* Telescope diameter */
  diam = strmatch( [oLog.issStation1, oLog.issStation2, oLog.issStation3, oLog.issStation4], "U");
  diam = [1.8,8](diam+1);

  /* Check if double polar */
  if (numberof(inputFlux)>numberof(diam)) {
    inputFlux = inputFlux(:4) + inputFlux(5:);
  }

  /* Compute input flux e/s/m2 */
  inputNormFlux = inputFlux / dit / gain / (pi * (diam/2)^2 );

  /* Compute transmission if the Hmag is known */
  if (oiLog.qcDbHmag)
  {
    /* Compute transmission in Hband */
    trans = inputNormFlux / ( 2.89246e+09 * 10^(-oiLog.qcDbHmag/2.5) );
    yocoLogInfo," add QC parameters about transmission (%):",trans*100;
    
    /* Fill QC parameter */
    pndrsSetLogInfo, oiLog, "qcTrans%s", iss, trans;
  }

  yocoLogTrace,"pndrsGetTransmission done.";
  return 1;
}

func pndrsGetPolNtelInMap(map)
{
  local ntel, npol;
  npol = numberof( yocoListClean( map.pol ));
  ntel = max(grow(map.t1,map.t2));
  return ntel*npol;
}

func pndrsGetNtelInMap(map)
{
  local ntel, npol;
  ntel = max(grow(map.t1,map.t2));
  return ntel;
}

func pndrsGetPolTelInMap(map,id,tel)
/* DOCUMENT t1 = pndrsGetPolTelInMap(map,id,tel)

   Return the telescope id, when considering the two polarisations
   as two different telescopes.
*/
{
  local out, ntel;
  ntel = max(max(map.t1,map.t2));

  if (tel==1) out = map(id).t1;
  if (tel==2) out = map(id).t2;
  out += ntel * (map(id).pol != map(1).pol );

  return out;
}

func pndrsGetRealName(dir)
/* DOCUMENT pndrsGetRealName(dir)

   DESCRIPTION
   Return the complete pathname for the directory.
   
   EXAMPLES
   > pndrsGetRealName(".")
   "/Volumes/Datas/lebouquj/Software/sources/pndrs/src/"
 */
{
  local here, real;
  here = get_cwd();
  real = cd(dir);
  cd,here;
  return (real==[] ? dir : real); 
}

/* -- */

local pndrsGetAltAz;
local pndrsGetAlt;
local pndrsGetAz;
/* DOCUMENT pndrsGetAltAz(oiData, oiLog)
            pndrsGetAlt(oiData, oiLog)
            pndrsGetAz(oiData, oiLog)

   Return the altitude/azimuth at the time of observation.
*/

func pndrsGetAltAz(oiData,oiLog) {
  yocoLogTrace,"pndrsGetAltAz";
  oLog = oiFitsGetOiLog(oiData,oiLog);
  return (oLog.issAlt + oLog.issAz + 12.98)%360.0;
}
oiFitsGetAltAz = pndrsGetAltAz;

func pndrsGetAlt(oiData,oiLog) {
  yocoLogTrace,"pndrsGetAlt";
  oLog = oiFitsGetOiLog(oiData,oiLog);
  return (oLog.issAlt)%360.0;
}
oiFitsGetAlt = pndrsGetAlt;

func pndrsGetAz(oiData,oiLog) {
  yocoLogTrace,"pndrsGetAz";
  oLog = oiFitsGetOiLog(oiData,oiLog);
  return (oLog.issAz)%360.0;
}
oiFitsGetAz = pndrsGetAz;

/* -- */

func pndrsGetAmbi(imgLog, &fwhm, &tau0)
/* DOCUMENT pndrsGetAmbi(imgLog, &fwhm, &tau0)

   Return ambiant conditions from the log:
   fwhm in [seconds]
   tau0 in [ms]
*/
{
  /* Make best average of existing values */
  fwhm = (imgLog.issFwhmStart * (imgLog.issFwhmStart>0) + imgLog.issFwhmEnd * (imgLog.issFwhmEnd>0)) /
    ((imgLog.issFwhmStart>0) + (imgLog.issFwhmEnd>0) + 1e-20);
  
  /* Make best average of existing values */
  tau0 = (imgLog.issTau0Start * (imgLog.issTau0Start>0) + imgLog.issTau0End * (imgLog.issTau0End>0)) * 1e3 /
    ((imgLog.issTau0Start>0) + (imgLog.issTau0End>0) + 1e-20);

  /* Put values for internal lamp */
  tau0 += 100.0 * (imgLog.target=="INTERNAL");
    
  return fwhm;
}

func pndrsGetScanningSpeed(oLog)
/* DOCUMENT pndrsGetScanningSpeed(oLog)

   Return the scanning speed in mu/2 of each baseline.
   This is OPD speed.
 */
{
  local map, vel;
  yocoLogTrace,"pndrsGetScanningSpeed()";
  
  if (numberof(oLog)>1) error;

  /* Get the map */
  map  = *oLog.correlation;
  
  /* Piezo speed in m/s */
  vel = [oLog.dl1Vel,oLog.dl2Vel,oLog.dl3Vel,oLog.dl4Vel] *
    sign([oLog.dl1Stroke,oLog.dl2Stroke,oLog.dl3Stroke,oLog.dl4Stroke]);

  /* OPD modulation speed, factor 2x comes from Mirror -> OPD */
  vel = 2. * vel([map.t1,map.t2])(,dif)(,1);
  
  yocoLogTrace,"Scanning speed is = "+pr1(vel*1e6)+" mu/s";
  yocoLogTrace,"pndrsGetScanningSpeed done";
  return vel;
}

func pndrsGetPicWidthFromTau0(oLog, &sigB, &tauB, checkUTs=)
/* DOCUMENT pndrsGetPicWidthFromTau0(oLog, &sigB, &tauB)

   Return the expected width of the interferometric pic
   in frequency space, in [m-1].

   SEE ALSO: pndrsGetPicWidth
 */
{
  local lbdB, lbd0, vel, sig0, fwhm, tau0, sigB, tauB, sigT;
  yocoLogInfo,"pndrsGetPicWidthFromTau0()";
    
  /* Default Wave */
  pndrsGetDefaultWave, oLog, lbd0, lbdB;

  /* Read ambient conditions */
  pndrsGetAmbi, oLog, fwhm, tau0;
  if ( tau0<=0 ) {
    yocoLogWarning,"tau0 is missing, please fill it (use 3ms) !!";
    tau0 = 3.0;
  }

  /* Check if UTs */
  base = swrite(format="%s%s%s%s",oLog.issStation1,
                oLog.issStation2,oLog.issStation3,oLog.issStation4);
  
  if ( base == "U1U2U3U4" && checkUTs) {
    yocoLogInfo,"Observation with UTs... force tau0 to 1ms !!";
    tau0 = 1.0;
  }
  
  /* Piezo speed */
  vel = pndrsGetScanningSpeed(oLog);
  
  /* Define the theoretical width of the pic */
  sigB = lbdB/lbd0^2;

  /* Define the theoretical width of the pic */
  tauB = 0.5 * (0.5e-6/lbd0(avg))^(6./5.) / ( abs(vel) * tau0*1e-3 );

  /* Some logging */
  // yocoLogInfo,"Predicted spectral bandwidth   = "+swrite(format="%.3f ",sigB*1e-6)(sum)+"mu-1";
  // yocoLogInfo,"Predicted turbulence bandwidth = "+swrite(format="%.3f ",tauB*1e-6)(sum)+"mu-1 (tau0="+pr1(tau0)+"ms)";

  /* Total and some verbose */
  sigT = sqrt( sigB^2 + tauB(-,)^2);
  Max  = max(sigT * lbd0);
  Avg  = avg(sigT * lbd0);
  Min  = min(sigT * lbd0);
  yocoLogInfo,"Predicted bandwidth (max,min)  = "+swrite(format="%.0f%% ",[Max,Avg,Min]*100)(sum)+"of sig0";
  
  yocoLogTrace,"pndrsGetPicWidthFromTau0 done";
  return sigT;
}

func pndrsGetPicWidth(oLog,checkUTs=)
{
  yocoLogTrace,"pndrsGetPicWith()";
  
  /* If given as a function */
  if( is_func(pndrsGetPicWidthUser) ) {
    yocoLogInfo,"User specified a function to compute the pic width.";
    return pndrsGetPicWidthUser(oLog);
  }

  /* If given as an array (lbd,base) */
  if ( is_array(pndrsGetPicWidthUser) ) {
    yocoLogInfo,"User specified an array to define the pic width.";
    return pndrsGetPicWidthUser;
  }

  /* Else use default (two times the prediction from tau0) */
  return 2.*pndrsGetPicWidthFromTau0(oLog,checkUTs=checkUTs);
}

local pndrsGetPicWidthUser;
pndrsGetPicWidthUser = [];
/* DOCUMENT pndrsGetPicWidthUser(oLog)

   This function should return the pic width in [m-1],
   in an array of two dimensions [nlbd,nbases]

   By default, it is set to pndrsGetPicWidthFromTau0, but
   it can be edited by the user.

   Don't forget to restore pndrsGetPicWidthUser=[]
*/

func pndrsBuildPolarAngleGroup(angle,delta)
{
  yocoLogInfo,"pndrsBuildPolarAngleGroup()";

  /* Define output and set group of first observation to 1 */
  group = array (0, dimsof(angle));
  group(1) = 1;

  /* Loop on remaining observations */
  for (i=2; i<=numberof (angle); i++)
  {
      /* Compare to previous */
     for (j=1; j<i; j++)
     {
         diff = angle(i) - angle(j);
         if (abs(diff) < delta || 360-abs(diff) < delta)
         {
             group(i) = group(j);
             break;
         }
     }

     /* Is not compatible with any previsous, so new group */
     if (group(i) == 0) group(i) = max(group) + 1;
  }

  yocoLogInfo,"pndrsBuildPolarAngleGroup done";
  return group;
}  
