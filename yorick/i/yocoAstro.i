/******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Astronomy-related functions
 *
 * "@(#) $Id: yocoMath.i,v 1.25 2011-04-12 18:15:25 fmillour Exp $"
 *
 ******************************************************************************/

func yocoAstro(void)
    /* DOCUMENT yocoAstro

       DESCRIPTION
       Main astronomical and physical quantities and conversion
       factor accessed via different unit systems.
   
       VERSION

       FUNCTIONS
       - yocoAstro                    : This script
       - yocoAstroAirIndex            : Optical index of air
       - yocoAstroBBody               : Integrated Black body function
       - yocoAstroBBodyLambda         : Black body function
       - yocoAstroBBodyLambdaDT       : Derivative of black body function
       - yocoAstroESOStampToJulianDay : Get julian day from an ESO time string
       - yocoAstroExtinction          : Extinction law
       - yocoAstroExtractBand         : Returns the values of standard atmospheric bands
       - yocoAstroFluxToJy            : Return the flux in Jansky
       - yocoAstroFluxToMag           : Return the magnitude, from a flux measurement
       - yocoAstroJY2000ToJulianDay   : Get Julian Day from Julian Year Epoch 2000
       - yocoAstroJulianDay           : Compute the Julian day
       - yocoAstroJulianDayNow        : Compute the Julian day of now
       - yocoAstroJulianDayToESOStamp : return an ESO time stamp from a Julian day
       - yocoAstroJulianDayToGregorian: return Gregorian date, from a Julian day
       - yocoAstroJulianDayToJY2000   : Get Julian Year Epoch 2000 from Julian Day
       - yocoAstroJulianDayToGMST     : Get Greenwich mean sidereal time from Julian Day
       - yocoAstroJyToFlux            : Compute the flux per unit of wavelength
       - yocoAstroMagToFlux           : from a magnitude, return the flux
       - yocoAstroMagToPhoton         : from a magnitude, return the nb. of photons
       - yocoAstroOrbit               : compute the orbit versus time
       - yocoAstroOrbitTest           : function to validate "yocoAstroOrbit"
       - yocoAstroPlotNorthEast       : plot "N-E" axes arrows
       - yocoAstroPlotOrbitTrace      : plot an orbit
       - yocoAstroVapSat              : Get partial pressure of vapor for a given element
       - yocoGetSpecType              : Returns the spectral type of a star from its nomenclature

       SEE ALSO
       yoco
    */
{
    version = strpart(strtok("$Revision: 1.20 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoAstro;
    }   
    return version;
}

/***************************************************************************/

local yocoASTRO_SPECTRAL_BAND;
/* DOCUMENT yocoASTRO_SPECTRAL_BAND
   
   DESCRIPTION
   Structure containing spectral bands information.

   PARAMETERS
   - wl : double, mean wavelength
   - wd : double, spectral width
   - f0 : double, flux for magnitude 0
*/
struct yocoASTRO_SPECTRAL_BAND {
    double wl, wd, f0;
};

local yocoASTRO_SPECTRAL_BAND_LIST;
/* DOCUMENT yocoASTRO_SPECTRAL_BAND_LIST
   
   DESCRIPTION
   Structure containing information on several spectral bands

   PARAMETERS
   - mean wavelength      : U, B, V, etc.
   - width                : Uwd, Bwd, Vwd, etc.
   - flux for magnitude 0 : Uf0, Bf0, Vf0

   CAUTIONS
   The following bands only are coded:
   U, B, V, R, I, J, H, K, L, M, N, Q, K12,
   K25, K60, K100;
*/
struct yocoASTRO_SPECTRAL_BAND_LIST {
  double U, P, B, V, R, I, J, H, K, K2m, L, M, N, Q, K12, K25, K60, K100;
  double Uwd, Pwd, Bwd, Vwd, Rwd, Iwd, Jwd, Hwd, Kwd, K2mwd, Lwd, Mwd, Nwd, Qwd, K12wd, K25wd, K60wd, K100wd;
  double Uf0, Pf0, Bf0, Vf0, Rf0, If0, Jf0, Hf0, Kf0, K2mf0, Lf0, Mf0, Nf0, Qf0, K12f0, K25f0, K60f0, K100f0;
};

/***************************************************************************/

/* Local definition to setup a common help
   Initialization is done above       */
local yocoASTRO_UNIT_SYSTEM;
local yocoAstroSI;
local yocoAstroCGS;
/* DOCUMENT yocoAstroSI
   yocoAstroCGS
   yocoASTRO_UNIT_SYSTEM

   DESCRIPTION
   Structure containing values of main units (mostly CGS and SI units with
   their most used multiples) and some (astro-)physical quantities. This
   structure has two instances called yocoAstroSI and yocoAstroCGS, which
   express these units and quantities in SI (MKSA) and CGS.

   PARAMETERS
   Most units are called by their standard name.  Some have non-trivial
   names:
   hr (hour), ps suffix (per second), mu prefix (micro), angstroem,
   Ohm (ohm), tr (2pi rad), deg (degree) as (second of arc), 
   mmHg (pressure of 1 mm of mercury), Jy (1e-26 W/m�), amu (atomic
   mass unit), Rsun, Msun, Lsun (radius, mass and luminosity of the
   sun), Mearth, Rearth (mass and radius of the earth), hbar (reduced
   Planck constant), kB (Boltzman constant), Grav (gravity constant)
   
   CAUTIONS
   candela, lux and lumen are not supported.
   
   EXAMPLES      
   Express 100 light years in solar radii
   > lyr_rsun = (100 * yocoAstroSI.c * yocoAstroSI.yr) / yocoAstroSI.Rsun

   Mass of 0.13 mmol of carbon 14.
   > mass_mg  = (0.13 * yocoAstroSI.mmol)  * yocoAstroSI.Na *
   ( 14 * yocoAstroSI.u) / yocoAstroSI.mg
*/

struct yocoASTRO_UNIT_SYSTEM  {
    double tr, rad, deg, as, mas, muas;
    double mus, ms, s, mn, hr, day, yr, Myr, Gyr;
    double Hz, kHz, MHz, GHz, Ci;
    double fm, pm, nm, mum, mm, cm, m, km, Rearth, Rsun, AU, pc, kpc, Mpc, Gpc;
    double mL, cL, L, hL;
    double cmps, mps, kps, kph, c;
    double mug, mg, g, kg, t, me, mp, amu, Msun, Mearth;
    double N, daN, kgf, dyn;
    double eV, keV, MeV, GeV, erg, mJ, J, kJ, MJ, GJ;
    double muW, mW, W, kW, MW, GW, TW, ergps, Lsun;
    double muT, mT, T, muG, mG, G;
    double mumol, mmol, mol;
    double muK, mK, K;
    double mu0;
    double mJy, Jy;
    double C, epsilon0, e;
    double muA, mA, A;
    double muV, mV, V, kV;
    double pF, nF, muF, mF, F;
    double muH, mH, H;
    double Ohm, kOhm, MOhm;
    double muS, mS, S;
    double Pa, hPa, mbar, bar, atm, mmHg;
    double Grav, kB, Na, h, hbar, sigma, alpha;
    yocoASTRO_SPECTRAL_BAND_LIST band;
    double _c1, _c2;
};

/***************************************************************************/

yocoAstroSI = yocoASTRO_UNIT_SYSTEM(
                                    tr        = 3.141592653590e+00,
                                    rad       = 1e+00,
                                    deg       = 1.745329251994e-02,
                                    as        = 4.848136811095e-06,
                                    mas       = 4.848136811095e-09,
                                    muas      = 4.848136811095e-12,
                                    ms        = 1e-03,
                                    s         = 1e+00,
                                    mn        = 6e+01,
                                    hr        = 3.6e+03,
                                    yr        = 3.15569259747e+07,
                                    Myr       = 3.15569259747e+13,
                                    Gyr       = 3.15569259747e+16,
                                    day       = 8.64e+04,
                                    Hz        = 1e+00,
                                    kHz       = 1e+03,
                                    MHz       = 1e+06,
                                    GHz       = 1e+09,
                                    Ci        = 3.7e+10,
                                    fm        = 1e-15, 
                                    pm        = 1e-12,
                                    nm        = 1e-09,
                                    mum       = 1e-06,
                                    mm        = 1e-03,
                                    cm        = 1e-02,
                                    m         = 1e+00,
                                    km        = 1e+03,
                                    Rsun      = 6.9598e+08,
                                    Rearth    = 6.378164e+06,
                                    AU        = 1.495985e+11,
                                    pc        = 3.085e+16,
                                    kpc       = 3.085e+19,
                                    Mpc       = 3.085e+22,
                                    Gpc       = 3.085e+25,
                                    mL        = 1e-06,
                                    cL        = 1e-04,
                                    L         = 1e-03,
                                    hL        = 1e-01,
                                    cmps      = 1e-02,
                                    mps       = 1e+00,
                                    kps       = 1e+03,
                                    kph       = 2.777777777778e-01,
                                    c         = 2.99792453e+08,
                                    mug       = 1e-09,
                                    mg        = 1e-06,
                                    g         = 1e-03,
                                    kg        = 1e+00,
                                    t         = 1e+03,
                                    me        = 9.10938188e-33,
                                    mp        = 1.67262158e-27,
                                    amu       = 1.66053873e-27,
                                    Msun      = 1.9892e+30,
                                    Mearth    = 5.976e+24,
                                    N         = 1e+00,
                                    daN       = 1e+01,
                                    kgf       = 9.80665,
                                    dyn       = 1e-05,
                                    eV        = 1.602176462e-19,
                                    keV       = 1.602176462e-16,
                                    MeV       = 1.602176462e-13,
                                    GeV       = 1.602176462e-10,
                                    erg       = 1e-07,
                                    mJ        = 1e-03,
                                    J         = 1e+00,
                                    kJ        = 1e+03,
                                    MJ        = 1e+06,
                                    GJ        = 1e+09,
                                    muW       = 1e-06,
                                    mW        = 1e-03,
                                    W         = 1e+00,
                                    mJy       = 1e-29,
                                    Jy        = 1e-26,
                                    kW        = 1e+03,
                                    MW        = 1e+06,
                                    GW        = 1e+09,
                                    TW        = 1e+12,
                                    ergps     = 1e-07,
                                    Lsun      = 3.826e+26,
                                    muT       = 1e-06,
                                    mT        = 1e-03,
                                    T         = 1e+00,
                                    muG       = 1e-10,
                                    mG        = 1e-07,
                                    G         = 1e-04,
                                    mu0       = 1.2566370615e-6,
                                    C         = 1e+00,
                                    epsilon0  = 8.854187817e-12,
                                    e         = 1.602176462e-19,
                                    muA       = 1e-06,
                                    mA        = 1e-03,
                                    A         = 1e+00,
                                    muV       = 1e-06,
                                    mV        = 1e-03,
                                    V         = 1e+00,
                                    kV        = 1e+03,
                                    muH       = 1e-06,
                                    mH        = 1e-03,
                                    H         = 1e+00,
                                    pF        = 1e-12,
                                    nF        = 1e-09,
                                    muF       = 1e-06,
                                    mF        = 1e-03,
                                    F         = 1e+00,
                                    Ohm       = 1e+00,
                                    kOhm      = 1e+03,
                                    MOhm      = 1e+06,
                                    muS       = 1e-06,
                                    mS        = 1e-03,
                                    S         = 1e+00,
                                    Pa        = 1e+00,
                                    hPa       = 1e+02,
                                    mbar      = 1e+02,
                                    bar       = 1e+05,
                                    atm       = 1.01325e+05,
                                    mmHg      = 1.3332e+02,
                                    Na        = 6.02214199e23,
                                    Grav      = 6.673e-11,
                                    kB        = 1.3806503e-23,
                                    sigma     = 5.670400e-8,
                                    muK       = 1e-06,
                                    mK        = 1e-03,
                                    K         = 1e+00,
                                    mumol     = 1e-06, 
                                    mmol      = 1e-03, 
                                    mol       = 1e+00,
                                    h         = 6.62606876e-34,
                                    hbar      = 1.05457160e-34,
                                    alpha     = 1/137.04,
                                    band      = yocoASTRO_SPECTRAL_BAND_LIST(
                                                                             U    = 3.67e-7, Uwd = 6.60e-8, Uf0    = 3.9811e-02, 
                                                                             B    = 4.36e-7, Bwd = 9.40e-8, Bf0    = 6.3096e-02,
                                                                             P    = 4.25e-7,                Pf0    = 6.3096e-02,
                                                                             V    = 5.45e-7, Vwd = 8.80e-8, Vf0    = 3.6308e-02,
                                                                             R    = 6.38e-7, Rwd = 1.38e-7, Rf0    = 2.2387e-02,
                                                                             I    = 7.97e-7, Iwd = 1.49e-7, If0    = 1.1482e-02,
                                                                             J    = 1.22e-6, Jwd = 2.13e-7, Jf0    = 3.1623e-03,
                                                                             H    = 1.63e-6, Hwd = 3.07e-7, Hf0    = 1.1482e-03,
                                                                             K    = 2.19e-6, Kwd = 3.90e-7, Kf0    = 3.9811e-04,
                                                                             L    = 3.45e-6, Lwd = 4.72e-7, Lf0    = 7.0795e-05,
                                                                             M    = 4.75e-6, Mwd = 4.60e-7, Mf0    = 2.0417e-05,
                                                                             N    = 1.02e-5, Nwd = 4.00e-6, Nf0    = 1.2303e-06,
                                                                             Q    = 2.10e-5, Qwd = 5.00e-6, Qf0    = 6.7608e-08,
                                                                             K12  = 1.20e-5,                K12f0  = 5.89175e-07,
                                                                             K25  = 2.50e-5,                K25f0  = 3.22817e-08,
                                                                             K60  = 5.00e-5,                K60f0  = 9.90981e-10,
                                                                             K100 = 1.00e-4,                K100f0 = 1.28911e-10
                                                                             ),
                                    _c1       = 1.19107e-16,
                                    _c2       = 0.0143883
                                    );

/***************************************************************************/

yocoAstroCGS = yocoASTRO_UNIT_SYSTEM(
                                     tr        = 3.141592653590e+00,
                                     rad       = 1e+00,
                                     deg       = 1.745329251994e-02,
                                     as        = 4.848136811095e-06,
                                     mas       = 4.848136811095e-09,
                                     muas      = 4.848136811095e-12,
                                     ms        = 1e-03,
                                     s         = 1e+00,
                                     mn        = 6e+01,
                                     hr        = 3.6e+03,
                                     day       = 8.64e+04,
                                     yr        = 3.15569259747e+07,
                                     Myr       = 3.15569259747e+13,
                                     Gyr       = 3.15569259747e+16,
                                     Hz        = 1e+00,
                                     kHz       = 1e+03,
                                     MHz       = 1e+06,
                                     GHz       = 1e+09,
                                     Ci        = 3.7e+10,
                                     fm        = 1e-13, 
                                     pm        = 1e-10,
                                     nm        = 1e-07,
                                     mum       = 1e-04,
                                     mm        = 1e-01,
                                     cm        = 1e+00,
                                     m         = 1e+02,
                                     km        = 1e+05,
                                     Rearth    = 6.378164e+08,
                                     Rsun      = 6.9598e+10,
                                     AU        = 1.495985e+13,
                                     pc        = 3.085e+18,
                                     kpc       = 3.085e+21,
                                     Mpc       = 3.085e+24,
                                     Gpc       = 3.085e+27,
                                     mL        = 1e+00,
                                     cL        = 1e+01,
                                     L         = 1e+03,
                                     hL        = 1e+05,
                                     cmps      = 1e+00,
                                     mps       = 1e+02,
                                     kps       = 1e+05,
                                     kph       = 2.777777777778e+01,
                                     c         = 2.99792453e+10,
                                     mug       = 1e-06,
                                     mg        = 1e-03,
                                     g         = 1e+00,
                                     kg        = 1e+03,
                                     t         = 1e+06,
                                     me        = 9.10938188e-30,
                                     mp        = 1.67262158e-24,
                                     amu       = 1.66053873e-24,
                                     Mearth    = 5.976e+27,
                                     Msun      = 1.9892e+33,
                                     N         = 1e+05,
                                     daN       = 1e+06,
                                     kgf       = 9.80665e+05,
                                     dyn       = 1e+00,
                                     eV        = 1.602176462e-12,
                                     keV       = 1.602176462e-09,
                                     MeV       = 1.602176462e-06,
                                     GeV       = 1.602176462e-03,
                                     erg       = 1e+00,
                                     mJ        = 1e+04,
                                     J         = 1e+07,
                                     kJ        = 1e+10,
                                     MJ        = 1e+13,
                                     GJ        = 1e+16,
                                     muW       = 1e+01,
                                     mW        = 1e+04,
                                     W         = 1e+07,
                                     kW        = 1e+10,
                                     MW        = 1e+13,
                                     GW        = 1e+16,
                                     TW        = 1e+19,
                                     ergps     = 1e+00,
                                     Lsun      = 3.826e+33,
                                     mJy       = 1e-26,
                                     Jy        = 1e-23,
                                     muT       = 1e-02,
                                     mT        = 1e+01,
                                     T         = 1e+04,
                                     muG       = 1e-06,
                                     mG        = 1e-03,
                                     G         = 1e+00,
                                     mu0       = 1.,
                                     C         = 1e+00,
                                     epsilon0  = 8.854187817e-12,
                                     e         = 1.602176462e-19,
                                     muA       = 1e-06,
                                     mA        = 1e-03,
                                     A         = 1e+00,
                                     muV       = 1e-06,
                                     mV        = 1e-03,
                                     V         = 1e+00,
                                     kV        = 1e+03,
                                     muH       = 1e-06,
                                     mH        = 1e-03,
                                     H         = 1e+00,
                                     pF        = 1e-12,
                                     nF        = 1e-09,
                                     muF       = 1e-06,
                                     mF        = 1e-03,
                                     F         = 1e+00,
                                     Ohm       = 1e+00,
                                     kOhm      = 1e+03,
                                     MOhm      = 1e+06,
                                     muS       = 1e-06,
                                     mS        = 1e-03,
                                     S         = 1e+00,
                                     Pa        = 1e+01,
                                     hPa       = 1e+03,
                                     mbar      = 1e+03,
                                     bar       = 1e+06,
                                     atm       = 1.01325e+06,
                                     mmHg      = 1.3332e+03,
                                     Na        = 6.02214199e23,
                                     Grav      = 6.673e-08,
                                     kB        = 1.3806503e-16,
                                     sigma     = 5.670400e-5,
                                     muK       = 1e-06,
                                     mK        = 1e-03,
                                     K         = 1e+00,
                                     h         = 6.62606876e-27,
                                     hbar      = 1.05457160e-27,
                                     alpha     = 1/137.04,
                                     mumol     = 1e-06, 
                                     mmol      = 1e-03, 
                                     mol       = 1e+00,
                                     band      = yocoASTRO_SPECTRAL_BAND_LIST(
                                                                              U    = 3.67e-5, Uwd = 6.60e-8, Uf0    = 3.9811e-01,
                                                                              P    = 4.25e-7,                Pf0    = 6.3096e-01,
                                                                              B    = 4.36e-5, Bwd = 9.40e-8, Bf0    = 6.3096e-01,
                                                                              V    = 5.45e-5, Vwd = 8.80e-8, Vf0    = 3.6308e-01,
                                                                              R    = 6.38e-5, Rwd = 1.38e-7, Rf0    = 2.2387e-01,
                                                                              I    = 7.97e-5, Iwd = 1.49e-7, If0    = 1.1482e-01,
                                                                              J    = 1.22e-4, Jwd = 2.13e-7, Jf0    = 3.1623e-02,
                                                                              H    = 1.63e-4, Hwd = 3.07e-7, Hf0    = 1.1482e-02,
                                                                              K    = 2.19e-4, Kwd = 3.90e-7, Kf0    = 3.9811e-03,
                                                                              L    = 3.45e-4, Lwd = 4.72e-7, Lf0    = 7.0795e-04,
                                                                              M    = 4.75e-4, Mwd = 4.60e-7, Mf0    = 2.0417e-04,
                                                                              N    = 1.02e-3, Nwd = 4.00e-6, Nf0    = 1.2303e-05,
                                                                              Q    = 2.10e-3, Qwd = 5.00e-6, Qf0    = 6.7608e-06,
                                                                              K12  = 1.20e-3,                K12f0  = 5.8918e-06, 
                                                                              K25  = 2.50e-3,                K25f0  = 3.2282e-07,
                                                                              K60  = 5.00e-3,                K60f0  = 9.9098e-09,
                                                                              K100 = 1.00e-3,                K100f0 = 1.2891e-09
                                                                              ),
                                     _c1       = 1.19107e-5,
                                     _c2       = 1.43883
                                     );


/****************************************************************************/
/*                              Johnson system,                             */
/*                  from Allen's Astrophysical Quantities,                  */
/*        Fourth Edition, 2001, Arthur N. Cox (ed.), Springer-Verlag        */
/*                                    and                                   */
/* Johnson system "+", from the spitzer webpage magnitude to flux converter */
/*           http://ssc.spitzer.caltech.edu/tools/magtojy/ref.html          */
/*                       Zeropoint is defined in W/m^2/m                    */
/*                           Bandwidths found on                            */
/*       http://www.starlink.rl.ac.uk/star/docs/sc6.htx/node10.html         */
/****************************************************************************/

yocoAstroJohnsonSystem =
    yocoASTRO_UNIT_SYSTEM(
                          band      = 
                          yocoASTRO_SPECTRAL_BAND_LIST(
                                                       U    = 3.65e-7, Uwd = 6.8e-8, Uf0    = 4.22e-2, 
                                                       B    = 4.4e-7, Bwd = 9.8e-8,  Bf0    = 6.4e-2,
                                                       V    = 5.5e-7, Vwd = 8.9e-8,  Vf0    = 3.75e-2,
                                                       R    = 7.1e-7, Rwd = 2.2e-7,  Rf0    = 1.75e-2,
                                                       I    = 9.7e-7, Iwd = 2.4e-7,  If0    = 8.4e-3,
                                                       J    = 1.25e-6, Jwd = 3.8e-7, Jf0    = 3.07563e-3,
                                                       H    = 1.60e-6, Hwd = 4.8e-7, Hf0    = 1.25889e-3,
                                                       K    = 2.22e-6, Kwd = 7.0e-7, Kf0    = 4.05733e-4,
                                                       L    = 3.54e-6, Lwd = 1.2e-6, Lf0    = 6.8898e-05,
                                                       M    = 4.80e-6,               Mf0    = 2.21201e-05,
                                                       N    = 10.6e-6,               Nf0    = 9.60531e-07,
                                                       Q    = 21.0e-6,               Nf0    = 6.39013e-08
                                                       ));

/***************************************************************************/
/*                      UKIRT system, from UKIRT webpage                   */
/*   http://www.jach.hawaii.edu/UKIRT/astronomy/calib/phot_cal/conver.html */
/*                      Zeropoint is defined in W/m^2/m                    */
/***************************************************************************/

yocoAstroUKIRT_System =
    yocoASTRO_UNIT_SYSTEM(
                          band      = 
                          yocoASTRO_SPECTRAL_BAND_LIST(
                                                       V    = 0.5556e-6,  Vf0    = 3.44e-2,
                                                       I    = 0.9e-6,     If0    = 8.25e-3,
                                                       J    = 1.25e-6,    Jf0    = 3.07e-3,
                                                       H    = 1.65e-6,    Hf0    = 1.12e-3,
                                                       K    = 2.2e-6,     Kf0    = 4.07e-4,
                                                       L    = 3.45e-6,    Lf0    = 7.30e-5,
                                                       M    = 4.8e-6,     Mf0    = 2.12e-5,
                                                       N    = 1.01e-5,    Nf0    = 1.17e-6,
                                                       Q    = 2.00e-5,    Qf0    = 7.80e-8
                                                       ));

/***************************************************************************/
/*                        2mass system extracted from                      */
/*   http://www.ipac.caltech.edu/2mass/releases/allsky/doc/sec6_4a.html    */
/*                       Zeropoint is defined in W/m^2/m                   */
/***************************************************************************/

yocoAstro2MASS_System =
    yocoASTRO_UNIT_SYSTEM(
                          band      = 
                          yocoASTRO_SPECTRAL_BAND_LIST(
                                                       J    = 1.235e-6, Jwd = 0.162e-6,  Jf0    = 3.129e-3,
                                                       H    = 1.662e-6, Hwd = 0.251e-6,  Hf0    = 1.133e-3,
                                                       K    = 2.159e-6, Kwd = 0.262e-6,  Kf0    = 4.283e-4
                                                       ));

/***************************************************************************/
/*                        DENIS system extracted from                      */
/*                   Fouque et al. A&A 141, 313{317 (2000)                 */
/*                      Zeropoint is defined in W/m^2/m                    */
/***************************************************************************/

yocoAstroDenisSystem =
    yocoASTRO_UNIT_SYSTEM(
                          band      = 
                          yocoASTRO_SPECTRAL_BAND_LIST(
                                                       I    = 0.791e-6,                  If0    = 1.2e-2,
                                                       J    = 1.228e-6,                  Jf0    = 3.17e-3,
                                                       K    = 2.145e-6,                  Kf0    = 4.34e-4
                                                       ));


/***************************************************************************
 *  Others additive constants
 ***************************************************************************/


func yocoGetSpecType(spType, &BminusV)
    /* DOCUMENT yocoGetSpecType(spType, &BminusV)

       DESCRIPTION
       Returns the B minus V index from a SIMBAD standard spectral type

       PARAMETERS
       - spType : input spectral type
       - BminusV: output B minus V

       EXAMPLES

       SEE ALSO
    */
{
    Harvard=["O","B","A","F","G","K","M"];
    H = strpart(spType,1:1);
    HF = where(H==Harvard);
        
    test = where(Harvard == H);
    
    if (numberof(test)==0)
    {
        return 0;
    }    
    else
    {
	temp = yocoStr2Double(strpart(spType,2:4));
        F = yocoStr2Long(strpart(spType,2:4));
    }
    
    test = F==temp;
    
    if (test)
        tail = strpart(spType,3:);
    else
        tail = strpart(spType,5:);
        
    class = "";
    permis=["I","V","a","b","/","-"];
        
    n = strlen(tail);
    for(i=1;i<=n;i++)
    {
        l = strpart(tail,i:i);
        if(anyof(l==permis))
            class = class+l;
    }

    if(class=="")
        return 0;

    classs = yocoStrSplit(yocoStrReplace(class,"/","-"),"-");
    if(numberof(classs)>=2)
        if(classs(0)==string(nil))
            classs = classs(:-1);

    class = classs;

    bminusv = 0.0;
    
    for(k=1;k<=numberof(class);k++)
    {
        bminusv = bminusv + _yocoAstroGetBminusV(F,HF,class(k));
    }
    BminusV = bminusv / numberof(class);
    // write, spType, H, temp, class;
    return BminusV;
}

/****************************************************************************/
   
func _yocoAstroGetBminusV(F, HF, class)
    /* DOCUMENT _yocoAstroGetBminusV(F, HF, class)

       DESCRIPTION

       PARAMETERS
       - F    : 
       - HF   : 
       - class: 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    if(class=="I")
    {
        x=[9,12,15,18,20,22,25,30,32,35,38,40,42,45,48,50,52,55,60,62,65];
        BV=[-0.27,-0.17,-0.10,-0.03,0.01,0.03,0.09,0.17,0.23,0.32,0.56,0.76,0.87,1.02,1.14,1.25,1.36,1.60,1.67,1.71,1.80];
        BminusV=interp(BV,x,F+10.*(HF-1));
    }
    else if(class=="II")
    {
        x1=[9,12,15,18,20,22,25,30,32,35,38,40,42,45,48,50,52,55,60,62,65];
        BV1=[-0.27,-0.17,-0.10,-0.03,0.01,0.03,0.09,0.17,0.23,0.32,0.56,0.76,0.87,1.02,1.14,1.25,1.36,1.60,1.67,1.71,1.80];
        BminusV1=interp(BV1,x1,F+10.*(HF-1));
        x2=[45,48,50,52,55,60,62,65];
        BV2=[0.86,0.94,1.00,1.16,1.50,1.56,1.60,1.63];
        BminusV2=interp(BV2,x2,F+10.*(HF-1));
        BminusV=(BminusV1+BminusV2)/2.;
    }
    else if(class=="III")
    {
        x=[45,48,50,52,55,60,62,65];
        BV=[0.86,0.94,1.00,1.16,1.50,1.56,1.60,1.63];
        BminusV=interp(BV,x,F+10.*(HF-1));
    }
    else if(class=="IV")
    {
        x1=[45,48,50,52,55,60,62,65];
        BV1=[0.86,0.94,1.00,1.16,1.50,1.56,1.60,1.63];
        BminusV1=interp(BV1,x1,F+10.*(HF-1));
        x2=[5,9,10,12,15,18,20,22,25,30,32,35,38,40,42,45,48,50,52,55,60,62,65];
        BV2=[-0.33,-0.31,-0.30,-0.24,-0.17,-0.11,-0.02,0.05,0.15,0.30,0.35,0.44,0.52,0.58,0.63,0.68,0.74,0.81,0.91,1.15,1.40,1.49,1.64];
        BminusV2=interp(BV2,x2,F+10.*(HF-1));
        BminusV=(BminusV1+BminusV2)/2.;
    }
    else if(class=="V")
    {
        x=[5,9,10,12,15,18,20,22,25,30,32,35,38,40,42,45,48,50,52,55,60,62,65];
        BV=[-0.33,-0.31,-0.30,-0.24,-0.17,-0.11,-0.02,0.05,0.15,0.30,0.35,0.44,0.52,0.58,0.63,0.68,0.74,0.81,0.91,1.15,1.40,1.49,1.64];
        BminusV=interp(BV,x,F+10.*(HF-1));
    }
    else
        return 0;
    return BminusV;
}


/**************************************************************************
 *  Others additive constants
 **************************************************************************/

local yocoAstroAbsoluteZero;
/* DOCUMENT yocoAstroAbsoluteZero

   DESCRIPTION
   Others additive constants that are not part of a conventional Unit System.
*/

yocoAstroAbsoluteZero = -273.15;


/**************************************************************************
 *  Black Body functions 
 **************************************************************************/

func yocoAstroBBody(T, unitSys)
    /* DOCUMENT yocoAstroBBody(T, unitSys)
       yocoAstroBBody(T, unitSys)

       DESCRIPTION
       Integrated Black body function computed with the Stefan-Boltzmann law. By
       default the unitSys is yocoAstroSI, but you can specify another one
       (yocoAstroCGS).
   
       PARAMETERS
       - T      : temperature (K, K)
       - unitSys: 
   
       RETURN VALUES
       Return the energy radiated (W/m2, erg/s/cm2)
    */
{
    if (is_void(unitSys)) unitSys = yocoAstroSI;
    if (structof(unitSys) != yocoASTRO_UNIT_SYSTEM )
        error,"unitSys should be a yocoASTRO_UNIT_SYSTEM";

    return unitSys.sigma * T^4;
}

/***************************************************************************/

func yocoAstroBBodyLambda(lambda, T, unitSys)
    /* DOCUMENT yocoAstroBBodyLambda(lambda, T, unitSys)
       yocoAstroBBodyLambda(lambda, T, unitSys)

       DESCRIPTION
       Black body function computed with the Planck's law of black-body
       radiation. By default the unitSys is yocoAstroSI, but you can specify
       another one (yocoAstroCGS).
   
       PARAMETERS
       - lambda : wavelength (m, cm)
       - T      : temperature (K, K)
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'
     
       RETURN VALUES
       Return the energy radiated (W/m2/m, erg/s/cm2/cm)
    */
{
    if (is_void(unitSys)) unitSys = yocoAstroSI;
    if (structof(unitSys) != yocoASTRO_UNIT_SYSTEM )
        error,"unitSys should be a yocoASTRO_UNIT_SYSTEM";

    mask = abs(unitSys._c2 / (T*lambda))>700;
    if(numberof(where(mask))==0)
        flambda = unitSys._c1 / lambda^5 / (exp(unitSys._c2 / (T*lambda)) - 1);
    else
    {
        flambda = lambda;
        flambda(where(mask)) = 0.0;
        flambda(where(!mask)) = unitSys._c1 / lambda(where(!mask))^5 / (exp(unitSys._c2 / (T*lambda(where(!mask)))) - 1);
    }

    return flambda;
}

/***************************************************************************/

func yocoAstroBBodyLambdaDT(lambda, T, unitSys)
    /* DOCUMENT yocoAstroBBodyLambdaDT(lambda, T, unitSys)

       DESCRIPTION
       Derivative of black body function in respect to T.
       By default the unitSys is yocoAstroSI, but you can
       specify another one (yocoAstroCGS).
   
       PARAMETERS
       - lambda : wavelength (m, cm)
       - T      :      temperature (K, K)
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'
   
       RETURN VALUES
       Return the derivative (W/m2/m/K, erg/s/cm2/cm/K)
    */
{
    if (is_void(unitSys)) unitSys = yocoAstroSI;
    if (structof(unitSys) != yocoASTRO_UNIT_SYSTEM )
        error,"unitSys should be a yocoASTRO_UNIT_SYSTEM";

    return unitSys._c1 / lambda^5 / (exp(unitSys._c2 / (T*lambda)) - 1)^2   \
        * exp(unitSys._c2/(T*lambda)) * unitSys._c2/(T^2*lambda);
}


/*************************************************************************
 *  Astrophysical extinction 
 **************************************************************************/

func yocoAstroExtinction(wavelength, Av, Rv, unitSys=, extLaw=)
    /* DOCUMENT yocoAstroExtinction(wavelength, Av, Rv, unitSys=, extLaw=)

       DESCRIPTION
       Extinction law assuming its value is know in the visible.
       By default the unitSys is yocoAstroSI, but you can specify another one
       (yocoAstroCGS).
   
       PARAMETERS
       - wavelength: wavelenth (m, cm)
       - Av        : extinction in the visible
       - Rv        : 
       - unitSys   : a fully defined 'yocoASTRO_UNIT_SYSTEM'
       - extLaw    : 
   
       RETURN VALUES
       Return the extinction.
   
       CAUTIONS
       The extinction law versus lambda is hard-coded and so you may want to
       check it. The law is defined between 1.e-5 and 1.e0 centimeters.
    */
{
    /* default unit system*/
    if (is_void(unitSys)) unitSys = yocoAstroSI;
    if (structof(unitSys) != yocoASTRO_UNIT_SYSTEM )
        error,"unitSys should be a yocoASTRO_UNIT_SYSTEM";

    if(is_void(extLaw))
        extLaw = "JB";

    if(extLaw=="JB")
    {
        /* Hard Coded JB's extinction law
           (contact J-B Lebouquin for details) ;-) */
        local bigr, wavlaw, extlaw;  
        bigr = 3.1;
        wavlaw = [1.e-5,1.05e-5,1.11e-5,1.18e-5,1.25e-5,
                  1.39e-5,1.49e-5,1.6e-5,1.7e-5,1.8e-5,1.9e-5,2.e-5,2.1e-5,
                  2.19e-5,2.3e-5,2.4e-5,2.5e-5,2.74e-5,3.44e-5,4.e-5,4.4e-5,
                  5.5e-5,7.e-5,9.e-5,1.25e-4,2.2e-4,3.4e-4,1.e0];
        extlaw = [11.3e0,9.8e0,8.45e0,7.45e0,6.55e0,5.39e0,
                  5.05e0,5.02e0,4.77e0,4.65e0,4.9e0,5.52e0,6.23e0,6.57e0,5.77e0,
                  4.9e0,4.19e0,3.1e0,1.8e0,1.3e0,1.e0,0.e0,-0.78e0,-1.6e0,
                  -2.23e0,-2.72e0,-2.94e0,-3.1e0];
        ext = (interp(extlaw, wavlaw, wavelength/unitSys.cm)+bigr)*Av/bigr;
    }
    else if(extLaw=="cardelli")
        // Extinction law from the article Cardelli et al. 1989, ApJ, 345, 245
    {
        x = 1.0/(wavelength/unitSys.mum);
        Alambda = a = b = array(0.0,dimsof(x));
        
        idx1 = where((x>=0.2)&(x<=1.1));
        if(numberof(idx1)!=0)
        {
            a(idx1) =  0.574 * x(idx1)^1.61;
            b(idx1) = -0.527 * x(idx1)^1.61;
        }
        
        idx2 = where((x>=1.1)&(x<=3.3));
        if(numberof(idx2)!=0)
        {
            y = x(idx2) - 1.82;
            a(idx2) = yocoMathPoly(y, [1, 0.17699, -0.50447, -0.02427,  0.72085, 0.01979, -0.77530,  0.32999]);
            b(idx2) = yocoMathPoly(y, [0, 1.41338,  2.28305,  1.07233, -5.38434, -0.62251, 5.30260, -2.09002]);
        }
        
        idx3 = where((x>=3.3)&(x<=8.0));
        if(numberof(idx3)!=0)
        {
            Fa = Fb = array(0.0,numberof(idx3))
                fx = where((x(idx3)>=5.9)&(x(idx3)<=8.0));
            if(anyof(fx))
            {
                Fa(fx) = -0.04473 * (x(idx3)(fx) - 5.9)^2 - 0.009779 * (x(idx3)(fx)-5.9)^3;
                Fb(fx) =  0.2130  * (x(idx3)(fx) - 5.9)^2 + 0.1207   * (x(idx3)(fx)-5.9)^3;
            }
            a(idx3) =  1.752 - 0.316 * x(idx3) - 0.104 / ((x(idx3) - 4.67)^2 + 0.341) + Fa;
            b(idx3) = -3.090 + 1.825 * x(idx3) + 1.206 / ((x(idx3) - 4.62)^2 + 0.263) + Fb;
        }

        idx4 = where((x>=8.0)&(x<=10));
        if(numberof(idx4)!=0)
        {
            a(idx4) = -1.073 - 0.628 * (x(idx4)-8.0) + 0.137 * (x(idx4)-8.0)^2 - 0.070 * (x(idx4)-8.0)^3;
            b(idx4) = 13.670 + 4.257 * (x(idx4)-8.0) - 0.420 * (x(idx4)-8.0)^2 + 0.374 * (x(idx4)-8.0)^3;
        }
        Alambda = a + b / Rv;
        ext = Alambda * Av;
    }
    
    return ext;
}

/**************************************************************************
 *  Atmospheric dispersion
 **************************************************************************/


func yocoAstroAirIndex(lambda, T, P, F, xc, law=)
    /* DOCUMENT yocoAstroAirIndex(lambda, T, P, F, xc, law=)

       Compute the air indice using several formulae:
       - Owens, 1967, p-56 Eq.32
       - Vannier (priv. comm., based on Ciddor article)
       - Ciddor, 1996, applied optics, 35, 1566 (wet air, visible & NIR)
       - Mathar, 2007, journal of optics A, 9, 470 (wet air + CO2, only JHK bands implemented here)

       PARAMETERS
       - lambda: Wavelength (in meters)
       - T     : double: temperature in [K]
       - P     : double: pressure in [Pascal]
       - F     : double: partial pressure of water vapor in [Pascal] for Owens law, otherwise, it is the fractional amount of water vapor [%]
       - xc    : partial pressure of CO2
       - law   : Law for computing the air index (can be "Owens", "Vannier", "Ciddor", "Mathar")

       RETURN VALUES
       - r, double: refractive index of air, the index is also define as
       n = 1 + r.1e-8
     
       SEE ALSO: 
    */
{
    if(is_void(law))
        law = "Owens";
    
    // Owens law
    if(law=="Owens")
    {
        local n,t,p,f,s2;
        if(is_void(F)) F=0.;

        /* conversion */
        t = T - 273.15;        // t in [deg Centigrade]
        p = P / 1.333224e+02;  // p in [torricelli]
        f = F / 1.333224e+02;  // f in [torricelli]
        lambda *= 1.e10*1.e-4; // lambda in [micron]
        s2 = 1./lambda^2.;
  
        /* air refraction , Owens, 1967, p-56  Eq 32 */
        r = (8342.13 + 2406030./(130.-s2) + 15997/(38.9-s2)) *
            (p/720.775) *
            (1 + p*(0.817 - 0.0133*t)*1e-6) / (1. + 0.0036610*t) +
            f*(5.722 - 0.0457*s2); 
    }
    // formulae from Ciddor (1996, applied optics, 35, 1566)
    // and ideas from Vannier for dry air index
    else if(law=="Vannier")
    {
        //**************** Standard law: 
        k0 = 238.0185;
        k1 = 5792105.0;
        k2 = 57.362;
        k3 = 167917.0;
  
        // T given in Kelvins, changed into Celsius
        T = T - 273.15;
        
        // P given Pascals, changed to mmHg
        P = P / yocoAstroSI.mmHg / yocoAstroSI.Pa;
        
        /*** Standard law, lambda in microns ***/
        sigma2 = 1.0 / (lambda * 1e6) ^ 2;
        // Ciddor 1996, eq. 1
        r =  (k1 / (k0 - sigma2) + k3 / (k2 - sigma2));
        n_as = 1 + 1e-8 * r;
        
        /*** Instantaneous index, T in Celsius et P in mmHg ***/
        // Ciddor, eq. ??? 
        n = 1 + (n_as-1) * P * (1 + (1.049 - 0.0157 * T) * 1e-6 * P) /
            (720.883 * (1 + 0.009661 * T));
    }
    // The complete formulae from Ciddor (1996, applied optics, 35, 1566)
    // including the water vapour content
    else if(law=="Ciddor")
    {
        //h is the fractionnal humidity value
        h = F / 100.0;

        // Sigma is in microns^-1
        sigma  = 1.0 / (lambda * yocoAstroSI.m / yocoAstroSI.mum);
        sigma2 = sigma * sigma;
        sigma4 = sigma2 * sigma2;
        sigma6 = sigma4 * sigma2;

        /*** Temperatures in Kelvin ! ***/
        T2 = T^2;

        // Following the steps from Ciddor 1996 in Appendix B
        /************ Point 1 ************/
        // Find svp (see below eq. 4)
        A   = 1.2378847e-5;
        B   = -1.9121316e-2;
        C   = 33.93711047;
        D   = -6.3431645e3;
        svp = exp(A * T2 + B * T + C + D / T);

        // find pw
        pw = h * svp;

        // find f (see below eq. 4)
        t     = T - 273.15;
        t2    = t^2;
        alpha = 1.00062;
        beta  = 3.14e-8;
        gamma = 5.6e-7;
        f     = alpha + beta * P + gamma * t2;

        // find xw
        xw    = f * h * svp / P;

        /************ Point 2 ************/
        // Ciddor 1996, eq. 1
        k0   = 238.0185;
        k1   = 5792105.0;
        k2   = 57.362;
        k3   = 167917.0;
        r    = (k1 / (k0 - sigma2) + k3 / (k2 - sigma2));
        n_as = 1 + 1e-8 * r;

        // Ciddor 1996, eq. 2
        n_axs = 1 + (n_as - 1)*(1 + 0.534e-6 * (xc - 450));
        n_gasx = 1 + 1e-8 * (k1 * (k0 + sigma2) / (k0 - sigma2)^2 +
                             k3 * (k2 + sigma2) / (k2 - sigma2)^2) *
            (1 + 0.534e-6 * (xc - 450));

        /************ Point 3 ************/
        // Find Ma (done in the function computeBIPM_Density)

        /************ Point 4 ************/

        // Find Za (done in point 6)
        // Ciddor 1996, eq. 12
        Pa  = 101325;
        Ta  = 15 + 273.15;
        xwa = 0;

        /************ Point 5 ************/
        // Find Zw (done in point 7)
        Pw  = 1333;
        Tw  = 20 + 273.15;
        xww = 1;

        /************ Point 6 ************/
        // compute rho_axs
        rho_axs = computeBIPM_Density(Pa, Ta, xwa, xc);

        // compute rho_ws
        rho_ws = computeBIPM_Density(Pw, Tw, xww, xc);

        /************ Point 7 ************/
        // Compressibility of moist air under experimental conditions
        // (eq. 12) Done in point 8 through computeBIPM_Density

        /************ Point 8 ************/
        // Density of the dry component of the moist air
        //rho_a = P * Ma * (1 - xw) / (Z * R * T);
        rho_a = computeBIPM_Density(P, T, xw, xc);

        /************ Point 9 ************/
        // Density of the water vapour component of the moist air
        //rho_w = P * Mw * xw / (Z * R * T);
        rho_w = computeBIPM_Density(pw, T, 1, xc);

        // Ciddor 1996, eq. 3
        //**************** vapeur d'eau standard:
        cf    = 1.022;
        w0    = 295.235;
        w1    = 2.6422;
        w2    = -0.032380;
        w3    = 0.004028;
        n_ws  = 1 + 1e-8 * cf * (w0 + w1 * sigma2 + w2 * sigma4 + w3 * sigma6);
        n_gws = 1 + 1e-8 * cf * (w0 + 3 * w1 * sigma2 + 5 * w2 * sigma4 + 7 * w3 * sigma6);

        /************ Point 10 ************/
        // Ciddor 1996, eq. 5
        n_prop = 1 + (rho_a / rho_axs) * (n_axs - 1) +
            (rho_w / rho_ws) * (n_ws - 1);

        n_gprop = 1 + (rho_a / rho_axs) * (n_gasx - 1) +
            (rho_w / rho_ws) * (n_gws - 1);
    }
    //  Mathar (2007, journal of optics A, 9, 470)
    else if(law=="Mathar")
    {
        /*** wlen in m ***/
        sigma = 1.0 / lambda * yocoAstroSI.cm / yocoAstroSI.m;
        sigmaref = 1e4 / 2.25;

        // T in Kelvins
        Tref = 273.15 + 17.5;

        // Pref in Pascals
        Pref = 75000;

        // Href in percentage of humidity
        Href = 10;

        // Tables from Mathar et al.
        Cjref = [0.200192e-3,
                 0.113474e-9,
                 -0.424595e-14,
                 0.100957e-16,
                 -0.293315e-20,
                 0.307228e-24
                 ];

        CjT = [0.588625e-1,
               -0.385766e-7,
               0.888019e-10,
               -0.567650e-13,
               0.166615e-16,
               -0.174845e-20
               ];

        CjTT = [-3.01513,
                0.406167e-3,
                -0.514544e-6,
                0.343161e-9,
                -0.101189e-12,
                0.106749e-16
                ];

        CjH = [-0.103945e-7,
               0.136858e-11,
               -0.171039e-14,
               0.112908e-17,
               -0.329925e-21,
               0.344747e-25
               ];

        CjHH = [0.573256e-12,
                0.186367e-16,
                -0.228150e-19,
                0.150947e-22,
                -0.441214e-26,
                0.461209e-30
                ];

        CjP = [0.267085e-8,
               0.135941e-14,
               0.135295e-18,
               0.818218e-23,
               -0.222957e-26,
               0.249964e-30
               ];

        CjPP = [0.609186e-17,
                0.519024e-23,
                -0.419477e-27,
                0.434120e-30,
                -0.122445e-33,
                0.134816e-37
                ];

        CjTH = [0.497859e-4,
                -0.661752e-8,
                0.832034e-11,
                -0.551793e-14,
                0.161899e-17,
                -0.169901e-21
                ];

        CjTP = [0.779176e-6,
                0.396499e-12,
                0.395114e-16,
                0.233587e-20,
                -0.636441e-24,
                0.716868e-28
                ];

        CjHP = [-0.206567e-15,
                0.106141e-20,
                -0.149982e-23,
                0.984046e-27,
                -0.288266e-30,
                0.299105e-34
                ];

        nm1 = array(0,numberof(wlen));
        for(j=1;j<=6;j++)
        {
            Cj = Cjref(j) +
                CjT(j)  * (1/T - 1/Tref) +
                CjTT(j) * (1/T - 1/Tref)^2 +
                CjH(j)  * (H - Href) +
                CjHH(j) * (H - Href)^2 +
                CjP(j)  * (P - Pref) +
                CjPP(j) * (P - Pref)^2 +
                CjTH(j) * (1/T - 1/Tref) * (H - Href) +
                CjTP(j) * (1/T - 1/Tref) * (P - Pref) +
                CjHP(j) * (H - Href) * (H - Href);

            write,Cj;
            nm1 += Cj * (sigma - sigmaref) ^ double(j-1);
        }
        r = 1e8*nm1;
        n = 1 + nm1;
    }
    return r;
}

/*************************************************************/

func _yocoAstroComputeBIPM_Density(P, T, xw, xc)
    /* DOCUMENT _yocoAstroComputeBIPM_Density(P, T, xw, xc)

       DESCRIPTION

       PARAMETERS
       - P : 
       - T : 
       - xw: 
       - xc: 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    // P in pascals
    // T in Kelvins
    // xw is the molar fraction of water vapor in moist air
    // xc ppm of CO2

    // gas constant,
    R = 8.314510;

    // Mw is the molar mass of water vapor
    Mw = 0.018015;

    // molar mass of dry air containing xc ppm of CO2
    Ma = 1e-3 * (28.9635 + 12.011e-6 * (xc - 400));

    // Compressibility of gas
    Z = computeCompressibility(P, T, xw);

    // BIPM density, Ciddor 1996 eq. 4
    rho = (P * Ma / (Z * R * T)) *
        (1 - xw * (1 - Mw / Ma));

    return rho;
}

/*************************************************************/

func _yocoAstroComputeCompressibility(P, T, xw)
    /* DOCUMENT _yocoAstroComputeCompressibility(P, T, xw)

       DESCRIPTION

       PARAMETERS
       - P : 
       - T : 
       - xw: 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    // P in pascals
    // T in Kelvins
    // xw is the molar fraction of water vapor in moist air

    // Coefficients to compute Z
    a0 = 1.58123e-6;
    a1 = -2.9331e-8;
    a2 = 1.1043e-10;
    b0 = 5.707e-6;
    b1 = -2.051e-8;
    c0 = 1.9898e-4;
    c1 = -2.376e-6;
    d = 1.83e-11;
    e = -0.765e-8;

    // t in Celsius
    t = T - 273.15;

    // Compute compressibility of gas, from Ciddor 1996, eq. 12
    Z = 1 - (P / T) *
        (a0 +
         a1 * t +
         a2 * t^2 +
         (b0 + b1 * t) * xw +
         (c0 + c1 * t) * xw^2) +
        (P / T) ^ 2 * (d + e * xw^2);

    return Z;
}

/**************************************************************************
 *  Conversion of flux and magnitude
 **************************************************************************/

func yocoAstroJyToFlux(Jy, lambda, unitSys)
    /* DOCUMENT yocoAstroJyToFlux(Jy, lambda, unitSys)

       DESCRIPTION
       Compute the flux per unit of wavelength as defined by: Jy.c/lambda^2
       By default the unitSys is yocoAstroSI, but you can specify another
       one (yocoAstroCGS).
   
       PARAMETERS
       - Jy     : flux (Jansky)
       - lambda : wavelength (m, cm)
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'

       RETURN VALUES
       Return the emited flux (W/m^2/m, erg/s/cm^2/cm)
    */
{
    /* default unit system*/
    if (is_void(unitSys)) unitSys = yocoAstroSI;
    if (structof(unitSys) != yocoASTRO_UNIT_SYSTEM )
        error,"unitSys should be a yocoASTRO_UNIT_SYSTEM";

    return Jy*unitSys.Jy / lambda^2 * unitSys.c;
}

/***************************************************************************/

func yocoAstroFluxToJy(F, lambda)
    /* DOCUMENT yocoAstroFluxToJy(F, lambda)

       DESCRIPTION
       Return the flux in Jansky given the flux per unit of wavelength, as
       defined by:  flux.lambda^2/c
       By default the unitSys is yocoAstroSI, but you can specify another one
       (yocoAstroCGS).
   
       PARAMETERS
       - F     : flux (W/m^2/m, erg/s/cm^2/cm)
       - lambda: wavelength (m, cm)
   
       RETURN VALUES
       Return the emited flux in Jy
    */
{
    /* default unit system*/
    if (is_void(unitSys)) unitSys = yocoAstroSI;

    return F * lambda^2 / unitSys.c / unitSys.Jy;
}

/***************************************************************************/

func yocoAstroExtractBand(names, unitSys)
    /* DOCUMENT yocoAstroExtractBand(names, unitSys)
            
       DESCRIPTION
       Return a structure yocoASTRO_SPECTRAL_BAND with its element initialized to
       the value of the band names as specified in unitSys.
       By default the unitSys is yocoAstroSI, but you can specify another one
       (yocoAstroCGS).
   
       PARAMETERS
       - names  : string, names of the required bands
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'
   
       RETURN VALUES
       Return the spectral band.
   
       EXAMPLES:
       extract the bands:
       > bands = yocoAstroExtractBand( "H" );
       > bands = yocoAstroExtractBand( ["J","H","K"] );
       > bands = yocoAstroExtractBand( "H", yocoAstroCGS );
   
       deal with them:
       > bands.wd
       > bands.wl
       > bands.f0
    */
{
    /* default unit system*/
    if (is_void(unitSys)) unitSys = yocoAstroSI;
    if (structof(unitSys) != yocoASTRO_UNIT_SYSTEM )
        error,"unitSys should be a yocoASTRO_UNIT_SYSTEM";

    local bands;
    bands = array(yocoASTRO_SPECTRAL_BAND,dimsof(names));

    /* Loop on the element of bands to fill them */
    for (i = 1; i <= numberof(names); ++i) 
    {
        if (names(i) == "U")    
        { 
            bands(i).wd=unitSys.band.Uwd   ;
            bands(i).f0=unitSys.band.Uf0   ;
            bands(i).wl=unitSys.band.U   ;
            continue; 
        }
        else if (names(i) == "B")
        { 
            bands(i).wd=unitSys.band.Bwd   ; 
            bands(i).f0=unitSys.band.Bf0   ; 
            bands(i).wl=unitSys.band.B   ; 
            continue; 
        }
        else if (names(i) == "V")    
        { 
            bands(i).wd=unitSys.band.Vwd   ; 
            bands(i).f0=unitSys.band.Vf0   ; 
            bands(i).wl=unitSys.band.V   ; 
            continue;
        }
        else if (names(i) == "R")    
        { 
            bands(i).wd=unitSys.band.Rwd   ; 
            bands(i).f0=unitSys.band.Rf0   ; 
            bands(i).wl=unitSys.band.R   ; 
            continue;
        }
        else if (names(i) == "I")    
        { 
            bands(i).wd=unitSys.band.Iwd   ; 
            bands(i).f0=unitSys.band.If0   ; 
            bands(i).wl=unitSys.band.I   ; 
            continue; 
        }
        else if (names(i) == "J")    
        { 
            bands(i).wd=unitSys.band.Jwd   ; 
            bands(i).f0=unitSys.band.Jf0   ; 
            bands(i).wl=unitSys.band.J   ; 
            continue; 
        }
        else if (names(i) == "H")   
        { 
            bands(i).wd=unitSys.band.Hwd   ; 
            bands(i).f0=unitSys.band.Hf0   ; 
            bands(i).wl=unitSys.band.H   ; 
            continue; 
        }
        else if (names(i) == "K")    
        { 
            bands(i).wd=unitSys.band.Kwd   ;
            bands(i).f0=unitSys.band.Kf0   ;
            bands(i).wl=unitSys.band.K   ;
            continue; 
        }
        else if (names(i) == "L")   
        { 
            bands(i).wd=unitSys.band.Lwd   ; 
            bands(i).f0=unitSys.band.Lf0   ; 
            bands(i).wl=unitSys.band.L   ; 
            continue;
        }
        else if (names(i) == "M")    
        {
            bands(i).wd=unitSys.band.Mwd   ;
            bands(i).f0=unitSys.band.Mf0   ;
            bands(i).wl=unitSys.band.M   ;
            continue;
        }
        else if (names(i) == "N")    
        {
            bands(i).wd=unitSys.band.Nwd   ;
            bands(i).f0=unitSys.band.Nf0   ;
            bands(i).wl=unitSys.band.N   ;
            continue; 
        }
        else if (names(i) == "Q")    
        {
            bands(i).wd=unitSys.band.Qwd   ;
            bands(i).f0=unitSys.band.Qf0   ; 
            bands(i).wl=unitSys.band.Q   ; 
            continue;
        }
        else if (names(i) == "K12") 
        {
            bands(i).wd=unitSys.band.K12wd ;
            bands(i).f0=unitSys.band.K12f0 ;
            bands(i).wl=unitSys.band.K12 ;
            continue;
        }
        else if (names(i) == "K25") 
        { 
            bands(i).wd=unitSys.band.K25wd ;
            bands(i).f0=unitSys.band.K25f0 ;
            bands(i).wl=unitSys.band.K25 ; 
            continue; 
        }
        else if (names(i) == "K60")
        {
            bands(i).wd=unitSys.band.K60wd ;
            bands(i).f0=unitSys.band.K60f0 ;
            bands(i).wl=unitSys.band.K60 ;
            continue;
        }
        else if (names(i) == "K100")
        { 
            bands(i).wd=unitSys.band.K100wd; 
            bands(i).f0=unitSys.band.K100f0; 
            bands(i).wl=unitSys.band.K100; 
            continue;
        } else {
            yocoLogWarning,"Band "+names(i)+" is not supported.";
        }
    }

    return bands;
}

/***************************************************************************/

func yocoAstroMagToFlux(mag, band, unitSys)
    /* DOCUMENT yocoAstroMagToFlux(mag, band, unitSys)

       DESCRIPTION
       Convert a magnitude into flux with the formula f0_band*10^(-0.4*mag)
       By default the unitSys is yocoAstroSI, but you can specify another one
       (yocoAstroCGS).
   
       PARAMETERS
       - mag    : magnitude in the band
       - band   : name of the band
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'
     
       RETURN VALUES
       Return the flux in the band (W/m^2/m, erg/s/cm^2/cm)
    */
{
    local bands;
    bands = yocoAstroExtractBand(band,unitSys);  
    return bands.f0 * 10 ^ (-0.4*mag);
}

/***************************************************************************/

func yocoAstroFluxToMag(flux, band, unitSys)
    /* DOCUMENT yocoAstroFluxToMag(flux, band, unitSys)

       DESCRIPTION
       Convert a flux into magnitude with the formula -2.5*log10(flux/f0_band)
       By default the unitSys is yocoAstroSI, but you can specify another
       one (yocoAstroCGS).
   
       PARAMETERS
       - flux   : flux in the band (W/m^2/m, erg/s/cm^2/cm)     
       - band   : name of the band
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'
   
       RETURN VALUES
       Return the magnitude in the band.
    */
{
    local bands;
    bands = yocoAstroExtractBand(band,unitSys);  
    return -2.5 * log10( flux / bands.f0 );
}

/***************************************************************************/

func yocoAstroMagToPhoton(mag, band, unitSys)
    /* DOCUMENT yocoAstroMagToPhoton(mag, band, unitSys)
       yocoAstroMagToPhoton(mag, band, unitSys)
             
       DESCRIPTION
       Convert a broad-band magnitude into a number of photons/m2/s.
       By default the unitSys is yocoAstroSI, but you can specify another
       one (yocoAstroCGS).

       PARAMETERS
       - mag    : magnitude in the band
       - band   : atmospheric band, for instance "J" or "H".
       - unitSys: a fully defined 'yocoASTRO_UNIT_SYSTEM'
   
       RETURN VALUES
       the number of photons per second and m2 in the band.
    */
  
{
    local bands;
    bands  = yocoAstroExtractBand(band, unitSys);
    return bands.f0 * 10 ^ (-0.4*mag) * bands.wd / (yocoAstroSI.h*yocoAstroSI.c / bands.wl);
}

/***************************************************************************/

func yocoAstroJulianDayToGMST(JD,modified=)
/* DOCUMENT GMST yocoAstroJulianDayToGMST(JD)

   DESCRIPTION
   Return the Greenwich mean sidereal time (GMST)
   in hour. Taken from
   http://aa.usno.navy.mil/faq/docs/GAST.php
   Precision is 0.1s per century

   Equation of equinoxes in not taken into account into GMST.
   But its maximu value is about 1.1 seconds. So the difference
   between the mean sideral time (GMST) and the apparent sideral
   time (GAST) is never more than 1.1 seconds.

   The local sideral LST can be computed with the longitude
   of the site (lon, in degress) with the formula:

   LST = (GMST - lon/360*24) % 24;

   EXAMPLES:
   > JD   = yocoAstroESOStampToJulianDay("2013-01-25T22:18:0.0");
   > GMST = yocoAstroJulianDayToGMST(JD);
   > lon  = yocoStrAngle("70:24:11.642");
   > LST  = (GMST - lon/360*24)%24;
   > yocoStrTime(LST);
*/
{
  local D;
  if (modified) jd += 2400000.5;
  
  /* Taken from:
     http://aa.usno.navy.mil/faq/docs/GAST.php */
  D = JD - 2451545.0;
  return 18.697374558 + 24.06570982441908 * D;
}

/***************************************************************************/

func yocoAstroESOStampToJulianDay(timeStamp, modified=, truncated=)
    /* DOCUMENT yocoAstroESOStampToJulianDay(timeStamp, modified=, truncated=)

       DESCRIPTION
       From a string stamp (with the ESO format:
       [year]-[month]-[day]T[hour]:[minute]:[second]), return the julian day
   
       PARAMETERS
       - timeStamp: The input time stamp
       - modified : whether to return modified Julian Day
       - truncated: whether to return Truncated Julian Day
   
       RETURN VALUES
       the Julian day corresponding to the ESO time stamp
       
       EXAMPLES
       > swrite(yocoAstroESOStampToJulianDay("2008-03-19T12:34:21"),format="%6f")
       "2454545.023854"
       > swrite(yocoAstroESOStampToJulianDay("2009-11-01T07:03:10.753"),format="%6f")
       "2455136.793874"
   
       SEE ALSO yocoAstroJulianDayToESOStamp, 
    */
{
    local Year,Month,Day,Hour,Minute,Second;
    Year = Month = Day = Hour = Minute = Second = 0.0;
    output = array(double, dimsof(timeStamp));

    /* convert into mjd */
    for (i=1;i<=numberof(output);i++) {
        if (sread(timeStamp(i),format="%f-%f-%fT%f:%f:%f",Year,Month,Day,Hour,Minute,Second)==6)
            output(i) = yocoAstroJulianDay(Year,Month,Day,Hour,Minute,Second,
                                           modified=modified, truncated=truncated);
    }
    
    /* return */
    return output;
}

/***************************************************************************/

func yocoAstroJulianDayToESOStamp(JD, modified=, truncated=)
    /* DOCUMENT yocoAstroJulianDayToESOStamp(JD, modified=, truncated=)

       DESCRIPTION
       From a julian day, return the ESO-format string stamp
       [year]-[month]-[day]T[hour]:[minute]:[second]
   
       PARAMETERS
       - JD       : input Julian Day
       - modified : whether to use modified Julian Day
       - truncated: whether to use Truncated Julian Day

       SEE ALSO yocoAstroESOStampToJulianDay
    */
{
    local Year,Month,Day,Hour,Minute,Second;
    yocoAstroJulianDayToGregorian,JD,Year,Month,Day,Hour,Minute,Second,
        modified=modified, truncated=truncated;

    /* convert into stamp */
    return swrite(format="%04d-%02d-%02dT%02d:%02d:%06.3f",
                  int(Year),int(Month),int(Day),int(Hour),int(Minute),double(Second));
}

/***************************************************************************/

func yocoAstroJulianDayToJY2000(JD, modified=, truncated=)
    /* DOCUMENT yocoAstroJulianDayToJY2000(JD, modified=, truncated=)

       DESCRIPTION
       From a julian day, return the Julian Year (JY) in Epoch 2000.0.
       Based on http://en.wikipedia.org/wiki/Julian_year_(astronomy)
       - J2000.0 epoch is 12:00 on January 1, 2000 in the Gregorian calendar.
       - Julian Year duration is exactly 365.25 days

       PARAMETERS
       - JD       : input Julian Day
       - modified : whether to use modified Julian Day
       - truncated: whether to use Truncated Julian Day

       SEE ALSO yocoAstroJY2000ToJulianDay
    */
{
    local JD2000;
  
    /* Epoch is J2000, that is exactly 12:00 on January 1, 2000 in the Gregorian (not Julian) calendar.
       This is actually JD = 2451545.0 */
    JD2000 = yocoAstroJulianDay(2000,01,01,12,00,00, modified=modified, truncated=truncated);
  
    /* Julian Year duration is exactly 365.25 days */
    return 2000.0 + (JD - JD2000) / 365.25;
}

func yocoAstroJY2000ToJulianDay(JY, modified=, truncated=)
    /* DOCUMENT yocoAstroJY2000ToJulianDay(JY, modified=, truncated=)

       DESCRIPTION
       From a Julian Year (JY) in Epoch 2000.0, return the Julian Day.
       Based on http://en.wikipedia.org/wiki/Julian_year_(astronomy)
       - J2000.0 epoch is 12:00 on January 1, 2000 in the Gregorian calendar.
       - Julian Year duration is exactly 365.25 days

       PARAMETERS
       - JY       : input Julian Year in Epoch 2000.0
       - modified : whether to use modified Julian Day
       - truncated: whether to use Truncated Julian Day

       SEE ALSO yocoAstroJulianDayToJY2000
    */
{
    local JD2000;
  
    /* Epoch is J2000, that is exactly 12:00 on January 1, 2000 in the Gregorian (not Julian) calendar.
       This is actually JD = 2451545.0 */
    JD2000 = yocoAstroJulianDay(2000,01,01,12,00,00, modified=modified, truncated=truncated);
  
    /* Julian Year duration is exactly 365.25 days */
    return JD2000 + (JY-2000.0)*365.25;
}

/***************************************************************************/

func yocoAstroJulianDayToGregorian(JD, &Year, &Month, &Day, &Hour, &Minute, &Second, modified=, truncated=)
    /* DOCUMENT yocoAstroJulianDayToGregorian(JD, &Year, &Month, &Day, &Hour, &Minute, &Second, modified=, truncated=)

       DESCRIPTION
       From a Julian day, return the Gregorian date
   
       PARAMETERS
       - JD       : input Julian Day
       - Year     : the year
       - Month    : the month
       - Day      : the day of the month
       - Hour     : the hour
       - Minute   : the minutes
       - Second   : the seconds
       - modified : input Julian day is a modified Julian Day
       - truncated: input Julian day is a truncated Julian Day 
   
       Source:
       http://www.astro.uu.nl/~strous/AA/en/reken/juliaansedag.html
   
       EXAMPLES
       > yocoAstroJulianDayToGregorian,yocoAstroJulianDayNow(),y,m,d,h,m,s
   
       SEE ALSO
    */
{
    local x2, c2, x1, c1, x0, j, m, d, id, r;

    if(truncated)     JD += 2440000.5;
    else if(modified) JD += 2400000.5;

    x2 = JD - 1721119.5;
    c2 = floor( (4.*x2 + 3.) / 146097. );
    x1 = x2 - floor( 146097.*c2/4 );
    c1 = floor( (100.*x1 + 99.)/36525. );
    x0 = x1 - floor( 36525.*c1/100. );
    j  = 100.*c2 + c1;
    m  = floor( (5.*x0 + 461.)/153. );
    d  = x0 - floor( (153.*m - 457.)/5. ) + 1;

    while ( anyof((id = (m>12))) )
    {
        m -= 12 * id;
        j += 1  * id;
    }

    /* Get the date */
    Month = m;
    Year  = j;

    if(anyof(Year <= 1582))
        yocoError, "Gregorian date is ONLY defined AFTER 1582";
    
    Day = floor(d);

    /* Now get the fraction of day */
    r = JD - yocoAstroJulianDay(Year,Month,Day);
    Hour=floor((r=r*24));
    Minute=floor((r=(r-Hour)*60));
    Second = (r-Minute)*60.0;
}

/***************************************************************************/
                     
func yocoAstroJulianDay(Year, Month, Day, Hour, Minute, Second, modified=, truncated=)
    /* DOCUMENT yocoAstroJulianDay(Year, Month, Day, Hour, Minute, Second, modified=, truncated=)

       DESCRIPTION
       Computes the Julian Day from an input date

       PARAMETERS
       - Year     : the year
       - Month    : the month
       - Day      : the day of the month
       - Hour     : the hour
       - Minute   : the minutes
       - Second   : the seconds
       - modified : whether to return modified Julian Day
       - truncated: hether to return Truncated Julian Day

       RETURN VALUES
       the Julian day corresponding to the input date
   
       EXAMPLES
       > yocoAstroJulianDay(2006, 12, 25, 4, 18, 35,modified=1)
       54094.2
   
       SEE ALSO
    */
{
    local C,B,T,f;

    if(is_void(Hour)) Hour=0.;
    if(is_void(Minute)) Minute=0.;
    if(is_void(Second)) Second=0.;

  
    f = (Month==1 | Month==2);
    Year -= f;
    Month += f*12.;

    if(anyof(Year > 1582))
    {
        B = array(0.0,dimsof(Year));
        C = int(double(Year(where(Year > 1582)))/100.);
        B(where(Year > 1582)) = 2-C+int(double(C)/4.);
    }
    else
        B = 0;
    
    T = Hour/24. + Minute/1440. + Second/86400.;
  
    JJ  = int(365.25 * ( Year+4716.)) +
        int(30.6001 * (Month+1)) + Day + T + B - 1524.5;

    if(truncated) JJ  -= 2440000.5;
    else if(modified) JJ -= 2400000.5;
  
    return JJ;
}

/***************************************************************************/
                    
func yocoAstroJulianDayNow(void, modified=, truncated=)
    /* DOCUMENT yocoAstroJulianDayNow(modified=, truncated=)

       DESCRIPTION
       Returns the Julian day of right now...
       Use Unix system "date -u".
   
       SEE ALSO
    */
{
    local time;
    time = rdline(popen("date -u",0));
    // time = timestamp();
    
    stamp  = yocoStrSplit(time," ", multDel=1);
    months = ["Jan","Feb","Mar","Apr","May","Jun",
              "Jul","Aug","Sep","Oct","Nov","Dec",
              "jan","feb","mar","apr","may","jun",
              "jul","aug","sep","oct","nov","dec"];
    Month  = where(stamp(2)==months);
    if (Month(1) > 12) Month -= 12;
    
    Day    = yocoStr2Double(stamp(3));
    Year   = yocoStr2Double(stamp(0));
    hours  = yocoStrSplit(stamp(4),":");
    Hour   = yocoStr2Double(hours(1));
    Minute = yocoStr2Double(hours(2));
    Second = yocoStr2Double(hours(3));

    JD     = yocoAstroJulianDay(Year,Month,Day,Hour,Minute,Second,
                                modified=modified, truncated=truncated);
    return JD(1);
}

/************************************************************************/

func yocoAstroPlotNorthEast(x0, y0, length, sepChar=, tosys=, height=, color=)
    /* DOCUMENT yocoAstroPlotNorthEast(x0, y0, length, sepChar=, tosys=, height=, color=)

       DESCRIPTION
       Plots a "N-E" arrows set of axes for Astronomy images plots

       PARAMETERS
       - x0     : x center of axes
       - y0     : y center of axes
       - length : length of axes
       - sepChar: separation between end of arrow and "N" or "E" characters
       - tosys  : system to which the axes are plot
       - height : height of the font used for "N" and "E"
       - color  : 

       EXAMPLES
       pli,1-unit(100)
       yocoAstroPlotNorthEast,10,50,10;

       SEE ALSO
    */
{
    if(is_void(sepChar))
        sepChar = 1.15*length;
    
    if(is_void(tosys))
        tosys = plsys();
    
    plsys,tosys;

    yocoPlotArrow, x0, y0, x0, y0+length,
        arlng=length/10.0, color=color;
    yocoPlotArrow, x0, y0, x0+length, y0,
        arlng=length/10.0, color=color;
    plt, "N", x0, y0+sepChar, tosys=tosys,
        justify="CH", height=height, color=color;
    plt, "E", x0+sepChar, y0, tosys=tosys,
        justify="CH", height=height, color=color;
}

/**************************************************************************
 *  Orbit generation from Campbell elements
 **************************************************************************/

local yocoASTRO_ORBIT;
/* DOCUMENT yocoASTRO_ORBIT

   Structure containing the Campbell orbital elements
   inspired from kepler.i

   T - time passage at periastron
   P - period
   a - semi-major axis
   e - eccentricity
   O - position angle of ascending node (from North to East)
   o - angle from ascending node to perihelion
   i - inclination

   Angles are in deg.

   The time can be defined in whaterver units (year, days), but should
   be consistent for: T, P, the time in yocoAstroOrbit, and in the
   following derivatives.

   and the (optional) time derivative:
   dadt, dedt, dodt, dOdt, didt;

   SEE ALSO: yocoASTRO_ORBIT, yocoAstroOrbit, yocoAstroPlotOrbitTrace,
   yocoAstroOrbitTest
*/
struct yocoASTRO_ORBIT{
    double T
    double P;
    double a;
    double e;
    double O;
    double o;
    double i;
    double Ka;
    double Kb;
    double g;
    double f;
    double dg;
    double Mt, Ma, Mb, d, MaMb, ap;
    double dadt;
    double dedt;
    double dOdt;
    double dodt;
    double didt;
};


func yocoAstroOrbit(time, orbit, &ma, &ta, &norb, &rv, crv=)
    /* DOCUMENT yocoAstroOrbit(time, orbit, &ma, &ta, &norb)
       or xyz = yocoAstroOrbit(time, orbit, ma, ta, norb)

       DESCRIPTION
       return 3-dimsof(orbit)-by-dimsof(time) XYZ coordinates
       corresponding to the orbit(s) ORBIT and time(s) TIME.  Optionally
       return mean anomaly MA, true anomaly TA, and integer number of
       orbits, each a dimsof(orbit)-by-dimsof(time) array.  The
       MA and TA are in radians.
   
       The x-axis is to the East;
       the y-axis is to the North;
       The z-axis is from the observer to the star.
       (negative derivative means object is approaching, RV definition)

       orbit is a structure yocoASTRO_ORBIT. The unit of time (year or days)
       should match the one of orbit.T and orbit.P. Angles are in deg.
   
       Mean anomaly is not an angle in real space; it is the quantity
       proportional to time in Kepler's equation.  True anomaly is the
       angle from perihelion to planet.

       See the source code of yocoAstroOrbitTest for some validations based
       on published orbits.
     
       SEE ALSO: yocoASTRO_ORBIT, yocoAstroOrbit, yocoAstroPlotOrbitTrace
       yocoAstroOrbitTest
    */
{
    /* result will be dimsof(orbit)-by-dimsof(time) */
    time = [orbit.e*0.+1.](..,+) * [time](..,+);

    /* ma = mean anomaly = time from perihelion to planet, as an angle
     * a = semi-major axis
     * e = eccentricity
     */
    ma = 2.*pi * (time - orbit.T) / orbit.P;
    a  = (orbit.a + orbit.dadt*time);
    e  = (orbit.e + orbit.dedt*time);

    /* reduce ma to interval (-pi,pi] */
    norb = ceil((ma-pi)/(2.*pi));
    ma -= 2.*pi*norb;

    /* ea = eccentric anomaly, ma = ea-e*sin(ea) is kepler's equation of time
     * solve for ea by newton iteration */
    ea = ma + e*sin(ma)*(1.+e*cos(ma));
    do {
        sea = sin(ea);
        cea = cos(ea);
        dea = (ea-e*sea - ma)/(1.-e*cea);
        ea -= dea;
    } while (anyof(abs(dea) > 1.e-8));

    /* ta = true anomaly = angle from perihelion to planet */
    ea = atan(sea,cea);
    ta = 2*atan( sqrt(1+e)*sin(ea/2) , sqrt(1-e)*cos(ea/2) );

    /* xyz in the reference frame of orbit */
    xyz = array(0., 3,dimsof(cea));
    xyz(1,..) = a * (cea-e);
    xyz(2,..) = a * sqrt(1.-e*e) * sea;

    /* Compute current value of arguments */
    ascn = (orbit.O + orbit.dOdt*time) * (pi/180.);
    argp = (orbit.o + orbit.dodt*time) * (pi/180.);
    incl = (orbit.i + orbit.didt*time) * (pi/180.);

    /* Revers x/y axes, as the following is extracted from
       kepler.i that defines orbit in the solar system
       reference frame. */
    ascn = pi/2 - ascn;
    incl = incl - pi;
    ascn = ascn + pi;
    argp = argp + pi;

    /* Projection into the plan of the sky */
    can = cos(ascn); // cos(O)
    san = sin(ascn); // sin(O)
    car = cos(argp); // cos(o)
    sar = sin(argp); // sin(o)
    cn  = cos(incl);  // cos(i)
    sn  = sin(incl);  // sin(i)

    axes = [[ can*car-san*sar*cn,  san*car+can*sar*cn, sn*sar],
            [-can*sar-san*car*cn, -san*sar+can*car*cn, sn*car],
            [         san*sn,             -can*sn,     cn]];
    axes = transpose(axes, 3);  /* make matrix indices first */

    rxyz = (axes * xyz(-,..))(,sum,..);

    /* Compute radial velocities */
    if (crv) {
      rv = array(double,2,dimsof(cea));
      rv(1,) = orbit.g + orbit.Ka * ( cos(argp + ta) + e*cos(argp) );
      rv(2,) = orbit.g - orbit.Kb * ( cos(argp + ta) + e*cos(argp) ) + orbit.dg;
    }
    
    return rxyz;
}

func yocoAstroPlotOrbitTrace(orbit, color=, type=, date=, size=, symbol=, label=, delta=, font=, height=, clabel=, datax=, datay=, fill=, sky=, width=, reflex=)
    /* DOCUMENT yocoAstroPlotOrbitTrace(orbit, color=, type=, date=, size=, symbol=, label=, delta=, font=, height=, clabel=, width=, sky=, reflex=)

       DESCRIPTION
       Plot a trace of orbit on the plane of the sky (E-N).
       The time passage at periastron (orbit.T) is marked with
       a symbol. The orbit is plotted uncomplete to inform about
       the rotation direction.

       date (size, symbol) : add specific position on the orbit trace
       represented by symbols. date should be an array in the same
       time unit as orbit.T and orbit.P

       label (delta, font, height, clabel) : add label for the specific
       positions. sky=1 means the East is left.

       PARAMETERS:
       - orbit:
       - color, type, size, symbol, fill, width: parameters for the trace
       - font, height, clabel: parameter for the labels
       - date: position of points in the trace
       - lavel: text label to be plotted in these positions
       - datax, datay: observed position at these date (linked)
       - reflex: if 1, the trace of the primary is also shown (depends on
         orbit.MaMb) and both stars orbit the center-of-mass.

       EXAMPLES:
       > orb = yocoASTRO_ORBIT(P=800, T=55000, a=12, e=0.0, o=80, i=70, O=25);
       > yocoAstroPlotOrbitTrace, orb;

       > d = span(orb.T, orb.T+orb.P, 10)(2:-1); 
       > yocoAstroPlotOrbitTrace, orb, date=d, symbol=2, label=swrite(format="%.1f",d);

       SEE ALSO: yocoASTRO_ORBIT, yocoAstroOrbit, yocoAstroPlotOrbitTrace
       yocoAstroOrbitTest
    */
{
    local xyz;

    /* We may want to plot the reflex motion of the primary,
       all against center of mass */
    if (reflex) {
      secondary = (+1) * orbit.MaMb / (1.+orbit.MaMb);
      primary   = (-1) / (1.+orbit.MaMb);
    } else {
      secondary = 1.0;
    }

    /* Plot trace */
    if (type!=0) {
    
        /* Make one orbit almost complete */
        time = orbit.T + orbit.P * span(0,1,10000);
        xyz  = yocoAstroOrbit(time, orbit) * secondary;
    
        /* Plot T0 of secondary */
        yocoPlotPlpMulti, xyz(2,1), xyz(1,1), color=color,symbol=4,size=0.75,fill=(xyz(3,1)>0.0);

        /* Plot trace of secondary */
        yocoPlotPlgMulti, xyz(2,:9900), xyz(1,:9900), color=color, type=type, width=width;
    
        /* Plot trace of primary */
        if (reflex) {
          yocoPlotPlgMulti,
            xyz(2,:9900) * primary / secondary,
            xyz(1,:9900) * primary / secondary,
            color=color, type=type, width=width;
        }

        /* Line of node */
        n = where( xyz(3,1:-1)*xyz(3,2:0) < 0);
        yocoPlotPlgMulti, xyz(2,n), xyz(1,n), color=color, type=2;
    }
  
    /* Plot specific position on orbit for date */
    if (is_array(date)) {
    
        xyz  = yocoAstroOrbit(date, orbit) * secondary;
        yocoPlotPlp, xyz(2,), xyz(1,), color=clabel, symbol=symbol, size=size, fill=fill;
    
        /* Link those position with data */
        if (is_array(datax) && is_array(datay)) {
          yocoPlotPlgMulti, transpose([xyz(2,),datay]),
            transpose([xyz(1,),datax]), color=clabel;
        }
    }

    /* Plot specific label on orbit for date */
    if (is_array(label)) {

        /* default for spatial separation from orbit */
        if (is_void(delta)) delta = orbit.a/20 * (orbit.i>90.0 ? -1 : 1 );
        if (is_void(height)) height=10;

        /* Compute the orbit position and derivative */
        xyz  = yocoAstroOrbit(date, orbit) * secondary;
        xyzd = yocoAstroOrbit(date+orbit.P/10000, orbit) * secondary - xyz;
        xyzd /= abs(xyzd(1,),xyzd(2,))(-,);
    
        /* Compute the label position */
        delta = [-1,1] * delta * xyzd([2,1],);
        xy0 = xyz(1:2,) + delta;

        /* Select justification */
        if (sky==1)
          justify = ["R","L"]( 1+(delta(1,)<0) ) + "H";
        else
          justify = ["L","R"]( 1+(delta(1,)<0) ) + "H";

        /* Plot the labels in current system */
        yocoPlotPltMulti, label, xy0(1,), xy0(2,), tosys=plsys(),
            justify=justify, height=height, font=font, color=clabel;
    }
}

func yocoAstroOrbitTest(void)
    /* DOCUMENT yocoAstroOrbitTest

       DESCRIPTION
       Plot 3 published orbits to demonstrate that yocoOrbit
       is defined correctly.

       SEE ALSO: yocoASTRO_ORBIT, yocoAstroOrbit, yocoAstroPlotOrbitTrace
       yocoAstroOrbitTest
    */
{
    yocoGuiWinKill;
    time = span(0,10,1000);

    yocoPlotDefaultDpi,70;
    yocoNmCreate,0,3,square=1,dy=0.1,dx=0.05;

    // http://cdsads.u-strasbg.fr/abs/2011ApJ...729L...5T
    plsys,1;
    yocoAstroPlotOrbitTrace,
        yocoASTRO_ORBIT(a=99., i=32.9, O=172.8, e=0.938, o=2.1, P=10.817),
        color="blue";
    yocoAstroPlotOrbitTrace,
        yocoASTRO_ORBIT(a=98.3, i=38.6, O=175.2, e=0.9401, o=1.9, P=10.817),
        color="red";
    limits,120,-120,-20,square=1;
    gridxy,2,2;
    pltitle,"2011ApJ...729L...5T";

    // http://cdsads.u-strasbg.fr/abs/2009A!%26A...497..195K
    plsys,2;
    yocoAstroPlotOrbitTrace,
        yocoASTRO_ORBIT(a=40, i=100.7, O=25.3, e=0.534, o=290.9, P=11.05, T=2002.87),
        color="blue";
    yocoAstroPlotOrbitTrace,
        yocoASTRO_ORBIT(a=43.6, i=99.0, O=26.5, e=0.592, o=285.8, P=11.26, T=2002.57),
        color="red", date=[2003.9, 2004.8, 2008.2, 1999.8];
    limits,50,-50,-50,square=1;
    gridxy,2,2;
    pltitle,"2009A!%26A...497..195K";

    //http://iopscience.iop.org/1538-3881/135/5/1659/pdf/aj!_135!_5!_1659.pdf
    plsys,3;
    yocoAstroPlotOrbitTrace,
        yocoASTRO_ORBIT(a=13, i=75.9, O=66, e=0.6211, o=232.4, P=592.11);
    limits,25,-10,-15,square=1;
    gridxy,2,2;
    pltitle,"aj!_135!_5!_1659.pdf";

    // http://iopscience.iop.org/1538-3881/135/5/1659/pdf/aj!_135!_5!_1659.pdf
    plsys,4;
    yocoAstroPlotOrbitTrace,
        yocoASTRO_ORBIT(a=813, i=47.3, O=80.9, e=0.397, o=130.9, T=1981.69, P=73.03);
    limits,1000,-1000,-1000,square=1;
    gridxy,2,2;
    pltitle,"Fig 7.6 : Orbital Elements of A VBS";

    yocoNmXytitles,"<--- East","North --->";
}


/**************************************************************************
 *  Conversion factor
 **************************************************************************/

local yocoAstroRadToDeg;
local yocoAstroDegToRad;
local yocoAstroRadToMas;
local yocoAstroMasToRad;
yocoAstroRadToDeg = 180./ pi;
yocoAstroDegToRad = pi / 180.;
yocoAstroMasToRad = pi/648000000.;
yocoAstroRadToMas = 648000000./pi;
/* DOCUMENT yocoAstroRadToDeg
   yocoAstroDegToRad
   yocoAstroRadToMas
   yocoAstroMasToRad
  
   DESCRIPTION
   Constants for angle conversion between mas (Mas),
   Degrees (Deg) and Radians (Rad).
   
   CAUTIONS
   The double precision is not waranted.
*/



local yocoAstroAngToMicron;
local yocoAstroMicronToAng;
local yocoAstroAngToMeter;
local yocoAstroMeterToAng;
yocoAstroAngtoMeter = 1.e-10;
yocoAstroMetertoAng = 1.e+10;
yocoAstroAngToMicron = 1.e-4;
yocoAstroMicronToAng = 1.e+4;
/* DOCUMENT yocoAstroAngToMicron
   yocoAstroMicronToAng
   yocoAstroAngToMeter
   yocoAstroMeterToAng

   DESCRIPTION
   Constants for Lenth conversion between Angstroms (Ang), Microns (Micron)
   and Meters (Meter).
   
   CAUTIONS
   The double precision is not waranted.
*/

local yocoAstroEvToJoule,yocoAstroJouleToEv;
local yocoAstroEvToCm_1,yocoAstroCm_1ToEv;
yocoAstroEvToJoule = 1.602177e-19;
yocoAstroJouleToEv = 1./1.602177e-19;
yocoAstroEvToCm_1 = 8065.48;
yocoAstroCm_1ToEv = 1./8065.48;
/* DOCUMENT yocoAstroEvToJoule
   yocoAstroEvToCm_1

   DESCRIPTION
   Constants for energy conversion between Joules (Joule), electronVolts
   (Ev), and centimeters^-1 (Cm_1).
   
   CAUTIONS
   The double precision is not waranted.
*/


/**************************************************************************
 *  Mendeleiev Table
 **************************************************************************/

/* Local definition to setup a common help
   Initialization is done above       */
local yocoAstroMendeleev;
local yocoASTRO_PERIODIC_TABLE;
/* DOCUMENT yocoASTRO_PERIODIC_TABLE
   yocoAstroMendeleev
     
   DESCRIPTION
   Structure containing information on elements of the periodic table.
   This structure has one default instance called yocoAstroMendeleev which
   contain the whole element from H (1) to Ac (89) sorted by increasing Z.

   PARAMETERS
   - name (string) : name                   ("Helium")
   - symb (string) : generic symbol             ("He")
   - Z (int) : atomic number                       (2)
   - masse (double) : atomic masse               (amu)
   - radius (double) : atomic radius             (Ang)
   - elecNev (double) : electronegativite
   - Tboi (double) : boiling temperature       (deg K)
   - Tfus (double) : fusion temperature        (deg K)
   
   CAUTIONS
   yocoAstroMendeleev table has to be updated, some values are still
   nulle. Elements with large Z should be included. Moreover, the table names
   are in French only!
*/

struct yocoASTRO_PERIODIC_TABLE {
    string name;    // element name (in French)
    string symb;    // element symbol
    int    Z;       // element number
    double masse;   // element mass
    double radius;  // Radius
    double elecNev; // Electronegativity
    double Tboi;    // Boiling temperature
    double Eboi;    // Vaporization enthalpy
    double Tfus;    // Fusion temperature
    double Efus;    // Fusion enthalpy
};

yocoAstroMendeleev = array(yocoASTRO_PERIODIC_TABLE,109);
yocoAstroMendeleev.name= 
    ["Hydrogene","Helium","Lithium","Beryllium","Bore","Carbone","Azote","Oxygene",
     "Fluor","Neon","Sodium","Magnesium","Aluminium","Silicium","Phosphore",
     "Soufre","Chlore","Argon","Potassium","Calcium","Scandium","Titane","Vanadium",
     "Chrome","Manganese","Fer","Cobalt","Nickel","Cuivre","Zinc","Gallium",
     "Germanium","Arsenic","Selenium","Brome","Krypton","Rubidium","Strontium",
     "Yttrium","Zirconium","Niobium","Molybdene","Technetium","Ruthenium","Rhodium",
     "Palladium","Argent","Cadmium","Indium","Etain","Antimoine","Tellure","Iode",
     "Xenon","Caesium","Baryum","Lanthane","Cerium","Praseodyme","Neodyme",
     "Promethium","Samarium","Europium","Gadolinium","Terbium","Dysprosium",
     "Holmium","Erbium","Thulium","Ytterbium","Lutecium","Hafnium","Tantale",
     "Tungstene","Rhenium","Osmium","Iridium","Platine","Or","Mercure","Thallium",
     "Plomb","Bismuth","Polonium","Astate","Radon","Francium","Radium","Actinium",
     "Thorium","Protactinium","Uranium","Neptunium","Plutonium","Americium",
     "Curium","Berkelium","Californium","Einsteinium","Fermium","Mendelevium",
     "Nobelium","Lawrencium","Rutherfordium","Dubnium","Seaborgium","Bohrium",
     "Hassium","Meitnerium"];

yocoAstroMendeleev.symb=
    ["H","He","Li","Be","B","C","N","O","F","Ne","Na","Mg","Al","Si","P","S","Cl",
     "Ar","K","Ca","Sc","Ti","V","Cr","Mn","Fe","Co","Ni","Cu","Zn","Ga","Ge","As",
     "Se","Br","Kr","Rb","Sr","Y","Zr","Nb","Mo","Tc","Ru","Rh","Pd","Ag","Cd","In",
     "Sn","Sb","Te","I","Xe","Cs","Ba","La","Ce","Pr","Nd","Pm","Sm","Eu","Gd","Tb",
     "Dy","Ho","Er","Tm","Yb","Lu","Hf","Ta","W","Re","Os","Ir","Pt","Au","Hg","Tl",
     "Pb","Bi","Po","At","Rn","Fr","Ra","Ac","Th","Pa","U","Np","Pu","Am","Cm","Bk",
     "Cf","Es","Fm","Md","No","Lr","Rf","Db","Sg","Bh","Hs","Mt"];

yocoAstroMendeleev.Z=indgen(numberof(yocoAstroMendeleev));

yocoAstroMendeleev.masse=
    [1.00794,4.0026,6.941,9.01218,10.81,12.011,14.0067,15.9994,18.9984,20.1797,
     22.9898,24.305,26.9815,28.0855,30.9738,32.066,35.4527,39.948,39.0983,40.078,
     44.9559,47.88,50.9415,51.9961,54.938,55.847,58.9332,58.6934,63.546,65.39,
     69.723,72.61,74.9216,78.96,79.904,83.8,85.4678,87.62,88.9059,91.224,92.9064,
     95.94,97.9072,101.07,102.906,106.42,107.868,112.411,114.818,118.71,121.757,
     127.6,126.904,131.29,132.905,137.327,138.905,140.115,140.908,144.24,144.913,
     150.36,151.965,157.25,158.925,162.5,164.93,167.26,168.934,173.04,174.967,
     178.49,180.948,183.84,186.207,150.23,192.22,195.08,196.967,200.59,204.383,
     207.2,208.98,208.982,209.987,222.018,223.02,226.025,227.027,232.038,231.036,
     238.029,237.048,244.064,243.061,247.07,247.07,251.08,252.083,257.095,258.1,
     259.101,260.105,261.11,262.114,263.12,262.12,0,266.138];

yocoAstroMendeleev.radius=
    [0.79,0.49,2.05,1.4,1.17,0.91,0.75,0.65,0.57,0.51,2.23,1.72,1.82,1.46,1.23,
     1.09,0.97,0.88,2.77,2.23,2.09,2,1.92,1.85,1.79,1.72,1.67,1.62,1.57,1.53,1.81,
     1.52,1.33,1.22,1.12,1.03,2.98,2.45,2.27,2.16,2.08,2.01,1.95,1.89,1.83,1.79,
     1.75,1.71,2,1.72,1.53,1.42,1.32,1.24,3.34,2.78,2.74,2.7,2.67,2.64,2.62,2.59,
     2.56,2.54,2.51,2.49,2.47,2.45,2.42,2.4,2.25,2.16,2.09,2.02,1.97,1.92,1.87,1.83,
     1.79,1.76,2.08,1.81,1.63,1.53,1.43,1.34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0];

yocoAstroMendeleev.elecNev=
    [2.1,0,1,1.5,2,2.5,3,3.5,4,0,0.9,1.2,1.5,1.8,2.1,2.5,3,0,0.86,1,1.3,1.5,1.6,
     1.6,1.5,1.8,1.8,1.8,1.9,1.6,1.6,1.8,2,2.4,2.8,0,0.8,1,1.3,1.4,1.6,1.8,1.9,2.2,
     2.2,2.2,1.9,1.7,1.7,1.8,1.9,2.1,2.5,0,0.8,0.9,1.1,1.1,1.1,1.1,1.1,1.2,1.2,1.2,
     1.2,1.2,1.2,1.2,1.2,1.1,1.2,1.3,1.5,1.7,1.9,2.2,2.2,2.2,2.4,1.92,1.8,1.8,1.9,2,
     2.2,0,0.7,0.9,1.1,1.3,1.5,1.4,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,0,0,0,0,
     0,0,0];

yocoAstroMendeleev.Tboi=
    [-252.732,-269,1342,2970,2550,4827,-196,-183,-188,-249,883,1107,2467,2355,300,
     444,-35,-186,760,1484,2831,3287,3380,2670,1962,2750,2870,2730,2567,907,2403,
     2830,817,685,59,-152,688,1383,3338,4377,4742,5560,4877,3900,3727,2970,2212,765,
     2080,2272,1750,990,184,-107,669,1640,3457,3426,3512,3027,3212,1791,1597,3268,
     3123,2562,2695,2863,1947,1194,3395,4602,5425,5660,5627,5300,4130,3827,3080,356,
     1457,1740,1560,962,337,-62,677,1140,3200,4790,0,3818,0,3232,2607,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0] + yocoAstroAbsoluteZero;

yocoAstroMendeleev.Eboi=
    [0.9, 0.08, 145.92, 292.4, 480, 355.8, 5.57, 6.82, 6.62, 1.71, 96.96, 127.4, 294, 384.22, 12.4, 45, 10.2, 6.43, 79.87, 153.6, 314.2, 421, 452, 344.3, 226, 349.6, 376.5, 370.4, 300.3, 115.3, 254, 334, 34.76, 95.48, 29.96, 9.08, 72.216, 144, 363, 573.2, 696.6, 598, 660, 595, 493, 357, 250.58, 99.87, 231.5, 295.8, 77.14, 114.1, 41.57, 12.57, 67.74, 140, 414, 414, 296.8, 273, 0, 166, 143.5, 359.4, 330.9, 230, 241, 261, 191, 128.9, 355.9, 575, 753, 824, 715, 627.6, 604, 510, 324, 59.11, 164.1, 179.5, 151, 0, 0, 16.4, 0, 0, 0, 514.4, 470, 477, 336, 344, 238.12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] * 1000; // J/mol

yocoAstroMendeleev.Tfus=
    [-258.975,-272,180,1278,2300,3650,-210,-219,-219,-246,98,649,660,1410,44,113,
     -101,-189,63,839,1541,1660,1890,1857,1244,1535,1495,1455,1083,419,30,937,613,
     217,-7,-157,39.3,769,1522,1852,2468,2610,2172,2310,1966,1554,962,321,156,232,
     630,449,113,-112,28,725,921,799,931,1024,1168,1077,822,1313,1360,1412,1474,
     1529,1545,819,1663,2227,2996,3410,3180,2700,2410,1772,1064,-39,303,327,271,254,
     302,-71,27,700,1050,1750,0,1132,630,641,994,1320,0,0,0,0,0,0,0,0,0,0,0,
     0,0] + yocoAstroAbsoluteZero;

/***************************************************************************/

func yocoAstroVapSat(elem, T)
    /* DOCUMENT yocoAstroVapSat(elem, T)

       DESCRIPTION

       PARAMETERS
       - elem: 
       - T   : 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    if(elem=="H2O")
    {
        Melem  = 0.018;
        P0elem = 1.013;
        Lelem  = 2.26e6 / Melem;
        T0elem = 373;
    }
    else
    {
        symb   = where(yocoAstroMendeleev.symb == elem);
        Melem  = yocoAstroMendeleev(symb).masse;
        T0elem = yocoAstroMendeleev(symb).Tboi;
        Lelem  = yocoAstroMendeleev(symb).Eboi;
        P0elem = 1.0;
    }
    R = 8.31447; // constante gaz parfait en J/K/mol
    
    return P0elem * exp(Melem * Melem * Lelem / R * (1.0 / T0elem - 1.0 / T));
}


struct yocoASTRO_STATIONS {
    string staName;
    double staXYZ(3);
};

local yocoASTRO_STATIONS_VLTI;
yocoASTRO_STATIONS_VLTI = array(yocoASTRO_STATIONS,34);
yocoASTRO_STATIONS_VLTI.staName = ["A0","A1","B0","B1","B2","B3","B4","B5","C0","C1","C2","C3","D0","D1","D2","E0","G0","G1","G2","H0","I1","J1","J2","J3","J4","J5","J6","K0","L0","M0","U1","U2","U3","U4"];
yocoASTRO_STATIONS_VLTI.staXYZ =  [[-14.642, -55.812, 0],
                                   [ -9.434, -70.949, 0],
                                   [ -7.065, -53.212, 0],
                                   [ -1.863, -68.334, 0],  
                                   [  0.739, -75.899, 0],
                                   [  3.348, -83.481, 0],
                                   [  5.945, -91.030, 0],
                                   [  8.547, -98.594, 0],
                                   [  0.487, -50.607, 0],
                                   [  5.691, -65.735, 0],
                                   [  8.296, -73.307, 0],
                                   [ 10.896, -80.864, 0],
                                   [ 15.628, -45.397, 0],
                                   [ 26.039, -75.660, 0],
                                   [ 31.243, -90.787, 0],
                                   [ 30.760, -40.196, 0],
                                   [ 45.896, -34.990, 0],
                                   [ 66.716, -95.501, 0],
                                   [ 38.063, -12.289, 0],
                                   [ 76.150, -24.572, 0],
                                   [ 96.711, -59.789, 0],
                                   [106.648, -39.444, 0],
                                   [114.460, -62.151, 0],
                                   [ 80.628,  36.193, 0],
                                   [ 75.424,  51.320, 0],
                                   [ 67.618,  74.009, 0],
                                   [ 59.810,  96.706, 0],
                                   [106.397, -14.165, 0],
                                   [113.977, -11.549, 0],
                                   [121.535,  -8.951, 0],
                                   [ -9.925, -20.335, 0],
                                   [ 14.887,  30.502, 0],
                                   [ 44.915,  66.183, 0],
                                   [103.306,  43.999, 0]];
