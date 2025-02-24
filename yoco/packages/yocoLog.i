/***************************************************************************** *
 * LAOG project - Yorick Contribution package 
 *
 * Logging facility
 *
 */

/***************************************************************************/

func yocoLog(void)
/* DOCUMENT yocoLog
    
   DESCRIPTION
     Logging service

   VERSION
     $Revision: 1.17 $
    
   FUNCTIONS
   - yocoLog       : 
   - yocoLogError  : Log informations about errors
   - yocoLogGet    : Get the logging service setting
   - yocoLogGetFile: 
   - yocoLogGetHelp: Get the textual tooltip help setting
   - yocoLogHelp   : Log help informations
   - yocoLogInfo   : Log informations about major events
   - yocoLogSet    : Configure the logging service
   - yocoLogSetFile: 
   - yocoLogSetHelp: Enable/disable textual tooltip help
   - yocoLogTest   : Log relevant informations used for software test
                        activities
   - yocoLogTrace  : Log function/procedure trace
   - yocoLogWarning: Log informations about abnormal events

   SEE ALSO
     yoco
*/
{
    version = strpart(strtok("$Revision: 1.17 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoLog;
    }   
    return version;
}

/***************************************************************************/
/*
 * Logging level constants
 */
yocoLOG_ERROR    = int(-1);
yocoLOG_QUIET    = int(0);
yocoLOG_WARNING  = int(1);
yocoLOG_INFO     = int(2);
yocoLOG_TEST     = int(3);
yocoLOG_TRACE    = int(4);

/*
 * Default log level
 */
extern _yocoLogEnabled;
extern _yocoLogLevel;
extern _yocoLogHelpEnabled;
_yocoLogLevel       = yocoLOG_INFO;
_yocoLogEnabled     = 1;
_yocoLogHelpEnabled = 1;

/*
 * File name of the optional log file.
 */
extern _yocoLogFileStream;

/***************************************************************************/

func yocoLogError(msg, detail, level)
/* DOCUMENT yocoLogError(msg, detail)
            yocoLogError(msg)

   DESCRIPTION
   This function logs informations about errors. It will print out error
   message using the following format:
      ERROR : (<functionName>) <msg>
         <detail>
   
   where <functionName> is the function from where this function is called.
   And then, it checks whether execution has to be stopped or not according to
   the logging severity level (optional here, can be set wit yocoLogSet), and
   preference setting, as shown in following table :
   +-----------------+-----------------+--------------------+
   |      Level      | yocoLog enabled | What it is done    |
   +-----------------+-----------------+--------------------+
   | yocoLOG_WARNING |       -         | Program continues  |
   | yocoLOG_INFO    |       0         | Program continues  |
   | yocoLOG_TEST    |       1         | Program is stopped |
   | yocoLOG_TRACE   |       -         | Program is stopped |
   +-----------------+-----------------+--------------------+
   
   PARAMETERS
   - msg   : message related to the occured error. 
   - detail: detail on the occured error; e.g. if error is related to a given
                file, specify its name here.

   EXAMPLES
     > yocoLogError, "Could not open file - permission denied", "file.fits";
    
   SEE ALSO
     yocoLogSet
*/
{
    /* If level is void */
    if ( is_void(level) )
        yocoLogGet, enabled, level
    
    /* Verbose level is always high enough */

    /* Print out message (if any) */
    _yocoLogPrintMsg, msg, "ERROR";

    /* Print out detail (if any) */
    _yocoLogPrintDetail, detail;
    
    /* Check if the error should be issued */
    if ( (level==yocoLOG_TEST && enabled!=0) || (level==yocoLOG_TRACE) )
        error;
}

/* If possible */
if ( is_func(errs2caller) ) errs2caller, yocoLogError;


/***************************************************************************/


func yocoLogWarning(msg, detail)
/* DOCUMENT yocoLogWarning(msg, detail)
            yocoLogWarning(msg)

   DESCRIPTION
     This function logs informations about abnormal events. It will print out
     message prefixed with "WARNING :".

   PARAMETERS
   - msg   : message related to the abnormal event.
   - detail: detail on the abnormal event ; if this message is related to a
                given file, specify its name here.

   EXAMPLES
     > yocoLogWarning, "No sky file given";
     > yocoLogWarning, "Cannot found OI file:", inputOiFile;
    
   SEE ALSO
     yocoLogSet
*/
{
    /* Check if verbose level is high enough */
    if ( (!_yocoLogEnabled) || (_yocoLogLevel < yocoLOG_WARNING) )
    {
        return;
    }

    /* Print out message (if any) */
    _yocoLogPrintMsg, msg, "WARNING";

    /* Print out detail (if any) */
    _yocoLogPrintDetail, detail;
}

/***************************************************************************/

func yocoLogInfo(msg, detail)
/* DOCUMENT yocoLogInfo(msg, detail)
            yocoLogInfo(msg)

   DESCRIPTION
     This function logs informations about major events.

   PARAMETERS
   - msg   : message related to the majors events. 
   - detail: detail on the event ; if this message is related to a given
                file, specify its name here.

   EXAMPLES
     > yocoLogInfo, "Loading flat-field file...", "amdmsFlatFieldMap.fits";
    
   SEE ALSO
     yocoLogSet
*/
{
    /* Check if verbose level is high enough */
    if ( (!_yocoLogEnabled) || (_yocoLogLevel < yocoLOG_INFO) )
    {
        return;
    }

    /* Print out message (if any) */
    _yocoLogPrintMsg, msg;

    /* Print out detail (if any) */
    _yocoLogPrintDetail, detail;
}

/***************************************************************************/


func yocoLogTest(msg, detail)
/* DOCUMENT yocoLogTest(msg, detail)
            yocoLogTest(msg)
            
   DESCRIPTION
     This function logs informations used for software test activities

   PARAMETERS
   - msg   : message related to the test activities. 
   - detail: detail on the test ; if this message is related to a given file,
                specify its name here.

   EXAMPLES
     > yocoLogTest, "Converted coordinates is (" + xCoord + "," + yCoord + ")";
     > yocoLogTest, "Used Oi File:", inputOiFile;
      
   SEE ALSO
     yocoLogSet
*/
{
    /* Check if verbose level is high enough */
    if ( (!_yocoLogEnabled) || (_yocoLogLevel < yocoLOG_TEST) )
    {
        return;
    }

    /* Print out message (if any) */
    _yocoLogPrintMsg, msg;

    /* Print out detail (if any) */
    _yocoLogPrintDetail, detail;
}

/***************************************************************************/


func yocoLogTrace(msg, detail)
/* DOCUMENT yocoLogTrace(msg, detail)
            yocoLogTrace(msg)

   DESCRIPTION
     This function logs function/procedure trace

   PARAMETERS
   - msg   : message giving name of function/procedure. 
   - detail: detail on trace ; if this message is related to a given file,
                specify its name here.

   EXAMPLES
     > yocoLogTrace, "yocoLogSet()";
    
   SEE ALSO
     yocoLogSet
*/
{
    /* Check if verbose level is high enough */
    if ( (!_yocoLogEnabled) || (_yocoLogLevel < yocoLOG_TRACE) )
    {
        return;
    }

    /* Print out message (if any) */
    _yocoLogPrintMsg, msg;

    /* Print out detail (if any) */
    _yocoLogPrintDetail, detail;
}

/***************************************************************************/


func yocoLogHelp(msg, detail)
/* DOCUMENT yocoLogHelp(msg, detail)

   DESCRIPTION
     This function prints out the help message.

   PARAMETERS
   - msg   : help message
   - detail: detail on help ; if this message is related to a given file,
                specify its name here.

   EXAMPLES
     > yocoLogHelp, "Help on file chooser", "- click on a file to select it";
    
   SEE ALSO
     yocoLogSet
*/
{
    /* Check if help is enabled */
    if (!_yocoLogHelpEnabled) 
    {
        return;
    }

    /* Print out message (if any) */
    _yocoLogPrintMsg, msg;

    /* Print out detail (if any) */
    _yocoLogPrintDetail, detail;
}

/***************************************************************************/


func yocoLogSet(enabled, level)
/* DOCUMENT yocoLogSet(enabled, level)

   DESCRIPTION
     This function enables/disables message logging, and sets verbose level.
     This function doe not influence neither logging of error messages nor
     printing of help messages.

   PARAMETERS
   - enabled: flag to enable or disable message logging.
   - level  : lowest level of messages to be printed out. The possible values
                  are :
                    o yocoLOG_WARNING 
                    o yocoLOG_INFO    
                    o yocoLOG_TEST    
                    o yocoLOG_TRACE   

   EXAMPLES
     > yocoLogSet, 1, yocoLOG_INFO

   SEE ALSO
     yocoLogSetHelp
*/
{
    extern _yocoLogEnabled;
    extern _yocoLogLevel;
    
    if (!is_void(enabled))
    {
        _yocoLogEnabled  = anyof(enabled);
    }
    
    if (!is_void(level))
    {
        _yocoLogLevel    = level;
    }
}

func yocoLogGet(&enabled, &level)
/* DOCUMENT yocoLogGet(&enabled, &level)

   DESCRIPTION
     This function gets logging services setting.

   PARAMETERS
   - enabled: flag indicating whether logging is enabled or not.
   - level  : logging level

   EXAMPLES
     > yocoLogGet, enabled, level

   SEE ALSO
     yocoLogSet
*/
{
    extern _yocoLogEnabled;
    extern _yocoLogLevel;

    enabled  = _yocoLogEnabled;
    
    level = _yocoLogLevel;
}

func yocoLogSetHelp(enabled)
/* DOCUMENT yocoLogSetHelp(enabled)

   DESCRIPTION
     This function enables/disables printing of help message

   PARAMETERS
   - enabled: flag to enable or disable help displaying.

   EXAMPLES
     > yocoLogSetHelp, 0,

   SEE ALSO
     yocoLogSet
*/
{
    extern _yocoLogHelpEnabled;
    
    _yocoLogHelpEnabled  = anyof(enabled);
}

/***************************************************************************/


func yocoLogGetHelp(&enabled)
/* DOCUMENT yocoLogGetHelp(&enabled)

   DESCRIPTION
     This function gets textual tooltip help setting.

   PARAMETERS
   - enabled: flag indicating whether textual tooltip help is enabled or not.

   EXAMPLES
     > yocoLogGetHelp, enabled
   
   SEE ALSO
     yocoLogSetHelp
*/
{
    extern _yocoLogHelpEnabled;
    enabled = _yocoLogHelpEnabled;
    return (enabled);
}


func _yocoLogPrintMsg(msg, prefix)
/* DOCUMENT _yocoLogPrintMsg(msg, prefix)

   DESCRIPTION
     Print out log message 
   
   PARAMETERS
   - msg   : log message.
   - prefix: prefix to be printed before message
*/
{
     /* Print out error message (if any) */
    if (!is_void(msg) ) 
    {
        if ( !yocoTypeIsString(msg) ) 
        {
            msg = pr1(msg);
        }

        if (strlen(msg) != 0)
        {
            if (!is_void(prefix) )
            {
                _yocoLogInTerm, prefix + " : " + msg;
                _yocoLogInFile, prefix + " : " + msg;
            }
            else
            {
                _yocoLogInTerm, msg;
                _yocoLogInFile, msg;
            }
        }
    }
}

/***************************************************************************/

func _yocoLogPrintDetail(detail)
/* DOCUMENT _yocoLogPrintDetail(detail)

   DESCRIPTION
     Print out log message 
   
   PARAMETERS
   - detail: detail related to a message.
*/
{
    /* Print out error detail (if any) */
    if ( is_void(detail) ) 
    {
        return;
    }
    if ( !yocoTypeIsString(detail) ) 
    {
        detail = pr1(detail);       
    }
    _yocoLogInTerm, "   " + detail;
    _yocoLogInFile, detail;
}

/***************************************************************************/

func yocoLogSetFile(str, overwrite=)
/* DOCUMENT yocoLogSetFile(str, overwrite=)

   DESCRIPTION
     Define 'str' (scalar string) as the
     file name for the logging output.

     If str is void, the logging in file is turned off,
     and message are only printed in the prompt.

     Optional parameter overwrite=1 to first remove
     the file is already existing.

   PARAMETERS
   - str        : 
   - overwrite  : 

   EXAMPLES
   > yocoLogSetFile,"~/today.log";
   > yocoLogSetFile();
   > yocoLogSetFile,"~/today.log",overwrite=1;

   SEE ALSO
   yocoLogGetFile, yocoLog
*/
{
  extern _yocoLogFileStream;


  if ( is_void(str) || yocoTypeIsStringScalar(str) )
  {
    _yocoLogFileStream = str;
  }
  else
  {
    error,"str should be a scalar string or void.";
  }
  
  if ( overwrite ) remove,str;
}

func yocoLogGetFile(&str)
/* DOCUMENT yocoLogGetFile(&str)

   DESCRIPTION
     Return the file that is defined for logging.
     If void, it means that the logging is done
     in the prompt only (no log file);

   PARAMETERS
   - str        : 

   EXAMPLES

   SEE ALSO
   yocoLogSetFile, yocoLog
*/
{
  extern _yocoLogFileStream;
  str = _yocoLogFileStream;
  return str;
}

/***************************************************************************/


func _yocoLogInFile(str)
/* DOCUMENT _yocoLogInFile(str)

   DESCRIPTION
     Print out the log message str (scalar string)
     in file __yocoLogFileStream (scalar string).

   PARAMETERS
   - str        : 

   EXAMPLES

   SEE ALSO
 */
{
  extern _yocoLogFileStream;
  local tmp;
  
  if ( typeof(_yocoLogFileStream) == "string")
    {
      tmp = open(_yocoLogFileStream,"a");
      write,tmp,str;
      close,tmp;
    }
}

func _yocoLogInTerm(str)
/* DOCUMENT _yocoLogInTerm(str)

   DESCRIPTION
     Print out the log message str (scalar string)
     in the prompt (write function).

   PARAMETERS
   - str        : 

   EXAMPLES

   SEE ALSO
 */
{
  write,str;
}

/* ******************************************************* */

if ( is_func(errs2caller) ) errs2caller, yocoLogSetFile;
