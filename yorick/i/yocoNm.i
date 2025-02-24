/******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Construct windows with N by M Gist systems for yorick
 *
 * "@(#) $Id: yocoNm.i,v 1.22 2011-01-13 20:58:39 lebouquj Exp $"
 *
 ******************************************************************************/

func yocoNm(void)
    /* DOCUMENT yocoNm

       DESCRIPTION
       Construct and handle windows with N by M Gist systems.
       See yocoPlotPlgMulti to plot a bundle of curves in several
       Gist systems.

       VERSION
       $Revision: 1.22 $

       REQUIRE
       - style.i

       FUNCTIONS
       - yocoNm         : This script
       - yocoNmCreate   : Create a sheet Gist ploting window with several
                          systems, ordered in columns and lines (N columns x M
                          lines)
       - yocoNmLimits   : Set the limits of all systems at the same time
       - yocoNmLogxy    : Set/unset the log display of all systems at the same
                          time
       - yocoNmMainTitle: Plot a main title to the sheet
       - yocoNmPlsys    : Select a given gist system
       - yocoNmRange    : Set the y-range of all systems at the same time
       - yocoNmRangex   : Set the x-range of all systems at the same time
       - yocoNmRead     : Read the number of systems in the current sheet
       - yocoNmTest     : Plot a bundle of curve and title in all gist-systems,
                          to test them.
       - yocoNmTitle    : Plot titles on top of each column
       - yocoNmXytitles : Plot bottom and left (X and Y) titles
    */
{
    version = strpart(strtok("$Revision: 1.22 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoNm;
    }   
    return version;
} 

require,"style.i";

/* Default value for most yocoNm parameters, in order
   to allow the experts user to change the preferences
   of yocoNm. */
local yocoNmDefault_style;
local yocoNmDefault_xtitleSpace;
local yocoNmDefault_ytitleSpace;
local yocoNmDefault_mtitleSpace;
local yocoNmDefault_V;
local yocoNmDefault_dx;
local yocoNmDefault_dy;
yocoNmDefault_xtitleSpace = 0.06;
yocoNmDefault_ytitleSpace = 0.07;
yocoNmDefault_mtitleSpace = 0.09;
yocoNmDefault_rtitleSpace = 0.01;
yocoNmDefault_V = [1,1];
yocoNmDefault_dy = yocoNmDefault_dx = 0.02;

func yocoNmCreate(win, n, m, dx=, dy=, fy=, fx=, rx=, ry=, V=, style=, file=, square=, landscape=, display=, dpi=, wait=, private=, hcp=, dump=, legends=, width=, height=, rgb=, tickLen=, labelHeight=, xtitleSpace=, ytitleSpace=, rtitleSpace=, mtitleSpace=)
    /* DOCUMENT yocoNmCreate(win, n, m, dx=, dy=, fy=, fx=, rx=, ry=, V=, style=, file=, square=, landscape=, display=, dpi=, wait=, private=, hcp=, dump=, legends=, width=, height=, rgb=, tickLen=, xtitleSpace=, ytitleSpace=, rtitleSpace=, mtitleSpace=)

       DESCRIPTION
       Construct a ploting windows with N by M Gist systems.
       Systems can be access with yocoNmSelectSys or plsys   
       See yocoPlotPlgMulti to plot a bundle of curves in several
       Gist systems.

       PARAMETERS
       - win  : is the number of the window to style (default is current window)
       
       - n, m : number gist-systems of the sheet, given as a number
                of columns (N) and lines (M). Default is the numbers
                of columns and lines of the current window.
     
       - dx, dy : x/y offset between the column/lines, in Gist's "NDC"
                  unit. In this system, 0.0013 unit is 1.000 point, and
                  there are 72.27 points per inch.
                  Default are yocoNmDefault_dy=yocoNmDefault_dx=0.02;
              
       - fy, fx : 1/0, set/unset the x and y ticks of each system by
                  specifying 1/0 for yes/no (default is ticks on all
                  systems [1,1,1,..]).
     
       - rx, ry : relative x/y width/height of different columns/lines.
                  So that: rx = [0.5,1] will setup a first column twice
                  smaller than the second one. (default is systems of
                  equivalent sizes [1,1,1...]).
              
       - V : global viewport containing all the systems, defined as
             V = [xmin,xmax,ymin,ymax]. For instance:
             V = [0.12,0.73,0.1,0.9]; or V = [0.1,0.9,0.12,0.73];
             Coordinates are in Gist's "NDC" coordinate system.  In this system,
             0.0013 unit is 1.000 point, and there are 72.27 points per inch.
             The lower left hand corner of the sheet of paper is at (0,0).
             For landscape=0, the 8.5 inch edge of the paper is horizontal;
             for landscape=1, the 11 inch edge of the paper is horizontal.
             You can also use the formating V =[rx,ry]. The viewport
             will be the entire sheet divided by rx and ry in X and Y
             dimensions respectively. Default is the entire
             yocoNmDefault_V=[1,1];
              
       - xtitleSpace, ytitleSpace, rtitleSpace, mtitleSpace : Keep space between
             the edge of the defined Viewport and the systems, on the left side
             (xtitle), on the bottom (ytitle), on top (mtitle) and on right
             (rtitle). This is useful if you have large ticks numbers or titles
             spanning several lines. Default are:
             yocoNmDefault_xtitleSpace = 0.06;
             yocoNmDefault_ytitleSpace = 0.07;
             yocoNmDefault_mtitleSpace = 0.09;
             yocoNmDefault_rtitleSpace = 0.01;
                    
       - style : gist system style, should be valid gist file, default is
                'yocoNmDefault_style = "boxed.gs";
             
       - file : optional file output name (Gist style sheet format)
     
       - square : 1, force the systems to be square
     
       - landscape : if true the sheet is landscape
     
       Others keywords: see 'window' function.
    
       EXAMPLES
       yocoNmCreate, win, n, m : set a n.x.m window
       yocoNmCreate, win, nwin : set a n.x.m window with n.m>nwin
       yocoNmCreate,, dx=1.    : change the dx of the current window without
       destroy the plot !
    */
{
    local n0,n,m,nn,mm,num,Dvx,Dvy,land,systems,leg,cleg;
    local vp_sheet,vp_sheet_size,vp_sheet_center;

    /* default style */
    if(is_void(style)){
        if(is_void(yocoNmDefault_style)) style = "boxed.gs";
        else style = yocoNmDefault_style;
    }

    /* default for spacing around and betweens the systems */
    if (is_void(xtitleSpace)) xtitleSpace = yocoNmDefault_xtitleSpace;
    if (is_void(ytitleSpace)) ytitleSpace = yocoNmDefault_ytitleSpace;
    if (is_void(mtitleSpace)) mtitleSpace = yocoNmDefault_mtitleSpace;
    if (is_void(rtitleSpace)) rtitleSpace = yocoNmDefault_rtitleSpace;
    if (is_void(V))           V  = yocoNmDefault_V;
    if (is_void(dx))          dx = yocoNmDefault_dx;
    if (is_void(dy))          dy = yocoNmDefault_dy;

    /* default windows */
    if(is_void(win))    win = window();
    
    /* default value for n and m are the current values */
    if(is_void(n) && is_void(m))  yocoNmRead,win,n,m;
    if(is_void(n) && !is_void(m)) yocoNmRead,win,n;
    if(!is_void(n) && is_void(m)) {
        m = int(ceil(n/ceil(sqrt(n)))); n=int(ceil(sqrt(n))); n0=n;n=m;m=n0;
    }
    
    /* default value for dx and dy */
    dx = _yocoNmConform1D(max(n-1,1), yocoNmDefault_dx ,"dx", dx);
    dy = _yocoNmConform1D(max(m-1,1), yocoNmDefault_dy ,"dy", dy);
    
    /* if 1 line or 1 column, dx and dy should be zero */
    if ( n==1 ) dx*=0;
    if ( m==1 ) dy*=0;
    
    /* default value for rx and ry */
    rx = _yocoNmConform1D(n, [1.0] ,"rx", rx);
    ry = _yocoNmConform1D(m, [1.0] ,"ry", ry);    
    
    /* configure the x-labels */
    fx = _yocoNmConform2D(n,m,1, [[-1]] ,"fx", fx);
    fy = _yocoNmConform2D(n,m,0, [[-1]] ,"fy", fy);
   
    /* where f<0, verifie the space between each systems */
    fx0 = fx;  fy0 = fy;
    fx = fx0 + (fx0<0) * (abs(fx0)  +  (grow(dy,10.0)(1:m)(-,)>0.035) );
    fy = fy0 + (fy0<0) * (abs(fy0)  +  (grow(10.0,dx)(1:n)(,-)>0.035) );


    /* Some verbose in case of debug */
    yocoLogTest,"yocoNmCreate - fx="+pr1(fx);
    yocoLogTest,"yocoNmCreate - fy="+pr1(fy);
    yocoLogTest,"yocoNmCreate - dx="+pr1(dx);
    yocoLogTest,"yocoNmCreate - dy="+pr1(dy);
        
    /* read the default style */
    __yocoNmtype__ = type;
    read_style, style, land, systems, leg, cleg;
    type =  __yocoNmtype__;
    if(!is_void(landscape)) land = landscape;

    /* grow the 'systems' variable to be an array */
    systems = array(systems(1),n,m);

    /* change the thick lenght if required */
    if(!is_void(tickLen)) {
        systems.ticks.horiz.tickLen *= tickLen;
        systems.ticks.vert.tickLen *= tickLen;
    }

    if(!is_void(labelHeight)) {
        systems.ticks.horiz.textStyle.height *= labelHeight;
        systems.ticks.vert.textStyle.height *= labelHeight;
    }
    
    

    /* Compute the usable space on the sheet, if not given by
       the user, or if given in a [Vx, Vy] way */
    if ( !(numberof(V)==4) ) {

        /* default size of a a4 sheet */
        if (landscape) vp_sheet = [0,1.033,0,0.799];
        else           vp_sheet = [0,0.799,0,1.033];

        vp_sheet_center = vp_sheet(zcen)([1,3]);
        vp_sheet_size   = vp_sheet(dif)([1,3])/2.;

        if ( numberof(V)==2 ) {
            vp_sheet_size *= V;
        }
        else if (!is_void(V)) {
            error,"V should be void, a 4-element array, or a 2-element array."
                }

        /* construct the sheet where the systems will be drawed */
        V = [ vp_sheet_center(1) - vp_sheet_size(1) + ytitleSpace,
              vp_sheet_center(1) + vp_sheet_size(1) - rtitleSpace,        
              vp_sheet_center(2) - vp_sheet_size(2) + xtitleSpace,
              vp_sheet_center(2) + vp_sheet_size(2) - mtitleSpace];
    }

    /* compute the system dimensions */
    Dvx = (V(2)-V(1) - dx(sum))/n;
    Dvy = (V(4)-V(3) - dy(sum))/m;

    /* normalization of the ratio */
    rx = rx * (V(2)-V(1) - dx(sum)) / rx(sum) / Dvx;
    ry = ry * (V(4)-V(3) - dy(sum)) / ry(sum) / Dvy;

    /* eventually force the system to be square */
    if(square) Dvx = Dvy = min(Dvx,Dvy);


    
    /* compute the limits of each viewport,
       invert the order of the y plot
       (from the top to the bottom) */
    xmin = (V(1) + grow(0.,Dvx*rx)(psum)(:-1) + grow(0.,dx)(psum))(,-:1:m);
    if(n==1) xmin = xmin([[1]]);
    xmax = xmin +  Dvx*rx;
    ymin = (V(3) + grow(0.,Dvy*ry(::-1))(psum)(:-1) + grow(0.,dy(::-1))(psum))(-:1:n,);
    if(m==1) ymin = ymin([[1]]);
    ymax = ymin + (Dvy*ry(::-1))(-,);

    /* if recentering */
    if(square) {
        delta = (V(1)+V(2))/2. - (min(xmin)+max(xmax))/2. ;
        xmin += delta; xmax += delta;
        delta = (V(3)+V(4))/2. - (min(ymin)+max(ymax))/2. ;
        ymin += delta; ymax += delta;
    }    

    /* set the systems viewports dimensions */
    systems.viewport = transpose([xmin,xmax,ymin(,::-1),ymax(,::-1)],2);
    
    /* set the systems ticks flags */
    systems.ticks.horiz.flags -= 0x020*((systems.ticks.horiz.flags/0x020)%2)*!fx;
    systems.ticks.vert.flags  -= 0x020*((systems.ticks.vert.flags/0x020)%2)*!fy;

    /* chose a default hcp file */
    if(!is_void(display) && is_void(hcp)) {
        hcp="out.ps";
        yocoLogWarning,"default HCP file will be set to 'out.ps'";
    }

    /* go to the 'win' windows if display */
    if(!is_void(display) || !is_void(private) || !is_void(dpi) )
    {
        winkill,win;
        window,win,display=display,dpi=dpi,wait=wait,
            private=private,hcp=hcp,dump=dump,
            legends=legends,width=width,height=height,rgb=rgb;
    }
    
    /* go to the 'win' windows if any display */
    window,win,wait=wait,
        dump=dump,
        legends=legends,width=width,height=height,rgb=rgb;

    /* set this style in the 'win' window */
    set_style,land,systems(*),leg,cleg;

    /* if need, write the style */
    if(file) write_style,file,land,systems,leg,cleg;

    return win;
}

/*---------------------------------------------------------------------------*/

func _yocoNmConform2D(n, m, isM, default, name, arr)
    /* DOCUMENT _yocoNmConform2D(n, m, isM, default, name, arr)

       DESCRIPTION

       PARAMETERS
       - n      : 
       - m      : 
       - isM    : 
       - default: 
       - name   : 
       - arr    : 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    local darr;
    /* configure the rank */
    if(is_void(arr))            arr = default;
    else if (dimsof(arr)(1)==0) arr = [[arr]];
    else if (dimsof(arr)(1)==1 )  arr = ( isM ? arr(-,) : arr(,-) );
    else if (dimsof(arr)(1)!=2) error,"Parameter "+name+" should be of rank 0,1 or 2";

    /* convert into arrays conformabe with n/m */
    darr = dimsof(arr);  
    if (darr(2)>n || darr(3)>m) {
        yocoLogWarning,"Paramater "+name+" has too much elements (continue anyway)";
    }
  
    return arr( 1 + (indgen(0:n-1)%darr(2)), 1 + (indgen(0:m-1)%darr(3)));
}

func _yocoNmConform1D(d, default, name, arr)
    /* DOCUMENT _yocoNmConform1D(d, default, name, arr)

       DESCRIPTION

       PARAMETERS
       - d      : 
       - default: 
       - name   : 
       - arr    : 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    local darr;
    /* configure the rank */
    if(is_void(arr))            arr = default;
    else if (dimsof(arr)(1)==0) arr = [arr];
    else if (dimsof(arr)(1)!=1) error,"Parameter "+name+" should be of rank 0 or 1";
  
    /* convert into arrays conformabe with n/m */
    darr = dimsof(arr);
    if (darr(2)>d) {
        yocoLogWarning,"Paramater "+name+" has too much elements (continue anyway)";
    }

    return arr( 1 + (indgen(0:d-1)%darr(2)) );
}

/*---------------------------------------------------------------------------*/

func yocoNmMainTitle(title, adjust)
    /* DOCUMENT yocoNmMainTitle(title, adjust)

       DESCRIPTION
       Plot a global title to a sheet.
       font and height can be changed with the external
       variables pltitle_font and pltitle_height
    */
{
    local xt,yt,n,m;
    extern pltitle_height;
    extern pltitle_font;

    if (is_void(adjust)) adjust=0;

    yocoNmRead,,n,m,sys;
    xt = (sys(1,1,1)+sys(2,n)) / 2.;
    yt = sys(4,1,1);

    plt, title, xt, yt + 0.055 + adjust,
        font=pltitle_font, justify="CB", height=pltitle_height,tosys=0;  
}


/*---------------------------------------------------------------------------*/

func yocoNmTitle(titles, adjust)
    /* DOCUMENT yocoNmTitle(titles, adjust)

       DESCRIPTION
       The same as pltitle, but for n by m window, so 'titles' could be array of
       string.

       EXAMPLES
       > yocoNmCreate, 0, 2, 3;
       > yocoNmXytitles, ["Time (s)","Time (hours)"],["Data A","Data B","Data C"];
       > yocoNmTitle,["Small Scale","Long Scale"];
    */
{
    local n,m,sys,xmin,xmax,tops,imax;
    extern pltitle_height;
    extern pltitle_font;
    extern plTitle_adjust;
  
    if(is_void(adjust) && is_void(plTitle_adjust)) adjust=0.;
    if(is_void(adjust)) adjust=plTitle_adjust;
  
    yocoNmRead,,n,m,sys;
    xmin = sys(1,)(*); xmax = sys(2,)(*);
    ymin = sys(3,)(*); ymax = sys(4,)(*);
    tpos = [ ((xmax+xmin)/2. )(1:n) , (max(ymax))(-:1:n) ];  
  
    imax = max(numberof(titles),numberof(tpos(,1)));
    if (is_array(titles)) for(i=1; i<=imax; i++) {
            ptitles= numberof(titles)>=1 ? &titles(i%numberof(titles)) : &titles;
            px= numberof(tpos(,1))>=1 ? &tpos(,1)(i%numberof(tpos(,1))) : &tpos(,1);  
            py= numberof(tpos(,2))>=1 ? &tpos(,2)(i%numberof(tpos(,2))) : &tpos(,2);
            plt, *ptitles, *px, *py + 0.02 + adjust,
                font=pltitle_font, justify="CB", height=pltitle_height,tosys=0;
        }
}

/*---------------------------------------------------------------------------*/

func yocoNmXytitles(xtitles, ytitles, adjust)
    /* DOCUMENT yocoNmXytitles(xtitles, ytitles, adjust)
       yocoNmXytitles, xtitles, ytitles, adjust;

       DESCRIPTION
       The same as xytitles, but for n by m window. 'xtitles' and/or 'ytitles'
       could be array of string.

       The extern variable 'pltitle_adjust' is the default adjustement for
       legends: [deltax,deltay].

       EXAMPLES
       > yocoNmCreate, 0, 2, 3;
       > yocoNmXytitles, ["Time (s)","Time (hours)"],["Data A","Data B","Data C"];
    */
{
    local imax,n,m;
    extern pltitle_height;
    extern pltitle_font;
    extern pltitle_adjust;
    if (is_void(pltitle_adjust)) pltitle_adjust=[0.,0.];
    if (is_void(adjust)) adjust= pltitle_adjust;

    yocoNmRead,,n,m,sys;
    xmin = sys(1,)(*); xmax = sys(2,)(*);
    ymin = sys(3,)(*); ymax = sys(4,)(*);

    xpos = [ ((xmax+xmin)/2. )(1:n) , (min(ymin))(-:1:n) ];
    ypos = [ (min(xmin))(-:1:m) , ((ymax+ymin)/2.)(::n)  ];

    imax = max(numberof(xtitles),numberof(xpos(,1)));
    if (is_array(xtitles)) for(i=1; i<=imax; i++) { 
            pxtitles= numberof(xtitles)>=1 ? &xtitles(i%numberof(xtitles)) : &xtitles;
            px= numberof(xpos(,1))>=1 ? &xpos(,1)(i%numberof(xpos(,1))) : &xpos(,1);  
            py= numberof(xpos(,2))>=1 ? &xpos(,2)(i%numberof(xpos(,2))) : &xpos(,2);  
            plt, *pxtitles, *px, *py + adjust(2) - 0.05,
                font=pltitle_font, justify="CT", height=pltitle_height, tosys=0;
        }

    imax = max(numberof(ytitles),numberof(ypos(,1)));
    if (is_array(ytitles)) for(i=1; i<=imax; i++) { 
            pytitles= numberof(ytitles)>=1 ? &ytitles(i%numberof(ytitles)) : &ytitles;
            px= numberof(ypos(,1))>=1 ? &ypos(,1)(i%numberof(ypos(,1))) : &ypos(,1);  
            py= numberof(ypos(,1))>=1 ? &ypos(,2)(i%numberof(ypos(,2))) : &ypos(,2);  
            plt, *pytitles, *px + adjust(1) - 0.05, *py,
                font=pltitle_font, justify="CB", height=pltitle_height, orient=1, tosys=0;
        }
}

/*---------------------------------------------------------------------------*/

func yocoNmLogxy(xflag, yflag)
    /* DOCUMENT yocoNmLogxy(xflag, yflag)

       DESCRIPTION
       The same as logxy but for n by m window;
    */
{
    local nsys,Xmin,Xmax,Ymin,Ymax;  
    get_style,landscape,systems,legends,clegends;
    nsys = numberof(systems);
    for(i=1;i<=nsys;i++) {
        plsys,i;
        logxy, xflag, yflag;
    }
}

/*---------------------------------------------------------------------------*/

func yocoNmLimits(xmin, xmax, ymin, ymax, square=, nice=, restrict=, individual=)
    /* DOCUMENT yocoNmLimits(xmin, xmax, ymin, ymax, square=, nice=, restrict=, individual=)

       DESCRIPTION
       The same as limits() but for n by m window, so xmin,xmax,ymin,ymax can be
       arrays. If called without arguments, all the systems will be set with the
       same limits. If call with individual=1, all systems will be set with
       different optimized limits.
    */
{
    local n,m;

    /* if individual, all limits are restore independantly */
    if(individual) _set_limits_nm,;
    /* set the global limits */
    else if(is_void(xmin) && is_void(xmax) && is_void(ymin) && is_void(ymax) && am_subroutine())
    {_set_limits_nm,_get_limits_nm(1);}
    /* set the limits store in xmin array*/
    else if(numberof(xmin)>1) _set_limits_nm,xmin;
    /* else, set the inputs as limits */
    else {
        yocoNmRead,,n,m;
        for(i=1;i<=n*m;i++) {
            plsys,i;limits,xmin,xmax,ymin,ymax,square=square,nice=nice,restrict=restrict;   
        }
    }
    /* return the previous global limits */
    return _get_limits_nm();    
}

func _get_limits_nm(mode)
    /* DOCUMENT _get_limits_nm(mode)

       DESCRIPTION
       Private function for yocoNm.
    */
{
    /* if mode<0 return the current limits, else return the
       max of the plots. if abs(mode)=1 return the max
       over all systems */
    local n,m,l,old_l;
  
    if(is_void(mode)) mode=0;
    yocoNmRead,,n,m,sys;

    /* Loop on all array */
    l = array(double,5,n,m); 
    for(i=1;i<=n;i++)
        for(j=1;j<=m;j++) {
            yocoNmPlsys,i,j,n;
            if( !(mode<0) ) {
                old_l=limits();
                limits; l(,i,j) = limits();
                limits, old_l(1),old_l(2),old_l(3),old_l(4);
            } else {
                l(,i,j) = limits();
            }
        }

    /* format the output */
    if(abs(mode)==1) l=[l(1,min,min),l(2,max,max),l(3,min,min),l(4,max,max),l(5,1,1)];
    return l;
}

func _set_limits_nm(l)
    /* DOCUMENT _set_limits_nm(l)

       DESCRIPTION
       Private function for yocoNm.
    */
{
    local n,m;
    yocoNmRead,,n,m,sys;
    if(is_array(l)) {dim=dimsof(l); if(dim(1)==1) dim=[3,dim(2),1,1];}
    for(i=1;i<=n;i++)
        for(j=1;j<=m;j++) {
            yocoNmPlsys,i,j,n;
            if(is_array(l)) {limits,l(1,i%dim(3),j%dim(4)),l(2,i%dim(3),j%dim(4)),l(3,i%dim(3),j%dim(4)),l(4,i%dim(3),j%dim(4));}
            else limits;
        }
}

/*---------------------------------------------------------------------------*/

func yocoNmRead(win, &n, &m, &sys)
    /* DOCUMENT yocoNmRead(win, &n, &m, &sys)
       yocoNmRead,win,n,m,sys

       DESCRIPTION
       Return thenumber of horizontal (n) and vertical (m) system in a NxM
       window. The outputs sys argument is the system array as return by the
       "get_style" function by reshaped into a NxM array.
    */
{
    local ymin, nsys,_land,_sys,_leg,_cleg;
    window,win;
    get_style, _land, _sys, _leg, _cleg;

    nsys = numberof(_sys);
    ymin = _sys.viewport(3,);

    /* find n */
    n = where(ymin!=ymin(1));
    if(is_array(n)) n = n(1)-1;
    else n = nsys;

    /* find m */
    m = nsys/n;

    sys    = array(double,4,n,m);
    sys(,*) = _sys.viewport;

    return [n,m]
        }

/*---------------------------------------------------------------------------*/

func yocoNmPlsys(col, line, n)
    /* DOCUMENT yocoNmPlsys(col, line, n)
       yocoNmPlsys,col,line;
       yocoNmPlsys(col,line);

       DESCRIPTION
       Switch to (or return the number of) the colxline system in a NxM
       (horyzontalxvertical) window. n, the number of horyzontal system, is an
       optional argument. If not present, the function will take the number of
       the current window.

       If called as a subroutine, the routine will swith to the system.
       If called as a function, the routine will only return the system number,
       so that this two following calls are identical.

       EXAMPLES
       > yocoNmPlsys,2,3;
       > plsys, yocoNmPlsys(2,3);
    */ 
{
    local n;
    if(is_void(n)) n = yocoNmRead()(1);
    if ( am_subroutine() ) plsys,(line-1)*n + col;
    return (line-1)*n + col;
}

/*---------------------------------------------------------------------------*/
func __range(void)
    /* DOCUMENT __range

       DESCRIPTION
       Private function for yocoNm
    */
{
    local lim;
    lim = limits()(1:2);
    limits;
    limits,lim(1),lim(2);
    return lim;
}

func _yocoNmLimits(void)
    /* DOCUMENT _yocoNmLimits

       DESCRIPTION
       Private function for yocoNm
    */
{
    local lim,out;
    lim = limits();
    limits;
    out = limits();
    limits,lim;
    return out;
}

func yocoNmRange(ymin, ymax, line, column)
    /* DOCUMENT yocoNmRange(ymin, ymax, line, column)
       yocoNmRange, ymin, ymax, line
       yocoNmRange, ymin, ymax
       yocoNmRange

       DESCRIPTION
       Set the Y-range for a n.m ploting window.

       PARAMETERS
       - ymin  : specified range. Can be scalars of arrays.
       - ymax  : specified range. Can be scalars of arrays.
       - line  : is a vector of the line number you want to range (integer).
                 If nil, the default is indgen(m) (all line).
       - column: If nil, the default is value is the maximum of all
                 windows of the considered line.
                 (optional): specify the considered column to be
                 ranged, default is indgen(n) (all lines);
    */
{
    local n,m,lim,pymin,pymax;
    yocoNmRead,,n,m;
    if(is_void(column)) column = indgen(n);
    if(is_void(line))   line   = indgen(m);
    if(is_void(ymin)) fmin = 1; else fmin = 0;
    if(is_void(ymax)) fmax = 1; else fmax = 0;

    for(l=1;l<=numberof(line);l++) {
        if(fmin) {
            plsys,(line(l)-1)*n+1; __range; ymin=limits()(3);
            for(col=1;col<=numberof(column);col++) {
                c = column(col);
                plsys,(line(l)-1)*n+c; __range; ymin=min(ymin,limits()(3));}
        }
        if(fmax) {
            plsys,(line(l)-1)*n+1; __range; ymax=limits()(4);
            for(col=1;col<=numberof(column);col++) {
                c = column(col);
                plsys,(line(l)-1)*n+c; __range; ymax=max(ymax,limits()(4));}
        }
        for(c=1;c<=numberof(column);c++) {
            plsys,(line(l)-1)*n + column(c);
            pymin= numberof(ymin)>=1 ? ymin(l%numberof(ymin)) : ymin;  
            pymax= numberof(ymax)>=1 ? ymax(l%numberof(ymax)) : ymax;  
            range,pymin,pymax;
        }
    }
}

/* For symmetry with yocoNmRangex */
local yocoNmRangey;
yocoNmRangey = yocoNmRange;

/*---------------------------------------------------------------------------*/

func yocoNmRangex(xmin, xmax, column, line)
    /* DOCUMENT yocoNmRangex(xmin, xmax, column, line)
       yocoNmRangex, xmin, xmax
       yocoNmRangex

       DESCRIPTION
       Set the X-range for a n.m ploting window.

       PARAMETERS
       - xmin  : specified range, can be scalars or arrays.
       - xmax  : specified range, can be scalars or arrays.
       - column: is a vector of the line number you want to range (integer).
                 If nil, the default is indgen(n) (all columns).
       - line  : If nil, the default is value is the maximum of all
                 windows of the considered columns.
                 (optional): specify the considered line to be
                 ranged, default is indgen(m) (all lines);
    */
{
    local n,m;
    yocoNmRead,,n,m;

    if(is_void(column)) column = indgen(n);
    if(is_void(line))   line   = indgen(m);

    /* eventually found the min and/or max x-range */
    if ( is_void(xmin) )
    {
        lim = _get_limits_nm(0);
        xmin = lim(1,column,line)(,min)(,-);
    }
    if ( is_void(xmax) )
    {
        lim = _get_limits_nm(0);
        xmax = lim(2,column,line)(,max)(,-);
    }

    /* Setup the x-range */
    for( c=1 ; c<=numberof(column) ; c++ )
        for(l=1;l<=numberof(line);l++) {
            yocoNmPlsys, c, l, n;
            pxmin = xmin( c%numberof(xmin(,1)), l%numberof(xmin(1,)) );
            pxmax = xmax( c%numberof(xmax(,1)), l%numberof(xmax(1,)) );
            limits, pxmin, pxmax;
        }
}

func yocoNmGridxy(x,y)
{
  local n,m;
  yocoNmRead,,n,m;
  for (i=1;i<=n*m;i++) {
    plsys,i;
    gridxy,x,y;
  }
  return 1;
}

/*---------------------------------------------------------------------------*/

func yocoNmTest(win)
    /* DOCUMENT yocoNmTest(win)

       DESCRIPTION
       Simple routine to test a window style.
       It read the number of systems and plot a curve in each of them, and add
       titles.

       EXAMPLES
       > yocoNmCreate, 0, 5, 3;
       > yocoNmTest;
    */
{
    local nsys,x;
    window,win;
    get_style,landscape,systems,legends,clegends;
    nsys = numberof(systems);

    x = span(-1,1.1,100);

    for(i=1;i<=nsys;i++) {
        plsys,i;
        plg,x^i,x,marks=0,type="solid";
    }

    yocoNmTitle,"titles";
    yocoNmXytitles,"xtitles","ytitles";
    yocoNmMainTitle,"GROS TITRE";

    yocoNmRangex,-1,1;
    yocoNmRangey,-1,1;
    yocoNmLimits;

    yocoNmPlsys,1,1;

    return nsys;
}
