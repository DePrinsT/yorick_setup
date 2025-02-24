/*******************************************************************************
* LAOG project - Yorick Contribution package 
* 
* Checking yorick type tools.
*
* "@(#) $Id: yocoType.i,v 1.12 2007-12-14 07:17:28 gzins Exp $"
*
* History
* -------
* $Log: not supported by cvs2svn $
* Revision 1.11  2007/11/17 16:43:49  jblebou
* Add functions yocoTypeIsNumerical
*
* Revision 1.10  2007/11/17 14:17:02  jblebou
* Format and complete the help.
*
* Revision 1.9  2007/11/16 13:55:02  jblebou
* Update documentation.
*
* Revision 1.8  2007/09/24 12:32:35  gzins
* Removed e-mail addresses
*
* Revision 1.7  2007/08/03 21:59:24  gzins
* Fixed cross-references between files
*
* Revision 1.6  2007/08/01 13:58:45  gluck
* Re-added version parsing to get return value when the function is called as a function (and not as a procedure)
*
* Revision 1.5  2007/08/01 08:48:27  gluck
* Deleted package version output since present in documentation block (information was redondant)
*
* Revision 1.4  2007/07/31 14:28:34  gluck
* Integrated log service
*
* Revision 1.3  2007/06/09 19:15:55  gzins
* Fixed minor bugs introduced by documentation generator
*
* Revision 1.2  2007/06/09 19:00:34  gzins
* Update documentatiopn formatting
*
* Revision 1.1  2007/06/09 16:48:26  jblebou
* Create the 'yocoType' file.
*
*/
func yocoType(void)
/* DOCUMENT yocoType(void)

   DESCRIPTION
     Checking type and conformabilities tools.
      
   VERSION
     $Revision: 1.12 $
 
   FUNCTIONS
     - yocoTypeIsFile            : Is this variable a file stream or a 
                                   directory ?
     - yocoTypeIsScalar          : Is this variable a scalar ?
     - yocoTypeIsInteger         : Is this variable a long/int ?
     - yocoTypeIsIntegerScalar   : Is this variable a long/int scalar ?
     - yocoTypeIsReal            : Is this variable a double/float ?
     - yocoTypeIsRealScalar      : Is this variable a double/float scalar ?
     - yocoTypeIsNumerical       : Is this variable a number ?
     - yocoTypeIsNumericalScalar : Is this variable a numerical scalar ?
     - yocoTypeIsString          : Is this variable a string ?
     - yocoTypeIsStringScalar    : Is this variable a single string ?
     
   SEE ALSO
     yoco
*/
{
    version = strpart(strtok("$Revision: 1.12 $",":")(2),2:-2);
    if(am_subroutine())
    {
        help, yocoType;
    }   
    return version;
} 

/* ************************************* */
func yocoTypeIsScalar(x)
/* DOCUMENT yocoTypeIsScalar(x)

   DESCRIPTION
     Returns true if X is a scalar.
*/
{ 
    return (is_array(x) && ! dimsof(x)(1)); 
}

/* ************************************* */
func yocoTypeIsInteger(x)
/* DOCUMENT yocoTypeIsInteger(x)

   DESCRIPTION
     Returns true if array X is of integer type.
     (i.e. long, int, char, short)
*/
{
    local s;
    return ((s=structof(x)) == long || s == int || s == char || s == short);
}

/* ************************************* */
func yocoTypeIsIntegerScalar(x)
/* DOCUMENT yocoTypeIsIntegerScalar(x)

   DESCRIPTION
     Returns true if array X is a scalar of integer type.
*/
{
    local s;
    return (((s=structof(x)) == long || s == int || s == char || s == short) &&
            ! dimsof(x)(1));
}

/* ************************************* */

func yocoTypeIsReal(x)
/* DOCUMENT yocoTypeIsReal(x)

   DESCRIPTION
     Returns true if array X is of real type.
     (i.e. float or double)
*/
{
    local s;
    return ((s=structof(x)) == float || s == double);
}

/* ************************************* */
func yocoTypeIsRealScalar(x)
/* DOCUMENT yocoTypeIsRealScalar(x)

   DESCRIPTION
     Returns true if array X is of real type
     (i.e. double or float).
*/  
{
    local s;
    return (((s=structof(x)) == double || s == float) && ! dimsof(x)(1));
}

/* ************************************* */
func yocoTypeIsNumerical(x, cpx)
/* DOCUMENT yocoTypeIsNumerical(x, cpx)

   DESCRIPTION
     Returns true if array X is of numerical type
     (i.e. int, long, short, double or float).
     If cpx is true (non-nil and non-zero), then complex
     is also accepted as numerical type.
*/  
{
    local s;
    return (((s=structof(x)) == double || s == float ||
             s == int || s == long || s == short ||
             (s == complex)*anyof(cpx)) );
}

/* ************************************* */
func yocoTypeIsNumericalScalar(x, cpx)
/* DOCUMENT yocoTypeIsNumericalScalar(x, cpx)

   DESCRIPTION
     Returns true if X is scalar of numerical type
     (i.e. int, long, short, double or float).
     If cpx is true (non-nil and non-zero), then complex
     is also accepted as numerical type.
*/  
{
    local s;
    return ( yocoTypeIsNumerical(x, cpx) && ! dimsof(x)(1) );
}

/* ************************************* */
func yocoTypeIsString(x)
/* DOCUMENT yocoTypeIsString(x)

   DESCRIPTION
     Returns true if array X is of string type.
*/
{
    return (structof(x) == string);
}

/* ************************************* */
func yocoTypeIsStringScalar(x)
/* DOCUMENT yocoTypeIsStringScalar(x)

   DESCRIPTION
     Returns true if array X is a scalar of string type.
*/
{
    return (structof(x) == string && ! dimsof(x)(1)); 
}

/* ************************************* */
func yocoTypeIsFile(name, restrict)
/* DOCUMENT yocoTypeIsFile(name, restrict)

   DESCRIPTION
     Return an array of int of the same dimension of name.

   PARAMETERS
     - name: name to be tested
     - restrict (optional):
       If not given (or 0) :
        - 1 if name is an existing file
        - 2 if name is an existing directory
        - 0 else
       If set to 1, speed up the search by avoiding a directory listing:
        - 1 if name is an existing file or directory
        - 0 else
        
   EXAMPLES
     > yocoTypeIsFile("~/");
     2
     > yocoTypeIsFile("~/",1);
     1
     > yocoTypeIsFile( ["./","test","/home","~/.emacs"] );
     [2,0,0,1]
*/
{
    local type, i, flag;

    type = array(int,dimsof(name));

    for(i=1;i<=numberof(name);i++) {
        /* test is file exist */
        if(open(name(i),"r",1)) type(i) += 1;
        /* add 1 if name is a directory */
        if(type(i)==1 & !restrict) {
            flag = lsdir(name(i));
            if(!(dimsof(flag)(1)==0 && flag==0))  type(i) += 1;
        }
    }
    return type;
}
