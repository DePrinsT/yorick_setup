/*******************************************************************************
* LAOG project - Yorick Contribution package
*
* "@(#) $Id: imgFitsUtils.i,v 1.6 2010-11-27 03:54:02 lebouquj Exp $"
*
* History
* -------
* $Log: not supported by cvs2svn $
* Revision 1.5  2010/08/27 06:36:02  lebouquj
* Fix a bug in oiFitsGrowOiArrays.
*
* Revision 1.4  2010/07/21 13:36:52  lebouquj
* Improve support for LOGICALs.
*
* Revision 1.3  2010/06/30 09:40:07  lebouquj
* Add the frameCnt array.
*
* Revision 1.2  2010/06/10 12:27:51  lebouquj
* Add a dimension in an array in imgFitsUtils so that it deal with the units
* of the FITS keyword parameters.
*
* Revision 1.1  2010/05/21 10:32:27  lebouquj
* Created.
*
*
*
*/

func imgFitsUtils(void)
/* DOCUMENT imgFitsUtils

   DESCRIPTION
   Tools to manipulate interferometric RAW data with ESO standart.

   USER-ORIENTED FUNCTIONS
   - imgFitsReadImgFiles
   - imgFitsReadImgData
   - imgFitsReadImgLog

   PARAMETERS

   EXAMPLES

   REQUIRE
   - cfitsioPlugin.i
   - oiFitsUtils.i
   - yoco.i

   VERSION
     $Revision: 1.6 $
   
   AUTHORS                                  
   - Jean-Baptiste LeBouquin (jblebou@eso.org)

   SEE ALSO
 */
{
    local version;
    
    version = strpart(strtok("$Revision: 1.6 $",":")(2),2:-2);
    if (am_subroutine())
    {
        write, format="package version: %s\n", version;
        help, imgFitsUtils;
    }
    
    return version;
}

require,"oiFitsUtils.i";
yocoLogInfo, "imgFitsUtils package loaded";


/* ------------------------------------------------------------------------ */

/* struct_imgData */
struct struct_imgDataHdr {
  long logId;
  long maxTel;
  long nRegion;
  // string insName;
  // string arrName;
};

struct struct_imgData {
  struct_imgDataHdr hdr;
  string instrument;
  double mjdObs;
  string dateObs;
  long   maxstep;
  long   nregion;
  long   *frameCnt;
  double *time;
  double *regdata;
  double *exptime;
  double *opd;
  double *localopd;
  long   *steppingPhase;
  string *tartype;
  long   *target;
};

/* ------------------------------------------------------------------------ */

func imgFitsReadImgLog(file)
/* DOCUMENT imgFitsReadImgLog(file)

   DESCRIPTION
   Read the header of the file and put it in a structure
   struct_imgLog. If this structure is not yet defined, it is
   defined on the fly based on the header keyword.

   PARAMETERS
   - file: FITS file or FITS filename
 */
{
  yocoLogTrace,"imgFitsReadImgLog()";
  extern struct_imgLog, structdic_imgLog;
  local data, titles, filetmp, fh;

  /* open the file */
  fh = ( structof(file)==string ? cfitsio_open(file) : file );

  /* test if already installed */
  if ( is_struct(struct_imgLog) ) {
    imgLog  = oiFitsLoadOiHdr(fh, struct_imgLog, structdic_imgLog);
    return  imgLog;
  }

  /* otherwise install it */
  structdic_imgLog = [];

  /* default parameters */
  grow, structdic_imgLog, [["long","logId","-",""]];
  
  /* read the header */
  data = cfitsio_get(fh,"*",,titles,point=1);
  
  /* loop on parameters */
  for (i=1;i<=numberof(data);i++) {
    
    /* prepare */
    type     = typeof(*data(i));
    header   = titles(i);
    variable = yocoStrReplace(header,["-","HIERARCH","ESO","LAOG"],[" ","","",""]);

    /* some test */
    if (variable == "COMMENT") continue;
    if (variable == "HISTORY") continue;

    /* prepare format */
    variable = strcase(0, strtrim(variable));
    fd = strfind(" ",variable,n=10);
    variable =  streplace(variable, fd+1,strcase(1, strpart(variable,fd+1)));
    variable =  streplace(variable, fd, "");
        
    /* log */
    grow, structdic_imgLog, [[type, variable, header, ""]];
  }
  
  /* default file name */
  yocoLogTest,"Install the pseudo-dynamique structure";
  filetmp = "~/.oiFitsStructTmp.i";
  /* write the tmp file and include it */
  f=open(filetmp,"w");
  write,f,"struct struct_imgLog{\n";
  write,f,format="%-10s %s;\n", structdic_imgLog(1,), structdic_imgLog(2,);
  write,f,"}\n";
  close,f;
  include,filetmp,1;

  /* keep only the last columns */
  structdic_imgLog = structdic_imgLog(2:4,);
  
  /* read the log */
  imgLog  = oiFitsLoadOiHdr(fh, struct_imgLog, structdic_imgLog);

  /* end function */
  yocoLogTrace,"imgFitsReadImgLog done";
  return  imgLog;
}

/* ------------------------------------------------------------------------ */

func imgFitsReadImgData(file,&imgData,force_array=)
/* DOCUMENT imgFitsReadImgData(file,&imgData,force_array=)

   DESCRIPTION
   Read the HDU IMAGING_DATA and put it in the structure
   struct_imgData. Data are stored as pointer.
   
   PARAMETERS
   - file: FITS file or FITS filename
   - foce_array=1: data are rearranged
 */
{
  yocoLogTrace,"imgFitsReadImgData()";
  local fh, imgData, id;
  imgData = struct_imgData();
  
  /* Open the file */
  fh = ( structof(file)==string ? cfitsio_open(file) : file );
  cfitsio_goto_hdu,fh,"IMAGING_DATA";

  /* Read the header */
  imgData.hdr = oiFitsLoadOiHdr(fh,  struct_imgDataHdr());
  
  /* Read the bintable */
  bintable = cfitsio_read_bintable(fh,bintitles);
  
  imgData.mjdObs         = double(cfitsio_get(fh,"MJD-OBS"));
  imgData.dateObs        = string(cfitsio_get(fh,"DATE-OBS"));
  imgData.maxstep        = long(cfitsio_get(fh,"MAXSTEP"));
  imgData.nregion        = int(cfitsio_get(fh,"NREGION"));
  imgData.steppingPhase  = pointer(bintable(where(bintitles=="STEPPING_PHASE")));
  imgData.localopd       = pointer(bintable(where(bintitles=="LOCALOPD")));
  imgData.opd            = pointer(bintable(where(bintitles=="OPD")));
  imgData.exptime        = pointer(bintable(where(bintitles=="EXPTIME")));
  imgData.time           = pointer(bintable(where(bintitles=="TIME")));
  imgData.tartype        = pointer(bintable(where(bintitles=="TARTYPE")));
  imgData.target         = pointer(bintable(where(bintitles=="TARGET")));
  imgData.regdata        = pointer(imgDecodeData(bintable,bintitles,imgData.nregion,force_array=force_array));

  if (is_array( (id=where(bintitles=="FRAMECNT")) )) {
    imgData.frameCnt = pointer(bintable(id));
  }

  yocoLogTrace,"imgFitsReadImgData done";
  return imgData; 
}

/* ------------------------------------------------------------------------ */

func imgDecodeData(bintable,bintitles,nregion,force_array=)
{
  local data; data = [];
  if(is_void(force_array)) force_array=1;
  
  if(!force_array) {
    data = pointer(bintable(where(bintitles=="DATA1")));
    for(i=2;i<=nregion;i++)
      grow,data, pointer(bintable(where(bintitles==("DATA"+pr1(i)))));
    return &data;
  }
  else {
    id=where(bintitles=="DATA1");
    data = *bintable(id)(1);
    data = array(data,nregion);
    for(i=2;i<=nregion;i++)
      data(..,i) = *bintable(where(bintitles==("DATA"+pr1(i))))(1);
    return &data;
  }
}

/* ------------------------------------------------------------------------ */

func imgFitsReadImgFiles(files, &imgLog, &imgData, append=, verbose=, force_array=)
/* DOCUMENT imgFitsReadImgFiles(files, &imgLog, &imgData, append=, force_array=)

   DESCRIPTION
   Read the raw data FITS file in standar ESO format.
   files can be a list of files.

   PARAMETERS
   - files: list of filename.

   EXAMPLES
   > f = "/Users/jlebouqu/Datas/ImgFits/VLT2-0812B-P12-1-100-2TK1steper-028_0737.fits";
   > imgFitsReadImgFiles, f, imgLog, imgData, append=0, verbose=1;
   > yocoPlotPlgMulti, imgData.regData

   SEE ALSO
 */
{
  yocoLogInfo,"imgFitsReadImgFiles()";
  local _imgData, _imgLog, n, i;

  /* if append if nil, we erase the current data */
  if (!append) {
    imgData = imgLog = [];
    addRef=0;
  } else {
    yocoLogInfo,"New data will be append to already loaded one.";
  }

  /* Loop on the files */
  n = numberof(files)
  for ( i=1 ; i<=n ; i++ ) {

    /* if verbose */
    write,format="\r read file %i over %i",i,n;

    /* read the file i */
    fh = cfitsio_open(files(i));
    _imgLog  = imgFitsReadImgLog(fh);
    _imgData = imgFitsReadImgData(fh,force_array=force_array);
    cfitsio_close, fh;

    /* ensure logId is unique and grow */
    _imgLog.logId  = ( is_array(imgLog) ? max(imgLog.logId) : 0 ) + 1;
    _imgData.hdr.logId = _imgLog.logId;
    grow, imgLog, _imgLog;
    grow, imgData, _imgData;
  }

  /* if scalar */
  if (dimsof(files)(1)==0) { imgLog = imgLog(1); imgData = imgData(1); }

  /* end functions */
  yocoLogInfo,"imgFitsReadImgFiles done";
  return 1;
}
