/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsConfig(void)
/* DOCUMENT pndrsConfig(void)

   CORRELATION MAPS
   - mapABCD_H: 24 outputs, Myriam's component, natural light
   - mapABCD_Hup: the same, for polarisation "up"
   - mapABCD_Hdown: the same, for polarisation "down"
   - mapABCD_Hpol: the same, with recording of both polarisation,
            the first 24 outputs are polar "down".
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.14 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsConfig;
    }   
    return version;
}


/* ********************************************************** */

/* Hypothesis to build the correlation maps:
   - base are increasing 1->nbase.
   - for each base, t1<t2
   - t1 and t2 are the PIONIER arms: 1 being the closest to the camera, so that
     1,2,3,4 are VLTI IP 1,3,5,7

   - currently, the correlation map should contain all baseline between 1-max(base)
     and all telescope between 1-max(t1,t2).

   The 'combined' correlation map have increasing baseline.
 */

struct struct_pndrsCorrelation {
  int t1;
  int t2;
  int base;
  int win;
  string pol;
  double vis;
  double phi;
  string type;
};

/*
  Case 24 outputs with the 4T-ABCD IONIC component from Myriam,
  Note that:
  0.4*pi ~80deg shift for 12,23,13,24 and 34
  0.17*pi ~30deg shifts for 14
  This is in agreement with Benisty et al., A&A 498, 601-613 (2009)

  Relative phase between the baselines is ad-hoc, meaning that
  the final closure-phase has no physical meaning yet.

  Base 3 and 5 have quite different spectral response... much redder.
*/

/*
  Available map so far:
  mapABCD_H :  ABCD, natural light
  mapABCD_Hpol :  ABCD, both polar
  mapABCD_Hdown :  ABCD, polar-1
  mapABCD_Hup   :  ABCD, polar-2
  
  mapABCD_H_AC :  ABCD used as AC, natural light
  
  mapABCD_K    :  ABCD used as AC, natural light
  mapABCD_K_AC :  ABCD used as AC, natural light
*/

extern mapABCD_H;
mapABCD_H = array(struct_pndrsCorrelation, 24);
mapABCD_H.pol = "Pnat";
mapABCD_H.type = "abcd";

mapABCD_H.win  = indgen(24);
mapABCD_H.t1   = [1,1,1,1,2,2,1,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3];
mapABCD_H.t2   = [2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4,4,4,3,3,4,4,4,4];
mapABCD_H.base = [1,1,1,1,2,2,3,3,3,3,4,4,4,4,5,5,5,5,2,2,6,6,6,6];
mapABCD_H.vis  = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

mapABCD_H.phi= [0,      1,   1.6,   0.6,
                0,      1,          
                0,      1,   1.6,   0.6,
                0,      1,  1.83,   0.83,
                0,      1,   1.6,   0.6,
                             1.6,   0.6,
                0,      1,   1.6,   0.6] *(pi);
                //                0,      1,   0.6,   1.6] *(pi);

/* Case 24 outputs with the 4T-ABCD IONIC component but with wollaston */
extern mapABCD_Hup, mapABCD_Hdown;
mapABCD_Hup       = mapABCD_H;
mapABCD_Hup.pol   = "Pup";
mapABCD_Hup.type  = "abcd";
mapABCD_Hdown      = mapABCD_H;
mapABCD_Hdown.pol  = "Pdown";
mapABCD_Hdown.type = "abcd";

/* Case 48 outputs with the 4T-ABCD IONIC component with wollaston */
extern mapABCD_Hpol;
mapABCD_Hpol = grow(mapABCD_Hdown,mapABCD_Hup);
mapABCD_Hpol(25:).base += 6;
mapABCD_Hpol(25:).win  += 24;

/* Hack for RAPID first night */
// mapABCD_Hpol = mapABCD_Hpol([1,24, 2,25, 3,26, 4,27, 5,28, 6,29, 7,30, 8,31, 9,32, 10,33, 11,34, 12,35,
//                              13,36, 13, 37, 14,38, 14,39, 16,40, 17,41, 18,42, 19,43, 20,44,
//                              21,45, 22,46, 23,47, 24,48]);

/* Test */
// mapABCD_Hpol(25:).t1  += 4;
// mapABCD_Hpol(25:).t2  += 4;

/* Case 12 outputs with the 4-ABCD IONIC component */
extern mapABCD_H_AC;
mapABCD_H_AC = mapABCD_H([1,2,5,6,7,8,11,12,15,16,21,22]);
mapABCD_H_AC.win = indgen(12);
mapABCD_H_AC.type = "ac";

/* Case 12 outputs with the 4-ABCD IONIC component and polar */
extern mapABCD_H_ACup, mapABCD_H_ACdown;
mapABCD_H_ACup = mapABCD_H_ACdown = mapABCD_H_AC;
mapABCD_H_ACup.pol   = "Pup";
mapABCD_H_ACup.type  = "ac";
mapABCD_H_ACdown.pol  = "Pdown";
mapABCD_H_ACdown.type = "ac";

/* ************************************************************** */

/* The 4-AC-H IONIC component */
extern mapAC_H;
mapAC_H = array(struct_pndrsCorrelation, 12);
mapAC_H.pol = "Pnat";
mapAC_H.type = "ac";

mapAC_H.win  = indgen(12);
mapAC_H.t1   = [1,1,2,1,1,1,1,2,2,2,3,3];
mapAC_H.t2   = [2,2,3,3,3,4,4,4,4,3,4,4];
mapAC_H.base = [1,1,2,3,3,4,4,5,5,2,6,6];

mapAC_H.vis  = [1,1,1,1,1,1,1,1,1,1,1,1];
mapAC_H.phi= [0, 1,
            1,
            0, 1,
            0, 1,
            1, 0,
            0,
            1, 0] * pi;

extern mapAC_Hpol, mapAC_Hup, mapAC_Hdown;
mapAC_Hup = mapAC_Hdown = mapAC_H;
mapAC_Hup.pol   = "Pup";
mapAC_Hdown.pol = "Pdown";
mapAC_Hup.type   = "ac";
mapAC_Hdown.type = "ac";
mapAC_Hpol = grow(mapAC_Hdown,mapAC_Hup);
mapAC_Hpol(13:).base += 6;
mapAC_Hpol(13:).win  += 12;

/* ************************************************************** */

/* The 4-ABCD-K IONIC component */
extern mapABCD_K;
mapABCD_K = array(struct_pndrsCorrelation, 24);
mapABCD_K.pol  = "Pnat";
mapABCD_K.type = "abcd";

mapABCD_K.win  = indgen(24);
mapABCD_K.base = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6];
mapABCD_K.t1   = [3,3,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1];
mapABCD_K.t2   = [4,4,4,4,4,4,4,4,3,3,3,3,4,4,4,4,3,3,3,3,2,2,2,2];
mapABCD_K.vis  = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
mapABCD_K.phi  = [0,1, 0.4,1.4,
                  0,1, 0.3,1.3,
                  0,1, 1.6,0.6,
                  0,1, 0.5,1.5,
                  0,1, 0.4,1.4,
                  0,1, 0.5,1.5]*(pi);


extern mapABCD_K_AC;
mapABCD_K_AC = mapABCD_K([1,2,5,6,9,10,13,14,17,18,21,22]);
mapABCD_K_AC.win = indgen(12);
mapABCD_K_AC.type  = "ac";

/* ************************************************************** */

extern mapACbeti_H;
mapACbeti_H = mapABCD_H([1,2,5,7,8,11,12,15,16,6,21,22])(::-1);
mapACbeti_H.win  = indgen(12);
mapACbeti_H.type  = "ac";

// mapACbeti_H = mapAC_H;
// mapACbeti_H.t1 = mapACbeti_H.t1(::-1);
// mapACbeti_H.t2 = mapACbeti_H.t2(::-1);

extern mapACbeti_Hpol, mapACbeti_Hup, mapACbeti_Hdown;
mapACbeti_Hup = mapACbeti_Hdown = mapACbeti_H;
mapACbeti_Hup.pol   = "Pup";
mapACbeti_Hdown.pol = "Pdown";
mapACbeti_Hup.type    = "ac";
mapACbeti_Hdown.type  = "ac";
mapACbeti_Hpol = grow(mapACbeti_Hdown,mapACbeti_Hup);
mapACbeti_Hpol(13:).base += 6;
mapACbeti_Hpol(13:).win  += 12;

mapACbeti_Hpol = [mapACbeti_Hdown,mapACbeti_Hup];
mapACbeti_Hpol(,2).base += 6;
mapACbeti_Hpol(,2).win  += 12;
mapACbeti_Hpol = transpose(mapACbeti_Hpol)(*);


/* ************************************************************** */

/* Define some default filter for fringe filtering */
pndrsFilterWide = [0.2,0.9] * 1e6;

pndrsFilterHClo = [0.47,0.72] * 1e6;
pndrsFilterHSnr = [0.52,0.67] * 1e6;
pndrsFilterHIn  = [0.38,0.83] * 1e6;
pndrsFilterHOut = [0.10,3.00] * 1e6;

pndrsFilterKClo = [0.40,0.53] * 1e6;
pndrsFilterKSnr = [0.41,0.48] * 1e6;
pndrsFilterKIn  = [0.38,0.62] * 1e6;
pndrsFilterKOut = [0.10,3.00] * 1e6;

/* 0 = filtOut-filterIn
   1 = pndrsFindBackground (use filterIn)
   2 = pndrsGetPicWidth    (return array (lbd, base) )
   3 = fixed integration limits, pndrsFilterHIn */
pndrsOptionBiasMethod = 2;

/* ************************************************************** */

func pndrsConfigGetBase(map,i,j,pol)
/* DOCUMENT pndrsConfigGetBase(map,i,j,pol)

   DESCRIPTION
   Return the id inside the "map" array corresponding
   to the telescopes ij and polarisiton pol.

   If the ji pair is found instead of ij, then
   the id is returned as -id.
 */
{
  local id;
  
  id = where( map.t1==i &
              map.t2==j &
              map.pol==pol );
  if (is_array(id)) return id(1);
  
  id = where( map.t1==j &
              map.t2==i &
              map.pol==pol );
  if (is_array(id)) return -id(1);
  
  return where();
}
