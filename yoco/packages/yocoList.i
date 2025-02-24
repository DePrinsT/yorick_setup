/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 *  List (1D array) manipulation tools.
 *
 * "@(#) $Id: yocoList.i,v 1.14 2010-10-08 07:13:32 lebouquj Exp $"
 *
 ******************************************************************************/

func yocoList(void)
/* DOCUMENT yocoList

   DESCRIPTION
     List (1D array) manipulation tools.
    
   VERSION
     $Revision: 1.14 $

   FUNCTIONS
   - yocoList        : 
   - yocoListClean   :
   - yocoListCleanId :
   - yocoListElementN: Return the value of an array at a
                          multidimentional indices
   - yocoListId      : 
   - yocoListIndex1  : Convert multidimensional one-dimensional indices
   - yocoListIndexN  : Convert one-dimensional into multidimensional indices
   - yocoListProduct : 
   - yocoListUniqueId: 
   - yocoListWhereN  : Return the indices of non-null values of an array
     
     - yocoListId       : Give a unique id of each distinct element of a list
     - yocoListUniqueId : Associate element of a list with
                          position in another list
     - yocoListClean    : Remove multiple element of a list
     
     - yocoListProduct  : Make the product of all term along one dimension
*/
{
    version = strpart(strtok("$Revision: 1.14 $",":")(2),2:-2);
    if (am_subroutine())
    {
        help, yocoList;
    }   
    return version;
} 

/* ================================================================= */

func yocoListIndexN(dim_list, idx_1)
/* DOCUMENT yocoListIndexN(dim_list, idx_1)

   DESCRIPTION
     Convert a one-dimensional offset into a multidimensional index.
     idx is an offset in respect to the beginning of a multidimensional array,
     e.g. as returned by where.  The dimensions of the array are are specified in
     dim_list.
  
     The result is the multi-dimensional index [i_1, ..., i_n], e.g. as returned
     by yocoListWhereN.
  
   EXAMPLES
     > A = [[7, 3, 2], [1, 2, 4]];
     > yocoListIndexN(dimsof(A), 5)
     [2, 2]
     
   SEE ALSO: yocoListWhereN, yocoListIndex1, yocoListElementN
*/
{
   local n, dim_n, idx_n, offsets;

   n           = dim_list(1);
   dim_1       = dimsof(idx_1);
   dim_n       = array(int, dim_1(1)+2);
   if (dim_1(1) != 0)
      dim_n(3:0)  = dim_1(2:);
   dim_n(1)    = dim_1(1)+1;
   dim_n(2)    = n;
   
   idx_n = array(long, dim_n);
   for (i = 1, idx_1 -= 1; i <= n; idx_1 /= dim_list(1+i++))
      idx_n(i,..) = idx_1 % dim_list(i+1);

   return idx_n+1;

}

func yocoListIndex1(dim_list, idx_n)
/* DOCUMENT yocoListIndex1(dim_list, idx_n)

   DESCRIPTION:
     Convert a multidimensional index into a one-dimensional offset.
     idx_n is a multidimensional index in a given array, e.g. as returned by
     yocoListWhereN.  The dimensions of the array are are specified in
     dim_list.
     
     The result is an one-dimensional offset in respect to the beginning of
     the array, e.g. as returned by where.

   EXAMPLES
     > A = [[7, 3, 2], [1, 2, 4]];
     > yocoListIndexN(dimsof(A), [[1, 1], [2, 2]])
     [1, 5]
   
   SEE ALSO: yocoListWhereN, yocoListIndexN, yocoListElementN
*/
{
   local n, dim_1, idx_1, offsets;

   dim_1    = dimsof(idx_n)(2:);
   dim_1(1) = numberof(dim_1)-1;
   idx_1    = array(long(0), dim_1);
   n        = dim_list(1);

   for (i = n, idx_n -= 1, dim_list(1) = 1; i > 0; --i) {
      idx_1 += idx_n(i,..);
      idx_1 *= dim_list(i);
   }

   return idx_1+1;
}

func yocoListWhereN(tab)
/* DOCUMENT yocoListWhereN(tab)

   DESCRIPTION
     Return the indices of non-null values of an array
     It is the same as where, except that the return value is not given
     as an offset in respect to the beginning of the array, but as a
     multidimensional index.
  
   EXAMPLES
     > A = [[[1,2],[3,4],[5,6]],[[7,8],[9,10],[11,12]]];
     > yocoListWhereN(A > 5)
     [[2,3,1],[1,1,2],[2,1,2],[1,2,2],[2,2,2],[1,3,2],[2,3,2]]
       
    SEE ALSO: where, yocoListIndexN, yocoListIndex1
 */
{
  return yocoListIndexN(dimsof(tab), where(tab));
}

func yocoListElementN(tab, idx_n)
/* DOCUMENT yocoListElementN(tab, idx_n)

   DESCRIPTION
     Return the value of an array at index [i_1, ..., i_n]

   EXAMPLES
     > A = [[[1,2],[3,4],[5,6]],[[7,8],[9,10],[11,12]]];
     > yocoListElementN(A, [[1, 1, 2], [2, 2, 2]];
     [7, 10]
      
   SEE ALSO: yocoListIndex1, yocoListIndexN
*/
{
  return A(yocoListIndex1(dimsof(A), idx_n));
}

func yocoListId(id, ref)
/* DOCUMENT yocoListId(id, ref)

   DESCRIPTION
     For each id, return the (last) position in ref where id==ref
     Return 0 where there is no match.

   PARAMETERS
   - id : 1D array
   - ref: 1D array

   EXAMPLES
     > yocoListId([4,5,2,3,2,1,5],[0,1,2,3,4]);
     [5,0,3,4,3,2,0]
 */
{
    local _id,out;

    if (is_void(ref) || is_void(id))
        error,"yocoListId takes exactly 2 parameters";

    ref=ref(*);

    out = array(0,dimsof(id));
    _id =  where2(id(*) == ref(-,));
    if (is_array(_id)) out(*)(_id(1,)) = _id(2,);
    return out;
}

func yocoListUniqueId(input)
/* DOCUMENT yocoListUniqueId(input)

   DESCRIPTION
     Return an id (integer) identical for all identical
     elements of the 1D array input.

   CAUTIONS
     The id is not increased by order of apparition in
     the list but by sorting order (as defined by sort).

   EXAMPLES
     > yocoListUniqueId([4,5,2,3,2,1,5,9]);
     [4,5,2,3,2,1,5,6]
   
     > yocoListUniqueId([9,1,34]);
     [2,1,3]
   
     > yocoListUniqueId([]);
     []
 */
{
    local id,in;

    /* simple cases */
    if (numberof(input)<1)   return;
    if (numberof(input)==1 ) return 1;

    /* get the ids*/
    in = input(*)(sort(input(*)));
    id = grow( 0, in(:-1)!=in(2:) )(psum)+1;

    /* return them */
    return id(yocoListId(input,in));
}

func yocoListClean(liste, input)
/* DOCUMENT yocoListClean(liste, input)

   DESCRIPTION
     Keep only a single item of each element of input.

   PARAMETERS
   - liste: 1D array to be cleaned
   - input: optional 1D array of same dimension than
                'liste'. If present, the difference is checked
                on this array.

   CAUTIONS
     The sorting is lost. The return values are ALWAYS a
     monotonically increasing array.
    
   EXAMPLES
     > yocoListClean([4,5,2,5,2,1,5]);
     [1,2,4,5]
   
     > yocoListClean(["tmp","tmp","tmp","tmp"]);
     "tmp"
  
     > strs = ["wed","1","we","sd","wer"];
     > yocoListClean(strs,strlen(strs));
     ["1","we","wed"]
     
     > yocoListClean([]);
     []
*/
{
  local tmp, ids, output, listeSorted;

  /* case input is void */
  if (is_void(input)) input=liste;
  if (numberof(liste) != numberof(input)) error,"liste and input should have same dim";
  
  /* very simple cases */
  if(is_void(input)) return;
  if(numberof(input)==1) return liste(1);
  
  /* sort the arrays */
  tmp = input(sort(input));
  listeSorted = liste(sort(input));

  /* find new elements */
  if(structof(tmp)==string) ids = where(tmp(1:-1) != tmp(2:0));
  else ids = where(tmp(dif));
  
  /* Concaten the found elements */
  if(is_array(ids)) ids = grow(1, ids+1);
  else              ids = 1;
  
  /* return the results */
  return listeSorted(ids);
}

func yocoListCleanId(liste)
/* DOCUMENT id = yocoListCleanId(liste)

   DESCRIPTION
   Return an array of index so that liste(id) contains
   only a single example of each element of input.

   PARAMETERS
   - liste: input array

   EXAMPLES
   > yocoListCleanId(random(10))
   [1,2,3,4,5,6,7,8,9,10]
   > yocoListCleanId([1,2,1,2,4,4,3,2,1])
   [1,2,5,7]

   SEE ALSO
*/
{
  local output;
  
  /* very simple cases */
  if(is_void(liste))     return;
  if(numberof(liste)==1) return 1;

  /* Loop on elements to look for new */
  for (output=1,i=2;i<=numberof(liste);i++)
    if (noneof( liste(output)==liste(i)) ) grow, output, i;

  /* Return Id of new elements */
  return output;
}


func yocoListProduct(data, dim)
/* DOCUMENT yocoListProduct(data, dim)

   DESCRIPTION
     Return the multiplication of the elements of DATA
     along the dimension DIM (default is 1, so the first dim).

   EXAMPLES
     > yocoListProduct([3,1,5])
     15
    
     > yocoListProduct( random(3,10), 2)
     [1.60373e-05,2.6681e-06,0.00037061]

   CAUTIONS
     This function explicitely loop on the DIM
     dimention of data.
 */
{
    local Dim,prod;

    /* If void */
    if(is_void(data)) return data;

    /* If scalar */
    Dim = dimsof(data);
    if(Dim(1)==0) return data;

    /* Default for dim is 1 */
    if(is_void(dim)) dim = 1;
    dim = int(dim);

    /* Transpose and prepare output array */
    if(dim>Dim(1)) return error("not conformable dimention");
    data = transpose(data,1,dim);
    prod = data(1,..)*0+1;

    /* Loop */
    for(i=1;i<=Dim(1+dim);i++) 
        prod *= data(i,..);

    return prod;
}
