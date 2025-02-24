/********************************************************************************
* PIONIER Data Reduction Software
*/

/* Dependencies */
#include "yoco.i"
#include "cfitsioPlugin.i"
#include "oiFitsUtils.i"
#include "imgFitsUtils.i"

/* PIONIER DRS */
#include "pndrsArchive.i"
#include "pndrsBrowser.i"
#include "pndrsFiles.i"
#include "pndrsProcess.i"
#include "pndrsPlot.i"
#include "pndrsSignal.i"
#include "pndrsImage.i"
#include "pndrsOiData.i"
#include "pndrsBatch.i"
#include "pndrsCalibrate.i"
#include "pndrsInteractive.i"
#include "pndrsSim.i"
#include "pndrsConfig.i"

extern pndrsVersion;
pndrsVersion = "3.94";

/* CHANGE LOG:
  3.94    Fix bug when using BatchTime as string
  3.93    Remove dependency to yocoAstroJulianDayNow()
  3.92    Polarisation spectrum in header
  3.90    Release for ESO
  3.87    Fix a bug introduced in version 3.85
  3.86    Add the ISS PRI DRPOS in oiLog, fix the units in header
  3.85    Normalise the kappa-matrix independently for each polarisation
  3.83    Fixes MJD on raw data
  3.82    Fixes for ARRAYX,Y,Z and target name
  3.81    Fixes for BETI at IPAG
  3.80    Add Rmag
  3.79    Fix bug in cleanQC for Isabelle
  3.77    Release for ESO
  3.76b   Test for NAOMI commissioning
  3.75    Release for ESO
  3.74    Change PRO.CATG from OIDATA_CALIBRATED to TARGET_OIDATA_CALIBRATED.
  3.73    Minor modif, mostly for ESO release
  3.71    Create SetupSimple
  3.7     Release for ESO
  3.53    Create the oidata_tf and oidata_calibrated recipes.
  3.52    Update product from Nausicaa requests
  3.51    Tagged version for ESO
  3.50    Tagged version for ESO
  3.44    Update SPEC_RES and other keyword for PHASE3
  3.42    Fig a bug when writting a header INTEGER which is == 'F'
  3.41    Add the averageFiles options
  3.40    Fix a bug graphic output for ESO pipeline
  3.39    Fix a bug in the naming of the TFVIS data in header (C.Hummel)
  3.38    Fix an issue with the definition of averaged time (found by C.Hummel)
  3.36    Compute the PSD of RAW injection
  3.35    Fix bug in tagged version
  3.34    Tagged version for ESO
  3.33    Deal with the change OPTI3 -> OPTI2
  3.32    Deal with the swap of OPD->LOCALOPD
  3.31    First version of RAPID for polar
  3.30    The hack for the poor baseline is better coded
  3.29    Improve
  3.28    create pndrsArchive
  3.27    change the way to calibrate the setups
          so that we can better follow the
          calibration process for ESO phase-3
  3.26    Uncomment processeing of AC data
  3.25    Tag
  3.24    Add QC parameters for KAPPA matrix
  3.23    Fix phase 3
  3.22    Fix the bug in flags in the HEADER
  3.21    Fix the bug in flags in the HEADER
  3.20    Include SNR and POS in OIFITS products
  3.19    Add the parameters for phase-3
  3.18    Change the PRO.CATG depending on DPR.CATG
  3.17    Add the concatenation ID for the setup of calibration
  3.16    Kappa matrix
  3.15    Fix bug in QC parameter
  3.14    QC parameters for matrix
  3.12    Big improvement in plots
  3.11    Big improvement in plots, coherent estimator for t3amp
  3.10    pndrsReduce should now be called with --mode=abcd
  3.09    Deal with CPL erasing the datasize in files.
  3.08    setupMatrix independent of DIT, but check of bad-pixel consistency.
  3.07    setupMatrix depends on DIT<1ms
  3.06    Compute kappa-matrix even for 3T.
  3.05    Back to normal computation of SNR.
  t3.03   Matrix is now 3D 
  3.02    Add the --logLevel in scripts
  3.00    Add the QC parameters.
  t3.01   Test new phasor for OPD, very very high SNR.
          Should verify with fringe-less data.
  t3.00   Add some QC parameters
  t2.99   Put 2 pixels to 0
  t2.98   Put 5 pixels to 0
  t2.96   Weigh by residual, discard
  t2.95   Weigh by residual, discard
  2.94    Remove bug in the way the flux is re-computed by the HACK.
  t2.93   Remove one pixel (5,19)
  2.92    New plots
  2.90    Check matrix <15adu/pixel/dit
  2.89    First stable version for RAPID.
  2.89    Use only DPR.TYPE=KAPPA,DARK for the kappa matrix.
  2.87    Now chek again matrix
  2.86    Creates pndrsShowPixel
  2.85    The kappa matrix is *not* tested.
  2.79    Add DET.POLAR in the getsetup (also in matrix)
  2.77    Deal with non-graphical mode for ESO
  2.76    Create pndrsComputeSingleMatrix, SingleOiData, SingleSpecCal
  2.75    Check the matrix at >3 and <0.1
  2.74    Add the DRS version at reduction and calibration
          Add the scriptDate for reduction and calibration
  2.73:   force 6pixels of low-frequency in the bias-estimate of AC
  2.72b:  implement the DARK window for RAPID.
  2.71:   take spectral calib of the begining of the night.
  2.7:    implement the PRO.CATG keywords.
  2.62 :  update all matrix->KAPPA_MATRIX, specCal->SPECTRAL_CALIB...
  2.61:   stable version
  2.601:  better support of catalogs and search
  2.600:  full-spectre and no check of matrix
  2.599:  matrix now check >5 and <0
  2.598:  check the matrix to avoid using poor quality matrix
  2.597:  only H
  2.596:  enlarge the acceptance to test the J-band
  2.595:  re-order the dispersion for RAPID in PIONIER
  2.58:   remove low frequencies when computing
          closure phases to avoid bias.
  2.57:   handle RAPID in BETI.
  2.56:   fix a bug in interpolation "interp"
  2.55:   reshuffle all the modes, enable "ns"
  2.54:   implement abcdfaint
  2.53:   update for K-band after COM-2
  2.52:   compute t3amp
  2.51:   add the n2arr and amp2arr in the HEADER as a
          workaround for the flux
  2.50:   force tau0=1ms when using UTs
  2.49:   fix bug in the way the telescope are found!!
  2.48:   Improve the way the flux are handled when 2 polarisation
          (assume different flux level for each polarisation
          for each telescope).
  2.47:   Create mode "abcd" -- Use negative frequencies to measure the bias
  2.44:   Improve pndrsInspect and remove the enlargement.
  2.43:   Implement new dispersion of LARGE in H-band
  2.42:   Fix the issue with bad dispersion
  2.4:    Deal with the 4T-ABCD-K combiner
  2.3:    Deal with the change of dispersion direction due to motorisation
          (can still reduce data from before).
  2.2:    deal with the motorization change
  2.0:    replace opd(2)-opd(1) by opd(1) - opd(2) in
          pndrsGetData -> invers all phases
  1.9e:   hack the prism SMALL for two days -> implemented in 1.9
  1.9sim: simulated data -> no bias observed.
  1.9b:   with linear fit of amp2/n2 -> no improvement -> removed
  1.9c:   with (sqrt(n2))(sum)/n instead of n2(sum) ->
          no improvement -> removed
*/

func pndrs(void)
/* DOCUMENT pndrs(void)

   DESCRIPTION
   PIONIER Data Reduction Software
   type pndrs() for the version number.
   
*/
{
    if (am_subroutine())
    {
        help, pndrs;
    }
    
    return pndrsVersion;
}

write,"pndrs package loaded ("+pndrsVersion+")";

/* Default graphical functions */
pldefault,marks=0;
pltitle_height = 16;

/* Default log managing functions */
oiFitsDefaultWriteLog = pndrsWritePnrLog;
oiFitsDefaultReadLog  = pndrsReadPnrLog;
oiFitsDefaultSetup    = pndrsGetSetup;
