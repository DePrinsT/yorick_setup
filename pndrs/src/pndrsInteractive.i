/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsInteractive(void)
/* DOCUMENT pndrsInteractive(void)

   FUNCTIONS:
   - pndrsInspectRawData
   - pndrsInspectAllRawData

   - pndrsInspect
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.64 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsInteractive;
    }   
    return version;
}

/* ******************************************************** */

func pndrsWaterPlsys(base, n)
/* DOCUMENT pndrsWaterPlsys(base, n) 

   DESCRIPTION
   The water fall contains direct and fft of scans,
   plus summed up graphs.
 */
{
  row = 1 + 2 * ((base - 1) / 3) + (n == 3 || n == 4);
  col = 1 + 2 * ((base - 1) % 3) + (n % 2 == 0);
  plsys, col + 6 * (row - 1);
}

/* ******************************************************** */

func pndrsAsPnrSelTable(file)
{
  /* Open file and find number of hdu */
  local fh, out;
  fh = ( structof(file)==string ? cfitsio_open(file,"r") : file );

  /* Loop on HDU */
  for (out=[],i=1;i<=numberof(cfitsio_list(fh));i++) {
    cfitsio_goto_hdu, fh, i;
    grow, out, cfitsio_get(fh,"EXTNAME");
  }
  
  /* Find number of hdu */
  if( structof(file)==string ) cfitsio_close,fh;

  out = where( out == "PNDRS_SEL" );
  return is_array(out) ? out(1)+1 : [];
}

func pndrsReadPnrSelTable(file)
{
  yocoLogInfo,"pndrsReadPnrSelTable()"; 
  local fh, img, hdu;

  /* Open file and find number of hdu */
  fh = ( structof(file)==string ? cfitsio_open(file,"r") : file );

  /* Find number of hdu */
  hdu = pndrsAsPnrSelTable(fh);
  if ( !is_array(hdu) ) {
    if( structof(file)==string ) cfitsio_close,fh;
    return [];
  }

  cfitsio_goto_hdu,fh, hdu;
  img = cfitsio_read_image(fh)
  
  /* Eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;
  
  yocoLogTrace,"pndrsReadPnrSelTable done"; 
  return transpose( img );
}

func pndrsWritePnrSelTable(file, sel)
{
  yocoLogInfo,"pndrsWritePnrSelTable() in file",file; 
  local fh, img, hdu;

  /* Open file and find number of hdu */
  fh = ( structof(file)==string ? cfitsio_open(file,"a") : file );
  
  /* Find number of hdu */
  hdu = pndrsAsPnrSelTable(fh);
  if ( !is_array(hdu) ) {
    yocoLogInfo,"Create table PNDRS_SEL in file";
    cfitsio_add_image, fh, transpose( sel ), "PNDRS_SEL";
  } else {
    yocoLogInfo,"Update table PNDRS_SEL in file";
    cfitsio_goto_hdu,fh, hdu;
    cfitsio_write_image, fh, transpose( sel );
  }

  /* Eventually close file */
  if( structof(file)==string ) cfitsio_close,fh;

  yocoLogTrace,"pndrsWritePnrSelTable()"; 
  return img;
}

func pndrsSelectPlotWatter(data, psd, sel, opd, freq, freq0)
{
  /* Remove the very low frequencies */
  psd(1:3,) = 0.0;
  
  /* Normalize */
  data -= data(*,)(min,-,-,);
  data /= data(*,)(max,-,-,);
  psd  -= psd (*,)(min,-,-,);
  psd  /= psd (*,)(max,-,-,);

 
  /* Plot waterfall */
  for (i=1;i<=dimsof(data)(0);i++) {
    /* plot averages (coherent flux and power) */
    pndrsWaterPlsys, i, 3;
    plg,data(,avg,i), opd(,i)*1e6, color=128;
    plg,(data(,,i) * sel(-,,i))(,sum) / ( sel(sum,i) + 1e-5 ), opd(,i)*1e6;
    limits; l=limits(); range,0,1.3*l(4);
    pndrsWaterPlsys, i, 4;
    plg,psd(,avg,i), freq(,i)*1e-6, color=128;
    plg,(psd(,,i) * sel(-,,i))(,sum) / ( sel(sum,i) + 1e-5 ), freq(,i)*1e-6;
    limits; l=limits(); range,0,1.3*l(4);
    /* plot scans and fft (graying selected frames) */
    data(,,i) += 0.5 * !sel(-,,i); 
    psd(,,i)  += 0.5 * !sel(-,,i); 
    pndrsWaterPlsys, i, 1;
    pli,data(,,i),opd(min,i)*1e6,1,opd(max,i)*1e6,numberof(data(1,,1)),cmin=0,cmax=1;
    limits;
    pndrsWaterPlsys, i, 2;
    pli,psd(,,i),freq(min,i)*1e-6,1,freq(max,i)*1e-6,numberof(psd(1,,1)),cmin=0,cmax=1;
    limits;
  }

}

func pndrsInspect(coherData, imgLog, &sel, dpi=, darkData=, noinit=, noInteractive=)
{
  yocoLogInfo,"pndrsInspect()";
  local data, nlbd, nscan, nstep, nbase, npol, opd, data, dataf, psd;
  local scan, scanC, psdC, i, id, s, ftdark, ft, olog, lbd0;

  /* */
  if (is_void(dpi))  dpi=100;

  /* Get data */
  pndrsGetData, coherData, imgLog, data, opd, map, olog;
  nlbd  = dimsof(data)(2);
  nstep = dimsof(data)(3);
  nscan = dimsof(data)(4);
  nbase = dimsof(data)(5);
  ntel = max(max(map.t1,map.t2));
  pol  = yocoListClean(map.pol)(*);
  npol = numberof(pol);

  /* Default wave */
  pndrsGetDefaultWave, olog, lbd0;
  
  /* Define the filters */
  if (strmatch( pndrsGetBand(olog(1)), "K") ) filtIn = pndrsFilterKSnr;
  if (strmatch( pndrsGetBand(olog(1)), "H") ) filtIn = pndrsFilterHSnr;

  if (nbase>6) {
    yocoLogWarning,"cannot deal with more than 6 baselines (or 2 pols)... keep only the first 6";
    data = data(..,1:6); nbase=6; opd = opd(..,1:6);
    // return 0;
  }

  /* Prepare selection */
  if ( is_void(sel) || dimsof(sel)(2)!=nscan || dimsof(sel)(3)!=nbase)  sel = array(int(1), nscan, nbase);

  /* Also flag the void scans */
  sel *= (data(avg,avg,,)!=0);

  /* Save current */
  sel0 = sel;

  /* Compute PSD  */
  pndrsSignalFourierTransform, data, opd, ft, freq;

  /* If the dark is provided, we compute an estimation of its PSD */
  if (is_array(darkData)) {
    pndrsGetData, darkData, imgLog, dark, opdd;
    pndrsSignalFourierTransform, dark, opdd, ftdark;
  } else {
    ftdark = ft(,,[1],) * 0.0;
  }

  /* Compute filtered version of data */
  filt  = ( (abs(freq)>filtIn(1,-,))  & (abs(freq)<filtIn(2,-,)) )(-,);
  pndrsSignalFourierBack, ft * filt, freq, dataf;

  /* Invert so that they are all in the same direction */
  flag = (opd(2,,) - opd(1,,));
  pndrsSignalReorder, data,  flag, data;
  pndrsSignalReorder, dataf, flag, dataf;
  freq = abs(freq)(,1,);
  opd  = opd(,1,); opd -= opd(avg,-,);
  
  /* Init arrays */
  scanC = abs( dataf(avg,) );
  psdC  = abs( ft(avg,3:nstep/2,) )^2  - (abs( ftdark(avg,3:nstep/2,) )^2)(,avg,-,);
  freq  = freq(3:nstep/2,);
  freq0 = 1./lbd0(avg);

  /* Init plot */
  if (!noinit) {
    winkill,1; window,1, dpi=dpi, width=int(11*dpi), height=int(8.5*dpi);
  }

  /* Init titles */
  main = swrite(format="%s   -   %s - %.4f", yocoFileSplitName(olog.fileName), olog.target, (*coherData.time)(*)(avg));
  sta  = (pndrsGetLogInfo(olog,"issStation%i",[map.t1,map.t2])+["-",""](-,))(,sum);
  titles = sta(-,) + [" (dir)", "(fft)"](,-);
  none = array("sum", 6);
  titles = grow(titles(,1:3)(*), none, titles(,4:6)(*), none);
  
  yocoNmCreate, 0, 6, 4, landscape=1, dx=[0.005, 0.033, 0.005, 0.033, 0.005],\
          dy=[0.005,0.02,0.005], ry=[2, 1, 2, 1];
  palette,"yarg.gp";
  get_style,,s;
  vp = s.viewport();

  /* Init buttons */
  buttons = array(Button(y=0.775,dy=0.01,dx=0.03,font="helvetica"),7);
  buttons.text = ["Revert","All","None","PREV","NEXT","SKIP","EXIT"];
  buttons.x    = [.48,.55,.62,.725,.8,.875,.95];
  
  b_channel      = array(Button(y=0.775,dy=0.01,dx=0.015,font="helvetica"),nlbd+1);
  b_channel.x    = span(0.09,0.38,nlbd+1);
  b_channel.text = grow( swrite(format="%i",indgen(nlbd)), "all");
  b_channel(0).font = "helveticaB";

  b_all          = array(Button(text="all",font="helvetica",height=8,dx=0.014,dy=0.007),nbase);
  b_all.x        = vp(2,[2, 4, 6, 14, 16, 18])-0.015;
  b_all.y        = vp(3,[2, 4, 6, 14, 16, 18])-0.010;
  b_none         = array(Button(text="none",font="helvetica",height=8,dx=0.014,dy=0.007),nbase);
  b_none.x       = vp(2,[2, 4, 6, 14, 16, 18])-0.015;
  b_none.y       = vp(3,[2, 4, 6, 14, 16, 18])-0.024;
  
  /**** Test buttons and execute action until exit ****/
  while ( 1 )
    {
      /* Replot and wait for the mouse */
      window,0; fma;
      yocoNmXytitles, ["OPD", "freq."](,-:1:3)(*), ["scan", "flux", "scan", "flux"], [0.02, 0.02];
      pndrsPlotAddTitles, titles, main,height=12;
      button_plot, buttons, b_channel, b_all, b_none;
      pndrsSelectPlotWatter, scanC, psdC, sel, opd, freq, freq0;

      /* Non interactive mode, like "skip" */
      if (noInteractive==1) {redraw; pause,20; return 0;}

      /* Interactive mode */
      clk = mouse(-1, 1, "");

      /* button: Check if clicked inside a viewport */
      for (v=1;v<=numberof(s);v++) {
        if ((v - 1)/ 6 % 2)
        {
          continue; /* viewport is an graph of averages, no frame to select */
        }
        if ( clk(6) > vp(4,v) || clk(6) < vp(3,v) || clk(5) > vp(2,v) || clk(5) < vp(1,v) ) 
        {
          continue; /* outside of the viewport */
        }
 
        /* Update the selection for this baseline */
        base  = (v + 1) / 2;
        if (base > 6)
        {
          base -= 3; /* second row inbetween... 6 plots / 2 to skip. */
        }
        first = max( min( int(clk([2,4])+0.5) ), 1);
        last  = min( max( int(clk([2,4])+0.5) ), nscan);
        sel(first:last,base) = (clk(0)!=0);
        break; 
      }
      
      /* button: all and none*/
      id = where( abs(clk(6)-b_all.y)<b_all.dy &
                  abs(clk(5)-b_all.x)<b_all.dx );
      if (is_array(id)) {
        sel(,id(1)) = (clk(0)!=0);
      }
      id = where( abs(clk(6)-b_none.y)<b_none.dy &
                  abs(clk(5)-b_none.x)<b_none.dx );
      if (is_array(id)) {
        sel(,id(1)) = !(clk(0)!=0);
      }


      /* button: Revert and all*/
      if (button_test(buttons(1), clk(5), clk(6))) sel = sel0;
      if (button_test(buttons(2), clk(5), clk(6))) sel(*) = (clk(0)!=0);
      if (button_test(buttons(3), clk(5), clk(6))) sel(*) = !(clk(0)!=0);
      
      /* button: Next, Prev, Exit */
      if (button_test(buttons(4), clk(5), clk(6))) return 2;
      if (button_test(buttons(5), clk(5), clk(6))) return 1;
      if (button_test(buttons(6), clk(5), clk(6))) return 0;
      if (button_test(buttons(7), clk(5), clk(6))) return -1;

      /* button: Spectral channels */
      id = where( abs(clk(6)-b_channel.y)<b_channel.dy &
                  abs(clk(5)-b_channel.x)<b_channel.dx );
      if (is_array(id)) {
        id = id(1);
        b_channel.font="helvetica";
        b_channel(id).font="helveticaB";
        if (id>nlbd) id = avg;
        scanC = abs( dataf(id,) );
        psdC  = abs( ft(id,3:nstep/2,) )^2 - (abs( ftdark(id,3:nstep/2,) )^2)(,avg,-,);
        freq0 = 1./lbd0(id);
      }

      
    }
  /* End while for buttons */

  // winkill,0;
  // winkill,1;
  yocoLogTrace,"pndrsInspect done";
  return 1;
}

/* ******************************************************** */

func pndrsInspectRawData(inputRawFile=, noinit=)
{
  yocoLogInfo,"pndrsInspectRawData()";
  
  /* Check the input files */
  if ( !pndrsCheckFile(inputRawFile,2,[1])) {
    yocoError,"Check arguments of pndrsInspectRawData: should be 1 existing file.";
    return 0;
  }
  
  /* Catch errors */
  if ( catch(0x01+0x02+0x08+0x10) ) {
    write,"pndrsInspectRawData catch: "+catch_message;
    return 0;
  }
  
  /* Load file */
  pndrsReadRawFiles, inputRawFile, imgData, imgLog;

  /* Log info */
  local fwhm, tau0;
  pndrsGetAmbi, imgLog(1), fwhm, tau0;
  yocoLogInfo,"------------- observation info --------------";
  yocoLogInfo,"file:    "+imgLog(1).fileName;
  yocoLogInfo,"target:  "+imgLog(1).target;
  yocoLogInfo,"date:    "+imgLog(1).dateObs;
  yocoLogInfo,"mjd:     "+swrite(format="%.3f",imgLog(1).mjdObs);
  yocoLogInfo,"setup:   "+pndrsGetSetup(,imgLog(1));
  yocoLogInfo,"ambi:    "+pr1(fwhm)+"'' / "+pr1(tau0)+"ms";
  yocoLogInfo,"---------------------------------------------";

  /* Basic data processing */
  pndrsProcessDetector, imgData, imgLog;
  pndrsReformData, imgData, imgLog;
  pndrsProcessOversampling, imgData, imgLog;
  pndrsComputeCoherentFlux, imgData, imgLog, coherData;

  /* Load the table if any */
  sel = pndrsReadPnrSelTable(inputRawFile);


  /* Execute the selection */
  answer = pndrsInspect( coherData, imgLog, sel);

  /* Check if not OK */
  if (answer==0) return 0;
  
  /* Create/Update the selection table in RAW file */
  pndrsWritePnrSelTable, inputRawFile, sel;

  yocoLogTrace,"pndrsInspectRawData done";
  return answer;
}

/* ******************************************************** */

func pndrsInspectAllRawData(inputDir=,overwrite=,inputRawFile=,savePdf=, noInteractive=)
{
  local i, inputRawFile, noinit;
  if ( is_void(overwrite) ) overwrite=0;
  if ( is_void(savePdf) )   savePdf=1;
  yocoLogInfo,"pndrsInspectAllRawData()";

  /* Check the argument */
  if ( !pndrsCheckDirectory(inputDir,2) ) {
     yocoError,"Check argument of pndrsInspectAllRawData";
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

  /* Check if request file exist */
  if ( is_array(inputRawFile) ) i = where(inputRawFile == oiLogDir(idSci).fileName);
  if ( !is_array(i) ) i=1; else i = i(1);
  
  /* Loop on science files */
  for ( ; i<=numberof(idSci) ; i++)
    {
      /* Some init */
      sel = answer = [];
      ids = idSci(i);
      inputRawFile = inputDir+"/"+oiLogDir(ids).fileName;

      /* Create root output file (so far only for PDF) */
      yocoFileSplitName, oiLogDir(ids).fileName, ,outputFile;
      outputFile = inputDir+"/"+outputFile;
      
      /* Just a log */
      yocoLogInfo,"****";
      str = swrite(format="pndrsInspectAllRawData is now working on file (%i over %i):",
                   i, numberof(idSci));
      yocoLogInfo, str, inputRawFile;

      /* Catch errors */
      if ( catch(0x01+0x02+0x08+0x10) ) {
        write,"pndrsInspectAllRawData catch: "+catch_message;
        continue;
      }

      /* Check if table exist */
      if (overwrite==0 && pndrsAsPnrSelTable(inputRawFile)) {
        yocoLogInfo,"file already has a PNR_SEL table... skipped.";
        continue;
      }

      /* Load file */
      pndrsReadRawFiles, inputRawFile, imgData, imgLog;
      sel = pndrsReadPnrSelTable(inputRawFile);

      /* Process data */
      pndrsProcessDetector, imgData, imgLog;
      pndrsReformData, imgData, imgLog;
      pndrsProcessOversampling, imgData, imgLog;
      pndrsComputeCoherentFlux, imgData, imgLog, coherData;

      /* Log info */
      pndrsGetAmbi, oiLogDir(ids), fwhm, tau0;
      yocoLogInfo,"------------- observation info --------------";
      yocoLogInfo,"file:    "+oiLogDir(ids).fileName;
      yocoLogInfo,"target:  "+oiLogDir(ids).target;
      yocoLogInfo,"date:    "+oiLogDir(ids).dateObs;
      yocoLogInfo,"mjd:     "+swrite(format="%.3f",oiLogDir(ids).mjdObs);
      yocoLogInfo,"setup:   "+pndrsGetSetup(,oiLogDir(ids));
      yocoLogInfo,"ambi:    "+pr1(fwhm)+"'' / "+pr1(tau0)+"ms";
      yocoLogInfo,"---------------------------------------------";
      

      /* Execute inspection. Outputs is in window 1 */
      answer = pndrsInspect( coherData, imgLog, sel,
                             noinit=noinit, noInteractive=noInteractive );

      /* Save pdf */
      if (savePdf) {
        remove,outputFile+"_inspect.pdf";
        pndrsSavePdf,1,outputFile+"_inspect.pdf",autoRotation=0;
      }
      
      /* Some stuffs */
      noinit=1;
      if (answer==-1) break;
      if (answer==0)  continue;
      if (answer== 2) { i = i-2; overwrite=1; }
      
      /* Create/Update the selection table in RAW file */
      system,"chmod u+w "+inputRawFile;
      pndrsWritePnrSelTable, inputRawFile, sel;
      system,"chmod a-w "+inputRawFile+" > /dev/null 2>&1";
    }
  
  yocoLogTrace,"pndrsInspectAllRawData done";
  return 1;
}

