/******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Yorick documentation tools
 *
 * "@(#) $Id: yocoDoc.i,v 1.31 2011-04-12 18:17:45 fmillour Exp $"
 *
 ******************************************************************************/

func yocoDoc(void)
/* DOCUMENT yocoDoc

       DESCRIPTION
       Documentation tools from LAOG-Yorick contribution project.

       VERSION
       $Revision: 1.31 $

       FUNCTIONS
   - yocoDoc                    : 
   - yocoDocListFunctions       : 
   - yocoDocUpdateFunctionsCalls: Updates your yorick functions help in one
       click.

       SEE ALSO
       yoco
    */
{
    version = strpart(strtok("$Revision: 1.31 $",":")(2),2:-2);
    if(am_subroutine())
    {
        help, yocoDoc;
    }
    return version;
} 

/***************************************************************************/
         
func yocoDocListFunctions(dir=, outFile=, tex=)
/* DOCUMENT yocoDocListFunctions(dir=, outFile=, tex=)

       DESCRIPTION
       produces a text file (tex=0) or a latex file (tex=1) containing all the
       descriptions and arguments of the functions contained in the "i" files
       (i.e. yorick scripts)

       PARAMETERS
   - dir    : directory containing the "i" files
   - outFile: output txt or tex file
   - tex    : if 1, the format of the text file is latex-compliant,
       otherwise it is written as a simple ASCII file

       RETURN VALUES
       outFile defaults to "~/test.txt" or "~/test.tex" depending on the value
       of the "tex" option

       EXAMPLES
       > cd,"$INTROOT/yorick/i";
       > yocoDocListFunctions

       SEE ALSO
    */
{
    if(is_void(dir))
        // Choose the directory
        if (yocoGuiFileChooser("DIRECTORY OR FILE"+
                               "(right-click to exit)",
                               dir) == 0)
        {
            return 0;
        }

    cd,dir;
  
    /* Get only Yorick files in given directory */
    if ((iFiles = _yocoDocGetYorickFiles(dir=dir)) == 0)
    {
        return 0;
    }

    // Open the destination file to edit the help
    if(is_void(outFile))
    {
        lastDir = yocoStrrtok(dir,"/")(0);
        if(tex==1)
            e = ".tex";
        else
            e = ".txt";
        outFile = dir+lastDir+"_functions"+e;
    }

    if(open(outFile,"r",1))
        yocoError, "File "+outFile+" exists.\n Erase it first (if you are sure of what you do) and run again !";
            
    fh_target = open(outFile, "w");
    
    fh = popen("whoami",0);
    whoami = rdline(fh);
    close,fh;
    
    // Write preamble of latex file
    if(tex==1)
    {
        write, fh_target, "\\documentclass[a4paper, 11pt]{article}";
        write, fh_target, "\\usepackage[latin1]{inputenc}";
        write, fh_target, "\\usepackage[T1]{fontenc}";
        write, fh_target, "\\usepackage[francais]{babel}";
        write, fh_target, "\\usepackage{graphicx}";
        write, fh_target, "\\usepackage{vmargin}"; 
        write, fh_target, "\\begin{document}";
        write, fh_target, "\\author{Created by "+whoami+" using \\texttt{yocoDocListFunctions}.}";
        write, fh_target, "\\title{List of yorick functions}";
        write, fh_target, "\\date{"+timestamp()+"}";
        write, fh_target, "\\maketitle";
    }
    else
    {
        write, fh_target, "********************************";
        write, fh_target, "*                              *";
        write, fh_target, "*   List of yorick functions   *";
        write, fh_target, "*                              *";
        write, fh_target, "********************************";
        write, fh_target, "\nCreated by "+whoami+" using yocoDocListFunctions.";
        write, fh_target, timestamp();
    }
    
    // Repeat the same procedure for each yorick file
    for (i = 1; i <= numberof(iFiles); i++)
    {
        sep = "\n";
        for (jCh=1; jCh < strlen(iFiles(i)); jCh++)
        {
            sep = sep + "*";
        }
        sep = sep + "****";

        yocoLogInfo, swrite("\n" + sep + "\n", iFiles(i), sep);

        // Open the source file to read all the help
        fh_source = open(iFiles(i), "r");

        funcs = _yocoDocGetAllFunctionsNames(fh_source, listSubRoutines=0);

        if((tex==1)&&(i!=1))
            write,fh_target,"\\newpage";
        if(tex==1)
            write,fh_target,"\\section{Script " + iFiles(i) + "}";
        else
        {
            write,fh_target,"\n***********************************";
            write,fh_target,"\n" + pr1(i) + ") Script " + iFiles(i);
            write,fh_target,"\n***********************************\n";
        }
            
        
        /* Read next function call, and its documentation...
           until the end of document has been reached */
        functCall = document = args = [];
        stillSomeWork = k = 1;
        while ( (stillSomeWork = 
                 _yocoDocReadNextFunctCall(fh_source, functCall, args, document) ) )

        {
            if(tex==1)
            {
                specialChars = ["&","_","$","%","#","{","}","[","]"];
                replacement = ["\\&","\\_","\\$","\\%","\\#","\\{","\\}","\\[","\\]"];
                document = yocoStrReplace(document,specialChars,replacement);
                args = yocoStrReplace(args,specialChars,replacement);
                functCall = yocoStrReplace(functCall,specialChars,replacement);
            }
            write,fh_target,
                "-----------------------------------------------";
            if(tex==1)
                write,fh_target,"\\\\";
             
            //fs = yocoStrReplace(document(1),"/* DOCUMENT","");
            fs = functCall + " : ";
            for(q=1;q<=numberof(args);q++)
            {
                fs = fs + args(q);
                if(q<numberof(args))
                    fs = fs + ", ";
            }
             
            if(tex==1)
                fs = "{\\texttt{ "+fs+"}}";
            
            write,fh_target,fs;
            if(tex==1)
                write,fh_target,"\\\\";
            
            _yocoDocCropDocument,"DESCRIPTION", document;

            if((tex==1)&&(strmatch(document(1),"DESCRIPTION")))
                document(1) = "{\\it "+document(1)+": }";
            write,fh_target,document(1);
            
            nD = numberof(document);
            
            if(tex==1)
                write,fh_target,"\\begin{verbatim}";
            for(kd=2;kd<=nD-1;kd++)
            {
                write,fh_target,document(kd);
            }
            if(tex==1)
                write,fh_target,"\\end{verbatim}";
        }

                
        // Close source and target files
        close, fh_source;
    }    
    if(tex==1)
    {
        write, fh_target, "\\end{document}";
    }
    close, fh_target;
    
    write,"\nOutput file is "+outFile;
}

/***************************************************************************/
         
func _yocoDocCropDocument(statement, &document)
/* DOCUMENT _yocoDocCropDocument(statement, &document)

       DESCRIPTION

       PARAMETERS
   - statement: 
   - document : 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    if (is_void(statement))
    {
        statement = "DESCRIPTION";
    }
    compressedDoc = yocoStrReplace(document," ","");

    len = strlen(statement);
    startStatement = where(strmatch(strpart(compressedDoc,1:len), statement));

    if (numberof(startStatement) == 0)
    {
        return 0;
    }
    else
    {
        startStatement = startStatement(1);
    }
    endStatement = where((!strmatch(compressedDoc(startStatement:),""))|
                         strmatch(compressedDoc(startStatement:),"*/"))(1) +
        startStatement-1;
    document = document(startStatement:endStatement);
}


/***************************************************************************/
         
func yocoDocUpdateFunctionsCalls(dir=)
/* DOCUMENT yocoDocUpdateFunctionsCalls(dir=)

       DESCRIPTION
       This script allows to get the help updated in one click for a set of
       yorick files or a selected file.

       This scripts updates the helps of the functions and updates several
       keywords automatically :
       o FUNCTIONS will be followed by the package list of functions
       o PARAMETERS will be followed by the list of current function's
       arguments
       o DEFAULTS will be followed by the list of default values for each
       argument

       If the function is not documented at all, then this script creates a
       template to fill in by the programmer

       PARAMETERS
   - dir: directory or file you want to update yorick functyions helps. If
       nothing is given in dir, then a file chooser pops up to choose
       what you want to update

       CAUTIONS
       Several rules of good programmation are to be followed if you want it to
       work properly but you will see by yourselves the result if you are a "bad
       programmer" ;-) Of course the old file is stored with _old added to its
       name, so don't worry, you won't loose your job !

       EXAMPLES
       You want to update the help of the file "yocoDoc.i" :

       > yocoDocUpdateFunctionsCalls(dir="yocoDoc.i")
       ****************************
       yocoDoc.i
       ************************************************
       yocoDoc
       yocoDocUpdateFunctionsCalls
       _yocoDocGetAllFunctionsNames
       _yocoDocUpdateListOfArgs
       _yocoDocUpdateSynopsys
       _yocoDocGetYorickFiles
       _yocoDocReadNextFunctCall
       _yocoDocWriteWithoutBlanks

       Then you get the help of the functions yocoDoc, yocoDocUpdateFunctionsCalls
       and ... updated in the file "yocoDoc.i"
    */
{
    if(is_void(dir))
        // Choose the directory
        if (yocoGuiFileChooser("DIRECTORY OR FILE"+
                               "(right-click to exit)",
                               dir) == 0)
        {
            return 0;
        }

    /* Not Yorick files in given directory */
    if ((iFiles = _yocoDocGetYorickFiles(dir = dir)) == 0)
    {
        return 0;
    }

    // Repeat the same procedure for each yorick file
    for (i = 1; i <= numberof(iFiles); i++)
    {
        sep = "\n";
        for (jCh=1; jCh < strlen(iFiles(i)); jCh++)
        {
            sep = sep + "*";
        }
        sep = sep + "****";

        yocoLogInfo, swrite("\n" + sep + "\n", iFiles(i), sep);

        // Open the source file to read all the help
        fh_source = open(iFiles(i), "r");

        // Open the destination file to edit the help
        fh_target = open(strpart(iFiles(i),:-2) + "_new.i", "w");

        funcs = _yocoDocGetAllFunctionsNames(fh_source, listSubRoutines=0);

        
        /* Read next function call, and its documentation...
           until the end of document has been reached */
        functCall = document = args = [];
        stillSomeWork = k = 1;
        while ( (stillSomeWork = 
                 _yocoDocReadNextFunctCall(fh_source, functCall, args, document,
                                           fhTarget=fh_target) ) )

        {
            argsNonVoid = where(args!="void");
          
          
            // Update the DOCUMENT statement with the current function call
            // and arguments
            _yocoDocUpdateSynopsys, functCall, args(argsNonVoid), document;
          
            if(numberof(argsNonVoid)!=0)
            {
                // Update the lists of arguments and functions 
                _yocoDocUpdateListOfArgs, "PARAMETERS",
                    args(argsNonVoid), document;
                _yocoDocUpdateListOfArgs, "DEFAULTS",
                    args(argsNonVoid), document;
            }

            // Update the list of function (why here ?)
            _yocoDocUpdateListOfArgs, "FUNCTIONS", funcs, document, alphabet=1;
        
            // Shape the arguments list for writing
            argList = "";
            if (!is_void(args))
            {
                argList = "(";
                if (numberof(args) > 1)
                {
                    for (k = 1; k <= numberof(args) - 1; k++)
                    {
                        argList = argList + args(k) + ", ";
                    }
                }
                argList = argList + args(0) + ")";
            }
          
            // Write the function call
            _yocoDocWriteWithoutBlanks, fh_target, "func " + functCall + argList;

            // Write the new Documentation
            for (h = 1; h <= numberof(document); h++)
            {
                _yocoDocWriteWithoutBlanks, fh_target, document(h);
            }
          
            // Write the starting point of the function
            _yocoDocWriteWithoutBlanks, fh_target, "{";

            // reset before staring following function
            functCall = document = args = [];
        } /* end - while */

                
        // Close source and target files
        close, fh_source;
        close, fh_target;

        // Move the older files to *_old.i and the new file to the current name
        rename,iFiles(i),strpart(iFiles(i), :-2) + "_old.i";
        rename,strpart(iFiles(i), :-2) + "_new.i",iFiles(i);
    }
}

/***************************************************************************/

func _yocoDocGetAllFunctionsNames(&fh, listSubRoutines=)
/* DOCUMENT _yocoDocGetAllFunctionsNames(&fh, listSubRoutines=)

       DESCRIPTION
       Taking a file stream (like in fh=open("file.i","r") ), reads and recognize
       all the functions contained in it.

       PARAMETERS
   - fh             : file stream to read
   - listSubRoutines: 

       RETURN VALUES
       This function returns a list of functions names contained in the file
       stream. At the end, the file stream is reinitialized to the original line
       number

       EXAMPLES
       > fh = open("yocoStr.i","r");
       > funcs = _yocoDocGetAllFunctionsNames(fh);
       > close, fh
       > print, funcs
       ["yocoStr","yocoStr2Long","yocoStr2Double","yocoStrTrail","yocoStrLead",
       "yocoStrTrim","yocoStrDefault","yocoStrSplit","yocoStrrtok","yocoStrChr",
       "yocoStrRevChr","yocoStrVal","yocoStrSub","yocoStrRev","yocoStrReplace"]
    */
{
    _DEBUG=0;

    if(is_void(listSubRoutines))
        listSubRoutines = 1;

    bmark = bookmark(fh);

    // Get all the function names
    funcList = [];
    while (line = rdline(fh))
    {
        compressedLine = yocoStrReplace(line, " ", "");
        if((strpart(compressedLine, 1:4)=="func") &&
           (strmatch(line, "func ")))
        {
            funcCall =
                yocoStrSplit(yocoStrReplace(compressedLine, "func", ""),
                             "(")(1);

            if(!(strpart(funcCall,1:1)=="_"))
                grow, funcList, funcCall;
            else if((strpart(funcCall,1:1)=="_")&&(listSubRoutines==1))
                grow, funcList, funcCall;
        }
    }
    // Go back to the beginning of the file stream
    backup, fh, bmark;

    return funcList;
}

/***************************************************************************/
         
func _yocoDocUpdateListOfArgs(statement, args, &document, alphabet=)
/* DOCUMENT _yocoDocUpdateListOfArgs(statement, args, &document, alphabet=)

       DESCRIPTION
       Using an array of string containing the content of each line of a yorick
       documentation, this script updates or creates if it does not exist a list
       of the arguments given by "args" just after the keyword "statement"
       The document variable is updated, see example for more details

       PARAMETERS
   - statement: the statement after you suppose there is a list of arguments,
       identified with the "-" symbol. statement defaults to
       "PARAMETERS".
   - args     : the arguments you want to update
   - document : document help
   - alphabet : if set to 1, sorts the args list before proceeding

       EXAMPLES
       > fh_source = open("yocoFile.i","r");
       > for(k=1;k<=6;k++)
       > _yocoDocReadNextFunctCall(fh_source, functCall, args, document)
       > close,fh_source
       > write,document+"\n";
       > document(2) = "PARAMETERS";
       > _yocoDocUpdateListOfArgs("PARAMETERS", args, document, alphabet=)
       > write,document+"\n";
    */
{
    if (is_void(statement))
    {
        statement = "PARAMETERS";
    }
    compressedDoc = yocoStrReplace(document," ","");

    len = strlen(statement);
    startStatement = where(strmatch(strpart(compressedDoc,1:len), statement));

    if (numberof(startStatement) == 0)
    {
        return 0;
    }
    else
    {
        startStatement = startStatement(1);
    }
    endStatement = where((!strmatch(compressedDoc(startStatement:),""))|
                         strmatch(compressedDoc(startStatement:),"*/"))(1) +
        startStatement-1;

    statementList = where(strmatch(document(startStatement+1:endStatement),
                                   "- "));
    if (numberof(statementList) != 0)
    {
        statementList = statementList + startStatement;

        startStatementList = min(statementList);
        endStatementList = max(statementList);

        lineSep = strtok(document(statementList),":");      
        documentedArgs = yocoStrReplace(lineSep(1,),["-"," "],["",""]);

        argComment = [];
        for(k=startStatementList;k<=endStatementList;k++)
        {
            if(strmatch(document(k),"- "))
            {
                lineSep = strtok(document(k),":");  
                grow,argComment,lineSep(2,);
            }
            else
                argComment(0) = argComment(0) + "\n" + document(k);
        }

        if (alphabet == 1)
        {
            args = args(sort(args));
        }
        argList = [];

        len = max(strlen(yocoStrReplace(args,["&","="],["",""])));
        for (iArg = 1; iArg <= numberof(args); iArg++)
        {
            test = where(yocoStrReplace(documentedArgs,["&","="],["",""]) ==
                         yocoStrReplace(args(iArg),["&","="],["",""]));
            if(numberof(test)!=0)
            {
                grow, argList, "   - "+swrite(format="%-"+pr1(len)+"s",
                                              yocoStrReplace(args(iArg),
                                                             ["&","="],
                                                             ["",""])) +
                    ":" + argComment(test)(1);
            }
            else
            {
                grow, argList, "   - "+swrite(format="%-"+pr1(len)+"s",
                                              yocoStrReplace(args(iArg),
                                                             ["&","="],
                                                             ["",""])) +
                    ": ";
            }
        }
        tmpDoc = [];
        grow, tmpDoc, document(:startStatementList-1), 
            argList,  document(endStatementList + 1:);
        document = tmpDoc;
    }
    else
    {
        argList = "   - " + swrite(format="%-"+pr1(len)+"s",
                                   yocoStrReplace(args,
                                                  ["&","="],
                                                  ["",""])) + " : ";
        tmpDoc = [];
        grow, tmpDoc, document(:startStatement), 
            argList, document(startStatement+1:);
        document = tmpDoc;
    }
}

/***************************************************************************/
         
func _yocoDocUpdateSynopsys(functCall, args, &document)
/* DOCUMENT _yocoDocUpdateSynopsys(functCall, args, &document)

       DESCRIPTION
       Updates the synopsis of the function, placed just after the DOCUMENT
       statement. The document variable is updated, try the example for more
       details
   
       PARAMETERS
   - functCall: name of the function
   - args     : arguments of the function, given as a list of strings
   - document : document to modify

       EXAMPLES
       > fh = open(Y_SITE+"i/demo1.i","r");
       > for(k=1;k<=6;k++)
       > _yocoDocReadNextFunctCall,fh_source, functCall, args, document
       > close,fh
       > write,document(1);
       > _yocoDocUpdateSynopsys,functCall, args, document
       > write,document(1);
    */
{
    if (!is_void(args))
    {
        argList = "(";
        if (numberof(args) > 1)
        {
            for (k = 1; k <= numberof(args) - 1; k++)
            {
                argList = argList + args(k) + ", ";
            }
        }
        argList = argList + args(0) + ")";
    }
    else
    {
        argList = "";
    }

    iDoc = where(strmatch(document, "DOCUMENT"))(1);
    if (strmatch(document(iDoc), "/*"))
    {
        document(iDoc) = "/* DOCUMENT " + functCall + argList;
    }
    else
    {
        document(iDoc) = "DOCUMENT " + functCall + argList;
    }
}

/***************************************************************************/

func _yocoDocGetYorickFiles(dir=)
/* DOCUMENT _yocoDocGetYorickFiles(dir=)

       DESCRIPTION
       Gives a list of yorick script (recognizable by their ".i" extension) in a
       directory

       PARAMETERS
   - dir: the optional directory path. If nothing is specified, the a file
       browser pops up

       RETURN VALUES
       A list of yorick files

       EXAMPLES
       > _yocoDocGetYorickFiles(dir=Y_SITE)
    */
{
    if(is_void(dir))
        // Choose the directory
        if (yocoGuiFileChooser("DIRECTORY OR FILE"+
                               "(right-click to exit)",
                               dir) == 0)
        {
            return 0;
        }
    //Check wether the clicked thing is a directory or a file
    if (strmatch(dir, ".i"))
    {
        files = array(dir, 1);
    }
    else
    {
        // Get files names
        files = lsdir(dir);
    }

    // Get only the yorick files (ending by ".i")
    suffixes = yocoStrrtok(files,".")(2,);
    iFiles = files(where((suffixes == "i") & (!strmatch(files,"#"))));
    return iFiles;
}

/***************************************************************************/
                      
func _yocoDocReadNextFunctCall(&fhSource, &functCall, &args, &document, fhTarget=)
/* DOCUMENT _yocoDocReadNextFunctCall(&fhSource, &functCall, &args, &document, fhTarget=)

       DESCRIPTION
       From a file stream opened on a yorick file, finds the next function call
       and populate the functCall, args and document variables respectively with
       the function call, the function arguments and the function's documentation

       PARAMETERS
   - fhSource : file stream
   - functCall: function name
   - args     : function arguments
   - document : function documentation
   - fhTarget : An opened file stream to a target file to write down. If
       nothing is given, them it defaults to an opened /dev/null
       file

       RETURN VALUES
       See the example for more information
   
       EXAMPLES
       > fh_source = open(Y_SITE+"i/demo1.i","r");
       > fh_target = open("/dev/null","w");
       > _yocoDocReadNextFunctCall,fh_source, fh_target, functCall, args, 
       document, stillSomeWork
       > write,functCall;
       > write,args;
    */
{
    templateDocument = ["/* DOCUMENT","",
                        "   DESCRIPTION","",
                        "   PARAMETERS","",
                        "   RETURN VALUES","",
                        "   CAUTIONS","",
                        "   EXAMPLES","",
                        "   SEE ALSO","*/"];

    document = functCall = [];
    document_found = 0;

    // Read the source file for getting the functions DOCUMENTs
    while (document_found==0)
    {
        line = rdline(fhSource);

        if (line == string(nil))
        {
            stillSomeWork = 0;
            return 0;
        }

        // Get the read line without blanks to not miss anything
        compressedLine = yocoStrReplace(line," ","");

        // Recognize a function call
        if ((strpart(compressedLine,1:4) == "func") &&
            (strmatch(line, "func ")))
        {
            // Remove the "func" statement and separate the function arguments
            funcLine = strpart(compressedLine, 5:);
            functCall = yocoStrSplit(funcLine, "(")(1); 
            args = yocoStrSplit(yocoStrReplace(funcLine,")",""),"(")(2);

            /*****************************************************/

            //read the function's header which contains the documentation.
            //If it does not exist, then fills in an empty DOCUMENT
            while (document_found == 0)
            {
                line1 = rdline(fhSource);
                compressedLine1 = yocoStrReplace(line1," ","");
                if (strmatch(compressedLine1, "/*DOCUMENT") ||
                    strmatch(compressedLine1, "/*"))
                {
                    grow, document, line1;
                    while (document_found == 0)
                    {
                        line = rdline(fhSource);
                        grow, document, line;
                        if (strmatch(line, "*/"))
                        {
                            document_found = 1;
                            start_func = 0;
                            while (start_func == 0)
                            {
                                line=rdline(fhSource);
                                if (strmatch(line, "{"))
                                {
                                    start_func = 1;
                                }
                                else
                                {
                                    grow, document, line;    
                                }
                            }
                        }
                    }
                }
                else
                {
                    args = args+compressedLine1;
                    if (strmatch(args, "{"))
                    {
                        args=yocoStrReplace(args, "{", "");

                        //Store the line number, just in case
                        bmark = bookmark(fhSource);

                        line2=rdline(fhSource);
                        compressedLine2 = yocoStrReplace(line1, " ", "");
                        if (strmatch(compressedLine2, "/*DOCUMENT"))
                        {
                            grow, document, line1;
                            while (document_found == 0)
                            {
                                line = rdline(fhSource);
                                grow, document, line;
                                if (strmatch(line, "*/"))
                                {
                                    document_found = 1;
                                    start_func = 0;
                                    while (start_func == 0)
                                    {
                                        line = rdline(fhSource);
                                        if (strmatch(line,"{"))
                                        {
                                            start_func = 1;
                                        }
                                        else
                                        {
                                            grow, document, line;
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            //Go back one line before
                            backup, fhSource, bmark;
                            document = templateDocument;
                            document_found = 1;
                        }                          
                    }
                }
            }
        }
        else
        {
            if (!is_void(fhTarget))
            {
                // If we are not in a function call,
                // then just copy the source line to the target file.
                _yocoDocWriteWithoutBlanks, fhTarget, line;
            }
        }
    }
    //Shape the args list
    args = yocoStrSplit(args, ",");
    args = args(where(!(args == string(nil))));

    yocoLogInfo, functCall;

    return  1;
}

/***************************************************************************/
         
func _yocoDocWriteWithoutBlanks(fh, line)
/* DOCUMENT _yocoDocWriteWithoutBlanks(fh, line)

       DESCRIPTION

       PARAMETERS
   - fh  : 
   - line: 
    */
{
    if (strmatch(strpart(line, 1:1), " ") && 
        (!strmatch(strpart(line,2:2), " ")) && 
        (!strmatch(strpart(line,2:2), "*")))
    {
        write, fh, format="%s\n", strpart(line, 2:0);
    }
    else
    {
        write, fh, format="%s\n", line;
    }
}

