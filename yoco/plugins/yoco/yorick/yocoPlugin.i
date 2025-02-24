local package_yocoPlugin;
/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Simple wrapper of yoco C-functions for Yorick.
 *
 * "@(#) $Id: yocoPlugin.i,v 1.4 2010-05-21 11:27:17 lebouquj Exp $"
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.3  2007/11/15 11:54:17  gzins
 * Added yocoErrorGet
 *
 * Revision 1.2  2007/11/14 11:12:17  gzins
 * Added yocoError
 *
 * Revision 1.1  2007/09/11 10:07:18  gzins
 * Added
 *
 */

func yocoPlugin(void)
/* DOCUMENT yocoPlugin(void)

  DESCRIPTION
    Collection of useful wrapped C-fonctions

  VERSION
    $Revision: 1.4 $

  CAUTIONS

  AUTHORS
    - Jean-Baptiste Le Bouquin
    - Gerard Zins

  FUNCTIONS
    - yocoSystem   : execute the specified command specified
*/
{
    version = strpart(strtok("$Revision: 1.4 $",":")(2),2:-2);
    if (am_subroutine())
    {
        write, format="package version: %s\n", version;
        help, yocoPlugin;
    }   
    return version;
} 

#include "yocoPluginWrapper.i"

func yocoSystem(command)
/* DOCUMENT yocoSystem(command)
  
  DESCRIPTION
    Executes the specified command by calling system function, and returns after
    the command has been completed.
  
  PARAMETERS
    - command : shell-command 
  
  RETURN VALUES
    Completion status of the executed command
  
  EXAMPLE
    > ret = yocoSystem("ls");
    > if (ret != 0) ...
  SEE ALSO
    yoco
 */
{
    return __yocoSystem(command);
}

  
