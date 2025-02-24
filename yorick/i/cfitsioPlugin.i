local package_cfitsioPlugin;
/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 */

func cfitsioPlugin(void)
/* DOCUMENT cfitsioPlugin(void)

   DESCRIPTION
   Plugin of cfitsio for Yorick
   This file contains high level FITS access routines based on
   the low level wrapped routines contained in cfitstioWrapper.i

   EXAMPLES
   1) READING A FILE:
   
   fh    = cfitsio_open(name,"r");              // open a existing file
   cfitsio_list, fh;                            // list all the HDU type
   cfitsio_goto_hdu,fh,3;                       // go to a HDU
   tests = cfitsio_get(fh,"TEST*",comments)     // read a key
   table = cfitsio_read_bintable(fh,titles);    // read the binary table
   cfitsio_goto_hdu,fh,"NAMEOFHDU";             // go to a HDU
   img   = cfitsio_read_image(fh);              // read the image 
   cfitsio_close,fh;                            // close the file
   
   2) CREATING A NEW FITS FILE:
   
   fh = cfitsio_open(filename,"c");             // create the file
   cfitsio_write_key, fh, "KEYNAME", keyvalue;  // add a card in the first HDU
   cfitsio_add_image, fh, data, "IMG_JB";       // add an image
   cfitsio_write_key, fh, "KEY", keyvalue2;     // add a card in this HDU
   data1 = random(100);
   data2 = swrite(format="str%i",indgen(100));
   cfitsio_add_bintable, fh, [&data1,&data2];   // aad a binary table
   cfitsio_close,fh;                            // close the file

   MOST USEFULL FUNCTIONS
   
    - cfitsio_open
    - cfitsio_close
    - cfitsio_file_name
    - cfitsio_file_mode
    - cfitsio_file_exists
    - cfitsio_url_type
    
    - cfitsio_goto_hdu
    - cfitsio_next_hdu
    - cfitsio_rewind
    - cfitsio_list
    - cfitsio_get_xtension
    - cfitsio_get_hdu_num
    - cfitsio_get_hdu_type
    - cfitsio_get_num_hdus
    
    - cfitsio_get
    - cfitsio_set
    - cfitsio_delete

    - cfitsio_add_image
    - cfitsio_write_image
    - cfitsio_read_image
    - cfitsio_read_image_subset
    - cfitsio_get_coordinate
    - cfitsio_get_img_dim
    - cfitsio_get_img_size
    - cfitsio_get_img_type
     
    - cfitsio_add_bintable
    - cfitsio_read_bintable
    - cfitsio_add_column
    - cfitsio_write_column
    - cfitsio_read_column
    - cfitsio_delete_rowlist
    - cfitsio_delete_col
    - cfitsio_get_colnum
    - cfitsio_get_colname
    - cfitsio_get_col_type


   OTHER FUNCTIONS
   
    - cfitsio_open_file
    - cfitsio_create_file
    - cfitsio_close_file
    - cfitsio_delete_file

    - cfitsio_movabs_hdu
    - cfitsio_movrel_hdu
    - cfitsio_movnam_hdu

    - cfitsio_update_key
    - cfitsio_write_key
    - cfitsio_write_comment
    - cfitsio_write_key_unit
    - cfitsio_write_history
    - cfitsio_write_date
    - cfitsio_write_tdim
    - cfitsio_find_nextkey
    - cfitsio_read_record
    - cfitsio_read_card
    - cfitsio_read_key_unit
    - cfitsio_read_key
    - cfitsio_modify_comment
    - cfitsio_modify_name
    - cfitsio_delete_key
    - cfitsio_delete_record
    
    - cfitsio_delete_rows
    - cfitsio_modify_vector_len
    - cfitsio_get_num_cols
    - cfitsio_get_num_rows
    - cfitsio_read_multicolumn
    
    - cfitsio_get_version
    - cfitsio_read_errmsg


    LOW LEVEL FUNCTIONS
    
    - cfitsio_read_tdim
    - cfitsio_get_hdrspace
    - cfitsio_create_img
    - cfitsio_write_pix
    - cfitsio_read_pix
    - cfitsio_read_subset
    - cfitsio_read_img
    - cfitsio_get_img_param
    - cfitsio_get_img_type
    - cfitsio_create_tbl
    - cfitsio_write_col
    - cfitsio_read_col 
    - cfitsio_insert_rows
    - cfitsio_insert_col
    - cfitsio_insert_cols
    
    - cfitsio_get_naxis
    - cfitsio_get_dims
    
   VERSION
   1.6
   
   REQUIRE
   Libraries -lcfitsio at compilation time but not at run time.

   CAUTIONS

   AUTHORS
   - Jean-Baptiste LeBouquin
*/
{
    version = strpart(strtok("$Revision: 1.6 $",":")(2),2:-2);
    if (am_subroutine())
    {
        write, format="package version: %s\n", version;
        help, cfitsioPlugin;
    }   
    return version;
} 

#include "cfitsioPluginWrapper.i"

////////////////////////////////////////////////////////////////////////////
//                    
//         Low level routines, just to protect wrapper functions
//                    
///////////////////////////////////////////////////////////////////////////

/*----------------  FITS file URL parsing routines -------------*/

/*----------------  FITS file I/O routines -------------*/

func cfitsio_open_file(filename,iomode)
/* DOCUMENT cfitsio_open_file(filename,iomode)

   Open an existing FITS data file.

   The IOMODE parameter determine the read/write access allowed in the
   file and can have values of READONLY (0) or READWRITE (1).
   The filename parameter gives the name of the file to be opened
   followed by an optional argument giving some information
   about what to to after opening. See a CFITSIO documentation
   to know all what is possible to do.
   
   EXAMPLES:
   cfitsio_open_file("test.fits[events][pha>50], READWRITE);

*/
{
    /* default */
    if ( is_void(iomode) ) iomode = READONLY;
    
    /* FIXME: test size of filename for compressed files, unkown issue */
    if( (strpart(filename,-2:)==".gz" || strpart(filename,-1:)==".Z") &&
        strlen(filename)>125 )
    {
        error,"Unable to open compressed files with full pathname longer than 125chars.";
    }
    
    return __ffopen( filename, iomode );
}

/*---------------- utility routines -------------*/

/*----------------- write single keywords --------------*/

func cfitsio_write_key(&fh,keyname,keyvalue,comment)
/* DOCUMENT cfitsio_write_key(&fh,keyname,keyvalue,comment)

   Write a keyword of the appropriate data type into the CHU.
   The first routine simply appends a new keyword whereas
   cfitsio_update_key will update the value and comment fields
   of the keyword if it already exists, otherwise it appends
   a new keyword.
 */
{
    /* default will be 0x0 that is no comment */
    comment = string(comment);
    
    /* parameters */
    datatype = cfitsio_TTYPE_of(keyvalue);
    
    /* convert string to char array, I don't know why ! */
    if(datatype==TSTRING)
    {
        keyvalue = cfitsio_strchr(keyvalue);
    }

    return __ffpky( fh, datatype, keyname, &keyvalue, comment );
}

func cfitsio_write_tdim(&fh, colnum, tdim)
/* DOCUMENT cfitsio_write_tdim(&fh, colnum, tdim)

   Write a TDIMn keyword whose value has the form ’(l,m,n...)’
   where l, m, n... are the dimensions of a multidimension array
   column in a binary table.
 */
{
  return __ffptdm( fh, colnum, int(tdim(1)), long(tdim(2:0)) );
}

/*----------------- write array of keywords --------------*/

/*------------------ get header information --------------*/

func cfitsio_get_hdrspace(&fh,&morekeys)
/* DOCUMENT cfitsio_get_hdrspace(fh,&morekeys)

   Return the number of existing keyword KEYSEXIST (not counting the END)
   and the amound of space currently available for more keys MOREKEYS.
   It return morekeys=-1 if the header
   has not yet been closed.
   
   cfitsioPlugin will add space if required when writing new keywords.
   So in practice there is no limit to the number of keyword.
*/
{
    /* memory allocation */
    morekeys  = cfitsio_typeinit_array(TINT);
    
    return __ffghsp( fh, morekeys );
}

/*------------------ move position in header -------------*/


/*------------------ read single keywords -----------------*/

func cfitsio_find_nextkey(&fh,inclist,exclist)
/* DOCUMENT card = cfitsio_find_nextkey(&fh,inclist,exclist);

   DESCRIPTION
   Return the next keyword whose name matches one of the strings in
   ’inclist’ but does not match any of the strings in ’exclist’.
   The strings in inclist and exclist may contain wild card characters
   (*, ?, and #) as described at the beginning of this section. This
   routine searches from the current header position to the end of the
   header, only, and does not continue the search from the top of the
   header back to the original position. The current header position may
   be reset with the ffgrec routine.
 */
{
    /* default  */
    if(is_void(exclist)) exclist = [""];

    /* check */
    if(is_void(inclist)) error,"inclist should be specified";
    
    /* add a dimension if required */
    if(dimsof(inclist)(1) == 0) inclist = [inclist];
    if(dimsof(exclist)(1) == 0) exclist = [exclist];
    
    /* get the dimensions */
    ninc = int(numberof(inclist));
    nexc = int(numberof(exclist));
    
    return __ffgnxk(fh, inclist, ninc, exclist, nexc);
}

func cfitsio_read_key(&fh,keytype,keyname,&comment)
/* DOCUMENT cfitsio_read_key(&fh,keytype,keyname,&comment)

   Return the specified keyword. In the first routine, the datatype
   parameter specifies the desired returned data type of the keyword
   value and can have one of the following symbolic constant values:
   TSTRING, TLOGICAL (== int), TBYTE, TSHORT, TUSHORT, TINT, TUINT,
   TLONG, TULONG, TLONGLONG, TFLOAT, TDOUBLE, TDBLCOMPLEX.
 */
{
    /* memory allocation */
    comment = cfitsio_typeinit_array(TSTRING,,FLEN_COMMENT);
    value   = cfitsio_typeinit_array(keytype,,FLEN_VALUE);
    
    /* convert string to char array, I don't know why ! */
    if(keytype==TSTRING)
    {
        value = cfitsio_strchr(value);
    }
    
    __ffgky, fh, keytype, keyname, &value, comment;
    
    /* back conversion for string */
    if(keytype==TSTRING)
    {
        value = cfitsio_chrstr(value);
    }
    
    return value;
}

func cfitsio_read_tdim(&fh, colnum)
/* DOCUMENT cfitsio_read_tdim(fh, colnum)

   Get the dimsof DAXES of the column COLNUM in a binary table.
   
   DAXES replace the parameters NAXIS and NAXES of the equivalent
   C-function "ffgtdm".
   Warning DAXES is also an array of the form :
   [naxis, naxes(1), naxes(2), ... naxes(naxis)]
   So DAXES is a standart yorick dimension arrray (return by dimsof). 
*/
{
    /* default */
    if(is_void(maxdim)) maxdim = 100;
    
    /* memory allocation */
    naxes  = array(cfitsio_TTYPE_type(TLONG),maxdim);
    naxis  = cfitsio_typeinit_array(TINT);
    
    __ffgtdm, fh, colnum, maxdim, naxis, naxes;
    
    /* Construct the Yorick-compliant dimension array */
    daxes = grow(naxis,naxes(1:naxis));
    
    /* Trick to deal with void column, daxes=0 */
    if(naxis==1 && naxes(1)==0)
    {
        daxes = 0;
    }
    
    return daxes;
}

/*------------------ read array of keywords -----------------*/

/*----------------- read required header keywords --------------*/

/*--------------------- update keywords ---------------*/

func cfitsio_update_key(&fh,keyname,keyvalue,comment)
/* DOCUMENT cfitsio_update_key(&fh,keyname,keyvalue,comment)

   Write a keyword of the appropriate data type into the CHU.
   The routine will update the value and comment fields
   of the keyword if it already exists, otherwise it appends
   a new keyword.
*/
{
    /* default will be 0x0 that is no comment */
    comment = string(comment);

    /* check */
    if(is_void(keyname) || is_void(keyvalue))
    {
        error,"argument empty";
    }

    /* format */
    datatype = cfitsio_TTYPE_of(keyvalue);

    /* convert string to char array, I don't know why ! */
    if(datatype==TSTRING)
    {
        keyvalue = cfitsio_strchr(keyvalue);
    }
    
    __ffuky, fh, datatype, keyname, &keyvalue, comment;
    
    return fh;
}

/*--------------------- modify keywords ---------------*/

/*--------------------- insert keywords ---------------*/

/*--------------------- delete keywords ---------------*/

/*--------------------- get HDU information -------------*/

/*--------------------- HDU operations -------------*/

func cfitsio_create_img(&fh,bitpix,daxes)
/* DOCUMENT cfitsio_create_img(fh,bitpix,daxes)
       
   Create an new HDU (IMAGE_HDU type) with the type BITPIX and the
   dimension DAXES.
   Warning DAXES is array of the form :
   [naxis, naxes(1), naxes(2), ... naxes(naxis)]
   So DAXES is a standart yorick dimension arrray (return by dimsof).
   
   EXAMPLES:
   cfitsio_create_img, fh, cfitsio_bitpix_of(data), dimsof(data);
*/
{
  return __ffcrim( fh, bitpix, int(daxes(1)), long(daxes(2:0)) );
}

func cfitsio_create_tbl(&fh,tbltype,naxis2,ttype,tform,unit,extname)
/* DOCUMENT cfitsio_create_tbl(fh,tbltype,naxis2,ttype,tform,unit,extname)
       
   Create a new ASCII or binary table extension. If the FITS FH file is
   currently empty then a dummy primary array will be created before
   appending the table extension to it.
   The TBLTYPE defines the type of table (BINARY_TBL or ASCII_TBL).
   The NAXIS2 parameter gives the initial number of row, and should normaly
   be set to 0 (default). cfitsioPlugin will automatically increase the size
   of the table as rows are written. The TTYPE gives the name of
   each field (column) in the table. TFORM gives the format of each field
   (e.g "1A", "5W"... see CFITSIO documentation for a complete list).
   The TUNIT (optional) gives the unit of each field. The extname gives the
   HDU name of this extension.
   
   WARNING : TTYPE (optional), TFORM (need), UNIT (optional) should have the
   same number of element (the number of field).
*/
{
    /* memory allocation */
    tfields  = numberof(tform);
    
    /* default */
    if(is_void(naxis2))
    {
        naxis2  = 0;
    }
    if(is_void(unit))
    {
        unit    = array("",tfields);
    }
    if(is_void(extname))
    {
        extname = "FYO_TBL";
    }
    if(is_void(ttype))
    {
        ttype   = "data"+swrite(format="%i",indgen(tfields));
    }
    
    /* check */
    if(numberof(tform) < tfields)
    {
        error,"not enought tform";
    }
    if(numberof(ttype) < tfields)
    {
        error,"not enought ttype";
    }
    if(numberof(unit)  < tfields)
    {
        error,"not enought tunit";
    }
    
    return __ffcrtb( fh, int(tbltype), long(naxis2), int(tfields), ttype, tform, unit, extname );
}

/*--------------------- define scaling or null values -------------*/

/*--------------------- get column information -------------*/

func cfitsio_get_colnum(&fh, casesen, templt)
/* DOCUMENT cfitsio_get_colnum(fh, casesen, templt)

   Get the table column number (or array of number) of the column name
   matches the input scalar string TEMPLT.
   If CASESSEN = CASEINSEN the the column name match will be case-sensitive.
*/
{
    /* memory allocation */
    local colnum0;
    colnum  = [];
    
    /* FIXME: rewrite this code (!) */
    do
    {
        colnum0 = cfitsio_typeinit_array(TINT);
        status = __ffgcno( fh, int(casesen), string(templt), colnum0);
        
        if(status && status!=COL_NOT_FOUND && status!=COL_NOT_UNIQUE)
        {
            error, cfitsio_get_errstatus(status);
        }
        grow,colnum,colnum0;
    }
    while(status!=COL_NOT_FOUND && status!=0);

    /* format colnum */
    if(numberof(colnum)==1)
    {
        colnum = colnum(1);
    }
    else
    {
        colnum  = colnum(:-1);
    }
    
    return colnum;
}

func cfitsio_get_colname(&fh, casesen, templt)
/* DOCUMENT cfitsio_get_colname(fh, casesen, templt)

   Get the table column number (or array of number)
   matches the input scalar string TEMPLT.
   If CASESSEN = CASEINSEN the the column
   name match will be case-sensitive.
   
   The function return COLNAME.
*/
{
    /* memory allocation */
    local colnum0,colname0;
    colname  = [];
    colnum   = [];
    
    /* FIXME: rewrite this code (!) */
    do
    {
        /* suppose colname smaller than 200 char */
        colname0 = cfitsio_typeinit_array(TSTRING,,200);
        colnum0  = cfitsio_typeinit_array(TINT);
        __ffgcnn, fh, casesen, templt, colname0, colnum0;
        if(status && status!=COL_NOT_FOUND && status!=COL_NOT_UNIQUE)
        {
            error,cfitsio_get_errstatus(status);
        }
        grow,colnum, colnum0;
        grow,colname,colname0;
    }
    while(status!=COL_NOT_FOUND && status!=0);

    /* reformat */
    if(numberof(colnum)==1)
    {
        colnum = colnum(1);
    }
    else
    {
        colnum  = colnum(:-1);
    }
    if(numberof(colname)==1)
    {
        colname = colname(1);
    }
    else
    {
        colname = colname(:-1);
    }
    
    return colname;
}

func cfitsio_get_col_type(&fh,colnum,&repeat,&width)
/* DOCUMENT cfitsio_get_col_type(fh,colnum,&repeat,&width)

   Get the datatype, vector repeat value and the width in bytes of
   the column COLNUM in an ASCII or a binary table.
*/
{
    /* memory allocation */
    coltype  = cfitsio_typeinit_array(TINT);
    repeat   = cfitsio_typeinit_array(TLONG);
    width    = cfitsio_typeinit_array(TLONG);

    __ffgtcl, fh, colnum, coltype, repeat, width;
    
    return coltype;
}

/*--------------------- read primary array or image elements -------------*/

func cfitsio_read_pix(&fh, datatype, daxes, fpixel, &nulval, &arrayc, &anynul)
/* DOCUMENT cfitsio_read_pix(&fh, datatype, daxes, fpixel, &nulval,
                             > &arrayc, &anynul)
   
   Read pixels from the FITS data array. ’fpixel’ is the starting pixel
   location and is an array of length NAXIS such that fpixel[0] is in the
   range 1 to NAXIS1, fpixel[1] is in the range 1 to NAXIS2, etc. The
   nelements parameter specifies the number of pixels to read. If fpixel
   is set to the first pixel, and nelements is set equal to the NAXIS1 value,
   then this routine would read the first row of the image. Alternatively,
   if nelements is set equal to NAXIS1 * NAXIS2 then it would read an entire
   2D image, or the first plane of a 3-D datacube.
   
   The routine will return any undefined pixels in the FITS array equal
   to the value of nullval.

   If FPIXEL is undefined then the whole image is read. If NUVALL is undefined
   then the default "0" value for this datatype is used.

   datatype and nuval are optional. Default is to use the type defined by
   the 'bitpix' of the image.
   
   The following functions are higher level routines.

   SEE ALSO: cfitsio_read_image, cfitsio_add_image,
             cfitsio_read_image_subset

             
   FIXME: Checl how the TLOGICAL are dealed with (actually they are read
   as TLOGICAL inside a memory defined as yorick INT).
*/
{
    /* check and eventually define the nulval value */
    if(is_void(datatype))
    {
        bitpix   = cfitsio_get_img_type(fh);
        datatype = cfitsio_bitpix_TTYPE(bitpix);
    }
    if(is_void(nulval))
    {
        nulval = cfitsio_typeinit_array(datatype);
    }
    if(structof(nulval) != cfitsio_TTYPE_type(datatype))
    {
        error,"not conformable type for nulval";
    }
    
    /* eventually define the fpixel array */
    if(is_void(fpixel))
    {
        /* if daxes is void, return without reading */
        if(dimsof(daxes)(1)==0 && daxes==0)
        {
            return [];
        }
        /* else defined fpixel as [1,1,1,..] */
        else if(daxes(1)==1)
        {
            fpixel = [1];
        }
        else
        {
            fpixel  = daxes(2:0)*0 + 1;
        }
    }
    
    /* memory allocation */
    anynul  = cfitsio_typeinit_array(TINT);
    arrayc = array(cfitsio_TTYPE_type(datatype), daxes); 
    nelem  = numberof(arrayc);
    
    __ffgpxv, fh, datatype, fpixel, nelem, &nulval, &arrayc, anynul;
    
    return arrayc;
}

func cfitsio_read_img(fh, datatype, felem, nelem, nulval, &arrayc, &anynull)
/* DOCUMENT cfitsio_read_img(fh, datatype, felem, nelem, nulval, &arrayc, &anynull)

   DESCRIPTION

   datatype and nuval are optional. Default is to use the type defined by
   the 'bitpix' of the image.
   
   The following functions are higher level routines.

   SEE ALSO: cfitsio_read_image, cfitsio_add_image,
             cfitsio_read_image_subset

             
   FIXME: Checl how the TLOGICAL are dealed with (actually they are read
          as TLOGICAL inside a memory defined as yorick INT).
 */
{
    /* check and eventually define the nulval value */
    if(is_void(datatype))
    {
        bitpix   = cfitsio_get_img_type(fh);
        datatype = cfitsio_bitpix_TTYPE(bitpix);
    }
    if(is_void(nulval))
    {
        nulval = cfitsio_typeinit_array(datatype);
    }
    if(structof(nulval) != cfitsio_TTYPE_type(datatype))
    {
        error,"not conformable type for nulval";
    }

    /* memory allocation */
    anynul  = cfitsio_typeinit_array(TINT);
    arrayc = array(cfitsio_TTYPE_type(datatype), nelem);

    __ffgpv, fh, datatype, felem, nelem, &nulval, &arrayc, anynul;
    
    return arrayc;
}

func cfitsio_read_subset(&fh, datatype, daxes, fpixel, lpixel, inc, nulval, \
                      &arrayc, &anynul)
/* DOCUMENT cfitsio_read_subset(&fh, datatype, daxes, fpixel, lpixel, inc, \ 
   nulval, &arrayc, &anynul)
   
   Read a rectnagular subimage (or the whole image) from the FITS data array.
   The FPIXEL and LPIXEL arrays give the coordinate of the first (lower
   left corner) and the last (upper right corner) pixels to be read. The INC
   array give the increment (stepin pixel) in each direction.
   Undefined FITS array elements will be returned with a value = nulval.
   The DAXES argument dhould be the dimension of the whole FITS image.

   datatype and nuval are optional. Default is to use the type defined by
   the 'bitpix' of the image.
   
   The following functions are higher level routines.
   
   SEE ALSO: cfitsio_read_image, cfitsio_add_image,
             cfitsio_read_image_subset

             
   FIXME: Checl how the TLOGICAL are dealed with (actually they are read
   as TLOGICAL inside a memory defined as yorick INT).
*/
{
    /* default  */
    if(is_void(datatype))
    {
        bitpix   = cfitsio_get_img_type(fh);
        datatype = cfitsio_bitpix_TTYPE(bitpix);
    }
    if(is_void(nulval))
    {
        nulval  = cfitsio_typeinit_array(datatype);
    }
    if(is_void(fpixel))
    {
        if(daxes(1)==1)
        {
            fpixel = [1];
        }
        else
        {
            fpixel  = daxes(2:0)*0+1;
        }
    }
    if(is_void(lpixel))
    {
        if(daxes(1)==1)
        {
            lpixel = [1];
        }
        else
        {
            lpixel  = daxes(2:0);
        }
    }
    if(is_void(inc))
    {
        inc = long(lpixel*0+1);
    }
    else
    {
        inc = long(inc);
    }
    
    /* check */
    if(anyof(dimsof(fpixel)!=dimsof(lpixel)))
    {
        error,"not conformable fpixel / lpixel";
    }
    if(anyof(fpixel>lpixel))
    {
        error,"not conformable fpixel / lpixel";
    }
    if(anyof(lpixel>daxes(2:0)))
    {
        error,"not conformable lpixel / daxes :\n\timages axis="+pr1(daxes(2:0));
    }
    if(structof(nulval) != cfitsio_TTYPE_type(datatype))
    {
        error,"not conformable type for nulval";
    }
    
    /* memory allocation */
    anynul     = cfitsio_typeinit_array(TINT);
    daxes(2:0) = long(ceil(double(lpixel - fpixel +1) / inc));
    arrayc     = array(cfitsio_TTYPE_type(datatype), daxes);
    
    __ffgsv, fh, int(datatype), long(fpixel), long(lpixel), long(inc), &nulval, &arrayc, anynul;
    
    return arrayc;
}

/*--------------------- read column elements -------------*/

func cfitsio_read_col(&fh, coltype, colnum, tdim, frow, nrows, nulval, &anynul)
/* DOCUMENT cfitsio_read_col(&fh, coltype, colnum, tdim, frow, nrows,
                             nulval, > &anynul)

   Read elements from an ASCII or binary table column (in the CDU).
   These routines return the values of the table column array elements.
   Undefined array elements will be returned with a value = nulval.
   
   The following functions are higher level and should be
   prefered to this low-level wrapper:
   
   SEE ALSO cfitsio_add_bintable, cfitsio_read_column,
            cfitsio_read_multicolumn,
            cfitsio_read_bintable,
            cfitsio_delete_rowlist
 */
{
    /* FIXME: simplify this code */
  
    /* memory allocation */
    local nelemen;
    anynul  = cfitsio_typeinit_array(TINT);
    
    /* check consistency between nulval and coltype */
    if(structof(nulval) != cfitsio_TTYPE_type(coltype))
    {
        error,"not conformable type";
    }

    /* Check the number of row to read */
    if ( frow+nrows-1 > cfitsio_get_num_rows(fh) || frow < 1 )
    {
        error,"Invalid number of rows to be read.";
    }
    
    /* trick deal with void column */
    if(dimsof(tdim)(1)==0 && tdim(1)==0)
    {
        arrayc = array(anynul,nrows);
        return arrayc;
    }

    /* TCOMPLEX should be transformed into TDBLCOMPLEX to match
       the type of yorick */
    if(coltype==TCOMPLEX)
    {
        coltype = TDBLCOMPLEX;
    }
        
    /* TLOGICAL are read as string to avoid memory
       allocation mismatch */
    if(coltype==TLOGICAL)
    {
        coltype = TSTRING;
        arrayc  = array(" ",tdim(2),nrows);
        nelemen = tdim(2)*nrows;
        logik = 1;
    }
    
    /* memory allocation depends on the type:
       If STRING */
    if(cfitsio_TTYPE_type(coltype)==string)
    {
        /* convert char into string */
        if(structof(nulval) == char)
        {
            nulval=string(&nulval)+"";
        }
        
        /* avoid null string */
        if(nulval==string(0))
        {
            nulval="";
        }
        
        if(logik!=1)
        {
            arrayc  = cfitsio_typeinit_array(TSTRING,nrows,tdim);
            nelemen = nrows;
        }
    }
    /* if not a STRING */
    else
    {
        arrayc  = array(cfitsio_typeinit_array(coltype,tdim),nrows);
        nelemen = numberof(arrayc);
    }

    __ffgcv, fh, coltype, colnum, long(frow), long(1), long(nelemen),      \
      &nulval, &arrayc, anynul;
    
    return arrayc;
}

/*------------ write primary array or image elements -------------*/

func cfitsio_write_pix(&fh, fpixels, nelements, arrayc)
/* DOCUMENT cfitsio_write_pix(&fh, fpixels, nelements, arrayc)

   Write pixels into the FITS data array. ’fpixel’ is an array of length
   NAXIS which gives the coordinate of the starting pixel to be written
   to, such that fpixel[0] is in the range 1 to NAXIS1, fpixel[1] is in
   the range 1 to NAXIS2, etc (doing data type conversion if
   necessary).

   The following functions are higher level and should be
   prefered to this low-level wrapper:
   
   SEE ALSO: cfitsio_add_image, cfitsio_read_image
 */
{
    /* memory allocation */
    datatype  = cfitsio_TTYPE_of(arrayc);
    
    return __ffppx( fh, int(datatype), fpixels, nelements, &arrayc );
}

/*--------------------- iterator functions -------------*/

/*--------------------- write column elements -------------*/

func cfitsio_write_col(&fh,colnum,arrayc)
/* DOCUMENT cfitsio_write_col(&fh,colnum,arrayc)

   Write elements into an ASCII or binary table column (in the CDU).
   
   The following functions are higher level and should be
   prefered to this low-level wrapper:
   
   SEE ALSO cfitsio_add_bintable, cfitsio_read_column,
            cfitsio_read_multicolumn,
            cfitsio_read_bintable,
            cfitsio_delete_rowlist
 */
{
    /* memory allocation */
    datatype  = cfitsio_TTYPE_of(arrayc);
    nelements = long(numberof(arrayc));
    
    return __ffpcl( fh, datatype, colnum, long(1), long(1), nelements, &arrayc );
}

func cfitsio_insert_cols(&fh,colnum,ttype,tform)
/* DOCUMENT cfitsio_insert_col(&fh,colnum,ttype,tform)
            cfitsio_insert_cols(&fh,colnum,ttype,tform)
            cfitsio_delete_col(&fh,colnum)

   Insert or delete column(s) in an ASCII or binary table.
   When inserting, COLNUM specifies the column number that the
   (first) new column should occupy in the table. NCOLS
   specifies how many columns are to be inserted. Any existing
   columns from this position and higher are shifted over to
   allow room for the new column(s).
 */
{
    /* parameters */
    ncols  = numberof(tform); 
 
    return __fficls( fh, colnum, ncols, ttype, tform );
}

/*--------------------- WCS Utilities ------------------*/

func fits_read_tbl_coord(&fh,&xrefval,&yrefval,&xrefpix,&yrefpix,&xsinc,&ysinc,&rot,&coordtype)
/* DOCUMENT fits_read_tbl_coord(&fh, > &xrefval, &yrefval, &xrefpix, &yrefpix,
                                       &xsinc, &ysinc, &rot, &coordtype)
 */
{
  /* memory allocation */
  xrefval = yrefval = xrefpix = yrefpix = cfitsio_typeinit_array(TDOUBLE);
  xsinc = ysinc = rot = cfitsio_typeinit_array(TDOUBLE);
  coordtype = cfitsio_typeinit_array(TSTRING);
  
  __ffgics, fh, xrefval, yrefval, xrefpix, yrefpix, xinc, yinc, rot, coordtype;

  return fh;
}

func fits_pix_to_world(xpix,ypix,xrefval,yrefval,xrefpix,yrefpix,xsinc,ysinc,rot,coordtype,&xpos,&ypos)
/* DOCUMENT fits_pix_to_world( xpix, ypix, xrefval, yrefval, xrefpix, yrefpix, xsinc,
                               ysinc, rot, coordtype, > &xpos, &ypos)

   DESCRIPTION

   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  /* memory allocation */
  xpos = ypos = cfitsio_typeinit_array(TDOUBLE);
  
  __ffgics, xpix, ypix, xrefval, yrefval, xrefpix, yrefpix, xinc, yinc, rot, coordtype, xpos, ypos;
  
  return fh;
}

/*--------------------- lexical parsing routines ------------------*/

/*--------------------- grouping routines ------------------*/

/*--------------------- group template parser routines ------------------*/

/*--------------------- image compression routines ------------------*/

////////////////////////////////////////////////////////////////////////////
//                    
//                         Pure Yorick functions
//                    
///////////////////////////////////////////////////////////////////////////

/* --------------------------- init variables ------------------------ */

local cfitsio_typeinit_string,  cfitsio_typeinit_array;
/* DOCUMENT cfitsio_typeinit_array(type, dim, nchar)   
   cfitsio_typeinit_fitsfile()
   
   Fonctions to define a variable before puting it as an argument
   of a fitsio c-wrapper function. TYPE could have the values:
   TSTRING, TDOUBLE, TINT... DIM is a dimension array, and could be
   void to define a scalar (equivalent to DIM=[0]). NCHAR define the
   lenght of the string when TYPE=TSTRING. It is mandatory to specify
   a value large enought to avoid memory pb in the C-code.
   
   SEE ALSO:
*/


func cfitsio_typeinit_string(nchar)
{
    if(is_void(nchar))
    {
        nchar=[0];
    }
    return string(&array(' ',nchar));
}
func cfitsio_typeinit_array(&type,dim,nchar)
{
    if(is_void(dim)) dim=[0];
    if(type==TSTRING) return array(cfitsio_typeinit_string(nchar),dim);
    else              return array(cfitsio_TTYPE_type(type),dim);
}

/* --------------------------- test type ------------------------ */

func cfitsio_is_fitsfile(x)
/* DOCUMENT cfitsio_is_fitsfile(x)

   Returns true if X is a fits file.
   
   SEE ALSO:
*/
{
    if(typeof(x) == "object_cfitsio")
        return 1;
    else
        return 0;
}

func cfitsio_is_scalar(x)
/* DOCUMENT cfitsio_is_scalar(x)

   Returns true if X is a scalar.
   
   SEE ALSO: cfitsio_is_integer_scalar, cfitsio_is_real_scalar,
   cfitsio_is_string_scalar. */
{
    return (is_array(x) && ! dimsof(x)(1));
}

func cfitsio_is_integer(x)
    /* DOCUMENT cfitsio_is_integer(x)
       Returns true if array X is of integer type.
       
       SEE ALSO: cfitsio_is_scalar. */
{ 
    return ((s=structof(x)) == long || s == int || s == char || s == short); 
}

func cfitsio_is_integer_scalar(x)
    /* DOCUMENT cfitsio_is_integer_scalar(x)
       Returns true if array X is a scalar of integer type.
       
       SEE ALSO: cfitsio_is_real_scalar, cfitsio_is_scalar, cfitsio_is_string_scalar. */
{
    return (((s=structof(x)) == long || s == int || s == char || s == short) &&
            ! dimsof(x)(1));
}

func cfitsio_is_real_scalar(x)
    /* DOCUMENT cfitsio_is_real_scalar(x)
       Returns true if array X if of real type (i.e. double or float).
       
       SEE ALSO: cfitsio_is_integer_scalar, cfitsio_is_scalar, cfitsio_is_string_scalar. */
{
    return (((s=structof(x)) == double || s == float) && ! dimsof(x)(1));
}

func cfitsio_is_string_scalar(x)
    /* DOCUMENT cfitsio_is_string_scalar(x)
       Returns true if array X is a scalar of string type.
       
       SEE ALSO: cfitsio_is_integer_scalar, cfitsio_is_real_scalar, cfitsio_is_scalar. */
{
    return (structof(x) == string && ! dimsof(x)(1));
}

func cfitsio_are_confomable(t1,t2)
    /* DOCUMENT cfitsio_are_conformable(t1,t2)
       Return 1 if data array t1 can be "growed" by data array t2
    */
{
    t1 = structof(t1);
    t2 = structof(t2);
    
    if(t1==int)
    {
        if(t2==int)
        {
            return 1;
        }
        else if(t2==char)
        {
            return 1;
        }
        else if(t2==short)
        {
            return 1;
        }
        
        else if(t2==[]) 
        {
            return 1;
        }
        else return 0;
    }
    if(t1==long)
    {
        if(t2==int)
        {
            return 1;
        }
        else if(t2==short)
        {
            return 1;
        }
        else if(t2==long)
        {
            return 1;
        }
        else if(t2==[])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else if(t1==float)
    {
        if(t2==int)
        {
            return 1;
        }
        else if(t2==short)
        {
            return 1;
        }
        else if(t2==long)
        {
            return 1;
        }
        else if(t2==float)
        {
            return 1;
        }
        else if(t2==[])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }    
    else if(t1==double)
    {
        if(t2==int)
        {
            return 1;
        }
        else if(t2==short)
        {
            return 1;
        }
        else if(t2==long)
        {
            return 1;
        }
        else if(t2==float)
        {
            return 1;
        }
        else if(t2==double)
        {
            return 1;
        }
        else if(t2==[])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else if(t1==char)
    {
        if(t2==char)
        {
            return 1;
        }
        else if(t2==int)
        {
            return 1;
        }
        else if(t2==[])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else if(t1==string)
    {
        if(t2==string)
        {
            return 1;
        }
        else if(t2==[])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else if(t1==pointer)
    {
        if(t2==pointer)
        {
            return 1;
        }
        else if(t2==[])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else if(t1==[])
    {
        return 1;
    }
    
    return 0;
}

/* --------------------------- test/convert type ------------------------ */

func cfitsio_check_bitpix(bitpix)
    /* DOCUMENT cfitsio_check_bitpix(bitpix)
       Test if FITS bits-per-pixel value BITPIX is valid.
       
       SEE ALSO: cfitsio_bitpix_of, cfitsio_bitpix_type, cfitsio_bitpix_info. */
    
{
    return ((bitpix>0 && (bitpix==8 || bitpix==16 || bitpix==32)) ||
            bitpix==-32 || bitpix==-64);
}

func cfitsio_bitpix_info(bitpix)
    /* DOCUMENT cfitsio_bitpix_info(bitpix)
       Return string information about FITS bits-per-pixel value.
       
       SEE ALSO: cfitsio_bitpix_of, cfitsio_bitpix_type, cfitsio_check_bitpix. */
    
{
    if (bitpix ==   8)
    {
        return "8-bit twos complement binary unsigned integer";
    }
    if (bitpix ==  16)
    {
        return "16-bit twos complement binary integer";
    }
    if (bitpix ==  32)
    {
        return "32-bit twos complement binary integer";
    }
    if (bitpix == -32)
    {
        return "IEEE single precision floating point";
    }
    if (bitpix == -64)
    {
        return "IEEE double precision floating point";
    }
    error, "invalid BITPIX value";
}

func cfitsio_bitpix_type(bitpix)
    /* DOCUMENT cfitsio_bitpix_type(bitpix)
       Returns Yorick data type given by FITS bits-per-pixel value BITPIX.
       
       SEE ALSO: cfitsio_bitpix_of, cfitsio_bitpix_info, cfitsio_check_bitpix. */
    
{
    if (bitpix ==   8)
    {
        return char;
    }
    if (bitpix ==  16)
    {
        return short;
    }
    if (bitpix ==  32)
    {
        return long;
    }
    if (bitpix == -32)
    {
        return float;
    }
    if (bitpix == -64)
    {
        return double;
    }
    error, "invalid BITPIX value";
}

func cfitsio_bitpix_of(x, native=)
    /* DOCUMENT cfitsio_bitpix_of(x)
       -or- cfitsio_bitpix_of(x, native=1)
       Return FITS bits-per-pixel value BITPIX for binary data X which can be
       an array or a data  type (structure definition).  If keyword NATIVE is
       true, the routine assumes that  binary data will be read/write to/from
       FITS file using native machine data representation.  The default is to
       conform to FITS standard and to  assume that XDR binary format will be
       used in FITS file.
       
       SEE ALSO: cfitsio_bitpix_type, cfitsio_check_bitpix. */
{
    if (is_array(x))
    {
        x = structof(x);
    }
    else if (typeof(x) != "struct_definition")
    {
        error, "expecting array or data type argument";
    }
    if (native)
    {
        /* Compute BITPIX. */
        bpb = 8; /* assume 8 bits per byte */
        if (x==char || x==short || x==int || x==long)
        {
            bitpix = bpb*sizeof(x);
            if (bitpix == 8 || bitpix == 16 || bitpix == 32)
            {
                return bitpix;
            }
        }
        else if (x == float || x == double)
        {
            bitpix = -bpb*sizeof(x);
            if (bitpix == -32 || bitpix == -64)
            {
                return bitpix;
            }
        }
    }
    else
    {
        /* Assume data will be read/written as XDR. */
        if (x == char)
        {
            return 8;
        }
        if (x == short)
        {
            return 16;
        }
        if (x == int || x == long)
        {
            return 32;
        }
        if (x == float)
        {
            return -32;
        }
        if (x == double)
        {
            return -64;
        }
    }
    error, "unsupported data type "+typeof(array(x));
}

func cfitsio_type_typecode(type)
{
    if(     type==TSTRING) 
    {
        return "A";
    }
    else if(type==TDOUBLE)
    {
        return "D";
    }
    else if(type==TINT) 
    {
        return "I";
    }
    else if(type==TLONG) 
    {
        return "J";
    }
    else if(type==TFLOAT) 
    {
        return "E";
    }
    else if(type==TCOMPLEX)
    {
        return "C";
    }
    else if(type==TDBLCOMPLEX)
    {
        return "M";
    }
    else if(type==TLOGICAL)
    {
        return "L";
    }
    else if(type==TSHORT)
    {
        return "I";
    }
    else error,"format not supported";
}

func cfitsio_TTYPE_type(&type)
{
    if(     type==TSTRING)
    {
        return string;
    }
    else if(type==TDOUBLE)
    {
        return double;
    }
    else if(type==TINT) 
    {
        return int;
    }
    else if(type==TLONG)
    {
        return long;
    }
    else if(type==TFLOAT) 
    {
        return float;
    }
    else if(type==TCOMPLEX)
    {
        return complex;
    }
    else if(type==TLOGICAL) 
    {
        return int;
    }
    else if(type==TSHORT)
    {
        return short;
    }
    else if(type==TDBLCOMPLEX)
    {
        return complex;
    }
    else
    {
        error,"format not supported";
    }
    
}

func cfitsio_TTYPE_of(&data)
{
    if(     typeof(data)=="double")
    {
        return TDOUBLE;
    }
    else if(typeof(data)=="int")
    {
        return TINT;
    }
    else if(typeof(data)=="long")
    {
        return TLONG;
    }
    else if(typeof(data)=="float")
    {
        return TFLOAT;
    }
    else if(typeof(data)=="char")
    {
        return TLOGICAL;
    }
    else if(typeof(data)=="short")
    {
        return TSHORT;
    }
    else if(typeof(data)=="string")
    {
        return TSTRING;
    }
    else if(typeof(data)=="complex")
    {
        return TDBLCOMPLEX;
    }
    else 
    {
        error,"format not supported";
    }
}

func cfitsio_bitpix_TTYPE(bitpix)
{
    return cfitsio_TTYPE_of(cfitsio_bitpix_type(bitpix)());
}

func cfitsio_set_tform(data)
/* DOCUMENT cfitsio_set_tform(data)
   
   Return the value of the TFORM keyword associated with the
   input data array DATA.     
*/
{
    local nelem,tcode;
    if(dimsof(data)(1) == 0)
    {
        error,"not an array data";
    }
    if(dimsof(data)(1) == 1)
    {
        nelem= 1;
    }
    else
    {
        nelem= numberof(data(..,1));
    }
    
    if(typeof(data)=="string")
    {
        if(nelem>1)
        {
            error,"array not available for string";
        }
        nelem = max(strlen(data));
    }
    
    tcode = cfitsio_type_typecode(cfitsio_TTYPE_of(data));
    return pr1(nelem)+tcode;
}

/* ------------------ string manipulation ---------------------- */

func cfitsio_strchr(str) 
/* DOCUMENT cfitsio_strchr(str)
   
   Return a character array corresponding to the string str.  If str is an
   array, the expansion occurs on the last dimension: if str is of dimension
   d_1 x ... x d_n, chr will be of dimension d_1 x ... x d_n x (l+1), where l
   is the maximum string length in array str.
   Exemple: ["a", "bc"] -> [['a','\0','\0'],['b','c','\0']]
*/
{
    local n;
    chr = array(char(0), dimsof(str(-:1:1+max(strlen(str)),..)));
    for (i = 1; i <= numberof(str); ++i)
    {
        if(str(i)==string([]))
        {
            continue;
        }
        local ch;
        ch = *pointer(str(i));
        chr(,i)(1:numberof(ch)) = ch;
    }
    return chr;
}

func cfitsio_chrstr(chr) 
/* DOCUMENT cfitsio_chrstr(chr)
   
   Return a string corresponding to the character array chr.  The string
   making is performed on the last dimension of chr; in other words, if chr is 
   of dimension d_1 x ... x d_n, then str is of dimension d_1 x ... x d_(n-1). 
   The C string format is assumed, so all characters following a '\0' are
   ignored.  
   Exemple: [['a','\0','\0'],['b','c','\0']] -> ["a", "bc"]
   ['a', '\0', 'b'] -> "a"
   
   SEE ALSO: strchr, chrstr
   
*/
{
    local ss;
    ss = array(string, dimsof(chr(1,)));
    for (i = 1; i <= numberof(chr(1,)); ++i)
    {
        ss(i) = string(&chr(,i));
    }
    return ss;
}

func cfitsio_trim(s)
/* DOCUMENT cfitsio_trim(s)
   
   Removes trailing  spaces (character 0x20) from scalar  string S (note:
   trailing spaces are not significant in FITS).
*/
{
    if (! (i = numberof((c = *pointer(s)))))
    {
        return string(0);
    }
    while (--i)
    {
        if (c(i) != ' ')
        {
            return string(&c(1:i));
        }
    }
    return "";
}

func cfitsio_parse(card, &comment, &kname, safe=)
/* DOCUMENT value = cfitsio_parse(card, comment, kname)
   
   Cut the input CARD into value, comment and kname...
   This function was directly extrated form the "fits2.i" of E.Thiebaul
*/
{
    
    if(is_void(safe))
    {
        safe = 1;
    }
    
    kname = strpart(card,1:7);
    /* special keyword */
    if(kname == "COMMENT")
    {
        return strpart(card,10:0);
    }
    if(kname == "HISTORY")
    {
        return strpart(card,10:0);
    }
    /* else, cut the card */
    kname = strtok(card, "=");
    /* recover the data part of the card */
    tail  = "="+kname(2);
    /* recover the name of the card */
    kname = cfitsio_trim(kname(1));
    
    /* other keyword */
    r = s = comment = string(0);
    if ((n = sread(tail, format="%1[=]%1s", r, s)) != 2)
    {
        return;
    }
    else if (strmatch("0123456789+-.", s))
    {
        /* Numerical value...
           ... try integer value: */
        re = 0;
        n = sread(tail, format="=%d%1s %[^\a]", re, s, comment);
        if (n==1 || (n>1 && s=="/"))
        {
            return re;
        }
        
        /* ... try real value: */
        re = 0.0;
        n = sread(tail, format="=%f%1s %[^\a]", re, s, comment);
        if (n==1 || (n>1 && s=="/"))
        {
            return re;
        }
        
        /* ... try complex value: */
        im = 0.0;
        n = sread(tail, format="=%f%f%1s %[^\a]", re, im, s, comment);
        if (n==2 || (n>2 && s=="/"))
        {
            return re + 1i*im;
        }
        
    }
    else if (s=="T" || s=="F")
    {
        /* Logical value. */
        value = (s == "T" ? 'T' : 'F');
        n = sread(tail, format="= "+s+"%1s %[^\a]", s, comment);
        if (n==0 || (n>0 && s=="/"))
        {
            return value;
        }
        
    }
    else if (s=="'" && sread(tail, format="= '%[^\a]", s))
    {
        /* String value. */
        q = p1 = p2 = string(0);
        value = "";
        do
        {
            if (sread(s, format="%[^']%[']%[^\a]", p1, q, p2))
            {
                value += p1;
            }
            else if (! sread(s, format="%[']%[^\a]", q, p2))
            {
                break;
            }
            if ((n = strlen(q)) > 1)
            {
                value += strpart(q, :n/2);
            }
        }
        while ((s=p2) && !(n%2));
        if (! sread(s, format="%1s %[^\a]", q, comment) || q=="/")
        {
            /* discard trailing spaces which are not significant in FITS */
            i = numberof((c = *pointer(value)));
            while (--i)
            {
                if (c(i) != ' ')
                {
                    return string(&c(1:i));
                }
            }
            return "";
        }
    }
    else if (s == "/")
    {
        /* Undefined keyword with comment. */
        sread, tail, format="= / %[^\a]", comment;
        return;
    }
    
    /* if safe==0, introduce an error */
    if (! safe)
    {
        error, "syntax error in FITS card \""+strpart(card, 1:8)+"\"";
    }
    
    /* If safe=1, return the data in string output */
    tail = strtok(tail,"/");
    comment = tail(2);
    if(comment!=string([]))
    {
        comment = cfitsio_trim(strpart(comment,2:0));
    }
    if(comment=="")
    {
        comment = string([]);
    }
    
    return cfitsio_trim(strpart(tail(1),3:0));  
}

////////////////////////////////////////////////////////////////////////////
//                    
//              High Level routines for FITSFILE manipulation
//                    
///////////////////////////////////////////////////////////////////////////

/* ------------------------  Basic fits I/O routines ------------------- */

func cfitsioRead(fileName)
/* DOCUMENT result = cfitsioRead(fileName)

   Reads the content of the image array contained in a fits file
   and fills the result yorick array.
       
   SEE ALSO: cfitsioRead, cfitsioWrite
*/
{
    local fh;

    /* Open an existing file */
    fh  = cfitsio_open(fileName,"r");

    /* Read the image */
    img = cfitsio_read_image(fh);

    /* Close the file */
    cfitsio_close,fh;
    
    return img;
}

func cfitsioWrite(fileName,data)
/* DOCUMENT cfitsioWrite,fileName,data;

   Write to a fits file the yorick array data, with any number of dimensions.
   
   SEE ALSO: cfitsioRead, cfitsioWrite
*/
{
    local fh;
    
    /* Create the file */
    fh = cfitsio_open(fileName,"w",overwrite=1);

    /* Add an image and write the data */
    cfitsio_add_image, fh, data, "IMAGE";

    /* Write the date */
    cfitsio_write_date,fh;  
    
    /* Close the file */
    cfitsio_close,fh;
    return 1;
}

/* For compatibility */
cfitsRead  = cfitsioRead;
cfitsWrite = cfitsioWrite;

/* --------------------------- FILES I/O ----------------------------------- */


cfitsio_close = cfitsio_close_file;
/* DOCUMENT cfitsio_close(&fh)
   Close the 'fh' open FITS file and set the fh value to [].
   
   SEE ALSO: cfitsio_open, cfitsio_close
*/

func cfitsio_open(filename,filemode,&fh,overwrite=)
/* DOCUMENT cfitsio_open(filename)
   -or-     cfitsio_open(filename, filemode)
   -or-     cfitsio_open,filename,filemode,fh;
   
   Opens  the FITS  file FILENAME  according to  FILEMODE.   The returned
   value is a FITS handle used  in most other FITS routines.  FILEMODE is
   one of:
   "r" or 'r' - read mode,  the header of the primary  HDU get read and
   is parsed.
   "w" or 'w' - write   mode,  new  file  is  created  (unless  keyword
   OVERWRITE is true, FILENAME must not already exists).
   "a" or 'a' - append  mode, stream  get positionned  at last HDU, the
   header of the last HDU get read and parsed.
   The default FILEMODE is "r" -- open an existing FITS file for reading.
   
   Keyword OVERWRITE can be used to force overwriting of an existing file
   (otherwise it is an error to create a file that already exists).
   
   The pointer on the file (fh) in return as in int since it
   avoid some dynamique memory allocation problems.
   
   SEE ALSO: cfitsio_open, cfitsio_close_file
*/
{
    local fh;

    /* Deal with ~ in the name */
    if ( strpart(filename,1:1)=="~" ) filename = get_env("HOME")+strpart(filename,2:);
    
    if(is_void(filemode))
    {
        filemode ="r";
    }
    if(filemode=='r')
    {
        filemode = "r";
    }
    else if(filemode=='w')
    {
        filemode = "w";
    }
    else if(filemode=='a')
    {
        filemode = "a";
    }
    else if(filemode=='c')
    {
        filemode = "c";
    }
    
    if(filemode=="c")
    {
        filemode="w";
        overwrite=1;
    }
    
    /* readonly mode */  
    if(filemode=="r")
    {
      return cfitsio_open_file(filename, READONLY);
    }
    /* write only mode */
    else if(filemode=="w")
    {
        if(overwrite)
        {
            remove,filename;
        }
        else if(!overwrite && open(filename,"r",1))
        {
            error, "file \""+filename+"\" already exists";
        }
        return cfitsio_create_file(filename);
    }
    /* read/write mode */
    else if(filemode=="a")
    {
      fh = cfitsio_open_file(filename, READWRITE);
      n  = cfitsio_get_num_hdus(fh);
      cfitsio_goto_hdu, fh, n;
      return fh;
    }
    /* else error */
    else
    {
        error,pr1(filemode)+" is not a conformable filemode, should be"+
            " \"r\", \"w\" or \"a\"";
    }
}

/* ----------------------------- HDU I/O ---------------------------- */

func cfitsio_goto_hdu(&fh,hdu,&hdutype)
/* DOCUMENT cfitsio_goto_hdu,fh,1
   -or-     cfitsio_goto_hdu, fh, "HDUNAME"
   -or-     cfitsio_goto_hdu, fh, "*NAME", BINARY_TBL
   
   Move to the correponding HDU in the FITS file 'fh'.

   ** cfitsio_goto_hdu,fh,hdunum,hdutype 
   move the 'hdunum' HDU and store his type in 'hdutype'.

   ** cfitsio_goto_hdu,fh,hduname,hdutype
   move to the next HDU which match the 'hduname' AND the 'hdutype'.
   'hdutype' could be BINARY_TBL, ASCII_TBL or IMAGE_HDU

   ** cfitsio_goto_hdu,fh,hduname
   move to the next HDU which match the 'hduname'
   AND with type BINARY_TBL .

   SEE ALSO: cfitsio_get_num_hdus, cfitsio_goto_hdu
*/
{
    if(is_void(hdu))
    {
        hdu=1;
    }
    if(is_void(hdutype))
    {
        hdutype=ANY_HDU;
    }
    if(typeof(hdu)=="int" || typeof(hdu)=="long")
    {
        cfitsio_movabs_hdu, fh, hdu;
    }
    else if(typeof(hdu)=="string")
    {
      cfitsio_movnam_hdu, fh, hdutype, hdu;
    }
    else
    {
        error,"HDU keyword should be a string or a int";
    }

    hdutype = cfitsio_get_hdu_type(fh);
    return fh;
}

func cfitsio_next_hdu(&fh)
/* DOCUMENT cfitsio_next_hdu(fh)
   
   Move FITS handle FH to next Header Data Unit and parse the header part
   of the  new unit.  Contents of FH  is updated with header  part of new
   HDU.  To allow for linked calls, the returned value is FH.

   This function is the SAME as 'cfitsio_movrel_hdu'
*/
{
    return cfitsio_movrel_hdu(fh,+1);
}

func cfitsio_rewind(&fh)
/* DOCUMENT cfitsio_rewind(fh)
   
   Move FITS handle FH to primary Header Data Unit.
   FH is returned when called as a function.
*/
{
    return cfitsio_goto_hdu(fh,1);
}

func cfitsio_list(fh)
/* DOCUMENT cfitsio_list, fh;
   -or- cfitsio_list(fh)
   
   Get the names of  the FITS extensions in FH.  FH can  be the name of a
   FITS file  or a FITS handle  FH (the input handle  is left unchanged).
   When called  as a  subroutine, the list  is printed to  terminal; when
   called as  a function, the returned  value is a string  array with the
   names of the FITS extensions in FH.
*/
{
    /* read current hdu and number of hdu */
    hdunum0 = cfitsio_get_hdu_num(fh);
    hdunum  = cfitsio_get_num_hdus(fh);

    /* first HDU is always an image, even void */
    descr = "IMAGE";

    /* loop on all XTENSION hdu */
    for(i=2;i<=hdunum;i++)
    {
        cfitsio_goto_hdu,fh,i;
        grow,descr,cfitsio_get(fh,"XTENSION");
    }

    /* go back on first hdu */
    cfitsio_goto_hdu,fh,hdunum0;

    /* if subroutine, write the results on the screen */
    if (am_subroutine())
    {
        write, format="HDU=%-3d  XTENSION=\"%s\"\n",indgen(numberof(descr)), descr;
    }

    return descr;
}

func cfitsio_get_xtension(fh)
/* DOCUMENT cfitsio_get_xtension(fh)
   
   Get XTENSION value  from current HDU in FITS  handle FH.  The returned
   value is a  scalar string with the name of  the extension;  "IMAGE" is
   returned for the primary HDU.
*/
{
    if(cfitsio_get_hdu_num(fh)==1)
    {
        return "IMAGE";
    }
    else
    {
        return cfitsio_get(fh,"XTENSION");
    }
}

/* --------------------------- Header I/O -------------------------- */

func cfitsio_get(&fh,key,&comment,&keyname, default=, point=)
/* DOCUMENT cfitsio_get(fh,key,comment,keyname,default=)

   Return the value of all the keyword which match KEY.
   KET could be an array.
   All the keyword SHOULD have the same keyvalue type.
   The comment part of the card is store in COMMENT as a string.
   The name part of the card is store in KEYNAME as a string;

   EXAMPLES:
   value = cfitsio_get(fh, ["TEST","COMMENT"], comments);
   value = cfitsio_get(fh, "EXTNAME");
   value = cfitsio_get(fh, "DATE*", comments, names);

   If no cards match KEY, the  value of keyword  DEFAULT is returned
   and COMMENT and NAME is set to the null string.

   IF POINT=1, the value are return as pointer on value, so there is no pb
   of type between value of different card.

   EXAMPLES:
   pvalue = cfitsio_get(fh, "*", comments, names, point=1);

   SEE ALSO: cfitsio_get, cfitsio_set, cfitsio_delete
*/
{
    local value,comment,keyname,_value,_comment,_card,_name;
    keyname = value = comment = [];

    for(i=1;i<=numberof(key);i++)
    {
        cfitsio_read_record, fh, 0;
        if(typeof(key(i))!="string")
        {              /* key is numerical */ 
            _card  = cfitsio_read_record(fh,key(i));
            _value = cfitsio_parse(_card,_comment,_name,safe=1);
            if(point)
            {
                grow,value,&value;
            }
            else
            {
                grow,value,_value;
            }
            grow,comment,_comment;
            grow,keyname,_name;
        }
        else
        {
            do
            {                                   /* key is string */
                if(strpart(key(i),1:9)=="HIERARCH ")
                {
                    key(i) = strpart(key(i),10:);
                }
                _card  = cfitsio_find_nextkey(fh,key(i));
                if(is_void(_card) || _card=="" || _card==string())
                {
                    break;
                }
                _value = cfitsio_parse(_card,_comment,_name,safe=1);
                if(point)
                {
                    grow,value,&_value;
                }
                else
                {
                    if(!cfitsio_are_confomable(value,_value))
                    {
                        error,"match FITS card with '"+typeof(value)+"' and '"+typeof(_value)+"'";
                    }
                    grow,value,_value;
                }
                grow,comment,_comment;
                grow,keyname,_name;
            }
            while(1);
        }
    }
    if(dimsof(key)(1)==0)
    {
        if(numberof(comment)==1)
        {
            comment = comment(1);
        }
        if(numberof(value)  ==1)
        {
            value   = value(1);
        }
    }
    
    if(is_void(value))
    {
        value = default;
    }
    if(is_void(comment))
    {
        comment = string([]);
    }
    if(is_void(keyname))
    {
        keyname = string([]);
    }
    
    return value;
}

func cfitsio_set(&fh,keyname,keyvalue,comment,unit)
/* DOCUMENT cfitsio_set(fh,keyname,keyvalue,comment,unit)

   Write a new key (or serie of key) in the 'fh'
   'keyvalue', 'comment' and 'unit' could be array of at
   maximum the dimension of 'keyname' (but but be smaller).
   If the key exist, the value is modified.
   
   EXAMPLES:
   cfitsio_set,fh, "T"+swrite(format="%i",indgen(5)), indgen(5), "commentary";

   SEE ALSO: cfitsio_set, cfitsio_get, cfitsio_delete
*/
{
    local pvalue,pcomme,numkey;
    numkey = max(numberof(keyname),numberof(keyvalue));

    /* Check is passed as pointers */
    point = (typeof(keyvalue)=="pointer");

    /* Loop on cards to be written */
    for(i=1;i<=numberof(keyname);i++)
    {
        pname = numberof(keyname)(1)>=1  ? &keyname(i%numberof(keyname))   : &keyname;  
        if(point)
        {
            pvalue= numberof(keyvalue)(1)>=1 ? keyvalue(i%numberof(keyvalue)) : keyvalue;
        }
        else
        {
            pvalue= numberof(keyvalue)(1)>=1 ? &keyvalue(i%numberof(keyvalue)) : &keyvalue;
        }
        pcomme= numberof(comment)(1)>=1  ? &comment(i%numberof(comment))   : &comment;
        punit = numberof(unit)(1)>=1     ? &unit(i%numberof(unit))         : &unit;
        *pname = cfitsio_trim(*pname);    
        
        if(*pname=="COMMENT")
        {
            cfitsio_write_comment,fh,*pvalue;
        }
        else if(*pname=="HISTORY")
        {
            cfitsio_write_history,fh,*pvalue;
        }
        else if (is_void(*pvalue))
        {
            __ffukyu,fh,*pname,*pcomme;
            if(*punit) cfitsio_write_key_unit,fh,*pname,*punit;
        }
        else
        {
            cfitsio_update_key,fh,*pname,*pvalue,*pcomme;
            if(*punit) cfitsio_write_key_unit,fh,*pname,*punit;
        }
    }
    return fh;
}

func cfitsio_delete(&fh,key)
/* DOCUMENT cfitsio_delete(fh,key)

   Delete the card (or serie of card) which match the pattern 'key'
   (or array of pattern).
   
   EXAMPLES:
   cfitsio_delete, fh, ["TEST*","TUNIT#"];

   SEE ALSO: cfitsio_set, cfitsio_get, cfitsio_delete
*/
{
    /* Go back to first record */
    cfitsio_read_record, fh, 0;
    
    for(i=1;i<=numberof(key);i++)
    {
        cfitsio_read_record, fh, 0;
        if(typeof(key)!="string")
        {
            cfitsio_delete_record,fh,key(i);
        }
        else
        {
            do
            {
                if(is_void(cfitsio_find_nextkey(fh,key(i))))
                {
                    break;
                }
                cfitsio_read_record, fh, 0;
                cfitsio_delete_key,fh,key(i);
            }
            while(1);
        }
    }
    return fh;
}

/* --------------------------- Images I/O -------------------------- */

func cfitsio_write_image(&fh, image)
/* DOCUMENT cfitsio_write_image(&fh, image)
   
   Write the 'image' data in the pre-created
   current IMAGE HDU.

   SEE ALSO: cfitsio_add_image, cfitsio_write_image,
             cfitsio_read_image, cfitsio_read_image_subset
             cfitsio_get_coordinate
*/
{
    /* parameters */
    dim       = dimsof(image);
    fpixels   = array(1,dim(1));
    nelements = numberof(image);

    /* Write data */
    cfitsio_write_pix, fh, fpixels, nelements, image;
    
    return fh;
}

func cfitsio_add_image(&fh, image, extname)
/* DOCUMENT cfitsio_add_image(&fh, image, extname)
   
   Create a new IMAGE HDU with the name 'extname'
   and write the multidimentional 'image' data.

   SEE ALSO: cfitsio_read_image
*/
{ 
    /* default */
    if(is_void(extname)) extname = "FYO-IMG";

    /* create the image */
    cfitsio_create_img, fh, cfitsio_bitpix_of(image), dimsof(image);

    /* add the extension name */
    cfitsio_write_key, fh, "EXTNAME", extname, "name of HDU";

    /* parameters */
    dim       = dimsof(image);
    fpixels   = array(1,dim(1));
    nelements = numberof(image);

    /* write data */
    cfitsio_write_pix, fh, fpixels, nelements, image;
    
    return fh;
}

func cfitsio_read_image(&fh, &image, &nulval)
/* DOCUMENT cfitsio_read_image(&fh, &image, &nulval)
   
   Read the 'image' multi-dimentional data from the current
   HDU.

   TLOGICAL image does not exist in YORICK and are read and
   returned as INT images.

   SEE ALSO: cfitsio_add_image, cfitsio_read_image,
             cfitsio_read_image_subset
*/
{
    /* parameters */
    daxes    = cfitsio_get_img_size(fh);
    bitpix   = cfitsio_get_img_type(fh);
    datatype = cfitsio_bitpix_TTYPE(bitpix);

    /* Read logical as yorick int.
       FIXME: check this code should better go
       in cfitsio_read_pix */
    if(datatype == TLOGICAL)
    {
        datatype = TINT;
    }

    /* Read whole image */
    image = cfitsio_read_pix(fh, datatype, daxes,, nulval);
    
    return image;
}

func cfitsio_read_image_subset(fh, fpixel, lpixel, inc, &image, &anynul)
/* DOCUMENT cfitsio_read_image_subset(&fh, fpixel, lpixel, inc, &image, &anynul)

   Read a subset of the 'image' multi-dimentional data from the current
   HDU. FPIXEL and LPIXEL give the coordinate of the first nad last
   element (lower left / upper right corner). INC give the step in pixel
   in each direction (array of long, same dimension than FPIXEL)

   SEE ALSO: cfitsio_add_image, cfitsio_read_image,
             cfitsio_read_image_subset
*/
{
    /* parameters */
    daxes    = cfitsio_get_img_size(fh);
    bitpix   = cfitsio_get_img_type(fh);
    datatype = cfitsio_bitpix_TTYPE(bitpix);
    
    /* Read logical as yorick int.
       FIXME: check this code should better go
       in cfitsio_read_subset */
    if(datatype == TLOGICAL)
    {
        datatype = TINT;
    }
    
    /* read the subset */
    image = cfitsio_read_subset(fh, datatype, daxes, fpixel, lpixel, inc, , , anynul);
    
    return image;
}

func cfitsio_get_coordinate(&fh, axis, span=)
/* DOCUMENT cfitsio_get_coordinate(fh, axis)
   
   Gets AXIS-th coordinate information for current HDU in FITS handle FH.
   By  default, the  result  is a  cfitsio_coordinate  structure defined  as
   follows:
   struct cfitsio_coordinate 
   long axis    : axis number
   long length  : number of elements along this axis
   string ctype : name of the coordinate represented by this axis
   double crpix : location of a reference point (starting at 1)
                  along this axis
   double crval : value of the coordinate along this axis at the
                  reference point
   double cdelt : partial derivative of the coordinate with respect
                  to the pixel index along this axis, evaluated at
                  the reference point
   double crota : used to indicate a rotation from a standard
                  coordinate system described by the value of CTYPE
                  to a different coordinate system in which the
                  values in the array are actually expressed
   
   If keyword  SPAN is true, then the  result is a vector  that gives the
   coordinate of each element along given axis:
   CDELT*(indgen(LENGTH) - CRPIX) + CRVAL
   Note that, if the axis length is zero, a nil value is returned.

   SEE ALSO: cfitsio_open, cfitsio_read_image
*/
{
    /* check */
    if (! cfitsio_is_integer_scalar(axis))
    {
        error, "AXIS number must be a scalar integer";
    }
    ith = swrite(format="%d", axis);
    if (structof((length = cfitsio_get(fh, (key = "NAXIS"+ith)))) != long ||
        length < 0)
    {
        error, ((is_void(length) ? "missing" : "bad value/type for")
                + " FITS card \"" + key + "\"");
    }
    if (structof((crpix = cfitsio_get(fh, (key = "CRPIX"+ith),
                                   default=1.0))) != double ||
        structof((crval = cfitsio_get(fh, (key = "CRVAL"+ith),
                                   default=1.0))) != double ||
        structof((cdelt = cfitsio_get(fh, (key = "CDELT"+ith),
                                   default=1.0))) != double ||
        structof((crota = cfitsio_get(fh, (key = "CROTA"+ith),
                                   default=0.0))) != double ||
        structof((ctype = cfitsio_get(fh, (key = "CTYPE"+ith),
                                   default=string(0)))) != string)
    {
        error, "bad data type for FITS card \"" + key + "\"";
    }

    /* deal with span */
    if (span)
    {
        return (length ? cdelt*(indgen(length) - crpix) + crval : []);
    }

    /* Build the structure */
    coord = cfitsio_coordinate(axis=axis, length=length, ctype=ctype,
                               crpix=crpix, crval=crval, cdelt=cdelt,
                               crota=crota);

    return coord;
}

struct cfitsio_coordinate {
    long axis, length;
    string ctype;
    double crpix, crval, cdelt, crota;
}

/* --------------------------- Tables I/O -------------------------- */

func cfitsio_add_column(&fh,data,ttype)
/* DOCUMENT cfitsio_add_column, &fh, data, ttype;

   DESCRIPTION
   Write data as a new column in BINARY table.

   SEE ALSO cfitsio_add_column, cfitsio_read_column,
            cfitsio_read_multicolumn,
            cfitsio_read_bintable
*/
{
    /* parameters */
    ncol    = cfitsio_get_num_cols(fh)+1;
    tform   = cfitsio_set_tform(data);

    /* default */
    if(is_void(ttype))
    {
        ttype = "data";
    }

    /* Insert column  */
    cfitsio_insert_col, fh, ncol, ttype, tform;

    /* Write the TDIM. */
    if(dimsof(data)(1)>1)
    {
        cfitsio_write_tdim, fh, ncol, dimsof(data(..,1));
    }

    /* Write the data */
    cfitsio_write_col, fh, ncol, data;

    return fh;
}

func cfitsio_write_column(&fh, colnum, data)
/* DOCUMENT cfitsio_write_column(&fh, colnum, data)

   DESCRIPTION
   Write a single column in an existing BINTABLE.

   SEE ALSO cfitsio_add_column, cfitsio_read_column,
            cfitsio_read_multicolumn,
            cfitsio_read_bintable
            cfitsio_delete_col
*/
{
    /* Write the TDIM. */
    if(dimsof(data)(1)>1)
    {
        cfitsio_write_tdim,fh, colnum, dimsof(data(..,1));
    }

    /* Write the data */
    cfitsio_write_col, fh, colnum, data;
    
    return fh;
}

func cfitsio_read_column(&fh,colnum,&ttype,&anynul,casesen=,frow=,nrows=)
/* DOCUMENT datta = cfitsio_read_column(&fh,colnum,&ttype,&anynul,casesen=,
                                        frow=,nrows=)

   DESCRIPTION
   Read the data from a single column in binary table.

   Optional arguments frow= and nrows= specify the first row (starting
   at 1) and the number of rows to be read. Default is to read all.

   SEE ALSO cfitsio_add_column, cfitsio_read_column,
            cfitsio_read_multicolumn,
            cfitsio_read_bintable
            cfitsio_delete_col
 */
{
    /* default */
    if(is_void(casesen))
    {
        casesen=0;
    }
    if(typeof(colnum)=="string")
    {
        colnum=cfitsio_get_colnum(fh, casesen, colnum);
    }
    
    /* parameters */
    coltype = cfitsio_get_col_type(fh,colnum);
    tdim    = cfitsio_read_tdim(fh, colnum);
    ttype   = cfitsio_get(fh,"TTYPE"+pr1(colnum));
    nulval  = cfitsio_typeinit_array(coltype);

    /* default for first row and number of rows
       to be read: real all rows.   */
    if ( is_void(nrows) )
    {
      nrows = cfitsio_get_num_rows(fh);
    }
    if ( is_void(frow) )
    {
      frow  = long(1);
    }
    
    /* read the datas */
    data = cfitsio_read_col(fh, coltype, colnum, tdim, frow, nrows, nulval, anynul);

    /* If scalar, return a scalar (assume string cannot be arrays).
       FIXME: check if this code should be better put in
       cfitsio_read_col */
    if( tdim(1)==1 && tdim(2)==1 && coltype!=TSTRING )
    {
        data = data(1,..);
    }
    
    return data;
}

func cfitsio_read_multicolumn(&fh,col,&bintitle,casesen=,force_array=)
{
    local ncols,col0;col0=[];
    if(is_void(casesen)) casesen=0;
    if(typeof(col=="string"))
    {
        for(i=1;i<=numberof(col);i++)
        {
            grow,col0,cfitsio_get_colnum(fh, casesen, col(i));
        }
        col = col0;
    }

    ncols = numberof(col);
    if(numberof(ncols)==0)
    {
        bintitle=[];
        return &[];
    }
    bintable = array(pointer,ncols);
    bintitle = array(string,ncols);
    for(i=1;i<=ncols;i++)
    { // loop on colnum :
        bintable(i) = &cfitsio_read_column(fh,col(i),name);
        bintitle(i) = name;
    }
    if(force_array)
    {
        bintable=_cfitsio_force_array(bintable,tab);
        bintitle=bintitle(tab);
    }
    return bintable;
}

func _cfitsio_force_array(pdata,tab)
{
    local data,tab; tab=[];
    data = array(*pdata(1),numberof(pdata));
    for(i=1;i<=numberof(pdata);i++)
    {
        if(!is_void(*pdata(i)))
        {
            data(..,i) = *pdata(i);
            grow,tab,i;
        }
    }
    return data;
}

func cfitsio_read_bintable(&fh, &bintitle, frow=, nrows=)
/* DOCUMENT cfitsio_read_bintable(fh, bintitle, frow=, nrows=)

   DESCRIPTION:
   Read a binary table form the current HDU.
   It return the title of each column in the bintitle array.

   This function return an array of pointer on each column
   of the bintable because the type of each column could
   be different.

   Optional arguments frow= and nrows= specify the first row (starting
   at 1) and the number of rows to be read. Default is to read all.

   * for exemple :
   b = cfitsio_read_bintable(fh);
   *b(1) is the first column of b
   *b(2) is the second one
   ...

   SEE ALSO: cfitsio_read_bintable, cfitsio_add_bintable,
             cfitsio_delete_rowlist
*/
{  
    local ncols,name;

    /* Read the number of column */
    ncols = cfitsio_get_num_cols(fh);

    /* Deal with the case the table is void */
    if(ncols==0)
    {
        bintitle=[""];
        return &[];
    }

    /* Define output arrays */
    bintable = array(pointer,ncols);
    bintitle = array(string,ncols);
    
    /* loop on colnum */
    for(i=1;i<=ncols;i++)
    {
        local tmp;
        tmp = cfitsio_read_column(fh,i,name,frow=frow,nrows=nrows);
        if(typeof(tmp)=="string" && allof(tmp==""))
        {
            tmp = array("",dimsof(tmp));
        }
        bintable(i) = &tmp;
        bintitle(i) = name;
    }
    
    return bintable;
}

func cfitsio_add_bintable(&fh, pcol, titles, units, extname)
/* DOCUMENT cfitsio_add_bintable(&fh, pcol, titles, units, extname)

   DESCRIPTION:
   Creat a new BINARY_TBL HDU  and write pcol as a
   binary table.
   'pcol' should be an 1-dim array of pointer (one per colum of
   the bintable). 'titles' is the array of columns titles.
   'units' is the array of columns units.
   'extname' is the name of the new HDU created.

   SEE ALSO: cfitsio_read_bintable, cfitsio_add_bintable,
             cfitsio_delete_rowlist

*/
{
    local tform,tmp;
    tform=[];

    /* check */
    if(typeof(pcol)!="pointer")
    {
        error,"pcol should be array of pointer";
    }
    
    /* number of cols */
    ncols = numberof(pcol);

    /* Loop on col to define the TFORM */
    for(i=1;i<=ncols;i++)
    {
        /* void string will kill cfitsio */
      if(typeof(*pcol(i)) =="string" &&
         is_array((tmp=where( *pcol(i)==string(0) |
                              *pcol(i)==string("")))))
        {
          (*pcol(i))(tmp)=" ";
        }
        
        grow,tform,cfitsio_set_tform(*pcol(i));
    }
    
    /* Create the table with all the columns */
    cfitsio_create_tbl, fh, BINARY_TBL, 0, titles, tform, units, extname;
    
    /* Write the data */
    for(i=1;i<=ncols;i++)
    {
        cfitsio_write_column, fh, i, *pcol(i);
    }

    return fh;
}

/* ---------------- For compatibility with fits.i -------------- */

func cfitsio_new_image(&fh, bitpix=, dimlist=, bzero=, bscale=)
/* DOCUMENT cfitsio_new_image(fh, ...)
   
   Starts a new image (array)  FITS extension.  This routine starts a new
   FITS  extension with  name "IMAGE"  and pre-set  FITS cards  needed to
   describe the array data according to keywords: BITPIX, DIMLIST, BZERO,
   BSCALE.  The returned value is FH.

   This is to match the cfits_new_image from fits.i
*/
{
    if(is_void(bitpix))
    {
        bitpix = -32;
    }
    if(is_void(dimlist))
    {
        dimlist = [1,1];
    }
    return cfitsio_create_img(fh,bitpix,dimlist);
}

cfitsio_current_hdu = cfitsio_get_hdu_num;
/* DOCUMENT cfitsio_current_hdu(fh);
   
   Return number of current Header Data Unit in FITS handle FH.
   This function is the SAME as 'cfitsio_get_hdu_num'

   This is to match the function fits_current_hdu in fits.i   
*/

func cfitsio_get_naxis(fh, fix)
/* DOCUMENT cfitsio_get_naxis(fh)

   Get  NAXIS   value  from   current  HDU  in   FITS  handle   FH.   See
   cfitsio_get_special for the meaning of FIX.
   
   This is to match the function cfits_get_naxis in fits.i
*/
{
    if(!is_void(fix))
    {
        error,"FIX keyword not implemented in 'cfitsioPlugin'";
    }
    return cfitsio_get_img_dim(fh);
}

func cfitsio_get_dims(fh, fix)
/* DOCUMENT cfitsio_get_dims(fh)

   Get all  NAXIS* values from current  HDU in FITS handle  FH and return
   vector  [NAXIS, NAXIS1,  NAXIS2, ...].

   This is to match the function cfits_get_dims in fits.i
*/
{
    if(!is_void(fix))
    {
        error,"FIX keyword not implemented in 'cfitsioPlugin'";
    }
    return cfitsio_get_img_size(fh);
}
