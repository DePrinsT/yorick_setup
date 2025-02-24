/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsSim(void)
/* DOCUMENT pndrsSim(void)

   FUNCTIONS:
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.1 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsSim;
    }   
    return version;
}

/* ******************************************************** */

func pndrsSimImgData(imgData,&imgLog)
{
  yocoLogInfo,"pndrsSimImgData()";
  local i, data, nlbd, nscan, nwin, ntel, tel, cont, ilog;
  
  data = float(*imgData.regdata);
  opl  = float(*imgData.localopd);
  map  = *imgLog.correlation;

  /* Parameters */
  darkLevel = 0*2.;    // dark level
  sigDet    = 0.*2.5;  // detection noise
  sigPho    = 1;       // photon noise
  sigTrk    = 10e-6;   // residual of opd-tracking
  sigPst    = 1.5e-6;  // rms of piston during scan
  sigInj    = 0.3;     // injection fluctuation (rms/avg)
  flux0     = 10.0;    // flux

  /* input visibilities */
  vis  = sqrt([0.5,0.5,0.5,0.5,0.5,0.5])(map.base)(-,-,-,);
  
  dim   = dimsof(data)(2:);
  nstep = imgLog.scanNreads
  nlbd  = dim(2);
  nscan = dim(4)/nstep;
  nwin  = dim(5);
  nspx  = imgLog.detNspx;
  ntel  = max(max(map.t1,map.t2));

  opl = transpose(opl);
  dim = dimsof(opl)(2:);
  opl = reform(opl, [3, nstep, dim(1)/nstep, dim(2)]);
  opl -= opl(avg,-,,);

  /* piston sequence */
  pst  = indgen(nstep);
  pst  = pst^-2.5 * (pst<nstep/2 & pst>1);
  pst  = fft( pst * exp(2.i*pi*random(nstep,nscan,ntel)), [-1,0,0] ).re;
  pst *= sigPst / pst(rms,-,,);

  /* Move opl */
  opl -= pst  +  random_n(nscan,ntel)(-,) * sigTrk;

  /* Build OPD */
  opd = ( opl(..,map.t2) - opl(..,map.t1) );

  /* Wavelength as default for this setup */
  pndrsGetDefaultWave, imgLog, lbd, dlbd;

  /* Build the average flux per telescope */
  shutters = [imgLog.shut1,imgLog.shut2,imgLog.shut3,imgLog.shut4];
  tel = flux0 * (1+0.1*random_n(ntel)) * shutters;
  
  /* Build a spectral shape */
  spec = span(1,1,nlbd+1)(1:nlbd);

  /* Build an injection curve */
  inj = indgen(nstep)^-2.0 * (indgen(nstep)<nstep/2);
  inj = fft( inj * exp(2.i*pi*random(nstep,nscan,ntel)), [-1,0,0] ).re;
  inj -= inj(avg,-,,);
  inj /= inj(rms,-,,);
  inj = 1.0 + sigInj * inj;
  inj = max(inj,0);
  
  /* So flux is: */
  flux = inj(-,,,) * spec * tel(-,-,-,); 
  
  /* Assume the kappa matrix is perfect and non-chromatic */
  cont = flux(,,,map.t1) + flux(,,,map.t2);
  norm = 2.*sqrt(flux(,,,map.t1)*flux(,,,map.t2));

  /* Fringes */
  fringes = vis * sin(2*pi*opd(-,)/lbd - map.phi(-,-,-,));
  /* Shape */
  shape = yocoMathSinc(pi*opd(-,)*dlbd/lbd^2);

  /* Total signal, FIXME: add proper photon noise */
  flux = cont + norm*fringes*shape;
  flux += random_n(dimsof(flux)) * sqrt(max(flux,0)) * sigPho;
  /* Dark level */
  flux += darkLevel;
  
  /* Convert the data into raw data */
  if ( imgLog.detMode == "SIMPLE" )
    {
      /* Add sampix and merge step and scans */
      flux = flux(,-:1:nspx,*,);
    }
  else if ( imgLog.detMode == "FOWLER" )
    {
      /* integrate */
      flux = flux(,psum,,);
      /* Add sampix and merge step and scans */
      flux = flux(,-:1:nspx,*,);
    }
  else if ( imgLog.detMode == "DOUBLE" )
    {
      /* Total signal at dbl-read1 */
      flux1  = 0.1*( cont + norm*fringes*shape );
      flux1 += random_n(dimsof(flux1)) * sqrt(max(flux1,0)) * sigPho;
      flux1 += darkLevel;
      /* Add the first dbl-read */
      flux = flux(,-:1:2,,,);
      flux(,1,,,) = flux1;
      /* Merge step and scans */
      flux  = flux(,,*,);
      /* Add sampix and merge sampix and dbl-read */
      flux  = flux(,-:1:nspx,,,)(,*,,);
    }
  else {
    yocoError,"Detector mode not implemented: "+imgLog.detMode;
    return 0;
  }

  /* Add detection noise */
  flux = flux + sigDet*random_n(dimsof(flux));
  
  /* Put the data (add x-win) */
  *imgData.regdata = long(flux)(-,..);
  
  yocoLogTrace,"pndrsSimImgData done";
  return 1;
}
