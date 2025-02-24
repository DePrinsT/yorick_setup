/******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Generic useful math functions
 *
 * "@(#) $Id: yocoMath.i,v 1.25 2011-04-12 18:15:25 fmillour Exp $"
 *
 ******************************************************************************/

func yocoMath(void)
/* DOCUMENT yocoMath

   DESCRIPTION
     Mathematic functions

   VERSION
     $Revision: 1.25 $

   REQUIRE
     - matrix.i (for yocoMathPolyFit)
     - bessel.i (for yocoMathAiry)

   FUNCTIONS
   - yocoMath               : 
   - yocoMathAiry           : Airy function
   - yocoMathBin2Dec        : binary to long decimal number translation
   - yocoMathBin2Double     : binary to double number translation
   - yocoMathCnk            : Number of combinations of n into k
   - yocoMathDec2Bin        : Long decimal to binary translation
   - yocoMathDouble2Bin     : Double precision to binary translation
   - yocoMathFactorial      : Factorial of integers
   - yocoMathGA_cross       : Genetic algorithm reproduction
   - yocoMathGA_fit         : Genetic algorithm function fitting
   - yocoMathGA_mute        : Mutation for the genetic algorithm
   - yocoMathGA_test        : Test-bench for the genetic algorithm
   - yocoMathGauss          : Gaussian function
   - yocoMathHeavyside      : Heavyside function
   - yocoMathLog2           : Base 2 logarithm
   - yocoMathLorentz        : Lorentzian function
   - yocoMathMnk            : All combinations of n into k
   - yocoMathMovingAvg      : Sliding average on an array
   - yocoMathPoly           : Compute polynomial points given its coeficients
   - yocoMathPolyFit        : Fit a data set by a polynomial law
   - yocoMathPow2           : Base 2 square
   - yocoMathResample       : Resampling a 1-D array with sinc
   - yocoMathSignedSqrt     : Square root with a sign
   - yocoMathSinc           : Sinus cardinal function
   - yocoMathUnwrap         : 
   - yocoMathVoigt          : 
   - yocoMathWienerFiltering: Wiener filter of an array
   - yocoMathCholesky

   SEE ALSO
     yoco
*/
{
    version = strpart(strtok("$Revision: 1.25 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoMath;
    }   
    return version;
} 

/************************************************************************/

func yocoMathMovingAvg(f, n, &sigma)
/* DOCUMENT yocoMathMovingAvg(f, n, &sigma)
   
   DESCRIPTION
     Compute the moving average over n sample of the input 1-d array f.

   PARAMETERS
   - f    : input 1-d array to be averaged
   - n    : number of sample to be averaged
   - sigma: OPTIONAL, input/output 1-d array;
               input: statistical dispersion of the data,
               output: statistical dispersion of the moving average, assuming
               no correlation between the data.
               containing the moving averaged.
*/
{
    local t,i,sigmares;

    /* default for sigma */
    if( is_void(sigma) )
    {
        sigma = array(1.0, dimsof(f));
    }

    /* initialize the output array */
    t = indgen(1:numberof(f):n)(:-1);
    res = f(t) * 0.0;
    sigmares = sigma(t) * 0.0;

    /* compute the moving sum */
    for (i=0;i<n;i++)
    {    
        res      += f(t+i) * sigma(t+1)^-2.0;
        sigmares += sigma(t+1)^-2.0;
    }
  
    /* normalize the results */
    res      = res / sigmares;
    sigmares = 1./ sqrt(sigmares);

    sigma = sigmares;
    return res;
}

/************************************************************************/

func yocoMathUnwrap(vector, center=, maxgrad=)
/* DOCUMENT yocoMathUnwrap(vector, center=, maxgrad=)

   DESCRIPTION
   Unwrap an array of angles in rad, based on the step-by-step
   difference (gradient). When the gradient is larger than
   pi, the quantity 2pi is removed.

   Operation is performed on the first dimension of vector.

   PARAMETERS
   - vector : input array
   - center : the average value of the returned array is 0, otherwise
     the first value of the array is kept unchanged.
   - maxgrad: maximum allowed gradient, default is pi.
*/
{
  /* Maximum allowed gradient in rad */
  if(is_void(maxgrad)) maxgrad=pi;
  gradient = vector(dif,..);
  
  lst = where(gradient > maxgrad);
  if(is_array(lst)) gradient(lst) -= 2*pi;
  
  lst = where(gradient < -maxgrad);
  if(is_array(lst)) gradient(lst) += 2*pi;
  
  if (!is_void(center)) gradient = gradient - gradient(avg,..)(-,..);

  /* Rebuild the array from gradient */
  unwrapped = gradient(cum,..) + vector(1,..)(-,..);
  return unwrapped;
}

/************************************************************************/

func yocoMathSinc(x)
/* DOCUMENT yocoMathSinc(x)

   DESCRIPTION
     Return sin(x)/x and return 1 where x=0. x can be of any dimension
     and numerical type.
   
   SEE ALSO
     sin
*/
{
  return ( sin(x) / (x + (x==0)) ) + (x==0);
}

/************************************************************************/

func yocoMathHeavyside(x, params)
/* DOCUMENT yocoMathHeavyside(x, params)
  
   DESCRIPTION
     Returns the "Double heavyside" function

   PARAMETERS
   - x     : is the abscissa
   - params: is an array of parameters for this function :
                o width = params(1)
                o offset = params(2)

   CAUTIONS
     The parameters are given in an array so that fitting procedures
     (LMfit or curvefit) can use the function directly without modifications

   EXAMPLES 
     > x = span(0,10,100);
     > width=1;
     > offset=5;
     > params=[width,offset];
     > plg,yocoMathHeavyside(x,params),x;

   SEE ALSO
     porte, gauss, lorentz, voigt, raie, sinc
*/
{
    width = params(1);
    offset = params(2);
    P = (x>offset-width) & (x<offset+width);
    return P;
}

/************************************************************************/

func yocoMathGauss(x, params)
/* DOCUMENT yocoMathGauss(x, params)
  
   DESCRIPTION
     Returns a gaussian function, normalized so that the integral is equal to 1

   PARAMETERS
   - x     : is the abscissa
   - params: is an array of parameters for this function :
                  o sigma = params(1)
                  o offset = params(2)

   CAUTIONS
     The parameters are given in an array so that fitting procedures
     (LMfit or curvefit) can use the function directly without modifications

   EXAMPLES 
     > x = span(0,10,100);
     > sigma=1;
     > offset=5;
     > params=[sigma,offset];
     > plg,yocoMathGauss(x,params),x;

   SEE ALSO
     porte, gauss, lorentz, voigt, raie, sinc
*/
{
    sigma  = double(params(1));
    offset = double(params(2));
    
     if(abs(sigma)>1.0e100)
         sigma = 1e100;
     if(abs(sigma)<1.0e-100)
         sigma = 1e-100;
     if(abs(offset)>1.0e100)
         offset = sign(offset)*1e100;
    
    G = exp(-(x-offset)^2/(2*sigma^2)) / (sigma * sqrt(2*pi));

    return G;
}

/***************************************************************************/

func yocoMathLorentz(x, params)
/* DOCUMENT yocoMathLorentz(x, params)
  
   DESCRIPTION 
    Returns a lorentzian function, normalized so that the integral is equal to
     1 

   PARAMETERS
   - x     : is the abscissa
   - params: is an array of parameters for this function :
                  o params(1) = gamma
                  o params(2) = offset

   CAUTIONS
     The parameters are given in an array so that fitting procedures
     (LMfit or curvefit) can use the function directly without modifications

   EXAMPLES 
     > x = span(0,10,100);
     > gamma=1;
     > offset=5;
     > params=[gamma,offset];
     > plg,yocoMathLorentz(x,params),x;

   SEE ALSO
     porte, gauss, lorentz, voigt, raie, sinc
*/
{
    gamma = params(1);
    off = params(2);
    L = gamma/(pi * ((x-off)^2+gamma^2));
    return L;
}

/***************************************************************************/

func yocoMathVoigt(x, params)
/* DOCUMENT yocoMathVoigt(x, params)
  
   DESCRIPTION 
     Returns a Voigt profile, normalized so that the integral is equal to
     1 

   PARAMETERS
   - x     : is the abscissa
   - params: is an array of parameters for this function :
                  o sigma = params(1)
                  o params(2) = gamma
                  o params(3) = offset

   CAUTIONS
     The parameters are given in an array so that fitting procedures
     (LMfit or curvefit) can use the function directly without modifications

   EXAMPLES 
     > x = span(0,10,100);
     > gamma=1;
     > offset=5;
     > params=[gamma,offset];
     > plg,yocoMathLorentz(x,params),x;

   SEE ALSO
     porte, gauss, lorentz, voigt, raie, sinc
*/
{
    N = numberof(x);
    gaussz    = yocoMathGauss(x, [params(1), params(3)]);
    lorentz  = roll(yocoMathLorentz(x, [params(2), (max(x)+min(x))/2]));
    fgauss   = 1.0/sqrt(N)*fft(gaussz, 1);
    florentz = fft(lorentz, 1);
    florentz = florentz/florentz(1).re
    voigt = 2.0/sqrt(N) * abs(fft(fgauss * florentz, -1));

    return voigt;
}


/************************************************************************/

func yocoMathSignedSqrt(x)
/* DOCUMENT yocoMathSignedSqrt(x)

   DESCRIPTION
     return +sqrt(x) if x > 0 and -sqrt(-x) if x < 0
  
   SEE ALSO
     sqrt
*/
{
    return sign(x) * sqrt(abs(x));
}

/************************************************************************/

func yocoMathWienerFiltering(fnction, &filter, filterStrength=, noiseAmount=)
/* DOCUMENT yocoMathWienerFiltering(fnction, &filter, filterStrength=, noiseAmount=)
                                    noiseAmount=)
  
   DESCRIPTION
     Filters a 1D array of double using the optimal Fourier filter which is
     the Wiener filter.

   PARAMETERS
   - fnction       : the 1D array you want to filter
   - filter        : OUTPUT the returned shape of the filter
   - filterStrength: OPTIONAL ?????????????
   - noiseAmount   : OPTIONAL If you want to specify the level of noise in
                         your data instead of letting the function to select
                         it, put a figure here

   RETURN VALUES
     The filtered array using the wiener filter is returned.

   CAUTIONS
     The noise is by default estimated using few points at high frequency.
     This can in some cases cause the filter to not work at all.
*/
{
    if(is_void(filterStrength))
    {
        filterStrength = 1.0;
    }
    if(is_void(noiseAmount))
    {
        noiseAmount = 10.0/100;
    }
    if(is_void(numberofAvgPoints))
    {
        numberofAvgPoints = 0.5/100;
    }

    N = numberof(fnction);

    // Left and right limit of the function, estimated by few points
    m1 = fnction(1:int(N*numberofAvgPoints+1))(avg);
    m2 = fnction(-int(N*numberofAvgPoints+1):0)(avg);
    dr = (m2-m1) * indgen(N) / N + m1;

    // periodization of the function
    fnctionBis = fnction - dr;

    // spectral density computation
    dsp = abs(fft(fnction))^2;

    // noise estimation
    noise = dsp(N/2 - int(N*noiseAmount):N/2 + int(N*noiseAmount))(avg);

    // noise substraction
    signal = dsp - noise * filterStrength;

    // The filter first estimation, given the noise amount
    filter = signal / (dsp+(dsp==0));

    // clipping of the filter values lower than 0
    if((numberof(where(filter<0))!=0)&&(numberof(where(filter<0))!=0))
    {
        filter(where(filter<0)(1):where(filter<0)(0))=0;
    }

    // Filter the function using the wiener filter computed
    filteredFnction = 1.0/N * fft(filter * fft(fnctionBis, 1), -1).re;

    // Return the filtered function, deperiodizing it.
    return filteredFnction + dr;
} 

/************************************************************************/

func yocoMathResample(x_in, y_in, x_out, &x_out_mod, &y_out)
/* DOCUMENT yocoMathResample(x_in, y_in, x_out, &x_out_mod, &y_out)
  
   DESCRIPTION 
     Resampling of the 1D array Y_in (defined at the data coordinates x_in)
     at the x_out coordinates, with the sinc method.
  
   EXAMPLES
     > x1 = span(-10,10,1000);
     > x2 = spanl(1,8,73);
     > y1 = cos(x1);
     > y2 = reechant(x1,y1,x2);
     > plg,y1,x1;
     > plg,y2,x2,color="red";
*/
{
    mnX = max(min(x_in),min(x_out));
    mxX = min(max(x_in),max(x_out));

    minX = max(mnX - (mxX-mnX)/2,min(x_in));
    maxX = min(mxX + (mxX-mnX)/2,max(x_in));

    idx_in = where((x_in>=minX)&(x_in<=maxX));
    if(numberof(idx_in)==0)
        error,"No point in both intervals !";
    x_in = x_in(idx_in);
    y_in = y_in(idx_in);
    idx_out = where((x_out>=mnX)&(x_out<=mxX));
    x_out_mod = x_out(idx_out);

    np_in = numberof(x_in);
    np_out = numberof(x_out);
    y_out = []; 

    m1 = double(y_in(1));
    m2 = double(y_in(np_in));
    dr_in = (m2-m1) * indgen(np_in ) / np_in + m1;
    dr_out = (m2-m1) * indgen(np_out) / np_out + m1;

    for ( k = 1 ; k <= np_out ; k++)
    {
        tab1 = where(x_out(k)<=x_in);
        if(numberof(tab1)!=0)
        {
            idx1 = tab1(1);
            tab2 = where(x_out(k)>=x_in);
            if(numberof(tab2)!=0)
            {
                idx2 = tab2(0);
                fpIdx = (idx1 * x_out(k) / x_in(idx1) +
                         idx2 * x_out(k) / x_in(idx2))/2.0;
                aa = double(pi * ( fpIdx - indgen(np_in) ));
                sincaa = yocoMathSinc(aa);
                grow, y_out, double(sum( (y_in) * sincaa ));
            }
            else
                grow, y_out, y_in(1);
        }
        else
            grow, y_out, y_in(0);
    }
    return y_out;
}

/************************************************************************/

func yocoMathFactorial(n)
/* DOCUMENT yocoMathFactorial(n)
  
   DESCRIPTION
     Compute the factorial !n, The input parameter n should be integer of
     any dimension

   CAUTIONS
     In its actual form, the function uses a double loop... so it may be
     a way to improve it.
*/
{
  local t,t0,n0;
  
  /* Test the input */
  t = structof(n);
  if( t!=int && t!=short && t!=long ) error,"n should be integer";

  /* Loop on the elements of n */
  t = array(t,dimsof(n));
  for(j=1;j<=numberof(n);j++)
  {
    n0 = n(j); t0 = 1;
    /* Compute the factoriel */
    for(i=2;i<=n0;i++) t0 *= i;
    t(j) = t0;
  }
  
  return t;
}

/************************************************************************/

func yocoMathCnk(n, k)
/* DOCUMENT yocoMathCnk(n, k)

   DESCRIPTION
     Return the number of combination of n into k, usually called C_n^k
*/
{
  return yocoMathFactorial(k) / (yocoMathFactorial(n) * yocoMathFactorial(k-n) );
}


/************************************************************************/

func yocoMathMnk(n, k)
/* DOCUMENT yocoMathMnk(n, k)

   DESCRIPTION
     Return the list of all possible combination of n elements into k, usually
     called M_n^k. The output is of the form array(int,n,k^n)

   EXAMPLES
     > dimsof( yocoMathMnk(2,3) )
     [2,2,9]

     > yocoMathMnk(2,3)(1,)
     [1,2,3,1,2,3,1,2,3]

     > yocoMathMnk(2,3)(2,)
     [1,1,1,2,2,2,3,3,3]
*/
{
    local n, id;

    /* Number of independant combination */
    n  = npos^ntir;
    id = double(indgen(0:n-1));

    /* Construct the combination list */
    return int(   (id(-,) / (npos^indgen(0:ntir-1) ) )% npos  )+1;
}

/************************************************************************/

func yocoMathPolyFit(n, x, y, w)
/* DOCUMENT yocoMathPolyFit(n, x, y, w)
         or yocoMathPolyFit(n, x, y, w)

   DESCRIPTION
     Return [a0,a1,a2,...aN], the coefficients of the least squares
     fit polynomial of degree N to the data points (X, Y).

   REQUIRE
     - matrix.i

   PARAMETERS
   - n: the maximum degree of polynom
   - x: 
   - y: 
   - w: is an optional weight array, which must be conformable with
           X and Y; it defaults to 1.0.  If the standard deviation of Y
           is sigma, conventional wisdom is that W = 1/sigma^2.
         
   EXAMPLES
     > x = random(10); y = random(10);
     > coef = yocoMathPolyFit( 3, x, y);
       
   SEE ALSO
     yocoMathPoly
*/
{
    require,"matrix.i";
    local xi,matrix,rhs,power;

    if (n<1) error,"N should be >0, use X(avg) if you want the mean."
    {
        if (is_void(w))
        {
            w= 1.;
        }
    }
    scale= 1./max(abs(x));
    x*= scale;
    y= double(y);

    xi= w*array(1.,dimsof(x));
    matrix= array(sum(xi), n+1, n+1);
    rhs= array(sum(y), n+1);

    power= indgen(0:n)(,-:1:n+1) + indgen(0:n)(-:1:n+1,);
    for (i=1 ; i<=2*n ; i++)
    {
        xi*= x;
        matrix(where(power==i))= sum(xi);
        if (i<=n)
        {
            rhs(i+1)= sum(y*xi);
        }
    }

    xi= LUsolve(matrix, rhs);
    xi(2:n+1)*= scale^indgen(n);

    return xi;
}

/************************************************************************/

func yocoMathPoly(x, a)
/* DOCUMENT yocoMathPoly(x, a)

   DESCRIPTION
     Returns the polynomial  A(1) + A(2)*x + A(3)*x^2 + ... + A(N)*X^N
     The data type and dimensions of the result, and conformability rules
     for the inputs are identical to those for the expression.

   SEE ALSO
     yocoMathPolyFit
*/
{
    y= array(structof(x), dimsof(x));
    for (n=dimsof(a)(0) ; n>0 ; n--) y= a(..,n) + y*x;
    return y;
}

/************************************************************************/

func yocoMathAiry(z, &w)
/* DOCUMENT yocoMathAiry(z, &w)
   - or -   w = yocoMathAiry(z)

   DESCRIPTION
     Compute the Airy function defined by 2.J(pi.z)/(pi.z)
     where J is the Bessel J function of order 1
     The data type and dimensions of the result, and conformability rules
     for the inputs are identical to those for the expression.

   REQUIRE
     - bessel.i
*/
{
  require,"bessel.i";
  local w,z,id;
  
  z = z*pi;
  id = (z==0);

  w = 2*bessj1(z)/(z+id)  +  id;
  
  return w;
}

/************************************************************************/

func yocoMathPow2(f, e)
/* DOCUMENT yocoMathPow2(f, e)

   DESCRIPTION
      Returns the base2 square of a number, given by the expression:
        f * 2.0^floor(e);
*/
{
    return f * 2.0^floor(e);
}

/************************************************************/

func yocoMathLog2(in)
/* DOCUMENT yocoMathLog2(in)

   DESCRIPTION
     Returns the base 2 log of number in.
*/
{
    n = log(abs(in+(in==0)))/log(2);
    e = floor(n)+1;
    f = exp((n-e)*log(2));
    return [f,e-1];
}

/***************************************************************************/
             
func yocoMathBin2Dec(bin)
/* DOCUMENT yocoMathBin2Dec(bin)

   DESCRIPTION
     Converts a binary figure described by a string of "0" and "1" onto a
     long decimal figure
    
   EXAMPLES
     > yocoMathBin2Dec("000000000110101101000")
     3432
*/
{
    dec = 0;
    len = strlen(bin);
    for(k=1;k<=len;k++)
    {
        dec = (2 * dec) + yocoStr2Long(strpart(bin,k:k));
    }
    return dec;
}

/************************************************************/

func yocoMathDec2Bin(dec)
/* DOCUMENT yocoMathDec2Bin(dec)

   DESCRIPTION
     Converts a decimal number to an array of "0" and "1"

   EXAMPLES
     > yocoMathDec2Bin(3432)
     "000000000110101101000"
*/
{
    size = sizeof(dec)*8;
    reste = 1;
    bin = "";
    if((dec%2)==1)
        bin = bin+"1";
    else
        bin = bin+"0";
    for(i=1; i<=size-11;i++)
    {
        reste = dec / 2;
        if(i>=2)
            bin = pr1(floor(dec % 2)) + bin;
        dec = reste;
    }
    return bin;
}

/************************************************************/

func yocoMathDouble2Bin(in)
/* DOCUMENT yocoMathDouble2Bin(in)

   DESCRIPTION
     Returns the binary equivalent of a double precision number
    
   EXAMPLES
     > yocoMathDouble2Bin(234.4524265)
     "+.11101010011100111101001000111001000111010101100000010*2^+7"
*/
{
    n = numberof(in);
    fracbits = 53; // # of bits for IEEE double fraction
    frac = array("",n);
    expo = array(0,n,1);
    x = yocoMathLog2(abs(in));
    f = x(1);
    e = x(2);
    frac = yocoMathDec2Bin(yocoMathPow2(f,fracbits));
    expo = e;
    if(expo>0)
        sign="+";
    else
        sign="";
    out = "+."+frac+"*2^"+sign+pr1(expo);
    if(in<0)
        out = "-"+strpart(out,2:);
    return out;
}

/************************************************************/

func yocoMathBin2Double(bit)
/* DOCUMENT yocoMathBin2Double(bit)

   DESCRIPTION
     Returns the double precision equivalent of a binary number

   EXAMPLES
     > yocoMathBin2Double("+.11101010011001000111010101100000010*2^+7")
     234.392
*/
{
    sign     = yocoStr2Double(strpart(bit,1:1)+"1");
    startm    = strfind(".",bit);
    endm      = strfind("*",bit);
    mantissa = strpart(bit,startm(2)+1:endm(1));
    expo = yocoStr2Double(yocoStrSplit(bit,"^")(2));
    
    dec      = 0.0;
    len      = double(strlen(mantissa));
    for(pralapouat=1;pralapouat<=len;pralapouat++)
    {
        dec = (2.0 * dec) +
            yocoStr2Double(strpart(mantissa,pralapouat:pralapouat));
    }
    dec = dec / 2.0^(len-1);
    if(expo>100.0)
        expo = 100.0;
    dec = dec * 2.0^(expo);
    return sign*dec;
}

/************************************************************/

func yocoMathGA_cross(father, mother, proba)
/* DOCUMENT yocoMathGA_cross(father, mother, proba)

   DESCRIPTION
     Used in genetic algorithm fit: from a "father" and a "mother" numbers
     given as binary strings, and a probability, returns back a "child" number
     resulting from crossing the binary mantissa of the two numbers.

   PARAMETERS
   - father: input binary number
   - mother: input binary number
   - proba : probability of crossing the 2 numbers

   SEE ALSO
     yocoMathBin2Double, yocoMathDouble2Bin
*/
{
    require,"random.i";
    
    r = random();
    if(r<proba)
    {
        r2 = random();
        r3 = random();
        if(r3>0.5)
        {
            p1 = father;
            p2 = mother;
        }
        else if(r3<=0.5)
        {
            p1 = mother;
            p2 = father;
        }
        cut = int(r2*strlen(p1)+0.5);
        son = strpart(p1,1:cut) + strpart(p2,cut+1:)
            }
    else
    {
        r2 = random();
        if(r2>0.5)
            son = mother;
        else if(r2<=0.5)
            son = father;
    }
    return son;
}

/************************************************************/

func yocoMathGA_mute(bit, proba)
/* DOCUMENT yocoMathGA_mute(bit, proba)
   
   DESCRIPTION
     Used in genetic algorithm fit: mutation of a binary chain,
     with a given probability

   PARAMETERS
   - bit  : binary string
   - proba: probability of mutation

   SEE ALSO
     yocoMathGA_cross
*/
{
    sign     = strpart(bit,1:1);
    if(random()<proba)
        if(sign=="+")
            sign = "-";
        else if(sign=="-")
            sign = "+";
    startm    = strfind(".",bit);
    endm      = strfind("*",bit);
    mantissa = strpart(bit,startm(0)+1:endm(1));
    expo = yocoStrSplit(bit,"^")(0);
    len = strlen(mantissa);
    newMant = "";
    for(pralapouat=1;pralapouat<=len;pralapouat++)
    {
        s = strpart(mantissa,pralapouat:pralapouat);
        if(random()<proba)
        {
            r = pr1(1 - yocoStr2Long(s));
            newMant = newMant + r;
        }
        else
        {
            newMant = newMant + s;
        }
    }
    if(random()<proba)
    {
        if(random()<0.5)
            expo = pr1(int(256*(0.5-random())));
        else
        {
            dexpo = yocoStr2Double(expo);
            if(dexpo<0)
                dexpo = dexpo-1;
            else if(dexpo>0)
                dexpo = dexpo+1;
            expo = pr1(dexpo);
        }
    }
    else
        expo = pr1(yocoStr2Double(expo));
    
    if(yocoStr2Double(expo)>=0)
        expo = "+"+expo;
    
    bitout = sign+"." + newMant + "*2^"+expo;
    
    if(random()<proba)
        bitout = yocoMathDouble2Bin(random_n());
    
    return bitout;
}

/************************************************************/

func yocoMathGA_fit(fct, xmes, &params, ymes, weights, itmax=, population=, probaCross=, probaMute=, elitism=, verbose=, randomStart=)
/* DOCUMENT yocoMathGA_fit(fct, xmes, &params, ymes, weights, itmax=, population=, probaCross=, probaMute=, elitism=, verbose=, randomStart=)
                           itmax=, population=, probaCross=, probaMute=,
                           elitism=, verbose=, randomStart=)

   DESCRIPTION
     Genetic algorithm fit.

   PARAMETERS
   - fct        : input function
   - xmes       : measures coordinates
   - params     : parameters of the input function
   - ymes       : measures
   - weights    : weights. w = 1/sigma2
   - itmax      : maximum iterations. defaults to 100
   - population : population of the "genetic pool", defaults to 10
   - probaCross : reproduction probability (defaults to 0.7)
   - probaMute  : mutation probability (defaults to 0.05)
   - elitism    : elitism, i.e. fraction of population which survive
                     each iteration. defaults 0.5 (50%)
   - verbose    : verbose mode
   - randomStart: start the parameters randomly instead of taking the
                     original values

   RETURN VALUES
     The final chi^2 is returned, and the params array is modified

   CAUTIONS
     The params array is modified, so please backup it in an other variable#
     if you want to make comparisons

   EXAMPLES
     see yocoMathGA_test
*/
{
    local nParams, P, Q;
      
    nParams = numberof(params);
    P = population;
    Q = numberof(ymes);
    
    if(is_void(verbose))
        verbose=1;
    
    if(is_void(probaCross))
        probaCross = 0.7;

    if(is_void(elitism))
    {
        elitism = 0.5;
    }
    
    if(is_void(probaMute))
        probaMute  = 0.05;

    if(is_void(P))
        P = 2*int(sqrt(numberof(ymes)));

    if(is_void(itmax))
        itmax = 10*int(sqrt(numberof(ymes)+nParams));

    if(is_void(weights))
        weights = array(1.0,dimsof(ymes));

    if(is_void(randomStart))
        randomStart=1;

    if(randomStart==1)
        pop = enfants = random_n(numberof(params),P);
    else
        pop = enfants = array(params,P);
  
    NOffsprings = int((1-elitism)*P+0.5);
  
    for(l=1;l<=nParams;l++)
    {
        for(k=2;k<=P;k++)
        {
            fo = yocoMathDouble2Bin(pop(l,k));
            so = yocoMathGA_mute(fo,probaMute);
            pop(l,k) = yocoMathBin2Double(so);
        }
    }
    
    chi2 = array(double,P);

    for(k=1;k<=P;k++)
    {
        testVals = fct(xmes,pop(,k));
        difference = testVals - ymes;
        chi2(k) = sum(weights*difference*difference);
    }
  
    sorting = sort(chi2);
    pop = pop(,sorting);
    chi2 = chi2(sorting);

    if(verbose)
        write,"Iterations",itmax;
  
    for(IT=1;IT<=itmax;IT++)
    {
        if(IT%10==0)
            write,"Iteration "+pr1(IT);
        
        sorting2 = sort(chi2);
        pop = pop(,sorting2);
        chi2 = chi2(sorting2);
      
        params = pop(,1);
      
        pairs = int([random(NOffsprings),
                     random(NOffsprings)]*(P-NOffsprings)+0.5);
      
        for(k=1;k<=NOffsprings;k++)
        {
            for(l=1;l<=nParams;l++)
            {
                mother = yocoMathDouble2Bin(pop(l,pairs(k,1)));
                father = yocoMathDouble2Bin(pop(l,pairs(k,2)));
                son  = yocoMathGA_cross(father, mother, probaCross);
                son2 = yocoMathGA_mute(son,probaMute);
                pop(l,P-NOffsprings+k) = yocoMathBin2Double(son2);
            }
            testVals = fct(xmes,pop(,P-NOffsprings+k));
            difference = testVals - ymes;
            chi2(P-NOffsprings+k) = sum(weights*difference*difference);
        }
    }
    return chi2;
}

/************************************************************/

func yocoMathGA_test(void)
/* DOCUMENT yocoMathGA_test

   DESCRIPTION
     If you want to test genetic alorithm fit on a very simple example, type
     > yocoMathGA_test
    
   SEE ALSO
     yocoMathGA_fit
*/
{
    yocoGuiWinKill;
    Npix = 500;
    x = span(0,150,Npix);
    //     paramsvrai = random_n(2);
    paramsvrai = [2.32875364,107.5365345748];
    yvrai1 = yocoMathGauss(x,paramsvrai);

    errorZ = 0.06;
  
    ymes1 = yvrai1+random_n(numberof(x))*errorZ;

    w = array(1.0/errorZ^2,Npix);
    
    a = [100.0,100.0];
    toto = yocoMathGA_fit(yocoMathGauss,x,a,ymes1,w,randomStart=1);
    
    yvrai2 = yocoMathGauss(x,a);
  
    window,3;
    fma;
    plg,yvrai1,x,color="black";
    plg,ymes1,x;
    plg,yvrai2,x,color="red";
    
    write,paramsvrai;
    write,a;
    write, sum(w*(yocoMathGauss(x,a) - ymes1)^2) / sum(w);
}

func yocoMathCholesky(a, raw)
/* DOCUMENT yocoMathCholesky(a)
       -or- yocoMathCholesky(a, 0/1)
       
     Given  a  symmetric  positive  definite  matrix  A,  returns  a  lower
     triangular  matrix C  which is  the Cholesky  decomposition of  A such
     that:

       A = C(+,)*C(+,);

     If  optional  second argument  is  true  (non-nil  and non-zero),  the
     scratch values in  the upper triangular part of  C are left unchanged;
     otherwise (the  default behavior), the  upper triangular part of  C is
     filled with zeros.

     If COV(nvar,nvar) is a covariance matrix, then a list of random number
     Y following this statistic can be built with:

       C = yocoMathCholesky( COV );
       Y = C(+,) * random_n(nvar,200)(+,);
*/
{
  if (! is_array(a) || structof(a) == complex ||
      (dims = dimsof(a))(1) != 2 || (n = dims(2)) != dims(3))
    error, "expecting a N x N non-complex array";
  a = double(a);

  if ((s = a(1,1)) <= 0.0) error, "the matrix is not positive definite";
  a(1,1) = sqrt(s);
  for (j=2 ; j<=n ; ++j) {
    a(1,j) = (t = a(1,j)/a(1,1));
    s = t*t;
    for (k=2 ; k<j ; ++k) {
      rng = 1:k-1;
      a(k,j) = (t = (a(k,j) - sum(a(rng,k)*a(rng,j)))/a(k,k));
      s += t*t;
    }
    s = a(j,j) - s;
    if (s <= 0.0) error, "the matrix is not positive definite";
    a(j,j) = sqrt(s);
  }
  if (! raw) {
    for (k=1 ; k<n ; ++k) a(k+1, 1:k)=0;
  }
  return a;
}


/************************************************************/
