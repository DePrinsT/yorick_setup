
/**** MODULE   'fftwPlugin' ****/
/****                 contains :                         ****/
/****    o DEFINE CONSTANTS                                ****/
/****    o ENUM CONSTANTS                                ****/
/****    o STRUCTURES                                    ****/
/****    o FUNCTIONS                                     ****/


if (!is_void(plug_in)) plug_in, "fftwPlugin";
write,"fftwPlugin plugin loaded";


/****** DEFINE CONSTANTS (numerical ones only) ******/

/****** ENUM CONSTANTS ******/

/****** STRUCTURES ******/

/****** FUNCTIONS ******/

/* 
 * Wrapping of 'fftwComplex1D' function */   
  
extern __fftwComplex1D;
/* PROTOTYPE
    void  fftwComplex1D( pointer , pointer , int )
*/
/* DOCUMENT  fftwComplex1D( pointer , pointer , int )
  * C-prototype:
    ------------
    void fftwComplex1D  (fftw_complex *in ,fftw_complex *out ,int n)
*/

/* 
 * Wrapping of 'fftwReal1D' function */   
  
extern __fftwReal1D;
/* PROTOTYPE
    void  fftwReal1D( float array , float array , int )
*/
/* DOCUMENT  fftwReal1D( float array , float array , int )
  * C-prototype:
    ------------
    void fftwReal1D  (float *in ,float *out ,int n)
*/
