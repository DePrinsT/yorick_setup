/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Test of the Wrapper of CFITSIO for Yorick.
 *
 * "@(#) $Id: cfitsioTest.i,v 1.2 2008-09-23 08:17:28 altariba Exp $"
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2007/02/16 14:26:03  jblebou
 * Add this test file to the project.
 *
 *
 */

/* include the plugin */
#include "cfitsioPlugin.i"

/* ==========================================================
               Test of user-oriented functions
   ========================================================== */

/* function to format the test outputs */
func __test_string(str)  {write,format="---------------------------------------------\n%-45s\n",str+"...";}
func __test_answer(flag) {write,format="%+45s\n","...ok";}

/* error value that will be tested */
errnum = [-1,0,1,101,102,112,104,105,201,202,203,204,301,312,303,304];

/* filename created by the test */
filename  = "test.fits";
remove,filename;

/* some keys that will be added */
keynumname = "TEST-NUM";
keynum = 10.0;
keystrname = "TEST-STR";
keystr = "test";
keychaname = "TEST-CHA";
keycha = 'y';
keyhiename = "TEST ESO TMP NUM";
keyhie = "test";

/* data for the primary image */
primaname = "PRIM-TEST";
data0 = indgen(1:5)(-:2:10,);

/* data for the secondary image */
imagename = "IMG_TEST";
data1 = span(0,10,15)(,-:1:20);

/* data for the binary table */
tablename = "TBL_TEST";
data2name = "COL1";
data2 = int(random(43)*100);
data3name = "COL2";
data3 = swrite(format="titi%i",int(2^(indgen(43)/3.)));
data4name = "COL3";
data4 = ['0','1']((random(43)>.5)+1);
data5name = "COL4";
data5 = random(3,4,43);
data6name = "COL5";
data6 = data5*1.i + data2(-,-,);

write,"========================================";
write,"=           Generic tests              =";
write,"========================================";

/* generic test */
__test_string,"fitsion version";
cfitsio_get_version();
__test_answer;

__test_string,"test error status";
for(i=1;i<=numberof(errnum);i++) cfitsio_get_errstatus(errnum(i));
__test_answer;

write,"========================================";
write,"= Test of user-oriented writting func. =";
write,"========================================";

remove,filename;

/* Test writing */
__test_string, "create a file";
fh = cfitsio_open(filename,"c");
__test_answer;

__test_string,"add an image";
cfitsio_add_image, fh, data0, primaname; 
__test_answer;

__test_string,"add an image";
cfitsio_add_image, fh, data1, imagename; 
__test_answer;

__test_string,"add a card (numerical)";
cfitsio_write_key, fh, keynumname, keynum;
__test_answer;

__test_string,"add a HIERARCH card (string)";
cfitsio_write_key, fh, keyhiename, keyhie;
__test_answer;

__test_string,"add a binary table";
cfitsio_add_bintable, fh,
  [&data2,&data3,&data4,&data5,&data6],
  [data2name,data3name,data4name,data5name,data6name];
__test_answer;

cfitsio_insert_cols, fh, 1, ["i1","i2"], ["3A","2D"];

__test_string,"add a card (char)";
cfitsio_write_key, fh, keychaname, keycha;  
__test_answer;

__test_string,"close the file";
cfitsio_close,fh;                         
__test_answer;


write,"========================================";
write,"= Test of user-oriented reading func.  =";
write,"========================================";

/* Test append */
__test_string,"open the file in append mode";
fh    = cfitsio_open(filename,"a");       
__test_answer;

__test_string,"close the file";
cfitsio_close,fh;                         
__test_answer;

/* Test read */

__test_string,"open the file in reading mode";
fh    = cfitsio_open(filename,"a");       
__test_answer;

__test_string,"list all HDU type";
cfitsio_list, fh;
__test_answer;

__test_string,"go to HDU number 3";
cfitsio_goto_hdu,fh,3;                    
write,format="HDUnum=%i\n",cfitsio_get_hdu_num(fh);
write,format="EXTNAME=%s\n",cfitsio_get(fh,"EXTNAME");
__test_answer;

__test_string,"read all 'N*' keys";
tests = cfitsio_get(fh,"N*",comments,names,point=1); 
for(i=1;i<=numberof(tests);i++)  write,format="Keyname:%-10s - Keyvalue: %s\n",names(i),pr1(*(tests(i)));
__test_answer;

__test_string,"read the binary table";
table = cfitsio_read_bintable(fh,titles);
for(i=1;i<=numberof(titles);i++)  
  write,format="%s is: %s...\n",titles(i),pr1((*(table(i)))(1:3));
__test_answer;

__test_string,"go to HDU called '"+imagename+"'";
cfitsio_goto_hdu,fh,imagename;               
write,format="EXTNAME=%s\n",cfitsio_get(fh,"EXTNAME");
__test_answer;

__test_string,"read its image";
img   = cfitsio_read_image(fh);             
write,format="max(data-dataorg)^2 = %.3f\n",float(max((img-data1)^2));
__test_answer;

__test_string,"close file";
cfitsio_close,fh;                           
__test_answer;

write,"========================================";
write,"= Test of individual wrapper functions =";
write,"========================================";


__test_string,"cfitsio_open_file";
fh = [];
fh = cfitsio_open_file(filename);
cfitsio_close,fh;
__test_answer;


__test_string,"cfitsio_file_exist";
cfitsio_file_exists(filename);
cfitsio_file_exists(filename+"toto");
//cfitsio_file_exists(filename+array("a",2000)(sum));
__test_answer;
                
fh = cfitsio_open_file(filename,READWRITE);

__test_string,"cfitsio_file_name, mode, type";
cfitsio_file_name(fh);
cfitsio_file_mode(fh);
cfitsio_url_type(fh);
__test_answer;

__test_string,"cfitsio_write_key";
cfitsio_write_key,fh,"TATA","test"," [unit1] ";
cfitsio_write_key,fh,"ESO OBS TOTO",pi," [unit2] ";
__test_answer;

__test_string,"cfitsio_read_card";
cfitsio_read_card(fh,"TATA");
cfitsio_read_card(fh,"ESO OBS TOTO");
__test_answer;

__test_string,"cfitsio_read_record";
cfitsio_read_record(fh,1);
cfitsio_read_record(fh,2);
__test_answer;

__test_string,"cfitsio_find_next";
cfitsio_find_nextkey(fh,"*");
cfitsio_find_nextkey(fh,"ESO*");
__test_answer;

__test_string,"cfitsio_read_key";
cfitsio_read_key_unit(fh,"TATA");
cfitsio_read_key_unit(fh,"ESO OBS TOTO");
__test_answer;

__test_string,"cfitsio_update_key";
cfitsio_update_key,fh,"TATA",pi^2;
cfitsio_update_key,fh,"ESO OBS TOTO","modified str";
__test_answer;

__test_string,"cfitsio_write_comment";
cfitsio_write_comment,fh,"comment test";
cfitsio_write_comment,fh,"long comment test"+string(&array('t',230));
cfitsio_write_comment,fh,string("");
__test_answer;

__test_string,"cfitsio_write_history";
cfitsio_write_history,fh,"history test";
cfitsio_write_history,fh,"long history test"+string(&array('t',230));
__test_answer;

__test_string,"cfitsio_write_date";
cfitsio_write_date,fh;
cfitsio_read_key(fh,TSTRING,"DATE");
__test_answer;

__test_string,"cfitsio_modify_comment";
cfitsio_modify_comment,fh,"ESO OBS TOTO","modified comment, this removed the unit";
cfitsio_modify_comment,fh,"TATA","modified comment, this removed the unit";
cfitsio_read_card(fh,"ESO OBS TOTO");
__test_answer;

__test_string,"cfitsio_write_key";
cfitsio_write_key_unit,fh,"TATA","unit:str";
cfitsio_write_key_unit,fh,"ESO OBS TOTO","unit:none";
cfitsio_read_card(fh,"ESO OBS TOTO");
__test_answer;

__test_string,"cfitsio_modify_name";
cfitsio_modify_name, fh, "TATA", "TOTO";
cfitsio_modify_name, fh, "ESO OBS TOTO", "ESO OBS TATA";
__test_answer;

__test_string,"cfitsio_delete_record";
cfitsio_read_record(fh,7);
cfitsio_delete_record, fh, 7;
cfitsio_read_record(fh,7);
__test_answer;

__test_string,"cfitsio_delete_key";
cfitsio_delete_key,fh, "TOTO";
cfitsio_delete_key,fh, "ESO OBS TATA";
__test_answer;

__test_string,"cfitsio_get_hdrspace";
cfitsio_get_hdrspace(fh,morekeys);
morekeys;
__test_answer;

__test_string,"cfitsio_get_hdu_num";
cfitsio_get_hdu_num(fh);
__test_answer;

__test_string,"cfitsio_get_hdu_type";
cfitsio_get_hdu_type(fh);
__test_answer;

__test_string,"cfitsio_get_img_type";
bitpix = cfitsio_get_img_type(fh);
bitpix;
__test_answer;

__test_string,"cfitsio_get_img_dim";
cfitsio_get_img_dim(fh);
__test_answer;

__test_string,"cfitsio_get_img_size";
cfitsio_get_img_size(fh);
__test_answer;


/*--------------------- HDU operations -------------*/

__test_string,"cfitsio_movabs_hdu";
fh = cfitsio_movabs_hdu(fh,2);
__test_answer;

__test_string,"cfitsio_movrel_hdu";
cfitsio_movrel_hdu,fh,-1;
__test_answer;

__test_string,"cfitsio_movnam_hdu";
fh = cfitsio_movnam_hdu(fh,ANY_HDU,"FYO_TBL");
__test_answer;

__test_string,"cfitsio_get_num_hdus";
cfitsio_get_num_hdus(fh);
__test_answer;

__test_string,"cfitsio_create_img";
cfitsio_create_img, fh, bitpix, dimsof(data0);
__test_answer;

__test_string,"cfitsio_write_pix";
fpixels   = array(1,2);
nelements = 7;
cfitsio_write_pix, fh, fpixels, nelements, data0;
__test_answer;

__test_string,"cfitsio_create_img";
cfitsio_create_img, fh, bitpix, [1,1];
__test_answer;

__test_string,"cfitsio_create_tbl";
cfitsio_create_tbl,fh,BINARY_TBL,,["tit1","tit2"],["10A","10D"],["u","v"];
cfitsio_insert_cols, fh, 1, ["i1","i2"], ["3A","2D"];
__test_answer;

/*--------------------- get column information -------------*/

__test_string,"cfitsio_close";
cfitsio_close,fh;
__test_answer;
