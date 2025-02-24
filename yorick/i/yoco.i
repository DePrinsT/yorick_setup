/******************************************************************************
 * LAOG project - Yorick Contribution package
 *
 * "@(#) $Id: yoco.i,v 1.19 2011-02-10 10:56:21 mella Exp $"
 *
 ******************************************************************************/

func yoco(void)
/* DOCUMENT yoco

   DESCRIPTION
   Yorick useful tools from IPAG-Yorick contribution project. These tools are
   organized in the following packages :
     - yocoDoc   : Documentation tools
     - yocoFile  : Files manipulation tools
     - yocoStr   : String manipulation tools
     - yocoMath  : Mathematics tools
     - yocoPlot  : Graphical tools
     - yocoNm    : Create and handle ploting windows with several Gist systems
     - yocoAstro : (astro)physical constants in several unit systems,
                   as well as Mendellev table, blackBody functions...
     - yocoType  : Checking types of Yorick variables
     - yocoLog   : Logging facilities
     - yocoList  : Simple tools to handle list (defined as 1D array)
     - yocoGui   : Graphical User Interface tools
     - yocoError : Tool to deal with yorick errors

   VERSION
     $Revision: 1.19 $

   AUTHORS
     - Florentin Millour
     - Jean-Baptiste Le Bouquin
     - Jean-Philippe Berger
     - Laurence Gluck
     - Gerard Zins

   SEE ALSO
     yocoFile, yocoStr, yocoMath, yocoPlot, yocoNm, yocoAstro, yocoType,
     yocoLog, yocoList, yocoGui, yocoError

   CONTRIBUTIONS
     If you want to contribute with any new file related function, just append
     it to the end of file, and add it to the following function list.
*/
{
    version = strpart(strtok("$Revision: 1.19 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yoco;
    }
    return version;
}

#include "yocoType.i"
#include "yocoLog.i"
#include "yocoStr.i"
#include "yocoDoc.i"
#include "yocoFile.i"
#include "yocoGui.i"
#include "yocoPlot.i"
#include "yocoMath.i"
#include "yocoNm.i"
#include "yocoAstro.i"
#include "yocoList.i"
#include "yocoError.i"
#include "yocoCds.i"

yocoLogInfo, "yoco - IPAG Yorick Contributions";
yocoLogInfo, "yoco package loaded";

