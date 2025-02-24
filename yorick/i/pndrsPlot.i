/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsPlot(void)
/* DOCUMENT pndrsPlot(void)

   FUNCTIONS
   - pndrsPlotRaw
   - pndrsPlotSpectra
   - pndrsPlotMatrix
   - pndrsPlotMatrixImage
   - pndrsPlotClockPattern

*/
{
    local version;
    version = strpart(strtok("$Revision: 1.17 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsPlot;
    }   
    return version;
}


func pndrsPlotMatrix(win, matrix, oLog, which=,type=)
{
  yocoLogTrace,"pndrsPlotMatrix()";
  if( !pndrsBatchPlotLevel ) return 1;

  local data, ntel, nlbd, nout;
  if (is_void(type)) type=1;


  /* Plot an average over the pixel and the scans */
  data = matrix(,,which);
  ntel = dimsof(data)(0);
  nlbd = dimsof(data)(2);
  nout = dimsof(data)(3);

  if (nlbd>1)  yocoNmCreate,win,2,int(ceil(double(nlbd)/2)),dx=0.06;
  else         yocoNmCreate,win,1,1,dx=0.06,fx=1,fy=1;
  for (i=1;i<=nlbd;i++) {
    yocoPlotPlgMulti, data(i,,), color=-4-indgen(ntel), type=type, tosys=i;
  }

  yocoNmLimits,0.5,nout+0.5;
  yocoPlotHorizLine, 0, type=3, tosys=indgen(nlbd);

  /* Add titles */
  main = swrite(format="%s - %.4f", oLog.target, oLog.mjdObs);
  channel = swrite(format="channel %02d",indgen(nlbd));
  pndrsPlotAddTitles,channel,main,"Kappa coeficients","output","kappa";
  
  yocoLogTrace,"pndrsPlotMatrix done";
  return 1;
}

func pndrsPlotMatrixImage(win, matrix, which=)
{
  yocoLogTrace,"pndrsPlotMatrixImage()";
  if( !pndrsBatchPlotLevel ) return 1;
  
  local data, dim, ntel;

  /* Plot an average over the pixel and the scans */
  data = matrix(,which);

  window,win;
  pli, data, cmin=0;
  palette,"gray.gp";

  yocoLogTrace,"pndrsPlotMatrixImage done";
  return 1;
}

func pndrsPlotFftWaterfall(win, imgData, imgLog, color=, which=, op=, lbd=, legend=)
{
  yocoLogTrace,"pndrsPlotFftWaterfall()";
  if( !pndrsBatchPlotLevel ) return 1;

  local data, nwin, dim, ft, opd, freq, oLog;
  if ( is_void(op) ) op=noOp;
  if ( is_void(lbd) ) lbd = avg;

  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }

  /* Get the data and the opds */
  pndrsGetData, imgData, imgLog, data, opd, map, oLog;

  /* Select some */
  data = data(,,,which);
  opd  = opd(,,,which);
  map  = map(which);
  
  pndrsSignalFourierTransform, data, opd, ft, freq;
  
  dim   = dimsof(data)(2:);
  nwin  = dim(0);
  nopd  = dim(1);

  ft = op( ft(lbd,,,) );
  ft -= ft (*,)(min,-,-,);
  ft /= (ft (*,)(max,-,-,) + 1e-10);

  /* Plot */
  winkill,win;
  yocoNmCreate,win,2,nwin/2,dx=0.06,dy=0.01;
  palette,"yarg.gp";
  
  for ( i=1 ; i<=nwin ; i++ )
    {
      plsys,i;
      pli, ft(,,i);
    }
  yocoNmRangex,0,256;

  /* Add titles */
  sta  = pndrsPlotGetBaseName(oLog)(which);
  main = swrite(format="%s - %.4f", oLog.target, (*imgData.time)(*)(avg));
  pndrsPlotAddTitles,sta,main,legend,"freq. [arbitr. unit]","scan number";
  
  yocoLogTrace,"pndrsPlotFftWaterfall done";
  return 1;
}

func pndrsPlotSpectraArray(win, data)
{
  if( !pndrsBatchPlotLevel ) return 1;

  local nwin;
  /* Plot */
  nwin = dimsof(data)(0);
  winkill,win;
  yocoNmCreate,win,2,nwin/2,dx=0,dy=0;
  yocoPlotPlgMulti, data(,avg,avg,),tosys=nwin;
  range,0;
}

func pndrsPlotAllSpectra(win, imgData, imgLog, width=, op=, symbol=, kill=, which=, legend=)
{
  yocoLogTrace,"pndrsPlotAllSpectra()";
  if( !pndrsBatchPlotLevel ) return 1;

  if ( numberof(imgData)>1 ) yocoError,"Accept only scalars.";
  if ( is_void(op) )     op = noOp;
  if ( is_void(symbol) ) symbol = 4;
  local data, nwin, dim, map, opd, oLog;
  
  /* Extract data, average steps and scans */
  pndrsGetData, imgData, imgLog, data, opd, map, oLog;
  data = data(,avg,avg,which);
  nlbd = dimsof(data)(2);
  nwin = dimsof(data)(0);

  /* Color per baseline */
  color= ["black","blue","cyan","green","yellow","red","black","blue","cyan","green","yellow","red"](map.base);
  
  /* Plot */
  if (kill!=0) winkill,win;
  yocoNmCreate,win,2,nwin/2,dx=0.06,dy=0.01;
  yocoPlotPlgMulti, op(data), color=color, width=width, tosys=indgen(nwin);
  yocoPlotPlpMulti, op(data), color=color, symbol=symbol, fill=1, tosys=indgen(nwin);
  yocoNmLimits, 0.5, nlbd+0.5;

  /* Add titles */
  if ( kill!=0 ) {
    sta  = pndrsPlotGetBaseName(oLog)(which);
    main = swrite(format="%s - %.4f", oLog.target, oLog.mjdObs);
    pndrsPlotAddTitles,sta,main,legend,"spec. channel","flux";
  }

  yocoLogTrace,"pndrsPlotAllSpectra done";
  return 1;
}


func pndrsPlotSpectra(win, imgData, imgLog, width=, op=, symbol=, kill=)
{
  yocoLogTrace,"pndrsPlotSpectra()";
  if( !pndrsBatchPlotLevel ) return 1;

  if ( numberof(imgData)>1 ) yocoError,"Accept only scalars.";
  if ( is_void(op) )     op = noOp;
  if ( is_void(symbol) ) symbol = 4;
  local data, nwin, dim, map, opd, oLog;
  
  /* Extract data, average steps and scans */
  pndrsGetData, imgData, imgLog, data, opd, map, oLog;
  data = data(,avg,avg,);
  nlbd = dimsof(data)(2);

  /* Color per baseline */
  color= ["black","blue","cyan","green","yellow","red","black","blue","cyan","green","yellow","red"](map.base);
  
  /* Plot */
  nwin = dimsof(data)(0);
  if (kill!=0) winkill,win;
  window,win,style="boxed.gs";
  yocoPlotPlgMulti, op(data), color=color, width=width;
  yocoPlotPlpMulti, op(data), color=color, symbol=symbol, fill=1;
  yocoNmLimits,0.5,nlbd+0.5;
  range,0;

  yocoLogTrace,"pndrsPlotSpectra done";
  return 1;
}

func pndrsPlotRaw(win, imgData, imgLog, color=, which=, op=, width=, lbd=, scan=, kill=, type=, allLimits=, legend=)
{
  yocoLogTrace,"pndrsPlotRaw()";
  if( !pndrsBatchPlotLevel ) return 1;

  if ( numberof(imgData)>1 ) error,"Accept only scalars.";
  local data, nwin, dim, map, oLog, sta, main;
  if ( is_void(op) )    op  = noOp;
  if ( is_void(lbd) )   lbd = avg;
  if ( is_void(type) )  type=1;

  /* Extract data and associated log */
  pndrsGetData, imgData, imgLog, data, opd, map, oLog;
  data = data(lbd,,scan,which)(*,);
  map  = map(which);
  dim  = dimsof(data)(2:);
  nwin = dim(0);

  /* Plot */
  if (kill!=0) winkill,win;
  yocoNmCreate,win,2,nwin/2,dx=0.06,dy=0.01;
  yocoPlotPlgMulti, op( data ), tosys=indgen(nwin), color=color, width=width, type=type;

  /* Add titles */
  if (kill!=0) {
    sta  = pndrsPlotGetBaseName(oLog)(which);
    main = swrite(format="%s - %.4f", oLog.target, (*imgData.time)(*)(avg));
    pndrsPlotAddTitles,sta,main,legend,"opd step","flux";
  }

  if (allLimits==1) yocoNmLimits;
  
  yocoLogTrace,"pndrsPlotRaw done";
  return 1;
}

func pndrsPlotRawWaterfall(win, imgData, imgLog, op=, lbd=, filter=, reorder=, legend=)
{
  yocoLogTrace,"pndrsPlotRawWaterfall()";
  if( !pndrsBatchPlotLevel ) return 1;

  local data, nwin, dim, oLog;
  if ( is_void(op) ) op=noOp;
  if ( is_void(lbd) ) lbd = avg;

  /* Currently not support arrays */
  if ( numberof(imgData)>1 ) {
    yocoError,"Accept only scalars.";
    return 0;
  }

  /* Extract data and associated log */
  pndrsGetData, imgData, imgLog, data, opd, map, oLog;

  /* Eventually filter */ 
  if ( is_array(filter) ) {
    pndrsSignalSquareFiltering, data, opd, filter, dataf;
    data = dataf;
  }

  /* Eventually reorder */
  pndrsSignalReorder, data, opd(dif,,)(1,)<0, data;
  
  data  = op( data(lbd,,,) );
  data -= data (*,)(min,-,-,);
  data /= (data (*,)(max,-,-,) + 1e-10);
  
  dim   = dimsof(data)(2:);
  nwin  = dim(0);

  /* Plot */
  winkill,win;
  yocoNmCreate,win,2,nwin/2,dx=0.06,dy=0.01;
  palette,"yarg.gp";
  
  for ( i=1 ; i<=nwin ; i++ )
    {
      plsys,i;
      pli, data(,,i);
    }

  /* Add titles */
  sta  = pndrsPlotGetBaseName(oLog);
  main = swrite(format="%s - %.4f", oLog.target, (*imgData.time)(*)(avg));
  pndrsPlotAddTitles,sta,main,legend,"opd step","scan number";
  
  yocoLogTrace,"pndrsPlotRawWaterfall done";
  return 1;
}

func pndrsPlotPsdOfPixels(win, imgData, imgLog)
{
  yocoLogTrace,"pndrsPlotPsdOfPixels()";
  local data, opd, map, olog, time;
  local psd, psf;

  winkill,win;
  yocoNmCreate,win,ndata,dx=0.06,dy=0.01,fx=1,fy=1, V=[0.7,0.5];

  /* Get data */
  pndrsGetData, imgData(1), imgLog, data, opd, map, oLog, time;
  data = data(avg,..);

  /* Compute pseudo-fringe */
  id = [where(map.base==1)(1:2),
        where(map.base==5)(1:2),
        where(map.base==2)(1:2)];
  fringes = [data(..,id(1,1))-data(..,id(2,1)),data(..,id(1,2))-data(..,id(2,2)),data(..,id(1,3))-data(..,id(2,3))]/2;

  /* Compute temporal power spectral density */
  psd = power( fft(data,[1,0,0]) );
  psf = power( fft(fringes,[1,0,0]) );
  df = 1./(time(0,1)-time(1,1));
  
  /* Plot */
  yocoPlotPlgMulti, psd(5:256,avg,), indgen(4:255)*df;
  yocoPlotPlgMulti, psf(5:256,avg,), indgen(4:255)*df,color=["red","blue","green"], width=5;
  
  logxy,0,1; gridxy,1,1;
  
  main  = swrite(format="%s - %.4f", oLog.target, (*imgData(1).time)(*)(avg));
  pndrsPlotAddTitles, ,main,"Dark: raw pixels -- Cols: A-C for 3 bases", "Frequencies [Hz]", "PSD";

  yocoLogTrace,"pndrsPlotPsdOfPixels done";
  return 1;
}

func pndrsPlotClockPattern(win, pattern, time, colName, interactive=)
/* DOCUMENT pndrsPlotClockPattern(win, pattern, time, colName, interactive=)

   DESCRIPTION
   Plot the clock pattern of the detector, read with function
   pndrsReadClockPattern.

   If "pattern" is void or a scalar string, then the pattern is read
   from this file.

   PARAMETERS
   - win: window for the plot
   - pattern, time, colNames: outtputs of the function pndrsReadClockPattern
*/
{
  yocoLogInfo,"pndrsPlotClockPattern()";
  if( !pndrsBatchPlotLevel ) return 1;

  local p,t,delta,v,n;

  /* Default */
  if (is_void(win)) win=0;
  if (is_void(pattern) || typeof(pattern)=="string") {
    pndrsReadClockPattern, pattern, time, pattern, colName;
  }

  /* Add sample to plot with horizintal bars */
  n = numberof(pattern(1,));
  p = pattern(-:1:2,)(*,)(:-2,);
  t = transpose( [time(1:-1), time(2:0)] )(*);
  delta = 2*indgen(0:n-1);

  /* Plot clocks */
  winkill,win;
  yocoNmCreate,win,1,1,fx=1;
  yocoPlotPlgMulti, p+delta(-,), t;

  /* Plot titles */
  v = viewport();
  delta = span(v(3),v(4),n*2)(1::2)(1:n);
  yocoPlotPltMulti,colName,v(1)-0.05,delta,tosys=0,color="red";

  yocoLogTrace,"pndrsPlotClockPattern done";
  return 1;
}

func pndrsPlotAddTitles(titles, main, main2, xtitle, ytitle,height=,font=, xydelta=)
{
  if( !pndrsBatchPlotLevel ) return 1;
  if (is_void(main2) ) main2 = "-";

  local str;
  str = yocoStrReplace(main+"\n"+main2,"_","!_");
  yocoNmMainTitle,str,-0.04;

  if (is_void(height))  height = pltitle_height;
  if (is_void(font))    font   = pltitle_font;
  if (is_void(xydelta)) xydelta  = [0.00,0.012];
  
  for (i=1;i<=numberof(titles);i++) {
    plsys,i; port= viewport();
    str = yocoStrReplace(titles(i),"_","!_");
    plt, str, port(zcen:1:2)(1), port(4)-0.03, font=font,
      justify="CB", height=height;
  }

  if (is_array(xtitle) || is_array(ytitle)) {
    yocoNmXytitles, xtitle, ytitle, xydelta;
  }
}

func pndrsPlotGetBaseName(oLog)
{
  local map,sta,ids,beam;
  
  map = *oLog.correlation;
  ids = [map.t1,map.t2];

  /* FIXME: missing a PIONIER to ISS here!! */
  
  sta  = pndrsGetLogInfo(oLog,"issStation%i",ids)+"";
  beam = totxt(ids);
  sta  = merge2(sta, beam, sta!="");
  
  sta = (sta+["-",""](-,))(,sum);
  return sta;
}

func pndrsPlotDefaultTitles(oLog)
{
  if( !pndrsBatchPlotLevel ) return 1;

  local map,sta,main;
  sta  = pndrsPlotGetBaseName(oLog);
  main = swrite(format="%s - %.4f", oLog.target, oLog.mjdObs);
  pndrsPlotAddTitles,sta,main;
}

extern pndrsPdfCounter;
pndrsPdfCounter = 0;

func pndrsSavePdf(win, org, name, autoRotation=)
{
  /* No plot, exit */
  if ( !pndrsBatchPlotLevel ) return 1;

  /* Goto window */
  window,win;

  /* Catch errors */
  if ( catch(0x13) ) {
     yocoLogError,"Cannot save PDF, pndrsSavePdf catch: "+catch_message;
     return 0;
  }

  /* Add the counter if the call is done
     with two arguments */
  if (is_array(name) ) {
    pndrsPdfCounter++;
    name = org +swrite(format="_%03d_",pndrsPdfCounter) + name;
  } else {
    name = org;
  }
  
  /* Create output */
  if (strpart(name, -3:0) == ".pdf") name = strpart(name,1:-4);

  /* First run ghostscript to produce an eps translated to (0,0) */
  psname = eps(name+".pdf", pdf=1);

  /* Second run ghostscript to produce the cropped pdf.
     Note the option -dAutoRotatePages=/None */
  if (autoRotation==0) gscmd = EPSGS_CMD+" -dAutoRotatePages=/None -sDEVICE=pdfwrite ";
  else                 gscmd = EPSGS_CMD+" -sDEVICE=pdfwrite ";
  
  gscmd += "-sOutputFile="+name+".pdf "+psname+" ; rm -rf "+psname;

  /* Execute in bckg */
  system,"( "+gscmd+" ) &";
  
  return 1;
}

/* ------------------------------------------------- */


