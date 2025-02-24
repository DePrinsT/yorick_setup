/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Plotting tools for yorick
 *
 * "@(#) $Id: yocoPlot.i,v 1.23 2010-11-27 03:21:31 lebouquj Exp $"
 *
 */

func yocoPlot(void)
    /* DOCUMENT yocoPlot

       DESCRIPTION
       Simple ploting functions from LAOG-Yorick contribution project.

       VERSION
       $Revision: 1.23 $

       REQUIRE
       - style.i (for yocoPlotColorLookupTable)

       FUNCTIONS
       - yocoPlot                : This script
       - yocoPlotArc             : plot an arc of circle
       - yocoPlotArrow           : plot an arrow
       - yocoPlotBars            : Bar-style plot
       - yocoPlotCircle          : plot a circle
       - yocoPlotColorLookupTable: Color bar plot, in an easy way
       - yocoPlotDefaultDpi      : 
       - yocoPlotEllipse         : plot an ellipse
       - yocoPlotHistogramme     : Histogram plot with bar-like plot
       - yocoPlotHorizLine       : Plot a horizontal line
       - yocoPlotPlgMulti        : Plot a bundle of curves
       - yocoPlotPlp             : Plot symbols with upper/lower limits
       - yocoPlotPlpMulti        : Plot a bundle of symbols
       - yocoPlotPltMulti        : Plot several string at the same time
       - yocoPlotVertLine        : Plot a vertical line
       - yocoPlotWithErrBars     : Plotting data with error bars

       SEE ALSO
       yoco
    */
{
    version = strpart(strtok("$Revision: 1.23 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoPlot;
    }   
    return version;
} 

/************************************************************************/

func yocoPlotDefaultDpi(dpi, wins=, landscape=)
    /* DOCUMENT yocoPlotDefaultDpi(dpi, wins=, landscape=)

       DESCRIPTION

       PARAMETERS
       - dpi      : 
       - wins     : 
       - landscape: 

       RETURN VALUES

       CAUTIONS

       EXAMPLES

       SEE ALSO
    */
{
    local i, width, height, tmp;
  
    /* Default frames */
    if (is_void(dpi))
        dpi=70;
    if (is_void(wins))
        wins=indgen(0:63);

    /* Check dpi */
    if ( !yocoTypeIsIntegerScalar(dpi) )
        error, "dpi should be a scalar integer";
    if ( !yocoTypeIsInteger(wins) )
        error, "'wins' should be a scalar integer";
    if ( dpi<10 || dpi>200)
        error, "'dpi' should be in the range 10...200";
  
    /* Default width and height */
    width  = int( 638.0 / 75 * dpi);
    height = int( 825.0 / 75 * dpi);

    /* Landscape */
    if (landscape) {tmp=width; width=height; height=tmp; }
    pldefault,dpi=dpi;

    /* Loop */
    for ( i=1 ; i<=numberof(wins) ; i++) {
        winkill,wins(i);
        window,wins(i),dpi=dpi,height=height,width=width,display="",hcp="";
    }
}

/************************************************************************/

func yocoPlotArc(x0, y0, r, pa0, pa1, step=, color=, type=, width=, marks=, fill=, plotLast=, plotFirst=)
    /* DOCUMENT yocoPlotArc(x0, y0, r, pa0, pa1, step=, color=, type=, width=, marks=, fill=, plotLast=, plotFirst=)

       DESCRIPTION
       Plots an arc of circle, either filled or not.

       PARAMETERS
       - x0       : x center of curvature
       - y0       : y center of curvature
       - r        : radius
       - pa0      : angle of strat of arc
       - pa1      : angle of end of arc
       - step     : number of points in arc
       - color    : see 'plg'
       - type     : see 'plg'
       - width    : see 'plg'
       - marks    : see 'plg'
       - fill     : see 'plg'
       - plotLast : plot a line from the center to the end of arc
       - plotFirst: plot a line from the center to the start of arc

       EXAMPLES
       > yocoGuiWinKill;
       > window,1;
       > yocoPlotArc,0, 0, 10, 0, 3*pi/2;
       > window,2;
       > yocoPlotArc, 0, 0, 10, 0, 3*pi/2, plotLast=1, plotFirst=1;
       > window,3;
       > yocoPlotArc, 0, 0, 10, 0, 3*pi/2, fill=1;
       
       SEE ALSO yocoPlotCircle
    */
{
    if(is_void(marks))
        marks=0;
    
    if(is_void(step))
        step=100;
    
    if(is_void(plotLast))
        plotLast = 0;
    
    if(is_void(plotFirst))
        plotFirst = 0;
    
    if(is_void(color))
        color = [0,0,0];
  
    alpha=span(pa0,pa1,step);
    x = r*cos(alpha) ;
    y = r*sin(alpha);

    if(fill==1)
        plotFirst=plotLast=1;

    if(plotFirst==1)
    {
        x = grow(0.0, x);
        y = grow(0.0, y);
    }

    if(plotLast==1)
    {
        x = grow(x, 0.0);
        y = grow(y, 0.0);
    }
  
    if(fill==1)
    {
        N = numberof(y);
        Y = -y + y0;
        X = -x + x0;
        plfp, char(array(color,1)), Y, X, N;
    }
    else
        plg, -y+y0, -x+x0,color=color,type=type,width=width,marks=marks;
}

/************************************************************************/

func yocoPlotCircle(x0, y0, r, step=, color=, type=, width=, marks=, fill=)
    /* DOCUMENT yocoPlotCircle(x0, y0, r, step=, color=, type=, width=, marks=, fill=)

       DESCRIPTION
       function copied from "paint.i" from S. Guieu

       PARAMETERS
       - x0   : x center of curvature
       - y0   : y center of curvature
       - r    : radius
       - step : number of points in arc
       - color: see 'plg'
       - type : see 'plg'
       - width: see 'plg'
       - marks: see 'plg'
       - fill : see 'plg'

       SEE ALSO yocoPlotArc
    */
{
    if(is_void(marks))
        marks=0;
    
    if(is_void(step))
        step=100;
    
    if(is_void(color))
        color = [0,0,0];
    
    alpha=span(0,2*pi,step);
    x = r*cos(alpha) ;
    y = r*sin(alpha);
  
    if(fill==1)
    {
        N = numberof(y);
        Y = -y+y0;
        X = -x+x0;
        plfp, char(array(color,1)), Y, X, N;
    }
    else
        plg, -y+y0, -x+x0,color=color,type=type,width=width,marks=marks;
}

/************************************************************************/

func yocoPlotEllipse(x0, y0, r1, r2, angle, step=, color=, type=, width=, marks=, fill=)
    /* DOCUMENT yocoPlotEllipse(x0, y0, r1, r2, angle, step=, color=, type=, width=, marks=, fill=)

       DESCRIPTION
       Ellipse plot

       PARAMETERS
       - x0   : x center
       - y0   : y center
       - r1   : major axis radius
       - r2   : minor axis radius
       - angle: rotation of ellipse
       - step : number of points in arc
       - color: see 'plg'
       - type : see 'plg'
       - width: see 'plg'
       - marks: see 'plg'
       - fill : see 'plg'

       SEE ALSO yocoPlotCircle, yocoPlotArc
    */
{
    if(is_void(marks))
        marks=0;
    
    if(is_void(step))
        step=100;
    
    if(is_void(color))
        color = [0,0,0];
    
    alpha=span(0,2*pi,step);
    x = r1 * cos(alpha)*cos(angle) + r2 * sin(alpha)*sin(angle);
    y = r2 * sin(alpha)*cos(angle) - r1 * cos(alpha)*sin(angle);
  
    if(fill==1)
    {
        N = numberof(y);
        Y = -y+y0;
        X = -x+x0;
        plfp, char(array(color,1)), Y, X, N;
    }
    else if(fill==-1)
    {
        N = numberof(y)+6;
        Y = grow(-y+y0,1e99,1e99,-1e99,-1e99, 1e99, 1e99);
        X = grow(-x+x0,0,   1e99, 1e99,-1e99,-1e99, 0);
        plfp, char(array(color,1)), Y, X, N;
    }
    else
        plg, -y+y0, -x+x0,color=color,type=type,width=width,marks=marks;
}

/************************************************************************/

func yocoPlotArrow(x1, y1, x2, y2, width=, color=, type=, marks=, arlng=, facX=)
    /* DOCUMENT yocoPlotArrow(x1, y1, x2, y2, width=, color=, type=, marks=, arlng=, facX=)

       DESCRIPTION
       Plots a simple arrow from one point to another.
       Works pretty much like pldj;

       PARAMETERS
       - x1   : start x
       - y1   : start y
       - x2   : end x
       - y2   : end y
       - width: see 'pldj'
       - color: see 'pldj'
       - type : see 'pldj'
       - marks: see 'pldj'
       - arlng: arrow length
       - facX : factor to plot the arrow with right proportions whatever
       the limits are. The default guess should work as soon as
       the limits are set before plotting the arrow.

       EXAMPLES
       > yocoGuiWinKill;
       > window,3;
       > yocoPlotArc, 0, 0, 10, 0, 7*pi/4, fill=1;
       > yocoPlotCircle, 30, 50, 10, fill=1;
       > yocoPlotArrow, 28, 38, 8, 8;

       SEE ALSO
    */
{
    if(is_void(facX))
    {
        vp = viewport();
        if(nallof(vp==0))
        {
            xyfac = (vp(2) - vp(1)) / (vp(4) - vp(3));
            lims = limits();
            facX = abs((lims(2) - lims(1)) / (lims(4) - lims(3)) / xyfac);
        }
        else
            facX = 1.0;
    }
    
    ang = atan(facX*(y2-y1),x2-x1);
    lng = abs(y2-y1,(x2-x1));

    if(is_void(arlng))
        arlng = 0.1*lng;
    
    pldj,x1,y1,x2,y2, width=width, color=color;
    
    pldj, x2, y2, x2+facX*cos(ang-pi-pi/6)*arlng, y2+sin(ang-pi-pi/6)*arlng,
        width=width, color=color;
    pldj, x2, y2, x2+facX*cos(ang+pi+pi/6)*arlng, y2+sin(ang+pi+pi/6)*arlng,
        width=width, color=color;
}

/************************************************************************/

func yocoPlotVertLine(x0, color=, type=, width=, hide=, l=, tosys=, marker=, marks=)
    /* DOCUMENT yocoPlotVertLine(x0, color=, type=, width=, hide=, l=, tosys=, marker=, marks=)

       DESCRIPTION 
       Plot a vertical line at the position X0.
       The L keyword specifie the [ymin, ymax].
       By default, it is the limits of the window.
       X0 and L could be array of the same dimension.

       PARAMETERS
       - x0    : position in x of the vertical line (can be array)
       - color : see help of 'plg'
       - type  : see help of 'plg'
       - width : see help of 'plg'
       - hide  : see help of 'plg'
       - l     : specify the vertical limits [ymin,ymax] default
       are the current limits of the system
       - tosys : see help of 'plg'
       - marker: see help of 'plg'
       - marks : see help of 'plg'

       SEE ALSO
       yocoPlotHorizLine, yocoPlotVertLine
    */
{
    local imax, i;
    
    /* get the number fo lines to be ploted */
    imax = max(numberof(x0), numberof(tosys), numberof(l));

    /* -- loop on the budle of curves -- */  
    for(i= 1; i <= imax; i++) {

        plsys, _yocoPlotGetScalarOneOfMulti(tosys,i);
      
        l = _yocoPlotGetArrayOneOfMulti(l,i);
        if ( is_void(l) ) l = limits()(3:4);

        plg, l,
            _yocoPlotGetScalarOneOfMulti(x0,i)(-:1:2),
            type   = _yocoPlotGetScalarOneOfMulti(type,   i),
            marker = _yocoPlotGetScalarOneOfMulti(marker, i),
            marks  = _yocoPlotGetScalarOneOfMulti(marks,  i),
            width  = _yocoPlotGetScalarOneOfMulti(width,  i),
            color  = _yocoPlotGetScalarOneOfMulti(color,  i),
            legend = _yocoPlotGetScalarOneOfMulti(legend, i),
            msize  = _yocoPlotGetScalarOneOfMulti(msize,  i),
            hide   = _yocoPlotGetScalarOneOfMulti(hide,   i),
            closed = _yocoPlotGetScalarOneOfMulti(closed, i),
            mspace = _yocoPlotGetScalarOneOfMulti(mspace, i),
            mphase = _yocoPlotGetScalarOneOfMulti(mphase, i),
            rays   = _yocoPlotGetScalarOneOfMulti(rays,   i),
            arrowl = _yocoPlotGetScalarOneOfMulti(arrowl, i),
            arroww = _yocoPlotGetScalarOneOfMulti(arroww, i),
            rspace = _yocoPlotGetScalarOneOfMulti(rspace, i),
            rphase = _yocoPlotGetScalarOneOfMulti(rphase, i);
    }
}

/************************************************************************/

func yocoPlotHorizLine(y0, color=, type=, width=, hide=, l=, tosys=, marker=, marks=)
    /* DOCUMENT yocoPlotHorizLine(y0, color=, type=, width=, hide=, l=, tosys=, marker=, marks=)

       DESCRIPTION 
       Plot a horizontal line at the position Y0.
       The L keyword specifie the [xmin, xmax].
       By default, it is the limits of the window.
       X0 and L could be array of the same dimension.

       PARAMETERS
       - y0    : position in y of the horizontal line (can be array)
       - color : see help of 'plg'
       - type  : see help of 'plg'
       - width : see help of 'plg'
       - hide  : see help of 'plg'
       - l     : specify the vertical limits [xmin,xmax] default
       are the current limits of the system
       - tosys : see help of 'plg'
       - marker: see help of 'plg'
       - marks : see help of 'plg'

       SEE ALSO
       yocoPlotHorizLine, yocoPlotVertLine
    */
{
    local imax, i;
    
    /* get the number fo lines to be ploted */
    imax = max(numberof(y0), numberof(tosys), numberof(l));

    /* -- loop on the budle of curves -- */  
    for(i= 1; i <= imax; i++) {

        plsys, _yocoPlotGetScalarOneOfMulti(tosys,i);
      
        l = _yocoPlotGetArrayOneOfMulti(l,i);
        if ( is_void(l) ) l = limits()(1:2);

        plg,
            _yocoPlotGetScalarOneOfMulti(y0,i)(-:1:2),
            l,
            type   = _yocoPlotGetScalarOneOfMulti(type,   i),
            marker = _yocoPlotGetScalarOneOfMulti(marker, i),
            marks  = _yocoPlotGetScalarOneOfMulti(marks,  i),
            width  = _yocoPlotGetScalarOneOfMulti(width,  i),
            color  = _yocoPlotGetScalarOneOfMulti(color,  i),
            legend = _yocoPlotGetScalarOneOfMulti(legend, i),
            msize  = _yocoPlotGetScalarOneOfMulti(msize,  i),
            hide   = _yocoPlotGetScalarOneOfMulti(hide,   i),
            closed = _yocoPlotGetScalarOneOfMulti(closed, i),
            mspace = _yocoPlotGetScalarOneOfMulti(mspace, i),
            mphase = _yocoPlotGetScalarOneOfMulti(mphase, i),
            rays   = _yocoPlotGetScalarOneOfMulti(rays,   i),
            arrowl = _yocoPlotGetScalarOneOfMulti(arrowl, i),
            arroww = _yocoPlotGetScalarOneOfMulti(arroww, i),
            rspace = _yocoPlotGetScalarOneOfMulti(rspace, i),
            rphase = _yocoPlotGetScalarOneOfMulti(rphase, i);
    }
}

/************************************************************************/

func yocoPlotHistogramme(data, &xRange, &histo, nbBars=, color=, range=, plot=, onlyBars=, logHisto=, vert=, width=)
    /* DOCUMENT yocoPlotHistogramme(data, &xRange, &histo, nbBars=, color=, range=, plot=, onlyBars=, logHisto=, vert=, width=)
  
       DESCRIPTION 
       Compute and plots histogram of data with nice barplot style.

       PARAMETERS
       - data    : The data you want to plot the histogram
       - xRange  : OUTPUT the x range of the histogram
       - histo   : OUTPUT the values for the histogram
       - nbBars  : OPTIONAL number of bar you want to plot. defaults to 
       numberof(data)/50
       - color   : OPTIONAL color of the plot
       - range   : OPTIONAL lower and upper value of the range in which you
       want to plot the histogram
       - plot    : OPTIONAL if set to 0, the function does not plot the
       histogram, letting you just get the OUTPUT values
       - onlyBars: Plot only a bar plot and not the line btween histogram
       - logHisto: Log scale for the histogram
       - vert    : plot the histogram vertically instead of horizontally
       - width   : 
    
       SEE ALSO
       histogram, yocoPlotBars
    */
{
    if(is_void(nbBars))
        nbBars = numberof(data)/50;

    xRange = histo = [];

    if(is_void(range))
    {
        range = array(double, 2);
        range(1) = min(data);
        range(2) = max(data);
        if(range(1)==range(2))
        {
            range(1) = range(1)-1;
            range(2) = range(2)+1;
        } 
    }

    if(logHisto!=1)
    {
        xRange = span(range(1),range(2),nbBars+1);
    }
    else if(logHisto==1)
    {
        xRange = spanl(range(1),range(2),nbBars+1);
        if(plot!=0)
            logxy,1;
    }
    
    histoData = digitize(data, xRange);
    histo     = histogram(histoData);

    
    
    if(numberof(histo)==1)
        return 0;
    if(numberof(where(histoData==1))!=0)
        histo = histo(2:);
    if(numberof(where(histoData==nbBars+1))!=0)
        histo = histo(:-1);
    
    while(numberof(histo)<numberof(xRange))
        grow, histo, 0.0;
    
    histo = histo/((double(sum(histo))+(double(sum(histo))==0))*(xRange(dif)(avg)));

    if(plot!=0)
    {
        if(vert==1)
            yocoPlotBars, histo, xRange, color=color, vert=1, width=width;
        else
            yocoPlotBars, histo, xRange, color=color, width=width;
    }

}

/************************************************************************/

func yocoPlotBars(Y, X, color=, onlyBars=, vert=, width=, type=)
    /* DOCUMENT yocoPlotBars(Y, X, color=, onlyBars=, vert=, width=, type=)
  
       DESCRIPTION
       Plot data with 'histogram like' style.
    
       PARAMETERS
       - Y       : Y values of the bar plot function
       - X       : X values of the bar plot function, with 1 more
       element than Y
       - color   : optional color of the bars
       - onlyBars: if true, the bars only are plotted
       - vert    : plot vertically
       - width   : 

       SEE ALSO
       histogram
    */
{
    nbars = numberof(X)-1;
    sep = X(dif)(min);

    if(vert==1)
    {
        for(i=1;i<=nbars;i++)
        {
          plg, [X(i), X(i)], [0, Y(i)], marks=0, color=color, width=width, type=type;
            plg, [X(i), X(i+1)], [Y(i), Y(i)], marks=0, color=color, width=width, type=type;
            plg, [X(i+1), X(i+1)], [0, Y(i)], marks=0, color=color, width=width, type=type;
        }
        if(onlyBars==0)
            plg,X,Y, width=width, type=type;
    }
    else
    {
        for(i=1;i<=nbars;i++)
        {
            plg, [0, Y(i)], [X(i), X(i)], marks=0, color=color, width=width, type=type;
            plg, [Y(i), Y(i)], [X(i), X(i+1)], marks=0, color=color, width=width, type=type;
            plg, [0, Y(i)], [X(i+1), X(i+1)], marks=0, color=color, width=width, type=type;
        }
        if(onlyBars==0)
            plg,Y,X, width=width, type=type;
    }
}

/***************************************************************************/

func yocoPlotColorLookupTable(minCLUT, maxCLUT, orient=, sys=, unit=, sup=, inf=, levels=, levColor=, nLabs=, nTicks=, palette=, offset=)
    /* DOCUMENT yocoPlotColorLookupTable(minCLUT, maxCLUT, orient=, sys=, unit=, sup=, inf=, levels=, levColor=, nLabs=, nTicks=, palette=, offset=)

       DESCRIPTION
       Plot a color lookup table in a color bar at the side or behind the
       viewport.

       REQUIRE
       - style.i

       PARAMETERS
       - minCLUT : min value of the color lookup table
       - maxCLUT : max value of the color lookup table
       - orient  : bar orientation; 0=horizontal, 1=vertical (default)
       - sys     : gist-system for which the table has to be plotted
       - unit    : Put a unit to the labels
       - sup     : Put a sign for the top label
       - inf     : Put a sign for the bottom label
       - levels  : Number of levels if there are e.g. contour plots
       together with the image
       - levColor: Levels colors
       - nLabs   : number of labels on the color bar
       - nTicks  : Number of ticks on the color bar
       - palette : 
       - offset  : 
    
       EXAMPLES
       > window, 0, style="amdlib1horiz.gs", height=500, width=600, legends=0;
       > yocoPlotColorLookupTable, 0, 100,orient=1
       > winkill, 0
    */
{
    require, "style.i";

    if(is_void(unit))
        unit = "";

    if(is_void(sup))
        sup = "";

    if(is_void(inf))
        inf = "";
    
    if(is_void(offset))
        offset = 0.0;
    
    get_style, landscape, systems, legends, clegends;
    vportTmp = systems.viewport();
    if(is_void(sys))
    {
        vport = grow(vportTmp(1,min),
                     vportTmp(2,max),
                     vportTmp(3,min),
                     vportTmp(4,max))
            }
    else
        vport = vportTmp(,sys);

    if(is_void(nLabs))
        nLabs = 6;

    if(is_void(nTicks))
        nTicks = 2*(nLabs-1)+1;
    
    levs = span(minCLUT, maxCLUT,  250); 
    n = numberof(levs) + 1;

    if(is_void(palette))
        colors= span(1, n, n);
    else
        colors = char(palette);

    n = dimsof(colors)(0);
    

    dx = dy = 0.0;
    if (orient == 1)
    {
        x = (vport(2)-offset + [0.022,0.042])(-:1:n+1,);
        xLabs  = (vport(2)-offset + 0.042)(-:1:nLabs);
        xTicks = (vport(2)-offset + 0.042)(-:1:nTicks);
        x0 = x(1, 1);
        x1 = x(1, 0);
        dx = 0.005;
        y = span(min(vport(3, )), max(vport(4, )), n+1)(, -:1:2);
        yLabs = span(min(vport(3, )), max(vport(4, )), nLabs);
        yTicks = span(min(vport(3, )), max(vport(4, )), nTicks);
        y0 = y(1, 1);
        y1 = y(0, 1);
    }
    else
    {
        y = (vport(3)-offset-[0.045, 0.065])(-:1:n+1, );
        yLabs = (vport(3)-offset-0.065)(-:1:nLabs);
        yTicks = (vport(3)-offset-0.065)(-:1:nTicks);
        y0 = y(1, 1);
        y1 = y(1, 0);
        dy = -0.005;
        x = span(min(vport(1, )), max(vport(2, )), n+1)(, -:1:2);
        xLabs = span(min(vport(1, )), max(vport(2, )), nLabs);
        xTicks = span(min(vport(1, )), max(vport(2, )), nTicks);
        x0 = x(1, 1);
        x1 = x(0, 1);
    }

    sys = plsys(0);
    plf, [colors], y, x, edges=0;

    plg, [y0, y0, y1, y1], [x0, x1, x1, x0], closed=1, marks=0, width=1, type=1;
        
    if(!is_void(levels))
    {
        pldj, array(x0,numberof(levels)), y0+levels/(maxCLUT-minCLUT)*(y1-y0),
            array(x1,numberof(levels)), y0+levels/(maxCLUT-minCLUT)*(y1-y0),
            color=levColor;
    }
    
    plsys, sys;

    labs = swrite(format="%.3g", span(minCLUT, maxCLUT, nLabs));
    labs(0) = sup+labs(0);
    labs(1) = inf+labs(1);

    plsys, 0;
    pldj, xTicks, yTicks, xTicks + dx, yTicks + dy;
    
    plsys, sys;
    plt1, labs+unit, xLabs + 2 * dx, yLabs + 2 * dy, justify=(orient?"LH":"CT");
}

/***************************************************************************/

func yocoPlotWithErrBars(y, yErr, x, xErr, color=, errColor=, type=, sizebar=, sizebarX=, width=, marks=, marker=, msize=)
    /* DOCUMENT yocoPlotWithErrBars(y, yErr, x, xErr, color=, errColor=, type=, sizebar=, sizebarX=, width=, marks=, marker=, msize=)
   
       DESCRIPTION
       Plots a graph of y versus x with error bars. Y and X must be 1-D arrays of
       equal length; if X is omitted, it defaults to [1, 2, ..., numberof(Y)].
    
       PARAMETERS
       - y       : ordinate values.
       - yErr    : errors on ordinate values.
       - x       : abscissa values.
       - xErr    : errors on abscissa values.
       - color   : color of plot
       - errColor: optional error bar colors
       - type    : see 'plg'
       - sizebar : optional error bar thickness.
       - sizebarX: optional error bar thickness.
       - width   : see 'plg'
       - marks   : is kept here only for compatibility
       - marker  : see 'plg'
       - msize   : see 'plmk'

       Keywords type, color, widths, marks and marker are also accepte
       with the same meaning than in plg.
                  
       SEE ALSO
       plg
    */
{
    if (is_void(x)) 
    {
        Nx = (dimsof(y))(1+1);
        x = indgen(Nx);
    }
    xl = double(max(x)-min(x));
    if (is_void(sizebar))
    {
        if (numberof(x) > 3)
        {
            sizebar = abs(x(dif))(min) / 3.0;
        }
        else if (numberof(x) <= 3)
        {
            sizebar = 0.1* x(1);
        }
    }

    x_off = sizebar;
    
    if (is_void(sizebarX))
    {
        if (numberof(x) > 3)
            sizebarX = abs(y(dif))(min) / 3.0;
        else if (numberof(x) <= 3)
            sizebarX = 0.1* y(1);
    }
    y_off = sizebarX;

    if (is_void(color))
    {
        color = "red";
    }

    if (is_void(marker))
    {
        marker = 4;
    }

    if (is_void(msize))
    {
        msize = 0.5;
    }

    if (is_void(errColor))
    {
        errColor = color;
    }

    plg, y, x, marks=0, type=type, color=color, width=width;
    
    if(!is_void(yErr))
    {
        pldj, x, y-yErr , x, y+yErr, color=errColor, width=width;
        pldj, x-x_off, y-yErr, x+x_off, y-yErr, color=errColor, width=width ;
        pldj, x-x_off, y+yErr, x+x_off, y+yErr, color=errColor, width=width ;
    }

    if(!is_void(xErr))
    {
        pldj, x-xErr, y , x+xErr, y, color=errColor, width=width;
        pldj, x-xErr, y-y_off, x-xErr, y+y_off, color=errColor, width=width ;
        pldj, x+xErr, y-y_off, x+xErr, y+y_off, color=errColor, width=width ;
    }

    if(is_void(msize)||(msize==0))
        plg, y, x, marks=1, type="none", color=color, marker=marker;
    else
        plmk, y, x, marker=marker, msize=msize, color=color;
}

func _yocoPlotGetScalarOneOfMulti(param, i, isPtr)
    /* DOCUMENT _yocoPlotGetScalarOneOfMulti(param, i, isPtr)

       DESCRIPTION
       Private function for yocoPlgMulti, yocoPlpMulti.
       Return the value param(i%numberof(param))

       EXAMPLES
       See code of yocoPlotPlgMulti for examples
    */
{
    if (is_void(param)) return [];
    param =  param ( i%numberof(param) );
    if (isPtr && typeof(param)=="pointer") return *param;
    return param;
}

func _yocoPlotGetArrayOneOfMulti(param, i, isPtr)
    /* DOCUMENT _yocoPlotGetArrayOneOfMulti(param, i, isPtr)

       DESCRIPTION
       Private function for yocoPlgMulti, yocoPlpMulti.
       Return the value param(, i%numberof(param))

       EXAMPLES
       See code of yocoPlotPlgMulti for examples
    */
{
    if (is_void(param)) return [];
    if (isPtr && typeof(param=="pointer")) {
        return *param ( i%numberof(param) );
    }
    else {
        return param ( , i%numberof(param(1,)) );
    }
}

/************************************************************************/

func yocoPlotPlgMulti(y, x, every=, legend=, hide=, type=, width=, color=, closed=, smooth=, marks=, marker=, mspace=, mphase=, msize=, rays=, arrowl=, arroww=, rspace=, rphase=, dx=, dy=, dtype=, tosys=)
    /* DOCUMENT yocoPlotPlgMulti(y, x, every=, legend=, hide=, type=, width=, color=, closed=, smooth=, marks=, marker=, mspace=, mphase=, msize=, rays=, arrowl=, arroww=, rspace=, rphase=, dx=, dy=, dtype=, tosys=)

       DESCRIPTION
       Plot the bundle of curves Y versus X labeled by the last indice.  Y must
       be 2-dimensional, and X may be 2-dimensional, 1-dimensional or omitted.
       If X is 2-dimensional, it must have the same dimensions as Y and Y(,i)
       versus X(,i) is plotted for each last indice i.  If X is 1-dimensional, it
       must have the same length as the 1st dimension of Y and Y(,i) versus X is
       plotted for each last indice i.  If X is omitted, it defaults to [1, 2,
       ..., numberof(Y(,1))].

       PARAMETERS
       - y     : data them-self
       - x     : abscissa of the data
       - every : optional keyword which can be used to plot every N curves in
       the bundle instead of all (default N=1).
       - legend: see 'plg'
       - hide  : see help of 'plg'
       - type  : see help of 'plg'
       - width : see help of 'plg'
       - color : see 'plg'
       - closed: see 'plg'
       - smooth: see 'plg'
       - marks : see 'plg'
       - marker: see 'plg'
       - mspace: see 'plg'
       - mphase: see 'plg'
       - msize : see 'plg'
       - rays  : see 'plg'
       - arrowl: see 'plg'
       - arroww: see 'plg'
       - rspace: see 'plg'
       - rphase: see 'plg'
       - dx    : optional X error bars
       - dy    : optional Y error bars
       - dtype : type of the error bars line
       - tosys : gist-system in which each curve has to be plotted. It may be
       omitted, integer scalar, or an integer array of the
       same length as the last dimension of y.

       All the plotting keywords of plg are accepted. They may be omitted,
       scalars, or arrays of the same lenght as the last dimension of y.

       EXAMPLES
       > x0 = span(0.001,1,10);
       > y  = x^indgen(0:4)(-,);
       > x  = x^span(0.9,1.1,5)(-,);
       > yocoPlotPlgMulti, y, x, type=indgen(5), color=-4-indgen(5);
     
       > yocoNmCreate,0,5;
       > yocoPlotPlgMulti, y, x, tosys=indgen(5);
    */
{
    local i, n, isPtr, px, py, pdy, pdx, psys;

    /* if complex, put it as Re/Im array */
    if (typeof(y) == "complex") y=[y.re,y.im];

    /* if pointer, count the number of elements */
    if (typeof(y) == "pointer" ) {
        isPtr = 1;
        y = y(*);
        imax = numberof(y);
    }
    /* concatene all other dimensions */
    else {
        isPtr = 0;
        y = y(,*);
        imax= numberof(y(1,));
    }

    /* deal with the legend */
    if (numberof(legend)==1) {
        legend=array(legend(1),imax);
        if(imax>1) legend(2:0) = "";
    }

    /* deal with the every keyword */
    if (is_void(every)) {
        n= 1;
    } else if (numberof(every)!=1 || (n= long(every(1))) <= 0) {
        error, "EVERY must be a scalar >= 1";
    }

    /* -- loop on the budle of curves -- */  
    for(i= (n+1)/2; i <= imax; i+= n) {

        /* go to the selected system */
        plsys, _yocoPlotGetScalarOneOfMulti(tosys,i);

        /* get the x and y */
        py = _yocoPlotGetArrayOneOfMulti(y, i, isPtr);
        px = _yocoPlotGetArrayOneOfMulti(x, i, isPtr);

        /* plot the curve */
        plg, py, px,
            type   = _yocoPlotGetScalarOneOfMulti(type,   i),
            marker = _yocoPlotGetScalarOneOfMulti(marker, i),
            marks  = _yocoPlotGetScalarOneOfMulti(marks,  i),
            width  = _yocoPlotGetScalarOneOfMulti(width,  i),
            color  = _yocoPlotGetScalarOneOfMulti(color,  i),
            legend = _yocoPlotGetScalarOneOfMulti(legend, i),
            msize  = _yocoPlotGetScalarOneOfMulti(msize,  i),
            hide   = _yocoPlotGetScalarOneOfMulti(hide,   i),
            closed = _yocoPlotGetScalarOneOfMulti(closed, i),
            smooth = _yocoPlotGetScalarOneOfMulti(smooth, i),
            mspace = _yocoPlotGetScalarOneOfMulti(mspace, i),
            mphase = _yocoPlotGetScalarOneOfMulti(mphase, i),
            rays   = _yocoPlotGetScalarOneOfMulti(rays,   i),
            arrowl = _yocoPlotGetScalarOneOfMulti(arrowl, i),
            arroww = _yocoPlotGetScalarOneOfMulti(arroww, i),
            rspace = _yocoPlotGetScalarOneOfMulti(rspace, i),
            rphase = _yocoPlotGetScalarOneOfMulti(rphase, i);

        /* eventually add the dy error bar  */
        pdy = _yocoPlotGetArrayOneOfMulti(dy, i, isPtr);
        if(!is_void(pdy)) 
            pldj, px, py-pdy, px, py+pdy,
                width  = _yocoPlotGetScalarOneOfMulti(width, i),
                color  = _yocoPlotGetScalarOneOfMulti(color, i),
                dtype  = _yocoPlotGetScalarOneOfMulti(dtype, i);

        /* eventually add the dx error bar  */
        pdx = _yocoPlotGetArrayOneOfMulti(dx, i, isPtr);
        if(!is_void(pdx)) 
            pldj, px-pdx, py, px+pdx, py,
                width  = _yocoPlotGetScalarOneOfMulti(width, i),
                color  = _yocoPlotGetScalarOneOfMulti(color, i),
                dtype  = _yocoPlotGetScalarOneOfMulti(dtype, i); 
    }
    /* -- end loop on the curves -- */

}

/************************************************************************/

func yocoPlotPltMulti(text, x, y, legend=, hide=, color=, font=, height=, opaque=, orient=, justify=, tosys=, every=)
    /* DOCUMENT yocoPlotPltMulti(text, x, y, legend=, hide=, color=, font=, height=, opaque=, orient=, justify=, tosys=, every=)
                                         
       DESCRIPTION
       As the 'plt' function, but accept input arrays to plot several texts at
       the same time.

       PARAMETERS
       - text   : same as plt
       - x      : same as plt
       - y      : same as plt
       - legend : see 'plt'
       - hide   : see 'plt'
       - color  : see 'plt'
       - font   : see 'plt'
       - height : see 'plt'
       - opaque : see 'plt'
       - orient : see 'plt'
       - justify: see 'plt'
       - tosys  : gist-system in which each curve has to be plotted. It may be
       omitted, integer scalar, or an integer array of the
       same length as the last dimension of y.
       - every  : optional keyword which can be used to plot every N string in
       the bundle instead of all (default N=1).

       All the plotting keywords of plt are accepted. They may be omitted,
       scalars, or arrays of the same lenght as the last dimension of text.

       EXAMPLES
       > yocoPlotPltMulti,["a","b","c"],random(3),random(3),
       tosys=1,color=["red","blue","green"];

                        
       > yocoNmCreate, 0, 3;
       > yocoPlotPltMulti,["a","b","c"],random(3),random(3),
       tosys=[1,2,3],color=["red","blue","green"];
    */
{

    local imax, i, pt;
    /* deal with the non-optional keywords */
    imax= max( numberof(y), numberof(text), numberof(x));

    /* deal with the every keyword */
    if (is_void(every)) {
        n= 1;
    } else if (numberof(every)!=1 || (n= long(every(1))) <= 0) {
        error, "EVERY must be a scalar >= 1";
    }

    /* -- loop on the budle of text -- */  
    for(i= (n+1)/2; i <= imax; i+= n) {

        /* go to the selected system */
        plsys, _yocoPlotGetScalarOneOfMulti(tosys,i);

        /* extract the text */
        pt = _yocoPlotGetScalarOneOfMulti(text, i);
        if (typeof(pt)!="string") pt = pr1(pt);

        /* plot the text */
        plt, pt,
            _yocoPlotGetScalarOneOfMulti(x, i),
            _yocoPlotGetScalarOneOfMulti(y, i),
            hide    = _yocoPlotGetScalarOneOfMulti(hide,    i),
            opaque  = _yocoPlotGetScalarOneOfMulti(opaque,  i),
            orient  = _yocoPlotGetScalarOneOfMulti(orient,  i),
            justify = _yocoPlotGetScalarOneOfMulti(justify, i),
            height  = _yocoPlotGetScalarOneOfMulti(height,  i),
            legend  = _yocoPlotGetScalarOneOfMulti(legend,  i),
            color   = _yocoPlotGetScalarOneOfMulti(color,   i),
            font    = _yocoPlotGetScalarOneOfMulti(font,    i),
            tosys   = _yocoPlotGetScalarOneOfMulti(tosys,   i);
    }
    /* -- end loop -- */
}

/************************************************************************/

func yocoPlotPlp(y, x, dx=, xlo=, xhi=, dy=, ylo=, yhi=, size=, symbol=, ticks=, legend=, type=, width=, color=, fill=, vect=, vscale=, hide=)
    /* DOCUMENT yocoPlotPlp(y, x, dx=, xlo=, xhi=, dy=, ylo=, yhi=, size=, symbol=, ticks=, legend=, type=, width=, color=, fill=, vect=, vscale=, hide=)

       DESCRIPTION:
       Plots points (X,Y) with symbols and/or  error bars.  X, and Y may have
       any dimensionality, but  must have the same number  of elements.  If X
       is nil, it defaults to indgen(numberof(Y)).

       PARAMETERS:
       - y     : position of the symbols.
       - x     : position of the symbols.
       - dx    : Keywords XLO, XHI, YLO, and/or YHI  can be used to indicate
       the bounds of the optional  error bars (default is to draw  no
       error bars).  Only specified bounds get plotted as  error bars.
       If value of keyword TICKS is true  (non-nil and non-zero), ticks
       get drawn at  the endpoints of the error bars.   Alternatively,
       keywords DX and/or DY  can be used to plot error bars  as segments
       from XLO=X-DX  to XHI=X+DX  and/or from YLO=Y-DY
       to  YHI=Y+DY.  If keyword  DX (respectively DY) is  used, any
       value of XLO and XHI (respectively YLO and YHI) is ignored.
       - xlo   : same as dx parameter
       - xhi   : same as dx parameter
       - dy    : same as dx parameter
       - ylo   : same as dx parameter
       - yhi   : same as dx parameter
       - size  : change the size of the symbols and tick
       (acts as a multiplier, default value is 1.0).
       - symbol: choose the shape of each symbol:
       0    nothing (just draw error bars if any)
       1    square
       2    cross (+ sign)
       3    triangle
       4    circle (hexagon)
       5    diamond
       - ticks : see 'pldj'
       - legend: see 'pldj'
       - type  : see 'pldj'
       - width : see 'pldj'
       - color : see 'pldj'
       - fill  : if true (non-nil  and non-zero), symbols are
       filled with COLOR (default is to draw open symbols).
       - vect  : vscale : allows to conver the errors bars into vectors. It can be
       usefull to  plot  upper/lower  limits  instead of  value+error.
       VECT=1 will convert the X error bars, VECT=2 the Y errors bars
       and VECT=3 both X and Y. The VSCALE  keyword define the size
       of the vector arrow.
       - vscale: see 'pldj'
       - hide  : see 'pldj'

       EXAMPLES
       > x=random(10); y=random(10); dy=random(10)/5.; dx=random(10)/10.;
       > yocoPlotPlp, x, y, symbol=5, color="blue", dy=dy, fill=1;
       > yocoPlotPlp, y, x, symbol=6, color="red",  dy=dy;
       > yocoPlotPlp, y, x, ylo=y-dy, yhi=, vect=2, fill=1, symbol=4;
       > yocoPlotPlp, y, x, dx=0.1*x, vect=1, vscale=0.5;
    */
{
    /* NDC units for symbols/ticks (one pixel = 0.00125268 NDC at 75 DPI) */
    u0 = 0.0;        // zero
    u1 = 0.00500214; // radius of about 5 pixels at 75 DPI

    /* multiply by the specified size */
    if (!is_void(size)) u1 *= size;
    if (!is_void(vscale)) vscale*=0.01;
    else vscale = 0.01;
    vteta  = pi/2.5;

    /* parse color, required for filling the polygon */
    if (is_void(color)) color = char(-2); /* fg */
    if (structof(color) == string) {
        n = where(color == __pl_color_list);
        if (numberof(n)!=1) error, "unrecognized color name: "+color;
        color = char(-n(1));
    } else if (structof(color) != char) {
        color = char(color);
    }

    /* default X */ 
    if (is_void(x)) (x = array(double, dimsof(y)))(*) = indgen(numberof(y));

    /* error bars */
    if (is_void(dx)) {
        err = (! is_void(xlo)) + 2*(! is_void(xhi));
    } else {
        xlo = x - dx;
        xhi = x + dx;
        err = 3;
    }
    if (err) {
        if(vect==1 || vect==3) {
            if(!is_void(xlo))
                __yocoPlotPlvec, y, xlo, 4, vscale, vteta;
            if(!is_void(xhi))
                __yocoPlotPlvec, y, xhi, 3, vscale, vteta;
        }  
        pldj, (is_void(xlo) ? x : xlo), y, (is_void(xhi) ? x : xhi), y,
            type=type, width=width, color=color, hide=hide;
        if (ticks) {
            xm = [ u0, u0];
            ym = [-u1, u1];
            if      (err == 1) __yocoPlotPlp,   y,       xlo;
            else if (err == 2) __yocoPlotPlp,   y,       xhi;
            else               __yocoPlotPlp, [y, y], [xlo, xhi];
        }
        xhi = xlo = [];
    }
    if (is_void(dy)) {
        err = (! is_void(ylo)) + 2*(! is_void(yhi));
    } else {
        ylo = y - dy;
        yhi = y + dy;
        err = 3;
    }
    if (err) {
        pldj, x, (is_void(ylo) ? y : ylo), x, (is_void(yhi) ? y : yhi),
            type=type, width=width, color=color, hide=hide;
        if(vect==2 || vect==3) {
            if(!is_void(ylo))
                __yocoPlotPlvec, ylo, x, 2, vscale, vteta;
            if(!is_void(yhi))
                __yocoPlotPlvec, yhi, x, 1, vscale, vteta;
        }  
        if (ticks) {
            xm = [-u1, u1];
            ym = [ u0, u0];
            if      (err == 1) __yocoPlotPlp,    ylo,       x;
            else if (err == 2) __yocoPlotPlp,    yhi,       x;
            else               __yocoPlotPlp, [ylo, yhi], [x, x];
        }
        yhi = ylo = [];
    }

    /* symbols */
    if (! symbol) {
        if (is_void(symbol)) symbol = 6;
        else return;
    }
    if (symbol == 1) {
        /* square */
        u2 = u1*sqrt(0.5);
        xm = [-u2, u2, u2,-u2];
        ym = [ u2, u2,-u2,-u2];
    } else if (symbol == 2) {
        /* + cross */
        xm = [-u1, u1, u0, u0, u0, u0];
        ym = [ u0, u0, u0, u1,-u1, u0];
        fill = 0;
    } else if (symbol == 3) {
        /* triangle */
        u2 = u1*0.5;
        u3 = u1*sqrt(0.75);
        xm = [u0, u3,-u3];
        ym = [u1,-u2,-u2];
    } else if (symbol == 4) {
        /* hexagon */
        u2 = u1*0.5;
        u3 = u1*sqrt(0.75);
        xm = [ u1, u2,-u2,-u1,-u2, u2];
        ym = [ u0, u3, u3, u0,-u3,-u3];
    } else if (symbol == 5) {
        /* diamond */
        xm = [u1, u0,-u1, u0];
        ym = [u0, u1, u0,-u1];
    } else if (symbol == 6) {
        /* x cross (rotated 45 degrees) */
        u2 = u1*sqrt(0.5);
        xm = [u2,-u2, u0, u2,-u2, u0];
        ym = [u2,-u2, u0,-u2, u2, u0];
        fill = 0;
    } else if (symbol == 7) {
        /* triangle (upside down) */
        u2 = u1*0.5;
        u3 = u1*sqrt(0.75);
        xm = [ u0, u3,-u3];
        ym = [-u1, u2, u2];
    } else if (symbol == 8) {
        /* 5 branch star */
        /* Notations: C18 = cos(18*ONE_DEGREE)
         *            S18 = sin(18*ONE_DEGREE)
         *            C54 = cos(54*ONE_DEGREE)
         *            S54 = sin(54*ONE_DEGREE)
         */
        u2 = 0.224514*u1; // C54*S18/S54
        u3 = 0.309017*u1; // S18
        u4 = 0.951057*u1; // C18
        u5 = 0.363271*u1; // C18*S18/S54
        u6 = 0.118034*u1; // S18*S18/S54
        u7 = 0.587785*u1; // C54
        u8 = 0.809017*u1; // S54
        u9 = 0.381966*u1; // S18/S54
        xm = [ u0, u2, u4, u5, u7, u0,-u7,-u5,-u4,-u2];
        ym = [ u1, u3, u3,-u6,-u8,-u9,-u8,-u6, u3, u3];
    } else if (symbol > 0) {
        /* N-side polygon in unit circle */
        PI = 3.141592653589793238462643383279503;
        a = (2.0*PI/symbol)*indgen(0:symbol-1);
        xm = u1*cos(a);
        ym = u1*sin(a);
    } else {
        error, "bad SYMBOL value";
    }
    __yocoPlotPlp, y, x;
}

func __yocoPlotPlvec(y, x, orient, scale, teta)
    /* DOCUMENT __yocoPlotPlvec(y, x, orient, scale, teta)
       Private routine used by plp. */
{
    extern color, fill, legend, width, hide;
    local z, xm, ym;

    if(orient==1) { // y>0
        xm = [cos(teta),0,-cos(teta)];
        ym = [-sin(teta),0,-sin(teta)];
    }
    else if(orient==2) { // y<0
        xm = [-cos(teta),0,cos(teta)];
        ym = [sin(teta),0,sin(teta)];
    }
    else if(orient==3) { // x>0
        xm = [-sin(teta),0,-sin(teta)];
        ym = [cos(teta),0,-cos(teta)];
    }
    else if(orient==4) { // x<0
        xm = [sin(teta),0,sin(teta)];
        ym = [cos(teta),0,-cos(teta)];
    }
    else error;

    xm *= scale;
    ym *= scale;

    n = array(1, 1 + numberof(y));
    n(1) = numberof(ym);
    if (fill && n(1) > 2) {
        if (numberof(color) == 3) {
            z = array(char, 3, numberof(n));
            z(,) = color;
        } else {
            z = array(color, numberof(n));
        }
    }
    plfp, z, grow(ym,y(*)), grow(xm,x(*)), n,
        legend=legend, edges=1, ewidth=width,
        ecolor=color, hide=hide;
}

func __yocoPlotPlp(y, x)
    /* DOCUMENT __yocoPlotPlp(y, x)
       Private routine used by yocoPlotPlp. */
{
    extern xm, ym, color, fill, legend, width, hide;
    local z;
    n = array(1, 1 + numberof(y));
    n(1) = numberof(ym);
    if (fill && n(1) > 2) {
        if (numberof(color) == 3) {
            z = array(char, 3, numberof(n));
            z(,) = color;
        } else {
            z = array(color, numberof(n));
        }
    }
    plfp, z, grow(ym,y(*)), grow(xm,x(*)), n,
        legend=legend, edges=1, ewidth=width, ecolor=color, hide=hide;
}

local __pl_color_list;
__pl_color_list = ["bg","fg","black","white","red","green","blue",
                   "cyan","magenta","yellow"];
/* DOCUMENT __pl_color_list - private list of color names */


/************************************************************************/

func yocoPlotPlpMulti(y, x, dx=, xlo=, xhi=, dy=, ylo=, yhi=, size=, symbol=, ticks=, legend=, type=, width=, color=, fill=, vect=, vscale=, hide=, every=, tosys=)
    /* DOCUMENT yocoPlotPlpMulti(y, x, dx=, xlo=, xhi=, dy=, ylo=, yhi=, size=, symbol=, ticks=, legend=, type=, width=, color=, fill=, vect=, vscale=, hide=, every=, tosys=)
       symbol=, ticks=, legend=, type=, width=, color=,
       fill=, vect=, vscale=, hide=, every=, tosys=)

       DESCRIPTION
       Plot a bundle of data Y versus X labeled by the last indice.  Y must
       be 2-dimensional, and X may be 2-dimensional, 1-dimensional or omitted.
       If X is 2-dimensional, it must have the same dimensions as Y and Y(,i)
       versus X(,i) is plotted for each last indice i.  If X is 1-dimensional, it
       must have the same length as the 1st dimension of Y and Y(,i) versus X is
       plotted for each last indice i.  If X is omitted, it defaults to [1, 2,
       ..., numberof(Y(,1))].

       PARAMETERS
       - y     : position of the symbols.
       - x     : position of the symbols.
       - dx    : bounds of the optional error bars (default is to draw  no
       error bars). See yocoPlotPlp for detailed explanation.             
       - xlo   : same explanation as for dx
       - xhi   : same explanation as for dx
       - dy    : same explanation as for dx
       - ylo   : same explanation as for dx
       - yhi   : same explanation as for dx
       - size  : see 'yocoPlotPlp'
       - symbol: symbol type (square, star, circle...). See yocoPlotPlp.
       - ticks : see 'yocoPlotPlp'
       - legend: see 'yocoPlotPlp'
       - type  : see 'yocoPlotPlp'
       - width : see 'yocoPlotPlp'
       - color : see 'yocoPlotPlp'
       - fill  : see 'yocoPlotPlp'
       - vect  : see 'yocoPlotPlp'
       - vscale: see 'yocoPlotPlp'
       - hide  : see 'yocoPlotPlp'
       - every : optional keyword which can be used to plot every N string in
       the bundle instead of all (default N=1).
       - tosys : gist-system in which each curve has to be plotted. It may be
       omitted, integer scalar, or an integer array of the
       same length as the last dimension of y.

       EXAMPLES
       > nx = 10; n = 5;
       > x = random(nx,n);
       > y = random(nx,n);
       > dy = random(nx,n) / 5.0;
       > dx = random(nx)   / 10.0;
       > yocoPlotPlpMulti, y, x, dx=dx, dy=dy, color=["red","blue"], 
       symbol = indgen(n), fill=1;
    */
{
    local i, n, imax, isPtr, px, py, pdy, pdx, psys;

    /* if complex, put it as Re/Im array */
    if (typeof(y) == "complex") y=[y.re,y.im];

    /* if pointer, count the number of elements */
    if (typeof(y) == "pointer" ) {
        isPtr = 1;
        y = y(*);
        imax = numberof(y);
    }
    /* concatene all other dimensions */
    else {
        isPtr = 0;
        y = y(,*);
        imax= numberof(y(1,));
    }

    /* deal with the legend */
    if (numberof(legend)==1) {
        legend=array(legend(1),imax);
        if(imax>1) legend(2:0) = "";
    }

    /* deal with the every keyword */
    if (is_void(every)) {
        n= 1;
    } else if (numberof(every)!=1 || (n= long(every(1))) <= 0) {
        error, "EVERY must be a scalar >= 1";
    }

    /* -- loop on the budle of curves -- */  
    for(i= (n+1)/2; i <= imax; i+= n) {

        /* go to the selected system */
        plsys, _yocoPlotGetScalarOneOfMulti(tosys,i);

        /* plot the curve */
        yocoPlotPlp,
            _yocoPlotGetArrayOneOfMulti(y, i, isPtr),
            _yocoPlotGetArrayOneOfMulti(x, i, isPtr),
            dx     = _yocoPlotGetArrayOneOfMulti(dx,  i, isPtr),
            xlo    = _yocoPlotGetArrayOneOfMulti(xlo, i, isPtr),
            xhi    = _yocoPlotGetArrayOneOfMulti(xhi, i, isPtr),
            dy     = _yocoPlotGetArrayOneOfMulti(dy,  i, isPtr),
            ylo    = _yocoPlotGetArrayOneOfMulti(ylo, i, isPtr),
            yhi    = _yocoPlotGetArrayOneOfMulti(yhi, i, isPtr),
            size   = _yocoPlotGetScalarOneOfMulti(size,   i),
            symbol = _yocoPlotGetScalarOneOfMulti(symbol, i),
            ticks  = _yocoPlotGetScalarOneOfMulti(ticks, i),
            legend = _yocoPlotGetScalarOneOfMulti(legend, i),
            type   = _yocoPlotGetScalarOneOfMulti(type,   i),
            width  = _yocoPlotGetScalarOneOfMulti(width,  i),
            color  = _yocoPlotGetScalarOneOfMulti(color,  i),
            fill   = _yocoPlotGetScalarOneOfMulti(fill,   i),
            vect   = _yocoPlotGetScalarOneOfMulti(vect,   i),
            vscale = _yocoPlotGetScalarOneOfMulti(vscale, i),
            hide   = _yocoPlotGetScalarOneOfMulti(hide,   i);

    } /* -- end of loop -- */

}

func yocoPlotContours(z, x0, y0, x1, y1,
                      legend=, hide=, levs=, nlevs=, type=, width=, color=,
                      marks=, marker=, mspace=, mphase=, smooth=)
/* DOCUMENT yocoPlotContours, z, x, y
            yocoPlotContours, z, x0, y0, x1, y1

   The first call is better used after a yocoPlotSurface while
   the second one is better used after a pli (pli is much faster
   for regular sampling).

   DESCRIPTION
*/
{
  if ( is_void(levs) )
  {
    if (is_void(nlevs)) error, "should specify levs or nlevs";
    zmax= double(max(z));
    zmin= double(min(z));
    levs= zmin + (zmax-zmin) / double(nlevs+1) * indgen(nlevs);
  }

  /* Check dimension of z */
  d = dimsof(z);
  if ( !is_array(d) || d(1)!=2 || d(2)<2 || d(3)<2 )
      error,"z should be a 2D array of at least 2x2";

  /* Compute mesh coordinates */
  if (numberof(x0)==d(2) & numberof(y0)==d(3) &
      numberof(x1)==0 & numberof(y1)==0 )
  {
    xx = x0(,-:1:d(3));
    yy = y0(-:1:d(2),);
  }
  else if (numberof(x0)==1 & numberof(y0)==1 &
           numberof(x1)==1 & numberof(y1)==1 )
  {
    xx = span(x0,x1,d(2))(,-:1:d(3));
    yy = span(y0,y1,d(3))(-:1:d(2),);
  }
  else
  {
    error,"x, y and z should be conformable";
  }

  /* Plot the contours */
  plc, z, yy, xx, levs=levs, legend=legend, hide=hide, type=type, width=width,
    color=color, marks=marks, marker=marker, mspace=mspace, mphase=mphase,
    smooth=smooth;
}
