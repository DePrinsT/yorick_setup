/*******************************************************************************
* PIONIER Data Reduction Software
*/

func pndrsBrowser(void)
/* DOCUMENT pndrsBrowser(void)

   USER ORIENTED FUNCTIONS:
   - pndrsFileChooser
   
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.8 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsBrowser;
    }   
    return version;
}


/*
 * Rules/Actions associated with new buttons
 */

func _pndrsBrowserButtonActionCreateLogFile(&dir, &files)
/* DOCUMENT _pndrsBrowserButtonActionCreateLogFile(&dir, &files)

       DESCRIPTION
       ** Private function for 'pndrsFileChooserNew' **

       Button-function that create the log file for the current directory, by
       calling 'pndrsCreateLog'. Current directory is then re-ploted to take
       into account the change (Log info is now available).
*/
{
    /* Create the LogFile and then replot everything */
    pndrsReadLog, get_cwd(), overwrite=1;
    yocoGuiBrowserUpdate, dir, files;
}

func _pndrsBrowserButtonActionRemoveLogFile(&dir, &files)
/* DOCUMENT _pndrsBrowserButtonActionRemoveLogFile(&dir, &files)

       DESCRIPTION
       ** Private function for 'pndrsFileChooserNew' **

       Button-function that removes the log file of the current directory,
       as given by function 'pndrsGetLogName'. Current directory is then
       re-ploted to take into account the change (Log info not available
       anymore).
*/
{
    /* Remove the LogFile and then replot everything */
    local logName;
    pndrsGetLogName, ".", logName;
    remove, logName;
    yocoGuiBrowserUpdate, dir, files;
}

func _pndrsBrowserButtonActionRemoveFile(&dir, &files)
/* DOCUMENT _pndrsBrowserButtonActionRemoveFile(&dir, &files)

       DESCRIPTION
       ** Private function for 'pndrsFileChooserNew' **

       Button-function that removes the selected file of the current directory,
       Current directory is then re-ploted to take into account the change
       (Log info not available anymore).
*/
{
    /* Remove the LogFile and then replot everything */

    local id, i;

    /* Found the name of the selected files */
    id = where(files.isSel);

    /* If none are select, just exit */
    if ( !is_array(id) )
        return;

    // Before doing anythin, prompt the user to confirm suppression
    result = yocoGuiInfoBox( "!!!!!!!!!!!!!!!!!\n"+
                             "!!! ATTENTION !!!\n"+
                             "!!!!!!!!!!!!!!!!!\n\n"+
                             "Are you sure you want"+
                             " to remove the selected files?",
                             butText=["YES!","NO!"],
                             butReturn=[1,0], win=7);
    if(result==0)
        return;
    
    /* Loop on file name and remove them */
    for ( i=1 ; i<=numberof(id) ; i++)
    {
        if ( files(id(i)).isDir )
            rmdir,  files(id(i)).name;
        else
            remove, files(id(i)).name;
    }

    /* Recompute new log and */
    yocoGuiBrowserUpdate, dir, files;
}

func _pndrsBrowserButtonActionHideNoFitsFiles(&dir, &files)
/* DOCUMENT _pndrsBrowserButtonActionHideNoFitsFiles(&dir, &files)

       DESCRIPTION
       ** Private function for 'pndrsFileChooserNew' **

       Button-function associated with rule 'pndrsBrowserRuleHideNoFitsFiles'.
       Button color changes if rule is (des)activated.
*/
{
    yocoLogTrace, "_pndrsBrowserButtonActionHideNoFitsFiles()";
  
    /* Get the id of the button */
    local butId;
    butId = where( dir.but.action == "_pndrsBrowserButtonActionHideNoFitsFiles")(1);
  
    /* Change the button status and add/remove the
       corresponding rule accordingly */
    if ( dir.but(butId).color==0.95 ) {
        dir.but(butId).color = 0.5;
        yocoGuiBrowserRulesManager, dir, "_pndrsBrowserRuleHideNoFitsFiles", +1;
    }
    else {
        dir.but(butId).color = 0.95;
        yocoGuiBrowserRulesManager, dir, "_pndrsBrowserRuleHideNoFitsFiles", -1;
    }

    /* If called before the files structure is ready */
    if (is_void(files)) return 1;

    /* Reread the current dir, to apply the rules
       and replot all */
    yocoGuiBrowserUpdate, dir, files;

    yocoLogTrace, "_pndrsBrowserButtonActionHideNoFitsFiles done";
    return 1;
}

func _pndrsBrowserRuleHideNoFitsFiles(&files)
/* DOCUMENT _pndrsBrowserRuleHideNoFitsFiles(&files)

   DESCRIPTION
   ** Private function for 'pndrsFileChooserNew' **

   Rule-function to remove non-FITS files from the input file list
   (files.name non matching .fits).
*/
{
    /* Hide all files not matching ".fits" */
    local tbk;
    tbk = where( strmatch(files.name,".fits") + files.isDir );
    files = files(tbk);
}

func _pndrsBrowserRulePionierInfo(&files)
/* DOCUMENT _pndrsBrowserRulePionierInfo(&files)

   DESCRIPTION
   ** Private function for 'pndrsFileChooserNew' **

   Rule-function used to fill the files.info string by reading the PIONIER
   log. If not present, just skip (no info). The files.info contains a
   short and reformated summary of the LOG content.
*/
{
    local logFile, oiLog;
    local dit, ndit, shutter, win;
  
    /* Found the default logFile name of the current dir */
    pndrsGetLogName,get_cwd(),logFile;

    /* If no log present or error while reading the log... just skip */
    if ( !yocoTypeIsFile(logFile) || !pndrsReadLog(get_cwd(), oiLog) ) {
        yocoLogTest,"logFile not found (skip info): ", logFile;
        return 0;
    }

    /* Construct the shutter info */
    win     = pndrsGetWindows(,oiLog);
    shutter = swrite(format="%i%i%i%i",oiLog.shut1,oiLog.shut2,oiLog.shut3,oiLog.shut4);
    det     = swrite(format="%s:%ix%i",oiLog.detMode,oiLog.detNspx,oiLog.detNdreads);
    date    = oiLog.dateObs;
    

    /* Shorten the displayed struing */
    det  = yocoStrReplace(det,["FOWLER","DOUBLE","SIMPLE"],["FWL","DBL","SPL"]);
    date = yocoStrReplace(date,["2010","2011","2012"],["10","11","12"]);
    
    /* Construct the info lines */
    InfoStr = swrite(format=
                     "%-"+pr1(max(strlen(date)))+"s  "+
                     "%-"+pr1(max(strlen(oiLog.insMode)))+"s  "+
                     "%-"+pr1(max(strlen(win)))+"s  "+
                     "%-"+pr1(max(strlen(det)))+"s  "+
                     "%-"+pr1(max(strlen(shutter)))+"s  "+
                     "%-"+pr1(max(strlen(oiLog.target)))+"s  ",
                     date, oiLog.insMode, win, det, shutter, oiLog.target);

    /* Fill the structure */
    InfoStr = grow("",InfoStr);
    pos = yocoListId(files.name,oiLog.fileName)+1;
    files.info = InfoStr(pos);

}

func _pndrsBrowserRuleSortForPionier(&files)
/* DOCUMENT _pndrsBrowserRuleSortForPionier(&files)

   DESCRIPTION
   ** Private function for 'amdlibFileChooserNew' **

   Rule-function used to sort the files according to criteria
   - is it a file (!files.isDir)
   - fitsdate     (files.info, this should have been filled before)
   - file name    (files.name)
*/
{
    /* Sort by isDir, info (so complete FITS date), name */
    files = files(msort( !files.isDir, files.info, files.name) );
}

func _pndrsBrowserRulePionierColor(&files)
/* DOCUMENT _pndrsBrowserRulePionierColor(&files)

   DESCRIPTION
   ** Private function for 'pndrsFileChooserNew' **
   
   Rule-function used to fill the files.color parameter by reading the PIONIER
   log if present... otherwise just skip (no info). The colors will be
   associated to each types depending on preferences.
*/
{
  local col, types;
    
  /* Define the colors */
  types = 1 +
    1*strmatch(files.info, " 1111 ") +
    2*strmatch(files.info, " 1000 ") + 
    2*strmatch(files.info, " 0100 ") +
    2*strmatch(files.info, " 0010 ") + 
    2*strmatch(files.info, " 0001 ") +
    3*strmatch(files.info, " 0000 ");
    
  col = [[0,0,0], [0,200,0], [200,100,0], [200,0,0]];

  files.color = col(,types);
}


/*
 * Customized init for pndrsBrowser
 */

func _pndrsBrowserInit(&dir, title)
/* DOCUMENT _pndrsBrowserInit(&dir, title)

   DESCRIPTION
   ** Private function for 'pndrsFileChooserNew' **
  
   Function to be passed to yocoGuiBrowser in order to customize the
   appearance and active buttons of the browser window:
   - change the display size, define the window title...
   - configure new buttons: 'PionierOnly', 'FitsOnly', 'ComputeLog'...
   - expand the help to this new buttons
   - add some default rules for hiding and sorting files.

   PARAMETERS
   - dir  : scalar string, see 'pndrsFileChooserNew'.
   - title: scalar string, will be used as title in the browser window.

   EXAMPLES
   See 'pndrsFileChooserNew'.
   
   SEE ALSO
   pndrsFileChooserNew
*/
{
    yocoLogTrace,"_pndrsBrowserInit()";
  
    local buts;
    extern __pndrsBrowserTitle;

    /* Change the display size */
    dir.vDis(0) = 0.73;
    dir.vBar(0) = 0.73;

    /* Define the title */
    dir.title = string(title)+"";

    /* Configuring new buttons, similar than the default ones
       expect for the positioning */

    buts = array(yocoBROWSER_BUTTONS, 4);
    buts(*)  = dir.but(1);
    buts.dx *= 1.5;
    buts.y   = dir.but.y(1) - 3*dir.but.dy(1);
    buts.x(1:4)  = span(dir.vDis(1)+0.1, dir.vBar(1)-0.1, 4); 

    /* Button's names  and associated action */
    buts.text   = ["Remove file","FITS Only","Compute Log","Remove Log"];
    buts.action = ["_pndrsBrowserButtonActionRemoveFile",
                   "_pndrsBrowserButtonActionHideNoFitsFiles",
                   "_pndrsBrowserButtonActionCreateLogFile",
                   "_pndrsBrowserButtonActionRemoveLogFile"];
  
    /* Add them to the configuration */
    dir.but(dir.nbBut+1:dir.nbBut+4) = buts;
    dir.nbBut += 4;
  
    /* Add some PIONIER rules for sorting and info */
    yocoGuiBrowserRulesManager, dir, "_pndrsBrowserRulePionierInfo", +1;
    yocoGuiBrowserRulesManager, dir, "_pndrsBrowserRuleSortForPionier", +1;
    yocoGuiBrowserRulesManager, dir, "_pndrsBrowserRulePionierColor", +1;

    /* Add the help */
    dir.help = dir.help + "\n" +
        "- Compute Log  -> (re)compute the PIONIER log for current dir,\n" +
        "                  to display more info on PIONIER files\n" +
        "- Remove Log   -> remove the log file if any\n";

    yocoLogTrace,"_pndrsBrowserInit done";
}

/* ========================================== */

func pndrsFileChooser(text, &fileName, directory=)
/* DOCUMENT pndrsFileChooser(text, &fileName, directory=)

   DESCRIPTION
   Display a graphical file browser customized for PIONIER data files; i.e. it
   colorized files according to their type (P2VM, dark, observation, etc).
   
   PARAMETERS
   - text     : text written on the console and as a title of the graphical
   window
   - fileName : list of the selected files/directories. 
   - directory: directory to be displayed first. If no one is specified, 
   default directory is the current one.
   a scalar string.
                    
   RETURN VALUES
   String containing the name of the directory/file chosen.
   
   EXAMPLES
   Look for a file in "/home/" directory.
   
   > pndrsFileChooser("Choose a file", fileName, directory="/home/")
   
   SEE ALSO
   yocoGuiFileChooser
*/
{
    local win, dpi, file;
    yocoLogTrace,"pndrsFileChooser()";

    /* Some default */
    if ( is_void(win) ) win=0;
     
    /* Some verbose */
    yocoLogTest,"Parameter directoy is:",directory;

    /* call the browser */
    fileName = yocoGuiBrowser(directory, win, 75, _pndrsBrowserInit, text);
  
    yocoLogTrace,"pndrsFileChooser done";
    return 1;
}
