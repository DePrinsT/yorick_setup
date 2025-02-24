/******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Files manipulation tools
 *
 * "@(#) $Id: yocoFile.i,v 1.27 2011-01-13 13:02:45 fmillour Exp $"
 *
 ******************************************************************************/

func yocoFile(void)
/* DOCUMENT yocoFile
   
   DESCRIPTION
     Files manipulation tools from LAOG-Yorick contribution project.
     
   VERSION
     $Revision: 1.27 $

   FUNCTIONS
   - yocoFile              : 
   - yocoFileExtractHiddens: Gets hidden and non-hidden files and/or
                                directories
   - yocoFileListByTime    : Returns a list of files sorted in order of date
   - yocoFileListDir       : Lists the content of a directory.
   - yocoFileListSubDirs   : 
   - yocoFileReadAscii     : Reads the ASCII file, 
   - yocoFileSplitName     : Split file name into path, root file name and
                                extension.

   SEE ALSO
   yoco
*/
{
    version = strpart(strtok("$Revision: 1.27 $",":")(2),2:-2);
    if(am_subroutine())
    {
        help, yocoFile;
    }   
    return version;
} 

/************************************************************************/
  
func yocoFileReadAscii(fileName, &data, nbCols=, delimiter=, fixedColWidth=, gz=, useSread=)
/* DOCUMENT yocoFileReadAscii(fileName, &data, nbCols=)

   DESCRIPTION
     Reads the ASCII file, name <fileName>, and returns the columns contained in
     a yorick-like array.

   PARAMETERS
   - fileName: name of the file, where information are stored.
   - data    : string array where information are stored.
   - nbCols  : outdated parameter

   RETURN VALUES
     String array where information are stored.

   EXAMPLES
     Read the first column of the file named "data.txt"
     > yocoFileReadAscii, "data.txt", data, nbCols=1;
*/
{
    if(is_void(useSread))
        useSread=1;

    if(is_void(delimiter))
        delimiter=" ";

    if(!gz)
        fi = open(fileName);
    else if(gz)
        fi = popen("gunzip -c "+fileName, 0);
    
    if (!is_void(fi))
    {
        maxLines = 32768;
        datline = [];
        do
        {
            dat   = rdline(fi, maxLines);
            datOK = where(dat==string(nil))
            grow,datline,dat;
        }
        while(numberof(datOK)==0);
        
        close, fi;
        datline = datline(where(datline));

        if(is_void(datline))
            return [];

        cols     = yocoStrSplit(datline(1), delimiter, multDel=1);
        realCols = where(cols!=string(nil));
        if(is_void(nbCols))
            nbCols = numberof(realCols);
        
        if (numberof(datline)==0)
        {
            data = "";
            return -1;
        }

        // Treat the case of fixed columns width files
        if(!is_void(fixedColWidth))
        {
            start = 1;
            stop=[];
            for (i = 1; i <= numberof(fixedColWidth)-1; i++)
            {
                grow,start, start(i) + fixedColWidth(i);
            }
            stop = start+fixedColWidth-1;
            data = strtrim(strpart(datline,transpose([start,stop])(*)-1));
        }
        else
        {
            // define format of line
            // frmt = sum(array("%s"+delimiter,numberof(cols)-1))+"%s";
            data = array(string, nbCols, numberof(datline));
            line = array(string, nbCols);
            //write,datline
            for (i = 1; i <= numberof(datline); i++)
            {
                if(useSread==1)
                    sread, datline(i), line;
                else
                {
                    line = yocoStrSplit(datline(i), delimiter, multDel=0);
                    // if(line(0)==string(nil))
                    //     line = line(:-1);
                    // if(line(1)==string(nil))
                    //     line = line(2:);
                    // if(numberof(line)>1)
                    //     if(line(1)=="")
                    //         line = line(2:);
                    nd = numberof(data(,1));
                    while(numberof(line)<nd)
                        grow,line,"";
                    if(numberof(line)>nd)
                        line = line(:nd);
                    // //sread, datline(i), line,format=frmt;
                }
                data(,i) = line;
            }
        }
    }

    
    return data;
}
  

/************************************************************************/

func yocoFileListDir(&directory, &shownFiles, &shownDirs, &hiddenFiles, &hiddenDirs, listType=)
/* DOCUMENT yocoFileListDir(&directory, &shownFiles, &shownDirs, &hiddenFiles, &hiddenDirs, listType=)
                            &hiddenDirs, listType=)

   DESCRIPTION
     This functions returns all the files contained in the current directory
     sorted with the directories first and the hidden files (beginning with ".")
     last.
     
   PARAMETERS
   - directory  : directory to be listed. By default, the current one.
   - shownFiles : visible files of 'directory'
   - shownDirs  : visible directories of 'directory'
   - hiddenFiles: hidden files of 'directory'
   - hiddenDirs : hidden directories
   - listType   : OPTIONAL indicating if files have to be sorted by name 
                     ("byName"), or by date ("byDate"); by default is "byName"
     
   EXAMPLES
     Lists current directory
     > yocoFileListDir, ".", shownFiles, shownDirs, hiddenFiles, hiddenDirs
*/
{
    if (is_void(directory))
    {
        directory = cd(".");
    }

    if (is_void(listType))
    {
        listType = "byName";
    }

    if (listType == "byName")
    {
        files = lsdir(directory, dirs);
        yocoFileExtractHiddens, files, dirs, shownFiles, shownDirs, hiddenFiles,
            hiddenDirs,sorting=1;
    }
    else if (listType == "byType")
    {
        files = lsdir(directory, dirs);
        suffixes = yocoStrrtok(files, ".")(2, );
        sortFiles = sort(suffixes);
        files = files(sortFiles);
        yocoFileExtractHiddens, files, dirs, shownFiles, shownDirs, hiddenFiles,
            hiddenDirs,sorting=0;
    }
    else if (listType == "byDate")
    {
        files = yocoFileListByTime(directory, dirs);
        yocoFileExtractHiddens, files, dirs, shownFiles, shownDirs, hiddenFiles,
            hiddenDirs,sorting=0;
    }
}
  
  
/************************************************************************/
  
func yocoFileListSubDirs(directory, &subdirectories, verbose=)
/* DOCUMENT yocoFileListSubDirs(directory, &subdirectories, verbose=)

   DESCRIPTION
   Provides a list of all subdirectories of the current directory.
   This function works recursively, so take care to not have link loops.

   PARAMETERS
   - directory     : base directory
   - subdirectories: an array containing the names of all subdirectories of "directory"
   - verbose       : verbose mode (default 1)

   RETURN VALUES
   an array containing the names of all subdirectories of "directory"

   EXAMPLES
   yocoFileListSubDirs,cd("~"),subdirs
   write,subdirs

   SEE ALSO lsdir
*/
{
    if(is_void(verbose))
        verbose=1;
    
    // Timer used for verbose purposes
    extern elapsed, elapsed2, tmpElapsed;
    if(am_subroutine())
    {
        write,"Listing sub-directories";
        elapsed = tmpElapsed = elapsed2 = array(0.0,3);
        timer, elapsed;
        namsub = 0;
        subdirectories = array("",2);
    }
    else
        namsub = 1;

    // This is where the array of the precedent run of the program
    // subdirectories is effectively filled
    grow, subdirectories, directory;

    for(k=1;k<=numberof(directory);k++)
    {
        // Listing all subdirectories of the current directory
        files = lsdir(directory(k), subdirs);

        // Verbose stuff
        if(namsub)
        {
            timer, elapsed2;
            if((elapsed2(3)-tmpElapsed(3))>5.)
            {
                curNumber   = numberof(subdirectories(where(subdirectories!="")));
                totalNumber = numberof(subdirs)+curNumber;
                timer,tmpElapsed;
                if(verbose)
                    write,"Found "+pr1(curNumber)+" directories in "+pr1(elapsed2(3)-elapsed(3))+"s";
            }
        }

        // Recursive calls of the same function to list ALL subdirectories
        if(!is_void(subdirs))
        {
            temp = yocoFileListSubDirs(directory(k) + subdirs + "/", subdirectories, verbose=verbose);
        }
    }
    return subdirectories;
}

  
/************************************************************************/
  
func yocoFileExtractHiddens(files, dirs, &shownFiles, &shownDirs, &hiddenFiles, &hiddenDirs, sorting=)
/* DOCUMENT yocoFileExtractHiddens(files, dirs, &shownFiles, &shownDirs, &hiddenFiles, &hiddenDirs, sorting=)
                                   &hiddenFiles, &hiddenDirs, sorting=)

   DESCRIPTION
     List files and/or directories according to the fact they are visible or
     hidden.
     
   PARAMETERS
   - files      : files to be treated
   - dirs       : directories to be treated
   - shownFiles : list of visible files
   - shownDirs  : list of visible directories
   - hiddenFiles: list of hidden files (i.e. beginning with ".")
   - hiddenDirs : list of hidden directories (i.e. beginning with ".")
   - sorting    : OPTIONAL parametre equal to 1 if files have to be sorted
                     by name.

   RETURN VALUES
     Different arrays containing shown and hidden files (starting with .---) in
     the UNIX Namefile system.
     
   EXAMPLES
     > files = [".file1", ".file2", "file1", "file2"]
     > dirs  = [".dir1", ".dir2", "dir1", "dir2"]
     > yocoFileExtractHiddens, files, dirs, shownFiles, shownDirs, hFiles, hDirs
     > shownFiles
     ["file1","file2"]
     > shownDirs
     ["dir1","dir2"]
     > hFiles
     [".file1",".file2"]
     > hDirs
     [".dir1",".dir2"]
*/
{
    if ((files != 0) && (!is_void(files)))
    {
        if (sorting == 1)
        {
            files = files(sort(files));
        }
        if (!is_void(where(strmatch(strpart(files, 1:1), "."))))
        {
            hiddenFiles = files(where(strmatch(strpart(files, 1:1), ".")));
        }
        if (!is_void(where(!strmatch(strpart(files, 1:1), "."))))
        {
            shownFiles = files(where(!strmatch(strpart(files, 1:1), ".")));
        }
    }

    if (!is_void(dirs))
    {
        if (sorting == 1)
        {
            dirs = dirs(sort(dirs));
        }
        if (!is_void(where(strmatch(strpart(dirs, 1:1), "."))))
        {
            hiddenDirs = dirs(where(strmatch(strpart(dirs, 1:1), ".")));
        }
        if (!is_void(where(!strmatch(strpart(dirs, 1:1), "."))))
        {
            shownDirs = dirs(where(!strmatch(strpart(dirs, 1:1), ".")));
        }
    }
}
  
/************************************************************************/
  
func yocoFileListByTime(directory, &dirs)
/* DOCUMENT yocoFileListByTime(directory, &dirs)

   DESCRIPTION
     Returns a list of files sorted in order of date
   
   PARAMETERS
   - directory: directory where files to sort are located
   - dirs     : list of sorted directories
     
   RETURN VALUES
     An array of files sorted by date
*/
{
    system,"ls -trap > /tmp/.dirContent";
    yocoFileReadAscii, "/tmp/.dirContent", files, nbCols=1;
    files = files(where(files!="./"));
    files = files(where(files!="../"));
    files = files(where(files!=string(nil)));
    dirs = files(where(strmatch(files, "/")));
    grow, dirs, files(where(strmatch(files, "@")));

    if(!is_void(dirs))
    {
        dirs = strtok(dirs, "/")(1, );
        dirs = strtok(dirs, "@")(1, );
    }
    
    files = files(where(!strmatch(files, "/")));
    if(!is_void(files))
    {
        files = files(where(!strmatch(files, "@")));
    }
    
    system, "rm /tmp/.dirContent";
    return files;
}


/***************************************************************************/

func yocoFileSplitName(path, &dir, &name, &ext, &file, check=)
/* DOCUMENT yocoFileSplitName(path, &dir, &name, &ext, &file, check=)

   DESCRIPTION
     Split file name into 3 strings: the directory where it is stored, the name
     itself and the file extension. From an array of strings containing full
     path name, return 3 arrays of strings containing the corresponding
     directories, names and extensions.
     
     When file is compressed (with .gz or .Z extension), the returned file extension
     will include primary extension and ".gz" or ".Z", see parameter "check="
     
     It is always possible to reconstruct the original 'path'
     by doing:   dir + name + ext;
   
   PARAMETERS
   - path : array containing complete file pathnames
   - dir  : array containing location directories
   - name : array containing names
   - ext  : array containing extensions
   - file : array containing names.extensions
   - check: optional string parameter to specify a list of
               special extensions to not be considered as
               real extensions. Default is check=[".gz".".Z"],
               see its effect on the example (2 last lines).
               Putting check=0 will remove this effect.
             
   EXAMPLES
     /d1//d2/name.ext ->   /d1//d2/       name       .ext      
     dir1//dir2/      ->   dir1//dir2/                         
     /dir1/dir2//     ->   /dir1/dir2//                         
     dir1/dir2/       ->   dir1/dir2/                          
     /dir/name.ext    ->   /dir/          name       .ext      
     dir/name.        ->   dir/           name       .         
     dir/name         ->   dir/           name                 
     /dir/name.gz     ->   /dir/          name       .gz       
     dir//~/name      ->   dir//~/        name                 
     ./dir/name       ->   ./dir/         name                 
     ./name           ->   ./             name                 
     .name            ->   ./             .name                
     /.name           ->   /              .name                
     /                ->   /                                   
     ./.              ->   ./             .                    
                      ->   ./                                   
     /.name.ext       ->   /              .name      .ext      
     name..ext        ->   ./             name.      .ext      
     /name.ext.gz     ->   /              name       .ext.gz   
     /name.ext..gz    ->   /              name.ext   ..gz      
     /name..ext.gz    ->   /              name.      .ext.gz   
*/
{
  /* Prepare the arrays, default check only *.gz files */
  if (is_void(check)) 
  {
    check = [".gz",".Z"];
  }
  if (is_void(path) ) 
  {
      return;
  }
  path = strtrim( path + "" );

  /* Found the last '/' */
  id = strfind("/",path,back=1);
  
  /* Found the directory, Keep the last '/' if any */
  id(1,) += (id(2,)!=-1);
  dir = strpart(path,transpose([0,id(1,)]));

  /* Change the void dir by './' */
  dir += ["","./"](1 + (dir==""));
    
  /* Found the file */
  id(2,) += (id(2,)==-1);
  file = strtrim(strpart(path,transpose([id(2,),strlen(path)])),2,blank=" ")+"";

  /* Found the last '.' and trick it */
  len = strlen(file);
  id = strfind(".",file,back=1);
  id(1,) += len*(id(2,)==-1);
  id(2,) -= ( id(2,)!=-1 & id(1,)!=len);
  /* Found the filename */
  name = strpart(file,transpose([0,id(1,)]))+"";
  /* Found the ext */
  ext = strpart(file,transpose([id(2,),len]))+"";

  /* Check if some special extension have to be ignored */
  for (i=1;i<=numberof(check);i++)
  {
      if (is_array((idGz=where(ext==check(i)))))
      {
          // Found the previous '.' and trick it
          tmp = strpart( file(idGz),1:-strlen(check(i)));
          len = strlen(tmp);
          id = strfind(".",tmp,back=1);
          id(1,) += len*(id(2,)==-1);
          id(2,) -= ( id(1,)!=0 & id(1,)!=len);
          // Found the filename
          name(idGz) = strpart(tmp,transpose([0,id(1,)]))+"";
          // Found the ext, add the check 
          ext(idGz) = strpart(tmp,transpose([id(2,),strlen(tmp)]))+check(i);
      }
  }
  
  /* Last check -> extension but no name */
  if ( is_array((id=where( name=="" & ext!=""))) )
  {
      name(id) = ext(id);
      ext(id) = "";
  }
  
  return name;
}

/***************************************************************************/
