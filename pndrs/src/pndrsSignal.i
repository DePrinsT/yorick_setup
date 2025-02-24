/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsSignal(void)
/* DOCUMENT pndrsSignal(void)

   FUNCTIONS:
   - abs(x)  - builtin function
   - real(x) 
   - imag(x)
   - power(x)
   - average(x)
   - averagePhase(x)
   
   - pndrsSignalFftIndgen
   - pndrsSignalWienerFiltering

   - pndrsSignalReorder
   - pndrsSignalRephase
   
   - pndrsSignalComputeAmp2Ratio
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.21 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsSignal;
    }   
    return version;
}

/* Some operators */
func noOp(x) { return x; }

func real(x) { return structof(x)==complex ? x.re : x; } 

func imag(x) { return structof(x)==complex ? x.im : x*.0; }

func power(x)  { return abs(x)^2.0; }


func averagePhase(x,d) {
  
  local deg;
  deg = pi/180.0;
  
  if (d==1) {
    return oiFitsArg( exp(1.i*x*deg )(sum,) ) / deg;
  }

  if (d==2) {
    return oiFitsArg( exp(1.i*x*deg )(,sum,) ) / deg;
  }

  if (d==3) {
    return oiFitsArg( exp(1.i*x*deg )(,,sum,) ) / deg;
  }

  if (d==4) {
    return oiFitsArg( exp(1.i*x*deg )(,,,sum,) ) / deg;
  }

  error;
}

func average(x,d) {
  
  local f;
  
  if (d==1) {
    f = abs(x)!=0;
    return (x * f)(sum,) / (f(sum,)+1e-10);
  }

  if (d==2) {
    f = abs(x(sum,-,))!=0;
    return (x * f)(,sum,) / (f(,sum,)+1e-10);
  }

  if (d==3) {
    f = abs(x(,sum,-,))!=0;
    return (x * f)(,,sum,) / (f(,,sum,)+1e-10);
  }

  if (d==4) {
    f = abs(x(,,sum,-,))!=0;
    return (x * f)(,,,sum,) / (f(,,,sum,)+1e-10);
  }

  error;
}

func pndrsSignalFftIndgen(dim) { return (u= indgen(0:dim-1)) - dim*(u > dim/2); }

func pndrsSignalFindBackgroundId(dist,mask,id0)
{
  local f,n,id0,dist,nstep,mask,tmp;

  /* Enlarge the distance in the mask */
  n    = numberof(dist);
  dist = dist + 1e20 * mask;

  /* Compute the position where dist is within its first quartil.
     Add neighboors (to avoid bias), but with direction opposit
     to id0, to not take fringe peak */
  id  = where( dist < dist(sort(dist))(int(n/4)) );
  id  = long( id + indgen(10)(-,) * sign(id-id0) )(*);

  /* Clean and remove point under the mask or outside */
  id = yocoListClean(id);
  id  = id( where( id>0 & id<n+1 ));
  id  = id( where( !mask(id) ));

  /* Keep only half of them, sorted by distance to id0 */
  tmp = abs(id-id0);
  id = id( where( tmp<(tmp(sort(tmp))(numberof(tmp)/2)) ) );
  
  return id;
}

func pndrsSignalWienerFiltering(data, &dataf, gui=)
/* DOCUMENT pndrsSignalWienerFiltering(data, &dataf, gui=)

   DESCRIPTION
   Perform pseudo-wiener filtering.
   Actually the filter is a band-pass [1,0]
   At worst, we return the average.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  yocoLogInfo,"pndrsSignalWienerFiltering( per win )";
  local dim, nopd, ft, freq, ftt, noise, nwin, nlbd, idm;
  dim  = dimsof(data)(2:);
  nopd = dim(2);
  nlbd = dim(1);
  idm  = nlbd/2+1;
  nwin = dim(0);

  /* Compute the PSD per outputs */
  ft   = fft(data,[0,1,0,0]) / sqrt(nopd);
  psd  = abs(ft)(avg,,avg,);
  freq = abs(pndrsSignalFftIndgen(nopd));

  /* Compute the filter. At worst, we return the average */
  filter = array(0.0, nopd, nwin);
  for (i=1;i<=nwin;i++) {
    noise  = median( psd(,i) );
    fnoise = min( freq( where(psd(,i)<noise*3) ) );
    // yocoLogWarning,"!!! Force fnoise !!!";
    // fnoise = 40.0;
    f0 = (freq<fnoise);
    f0( where(freq==min(freq)) ) = 1;
    f0 /= max(f0);
    filter(,i) = f0;
  }

  /* Get back */
  ftt   = ft * filter(-,,-,);
  dataf = fft(ftt,[0,-1,0,0]) / sqrt(nopd);

  /* If real, return real */
  if ( structof(data)==double ) dataf = dataf.re;
  if ( structof(data)==float )  dataf = float(dataf.re);

  /* Eventually plot */
  ids = 1:nopd/2;
  if ( gui && pndrsBatchPlotLevel )
  {
    winkill,gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.06,dy=0.01;
    for (i=1;i<=nwin;i++) {
      if (nlbd>2) {
        yocoPlotPlgMulti, power(ft(1,,,i))(ids,avg), tosys=i, type=1, color="red";
        yocoPlotPlgMulti, power(ft(0,,,i))(ids,avg), tosys=i, type=1, color="green";
      }
      yocoPlotPlgMulti, power(ft(idm,,,i))(ids,avg), tosys=i, type=1;

      plsys,i; logxy,0,1;
      limits; l=limits();

      if (nlbd>2) {
        yocoPlotPlgMulti, power(ftt(1,,,i))(ids,avg), tosys=i, type=1, color="red", width=3;
        yocoPlotPlgMulti, power(ftt(0,,,i))(ids,avg), tosys=i, type=1, color="green", width=3;
      }
      yocoPlotPlgMulti, power(ftt(idm,,,i))(ids,avg), tosys=i, type=1, width=3;
      range,l(3),l(4);

    }
    pause,10;
  }
  
  yocoLogTrace,"pndrsSignalWienerFiltering()";
  return 1;
}


func pndrsSignalReorder(data, flag, &datao)
{
  yocoLogTrace,"pndrsSignalReorder()";
  local dim;
  dim = dimsof(flag)(2:);

  /* Init new memory */
  datao = array(structof(data), dimsof(data));
  
  /* loop on scan and window */
  for ( i=1 ; i<=dim(1) ; i++) 
    for ( j=1 ; j<=dim(2) ; j++)
      {
        /* reorder if flag<0 */
        if ( flag(i,j)>0 ) datao(,,i,j) = data(,,i,j);
        else               datao(,,i,j) = data(,::-1,i,j);
      }

  yocoLogTrace,"pndrsSignalReorder done";
  return 1;
}

func pndrsSignalRephase(data, flag, &datao)
{
  yocoLogTrace,"pndrsSignalRephase()";
  local dim;
  dim = dimsof(flag)(2:);
  
  /* Init new memory */
  datao = array(structof(data), dimsof(data));
  
  /* loop on scan and window */
  for ( i=1 ; i<=dim(1) ; i++) 
    for ( j=1 ; j<=dim(2) ; j++)
      {
        /* rephase if flag<0 */
        if ( flag(i,j)>0 ) datao(,,i,j) = data(,,i,j);
        else               datao(,,i,j) = conj( data(,,i,j) );
      }
  
  yocoLogTrace,"pndrsSignalRephase done";
  return 1;
}

func pndrsSignalFourierTransform(data, opd, &ft, &freq)
/* DOCUMENT 

   DESCRIPTION
   All scans will put in increasing opd.

   Frequencies and data are ordered [0 -> 2max].
   And the fringe power should be within 0-max.
   
   However, 2max will be negative if the scan
   was decreasing.This allow to
   - perform the same operation on all data by using abs(freq).
   - still remember that this was an inversed scan.

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
    yocoLogTrace,"pndrsSignalFourierTransform()";
    local dx, nread, datao;

    /* Compute opd */
    dx = opd(-1,,) - opd(-2,,);

    if (min(abs(dx)) == 0) {
        yocoLogWarning, "opd seems invalid!!";
    }
    
    /* Compute the sigma arrays */
    nread = dimsof(data)(3);
    freq = span(0,1,nread+1)(:-1) / dx(-,);
    
    /* reorder if flag<0 */
    pndrsSignalReorder, data, dx, datao;

    /* Compute the ffts */
    ft = fft(datao, [0,+1,0,0]) / sqrt(nread);

    yocoLogTrace,"pndrsSignalFourierTransform done";
    return 1;
}

func pndrsSignalFourierBack(ft, freq, &data, &opd)
{
    yocoLogTrace,"pndrsSignalFourierBack()";
    local df, nread, datao;

    /* Compute the OPD arrays */
    df = freq(-1,,) - freq(-2,,);
    nread = dimsof(ft)(3);
    opd = span(-.5,.5,nread+1)(:-1) / df(-,);

    /* Compute the ffts */
    datao = fft(ft, [0,-1,0,0]) / sqrt(nread);
    
    /* reorder if flag<0 */
    pndrsSignalReorder, datao, df, data;

    yocoLogTrace,"pndrsSignalFourierBack done";
    return 1;
}

func pndrsSignalSquareFiltering(data, opd, filter, &dataf, &ft0)
{
  yocoLogTrace,"pndrsSignalSquareFiltering()";
  local ft, freq, mask;
  
  /* Fourier transform */
  pndrsSignalFourierTransform, data, opd, ft, freq;

  /* Filter  */
  ft0=ft;
  mask = (abs(freq)>filter(1)) & (abs(freq)<filter(2));
  ft  *= mask(-,);

  /* Fourier back */
  pndrsSignalFourierBack, ft, freq, dataf;
  
  yocoLogTrace,"pndrsSignalSquareFiltering done";
  return 1;
}

func pndrsSignalComputePhase(bisp, &phases, &phasesErr, gui=)
{
  yocoLogInfo,"pndrsSignalComputePhase()";
  local bisp0, nscan, nboot, nwin, nid;
  nlbd  = dimsof(bisp)(2);
  idm   = nlbd/2+1;
  nscan = dimsof(bisp)(3);
  nwin  = dimsof(bisp)(4);

  /* Init arrays with meaningless values */
  phases    = array(float(0.0),  nlbd, nwin);
  phasesErr = array(float(1000.0), nlbd, nwin);
  
  /* Loop on baseline */
  for ( w=1 ; w<=nwin ;w++) {

    /* Keep only valid scans (non zero), assuming all wavelength
       have the same selections */
    id = where( abs(bisp)(1,,w) );
    nid  = numberof(id);
    
    /* If not enough scans, reject the data */
    if ((nscan>10 && nid<10) || nid<1) {
      yocoLogInfo,swrite(format="Base %2i accepted scans: %3d (%d)    -  phi=rejected",w,nid,nscan);
      continue;
    }

    /* Bootstrap over the scans. The first bootstrap
       is simply the selection of all data */
    bispb = bisp(,id,w);
    nboot = max(nid, 300);
    boot  = int( random(nid,nboot)*nid ) + 1;
    boot(,1) = indgen(nid);
    
    /* Compute the final closure */
    bispb         = bispb(,boot)(,avg,);
    phases(,w)    = oiFitsArg( bispb(,1) ) * 180/pi;
    phasesErr(,w) = oiFitsArg( bispb * conj(bispb(,1)) )(,rms) * 180/pi;
    
    /* Verbose */
    yocoLogInfo,swrite(format="Base %2i accepted scans: %3d (%d)    "+
                       "-  phi=%+7.2fdeg+-%5.1f  -  phi=%+7.2fdeg+-%5.1f",
                       w,nid,nscan,
                       phases(1,w),phasesErr(1,w),
                       phases(0,w),phasesErr(0,w));
    
  } /* end loop on baseline */ 

  /* Eventually plot */
  if ( gui && pndrsBatchPlotLevel)
  {
    winkill,gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.01,dy=0.01,square=1;
    for (i=1;i<=nwin;i++) {
      
      if (nlbd>2) {
        yocoPlotPlpMulti, bisp(1,,i).im, bisp(1,,i).re, fill=0, tosys=i, color="red";
        yocoPlotPlpMulti, bisp(0,,i).im, bisp(0,,i).re, fill=0, tosys=i, color="green";
      }
      yocoPlotPlpMulti, bisp(idm,,i).im, bisp(idm,,i).re, fill=0, tosys=i;
      
      limits,square=1;
      Max = max(abs(limits()(1:4)));

      if (nlbd>2) {
        tmp = 2.* Max * exp( 1.i*( phases(1,i) + phasesErr(1,i)*[-1,0,1] )*pi/180 )(-,) * [0,1];
        yocoPlotPlgMulti, tmp.im, tmp.re, color="red";
        tmp = 2.* Max * exp( 1.i*( phases(0,i) + phasesErr(0,i)*[-1,0,1] )*pi/180 )(-,) * [0,1];
        yocoPlotPlgMulti, tmp.im, tmp.re, color="green";
      }
      tmp = 2.* Max * exp( 1.i*( phases(idm,i) + phasesErr(idm,i)*[-1,0,1] )*pi/180 )(-,) * [0,1];
      yocoPlotPlgMulti, tmp.im, tmp.re;

      
      limits,-Max,Max,-Max,square=1;
      gridxy,2,2;
    }
  }

  yocoLogInfo,"pndrsSignalComputePhase done";
  return 1;
}

func pndrsSignalComputeAmp2Ratio(amp2, norm2, &vis2, &vis2Err, gui=, square=)
{
  yocoLogInfo,"pndrsSignalComputeAmp2Ratio()";
  local nscan, nwin, boot, nlbd, idm;
  nlbd  = dimsof(amp2)(2);
  idm   = nlbd/2+1;
  nscan = dimsof(amp2)(3);
  nwin  = dimsof(amp2)(4);
  if (is_void(square)) square=1

  /* Init arrays with meaningless values */
  vis2    = array(float(0.0),  nlbd, nwin);
  vis2Err = array(float(100.0), nlbd, nwin);
  
  /* Loop on baseline */
  for ( w=1 ; w<=nwin ;w++) {

    /* Keep only valid scans (non zero), assuming all wavelength
       have the same selections */
    id  = where( amp2(1,,w)!=0 & norm2(1,,w)!=0 );
    nid = numberof(id);

    /* If not enough scans, reject the data */
    if ((nscan>15 && nid<15) || nid<1) {
      yocoLogInfo,swrite(format="Base %2i accepted scans: %3d (%d)    -  amp=rejected",w,nid,nscan);
      continue;
    }

    /* Bootstrap over the valid scans. The first bootstrap
       is simply the selection of all data */
    amp2b  = amp2(,id,w);
    norm2b = norm2(,id,w);
    
    nboot  = max(nid, 300);
    boot   = int( random(nid,nboot)*nid ) + 1;
    boot(,1) = indgen(nid);
  
    /* Average over the boot and compute the vis2 */
    vis2b  = amp2b(,boot)(,avg,) / norm2b(,boot)(,avg,);
    vis2Err(,w) = vis2b(,rms);
    vis2(,w)    = vis2b(,1);

    /* Verbose */
    yocoLogInfo,swrite(format="Base %2i accepted scans: %3d (%d)    "+
                       "-  amp=%5.1f%%+-%4.1f  -  amp=%5.1f%%+-%4.1f",
                       w,nid,nscan,
                       vis2(1,w)*100,vis2Err(1,w)*100,
                       vis2(0,w)*100,vis2Err(0,w)*100);
  }
  /* end loop on base */
  
  /* Eventually plot */
  if ( gui && pndrsBatchPlotLevel )
  {
    winkill,gui;
    yocoNmCreate,gui,2,nwin/2,dx=0.06,dy=0.06;
    for (i=1;i<=nwin;i++) {
      
      if (nlbd>1) {
        yocoPlotPlpMulti, amp2(1,,i), norm2(1,,i), fill=0, tosys=i,color="red";
        yocoPlotPlpMulti, amp2(0,,i), norm2(0,,i), fill=0, tosys=i,color="green";
      }
      yocoPlotPlpMulti, amp2(idm,,i), norm2(idm,,i), fill=0, tosys=i;
      
      if (square) limits,square=1; else limits;
      Max = max(abs(limits()(1:4)));
      tmp = span(0,2.*Max,2) * (vis2(0,i)!=0);
       
      yocoPlotPlgMulti, tmp * (vis2(idm,i) + vis2Err(idm,i)*[-1,0,1])(-,), tmp;
      if (nlbd>1) {
        yocoPlotPlgMulti, tmp * (vis2(1,i) + vis2Err(1,i)*[-1,0,1])(-,), tmp, color="red";
        yocoPlotPlgMulti, tmp * (vis2(0,i) + vis2Err(0,i)*[-1,0,1])(-,), tmp, color="green";
      }
      
      if (square) limits,-Max/5,Max,-Max/5,square=1;
      gridxy,2,2;
    }
  }

  yocoLogInfo,"pndrsSignalComputeAmp2Ratio done";
  return 1;
}


/* *** Test routines, not used *** */


// func pndrsSignalSquareFiltering2(data, opd, filter, &dataf)
// {
//     local Dx, nread; 
//     Dx = opd(0,,) - opd(1,,);
//     nread = dimsof(data)(3);
    
//     /* Compute the ffts */
//     ft = fft(data, [0,+1,0,0]) / sqrt(nread);

//     /* filter */
//     freq = pndrsSignalFftIndgen(nread) / Dx(-,);
//     mask = (freq>filter(1)) & (freq<filter(2));
//     ft  *= mask(-,);

//     /* Compute the ffts */
//     dataf = fft(ft, [0,-1,0,0]) / sqrt(nread);
  
//     return 1;
// }

// func pndrsSignalWienerFilteringOrg(data, &dataf)
// {
//   yocoLogInfo,"pndrsSignalWienerFilteringOrg()";
//   local dim, nopd, ft, freq, ftt, noise;
//   dim  = dimsof(data)(2:);
//   nopd = dim(2);

//   /* Compute the PSD */
//   ft   = fft(data,[0,1,0,0]) / sqrt(nopd);
//   psd  = abs(ft)(avg,,avg,avg);
//   freq = abs(pndrsSignalFftIndgen(nopd));

//   /* Compute the filter. At worst, we return the average */
//   noise  = median(psd);
//   fnoise = min( freq( where(psd<noise) ) );
//   filter = (freq<fnoise);
//   filter( where(freq==min(freq)) ) = 1;
//   filter /= max(filter);

//   /* Get back */
//   ftt   = ft * filter(-,,-,-);
//   dataf = fft(ftt,[0,-1,0,0]) / sqrt(nopd);

//   /* If real, return real */
//   if ( structof(data)==double ) dataf = dataf.re;
//   if ( structof(data)==float )  dataf = float(dataf.re);
  
//   yocoLogTrace,"pndrsSignalWienerFilteringOrg()";
//   return 1;
// }
