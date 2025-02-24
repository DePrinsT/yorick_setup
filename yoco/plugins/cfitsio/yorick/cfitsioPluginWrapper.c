#include "pstdlib.h"
#include "string.h"

#include "ydata.h"
#include "yapi.h"

#include "fitsio.h"

/* ============================================================
   
   The FITS file is stored as an opaque object whose constructor
   and destructor are defined.

   A great evolution would be to embed the "status"
   in the fitsFile object too.

   ============================================================ */


int CheckCfitsioStatus(int status)
{
  if (status != 0 &&
      status != KEY_NO_EXIST &&
      status != COL_NOT_FOUND &&
      status != COL_NOT_UNIQUE )
  {
    /* Convert into error message */
    char err_text[FLEN_ERRMSG];
    char long_err_text[FLEN_ERRMSG+65];
    fits_get_errstatus(status, err_text);
    
    /* Stop on error */
    sprintf(long_err_text,"cfitsioPlugin\n %i -> %s",status,err_text);
    y_error(long_err_text);
  }

  return status;
}

int PushCfitsioStatus(int status)
{
  CheckCfitsioStatus(status);
  PushIntValue(status);

  return status;
}

/*   ============================================================ */
 
/* Define the opaque object "object_cfitsio".
   Currently it only contains the pointer
   to the FITS file stream but we can add additional parameters
   such as the CFITSIO status */
static void fits_free(void *);
static void fits_print(void *);

typedef struct object_cfitsio object_cfitsio;
struct object_cfitsio {
  fitsfile *ptr; /* FITS file handle */
};


/* Build the associated class for the opaque object */
static y_userobj_t cfitsio_class = {
  "object_cfitsio", fits_free, fits_print, 0, 0, NULL
};

/* on_free is use to cleanup data when object is no longer referenced */
static void fits_free(void *addr)
{
  object_cfitsio *this = (object_cfitsio *)addr;
  int status = 0;

  /* check if FITS stream still open */
  if ( this->ptr != NULL )
  {
    /* close file */
    ffclos( this->ptr, &status );
    this->ptr = NULL;
  }

  /* make an warning and not an error so that the
     opaque object is indeed closed. */
  if (status)
    {
      char err_text[FLEN_ERRMSG];
      char long_err_text[FLEN_ERRMSG+65];
      fits_get_errstatus(status, err_text);
      sprintf(long_err_text,"cfitsioPlugin cannot close file\n %i -> %s",status,err_text);
      y_warn(long_err_text);
    }
}

/* on_print is used by Yorick's info command */
static void fits_print(void *addr)
{
  object_cfitsio *this = (object_cfitsio *)addr;

  if ( this->ptr == NULL )
  {
    y_print("empty object_cfitsio (closed FITS stream)", 1);
  }
  else
  {
    /* read information */
    int nhdu,hdunum,hdutype,filemode,status = 0;
    char filename[FLEN_FILENAME];
    char line[80];
    ffflnm( this->ptr, filename, &status );
    ffflmd( this->ptr, &filemode, &status );
    ffghdt( this->ptr, &hdutype, &status );
    ffthdu( this->ptr, &nhdu, &status);
    ffghdn( this->ptr, &hdunum);
    CheckCfitsioStatus(status);
    
    /* filename */
    if      (filemode==READONLY)  y_print("readonly object_cfitsio (FITS stream):",1);
    else if (filemode==READWRITE) y_print("readwrite object_cfitsio (FITS stream):",1);
    else                          y_print("unknown object_cfitsio (FITS stream):",1);
    y_print(filename, 1);
    
    /* additional info */
    sprintf(line,"  CURRENT HDU: %d over %d",hdunum,nhdu);
    y_print(line, 1);
  }
}

/* push a new opaque object_cfitsio on the stack */
void ypush_fitsfile(fitsfile *fptr)
{
  /* push an new opaque object on the stack */
  object_cfitsio *this;
  this = (object_cfitsio *)ypush_obj(&cfitsio_class, sizeof(object_cfitsio));

  /* fill it */
  this->ptr = fptr;
}

/* get the fitsfile pointer from an opaque object_cfitsio in the stack */
fitsfile *ygeta_fitsfile(int iarg)
{
  object_cfitsio *this = (object_cfitsio *)yget_obj(iarg, &cfitsio_class);
  if ( this == NULL ||
       this->ptr == NULL )
  {
    y_error("empty object_cfitsio (FITS stream closed?)");
  }

  /* return the pointer to FITS */
  return (fitsfile *)(this->ptr);
}

/* ============================================================
   
                             Open/Close

   These functions have been deeply modifed.
   
   ============================================================ */

extern BuiltIn Y___ffopen;

// extern int ffopen(long *, char *, int , int *);
void
Y___ffopen(int n)
{
  if (n!=2) YError("__ffopen takes exactly 2 arguments");

  /* check filename */
  char *filename = yarg_sq(1);

  if ( strlen(filename) > FLEN_FILENAME ) YError("filename string too long");

  int status = 0;
  fitsfile *fptr;
  CheckCfitsioStatus( ffopen(&fptr, filename, yarg_si(0), &status) );

  /* return the newly created FITS file */
  ypush_fitsfile(fptr);
}

extern BuiltIn Y___ffinit;

// extern int ffinit(long *, char *, int *);
void
Y___ffinit(int n)
{
  if (n!=1) YError("__ffinit takes exactly 1 argument");

  /* check filename */
  char *filename = yarg_sq(0);
  if ( strlen(filename) > FLEN_FILENAME ) YError("filename string too long");

  int status = 0;
  fitsfile *fptr;
  CheckCfitsioStatus( ffinit( &fptr, filename, &status) );

  /* return this newly created FITS file */
  ypush_fitsfile(fptr);
}

extern BuiltIn Y___ffclos;

// extern int ffclos(long , int *);
void
Y___ffclos(int n)
{
  if (n!=1) YError("__ffclos takes exactly 1 argument");

  /* recover the position of the argument in the global table.
     (should be called before any yget_) */
  long pos = yget_ref(0);
  int status = 0; 
  object_cfitsio *this = (object_cfitsio *)yget_obj(0, &cfitsio_class);

  /* close file stream and replace pointer to NULL */
  if ( this->ptr != NULL )
  {
    ffclos(this->ptr, &status);
    this->ptr = NULL;
  }
  else
  {
    y_warn("object_cfitsio (FITS stream) was already closed");
  }

  /* Free the input argument */
  ypush_nil();
  yput_global(pos, 0);

  /* check status at the end */
  CheckCfitsioStatus(status);
}

extern BuiltIn Y___ffdelt;

// extern int ffdelt(long , int *);
void
Y___ffdelt(int n)
{
  if (n!=1) YError("__ffdelt takes exactly 1 argument");

  /* recover the position of the argument in the global table 
     (should be called before any yget_) */
  long pos = yget_ref(0);
  int status = 0; 
  object_cfitsio *this = (object_cfitsio *)yget_obj(0, &cfitsio_class);

  /* close file stream and replace pointer to NULL */
  if (this->ptr != NULL)
  {
    ffdelt(this->ptr, &status);
    this->ptr = NULL;
  }
  else
  {
    y_warn("object_cfitsio (FITS stream) was already closed");
  }

  /* Free the input variable */
  ypush_nil();
  yput_global(pos, 0);

  /* check status at the end */
  CheckCfitsioStatus(status);
}


/* ============================================================
   
                    Simple wrapper functions
   
   ============================================================ */


// extern int ffexist(char *, int *, int *);
void
Y___ffexist(int n)
{
  if (n!=1) YError("__ffexist takes exactly 1 argument");
  char *filename = yarg_sq(0);
  if ( strlen(filename) > FLEN_FILENAME ) YError("filename string too long");

  int status = 0;
  int exist  = 0;
  CheckCfitsioStatus(ffexist(filename, &exist, &status));

  PushIntValue(exist);
}

extern BuiltIn Y___ffurlt;

// extern int ffurlt(long , char *, int *);
void
Y___ffurlt(int n)
{
  if (n!=1) YError("__ffurlt takes exactly 1 argument");

  int status = 0;
  char url[FLEN_FILENAME];
  CheckCfitsioStatus(ffurlt(ygeta_fitsfile(0), url, &status));

  *ypush_q(0) = (char *)p_strcpy(url);
}


extern BuiltIn Y___ffflnm;

// extern int ffflnm(long , char *, int *);
void
Y___ffflnm(int n)
{
  if (n!=1) YError("__ffflnm takes exactly 1 argument"); 

  int status = 0;
  char filename[FLEN_FILENAME];
  CheckCfitsioStatus(ffflnm(ygeta_fitsfile(0), filename, &status)); 

  *ypush_q(0) = p_strcpy(filename);
}

extern BuiltIn Y___ffflmd;

// extern int ffflmd(long , int *, int *);
void
Y___ffflmd(int n)
{
  if (n!=1) YError("__ffflmd takes exactly 1 argument");

  int status = 0;
  int iomode = 0;
  CheckCfitsioStatus(ffflmd(ygeta_fitsfile(0), &iomode, &status));

  PushIntValue(iomode);
}

extern BuiltIn Y___ffvers;

// extern float ffvers(float *);
void
Y___ffvers(int n)
{
  if (n!=1) YError("__ffvers takes exactly 1 void argument");

  float version;
  PushDoubleValue((double)ffvers(&version));
}

extern BuiltIn Y___ffgerr;

// extern void ffgerr(int , char *);
void
Y___ffgerr(int n)
{
  if (n!=1) YError("__ffgerr takes exactly 1 argument");

  char err[FLEN_ERRMSG];
  ffgerr(yarg_si(0), err);

  *ypush_q(0) = p_strcpy(err);
}

extern BuiltIn Y___ffgmsg;

// extern int ffgmsg(char *);
void
Y___ffgmsg(int n)
{
  if (n!=1) YError("__ffgmsg takes exactly 1 void argument");
  char err[FLEN_ERRMSG];
  if ( ffgmsg(err) == 0 )
    {
      ypush_nil();
    }
  else
    {
      *ypush_q(0) = p_strcpy(err);
    }
}

extern BuiltIn Y___ffpky;

// extern int ffpky(long , int , char *, void *, char *, int *);
void
Y___ffpky(int n)
{
  if (n!=5) YError("__ffpky takes exactly 5 arguments");
  long pos = yget_ref(n-1);

  int status = 0;
  CheckCfitsioStatus(ffpky(ygeta_fitsfile(4), yarg_si(3), yarg_sq(2), 
    yarg_sp(1), yarg_sq(0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffpcom;

// extern int ffpcom(long , char *, int *);
void
Y___ffpcom(int n)
{
  if (n!=2) YError("__ffpcom takes exactly 2 arguments");

  int status = 0;
  PushCfitsioStatus(ffpcom(ygeta_fitsfile(1), yarg_sq(0), &status));
}

extern BuiltIn Y___ffpunt;

// extern int ffpunt(long , char *, char *, int *);
void
Y___ffpunt(int n)
{
  if (n!=3) YError("__ffpunt takes exactly 3 arguments");

  int status = 0;
  PushCfitsioStatus(ffpunt(ygeta_fitsfile(2), yarg_sq(1), yarg_sq(0), 
    &status));
}

extern BuiltIn Y___ffphis;

// extern int ffphis(long , char *, int *);
void
Y___ffphis(int n)
{
  if (n!=2) YError("__ffphis takes exactly 2 arguments");

  int status = 0;
  PushCfitsioStatus(ffphis(ygeta_fitsfile(1), yarg_sq(0), &status));
}

extern BuiltIn Y___ffpdat;

// extern int ffpdat(long , int *);
void
Y___ffpdat(int n)
{
  if (n!=1) YError("__ffpdat takes exactly 1 argument");

  int status = 0;
  PushCfitsioStatus(ffpdat(ygeta_fitsfile(0), &status));
}

extern BuiltIn Y___ffpcks;

// extern int ffpcks (long , int *);
void
Y___ffpcks(int n)
{
  if (n!=1) YError("__ffpcks takes exactly 1 argument");

  int status = 0;
  PushCfitsioStatus(ffpcks(ygeta_fitsfile(0), &status));
}

extern BuiltIn Y___ffptdm;

// extern int ffptdm(long , int , int , long *, int *);
void
Y___ffptdm(int n)
{
  if (n!=4) YError("__ffptdm takes exactly 4 arguments");

  int status = 0;
  PushCfitsioStatus(ffptdm(ygeta_fitsfile(3), yarg_si(2), yarg_si(1), 
			   yarg_l(0,0), &status));
}

extern BuiltIn Y___ffghsp;

// extern int ffghsp(long , int *, int *, int *);
void
Y___ffghsp(int n)
{
  if (n!=2) YError("__ffghsp takes exactly 2 arguments");

  int keysexist, status = 0;
  CheckCfitsioStatus(ffghsp(ygeta_fitsfile(1), &keysexist, yarg_i(0,0), &status));

  PushIntValue(keysexist);
}

extern BuiltIn Y___ffgnxk;

// extern int ffgnxk(long , char **, int , char **, int , char *, int *);
void
Y___ffgnxk(int n)
{
  if (n!=5) YError("__ffgnxk takes exactly 5 arguments");

  int status = 0;
  char card[FLEN_CARD];
  CheckCfitsioStatus(ffgnxk(ygeta_fitsfile(4), yarg_q(3,0), yarg_si(2), yarg_q(1,0), 
    yarg_si(0), card, &status));

  *ypush_q(0) = p_strcpy(card);
}

extern BuiltIn Y___ffgrec;

// extern int ffgrec(long , int , char *, int *);
void
Y___ffgrec(int n)
{
  if (n!=2) YError("__ffgrec takes exactly 2 arguments");

  int status = 0;
  char card[FLEN_CARD];
  CheckCfitsioStatus(ffgrec(ygeta_fitsfile(1), yarg_si(0), card, &status));

  *ypush_q(0) = p_strcpy(card);
}

extern BuiltIn Y___ffgcrd;

// extern int ffgcrd(long , char *, char *, int *);
void
Y___ffgcrd(int n)
{
  if (n!=2) YError("__ffgcrd takes exactly 2 arguments");

  int status=0;
  char card[FLEN_CARD];
  CheckCfitsioStatus(ffgcrd(ygeta_fitsfile(1), yarg_sq(0), card, &status));

  *ypush_q(0) = p_strcpy(card);
}

extern BuiltIn Y___ffgunt;

// extern int ffgunt(long , char *, char *, int *);
void
Y___ffgunt(int n)
{
  if (n!=2) YError("__ffgunt takes exactly 2 arguments");

  int status=0;
  char card[FLEN_CARD];
  CheckCfitsioStatus(ffgunt(ygeta_fitsfile(1), yarg_sq(0), card, &status));

  *ypush_q(0) = p_strcpy(card);
}

extern BuiltIn Y___ffgky;

// extern int ffgky(long , int , char *, void *, char *, int *);
void
Y___ffgky(int n)
{
  if (n!=5) YError("__ffgky takes exactly 5 arguments");

  int status=0;
  PushCfitsioStatus(ffgky(ygeta_fitsfile(4), yarg_si(3), yarg_sq(2), 
			  yarg_sp(1), yarg_sq(0), &status));
}

extern BuiltIn Y___ffgtdm;

// extern int ffgtdm(long , int , int , int *, long *, int *);
void
Y___ffgtdm(int n)
{
  if (n!=5) YError("__ffgtdm takes exactly 5 arguments");

  int status=0;
  PushCfitsioStatus(ffgtdm(ygeta_fitsfile(4), yarg_si(3), yarg_si(2), 
			   yarg_i(1,0), yarg_l(0,0), &status));
}

extern BuiltIn Y___ffuky;

// extern int ffuky(long , int , char *, void *, char *, int *);
void
Y___ffuky(int n)
{
  if (n!=5) YError("__ffuky takes exactly 5 arguments");

  int status=0;
  CheckCfitsioStatus(ffuky(ygeta_fitsfile(4), yarg_si(3), yarg_sq(2), 
			  yarg_sp(1), yarg_sq(0), &status));
}

extern BuiltIn Y___ffukyu;

// extern int ffukyu(long , char *, char *, int *);
void
Y___ffukyu(int n)
{
  if (n!=3) YError("__ffuky takes exactly 3 arguments");

  int status=0;
  CheckCfitsioStatus(ffukyu(ygeta_fitsfile(2), yarg_sq(1),
                            yarg_sq(0), &status));
}


extern BuiltIn Y___ffmnam;

// extern int ffmnam(long , char *, char *, int *);
void
Y___ffmnam(int n)
{
  if (n!=3) YError("__ffmnam takes exactly 3 arguments");

  int status=0;
  PushCfitsioStatus(ffmnam(ygeta_fitsfile(2), yarg_sq(1), yarg_sq(0), 
			   &status));
}

extern BuiltIn Y___ffmcom;

// extern int ffmcom(long , char *, char *, int *);
void
Y___ffmcom(int n)
{
  if (n!=3) YError("__ffmcom takes exactly 3 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffmcom(ygeta_fitsfile(2), yarg_sq(1), yarg_sq(0), 
			   &status));
  
  ypush_global(pos);
}

extern BuiltIn Y___ffdkey;

// extern int ffdkey(long , char *, int *);
void
Y___ffdkey(int n)
{
  if (n!=2) YError("__ffdkey takes exactly 2 arguments");
  int status=0;
  PushCfitsioStatus(ffdkey(ygeta_fitsfile(1), yarg_sq(0), &status));
}

extern BuiltIn Y___ffdrec;

// extern int ffdrec(long , int , int *);
void
Y___ffdrec(int n)
{
  if (n!=2) YError("__ffdrec takes exactly 2 arguments");
  int status=0;
  PushCfitsioStatus(ffdrec(ygeta_fitsfile(1), yarg_si(0), &status));
}

extern BuiltIn Y___ffghdn;

// extern int ffghdn(long , int *);
void
Y___ffghdn(int n)
{
  if (n!=1) YError("__ffghdn takes exactly 1 argument");
  int hdunum;
  ffghdn(ygeta_fitsfile(0), &hdunum);
  PushIntValue( hdunum );
}

extern BuiltIn Y___ffghdt;

// extern int ffghdt(long , int *, int *);
void
Y___ffghdt(int n)
{
  if (n!=1) YError("__ffghdt takes exactly 1 argument");
  int status=0;
  int hdutype;
  CheckCfitsioStatus(ffghdt(ygeta_fitsfile(0), &hdutype, &status));
  PushIntValue( hdutype );
}

extern BuiltIn Y___ffdhdu;

void
Y___ffdhdu(int n)
{
  if (n!=1) YError("__ffdhdu takes exactly 1 argument");
  int status=0;
  int hdutype;
  PushCfitsioStatus(ffdhdu(ygeta_fitsfile(0), &hdutype, &status));
}

extern BuiltIn Y___ffgidt;

// extern int ffgidt(long , int *, int *);
void
Y___ffgidt(int n)
{
  if (n!=1) YError("__ffgidt takes exactly 1 argument");
  int status=0;
  int bitpix;
  CheckCfitsioStatus(ffgidt(ygeta_fitsfile(0), &bitpix, &status));
  PushIntValue( bitpix );
}

extern BuiltIn Y___ffgidm;

// extern int ffgidm(long , int *, int *);
void
Y___ffgidm(int n)
{
  if (n!=1) YError("__ffgidm takes exactly 1 argument");
  int status=0;
  int naxis;
  CheckCfitsioStatus(ffgidm(ygeta_fitsfile(0), &naxis, &status));
  PushIntValue( naxis );
}

extern BuiltIn Y___ffgisz;

// extern int ffgisz(long , int , long *, int *);
void
Y___ffgisz(int n)
{
  if (n!=1) YError("__ffgisz takes exactly 1 argument");
  
  /* get the fits file */
  fitsfile *fptr = ygeta_fitsfile(0);

  /* read the naxis in an array [1,naxis] */
  int naxis, status=0;
  CheckCfitsioStatus( ffgidm(fptr, &naxis, &status) );

  /* push daxes as array of naxis+1 elements */
  long dims[2];
  dims[0] = (long)1;
  dims[1] = (long)naxis+1;
  long *daxes = ypush_l(dims);
  
  /* fill in daxes */
  daxes[0] = naxis;
  CheckCfitsioStatus(ffgisz(fptr, naxis, daxes+1, &status));
}

extern BuiltIn Y___ffmahd;

// extern int ffmahd(long , int , int *, int *);
void
Y___ffmahd(int n)
{
  if (n!=2) YError("__ffmahd takes exactly 2 arguments");
  long pos = yget_ref(n-1);

  int hdut, status=0;
  CheckCfitsioStatus(ffmahd(ygeta_fitsfile(1), yarg_si(0), &hdut, &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffmrhd;

// extern int ffmrhd(long , int , int *, int *);
void
Y___ffmrhd(int n)
{
  if (n!=2) YError("__ffmrhd takes exactly 2 arguments");
  long pos = yget_ref(n-1);

  int hdut, status=0;
  CheckCfitsioStatus(ffmrhd(ygeta_fitsfile(1), yarg_si(0), &hdut, &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffmnhd;

// extern int ffmnhd(long , int , char *, int , int *);
void
Y___ffmnhd(int n)
{
  if (n!=3) YError("__ffmnhd takes exactly 3 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffmnhd(ygeta_fitsfile(2), yarg_si(1), yarg_sq(0), 0, &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffthdu;

// extern int ffthdu(long , int *, int *);
void
Y___ffthdu(int n)
{
  if (n!=1) YError("__ffthdu takes exactly 1 argument");

  int numhdus,status=0;
  CheckCfitsioStatus(ffthdu(ygeta_fitsfile(0), &numhdus, &status));

  PushIntValue(numhdus);
}

extern BuiltIn Y___ffcrim;

// extern int ffcrim(long , int , int , long *, int *);
void
Y___ffcrim(int n)
{
  if (n!=4) YError("__ffcrim takes exactly 4 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffcrim(ygeta_fitsfile(3), yarg_si(2), yarg_si(1), 
			    yarg_l(0,0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffcrtb;

// extern int ffcrtb(long , int , long , int , char **, char **, char **, char *, int *);
void
Y___ffcrtb(int n)
{
  if (n!=8) YError("__ffcrtb takes exactly 8 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffcrtb(ygeta_fitsfile(7), yarg_si(6), yarg_sl(5), 
			    yarg_si(4), yarg_q(3,0), yarg_q(2,0),
			    yarg_q(1,0), yarg_sq(0), 
			    &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffgcno;

// extern int ffgcno(long , int , char *, int *, int *);
void
Y___ffgcno(int n)
{
  if (n!=4) YError("__ffgcno takes exactly 4 arguments");
  int status=0;
  PushCfitsioStatus(ffgcno(ygeta_fitsfile(3), yarg_si(2), yarg_sq(1), 
			   yarg_i(0,0), &status));
}

extern BuiltIn Y___ffgcnn;

// extern int ffgcnn(long , int , char *, char *, int *, int *);
void
Y___ffgcnn(int n)
{
  if (n!=5) YError("__ffgcnn takes exactly 5 arguments");

  int status=0;
  PushCfitsioStatus(ffgcnn(ygeta_fitsfile(4), yarg_si(3), yarg_sq(2), 
			   yarg_sq(1), yarg_i(0,0), &status));
}

extern BuiltIn Y___ffgtcl;

// extern int ffgtcl(long , int , int *, long *, long *, int *);
void
Y___ffgtcl(int n)
{
  if (n!=5) YError("__ffgtcl takes exactly 5 arguments");

  int status=0;
  PushCfitsioStatus(ffgtcl(ygeta_fitsfile(4), yarg_si(3), yarg_i(2,0), yarg_l(1,0), 
			   yarg_l(0,0), &status));
}

extern BuiltIn Y___ffgncl;

// extern int ffgncl(long , int *, int *);
void
Y___ffgncl(int n)
{
  if (n!=1) YError("__ffgncl takes exactly 1 argument");

  int ncl,status=0;
  CheckCfitsioStatus(ffgncl(ygeta_fitsfile(0), &ncl, &status));

  PushIntValue(ncl);
}

extern BuiltIn Y___ffgnrw;

// extern int ffgnrw(long , long *, int *);
void
Y___ffgnrw(int n)
{
  if (n!=1) YError("__ffgnrw takes exactly 1 argument");

  int status=0;
  long ncr;
  CheckCfitsioStatus(ffgnrw(ygeta_fitsfile(0), &ncr, &status));

  PushLongValue(ncr);
}

extern BuiltIn Y___ffgpxv;

// extern int ffgpxv(long , int , long *, long , void *, void *, int *, int *);
void
Y___ffgpxv(int n)
{
  if (n!=7) YError("__ffgpxv takes exactly 7 arguments");

  int status=0;
  PushCfitsioStatus(ffgpxv(ygeta_fitsfile(6), yarg_si(5), yarg_l(4,0), yarg_sl(3), 
			   yarg_sp(2), yarg_sp(1), yarg_i(0,0), &status));
}

extern BuiltIn Y___ffgsv;

// extern int ffgsv(long , int , long *, long *, long *, void *, void *, int *, int *);
void
Y___ffgsv(int n)
{
  if (n!=8) YError("__ffgsv takes exactly 8 arguments");

  int status=0;
  PushCfitsioStatus(ffgsv(ygeta_fitsfile(7), yarg_si(6), yarg_l(5,0), yarg_l(4,0), 
			  yarg_l(3,0), yarg_sp(2), yarg_sp(1), yarg_i(0,0), &status));
}

extern BuiltIn Y___ffgsv;

// extern int ffgsv(long , int , long, long, void *, void *, int *, int *);
void
Y___ffgpv(int n)
{
  if (n!=7) YError("__ffgpv takes exactly 7 arguments");

  int status=0;
  PushCfitsioStatus(ffgpv(ygeta_fitsfile(6), yarg_si(5), yarg_sl(4), 
			  yarg_sl(3), yarg_sp(2), yarg_sp(1), yarg_i(0,0), &status));
}

extern BuiltIn Y___ffgcv;

// extern int ffgcv(long , int , int , long , long , long , void *, void *, int *, int *);
void
Y___ffgcv(int n)
{
  if (n!=9) YError("__ffgcv takes exactly 9 arguments");

  int status=0;
  PushCfitsioStatus(ffgcv(ygeta_fitsfile(8), yarg_si(7), yarg_si(6), 
			  yarg_sl(5), yarg_sl(4), yarg_sl(3), yarg_sp(2), yarg_sp(1), 
			  yarg_i(0,0), &status));
}

extern BuiltIn Y___ffppx;

// extern int ffppx(long , int , long *, long , void *, int *);
void
Y___ffppx(int n)
{
  if (n!=5) YError("__ffppx takes exactly 5 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffppx(ygeta_fitsfile(4), yarg_si(3), yarg_l(2,0), yarg_sl(1), 
			   yarg_sp(0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffpcl;

// extern int ffpcl(long , int , int , long , long , long , void *, int *);
void
Y___ffpcl(int n)
{
  if (n!=7) YError("__ffpcl takes exactly 7 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffpcl(ygeta_fitsfile(6), yarg_si(5), yarg_si(4), 
			   yarg_sl(3), yarg_sl(2), yarg_sl(1), yarg_sp(0),
			   &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffirow;

// extern int ffirow(long , long , long , int *);
void
Y___ffirow(int n)
{
  if (n!=3) YError("__ffirow takes exactly 3 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffirow(ygeta_fitsfile(2), yarg_sl(1), yarg_sl(0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffdrow;

// extern int ffdrow(long , long , long , int *);
void
Y___ffdrow(int n)
{
  if (n!=3) YError("__ffdrow takes exactly 3 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffdrow(ygeta_fitsfile(2), yarg_sl(1), yarg_sl(0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffdrws;

// extern int ffdrws(long , long *, long , int *);
void
Y___ffdrws(int n)
{
  if (n!=2) YError("__ffdrws takes exactly 2 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  long ntot;
  CheckCfitsioStatus(ffdrws(ygeta_fitsfile(1), ygeta_l(0,&ntot,0), ntot, &status));

  ypush_global(pos);
}

extern BuiltIn Y___fficol;

// extern int fficol(long , int , char *, char *, int *);
void
Y___fficol(int n)
{
  if (n!=4) YError("__fficol takes exactly 4 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(fficol(ygeta_fitsfile(3), yarg_si(2), yarg_sq(1), 
			    yarg_sq(0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___fficls;

// extern int fficls(long , int , int , char **, char **, int *);
void
Y___fficls(int n)
{
  if (n!=5) YError("__fficls takes exactly 5 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(fficls(ygeta_fitsfile(4), yarg_si(3), yarg_si(2), 
			    yarg_q(1,0), yarg_q(0,0), &status));

  ypush_global(pos);
}

extern BuiltIn Y___ffmvec;

// extern int ffmvec(long , int , long , int *);
void
Y___ffmvec(int n)
{
  if (n!=3) YError("__ffmvec takes exactly 3 arguments");

  int status=0;
  PushCfitsioStatus(ffmvec(ygeta_fitsfile(2), yarg_si(1), yarg_sl(0), 
			    &status));
}

extern BuiltIn Y___ffdcol;

// extern int ffdcol(long , int , int *);
void
Y___ffdcol(int n)
{
  if (n!=2) YError("__ffdcol takes exactly 2 arguments");
  long pos = yget_ref(n-1);

  int status=0;
  CheckCfitsioStatus(ffdcol(ygeta_fitsfile(1), yarg_si(0), &status));

  ypush_global(pos);
}
