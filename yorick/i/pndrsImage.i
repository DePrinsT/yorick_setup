/*******************************************************************************
*
* PIONIER Data Reduction Software
*
*/

func pndrsImage(void)
/* DOCUMENT pndrsImage(void)

   FUNCTIONS:
   - pndrsImageGetStrehl
   
*/
{
    local version;
    version = strpart(strtok("$Revision: 1.1 $",":")(2),2:-2);
    
    if (am_subroutine())
    {
        help, pndrsImage;
    }   
    return version;
}


func pndrsImageGetStrehl(imgData, x1, y1, &s)
/* DOCUMENT pndrsImageGetStrehl(imgData, x1, y1, &s)

   DESCRIPTION
   Compute the Strehl of the images, as the ratio between the
   pixel in (x1,y1) versus the 3x3 box around it.

   The scan and the nscan direction are averaged first, so
   the dimension of "s" is (nwin).

   Optionally, x1 and y1 can be conformable arrays. In this case
   the dimension of "s" is (dimsof(x1), nwin).
   
   PARAMETERS

   EXAMPLES

   SEE ALSO
 */
{
  local data, f;
  yocoLogInfo,"pndrsImageGetStrehl()";

  /* Get data */
  if ( numberof(imgData)>1 ) return yocoError("Only works with scalar imgData");
  data = (*imgData(1).regdata)(,,avg,avg,);

  /* Compute the Strehl as the 1/9pixels */
  f = data(x1+0,y1+0,);
  s =  f / ( data(x1-1,y1-1,) + data(x1+0,y1-1,) + data(x1+1,y1-1,) +
             data(x1-1,y1+0,) + data(x1+0,y1+0,) + data(x1+1,y1+0,) +
             data(x1-1,y1+1,) + data(x1+0,y1+1,) + data(x1+1,y1+1,) );

  yocoLogTrace,"pndrsImageGetStrehl done";
  return 1;
}

