/******************************************************************************
 * LAOG project - Yorick Contribution package 
 *
 * CDS interrogation tools
 *
 * "@(#) $Id: yocoCalibrate.i,v 1.40 2010/12/17 10:30:45 fmillour Exp $"
 *
 ******************************************************************************/

// To see how the web tool is defined, look at yocoPreferences.i

/*************************************************************/
/** Includes *************************************************/
/*************************************************************/

require, "bessel.i";

/*************************************************************/

func yocoCds(void)
/* DOCUMENT yocoCds

   FUNCTIONS
   - yocoCds                 : 
   - yocoCdsGetSED           : 
   - yocoCdsPlotSED          : 
   - yocoCdsQueryStarDiameter: 
   - yocoCheckWebTool        : 

   SEE ALSO
*/
{
    version = strpart(strtok("$Revision: 1.40 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoCds;
    }   
    return version;
}



func yocoCheckWebTool(&availableWebTools)
/* DOCUMENT yocoCheckWebTool(&availableWebTools)

   DESCRIPTION
   - If void, value is set to its default.
   - Then check that value is 0 or 1
   
   RETURN VALUES
   0/1

   SEE ALSO:
*/
{
  yocoLogTrace, "yocoCheckWebTool()";

  /* Check which web tool is installed on the current computer */
  webTools = ["curl", "wget"];
  availableWebTools = [];
  for(k=1;k<=numberof(webTools);k++)
  {
      fh = popen("which "+webTools(k)+" 2> /dev/null", 0);
      answer = [];
      while(line=rdline(fh))
          grow,answer,line;
      close,fh;
      if(!is_void(answer))
      {
          grow, availableWebTools, webTools(k);
      }
  }

  /* In case no web tool is found, issue a warning */
  if(is_void(availableWebTools)) 
  {
      yocoLogWarning,"No web tool found. Calibrators web search will not work.";
      availableWebTools = [];
  }

  return availableWebTools;
}

yocoWEB_TOOL = yocoCheckWebTool()(1);


/****************************************************************/
/*** Web tools **************************************************/
/****************************************************************/

func _yocoCdsSendVizierQuery(catalog, outputCols, starName, &scriptFile, &outputFile, &finishFile, mirror=, radius=, nMax=)
/* DOCUMENT _yocoCdsSendVizierQuery(catalog, outputCols, starName, &scriptFile, &outputFile, &finishFile, mirror=, radius=, nMax=)

       DESCRIPTION
       Send a HTTP query to the Vizier database for any vizier catalog and
       store the result to a file in the /tmp directory.

       PARAMETERS
   - catalog   : catalog name, in the vizier standard
   - outputCols: outpu columns to get
   - starName  : star name or coordinates, in the simbad way
   - scriptFile: ouptut script file name
   - outputFile: output file name
   - finishFile: the file that tells the query is over
   - mirror    : the HTTP mirror of the VIZIER server
   - radius    : radius of the query (in ")
   - nMax      : maximum number of results returned

       RESULTS
       This script produces 3 files: a shell script /tmp/scriptFile, launched
       at the end of this yorick script, a result file containing the
       resulting query to vizier, and a "finish" file when the query is
       successful.
       
       EXAMPLES
       catalog = "J/A+A/386/492";
       cols = "cDiam e_cDiam";
       star = "Gamma Vel";
       _yocoSendVizierQuery,catalog, cols, star, scriptFile, outputFile;
       system,"more "+scriptFile;
       system,"more "+outputFile;
       
       SEE ALSO:
    */
{
    extern yocoWEB_TOOL;
    
    // if no column name is given, default is to query all columns
    if(allof(outputCols==""))
        outputCols="**";

    // Radius is the search radius around the star, in "
    if(is_void(radius))
        radius = 20;

    // nMax is the maximum number of results returned
    if(is_void(nMax))
        nMax = 1;

    // The vizier mirror, set by default
    if(is_void(mirror))
        mirror = "http://webviz.u-strasbg.fr";
    // mirror = "http://vizier.cfa.harvard.edu";

    // Replace spaces and special characters from yorick to - and _
    outName = yocoStrReplace(starName," ","_");
    outCat  = yocoStrReplace(catalog,[" ","/"],["_","-"]);

    // shell script that will be run at the end of this function
    scriptFile = "/tmp/"+outName+".viz"+outCat+"Script";
    
    // Result file containing the result of the web query
    outputFile = "/tmp/"+outName+".viz"+outCat+"Result";

    // File telling if the query is finished or not
    finishFile = "/tmp/"+outName+".viz"+outCat+"Finish";
    
    // Special characters, to be replaced in the web query
    specChar = ["%", "+", " ", "/", "?", "#", "&", "_"];
    repl = ["%25", "%2B", "+", "%2F", "%3F", "%23", "%26", "\\_"];
    
    // Replacing special characters
    outputCols2 = yocoStrReplace(outputCols,specChar,repl);
    catalog2    = yocoStrReplace(catalog,specChar,repl);
    starName2   = yocoStrReplace(starName,specChar,repl);
    
    // Building the full URL to query
    url = "\""+mirror+"/viz-bin/asu-tsv?"+
        "-source="+catalog2+"&"+
        "-out="+outputCols2+"&"+
        "-c="+starName2+"&"+
        "-c.rs="+pr1(radius)+"&"+
        "-sort=\_r&"+
        "-out.max="+pr1(nMax)+"\"";
    
    if(yocoWEB_TOOL=="wget")
    {
        // The shell commands themselves
        todo = "wget "+url+" -O "+outputFile+
            " -o /dev/null ; touch "+finishFile;
    }
    else if(yocoWEB_TOOL=="curl")
    {
        // The shell commands themselves
        todo = "curl -s "+url+" -o "+outputFile+
            " ; touch "+finishFile;
    }
    else
        yocoError,"No web tool specified";
    
    // Write the shell script
    fh = open(scriptFile,"w");
    write,fh,todo;
    close,fh;
    
    // run the shell script
    system,"chmod +x "+scriptFile;

    // Launch the script file and give back control before the script is
    // finished to allow simultaneous multiple queries
    system, scriptFile+" &";
}

/***************************************************************************/

func _yocoCdsReadVizierQuery(outputFile)
/* DOCUMENT _yocoCdsReadVizierQuery(outputFile)

       DESCRIPTION
       reads the result from a call to _sendVizierQuery. Normally only the
       relevant columns (and not the comments) are output
       
       PARAMETERS
   - outputFile: the result file from a call to _yocoSendVizierQuery

       RETURN VALUES
       a table with the result

       EXAMPLES
       catalog = "J/A+A/386/492";
       cols = "cDiam e_cDiam";
       star = "Gamma Vel";
       _yocoSendVizierQuery,catalog, cols, star, scriptFile, outputFile;
       result = _yocoReadVizierQuery(outputFile);
       print,result;

       SEE ALSO
    */
{
    // Read the output file
    red = [];
    fh = open(outputFile,"r");
    while(line=rdline(fh))
        grow,red,line;
    close,fh;

    // In case the file is empty, return zero
    if(is_void(red))
        return 0;

    // sorting the useful information
    red2 = red(where((strpart(red,1:1)!="#") &
                     (strmatch(red,""))));
    
    // in case the file contains only comments, return a fixed array
    if(is_void(red2))
        red2 = [";",";",";",";"];

    // if result is badly conformed, return zero
    red3 = [];
    if(numberof(red2)<4)
        return 0;

    // parse the lines to put them into columns
    for(k=1;k<=numberof(red2);k++)
    {
        grow,red3,array(yocoStrSplit(red2(k),";"),1);
    }

    return red3;
}

/***************************************************************************/

func yocoCdsVizierQuery(catalog, starName, &outputCols, &value, &unit, radius=, nMax=)
    /* DOCUMENT vizQuery(catalog, starName, &outputCols, &value, &unit, radius=, nMax=)

       DESCRIPTION
       from a star name or coordinates, returns the selected columns of the
       queried catalog. It makes use of _sendVizQuery and _readVizQuery

       PARAMETERS
       - catalog   : the catalog you want to browse
       - starName  : the star name
       - outputCols: the output columns
       - value     : the return values from the catalog
       - unit      : the units of the columns
       - radius    : 
       - nMax      : 

       RETURN VALUES

       CAUTIONS
       output columns must be ONE string, with column names separated by spaces.

       EXAMPLES
       catalog = "J/A+A/386/492";
       cols = "cDiam e_cDiam";
       star = "Gamma Vel";
       r=vizQuery( catalog, star, cols, value, unit);
       write,value;
       write,unit;

       SEE ALSO
    */
{
    if(is_void(outputCols))
        outputCols="";

    // Actually sending the command and getting the result
    _yocoCdsSendVizierQuery, catalog, outputCols, starName, scriptFile, outputFile, finishFile, radius=radius, nMax=nMax;

    timeOut = 20.0;
    esuap = 0.1;
    spentTime = 0.0;

    do
    {
        pause,int(esuap*1000);
        spentTime+=esuap;

        if(spentTime<=timeOut)
            stop=0;
        else
            stop=1;
    }
    while((!open(finishFile,"r",1))&&(stop==0));

    remove, scriptFile;
    remove, finishFile;

    if(spentTime>timeOut)
    {
        write,"Query timed out ("+pr1(timeOut)+"s) !"
            return 0;
    }

    red = _yocoCdsReadVizierQuery(outputFile);
    remove, outputFile;

    value2 = yocoStrReplace(red(1,4:)," ","");
    value = array("",numberof(yocoStrSplit(value2(1),"\t")), numberof(value2));
    for(k=0;k<=numberof(value2);k++)
        value(,k) = yocoStrSplit(value2(k),"\t");
    unit = yocoStrSplit(yocoStrReplace(red(1,2)," ",""),"\t");
    if(outputCols=="")
        outputCols = yocoStrSplit(yocoStrReplace(red(1,1)," ",""),"\t");

    return red;
}

/***************************************************************************/
/*   Example of application 1: get the diameter of a star by browing CDS   */
/***************************************************************************/

func yocoCdsQueryStarDiameter(starNames, &finDiamErr, &catalogName, verbose=)
/* DOCUMENT yocoCdsQueryStarDiameter(starNames, &finDiamErr, &catalogName, verbose=)

       DESCRIPTION
       Query the diameter in CHARM2 and Merand et al. from an array of names
       of the same star or using an ESO fits file as an input.

       PARAMETERS
   - starNames  : The input array containing all possible star names
                        you can find about this star, including its coordinates
                        of the star written with the in Vizier standard
   - finDiamErr : The diameter error computed as a weighted average of
                        all diameters errors plus standard deviation
   - catalogName: The catalog name from where comes the diameter
   - verbose    : verbose mode

       RESULTS
       You get the diameter of the star in mas if it exists in
       several optical interferometry catalogs (type
       > print, yocoDIAMETERS_CATALOGS
       to have details)

       EXAMPLES
       diam = yocoQueryStarDiam(starNames="hd-123139",diamErr, catalogName);
       write,diam;
       write,diamErr;
       write,catalogName;
    
       SEE ALSO:
    */
{
// Interferometry diameters catalogs in VIZIER
// Description, VIZIER name, diameter column name, error on the diameter column
yocoDIAMETERS_CATALOGS = [["CHARM (Richichi, 2002, A&A, 386, 492)",
                             "J/A+A/386/492", "cDiam", "e_cDiam"],
                            ["Borde et al. (Borde+, 2002, A&A, 393, 183)",
                             "J/A+A/393/183", "LDD", "e_LDD"],
                            ["CHARM2 (Richichi+, 2005, A&A, 431, 773)",
                             "J/A+A/431/773", "UD", "e_UD"],
                            ["Merand et al. (Merand+, 2005, A&A, 433, 1155)",
                             "J/A+A/433/1155", "UDdiamKs", "e_UDdiam"],
                            ["ESO calibrators programme (Richichi+, 2005, A&A, 434, 1201)",
                             "J/A+A/434/1201","Diam", "e_Diam"],
                            ["CADARS (Pasinetti-Fracassini+ 2001, A&A, 367, 521)",
                             "II/224/cadars","Diam", ""],
                            ["Van Belle et al. (Van Belle et al., 2008, ApJSS, 176, 276)",
                             "J/ApJS/176/276/stars", "theta", "e_theta"]
                            ];

    catalogs = yocoDIAMETERS_CATALOGS(2,);
    nCats = numberof(catalogs);
    diams = yocoDIAMETERS_CATALOGS(3,);
    ediams = yocoDIAMETERS_CATALOGS(4,);
    cols = diams + " " + ediams;
    
    if(is_void(verbose))
        verbose=1;


    // Remove crapy stuff from star name
    starName2 = yocoStrReplace(starNames,["-","_"],[" "," "]);
    replaceThem = ["HR K","HRK",
                   "LR", "LOW", "JHK",
                   "MR K", "MRK", "2.1", "2.3", 
                   "SEQUENCE", "2T", "3T", 
                   "END", "NIGHT", "BRG", "HEI", 
                   "CALIBRATOR", "CAL", "SCI"];
    starName3 = yocoStrReplace(starName2,
                               replaceThem,array("",
                                                 numberof(replaceThem)));

    // Useful for next steps : get star name without spaces
    starNameNoSpace = yocoStrReplace(starName3," ","");

    // Build a name database for queries
    // (trying several cut and parse of the name to match it in vizier)
    tries = [];
    for(k=1;k<=numberof(starName3);k++)
    {
        // try with the full name
        grow,tries,starName3(k);
        
        // try with the name minus the two last letters
        // (e.g. "HD87643-1" --> "HD87643")
        grow,tries,strpart(starName3(k),1:-2);
        
        for(l=8;l>=1;l--)
        {
            // try with three-letters parse of the name plus a space
            // (e.g. "alpha_col-1_toto" --> "alpha col")
            try1 = strpart(starNameNoSpace(k),1:l);
            try2 = strpart(starNameNoSpace(k),l+1:l+3);
            grow,tries, try1+" "+try2;
        }
    }

    // remove multiple names in the tries
    tries = yocoStrRemoveMultiple(tries);
    nTries = numberof(tries);

    // Send a parallel query to all catalogs using all names tries
    outZ = scrZ = finZ = [];
    for(kTry=1;kTry<=nTries;kTry++)
    {
        for(l=1;l<=nCats;l++)
        {
            _yocoCdsSendVizierQuery, catalogs(l), cols(l), tries(kTry), scriptFile, outputFile, finishFile;
            grow,outZ,outputFile;
            grow,scrZ,scriptFile;
            grow,finZ,finishFile;
        }
    }
    
    timeOut = 30.0;
    spentTime = 0.0;
    finished = array("no",nCats*nTries);
    
    diam = diamErr = array(0.0,nCats*nTries);

    startTime = elapsed = array(0.0,3);
    timer,startTime;

    // Read the calibrator diameters, from all catalogs, using a web timeout
    do
    {
        timer,elapsed;
        spentTime=elapsed(3)-startTime(3);
        pause,100;
        for(kCat=1;kCat<=nCats;kCat++)
        {
            for(kTry=1;kTry<=nTries;kTry++)
            {
                red = [];
                cnTry = kCat+(kTry-1)*nCats;
                
                // for all tries, check if the query finished...
                if(fh = open(finZ(cnTry),"r",1))
                {
                    // ...and read the result file
                    redd = _yocoCdsReadVizierQuery(outZ(cnTry));
                
                    titles = redd(,1);

                    test = where(titles==diams(kCat));
                
                    if(numberof(test)!=0)
                    {
                        units = redd(,2);
                        values = redd(,4);
                    
                        diamCol = test(1);
                        diamUnit = units(diamCol);
                    
                        // Get the diameter
                        diam(cnTry) = yocoStr2Double(values(diamCol));
                    
                        if(diamUnit=="arcsec")
                            diam(cnTry) = diam(cnTry)*1e3;
                    
                        diamErrCol = where(titles==ediams(kCat));
                    
                        if(numberof(diamErrCol)!=0)
                        {
                            // Get the diameter error
                            diamErrUnit = units(diamErrCol(1));
                            diamErr(cnTry)  = yocoStr2Double(values(diamErrCol(1)));
                        
                            if(diamErrUnit=="arcsec")
                                diamErr(cnTry) = diamErr(cnTry)*1e3;
                        }

                        // marker to check that all parallel queries have finished
                        finished(cnTry) = "ok";
                    }
                    else
                    {
                        finished(cnTry) = "not ok";
                    }
                }
            }
        }
    }
    while(anyof(finished=="no")&&(spentTime<timeOut));

    // At the end remove unused files
    for(kCat=1;kCat<=nCats*nTries;kCat++)
    {
        remove,outZ(kCat);
        remove,scrZ(kCat);
        remove,finZ(kCat);
    }

    // In case the query timed out
    if(spentTime>timeOut)
    {
        catalogName = "TIMED_OUT!";
        write,"Query timed out ("+pr1(timeOut)+"s) !";
        diam = 0;
        diamErr = 0;
        return 0;
    }
    
    // In case the query failed from all catalogs
    else if(allof(finished=="not ok"))
    {
        catalogName = "NOT_FOUND!";
        // prompt the user to find his calibrator diameter from another way
        // (viscalc, aspro or getcal)
        write,"No entry in the catalogs ! Please try finding the diameter using:\n"+
            "- CalVin    ---> http://www.eso.org/observing/etc\n"+
            "- searchCal ---> http://www.mariotti.fr/searchcal_page.htm\n"+
            "- getCal    ---> http://mscweb.ipac.caltech.edu/gcWeb\n"+
            "and fill in the missing information";
        diam = 0;
        diamErr = 0;
        return 0;                
    }
    
    idx = where(finished=="ok");

    // At the end, use only the catalogs for which the query was successful
    usedCats = array(catalogs,nTries)(idx);
    finCats = yocoStrRemoveMultiple(usedCats,id);

    // The series of diameters from all successful catalogs
    diam = diam(idx)(id);
    finDiam = avg(diam);
    
    // Compute the diameters dispersion
    if(numberof(diam)>1)
        rmsDiam = diam(rms);
    else
        rmsDiam = 0;

    // Get the diameters errors from the catalogs which have one
    diamErr = diamErr(idx)(id);
    idx2 = where(diamErr!=0);

    // Compute the global error from the diameters errors
    if(numberof(idx2)!=0)
        sumVarDiams = (sum(diamErr(idx2)^2))/numberof(diamErr(idx2));
    else
        sumVarDiams = 0;
    
    // the final error is the average variance between the diameters
    // dispersion and the global error. This computation should be
    // a little bit redundant.
    finDiamErr = sqrt(sumVarDiams + rmsDiam^2 ) / sqrt(2);

    // Store the diameters serie in a compact form
    catalogName = "";
    if(numberof(finCats)>1)
        for(k=1;k<=numberof(finCats);k++)
        {
            catalogName = catalogName + finCats(k)+":"+pr1(diam(k))+"+-"+pr1(diamErr(k));
            if(k<numberof(finCats))
                catalogName = catalogName + ",";
        }
    else
        catalogName = finCats(1)+":"+pr1(diam(1))+"+-"+pr1(finDiamErr(1));

    // Verbose output diameter and error
    if(verbose)
        write,"Found a diameter of "+pr1(finDiam)+"+-"+pr1(finDiamErr)+" in "+catalogName;

    return finDiam;
}




/***************************************************************************/
/*    Example of application 2: get the SED of a star by browing CDS       */
/***************************************************************************/

func yocoCdsGetSED(starName, outFile=)
/* DOCUMENT yocoCdsGetSED(starName, outFile=)

       DESCRIPTION

       PARAMETERS
   - starName: 
   - outFile : 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    // Useful for next steps : get star name without spaces
    starNameNoSpace = yocoStrReplace(starName," ","");

    cats = [// V mag catalogs
            "I/5", "I/62C", "I/78", "I/97", "I/113A", "I/116",
            "I/131", "I/149A", "I/196", "I/197A",
            "I/238A", "I/239", "I/250", "I/256", "I/260","I/265",
            "I/271", "I/274", "I/280", "I/289", "I/294",
            "I/297", "I/298", "I/305", "I/306", "I/312",
            "II/5A", "II/168", "II/224", "II/226", "II/237","II/264",
            "III/17", "III/200B", "III/221A", "III/223", "III/231", "III/252", "IV/22",
            "IV/27", "V/50", "V/53A",
            "V/109", "V/117", "V/125","IX/10A", "J/ApJ/582/1011",
            "J/ApJ/595/1206", "J/A+A/352/555",
            "J/A+A/371/943", "J/A+A/386/492", "J/A+A/417/651",
            "J/A+A/431/773", "J/A+A/438/139",
            "J/A+A/465/271", "J/A+A/483/903", "J/AJ/121/2148",
            "J/AJ/129/1063", "J/AJ/130/1680",
            "J/MNRAS/326/959", "J/AZh/83/821", "J/PASP/120/1128",
            // B mag catalogs
            "I/252","J/A+A/427/387",
            // I mag catalogs
            "I/284",
            // JHK catalogs
            "B/denis", "II/246", "II/7A",
            // UV catalogs
            "II/97","II/59","III/39",
            // FIR catalogs
            "V/98", "V/114", "I/270", "VI/111", "II/125", "II/94", "II/126",
            "II/225", "II/275", "III/197",
            "J/other/NewA/9.509", "VII/237"
            ];

    write,"sending a global query to vizier";
    nCats = numberof(cats);

    outZ = scrZ = finZ = [];
    for(l=1;l<=nCats;l++)
    {
        _yocoCdsSendVizierQuery,cats(l), "", starName, scriptFile, outputFile, finishFile;
        grow,outZ,outputFile;
        grow,scrZ,scriptFile;
        grow,finZ,finishFile;
    }

    timeOut = 120;
    finished = array("no",nCats);
    spentTime = 0.0;
    startTime = elapsed = array(0.0,3);
    timer,startTime;
    timSt = 0.0;
    dabouet = 2;
    write,pr1(numberof(where(finished=="no")))+" catalogs left to query ...";
    do
    {
        // pause,500;
        timer,elapsed;
        spentTime=2*abs(elapsed(2)-startTime(2));

        timr = abs(spentTime-timSt);
        // write,timr,spentTime;

        if(timr>dabouet)
        {
            timSt = spentTime;
            newpr1 = pr1(numberof(where(finished=="no")))+" catalogs left to query ...";
            if(oldpr1==newpr1)
            {
                dabouet = dabouet*2;
                write,"still waiting for the same catalogs...";
            }
            else
            {
                dabouet = 1;
                write,newpr1;
                oldpr1 = newpr1;
            }
        }

        for(k=1;k<=nCats;k++)
        {
            if(open(finZ(k),"r",1))
                finished(k)="yes";
        }
    }
    while(anyof(finished=="no")&&(spentTime<timeOut));

    if(spentTime>timeOut)
    {
        for(k=1;k<=nCats;k++)
        {
            remove,outZ(k);
            remove,finZ(k);
            remove,scrZ(k);
        }
        readableError,"timed out !";
    }

    write,"Got all catalogs data. reading..."; 

    redd=[];
    for(k=1;k<=nCats;k++)
    {
        grow, redd, "";
        if(fh = open(outZ(k),"r",1))
        {
            while(line=rdline(fh))
                grow, redd, line;
            close,fh;
        }
    }

    pause,100;
    for(k=1;k<=nCats;k++)
    {
        remove,outZ(k);
        remove,finZ(k);
        remove,scrZ(k);
    }

    N = numberof(redd);
    k=1;
    colsComments = colsUnits = colsNames = colsValues = catNames = catTitles = [];
    // catBlackList = ["I/271", "I/297", "II/7A", "II/246", "I/289", "J/ApJS/154/673"];
    catBlackList = [""];
    while(k<N)
    {
        cat = [];
        do
        {
            grow,cat,redd(k);
            k++;
        }
        while((k<=N)&&(redd(k)!=""));

        if(!is_void(cat))
        {
            if(anyof(strmatch(cat,"#RESOURCE")))
            {
                colsCom = cat(where(strmatch(cat,"#Column")));
                catName = cat(where(strmatch(cat,"#Name")))(1);
                catName = yocoStrReplace(catName,"#Name: ","");
                catTitle = cat(where(strmatch(cat,"#Title")))(1);
                catTitle = yocoStrReplace(catTitle,"#Title: ","");

                if(allof(catName!=catBlackList))
                {

                    // Magnitude test
                    test = (strmatch(colsCom,"magnitude", 1)|
                            strmatch(colsCom,"flux", 1)|
                            strmatch(colsCom,"B-V", 1)|
                            strmatch(colsCom,"U-B", 1)|
                            strmatch(colsCom,"standard deviation",1));
                    if(anyof(test))
                    {
                        if((!strmatch(cat(0),"#"))&
                           (!strmatch(cat(-1),"#"))&
                           (!strmatch(cat(-2),"#"))&
                           (!strmatch(cat(-3),"#")))
                        {
                            colsUn = yocoStrSplit(cat(-2),"\t");
                            colsNam= yocoStrSplit(cat(-3),"\t");
                            colsVal= yocoStrSplit(cat(0),"\t");
                            colsCom = colsCom(1:numberof(colsUn));
                            test = test(1:numberof(colsUn));

                            if(anyof(strmatch(colsCom,"B-V")))
                                write,colsNam(where(strmatch(colsCom,"B-V")));

                            test2 = (
                                     strmatch(colsCom,"B-V",1)|
                                     strmatch(colsCom,"U-B",1)|
                                     strmatch(colsUn,"mag",1)|
                                     strmatch(colsUn,"Jy", 1)|
                                     strmatch(colsUn,"w/m2", 1));

                            if(anyof(test&test2))
                            {
                                grow,catNames,array(catName,numberof(where(test&test2)));
                                grow,catTitles,array(catTitle,numberof(where(test&test2)));
                                grow,colsComments,colsCom(where(test&test2));
                                grow,colsUnits,colsUn(where(test&test2));
                                grow,colsNames,colsNam(where(test&test2));
                                grow,colsValues,colsVal(where(test&test2));
                            }
                        }
                    }
                }
            }
        }
    }

    write,"finished";

    if(numberof(colsNames)==0)
    {
        write,"WARNING ! No data found ! Exiting...";
        return 0;
    }

    SED = WLEN = CATNAME = COLVALUE = COLNAME = COLUNIT = CATCODE = [];

    N = numberof(colsNames);

    for(kc=1;kc<=N;kc++)
    {
        if(_yocoCdsParseFlux(catNames(kc), catTitles(kc), colsComments(kc),
                      colsUnits(kc), colsNames(kc), colsValues(kc), flux, wavelength))
        {
            if(flux!=0)
            {
                write,colsNames(kc), ":", colsValues(kc), colsUnits(kc),
                    "at",wavelength,"m, in", catNames(kc),":", catTitles(kc);

                grow,SED,flux;
                grow,WLEN,wavelength;
                grow,CATNAME, catTitles(kc);
                grow,COLVALUE,colsValues(kc);
                grow,COLUNIT, colsUnits(kc);
                grow,COLNAME, colsNames(kc);
                grow,CATCODE,catNames(kc);
            }
        }
        // else
        // write,colsNames(kc), ":", colsValues(kc), colsUnits(kc),
        // ", in", catNames(kc),":", catTitles(kc);
    }

    if(is_void(outFile))
    {
        outFile = HOME+starNameNoSpace+".sed";
    }
    if(open(outFile,"r",1))
    {
        write,"WARNING ! File "+outFile+
            " is in the way, please remove or change its name before continuing...";
        return 0;
    }

    write,"Writing SED ASCII file "+outFile;
    fh = open(outFile,"w");
    write,fh,"# Flux(W/m^2/m) Wavelength(m) Catalog_Code Column_Name Column_Value Column_Unit Catalog_Reference";
    write,fh,"# _____________________________________________________________________________________________";
    write,fh,SED,WLEN,CATCODE,COLNAME,COLVALUE,COLUNIT,yocoStrReplace(CATNAME,[" "],["_"]);
    close,fh;

    return 1;
}

/*************************************************************/

func yocoCdsPlotSED(ASCIIfile)
/* DOCUMENT yocoCdsPlotSED(ASCIIfile)

       DESCRIPTION

       PARAMETERS
   - ASCIIfile: 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    if(yocoGuiFileChooser("Choose a file", ASCIIfile) == 0)
        return 0;
    data =yocoFileReadAscii(ASCIIfile);
    SED = yocoStr2Double(data(1,3:));
    WLEN = yocoStr2Double(data(2,3:));

    fma;
    plg,SED,WLEN,type="none",marker='\2';
    logxy,1,1;
    limits;
    xytitles,"Wlen (m)", "Flux (W/m^2^/m)";
}

/*************************************************************/

func _yocoCdsParseFlux(catName, catTitle, colsComment, colsUnit, colsName, colsValue, &Uflux, &Uwlen)
/* DOCUMENT _yocoCdsParseFlux(catName, catTitle, colsComment, colsUnit, colsName, colsValue, &Uflux, &Uwlen)

       DESCRIPTION

       PARAMETERS
   - catName    : 
   - catTitle   : 
   - colsComment: 
   - colsUnit   : 
   - colsName   : 
   - colsValue  : 
   - Uflux      : 
   - Uwlen      : 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    // Select system based on the catalog

    // B & V magnitudes : Johnson system
    system = yocoAstroJohnsonSystem;
    denis ="B/denis";
    twomass = "II/246";

    if(strmatch(catName,denis,1))
    {
        system.band.I = yocoAstroDenisSystem.band.I;
        system.band.If0 = yocoAstroDenisSystem.band.If0;
        system.band.J = yocoAstroDenisSystem.band.J;
        system.band.Jf0 = yocoAstroDenisSystem.band.Jf0;
        system.band.K = yocoAstroDenisSystem.band.K;
        system.band.Kf0 = yocoAstroDenisSystem.band.Kf0;
    }
    else if(strmatch(catName,twomass,1))
    {
        system.band.J = yocoAstro2MASS_System.band.J;
        system.band.Jf0 = yocoAstro2MASS_System.band.Jf0;
        system.band.H = yocoAstro2MASS_System.band.H;
        system.band.Hf0 = yocoAstro2MASS_System.band.Hf0;
        system.band.K = yocoAstro2MASS_System.band.K;
        system.band.Kf0 = yocoAstro2MASS_System.band.Kf0;
    }

    //All the different possible magnitude bands
    bands = ["m148","m154","m161","m166","m172","m181","m192","m204","m219","m245","m280","m360",
             "F2740", "F2365", "F1965", "F1565",
             "15N","15W","18","22","25","33"];
    wlen = yocoStr2Double(strpart(bands,2:))*yocoAstroSI.nm;
    wlen(13:16) = wlen(13:16)/10;
    wlen(-5:-4) = yocoStr2Double(strpart(bands(-5:-4),:-1))*yocoAstroSI.nm*10;
    wlen(-3:0) = yocoStr2Double(bands(-3:0))*yocoAstroSI.nm*10;
    step = 20;
    for(K=1;K<=70;K++)
    {
        grow,bands,"F"+pr1((K-1)*20+1360);
        grow,wlen,((K-1)*20+1360)*yocoAstroSI.nm/10;
    }

    grow,bands,["U","P","B","V","R","I","J","H","K","L","M","N","Q"];
    grow,wlen,[system.band.U,
               system.band.P,
               system.band.B,
               system.band.V,
               system.band.R,
               system.band.I,
               system.band.J,
               system.band.H,
               system.band.K,
               system.band.L,
               system.band.M,
               system.band.N,
               system.band.Q];

    grow,bands,["Fnu_12","Fnu_25","Fnu_60","Fnu_100", "F1.25um","F2.2um","F3.5um","F4.9um","F12um",
                "F25um","F60um","F100um","F140um","F240um"];
    grow,wlen,[12,25,60,100,1.25,2.2,3.5,4.9,12,25,60,100.,140,240]*yocoAstroSI.mum;

    grow,bands, ["S80cm","S20cm","S6cm"];
    grow,wlen, [80,20,6]*yocoAstroSI.cm;

    curBand = where((colsName==bands+"mag")|(colsName==bands));

    grow,bands, ["U-B","B-V","V-R","V-K","R-I"];
    grow,wlen, [0,0,0,0,0]*yocoAstroSI.cm;

    if(yocoStr2Double(colsValue)==0)
        return 0;

    if(yocoStr2Double(colsValue)==99.9)
        return 0;

    if(numberof(curBand)==0)
        return 0;

    Uwlen = wlen(curBand)(1);

    if(colsUnit=="mag")
    {
        if(strmatch(catName,"II/97",1))
        {
            Uflux = 10^((yocoStr2Double(colsValue) + 26.10) / -2.5)/1e-9;
        }
        else if(strmatch(colsName,"12")&&!strmatch(catTitle,"UV"))
        {
            Uflux = yocoAstroMagToFlux(yocoStr2Double(colsValue), "K12");
        }
        else if(strmatch(colsName,"25")&&!strmatch(catTitle,"UV"))
        {
            Uflux = yocoAstroMagToFlux(yocoStr2Double(colsValue), "K25");
        }
        else if(strmatch(colsName,"60")&&!strmatch(catTitle,"UV"))
        {
            Uflux = yocoAstroMagToFlux(yocoStr2Double(colsValue), "K60");
        }
        else if(strmatch(colsName,"100")&&!strmatch(catTitle,"UV"))
        {
            Uflux = yocoAstroMagToFlux(yocoStr2Double(colsValue), "K100");
        }
        else
        {
            Uflux = yocoAstroMagToFlux(yocoStr2Double(colsValue),
                                       bands(curBand)(1),
                                       system);
        }
    }
    else if(strmatch(colsUnit,"10mW/m2/nm",1))
    {
        Uflux = yocoStr2Double(colsValue)/100/1e-9;
    }
    else if(strmatch(colsUnit,"10-14W/m2/nm",1))
    {
        Uflux = yocoStr2Double(colsValue)*1e-3;
    }
    else if(colsUnit=="Jy")
    {
        Uflux = yocoAstroJyToFlux(yocoStr2Double(colsValue), Uwlen);
    }
    else if(colsUnit=="mJy")
    {
        Uflux = yocoAstroJyToFlux(yocoStr2Double(colsValue)/1000.0, Uwlen);
    }
    else
        return 0;

    if(Uflux==0)
        return 0;

    return 1;
}
