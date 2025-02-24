/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * String manipulation tools
 *
 * "@(#) $Id: yocoStr.i,v 1.21 2008-09-15 12:27:48 fmillour Exp $"
 *
 ******************************************************************************/

func yocoStr(void)
/* DOCUMENT yocoStr

   DESCRIPTION
     String manipulation tools from LAOG-Yorick contribution project.
     
   VERSION
     $Revision: 1.21 $

   CAUTIONS
     This package is only necessary if you use older versions of yorick (<2.0).
     Otherwise you have nice string manipulation tools included in newer yorick
     versions

   FUNCTIONS
   - yocoStr              : 
   - yocoStr2Double       : Converts string into double
   - yocoStr2Long         : Converts string into long integer
   - yocoStrAngle         : Numerical <-> string converion for angles 
   - yocoStrChr           : 
   - yocoStrDefault       : 
   - yocoStrLead          : 
   - yocoStrRemoveMultiple: 
   - yocoStrReplace       : 
   - yocoStrRev           : 
   - yocoStrRevChr        : 
   - yocoStrSplit         : 
   - yocoStrSub           : 
   - yocoStrTime          : 
   - yocoStrTrail         : 
   - yocoStrTrim          : 
   - yocoStrVal           : 
   - yocoStrrtok          : 
   
     Use only if yorick version<2.0:
     - yocoStrChr            : Converts string into character array
     - yocoStrDefault        : Sets the defaults for string operations.
     - yocoStrLead           : Removes leading spaces
     - yocoStrRemoveMultiple : Remove multiple elements from a strong array
     - yocoStrRev            : Reverses a string
     - yocoStrRevChr         : Converts a character array into strings 
     - yocoStrSplit          : Splits a string
     - yocoStrSub            : Gets substrings from list of strings
     - yocoStrTrail          : Removes trailing spaces
     - yocoStrTrim           : Trims leading and trailing spaces
     - yocoStrVal            : Gets the Nth character number of a string
     - yocoStrrtok           : Splits a string in two parts using reverse strtok
     - yocoStrReplace        : Replace search strings within a string with
                               replacement string

   SEE ALSO
     yoco
*/
{
    version = strpart(strtok("$Revision: 1.21 $",":")(2),2:-2);
    if(am_subroutine())
    {
        help, yocoStr;
    }   
    return version;
} 

/***************************************************************************/

func yocoStr2Long(str)
/* DOCUMENT yocoStr2Long(str)
     
   DESCRIPTION
     Convert a string into a long integer.

   PARAMETERS
   - str: the string to be converted

   RETURN VALUES
     The converted long integer value.

   CAUTIONS
     If the string has anything other than numbers, then the returned value
     will be systematically 0

   EXAMPLES
     > yocoStr2Long("234")
     234
     > yocoStr2Long(["234","-12"])
     [234,-12]

   SEE ALSO 
     yocoStr2double, yocoStr
*/
{
    if (numberof(str) == 1)
    {
        i = 0;
    }
    else
    {
        i = array(0, dimsof(str));
    }
    sread, str, i;
    if(anyof(i==0))
    {
        w = where(i==0);
        for(k=1;k<=numberof(w);k++)
            sread, str(w(k)), i(w(k));
    }
    return i;
} 

/***************************************************************************/

func yocoStr2Double(str)
/* DOCUMENT yocoStr2Double(str)
  
   DESCRIPTION
     Convert a string into a double.

   PARAMETERS
   - str: the string to be converted

   RETURN VALUES
     The converted double value.

   CAUTIONS
     If the string has anything other than numbers, then the returned value
     will be systematically 0

   EXAMPLES
     > yocoStr2Double("1.23")
     1.23
     > yocoStr2Double(["1.23","-1"])
     [1.23,-1.0]

   SEE ALSO
     yocoStr2Long, yocoStr
*/
{
    if (numberof(str)==1)
    {
        a = 0.0;
    }
    else
    {
        a = array(0.0, dimsof(str));
    }
    sread, str, a;
    if(anyof(a==0))
    {
        w = where(a==0);
        for(k=1;k<=numberof(w);k++)
            sread, str(w(k)), a(w(k));
    }
    return a;
}    

/***************************************************************************/

func yocoStrTrail(str)
/* DOCUMENT yocoStrTrail(str)

   DESCRIPTION
     Removes trailing spaces (character 0x20) from scalar string str.
    
   PARAMETERS
   - str: the string to be trimmed

   RETURN VALUES
     The trimmed string.

   CAUTIONS
     Prefer the compiled function 'strtrim' (yorick version >2.0). 

   EXAMPLES
     > yocoStrTrail("  This a text   ")
     "  This a text"

   SEE ALSO
     yocoStrLead, yocoStr
*/
{
    if (!(i = numberof((c = *pointer(str)))))
    {
        return string(0);
    }

    if(str == "")
    {
        return str;
    }
    
    while (--i)
    {
        { 
            if (c(i) != ' ') 
            {
                return string(&c(1:i));
            }
        }
    }
        
    return "";
}

/***************************************************************************/

func yocoStrLead(str)
/* DOCUMENT yocoStrLead(str)

   DESCRIPTION
     Removes leading spaces (character 0x20) from scalar string str.
    
   PARAMETERS
   - str: the string to be trimmed

   RETURN VALUES
     The trimmed string.

   CAUTIONS
     Prefer the compiled function 'strtrim' (yorick version >2.0). 

   EXAMPLES
     > yocoStrLead("  This a text   ")
     "This a text   "

   SEE ALSO
     yocoStrTrail
*/
{
    c = *pointer(str);
    if(is_void(c))
    {
        return str;
    }
    if(is_array((l = where(c != ' '))))
    {
        return string(&c(l(1):0));
    }
    else
    {
        return str;
    }
}

/***************************************************************************/

func yocoStrTrim(strList, blank=, left=, right=)
/* DOCUMENT yocoStrTrim(strList, blank=, left=, right=)

   DESCRIPTION
     Trims leading and trailing spaces of strings contained in the given list.

   PARAMETERS
   - strList: list of strings to be trimmed
   - blank  : a string specifying the white spaces to consider 
                 (default: " \t")
   - left   : whether leading spaces are to be trimmed (default: 1)
   - right  : whether trailing spaces are to be trimmed (default: 1)
     
     These defaults can be modified via yocoStrDefault.

   CAUTIONS
     Prefer the compiled function 'strtrim' (yorick version >2.0). 

   EXAMPLES
     Trim trailing spaces
   
     > yocoStrTrim("  This a text   ", left=0)
     "This a text   "

     Trim trailing and leading space and '!' characters
     
     > yocoStrTrim(["  This a text  !!", "  This another text!"], blank=" !")
     ["This a text","This another text"]

   SEE ALSO 
     yocoStrDefault, yocoStrTrail, yocoStrLead, yocoStr
*/
{
    local subStr, len, jr, jl;

    /* load defaults */
    blank = is_void(blank)? _yocoStrBlank: yocoStrChr(blank)(1:-1);
    if (is_void(left))
    {
        left  = _yocoStrLeft;
    }
    if (is_void(right))
    {
        right = _yocoStrRight;
    }

    /* array loop */    
    subStr = array(string(""), dimsof(strList));
    for (i = 1; i <= numberof(strList); ++i)
    {
        str = strList(i);
        if ((len = strlen(str)) == 0)
        {
            continue;
        }

        nonSpace=where((yocoStrChr(str)(1:-1)
                        (-:1:numberof(blank),) == blank)(sum,) == 0);

        if (numberof(nonSpace) == 0) 
        {
            continue;
        }

        jLeft = left?  min(nonSpace): 1;
        jRight = right? max(nonSpace): len;

        subStr(i) = strpart(str, jLeft:jRight);
    }

    return subStr;
}

/***************************************************************************/

func yocoStrDefault(blank=, right=, left=)
/* DOCUMENT yocoStrDefault(blank=, right=, left=)

   DESCRIPTION
     Set the defaults for string operations.
  
   PARAMETERS
   - blank: a string specifying the caracteres to be considered
               as white spaces (default is blanck and tab: " \t")
   - right: whether trailing spaces are to be trimmed (default: 1)
   - left : whether leading spaces are to be trimmed (default: 1)

   SEE ALSO 
     yocoStrTrim, yocoStr
*/
{
    extern _yocoStrBlank, _yocoStrRight, _yocoStrLeft;

    if (!is_void(blank))
    {
        _yocoStrBlank = (*pointer(blank))(1:-1);
    }
    if (!is_void(right))
    {
        _yocoStrRight = right;
    }
    if (!is_void(left))  
    {
        _yocoStrLeft  = left;
    }
}

yocoStrDefault, blank=" \t", right=1, left=1;

/***************************************************************************/

func yocoStrSplit(str, delimiter, multDel=)
/* DOCUMENT yocoStrSplit(str, delimiter, multDel=)

   DESCRIPTION
     Splits a string and output the string parts in a new array deleting the
     'delimiter' strings.

   PARAMETERS
   - str      : the array to split
   - delimiter: delimiter string to erase
   - multDel  : OPTIONAL when set to 1 if empty splitted
                   strings are removed

   RETURN VALUES
     String array containing splitted strings

   CAUTIONS
     Prefer the compiled functions 'strword' 'strfind'...
     (yorick version >2.0). 

   EXAMPLES
     Split string "INS_autoCAL_data" considering "auto" as delimiter
     
     > str =  "INS_autoCAL_data"
     > yocoStrSplit(str, "data")
     ["AMBER_","P2VM_data"]

     Split string "arg1,arg2,,arg4" considering "," as delimiter;
     3rd empty splitted string is deleted.
     
     > str =  "arg1,arg2,,arg4"
     > yocoStrSplit(str, ",", multDel=1)
     ["arg1","arg2","arg4"]

   SEE ALSO
     yocoStr
*/
{
    splittedStr = [];
    delLen      = strlen(delimiter);
    strLen      = strlen(str);
    delPos      = [];                   /* Delimiter position */

    /* Look for delimiters */
    for (i = 1; i <= (strLen - delLen + 1); i++)
    {
        subStr = strpart(str, i:i + delLen - 1);
        if (subStr == "")
        {
            subStr = string(nil);
        }
        if (strmatch(delimiter, subStr))
        {
            grow, delPos, i;
            i += delLen - 1;
        }
    }

    /* If found */
    if (!is_void(delPos))
    {
        grow, splittedStr, strpart(str, 1:delPos(1)-1);

        for (j = 1; j <= numberof(delPos)-1; j++)
        {
            grow, splittedStr, 
                strpart(str, delPos(j) + delLen : delPos(j + 1) - 1);
        }

        subStr = strpart(str, delPos(0) + delLen : 0);
        if (subStr == "")
        {
            subStr = string(nil);  
        }
        grow, splittedStr, subStr;

        if (delPos(1) == 1)
        {
            splittedStr = grow(string(nil), splittedStr(2:));
        }
    }
    else
    {
        splittedStr = [str, string(nil)];
    }

    /* Deleted empty splitted string */
    if (multDel == 1)
    {
        splittedStr =  splittedStr(where(splittedStr != ""));
    }

    return splittedStr;
}

/***************************************************************************/

func yocoStrrtok(str, delimiter)
/* DOCUMENT yocoStrrtok(str, delimiter)

   DESCRIPTION 
     strtok splits a string in two parts, the first one containing the
     substring until the first delimiter character has been found, and the
     second part containing the rest of the original string.
     
     yocoStrrtok performs the same kind of statement, whereas the first
     substring is taken until the penultimate delimiter was found.

   PARAMETERS
   - str      : array of strings to split.
   - delimiter: the set of delimiters. By default, it is " \t\n" (blanks,
                   tabs, or newlines)

   RETURN VALUES
     A string array ts with dimension 2-by-dimsof(str); ts(1,) is
     the first token, and ts(2,) is the remainder of the string (the character
     which terminated the first token will be in neither of these parts).

   CAUTIONS
     Prefer the compiled functions 'strword' 'strfind'...
     (yorick version >2.0). 

   EXAMPLES
     > str = ["INS_Mode1_autoCAL", "INS_Mode2_OBS"]
     > yocoStrrtok(str, "_")
     [["INS_Mode1","autoCAL"],["INS_Mode2","OBS"]]

   SEE ALSO
     yocoStrSplit, yocoStr
*/
{
    nbStr = numberof(str);
    splittedStr = array(string, 2, nbStr);

    for (i = 1; i <= nbStr; i++)
    {
        a = str(i);
        stop = 0;
        while (stop == 0)
        {
            aa = strtok(a, delimiter);
            a = aa(2);
            if (a == string(nil))
            {
                stop = 1;
            }
        }
        splittedStr(2,i) = aa(1);

        if (aa(1) != str(i))
        {
            splittedStr(1, i) = 
                strpart(str(i), 1 : strlen(str(i)) - strlen(aa(1)) - 1);
        }
        else
        {
            splittedStr(1, i) = string(nil);
        }
    }
    return splittedStr;
}

/***************************************************************************/

func yocoStrChr(str)
/* DOCUMENT yocoStrChr(str)

   DESCRIPTION 
     Return a character array corresponding to the string str. If str is an
     array, the expansion occurs on the last dimension: if str is of dimension
     d_1 x ... x d_n, chr will be of dimension d_1 x ... x d_n x (l+1),
     where l is the maximum string length in array str.

   PARAMETERS
   - str: array of strings to convert.

   RETURN VALUES
     Array of expanded character arrays
    
   CAUTIONS
     Prefer the compiled functions 'strchar' (yorick version >2.0). 

   EXAMPLES
     > str=["a", "bc"]
     > yocoStrChr(str)
     [[0x61,0x00,0x00],[0x62,0x63,0x00]]

   SEE ALSO
     yocoStrRevChr, yocoStr
*/
{
    local n;

    chr = array(char(0), dimsof(str(-:1:1+max(strlen(str)),..)));
    for (i = 1; i <= numberof(str); ++i) 
    {
        local ch;
        ch = *pointer(str(i));
        chr(,i)(1:numberof(ch)) = ch;
    }

    return chr;
}

/***************************************************************************/

func yocoStrRevChr(chr)
/* DOCUMENT yocoStrRevChr(chr)

   DESCRIPTION 
     Return a string corresponding to the character array chr.  The string
     making is performed on the last dimension of chr; in other words, if chr
     is of dimension d_1 x ... x d_n, then str is of dimension d_1 x ... x
     d_(n-1). The C string format is assumed, so all characters following
     a '\0' are ignored.
   
   PARAMETERS
   - chr: array of characters to convert.

   RETURN VALUES
     Array of converted strings
    
   CAUTIONS
     Prefer the compiled functions 'strchar' (yorick version >2.0). 

   EXAMPLES
     > str=["a", "bc"]
     > chr = yocoStrChr(str)
     > yocoStrRevChr(chr)
     ["a","bc"]
   
   SEE ALSO
     yocoStrChr, yocoStr
*/
{
    local strArray;

    strArray = array(string, dimsof(chr(1,)));
    for (i = 1; i <= numberof(chr(1,)); ++i)
    {
        strArray(i) = string(&chr(,i));
    }

    return strArray;
}

/***************************************************************************/

func yocoStrVal(str, idx)
/* DOCUMENT yocoStrVal(str, idx)

   DESCRIPTION 
     Return the Nth character number of a string. Issues an error if beyond
     boundaries of all strings of array str.

   PARAMETERS
   - str: string.
   - idx: position of character to get

   RETURN VALUES
     Character at position idx 
      
   EXAMPLES
     > str="This is a string"
     > yocoStrVal(str, 2)
     0x68

   SEE ALSO
     yocoStr
*/
{

    return yocoStrChr(str)(idx,);
   
}

/***************************************************************************/

func yocoStrSub(str, idx)
/* DOCUMENT yocoStrSub(str, idx)

   DESCRIPTION
     Take a substring or a permutated substring from string
     The difference with strpart is
        i)  you cannot go beyond boundaries
        ii) but you are allowed to mix up characters
   
   PARAMETERS
   - str: input string
   - idx: a range or an array describing which elements to take from the
             string
  
   RETURN VALUES
     Sub-strings array

   CAUTIONS
     Prefer the compiled functions 'strchar' 'strfind' 'strgrep'...
     (yorick version >2.0). 

   EXAMPLES
     > yocoStrSub("Hello, world!", [0,5])
     "le"
     > yocoStrSub("Hello, world!", -1:8:-1)
     "!dlrow"

   SEE ALSO
     yocoStrRev, yocoStrVal, yocoStrRevChr, yocoStrChr, yocoStr
*/
{
    local ss;

    ss = array(string, dimsof(str));
    for (i = 1; i <= numberof(str); ++i)
    {
        ss(i) = strlen(str(i)) == 0? "": yocoStrRevChr(yocoStrChr(str(i))(idx));
    }
    return ss;

}

/***************************************************************************/
func yocoStrRev(str)
/* DOCUMENT yocoStrRev(str)

   DESCRIPTION 
     Return the reversed string

   PARAMETERS
   - str: string to reverse

   CAUTIONS
     Prefer the compiled functions 'strchar' 'strfind' 'strgrep'...
     (yorick version >2.0). 

   EXAMPLES
     > yocoStrRev("Hello, world!")
     "!dlrow ,olleH"

   SEE ALSO
     yocoStrSub, yocoStr
*/
{
    return yocoStrSub(str, -1:1:-1);   
}

/***************************************************************************/

func yocoStrReplace(str, oldSubstr, newSubstr)
/* DOCUMENT yocoStrReplace(str, oldSubstr, newSubstr)

   DESCRIPTION 
     Replaces any occurrences of search strings within a string with
     replacement string. Note that both oldSubstr and newSubstr can
     be arrays to allow mulitple replacements.

   PARAMETERS
   - str      : input string
   - oldSubstr: substring to replace. By default, it is set to "_"
   - newSubstr: new substring. By default "!_"
   
   RETURN VALUES
     The string after replacement
   
   EXAMPLES
     Change "bad" with "good"

     > str = "This is a bad example"
     > yocoStrReplace(str, "bad", "good")
     "This is a good example"
     
     Replace all "_" by "!_", and remove  all "#" and blancks

     > str = "# name_with_underscore #"
     > yocoStrReplace(str, [" ","_","#"], ["", "!_",""])
     "name!_with!_underscore"

   SEE ALSO
     yocoStrSplit, yocoStr
*/
{
    copyOfStr = str;

    if (is_void(oldSubstr))
    {
        oldSubstr = ["_"];
    }
    if (is_void(newSubstr))
    {
        newSubstr = ["!_"];
    }

    N = numberof(str);
    K = numberof(oldSubstr);
    for (k = 1; k <= K; k++)
    {
        newStr = [];
        for (j = 1; j <= N; j++)
        {
            /* Split string using 'oldSubstr' as separator */
            subStrList = yocoStrSplit(str(j), oldSubstr(k));

            if ((subStrList(0) == string(nil)) &&
                (strpart(str(j), 1-strlen(oldSubstr(k)) : 0) != oldSubstr(k)))
            {
                subStrList = subStrList(1:-1);
            }

            mergedStr = "";
            /* Merge substrings introducing newSubstr */
            for (i = 1; i <= numberof(subStrList); i++)
            {
                mergedStr = mergedStr + subStrList(i);
                if (i < numberof(subStrList))
                {
                    mergedStr = mergedStr + newSubstr(k);
                }
            }

            grow, newStr, mergedStr;
        }
        if (N == 1)
        {
            newStr = newStr(1);
        }
        if (k < K)
        {
            str = newStr;
        }
    }

    newStr2 = copyOfStr;
    for (i = 1; i <= numberof(newStr); i++)
    {
        newStr2(i) = newStr(i);
    }

    return newStr2;
}

/************************************************************************/

func yocoStrRemoveMultiple(&input, &order)
/* DOCUMENT yocoStrRemoveMultiple(&input, &order)
    - or -  output = yocoStrRemoveMultiple(input);
     
   DESCRIPTION 
     Remove multiple element from the 1D numerical array INPUT. the results
     is store in INPUT (first forme) or return (second forme).
     Cleaned array is ALWAYS a monotonically increasing.

   PARAMETERS:
   - input: input string array, replace by the cleaned array if called
               as a subroutine.
   - order:
     
   EXAMPLES
     > yocoStrRemoveMultiple([9,1,5,1,9,2])
     [1,2,5,9];
     > yocoStrRemoveMultiple([2,2,2])
     2;
     > yocoStrRemoveMultiple()
     [];
*/
{
    local tmp,liste,output;

    if(is_void(input))
        return;

    /* keep the first element */
    newOrder = sort(input);
    tmp = input(newOrder);
    output = order = [];

    /* find new elements */
    while(numberof(tmp)!=0)
    {
        grow,output,tmp(1);
        grow,order,newOrder(1);
        newSort = where(tmp!=tmp(1));
        tmp = tmp(newSort);
        newOrder = newOrder(newSort);
    }

    /* return the results */
    if(am_subroutine())
      input = output;
    else
      return output;
}

/************************************************************************/

func yocoStrTime(time, sep, &hour, &minute, &second)
/* DOCUMENT yocoStrTime(time, sep, &hour, &minute, &second)
             timeStr = yocoStrTime(timeDec, sep, pre)
             yocoStrTime, time, sep, &hour, &minute, &second

   DESCRIPTION
     Conversion from time expressed as a string and time expressed
     as a decimal.

   PARAMETERS   
   - time  : time expression with string format (eg. "hh mm ss", or
   - sep   : 
   - hour  : 
   - minute: 
   - second: 
             "hh:mm:ss" or "hh-mm-ss") or in numerical format
             (eg. 12.0 or 3.25)
              
     - sep:  define the separator (mainly ':' or ' '), default is ' '
             automatic detection normaly find ':'

     - hour, minute, second: numerical values returned in the case
             of translation string->numerical.

     - pre:  number of digit for the precision (below seconds)
             in the string, in case numerical->string.

   EXAMPLES
     > yocoStrTime( ["05:56:38.567","12:00:18.567"] )
     [5.94405,12.0052]
      
     > yocoStrTime( [5.94405,12.0052], "-", 2)
     ["05-56-38.58","12-00-18.72"]
*/
{
    local tt, form;

    /* Get the type */
    tt = typeof(time);

    /* --- Str to Dec --- */
    if (tt == "string" )
    {
        /* Default for sep */
        if(is_void(sep)) {
            if(anyof(strmatch(time,":"))) sep = ":";
            else sep = " ";
        }   
        if(structof(sep)!=string) error,"'sep' should be a string (\" \" or \":\")";

        hour = minute = array(0, dimsof(time));
        second        = array(0.,dimsof(time));

        time = strtrim(time);
        sread, time, format="%2d"+sep+"%2d"+sep+"%f", hour, minute, second;

        return double(hour)+double(minute)/60.+double(second)/3600.;
    }

    /* --- Dec to Str --- */
    if (tt == "double" || tt == "float" || tt == "long" || tt == "int" )
    {
        /* Default for sep and pre */
        pre = hour;
        if(is_void(pre)) pre=0;
        if(is_void(sep)) sep=":";
        if(structof(sep)!=string) error,"'sep' should be a string (\" \" or \":\")";

        time = double(time);
        if(structof(sep)!=string) error,"'sep' should be a string (\" \" or \":\")";

        hour=int(time);
        minute=int((time-hour)*60);
        second=(time-hour)*3600%60;

        form = "%02i"+sep+"%02i"+sep+"%0"+pr1(3+int(pre)-!pre)+"."+pr1(int(pre))+"f";

        return swrite(format=form,hour,minute,second);
    }

    error,"'time' should be numerical or string array.";
}


/************************************************************************/

func yocoStrAngle(angle, sep, &deg, &minute, &second)
/* DOCUMENT yocoStrAngle(angle, sep, &deg, &minute, &second)
             angleStr = yocoStrAngle(angleDec, sep, pre)
             angleStrAngle, angle, sep, &deg, &minute, &second

   DESCRIPTION
     Conversion from angle expressed as a string and angle expressed
     as a decimal in degree.

   PARAMETERS   
   - angle : angle expression with string format: "deg min ss", or
   - sep   : 
   - deg   : 
   - minute: 
   - second: 
            "deg:min:ss" ; or in  numerical format:
            12.0 or -3.25
             
     - sep: define the separator (mainly ":" or " ").
            automatic detection normaly find ":" or " "

     - deg, minute, second: numerical values returned in the case
            of translation string->numerical.

     - pre: number of digit for the precision (below seconds)
            in the string, in case numerical->string.

   EXAMPLES
     > yocoStrAngle( ["45:56:78.567","-00:01:18.567"] )
     [45.9552,-45.0218]

     > yocoStrAngle ( [45.9552,-0.0218242],":",2)
     ["+45:57:18.72","-00:01:18.57"]
*/
{
    local tt, form;

    /* Get the type */
    tt = typeof(angle);

    /* --- Str to Dec --- */
    if (tt == "string" )
    {

        /* Default for pre and sep */
        if(is_void(sep)) {
            if(anyof(strmatch(angle,":"))) sep = ":";
            else sep = " ";
        }
        if(structof(sep)!=string) error,"'sep' should be a string (\" \" or \":\")";

        /* conversion */
        deg = minute = array(0, dimsof(angle));
        second       = array(0.,dimsof(angle));
        angle = strtrim(angle);
        signed = [+1.0,-1.0]( (strpart(angle,1:1)=="-")+1 );
        sread, angle, format="%d"+sep+"%d"+sep+"%f", deg, minute, second;

        return (abs(double(deg))+double(minute)/60.+double(second)/3600. ) * signed;
    }

    /* --- Dec to Str --- */
    if (tt == "double" || tt == "float" || tt == "long" || tt == "int" )
    {

        /* Default for pre and sep */
        pre = deg;
        if(is_void(pre)) pre=0;
        if(is_void(sep)) sep=":";
        if(structof(sep)!=string) error,"'sep' should be a string (\" \" or \":\")";

        /* Conversion */
        angle = double(angle);
        signed = ["+","-"]( (sign(angle)==-1) + 1);
        angle  = abs(angle);
        deg    = int(angle);
        minute = int((angle-abs(deg))*60);
        second = ((angle-abs(deg))*3600) % 60;

        /* format the output */
        form = "%02i"+sep+"%02i"+sep+"%0"+pr1(3+int(pre)-!pre)+"."+pr1(int(pre))+"f";
        return signed + swrite(format=form,deg,minute,second);
    }

    error,"'angle' should be numerical or string array.";
}
