/*******************************************************************************
 *
 * "@(#) $Id: yocoSystem.c,v 1.3 2007-11-22 06:39:21 gzins Exp $"
 *
 * Author :
 *   - Gerard Zins
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2007/09/11 10:03:54  gzins
 * Added
 *
 *----------------------------------------------------------------------------*/

/**
 * @file
 * C-function to execute shell command
 */

/*
 * System header
 */

/*
 * Local header
 */
#include "yocoPlugin.h"

/**
 * Execute 
 *
 * @param command shell-command to be executed
 */
int yocoSystem(char *command)
{
  return (p_system(command));
}
