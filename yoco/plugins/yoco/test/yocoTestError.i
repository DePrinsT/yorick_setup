/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Test program for improved error handling
 *
 * "@(#) $Id: yocoTestError.i,v 1.1 2007-11-14 15:05:24 gzins Exp $"
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 */
require,"yoco.i";
require,"yocoPlugin.i";

func myFunction(n, level) 
{
    write, "-- test number: " + pr1(n);
    yocoError, "Error message", "Detail on error", level;
    write, "--";
}

/* Disable error */
yocoErrorSet, 0;
myFunction, 1, 1;
myFunction, 2, 2;

/* Enable error */
yocoErrorSet,1;
myFunction, 3, 1;
myFunction, 4, 2;

