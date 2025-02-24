/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Improved error handling
 *
 * "@(#) $Id: yocoError.i,v 1.2 2010-05-21 11:35:06 lebouquj Exp $"
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2010/05/21 11:21:56  lebouquj
 * Add yocoError, as this can be dealed with an interpreted function
 * with yorick>2.1.05
 *
 * Revision 1.3  2007/11/15 11:54:17  gzins
 * Added yocoErrorGet
 *
 * Revision 1.2  2007/11/14 15:01:48  gzins
 * Fixed bug in yocoErrorSet and updated documentation
 *
 * Revision 1.1  2007/11/14 11:10:20  gzins
 * Added
 *
 */

/*
 * Local variables
 */

local yocoErrorEnable;
/* DOCUMENT yocoErrorEnable

   See help, yocoError for explanation.
 */

func yocoError(message,detail,level)
/* DOCUMENT yocoError(msg, detail, level)

  DESCRIPTION
    This function s an 'improved' error handler. It prints out given error
    message using the following format:
         ERROR : (<functionName>) <msg>
             <detail>
             
    where <functionName> is the function from where this function is called.
    And then, it checks whether execution has to be stopped or not according to
    the error severity level, and preference setting, as shown in following
    table :
      +-------+-----------------+--------------------+
      | Level | yocoErrorEnable | What it is done    |
      +-------+-----------------+--------------------+
      |   1   |       -         | Program continues  |
      |   2   |       0         | Program continues  |
      |   2   |       1         | Program is stopped |
      |   3   |       -         | Program is stopped |
      +-------+-----------------+--------------------+
    
  PARAMETERS
    - msg    : optional string, message related to the occured error
    - detail : optional string, detail on the occured error; e.g. if error is
               related to a given file, specify its name here.
    - level x: optional integer, see below.
   
   SEE ALSO: yocoError, yocoErrorSet, yocoErrorGet, error
*/
{
  if ( is_array(detail) )
  {
    message = string(message) + "\n   " + detail;
  }

  /* If level is void */
  if ( is_void(level) ) level = 2;

  /* Check if the error should be issued */
  if ( (level==2 && yocoErrorEnable!=0) || (level==3) ) { error,message; }

  /* Else return 0 */
  write,format="ERROR %s\n",message;
  return 0;
}

/* If possible */
if ( is_func(errs2caller) ) errs2caller, yocoError;


func yocoErrorSet(errorFlag)
/* DOCUMENT yocoErrorSet, errorFlag;

  DESCRIPTION
    Enable/disable error mode (whether program is stopped or not) when error
    severity level is equal to 2.

  PARAMETERS
    - errorFlag : Define the mode of yocoError (0/1).
                    
  SEE ALSO: yocoError, yocoErrorSet
*/
{    
    extern yocoErrorEnable;
    extern after_error;

    /* Default is error */
    if (is_void(errorFlag)) 
    {
        errorFlag  = 1;
    }

    /* Set/unset the error mode by filling the 'yocoErrorEnable'
       variable by 0 or 1 */
    if ( !yocoTypeIsIntegerScalar(errorFlag) ) 
    {
        error,"errorFlag should be scalar integer";
    }
    yocoErrorEnable = min( max(0,errorFlag), 1);
    yocoLogTest,"Set error mode: "+["OFF","ON"](yocoErrorEnable+1);

    /* return 1 if success */
    return 1;
}

func yocoErrorGet(void)
/* DOCUMENT yocoErrorGet

  DESCRIPTION
    Returns the error mode setting

  SEE ALSO: yocoError, yocoErrorSet
*/
{    
    extern yocoErrorEnable;

    return yocoErrorEnable;
}

/* =========================================
   Set the default to:
   - error mode on
   - return value = 0
*/
yocoErrorSet, 1;
