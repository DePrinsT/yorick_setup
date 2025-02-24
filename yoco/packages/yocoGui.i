/******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Graphical User Interface tools 
 *
 * "@(#) $Id: yocoGui.i,v 1.70 2011-04-12 18:24:59 fmillour Exp $"
 *
 ******************************************************************************/

func yocoGui(void)
/* DOCUMENT yocoGui

       DESCRIPTION
       Graphical User Interface tools from LAOG-Yorick contribution project.

       VERSION
       $Revision: 1.70 $

       CAUTIONS
       *  THIS IS AN EXPERIMENTAL GUI FOR YORICK...
       *  COMPATIBILITY IS NOT WARRANTED IN THE FUTURE...
       *  USE IT AT YOUR OWN RISK !
   
       REQUIRE
       - button.i

       FUNCTIONS
   - yocoGui                   : This script
   - yocoGuiBrowser            : Interactive file/directory browser
   - yocoGuiBrowserRulesManager: Public function to manage custom rules
                                     in the file browser
   - yocoGuiBrowserUpdate      : Refresh function for the browser
   - yocoGuiChangeNumber       : Display a GUI to change an array of numbers
   - yocoGuiErrorBox           : Display an error box with custom text
   - yocoGuiFileChooser        : Interactive [deprecated] file browser
   - yocoGuiInfoBox            : Display an info box with custom text
   - yocoGuiInitTime           : For progress box plot vs time: init
   - yocoGuiPlotScrollBar      : Plots a scroll bar
   - yocoGuiProgressBox        : Plot a progress box with a scroll bar
   - yocoGuiTestScrollBar      : Check whether mouse is in scroll bar or not.
   - yocoGuiWinKill            : Kills all windows or given one(s)

       SEE ALSO
       yoco
    */
{
    version = strpart(strtok("$Revision: 1.70 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoGui;
    }   
    return version;
} 

require,"button.i";

/***************************************************************************/

struct yocoGUI_SCROLL_BAR 
{
    double x, y; /* NDC coordinates of button center */
    double length;
    double height;
    double percent; 
    int    orient; 
    string style;
};

/***************************************************************************/

func yocoGuiInfoBox(text, butText=, win=, click=, butReturn=, dpi=, justify=)
/* DOCUMENT yocoGuiInfoBox(text, butText=, win=, click=, butReturn=, dpi=, justify=)
       
       DESCRIPTION
       Plots an informative graphical window, and the appropriate
       buttons you want to.
       
       PARAMETERS
   - text     : the text you want to display in the info box; default is
                    "I want to click \"OK\""
   - butText  : the text inside the button(s) to make a choice; default is
                    "OK".
   - win      : choose any window you want. Default is number 0.
   - click    : if click is 0, then only display text, with no confirmation
                    button. Default is 1.
   - butReturn: Value that should be returned by the function, in the same
                    order that text in butText
   - dpi      : size of the window, see 'help, window' (better between 30-75)
   - justify  : 

       EXAMPLES
       Plot a box with a question
  
       > yocoGuiInfoBox( "!!! ATTENTION !!!",
       butText=["OK, modify","Cancel, do nothing"],
       butReturn=[1,0]);
     
       Plot an informative box
     
       > yocoGuiInfoBox, "The gentleman understands righteousness,"+
       " the petty man understands interest.\n"+
       "Confucius (551 B.C. - 479 B.C.)", click=0
    */
{
    /* Default for Win */
    if(is_void(win))
        win=0;

    if(is_void(justify))
        justify="C";

    /* Kill this windows anyway */
    winkill,win;

    /* Default for text */
    if (is_void(text)) text = "I want to click \"OK\"";

    /* Write message in standard terminal to get information afterwards */
    yocoLogTest,"yocoGuiInfoBox information:", text;

    /* Default for click */
    if (is_void(click)) click=1;

    /* Default for butTest */
    if (is_void(butText)) butText = "OK";

    /* Default for butReturn */
    if (is_void(butReturn)) butReturn = butText;

    /* Default for justify */
    if (is_void(justify)) justify="C";

    /* Test if comformable */
    if ( numberof(butReturn) != numberof(butText) )
        error, "butText and butReturn should be conformable";

    nbButtons = numberof(butText);

    /* default for dpi. The dpi should be 30<dpi<75
       otherwise some X11 will screw up */
    if(is_void(dpi)) dpi = 75;

    /* Window parameter :
       - 0.8x1.03 in NDX
       - int(638.0*dpi/75); */
    winHeightNDX = 1.03;
    winWidthNDX  = 0.8;
    winHeightCenterNDX = 0.63;
    winHeight    = int(825.0*dpi/75);
    winWidth     = int(638.0*dpi/75);
    
    /* We force'courierB', with size 24, because the font size is
       the same for capital/normal letters and is generaly known by
       every X11 server */
    height  = 16;
    height0 = 24.0;
    font   = "courierB";
    
    /* Which correspond to 46.5x37 char per pages */
    lettersPerLine  = 46.5*height0/height - 5;
    linesPerPage    = 37.0*height0/height;
    letterWidthNDX  = winWidthNDX  / lettersPerLine;
    letterHeightNDX = winHeightNDX / linesPerPage;
    letterHeight    = winHeight    / linesPerPage;
    
    /* Crop the text in words at the window width, by 
       looping on the char array */
    inc=1; i=1; last=0;
    textChar = strchar(text(*));
    
    while ( i<numberof(textChar) )
    {
        /* Found last blanck position */
        if ( textChar(i)==' ' )
            last=i;

        /* If new line, reset the counter of letter */
        if ( textChar(i)=='\n' )
            inc = last = 0;

        /* Check if larger than the number of letter (max-10) */
        if ( inc > (lettersPerLine-10) )
        {
            /* Cut at previous word... or right now if word larger than the line... */
            if (last)
                textChar(last) = '\n';
            else
                textChar = grow(textChar(:i), ['-','\n','-'], textChar(i:) );
        
            /* Reset counter of letter */
            inc = last = 0;
        }
      
        inc++;
        i++;
    }

    /* Reconstruct the string */
    text = strchar(textChar(*));

    /* Get buttons sizes in NDX = the letter size */
    dxBut = max(strlen(butText)+1) * letterWidthNDX / 2.0 ;
    dyBut = 1.2*letterHeightNDX / 2.0;

    /* Get text and button Xpos in NDX = centered */
    xBut  = winWidthNDX / 2;

    /* Found the relative Ypos of text and buttons in NDX
       if click==0, buttons are not displayed */
    yBut  = 2.*letterHeightNDX  * (click==1);
    yText = yBut + 1.5*letterHeightNDX;
    
    /* Found the total hight of the plot in NDX */
    yMax  = yText + (numberof(where(textChar=='\n')) + 2) * letterHeightNDX;
    
    /* Shift them to have them centered on the displayed window */
    center = winHeightNDX - (yMax/2);
    center = max( min( winHeightCenterNDX, center ), winHeightNDX/2 );
    yBut  += center - yMax/2;
    yText += center - yMax/2;

    /* Set buttons parameters */
    buttons = array(Button, nbButtons);
    buttons.x = xBut + ( 2*indgen(nbButtons) - nbButtons -1 ) * dxBut;
    buttons.y = yBut;
    buttons.dx = dxBut;
    buttons.dy = dyBut;
    buttons.text = butText;
    buttons.font = font;
    buttons.height = height;
    buttons.width  = 0;

    /* Found the part of the window that should be displayed,
       we always display the complete width */
    winHeightDisplay = int(winHeight / winHeightNDX * yMax);
    winWidthDisplay  = int(winWidth);

    /* Create graphics window */
    window, win, dpi=dpi, height=winHeightDisplay, width=winWidthDisplay, wait=1;

    if(justify=="C")
    {
        xText = winWidthNDX / 2;
        textJustify = "CA";
    }
    else if(justify=="L")
    {
        maxLen = max(strword(text,"\n",200)(::2)(dif));
        xText = winWidthNDX / 2 - maxLen * letterWidthNDX / 2;
        textJustify = "LA";
    }
    else if(justify=="R")
    {
        maxLen = max(strword(text,"\n",200)(::2)(dif));
        xText = winWidthNDX / 2 + maxLen * letterWidthNDX / 2;
        textJustify = "RA";
    }
    
    // Separate again text in different lines, but now the lines
    // cut is supposed to be OK
    textCut = yocoStrSplit(text,"\n");
    // Plot text
    nT = numberof(textCut);
    for (iT = 1; iT <= nT; iT++)
    { 
        plt, yocoStrReplace(textCut(iT), ["!","_"], ["!!","!_"]),
            xText, yText - 1.05*letterHeightNDX * (-nT + iT),
            height=height, justify=textJustify,
            font="courierB",tosys=0;
    }


    /* If interactive question */
    if(click==1)
    {
        /* Plot buttons */
        button_plot, buttons;
        
        /* Test buttons and execute action */
        while (1 == 1)
        { 
            mouseClick = 0;
            while (mouseClick == 0)
            { 
                window, win;
                result=mouse(0, 0, "");

                if ((result(10) != 0))
                {
                    xMouse = result(5);
                    yMouse = result(6);
                    mouseClick = 1;
                }
            }

            for (iButton=1; iButton <= nbButtons; iButton++)
            {
                if (button_test(buttons(iButton), xMouse, yMouse))
                {
                    winkill,win;
                    yocoLogTest, "yocoGuiInfoBox click:", "\""+butText(iButton)+"\"";
                    return butReturn(iButton);
                }
            }
        }
    }
}

/***************************************************************************/

func yocoGuiErrorBox(text, win=, dpi=)
/* DOCUMENT yocoGuiErrorBox(text, win=, dpi=)
   
       DESCRIPTION
       Plots an error box and stops with an error.

       PARAMETERS
   - text: Explanatory text to the error
   - win : Choose any window you want. Default is 0.
   - dpi : size of the window, see 'help, window' (better between 30-75)

       EXAMPLES
       > yocoGuiErrorBox,"Bwaaaaah ! This is an error ;-)";
    */
{
    yocoGuiInfoBox,"!!!!!!!!!!!!! \n !!! ERROR !!!"+
        " \n !!!!!!!!!!!!! \n \n"+text+"\n ", win=win, dpi=dpi;
    error;
}

/************************************************************************/

func yocoGuiChangeNumber(oldNr, &fig2ch, once=, win=, kill=, dpi=)
/* DOCUMENT yocoGuiChangeNumber(oldNr, &fig2ch, once=, win=, kill=, dpi=)

       DESCRIPTION
       Graphical tool to easily change arrays of numbers.

       PARAMETERS
   - oldNr : The original array you want to change
   - fig2ch: 
   - once  : 
   - win   : any window for this gui can be choosed. Default 0.
   - kill  : wether to kill or not the window after operation.
   - dpi   : dpi, see help, window, Better between 30 to 80.

       CAUTIONS
       In development !
    */
{
    if(is_void(once))
        once=0;
    if(is_void(oldNr))
        oldNr=0.0;
    if(is_void(kill))
        kill=1;
    if(is_void(win))
        win=0;
    
    /* default for dpi. The dpi should be 30<dpi<75
       otherwise some X11 will screw up */
    if(is_void(dpi)) dpi = 75;

    if(kill==1)
        winkill,win;

    // Define window center
    winCenterX = 0.4;
    winCenterY = 0.65;
    // Define text-to-graphics parameters
    maxWindowWidth   = dpi*638/75;
    height           = 24;
    convertFact      = 1500.0;
    convertFactPix   = 1100.0;
    letterWidth      = height / convertFact;
    letterHeight     = letterWidth * 3 / 2.0;
    letterWidthPix   = letterWidth * convertFactPix;
    letterHeightPix  = letterHeight * convertFactPix;


    N = numberof(oldNr);

    if(kill==0)
        window, 0;
    else
        window, 0, dpi=dpi, width=290, height=130*N, wait=1, style=, wait=1;

    if(is_void(fig2ch))
        if(numberof(where(oldNr==0))!=0)
        {
            fig2ch=array(int, N);
            fig2ch(where(oldNr==0))=0;

            if(numberof(where(oldNr!=0))!=0)
                fig2ch(where(oldNr!=0))=int(log10(abs(oldNr(where(oldNr!=0)))));
        }
        else
            fig2ch=int(log10(abs(oldNr)));

    nButtons = 4;
    buttons = array(Button, nButtons);
    buttons.x = [winCenterX-letterWidth*10, winCenterX+letterWidth*10,
                 winCenterX, winCenterX];
    buttons.y = [winCenterY, winCenterY,
                 winCenterY-letterHeight, winCenterY+letterHeight];
    buttons.dx = [letterWidth, letterWidth, letterWidth, letterWidth];
    buttons.dy = [letterHeight/2, letterHeight/2,
                  letterHeight/2, letterHeight/2];
    buttons.text = ["<", ">", "-", "+"];
    buttons.font = array("courier", nButtons);

    ok = Button(x=winCenterX, y=winCenterY-letterHeight*2.2,
                dx=letterWidth, dy=letterHeight/2,
                text="OK", font="courier");

    allButt = [];

    for(iNr=1;iNr<=N;iNr++)
    {
        decal = 3.5*letterHeight*(iNr-1);
        but = buttons;
        but.y = buttons.y - decal;
        grow, allButt, but;
    }
    ok.y = ok.y - decal;
    grow, allButt, ok;

    fma;

    while(fini!=1)
    {
        fma;
        fch = fig2ch + (fig2ch>=0) - (oldNr<0) - 1;

        for(iNr=1;iNr<=N;iNr++)
            allButt.x(3+nButtons*(iNr-1):4+nButtons*(iNr-1)) =
                winCenterX - (strlen(pr1(oldNr(iNr)))/2.0)*letterHeight +
                letterHeight/2.0 - fch(iNr)*letterHeight;

        button_plot, allButt;

        for(iNr=1;iNr<=N;iNr++)
        {
            decal = winCenterY-3.5*letterHeight*(iNr-1);
            plt, pr1(oldNr(iNr)), winCenterX, decal, justify="CH",
                height=height, font="courierB";
        }

        result = mouse(0, 0, "");
        x=result(1);
        y=result(2);

        for(iNr=1;iNr<=N;iNr++)
        {
            if(button_test(allButt(1+nButtons*(iNr-1)), x, y))
            {
                fig2ch(iNr)++;
            }
            else if(button_test(allButt(2+nButtons*(iNr-1)), x, y))
            {
                fig2ch(iNr)--;
            }
            else if(button_test(allButt(3+nButtons*(iNr-1)), x, y))
            {
                oldNr(iNr)-=10^double(fig2ch(iNr));
                if(once==1)
                    return oldNr;
            }
            else if(button_test(allButt(4+nButtons*(iNr-1)), x, y))
            {
                oldNr(iNr)+=10^double(fig2ch(iNr));
                if(once==1)
                {
                    if(kill==1)
                        winkill,win;
                    return oldNr;
                }
            }
            if(button_test(allButt(nButtons*N+1), x, y))
            {
                if(once==1)
                {
                    if(kill==1)
                        winkill,win;
                    return "ok";
                }
                else
                {
                    if(kill==1)
                        winkill,win;
                    return oldNr;
                }
            }
        }
    }
}

/***************************************************************************/

func yocoGuiInitTime(void)
/* DOCUMENT yocoGuiInitTime

       DESCRIPTION
       Get the current time and return it, useful for yocoGuiProgressBox.

       SEE ALSO yocoGuiProgressBox
    */
{
    startTime = array(double, 3);
    timer, startTime;
  
    return startTime(3);
}

/***************************************************************************/

func yocoGuiProgressBox(amount, barStyle=, barTitle=, minAmount=, maxAmount=, minLabel=, maxLabel=, kill=, win=, dpi=, startTime=)
/* DOCUMENT yocoGuiProgressBox(amount, barStyle=, barTitle=, minAmount=, maxAmount=, minLabel=, maxLabel=, kill=, win=, dpi=, startTime=)
       maxAmount=, minLabel=, maxLabel=, kill=,
       win=, dpi=)

       DESCRIPTION
       Plots a progress box, with labels and a title, using the input amount.

       PARAMETERS
   - amount   : amount is a figure between minAmount and maxAmount.
                    Defaults to a percentage
   - barStyle : Graphic style of the progress bar. Currently only "classic"
                    is available
   - barTitle : Set a title to your progress bar.
   - minAmount: Minimum value amount can be. Defaults to 0.
   - maxAmount: Maximum value amount can be. Defaults to 100.
   - minLabel : Set a label to minAmount. Defaults to 0.
   - maxLabel : Set a label to maxAmount. Defaults to 100.
   - kill     : if 1 kills the window 'win'.
   - win      : window number use to display progress bar. Defaults to 7. 
   - dpi      : size of the window, see 'help, window' (better between 30-75)
   - startTime: To display the progress box in time, input here a start time

       EXAMPLES
       > for(k=1;k<=1000;k++)
       cont> {
       cont>   yocoGuiProgressBox,k/10.0, minAmount=1, maxAmount=100, kill=(k<=1);
       cont>   pause,5;
       cont> }
    */
{

    /* Define the scroll bar */
    scrollBar = yocoGUI_SCROLL_BAR(x=0.4, y=0.62, length=0.5, percent=20, 
                                   orient=0, style="classic", height=0.01);

    /* Several default values */
    if (is_void(win))
    {
        win=7;
    }
    if (is_void(barStyle))
    {
        scrollBar.style = "classic";
    }
    else
    {
        scrollBar.style = barStyle;
    }
    if (is_void(minAmount))
    {
        minAmount = 0.0;
    }
    if (is_void(maxAmount))
    {
        maxAmount = 100.0;
    }
    if (is_void(minLabel))
    {
        minLabel = "0%";
    }
    if (is_void(maxLabel))
    {
        maxLabel = "100%";
    }
    if (is_void(barTitle))
    {
        barTitle = "Progress";
    }
    if (is_void(dpi))
    {
        dpi = 75;
    }

    if(!is_void(startTime))
    {
        minLabel = pr1(startTime);
        maxLabel = pr1((1-(amount-minAmount)/(maxAmount-minAmount))*startTime);
    }

    /* Compute the current position */
    scrollBar.percent = amount / double(maxAmount - minAmount)*100.0;

    /* Configure the window... note that the size is hard-coded */
    if (kill==1)
    {
        winkill, win;
        window, win, dpi=dpi, width=int(550.0*dpi/75), height=int(120*dpi/75), wait=1;
    }
    else
    {
        window, win;
        fma;
    }

    /* Plot the scroll bar */
    yocoGuiPlotScrollBar, scrollBar;

    /* Plot the min/max and current pos */
    plt, minLabel, scrollBar.x - scrollBar.length / 2, scrollBar.y - 0.025, 
        justify="CH", height=18, font="courierB", tosys=0;
    plt, maxLabel, scrollBar.x + scrollBar.length / 2, scrollBar.y - 0.025,
        justify="CH", height=18, font="courierB", tosys=0;
    plt, strpart(pr1(amount),1:4), scrollBar.x +
        scrollBar.percent * scrollBar.length / 100 -
        scrollBar.length / 2, scrollBar.y + 0.025, justify = "CH",
        height=18, font="courierB", tosys=0;

    /* Plot the title */
    plt, barTitle, scrollBar.x, scrollBar.y + 0.06, height=24,
        justify="CH", font="courierB";

    /* Put this window in front */
    window, win;

    /* If we reach the end, kill the window */
    if (amount == maxAmount)
    {
        winkill, win;
    }
}

/***************************************************************************/

func yocoGuiPlotScrollBar(scrollBar)
/* DOCUMENT yocoGuiPlotScrollBar(scrollBar)
  
       DESCRIPTION
       Plots a scroll bar
    
       PARAMETERS
   - scrollBar: the scroll bar to plot which is defined by a
                    yocoGUI_SCROLL_BAR-type structure including:
                    o x,y     : NDC coordinates of scroll bar center
                    o length  : lenght of scroll bar
                    o height  : size of the bar 
                    o percent : bar position in percent
                    o orient  : scroll bar orientation; 0=horizontal, 
                                 1=vertical
                    o style   : must be "classic" or "boxed" 

       EXAMPLES
       > scrollBar = yocoGUI_SCROLL_BAR(x=0.5, y=0.5, length=0.5, percent=20, 
       orient=0, style="classic", height=0.01);
     
       > yocoGuiPlotScrollBar, yocoGUI_SCROLL_BAR;
    */
{
    if (is_void(scrollBar.orient))
    {
        scrollBar.orient = 0;
    }

    plsys, 0;

    if (is_void(scrollBar))
    {
        scrollBar = yocoGUI_SCROLL_BAR(x=0.4, y=0.65, length=0.4, percent=50, 
                                       orient=0, style="boxed", height=0.01);
    }

    if (scrollBar.style == "classic")
    {
        if (scrollBar.orient == 0)
        {
            /* Plot of a progress bar */
            x1 = scrollBar.x - (scrollBar.length-0.01) * 
                (50-scrollBar.percent) / 100.0 - scrollBar.height;
            x2 = scrollBar.x - (scrollBar.length-0.01) * 
                (50-scrollBar.percent) / 100.0 + scrollBar.height;
            y1 = scrollBar.y - scrollBar.height;
            y2 = scrollBar.y + scrollBar.height;

            X1 = scrollBar.x - scrollBar.length/2;
            X2 = scrollBar.x + scrollBar.length/2;
            Y1 = scrollBar.y;
            Y2 = scrollBar.y;
        }
        else
        {
            /* Plot of a progress bar */
            x1 = scrollBar.x - scrollBar.height;
            x2 = scrollBar.x + scrollBar.height;
            y1 = scrollBar.y - (scrollBar.length-0.01) * 
                (50-scrollBar.percent) / 100.0 - scrollBar.height;
            y2 = scrollBar.y - (scrollBar.length-0.01) *
                (50-scrollBar.percent) / 100.0 + scrollBar.height;

            X1 = scrollBar.x;
            X2 = scrollBar.x;
            Y1 = scrollBar.y - scrollBar.length/2;
            Y2 = scrollBar.y + scrollBar.length/2;
        }

        plfp, 0x0, [y2, y2, y1, y1], [x1, x2, x2, x1], 4; 
        plg, [Y1, Y2], [X1, X2], marks=0; 
        /* End of the plot */
    }
    else if (scrollBar.style == "boxed")
    {
        if (scrollBar.orient == 0)
        {
            /* Plot of a progress bar */
            x1 = scrollBar.x - (scrollBar.length - 0.01) * 
                (50 - scrollBar.percent) / 100.0 - scrollBar.height; 
            x2 = scrollBar.x - (scrollBar.length - 0.01) * 
                (50 - scrollBar.percent) / 100.0 + scrollBar.height;
            y1 = scrollBar.y - scrollBar.height;
            y2 = scrollBar.y + scrollBar.height;

            X1 = scrollBar.x - scrollBar.length / 2;
            X2 = scrollBar.x + scrollBar.length / 2;
            Y1 = scrollBar.y;
            Y2 = scrollBar.y;
        }
        else
        {
            /* Plot of a progress bar */
            x1 = scrollBar.x - scrollBar.height;
            x2 = scrollBar.x + scrollBar.height;
            y1 = scrollBar.y - (scrollBar.length-0.01) *
                (50-scrollBar.percent) / 100.0 - scrollBar.height; 
            y2 = scrollBar.y - (scrollBar.length-0.01) * 
                (50-scrollBar.percent) / 100.0 + scrollBar.height;

            X1 = scrollBar.x;
            X2 = scrollBar.x;
            Y1 = scrollBar.y - scrollBar.length / 2;
            Y2 = scrollBar.y + scrollBar.length / 2;
        }

        plfp, 0x0, [y2, y2, y1, y1], [x1, x2, x2, x1], 4; 
        plg, [Y1, Y2, Y2, Y1, Y1], [X1, X1, X2, X2, X1], marks=0;
        /* End of the plot */
    }
}

/***************************************************************************/

func yocoGuiTestScrollBar(scrollBar, xMouse, yMouse)
/* DOCUMENT yocoGuiTestScrollBar(scrollBar, xMouse, yMouse)

       DESCRIPTION 
       Check whether mouse is in scroll bar or not. If yes, return the relative
       mouse position in percent, and 0 otherwise.

       PARAMETERS
   - scrollBar: the scroll bar
   - xMouse   : x NDC coordinates of mouse
   - yMouse   : y NDC coordinates of mouse

       RETURN VALUES
       Relative mouse position in scroll bar (in percent), and 0 otherwise
     
       SEE ALSO
       yocoGuiPlotScrollBar
    */
{
    if (abs(yMouse - scrollBar.y) < scrollBar.height &&
        abs(xMouse - scrollBar.x) < scrollBar.width)
    {
        return ((xMouse - scrollBar.x) / scrollBar.height + 0.5) * 100;
    }
    else
    {
        return 0;
    }
}

/***************************************************************************/

func yocoGuiFileChooser(text, &out, directory=, colorFunc=, updateFunc=, updateLabel=, win=, doNotChangeCwd=, dpi=)
/* DOCUMENT yocoGuiFileChooser(text, &out, directory=, colorFunc=, updateFunc=, updateLabel=, win=, doNotChangeCwd=, dpi=)
       updateLabel=, win=, doNotChangeCwd=, dpi=)

       DESCRIPTION
       Display a graphical file browser to navigate across directories and choose
       a file or a directory. The output is the list of selected files with their
       paths. This function only returns a string and doesn't make any action to
       the files selected. One can uses the output of this function as input to
       other function that handle data files but need the file name to be
       explicit.
       It is possible to :
       - select a file by clicking on its name, just as in a standard file
       browser
       - select multiple files by pressing the <SHIFT> or <CTRL> keys while
       clicking, and validate your choice with a right click
       - exit the function with a right click

       PARAMETERS
   - text          : text written on the console and as a title of the
                         window
   - out           : list of the selected files/directories 
   - directory     : directory to be displayed first. If no one is
                         specified, default directory is the current one.
   - colorFunc     : user function returning colors for the list of files.
                         It also gives the types of supported file types and
                         the associated colors. The prototype of this function
                         is :
                         colorFunc(directory, &files, &types, &colors, sortByDate=):
                         o directory  : directory name where files are located
                         o files      : list of file names
                         o types      : list of supported file types 
                         o colors     : list of colors associated to file types
                         o sortByDate : if set to 1, file list and returned
                                        color list are sorted by date
   - updateFunc    : updating user function. If specified, a new button
                         is added to the file browser, and this function is
                         called when this new button is pressed. The prototype
                         of this function is: updateFunc(inputDir=) with:
                         o directory: current directory
   - updateLabel   : label of update button; by default is UPDATE 
   - win           : 
   - doNotChangeCwd: 
   - dpi           : size of the window, see 'help, window' (better between 30-75)

       RETURN VALUES
       String containing the name of the directory/file chosen.
       If no choice was made, return 0

       EXAMPLES
       > yocoGuiFileChooser("Choose a file", out, directory="/home/")
    */
{
    /* Found where we are */
    if(doNotChangeCwd)
        hereStart = get_cwd();

    /* Default parameters */
    if(is_void(dpi))
    {
        dpi = 75;
    }
    if (is_void(directory))
    {
        directory = cd("./");
    }
    // If directory is still void, set to an empty string
    if (is_void(directory))
    {
        directory = "";
    }
    if(is_void(win))
    {
        win=0;
    }
    

    /* Configure window */
    winkill, win;

    /* Go to the specified directory ,
       and allow directory to disappear */
    dirString = "";
    while(is_void(cd(directory)))
    {
        yocoLogWarning,"Directory "+directory+" does not exist", 
            "Trying parent directory";
        dirString = dirString + "../"
            directory = cd(dirString);
        if (is_void(directory))
        {
            directory = "";
        }
    }

    /* Print text */
    yocoLogInfo, text, "\a";
    yocoLogHelp, "HELP on file chooser";
    yocoLogHelp, , "- left click on a file : select one file";
    yocoLogHelp, , "- right click on a file : quit browser without having " + 
        "selected " + "anything";
    yocoLogHelp, , "- SHIFT left click file1 - left click fileN : select " + 
        "all contiguous files between file1 and fileN";
    yocoLogHelp, , "- CONTROL left click on file1 file2 ... fileN : select " + 
        "files file1 ... fileN";
    yocoLogHelp, , "Note: to validate a multiple selection, right click on " + 
        "a file";
    
    getOut = 0;
    textOutput = 0;
    underlined = [];
    resultArray = [];
    ctrlPressed = 0;
    ctrlOnce = 0;
    shiftPressed = 0;
    shiftOnce = 0;
    start = 1;
    nrows = 30;
    ncols = 2;
    
    minX = 0.04;
    minY = 0.13;
    maxX = 0.99;
    maxY = 0.70;

    wRoot = [minX,minY];
    wSize = [maxX-minX,maxY-minY];
    padding = 0.01;

    /* Configuring browser's buttons */
    nbButtons = 15;
    if (!is_void(updateFunc))
    {
        nbButtons++;
    }
    x = minX/2+maxX/2+[-0.21, -0.14, -0.07, 0.0, 0.07, 0.14, 0.21, 
                       -0.2, -0.1, 0.0, 0.1, 0.2, 
                       -0.11, 0.0, 0.11];
    y = [minY-0.03, minY-0.03, minY-0.03, minY-0.03, minY-0.03, minY-0.03, minY-0.03, 
         minY-0.06, minY-0.06, minY-0.06, minY-0.06, minY-0.06, 
         minY-0.09, minY-0.09, minY-0.09];
    dx = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 
          0.042, 0.042, 0.042, 0.042, 0.042, 
          0.045, 0.045, 0.045];
    label = ["<<<", "<", "..", "HOME", "/", ">", ">>>", 
             "DIRS", "HIDDEN", "BYNAME", "BYDATE", "BYTYPE", 
             "ALLFILES", "THISDIR", "ALLDIRS"];
    
    windowHeight=640;
    if (!is_void(updateFunc))
    {
        grow, x, minX/2+maxX/2;
        grow, y, minY-0.12;
        grow, dx, 0.15;
        if (is_void(updateLabel))
        {
            grow, label, "UPDATE";
        }
        else
        {
            grow, label, updateLabel;
        }
        windowHeight = 650;
    }
    buttons = array(Button, nbButtons);
    buttons.x = x; 
    buttons.y = y;
    buttons.dx = dx; 
    buttons.dy = array(0.01, nbButtons);
    buttons.text = label;
    buttons.font   = array("courier", nbButtons);
    buttons.height = array(0, nbButtons);
    buttons.width  = array(0, nbButtons);
        
    window, win, dpi=dpi, style="nobox.gs",
        height=int(windowHeight*dpi/75),
        width=int(825*dpi/75), wait=1;
    get_style, landscape, systems, legends, clegends;
    set_style, 1, systems, legends, clegends;
    //     set_style, 1, systems, legends, clegends;
    vport = systems.viewport(,1);
    

    files  = [];
    dirs   = [];
    nbFiles = [];
    showD  = 1;
    showH  = 0;
    listType = "byName";

    colors = [];
    _yocoGuiDisplayFiles, directory, dirs, files, colors, firstFileNum=start,
        refresh=1, title=text, showHiddens=showH, showDirs=showD,
        nbRows=nrows, nbCols=ncols, padding=padding, windowRoot=wRoot,
        windowSize=wSize, underLined=underlined, listType=listType,
        colorFunc=colorFunc, win=win;
    button_plot, buttons;

    xMouse = 0;
    yMouse = 0;

    while (1 == 1)
    {
        mouseClick = 0;
        if (button_test(buttons(1), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "<<<" */
            if (start > nrows - 1)
            {
                start -= ncols * nrows;
            }
            while (start <= 0)
            {
                start += nrows;
            }
            _yocoGuiDisplayFiles, , dirs, files, colors, firstFileNum=start,
                refresh=1, nbRows=nrows, nbCols=ncols, padding=padding,
                title=text, showHiddens=showH, showDirs=showD, windowRoot=wRoot,
                windowSize=wSize, underLined=underlined, listType=listType,
                colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(2), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "<" */
            if (start > nrows - 1)
            {
                start -= nrows;
            }
            _yocoGuiDisplayFiles, , dirs, files, colors, firstFileNum=start,
                refresh=1, nbRows=nrows, nbCols=ncols, padding=padding,
                title=text, showHiddens=showH, showDirs=showD, windowRoot=wRoot,
                windowSize=wSize, underLined=underlined, listType=listType,
                colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(3), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button ".." */
            cd, "..";
            directory = cd(".");
            start = 1;
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(4), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "HOME" */
            cd, "~";
            directory = cd(".");
            start = 1;
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(5), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "/" */
            cd, "/";
            directory = cd(".");
            start = 1;
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(6), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button ">" */
            if (start < numberof(files) - nrows)
            {
                start += nrows;
            }
            _yocoGuiDisplayFiles, , dirs, files, colors, firstFileNum=start,
                refresh=1, nbRows=nrows, nbCols=ncols, padding=padding,
                title=text, showHiddens=showH, showDirs=showD, windowRoot=wRoot,
                windowSize=wSize, underLined=underlined, listType=listType,
                colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(7), xMouse,yMouse) && (getOut == 0))
        {
            /* Click on button ">>>" */ 
            if (start<numberof(files)-nrows)
            {
                start += ncols * nrows;
            }
            while(start>=numberof(files))
            {
                start -= nrows;
            }
            _yocoGuiDisplayFiles, , dirs, files, colors, firstFileNum=start,
                refresh=1, nbRows=nrows, nbCols=ncols, padding=padding,
                title=text, showHiddens=showH, showDirs=showD, windowRoot=wRoot,
                windowSize=wSize, underLined=underlined, listType=listType,
                colorFunc=colorFunc, win=win;
            button_plot,buttons;
        }
        else if (button_test(buttons(8), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "DIRS" */
            if (showD == 1)
            {
                showD = 0;
            }
            else
            {
                showD = 1;
            }
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(9), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "HIDDEN" */
            if (showH == 1)
            {
                showH = 0;
            }
            else
            {
                showH = 1;
            }
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(10), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "BYNAME" */
            listType = "byName";
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(11), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "BYDATE" */
            listType = "byDate";
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(12), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "BYTYPE" */
            listType = "byType";
            underlined = [];
            resultArray = [];
            ctrlPressed = 0;
            ctrlOnce = 0;
            shiftPressed = 0;
            shiftOnce = 0;
            colors = [];
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        }
        else if (button_test(buttons(13), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "ALLFILES" */
            winkill, 0;
            if (!is_void(files))
            {
                out = yocoStrReplace(directory+files, [":", " "], ["\:", "\ "]);
                /* Go back to first directory, and return the cliked value */
                if(doNotChangeCwd)
                    cd, hereStart;
                return out;
            }
            else
            {
                yocoLogWarning, "No choice have been made";
                out = 0;
                /* Go back to first directory, and return the cliked value */
                if(doNotChangeCwd)
                    cd, hereStart;
                return 0;
            }
        }
        else if (button_test(buttons(14), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "THISDIR" */
            winkill, 0;
            out = directory;
            /* Go back to first directory, and return the cliked value */
            if(doNotChangeCwd)
                cd, hereStart;
            return directory;
        }
        else if (button_test(buttons(15), xMouse, yMouse) && (getOut == 0))
        {
            /* Click on button "ALLDIRS" */
            winkill, 0;
            if (!is_void(dirs))
            {
                out = directory + dirs + "/";
                /* Go back to first directory, and return the cliked value */
                if(doNotChangeCwd)
                    cd, hereStart;
                return out;
            }
            else
            {
                out = 0;
                /* Go back to first directory, and return the cliked value */
                if(doNotChangeCwd)
                    cd, hereStart;
                return 0;
            }
        }
        else if ((!is_void(updateFunc)) &&
                 (button_test(buttons(16), xMouse, yMouse) && (getOut == 0)))
        {
            /* Click on button "UPDATE" */
            updateFunc, inputDir=directory;
            window,win;
            
            colors=[];
            
            _yocoGuiDisplayFiles, directory, dirs, files, colors,
                firstFileNum=start, refresh=1, nbRows=nrows, nbCols=ncols,
                padding=padding, title=text, showHiddens=showH, showDirs=showD,
                windowRoot=wRoot, windowSize=wSize, underLined=underlined,
                listType=listType, colorFunc=colorFunc, win=win;
            button_plot, buttons;
        } 
        else
        {
            textOutput = _yocoGuiCheckText(files, start, nrows, ncols, wRoot,
                                           wSize, padding, xMouse, yMouse,
                                           fileNum);

            if (textOutput != 0)
            {
                if (!is_void(dirs))
                {
                    is_directory = strmatch(dirs + " ", textOutput + " ")(sum);
                }
                else
                {
                    is_directory = 0;
                }

                if (getOut == 0)
                {
                    if (ctrlPressed == 1)
                    {
                        if (is_void(resultArray))
                        {
                            grow, resultArray, "";
                        }

                        if (!strmatch(resultArray + " ", 
                                      directory + textOutput + " ")(sum))
                        {
                            grow, underlined, fileNum;
                            grow, resultArray, directory + textOutput;
                            resultArray = resultArray(where(resultArray != ""));
                        }
                        else if (numberof(resultArray) >= 2)
                        {
                            underlined = underlined(where(resultArray !=
                                                          directory + textOutput));
                            resultArray = resultArray(where(resultArray !=
                                                            directory + textOutput));
                        }
                        else
                        {
                            underlined = [];
                            resultArray = [];
                        }
                        directory = [];
                    }
                    else if (shiftPressed == 1)
                    {
                        if (is_void(resultArray))
                        {
                            grow, resultArray, "";
                        }

                        if (!strmatch(resultArray + " ", 
                                      directory + textOutput + " ")(sum))
                        {
                            if (shiftOnce == 1)
                            {
                                underlined = fileNum;
                                resultArray = [];
                            }
                            else
                            {
                                if (is_void(underlined))
                                {
                                    underlined = fileNum;
                                    underlined;
                                }
                                else if (fileNum > underlined(1))
                                {
                                    underlined = underlined + 
                                        indgen(fileNum - underlined + 1) - 1;
                                    resultArray = directory + files(underlined);
                                }
                                else
                                {
                                    underlined = fileNum + 
                                        indgen(underlined - fileNum + 1) - 1;
                                    resultArray = directory + files(underlined);
                                }
                            }
                        }
                        else
                        {
                            underlined = [];
                            resultArray = [];
                            shiftOnce = 0;
                        }
                        directory = [];
                    }
                    else if ((shiftPressed == 0) && (ctrlPressed == 0))
                    {
                        if (is_directory == 0)
                        {
                            winkill, win;
                            out = directory + textOutput;
                            /* Go back to first directory, and return the cliked value */
                            if(doNotChangeCwd)
                                cd, hereStart;
                            return out;
                        }
                        else
                        {
                            cd, textOutput;
                            directory = cd(".");

                            start = 1;
                            underlined = [];
                            resultArray = [];
                            ctrlPressed = 0;
                            ctrlOnce = 0;
                            shiftPressed = 0;
                            shiftOnce = 0;
                        } 
                    }
                    colors = [];
                    _yocoGuiDisplayFiles, directory, dirs, files, colors, 
                        firstFileNum=start, refresh=0, nbRows=nrows,
                        nbCols=ncols, padding=padding, title=text,
                        showHiddens=showH, showDirs=showD, windowRoot=wRoot,
                        windowSize=wSize, underLined=underlined,
                        listType=listType, colorFunc=colorFunc, win=win;
                    button_plot, buttons;
                }
                else if (getOut == 1)
                {
                    if ((ctrlPressed == 1) || (shiftPressed == 1) ||
                        (ctrlOnce == 1) || (shiftOnce >= 1))
                    {
                        winkill, win;
                        if ((numberof(resultArray) == 1) &&
                            (resultArray(1) == ""))
                        {
                            out = 0;
                            /* Go back to first directory, and return the cliked value */
                            if(doNotChangeCwd)
                                cd, hereStart;
                            return 0;
                        }
                            
                        out = resultArray;
                        /* Go back to first directory, and return the cliked value */
                        if(doNotChangeCwd)
                            cd, hereStart;
                        return resultArray;
                    }
                    else
                    {
                        winkill, win;
                        out = 0;
                        /* Go back to first directory, and return the cliked value */
                        if(doNotChangeCwd)
                            cd, hereStart;
                        return 0;
                    }
                }
            }
        }

        mouseClick = 0;
        while (mouseClick == 0)
        { 
            window, win;
            result = mouse(0, 0, "");

            if ((result(10) != 0))
            {
                xMouse = result(5);
                yMouse = result(6);
                mouseClick = 1;
                getOut = 0;
            }

            if (result(11) == 1)
            {
                shiftPressed = 1;
                if (shiftOnce == 1)
                {
                    shiftOnce = 2;
                }
                else
                {
                    shiftOnce = 1;
                }
                ctrlPressed = 0;
                ctrlOnce = 0;
            }
            else if (result(11) == 4)
            {
                ctrlPressed = 1;
                ctrlOnce = 1;
                shiftPressed = 0;
                shiftOnce = 0;
            }
            else
            {
                ctrlPressed = 0;
                shiftPressed = 0;
            }

            if (result(10) == 3)
            {
                mouseClick = 1;
                getOut = 1;
            }
        }
    }
}

/************************************************************************/

func _yocoGuiCheckText(files, firstFileNum, nbRows, nbCols, windowRoot, windowSize, padding, xMouse, yMouse, &fileNum)
/* DOCUMENT _yocoGuiCheckText(files, firstFileNum, nbRows, nbCols, windowRoot, windowSize, padding, xMouse, yMouse, &fileNum)
       windowRoot, windowSize, padding, xMouse, yMouse, &fileNum)

       DESCRIPTION
       Return the name of the selected file from a list of files displayed in
       graphical window; i.e. it tests if the mouse points to an element of the
       displayed list. 

       PARAMETERS
   - files       : list of files 
   - firstFileNum: number of the first file listed in window 
   - nbRows      : number of rows used to display the file list
   - nbCols      : number of columns used to display the file list
   - windowRoot  : NDC coordinates of the window showing file list 
   - windowSize  : window size showing file list 
   - padding     : space in the horizontal and vertical directions between
       element list.
   - xMouse      : abscissa of the mouse position 
   - yMouse      : ordinate of the mouse position 
   - fileNum     : number of the selected file; set to 0 if no file selected

       RETURN VALUES
       String containing the name of the selected directory/file.
       If no choice was made, return 0

       EXAMPLES
       Simulate selection of the first file of the list. 

       > firstFileNum = 1;
       > nbRows = 21;
       > nbCols = 2;
       > padding=0.01;
       > wRoot = [0.04,0.37];
       > wSize = [0.72,0.558];
       > files=["fileName1.i", "fileName2.i", "fileName3.i", "fileName4.i"];
       > nbFiles = numberof(files);
       > xMouse  = 0.08;
       > yMouse  = 0.9;
       > _yocoGuiCheckText(files, firstFileNum, nbRows, nbCols, wRoot, wSize,
       padding, xMouse, yMouse, fileNum)
    */
{
    X1 = windowRoot(1);
    X2 = windowRoot(1) + windowSize(1);
    Y1 = windowRoot(2);
    Y2 = windowRoot(2) + windowSize(2);

    colSep = (X2 - X1 - 2*padding) / nbCols;
    rowSep = (Y2 - Y1 - 2*padding) / nbRows;

    letterWidth = 0.0088;
    nbLetters = int(colSep / letterWidth - 1);

    text = _yocoGuiGetCroppedText(yocoStrReplace(files), nbLetters, lastLetters=9);

    for (i = 1 ; i <= nbRows; i++)
    {
        for (j = 1; j <= nbCols; j++)
        {
            fileNum = i - 1 + firstFileNum + (j-1) * nbRows;
            if (fileNum <= numberof(files))
            {
                x1 = X1 + padding + colSep * (j-1);
                x2 = x1 + letterWidth * strlen(text(fileNum));
                y1 = Y2 + padding - rowSep * i - 0.022;
                y2 = Y2 + padding - rowSep * i - 0.002;
                
                if ((x1 < xMouse) && (x2 > xMouse) && 
                    (y1 < yMouse) && (y2 > yMouse))
                {
                    return files(fileNum);
                }
            }
        }
    }
    return 0;
}

/***************************************************************************/

func _yocoGuiGetCroppedText(text, nbLetters, lastLetters=)
/* DOCUMENT _yocoGuiGetCroppedText(text, nbLetters, lastLetters=)

       DESCRIPTION 
       Crop the text to the given number of letters, keeping the number of
       trailing letters, if specified. 

       PARAMETERS
   - text       : text to be cropped
   - nbLetters  : maximun number of letters in cropped text
   - lastLetters: number of trailing letters to be kept; by default keep
                      only the last letter when text is cropped   
                       
       RETURN VALUES
       The cropped text.
   
       EXAMPLES 
       Crop the text "myfile.txt" to 8 characters, which will results in
       "myfi..xt"
       > _yocoGuiGetCroppedText("myfile.txt", 8, lastLetters=2)
    */
{
    if (is_void(lastLetters))
    {
        lastLetters = 0;
    }
  
    idx = 1 - lastLetters;
    if (idx > 0)
    {
        idx = 0;
    }

    text = yocoStrReplace(text, "!", "");
    outText = yocoStrReplace(text, "!", "");
    N = numberof(text);
    for (iT = 1; iT <= N; iT++)
    {
        if (strlen(text(iT)) > nbLetters + 1)
        {
            outText(iT) = strpart(text(iT), 1 : nbLetters - 3 + idx) + ".." + 
                strpart(text(iT), idx : 0);
        }
    }
    outText = yocoStrReplace(outText);
    return outText;
}

/***************************************************************************/

func _yocoGuiDisplayFiles(&directory, &dirs, &files, &colors, firstFileNum=, refresh=, title=, showHiddens=, showDirs=, nbRows=, nbCols=, windowRoot=, windowSize=, padding=, underLined=, listType=, colorFunc=, win=)
/* DOCUMENT _yocoGuiDisplayFiles(&directory, &dirs, &files, &colors, firstFileNum=, refresh=, title=, showHiddens=, showDirs=, nbRows=, nbCols=, windowRoot=, windowSize=, padding=, underLined=, listType=, colorFunc=, win=)

       DESCRIPTION 
       Display the content (files and/or directories) of the specified
       'directory'.
     
       PARAMETERS
   - directory   : current directory
   - dirs        : list of the directories respective to files of the
                       'files' list. If not filled, it is the list of
                       directories located in the current one.
   - files       : list of files to be displayed. If not filled, all files
                       of the current directory are displayed.
   - colors      : list of colors associated to the files to be displayed.
                       If not given, call <colorFunc> to get color list if this
                       function is provided. Otherwise, black is used.
   - firstFileNum: OPTIONAL number of the first file to plot. By default,
                       set to 1.
   - refresh     : OPTIONAL set to 1 to erase the window before plotting the
                       menu.
   - title       : OPTIONAL text written as browser title. By default, title
                       is the current directory name.
   - showHiddens : OPTIONAL if set to 1, hidden files and/or dirs (ie those
                       whose first character is ".") are displayed. Default
                       value is 0.
   - showDirs    : OPTIONAL if set to 1 (default value), directory are
                       displayed otherwise only files are visible. 
   - nbRows      : OPTIONAL number of rows of text in the menu.
   - nbCols      : OPTIONAL number of columns of text in the menu.
   - windowRoot  : OPTIONAL coordinates of the window's left bottom corner.
   - windowSize  : OPTIONAL window's dimensions.
   - padding     : OPTIONAL size of space between menu's columns. By
                       default, it is set to 0.01.
   - underLined  : OPTIONAL array of files to be underlined (used for
                       multiple files selction)
   - listType    : OPTIONAL indicating if files have to be stored by name,
                       by type or by date.
   - colorFunc   : OPTIONAL array with colors relative to the type of data
                       stored in amber files. 
   - win         : Choose any window for this gui. Default 0.

       SEE ALSO
       yocoGuiFileChooser
    */
{
    plsys,0;

    if (refresh == 1)
    {
        fma;
    }
    
    if (is_void(showHiddens))
    {
        showHiddens=0;
    }
    
    if(is_void(win))
        win=7;
    
    if (is_void(showDirs))
    {
        showDirs=1;
    }

    if (is_void(windowSize))
    {
        X1 = 0.188;
        X2 = 0.5975;
        Y1 = 0.444;
        Y2 = 0.852;
    }
    else if (is_void(windowRoot))
    {
        X1 = 0.188;
        X2 = 0.188 + windowSize(1);
        Y1 = 0.444;
        Y2 = 0.444 + windowSize(2);
    }
    else
    {
        X1 = windowRoot(1);
        X2 = windowRoot(1) + windowSize(1);
        Y1 = windowRoot(2);
        Y2 = windowRoot(2) + windowSize(2);
    }

    if (is_void(padding))
    {
        padding=0.01;
    }

    if (is_void(firstFileNum))
    {
        firstFileNum = 1;
    }

    if (is_void(nbRows))
    {
        nbRows = 20;
    }

    if (is_void(nbCols))
    {
        nbCols = 3;
    }

    colSep=(X2 - X1 - 2 * padding) / nbCols;
    rowSep=(Y2 - Y1 - 2 * padding) / nbRows;

    if (is_void(listType))
    {
        listType = "byName";
    }

    if (!is_void(directory))
    {
        shownFiles = shownDirs = hiddenFiles = hiddenDirs = [];
        yocoFileListDir, directory, shownFiles, shownDirs,
            hiddenFiles, hiddenDirs, listType=listType;

        files = [];
        dirs  = [];
        if ((showDirs == 1) && (showHiddens == 1))
        {
            grow, files, shownDirs, shownFiles, hiddenDirs, hiddenFiles;
            grow, dirs, shownDirs, hiddenDirs;
        }
        else if ((showDirs == 1) && (showHiddens == 0))
        {
            grow, files, shownDirs, shownFiles;
            grow, dirs, shownDirs;
        }
        else if ((showDirs == 0) && (showHiddens == 1))
        {
            grow, files, shownFiles, hiddenFiles;
        }
        else if ((showDirs == 0) && (showHiddens == 0))
        {
            grow, files, shownFiles;
        }
    }
    else
    {
        directory = cd(".");
    }

    if (is_void(files))
    {
        files = lsdir(directory);
    }

    files = yocoStrReplace(files, "\n", "");

    if (is_void(title))
    {
        title = directory;
    }
    else
    {
        title = title+"\n"+directory;
    }
    
    plt, yocoStrReplace(title), X1 + (X2 - X1) / 2., Y2 + padding, 
        justify="CA", opaque=1, font="helveticaB", height=18, tosys=0;
    
    plfp, 0xff, [Y2, Y2, Y1, Y1], [X1, X2, X2, X1], 4;

    nbFiles = numberof(files);

    if (nbFiles==0)
    {
        plg, [Y1, Y2, Y2, Y1, Y1], [X1, X1, X2, X2, X1], marks=0; 
        return 0;
    }

    if (firstFileNum+nbRows*nbCols<nbFiles)
    {
        plt, ">>", X2 + 0.002, (Y1 + Y2) / 2, height=24;
    }
    
    if (firstFileNum>1)
    {
        plt, "<<", X1 - 0.037, (Y1 + Y2) / 2, height=24;
    }
    colorVoid = 0;
    if (is_void(colors))
    {
        colorVoid = 1;
    }

    sortByDate = 0;
    if (listType == "byDate")
    {
        sortByDate = 1;
    }
    
    if (is_void(colors) && (!is_void(colorFunc)))
    {
        colors = colorFunc(directory, files, allTypes, allColors,
                           sortByDate=sortByDate);
        window,win;
        plsys,0;
    }

    if (is_void(colors))
    {
        colors = array([0, 0, 0], nbFiles);
    }

    if (!is_void(allTypes))
    {
        nbTypes = numberof(allTypes);
        for (iType = 1; iType <= nbTypes; iType++)
        {
            xtext = X1 + (X2-X1-0.1)*(2*iType/(nbTypes+1));
            ytext = Y1 - (2+(iType-1)%((nbTypes+1)/2)) * rowSep;
            plt, allTypes(iType), xtext, ytext, 
                color=allColors(,iType), tosys=0, font=font, height=12;
        }
    }

    number = 1;
    rowNumber = colNumber =0;
    nsdir=nhdir = nsfile = nhfile = 0;

    while ((number <= nbRows * nbCols) &&
           (number + firstFileNum - 1 <= nbFiles))
    {
        if (numberof(dirs)!=0)
        {
            if (strmatch(dirs + " " , 
                         files(number + firstFileNum - 1) + " ")(sum) >= 1)
            {
                font="courierB";
            }
            else
            {
                font="courier";
            }
        }
        else
        {
            font="courier";
        }
        if (rowNumber >= nbRows)
        {
            rowNumber = 0;
            colNumber++;
            Xpoly = X1 + colNumber * colSep;
            plfp, 0xff, [Y2, Y2, Y1, Y1], [Xpoly, X2, X2, Xpoly], 4;
            plg, [Y2, Y1], [Xpoly, Xpoly], marks=0;
        }

        letterWidth = 0.0088;
        nbLetters = int(colSep / letterWidth - 1);

        text  = _yocoGuiGetCroppedText(yocoStrReplace(files(number +
                                                            firstFileNum - 1)),
                                       nbLetters, lastLetters=9);
        xtext = X1 + padding + colNumber * colSep;
        ytext = Y2 + 0.002 - padding -(rowNumber + 1) * rowSep;
        plt, text, xtext, ytext, color=colors(,number + firstFileNum - 1),
            tosys=0, font=font, height=12;

        if (numberof(underLined) == 1)
        {
            if ((number + firstFileNum - 1 == underLined)(1))
            {
                x1 = X1 + padding + colSep * (colNumber);
                x2 = X1 + padding + colSep * (colNumber) +
                    0.0114 * strlen(files(number + firstFileNum - 1));
                y1 = Y2 + padding - rowSep * (rowNumber + 1) - 0.022;
                y2 = Y2 + padding - rowSep * (rowNumber + 1) - 0.002;
                plg, [y1, y1], [x1, x2], marks=0;
            }
        }
        else if ((numberof(underLined) >= 2) &&
                 ((number + firstFileNum - 1 == underLined)(sum) == 1))
        {
            x1 = X1 + padding + colSep * (colNumber);
            x2 = X1 + padding + colSep * (colNumber) +
                letterWidth * strlen(text);
            y1 = Y2 + padding - rowSep * (rowNumber + 1) - 0.022;
            y2 = Y2 + padding - rowSep * (rowNumber + 1) - 0.002;
            plg, [y1, y1], [x1, x2], marks=0;
        }

        rowNumber++;
        number++;
    }

    Xpoly = X1 + (colNumber + 1) * colSep;
    plfp, 0xff, [Y2, Y2, Y1, Y1], [Xpoly, X2, X2, Xpoly], 4;

    plg, [Y1, Y2, Y2, Y1, Y1], [X1, X1, X2, X2, X1], marks=0;

    /* Plot of a progress bar */
    N = numberof(files);

    percent = 100 - 100 * (N - firstFileNum * N / 
                           (N - nbRows + ((N - nbRows) == 0))) / N;
    if (percent > 99)
    {
        percent=99;
    }

    scrollBar = yocoGUI_SCROLL_BAR(x=X1+(X2-X1)/2, y=Y1, 
                                   length=X2-X1, percent=percent, orient=0, 
                                   style="classic", height=0.01);

    yocoGuiPlotScrollBar, scrollBar;
}

/***************************************************************************/

func yocoGuiWinKill(w1, ..)
/* DOCUMENT yocoGuiWinKill(w1, ..)

       DESCRIPTION 
       Kills the window(s) given by the number(s) w1, w2, etc.
       By default, kills all the windows if no argument is given.
       w1 can also be an array of integer, specifying several windows
       to be killed.

       EXAMPLES 
       Kill all graphics windows
       > yocoGuiWinKill

       Kill graphics windows 2 and 52
       > yocoGuiWinKill, 2, 52
     
       Kill graphics windows 2,5, and 60 other method
       > yocoGuiWinKill, [2,5,60]
    */
{
    local i;
    
    if (is_void(w1))
        for(i=0;i<=63;i ++ )
            winkill, i;
    else
        for(i=1;i<=numberof(w1);i++)
            winkill,w1(i);
    
    while (more_args())
    {
        wn = next_arg();
        for(i=1;i<=numberof(wn);i++)
            winkill, wn(i);
    }
}

/***************************************************************************/

/***************************************************************************/
  
/*
 * Private structures
 */

struct yocoBROWSER_BUTTONS{
    double x;               // x-pos of the button in system 0
    double y;               // x-pos of the button in system 0
    double dx;              // dx half-width of the button in system 0
    double dy;              // dy half-width of the button in system 0
    string text;            // button text
    string font;            // button font
    double height;          // button height
    double width;           // button width
    double color;           // button color (cmin=0,cmax=1)
    string action;          // name of the function to be executed
};
/* action:
   string containing the function name to be executed when the button is
   clicked. The action functions syntaxes should be of the form:
   > myButtonAction, &dir, &files;
*/

struct yocoBROWSER_FILE_INFO{
    string name;            // name of the file
    string info;            // additional string which can contain information
    long   color(3);        // color (not used)
    int    isSel;           // isSel=1 means this file is currently selected by the user
    int    isDir;           // isDir=1 means this file is a sub-directory
};

struct yocoBROWSER_DIR_INFO{
    int     pos;                 // current display pos
    string  dir;                 // current dir
    string  font;                // font in the file-list displey ("courier")
    int     height;              // font height in the file-list display (12)
    double  vDis(4);             // viewport of the display system
    double  vBar(4);             // viewport of the scroll-bar system
    int     nbFile;              // total number of files in this dir
    string  rules;               // rules to be applyied to 'files' before displaying them
    int     nbBut;               // number of button in the header (next array)
    yocoBROWSER_BUTTONS but(99); // header buttons, max is 99
    int     exit;                // if exit==1, the infinite loop ends
    int     ReturN;              // if ReturN==1, the files are returned
    int     presBut;             // id of the last pressed button
    string  help;                // long string containing the help.
    string  title;               // title on top of the display
};


/***************************************************************************
 * Header default button functions
 ***************************************************************************/

func _yocoGuiBrowserButtonActionClear(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionClear(&dir, &files)

       DESCRIPTION
       Clear browser plot

       SEE ALSO
    */
{
    /* Clear all selected files, replot selection only */
    files.isSel = 0;
    _yocoGuiBrowserReplotSelection, dir, files;
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionHelp(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionHelp(&dir, &files)

       DESCRIPTION
       Display a help of the browser

       SEE ALSO
    */
{
    /* Just ask for the help... print it on the terminal */
    dhelp = sum(["--------------   Browser Help  ----------------------\n",
                dir.help,
                "-----------------------------------------------------\n"])
    write,dhelp;

    curWin = window();
    yocoGuiInfoBox,dhelp, click=0, win=1, justify="L";
    window,curWin;
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionExit(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionExit(&dir, &files)

       DESCRIPTION
       exit the browser

       SEE ALSO
    */
{
    /* The user call EXIT, so exit the infinit loop */
    dir.exit = 1;
    dir.ReturN = 0;
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionOK(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionOK(&dir, &files)

       DESCRIPTION
       Exit the browser and return the result

       SEE ALSO
    */
{
    /* The user call EXIT, so exit the infinit loop */
    dir.exit=1;
    dir.ReturN = 1;
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionHome(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionHome(&dir, &files)

       DESCRIPTION
       Change directory to the home directory

       SEE ALSO
    */
{
    /* We change current dir, so we replot all */
    yocoGuiBrowserUpdate, dir, files, get_home();
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionTop(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionTop(&dir, &files)

       DESCRIPTION
       Go to root directory

       SEE ALSO
    */
{
    /* We change current dir, so we replot all */
    yocoGuiBrowserUpdate, dir, files, "/";
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionUp(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionUp(&dir, &files)

       DESCRIPTION
       Change to upper directory

       SEE ALSO
    */
{
    /* We change current dir, so we replot all */
    yocoGuiBrowserUpdate, dir, files, "../";
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionHere(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionHere(&dir, &files)

       DESCRIPTION
       Go to current directory (refresh)

       SEE ALSO
    */
{
    /* We change current dir, so we replot all */
    yocoGuiBrowserUpdate, dir, files, "./";
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionAllFiles(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionAllFiles(&dir, &files)

       DESCRIPTION
       Select all files

       SEE ALSO
    */
{
    /* Get the id of the button */
    local butId;
    butId = where( dir.but.action == "_yocoGuiBrowserButtonActionAllFiles")(1);

    /* Change the button status and change the
       selection accordingly */
    if ( dir.but(butId).color==0.95 ) {
        dir.but(butId).color = 0.5;
        files.isSel = (files.isSel + !files.isDir)>0;
    }
    else {
        dir.but(butId).color = 0.95;
        files.isSel = (files.isSel - !files.isDir)>0;
    }

    /* Replot the selection and the buttons */
    _yocoGuiBrowserPlotAll, dir, files;
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionAllDirs(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionAllDirs(&dir, &files)

       DESCRIPTION
       select all directories

       SEE ALSO
    */
{
    /* Get the id of the button */
    local butId;
    butId = where( dir.but.action == "_yocoGuiBrowserButtonActionAllDirs")(1);

    /* Change the button status and change the
       selection accordingly */
    if ( dir.but(butId).color==0.95 ) {
        dir.but(butId).color = 0.5;
        files.isSel = (files.isSel + files.isDir)>0;
    }
    else {
        dir.but(butId).color = 0.95;
        files.isSel = (files.isSel - files.isDir)>0;
    }

    /* Replot the selection and the buttons */
    _yocoGuiBrowserPlotAll, dir, files;
}

/***************************************************************************/

func _yocoGuiBrowserButtonActionThisDir(&dir, &files)
/* DOCUMENT _yocoGuiBrowserButtonActionThisDir(&dir, &files)

       DESCRIPTION
       Select and return the current directory

       SEE ALSO
    */
{
    /* Get the current dir */
    files = yocoBROWSER_FILE_INFO();
    files.isSel = files.isDir = 1;
    files.name = "./";

    /* Then exit the infinit loop */
    dir.exit=1;
    dir.ReturN=1;
}


/***************************************************************************
 * Init functions
 ***************************************************************************/

func __yocoGuiBrowserGetNbLine(dir)
/* DOCUMENT __yocoGuiBrowserGetNbLine(dir)

       DESCRIPTION
       Number of line per window - there is 0.0013 unit per font points,
       and I add the 1.2 factor for larger line spacing
       
       SEE ALSO
    */
{
    /* Number of line per window - there is 0.0013 unit per font points,
       and I add the 1.2 factor for larger line spacing */
    return ( (dir.vDis(4)-dir.vDis(3)) / (0.0013 * dir.height * 1.2) );
}

/***************************************************************************/

func _yocoGuiBrowserInit(&dir, win, dpi)
/* DOCUMENT _yocoGuiBrowserInit(&dir, win, dpi)

       DESCRIPTION
       Private function for _yocoGuiBrowser:
       - Init the DIR structure
       - Init the ploring window

       PARAMETERS
   - dir: structure that contains the display properties
              like buttons, system sizes, font, current dir...
   - win: specify the window used by the browser, default is 0
   - dpi:
     
       SEE ALSO:
    */
{
    /* Some default */
    if ( is_void(dpi) ) dpi=70;
    if ( is_void(win) ) win=0;

    /* Init the dir structure */
    dir   = yocoBROWSER_DIR_INFO(font="courier", height=12, pos=0);

    /* Init the title */
    dir.title = "default yocoGuiBrowser - choose files(s)/dir(s)";

    /* Init the display size */
    dir.vDis = [0.015,1.00088,0.08,0.75];
    dir.vBar = [1.00288,1.023,0.08,0.75];

    /* Define the window */
    winkill,win;
    window, win, wait=1, dpi=dpi, width=int(825.0*dpi/75), height=int(638.0*dpi/75);

    /* Configuring the browser's default buttons */
    dir.nbBut  = 11;
    dir.but.dx = 0.04; 
    dir.but.dy = 0.012;
    dir.but.y  = dir.vDis(3) - 0.02;
    dir.but.font    = "helvetica";
    dir.but.font(9:dir.nbBut) = "helveticaB";
    dir.but.color   = 0.95;
    dir.but.x(1:dir.nbBut)  = span(dir.vDis(1)+0.045, dir.vDis(2)-0.045, dir.nbBut);
    /* Button's names  and associated action */
    dir.but.text(1:dir.nbBut)   = ["./","../","/","Home","AllDirs","AllFiles","Clear","Help","THISDIR","CANCEL","OK"];
    dir.but.action(1:dir.nbBut) = ["_yocoGuiBrowserButtonActionHere",
                                   "_yocoGuiBrowserButtonActionUp",
                                   "_yocoGuiBrowserButtonActionTop",
                                   "_yocoGuiBrowserButtonActionHome",
                                   "_yocoGuiBrowserButtonActionAllDirs",
                                   "_yocoGuiBrowserButtonActionAllFiles",
                                   "_yocoGuiBrowserButtonActionClear",
                                   "_yocoGuiBrowserButtonActionHelp",
                                   "_yocoGuiBrowserButtonActionThisDir",
                                   "_yocoGuiBrowserButtonActionExit",
                                   "_yocoGuiBrowserButtonActionOK"];

    /* Default rules: remove the .* files */
    dir.rules = "_yocoGuiBrowserRuleHideDotFiles,";

    /* Setup the default help string */
    dir.help = "\n" + 
        "- double-clk on a single file      -> select it \n" +
        "- double-clk on a single directory -> enter it \n" +
        "- single-click on file or dir      -> (un)select it \n" +
        "- select several files or dirs     -> (un)select them \n" +
        " \n" +
        "- move or click in the scrollbar   -> navigation \n" +
        " \n" +
        "- button Clear     -> unselect all items \n" +
        "- button Help      -> print this help in the yorick term \n" +
        "- button EXIT      -> exit with current selection \n";

}

/***************************************************************************/

func yocoGuiBrowserUpdate(&dir, &files, newDir)
/* DOCUMENT yocoGuiBrowserUpdate(&dir, &files, newDir)

       DESCRIPTION
       Update the browser display

       SEE ALSO
    */
{
    /* We change current dir, so we replot all */
    if ( !_yocoGuiBrowserFillStrs( dir, files, newDir ) )
    {
        /* If failed to list the dir, exit */
        return 0;
    };
    _yocoGuiBrowserPlotAll, dir, files;
    return 1;
}

/***************************************************************************/

func _yocoGuiBrowserFillStrs(&dir, &files, newDir)
/* DOCUMENT _yocoGuiBrowserFillStrs(&dir, &files, newDir)

       DESCRIPTION
       Move to the directory newDir (default is "./"). Then fill
       the dir and files structures with this directory.

       Then it execute the rules specified in dir.rules.

       PARAMETERS
   - dir   : the DIR structure
   - files : array of FILES structures
   - newDir: string with the name of the new directory
    */
{
    yocoLogTrace,"_yocoGuiBrowserFillStrs()";
    local tmpD,tmpF,files,dirs,rules;

    /* Eventually change directory */
    if (newDir) {
        /* If failed to go in this dir */
        if( !cd(newDir) ) {
            yocoLogInfo,"Cannot list dir:",newDir;
            return 0;
        }
        yocoLogInfo,"Now in dir:",get_cwd();
    }

    /* Current place */
    dir.dir = get_cwd();
    tmpF = lsdir("./",tmpD);

    /* Init the filelist */
    files = [];
    if (numberof(tmpF)>0) {
        files = array(yocoBROWSER_FILE_INFO,numberof(tmpF));
        files.name = tmpF;
        files.info = "";
    }

    /* Init the dir list */
    dirs = [];
    if (numberof(tmpD)>0) {
        dirs  = array(yocoBROWSER_FILE_INFO,numberof(tmpD));
        dirs.name  = tmpD+"/";
        dirs.isDir = 1;
        dirs.info  = "";
    }

    /* Fill the names */
    files = grow( files, dirs);

    /* By default go at the top */
    dir.pos = 0;

    /* Executing current rules */
    rules = strpart(dir.rules,strword(dir.rules,",",10));
    for ( i=1 ; i<=numberof(rules) ; i++ )
    {
        /* Skip void rules */
        if (rules(i)==string(0) || rules(i)=="") continue;

        /* Execute the rule if still files to be processed */
        yocoLogTest,"Execute rule number: "+pr1(i);
        if (numberof(files)>1) tmp = symbol_def(rules(i))(files);

        /* If file list is void, just keep the current dir */
        if (is_void(files)) {
            files = [yocoBROWSER_FILE_INFO(name="./",isDir=1,info="")];
        }
    }

    yocoLogTrace,"_yocoGuiBrowserFillStrs done";
    return 1;
}

/***************************************************************************
 * Rules workers
 ***************************************************************************/

func yocoGuiBrowserRulesManager(&dir, funcname, act)
/* DOCUMENT yocoGuiBrowserRulesManager(&dir, funcname, act)

       DESCRIPTION
       Simple tool to add/remove a funcname to the list
       of rules stored into the dir.rules structure.

       dir.rules contains a list of function name that allows to perform
       operation on the file array like computing the info, hiding some files,
       sorting them...

       CAUTIONS:
       - dir.rules should be a string of the form:
       > dir.rules="rule1,otherRule,lastRule,";
       The rules are executed from the left to the right.

       - Each rule should be a function with a single parameter,
       the files structure:
       > rule1(files)
       > otherRule(files)
       > lastRule(files)

       PARAMETERS:
   - dir     : the DIR structure
   - funcname: the function name, as string
   - act     : an integer,
                   +1 -> funcname is added if not already there
                   -1 -> funcname is removed if present
    */
{
    yocoLogTrace,"yocoGuiBrowserRulesManager()";
    
    /* Add this function in the rule-list */
    if (act>0 && !strmatch(dir.rules,funcname) ) {
        dir.rules = dir.rules+funcname+",";
    }

    /* Remove this function in the rule-list */
    else if (act<0 && strmatch(dir.rules,funcname) ) {
        dir.rules = yocoStrReplace(dir.rules,funcname+",","");
    }
    
    yocoLogTrace,"yocoGuiBrowserRulesManager done";
}

/***************************************************************************/

func _yocoGuiBrowserRuleHideDotFiles(&files)
/* DOCUMENT _yocoGuiBrowserRuleHideDotFiles(&files)

   DESCRIPTION
   Simple _yocoGuiBrowser rule to hide the .* files,
   that is remove them from the file list.
*/
{
    /* Hide all '.*' files */
    local tbk;
    tbk = where( (strpart(files.name,1:1)!=".") + (files.name=="./"));
    files = files(tbk);
}

/*
 * Plotting functions
 */

func _yocoGuiBrowserReplotLimits(&dir)
/* DOCUMENT _yocoGuiBrowserReplotLimits(&dir)

   DESCRIPTION
   Set the limits of the list of file display (system 1)
   based on the information stored into dir (as the current
   pos dir.pos, the number of possible lines per plot nbLine...)

   Then the small scrollbar on the system 2 is updated accordingly.

   PARAMETERS:
   - dir: a valid yocoBROWSER_DIR_INFO structure
*/
{
    yocoLogTrace,"_yocoGuiBrowserReplotLimits()";

    local ymin, ymaz, yall, nbLine;

    /* Number of lines */
    nbLine = __yocoGuiBrowserGetNbLine(dir);

    /* Check if the limits are reached */
    dir.pos = min( dir.nbFile-nbLine+1, dir.pos );  
    dir.pos = max( 0, dir.pos );
    ymin = (dir.pos+nbLine);
    ymax = dir.pos;
    yall = dir.nbFile;

    /* Set the limits of the display system,
       0 is the top, nbLine is the bottom */
    plsys,1;
    limits, 0,, ymin, ymax, square=1;

    /* Set the limits of the bar system,
       FIXME: now I overwrite each time... try pledit. */
    plsys,2;
    palette,"gray.gp";
    plfp,[0.85],[0,yall,yall,0],[0,0,1,1],4,cmin=0,cmax=1;
    plfp,[0],[ymin,ymax,ymax,ymin],[0,0,1,1],4,cmin=0,cmax=1;
    limits, 0, 1, yall, 0;

    yocoLogTrace,"_yocoGuiBrowserReplotLimits done";
}

/***************************************************************************/

func _yocoGuiBrowserReplotSelection(&dir, &files)
/* DOCUMENT _yocoGuiBrowserReplotSelection(&dir, &files)

       DESCRIPTION
       Plot/replot the selections only, as small (un)clicked squares on the
       left of the filenames.

       No erase (fma) of the plot is done in this function, so 
       this allows to replot only the selection when needed.

       PARAMETERS:
   - dir  : a valid yocoBROWSER_DIR_INFO structure
   - files: a valibd yocoBROWSER_FILE_INFO structure
    */
{
    yocoLogTrace,"_yocoGuiBrowserReplotSelection()";
    /* Don't erase the plot, just use pledit */
    plsys,1;

    /* Loop on the files */
    for (i=1 ; i<=numberof(files) ; i++)
    {
        /* un(hide) the 'backgound frame' associated with files(i) */
        pledit, 2*int(i)-1, hide=!files(i).isSel;
    }
    
    yocoLogTrace,"_yocoGuiBrowserReplotSelection done";
}

/***************************************************************************/

func _yocoGuiBrowserPlotAll(&dir, &files)
/* DOCUMENT _yocoGuiBrowserPlotAll(&dir, &files)

       DESCRIPTION
       Erase (fma) and replot the filelist display in system 1.
       Therefore all plot should be redone...
       this is done at the end of the function.

       PARAMETERS:
   - dir  : a valid yocoBROWSER_DIR_INFO structure
   - files: a valibd yocoBROWSER_FILE_INFO structure
    */
{
    yocoLogTrace,"_yocoGuiBrowserPlotAll()";
    
    local title, justify, limitLength, name, nbLine;
    /* Plotting parameters */
    justify = "LA";
    limitLength = 100;

    /* Number of lines */
    nbLine = __yocoGuiBrowserGetNbLine(dir)

        /* Erase... so every system should be replot after this one */  
        /* Setup the ploting systems */
        fma;
    window, win, style="nobox.gs";
    get_style,, _s,__l,__c;
    _s = _s([1,1]);
    _s(1).viewport = dir.vDis;
    _s(2).viewport = dir.vBar;
    set_style,1, _s, __l, __l;
    palette,"gray.gp";

    /* Plot the title */
    plt,
        yocoStrReplace(dir.title, ["!","_"], ["!!","!_"]),
        dir.vDis(zcen:1:2)(1), dir.vDis(4)+0.02-0.015, color="black",
        justify="CB", font="timesB",
        height=18,tosys=0;

    /* Plot a box around the text FIXME: can be done with the styles */
    plsys,0;
    plg,dir.vDis([3,4,4,3]),dir.vDis([1,1,2,2]),closed=1,type=1,marks=0,width=2,color="black";

    /* Some init */
    dir.nbFile = numberof(files);

    /* Get some info about the string lenght for formating */
    maxLenght = min(limitLength, max(strlen(files.name)));

    /* Loop on the files */
    plsys,1;
    for (i=1 ; i<=numberof(files) ; i++)
    {

        /* Update pos, start with 1 for the first element,
           this is required for ploting the selection icons and
           perform the mouse test afterward */
        f = files(i);

        /* Format the displayed line if name is too long */
        name = f.name;
        if ( strlen(name)>limitLength ) {
            name = strpart(name,:5)+"..."+strpart(name,-limitLength+9:);
        }

        /* Add the name + info */
        Str = swrite(format="%-"+pr1(maxLenght)+"s     %-s", name, f.info);

        /* Plot the background frames used to emphasize the selection,
           By default hide them, they will be unhide by 'ReplotSelection' */
        plf, [[0.85]],
            i-[[0,1],[0,1]],
            3*nbLine*[[0,0],[1,1]],
            cmin=0,cmax=1,hide=0,edges=0;

        /* In the forground, plot the filename + info, directory are in Bold,
           the 0.25 and 0.05 shifts are for better centering */
        plt,
            yocoStrReplace(Str, ["!","_"], ["!!","!_"]),
            0.25, i-0.15, color="black",
            justify=justify, font=dir.font+["","B"](f.isDir+1),
            height=dir.height,tosys=1,color=f.color;
    }

    /* Replot the header's buttons */
    plsys,0;
    for (i=1 ; i<=dir.nbBut ; i++)
    {
        b = dir.but(i);
        plf, b.color(,-,-),
            b.y+b.dy*[[-1,1],[-1,1]],
            b.x+b.dx*[[-1,-1],[1,1]],
            cmin=0,cmax=1,hide=0,edges=1;
        plt, b.text, b.x, b.y, justify="CH", font=b.font, height=b.height, opaque=0;
    }

    /* Replot the selection and the limits */
    _yocoGuiBrowserReplotSelection, dir, files;
    _yocoGuiBrowserReplotLimits, dir;

    /* Redraw */
    redraw;
    yocoLogTrace,"_yocoGuiBrowserPlotAll done";
}

/***************************************************************************/
/* Browsing functions
/***************************************************************************/

func _yocoGuiBrowserHeaderTest(&dir, &files, click)
/* DOCUMENT _yocoGuiBrowserHeaderTest(&dir, &files, click)
   
       DESCRIPTION
       Loop on the buttons to check if one of them
       has been selected by the last click. In that case,
       execute the associated action.
   
       PARAMETERS:
   - dir  : a valid yocoBROWSER_DIR_INFO structure
   - files: a valibd yocoBROWSER_FILE_INFO structure
   - click: double array as returned by the mouse function
    */
{
    /* Loop on the buttons */
    for ( i=1 ; i<=dir.nbBut ; i++ )
    {
        /* test if clicked... execute the associated action
           and break the loop (only one button at a time) */
        if (
            abs(click(6) - dir.but(i).y) < dir.but(i).dy &&
            abs(click(5) - dir.but(i).x) < dir.but(i).dx )
        {
            dir.presBut = i;
            tmp = symbol_def( dir.but(i).action )(dir, files);
            return 1;
        }
    }
    return 0;
}

/***************************************************************************/

func _yocoGuiBrowserViewportTest(&dir, which, clk, &f0, &l0)
/* DOCUMENT _yocoGuiBrowserViewportTest(&dir, which, clk, &f0, &l0)
       &l0 )
   
       DESCRIPTION
       Check if the click has be done inside the display
       viewport... in that case return the positions clicked
       in unit of "files".

       PARAMETERS:
   - dir  : a valid yocoBROWSER_DIR_INFO structure
   - which: choose a viewport to test: 1 is 'vDis', else is 'vBar'
   - clk  : 
   - f0   : 
   - l0   : 
    */
{
    /* Get the viewport */
    local vp, f0, l0;
    vp = ( which ? dir.vDis : dir.vBar );

    /* If outside the viewport -> return [] */
    if ( clk(6)>vp(4) || clk(6)<vp(3) || clk(5)>vp(2) || clk(5)<vp(1) )
        return [];

    /* Otherwise convert into 'files position' */
    local first, last, _tmp;
    first = int(clk(2))+1;
    last  = int(clk(4))+1;

    /* avoid the limits */
    f0 = first = min( max(1, first), dir.nbFile);
    l0 = last  = min( max(1, last),  dir.nbFile);

    /* Sort them */
    _tmp  = min(first, last);
    last  = max(first, last);
    first = _tmp;

    /* Bug fixed when the last one is larger than the number of files... */

    /* Return the clicked positions in the list of file */
    return indgen( first:last );
}

/***************************************************************************/

func yocoGuiBrowser(inputDir, win, dpi, customInit, customArg)
/* DOCUMENT yocoGuiBrowser(inputDir, win, dpi, customInit, customArg)

       DESCRIPTION
       Simple file browser, but customizable for various application via
       the customInit function.

       PARAMETERS:
   - inputDir  : (optional) input dir, where to start the navigation.
                     Note that the current dir (as returned by get_cwd())
                     is modified in real-time by the browser.
   - win       : (optional) browser's window (default is 0).
   - dpi       : (optional) browser's window dpi.
   - customInit: (optional) a function called after standard initialization
                     of the yocoBROWSER_DIR_INFO variable, done by the function
                     "_yocoGuiBrowserInit". Can be used to add buttons and actions
                     to the browser. See example in "_yocoGuiBrowserInit".
                     Syntax should be
                     > customInit, dir, custromArg;
   - customArg : arguments for the custom initialization.
   
       RETURN VALUES:
       - return a list of files and/or directory as a string array. If not
       selection has been done, return [].

       CAUTIONS:
       This browser can be used with whatever screen resolution (DPI) used...
       but in order to see something, you need to be around DPI~70.
    */
{
    yocoLogTrace,"_yocoGuiBrowser()";

    local dir, files, clk, time, pos, lastClick, lastTime;
    lastPos  = -99;
    lastTime = -99.0;
    time = [0.0,0.0,0.0];

    /* Init the window and the structures */
    _yocoGuiBrowserInit, dir, win, dpi;

    /* Execute other init, in case of customization */
    if ( is_func(customInit) )  customInit, dir, customArg;

    /* Fill it with specified dir */
    if ( !yocoGuiBrowserUpdate(dir, files, inputDir) )
    {
        /* If failed to list the dir, exit */
        winkill;
        return 0;
    };

    /**** Test buttons and execute action while the exit flag is raise ****/
    while ( !dir.exit )
    {

        /*** Wait for the mouse ***/
        clk = mouse(-1, 1, "");
        timer, time;

        /*** If click on the list of files/dirs (inside vDis) ***/
        if ( is_array((pos=_yocoGuiBrowserViewportTest(dir, 1, clk))) )
        {

            /* Check if double-click, should be less than 0.75s
               and both previous and actual clicked should be scalar,
               - if dir, enter in it
               - if file, select only this one and exit */
            if ( (time(3) - lastTime)<0.75 &&
                 numberof(pos)==1         &&
                 numberof(lastPos)==1     &&
                 pos(1)==lastPos(1)      )
            {
                if ( files(pos(1)).isDir )
                {
                    yocoGuiBrowserUpdate, dir, files, files(pos(1)).name;
                }
                else {
                    files.isSel = 0;
                    files(pos(1)).isSel = 1;
                    dir.exit = 1;
                    dir.ReturN = 1;
                }
            }
            /* If not a valid double click,
               (un)select the given file/dir,
               replot only selection */
            else
            {
                files(pos).isSel = !files(pos).isSel;
                _yocoGuiBrowserReplotSelection, dir, files;
            }

            /* store the clicked... and continue */
            lastPos  = pos;
            lastTime = time(3);
            continue;
        }

        /*** If click on the scrollBar (inside vBar) ***/
        if ( is_array((pos=_yocoGuiBrowserViewportTest(dir, 0, clk, f, l))) )
        {
            /* Number of line */
            nbLine = __yocoGuiBrowserGetNbLine(dir);

            /* If first click is inside the 'bar' -> go where it has been
             * released (put the midle of the display at the clicked pos) */
            if ( f>=dir.pos && f<=dir.pos+nbLine ) {
                dir.pos = int( l - 0.5*nbLine );
            }
            /* If first click is top/bottom of the 'bar' -> go up/down */
            else if ( f<dir.pos ) {
                dir.pos -= int(0.3*nbLine) ;
            }
            else if ( f>dir.pos+nbLine ) {
                dir.pos += int(0.3*nbLine) ;
            }
            /* Only limits have changed... replot only them */
            _yocoGuiBrowserReplotLimits, dir;
            continue;
        }

        /*** If clik on a header button ***/
        _yocoGuiBrowserHeaderTest, dir, files, clk;

    } /**** End loop on mouse ****/

    /* Kill the browser window before returing */
    winkill;

    /* Format the output */
    local output;
    output = files.name( where(files.isSel) );
    if ( numberof(output)==1 ) output = output(1);

    yocoLogTrace,"_yocoGuiBrowser done";
    if(dir.ReturN==1)
        return output;
    else
        return;
}
