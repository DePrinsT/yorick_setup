if (!is_void(plug_in)) plug_in, "cfitsioPlugin";
write,"cfitsioPlugin plugin loaded";

/****** DEFINE CONSTANTS (numerical ones only) ******/

/* Wrapping of 'FLEN_FILENAME' define */
FLEN_FILENAME = int (1025);
        
/* Wrapping of 'FLEN_KEYWORD' define */
FLEN_KEYWORD = int (72);
        
/* Wrapping of 'FLEN_CARD' define */
FLEN_CARD = int (81);
        
/* Wrapping of 'FLEN_VALUE' define */
FLEN_VALUE = int (71);
        
/* Wrapping of 'FLEN_COMMENT' define */
FLEN_COMMENT = int (73);
        
/* Wrapping of 'FLEN_ERRMSG' define */
FLEN_ERRMSG = int (81);
        
/* Wrapping of 'FLEN_STATUS' define */
FLEN_STATUS = int (31);
        
/* Wrapping of 'TBIT' define */
TBIT = int (1);
        
/* Wrapping of 'TBYTE' define */
TBYTE = int (11);
        
/* Wrapping of 'TSBYTE' define */
TSBYTE = int (12);
        
/* Wrapping of 'TLOGICAL' define */
TLOGICAL = int (14);
        
/* Wrapping of 'TSTRING' define */
TSTRING = int (16);
        
/* Wrapping of 'TUSHORT' define */
TUSHORT = int (20);
        
/* Wrapping of 'TSHORT' define */
TSHORT = int (21);
        
/* Wrapping of 'TUINT' define */
TUINT = int (30);
        
/* Wrapping of 'TINT' define */
TINT = int (31);
        
/* Wrapping of 'TULONG' define */
TULONG = int (40);
        
/* Wrapping of 'TLONG' define */
TLONG = int (41);
        
/* Wrapping of 'TINT32BIT' define */
TINT32BIT = int (41);
        
/* Wrapping of 'TFLOAT' define */
TFLOAT = int (42);
        
/* Wrapping of 'TLONGLONG' define */
TLONGLONG = int (81);
        
/* Wrapping of 'TDOUBLE' define */
TDOUBLE = int (82);
        
/* Wrapping of 'TCOMPLEX' define */
TCOMPLEX = int (83);
        
/* Wrapping of 'TDBLCOMPLEX' define */
TDBLCOMPLEX = int (163);
        
/* Wrapping of 'TYP_STRUC_KEY' define */
TYP_STRUC_KEY = int (10);
        
/* Wrapping of 'TYP_CMPRS_KEY' define */
TYP_CMPRS_KEY = int (20);
        
/* Wrapping of 'TYP_SCAL_KEY' define */
TYP_SCAL_KEY = int (30);
        
/* Wrapping of 'TYP_NULL_KEY' define */
TYP_NULL_KEY = int (40);
        
/* Wrapping of 'TYP_DIM_KEY' define */
TYP_DIM_KEY = int (50);
        
/* Wrapping of 'TYP_RANG_KEY' define */
TYP_RANG_KEY = int (60);
        
/* Wrapping of 'TYP_UNIT_KEY' define */
TYP_UNIT_KEY = int (70);
        
/* Wrapping of 'TYP_DISP_KEY' define */
TYP_DISP_KEY = int (80);
        
/* Wrapping of 'TYP_HDUID_KEY' define */
TYP_HDUID_KEY = int (90);
        
/* Wrapping of 'TYP_CKSUM_KEY' define */
TYP_CKSUM_KEY = int (100);
        
/* Wrapping of 'TYP_WCS_KEY' define */
TYP_WCS_KEY = int (110);
        
/* Wrapping of 'TYP_REFSYS_KEY' define */
TYP_REFSYS_KEY = int (120);
        
/* Wrapping of 'TYP_COMM_KEY' define */
TYP_COMM_KEY = int (130);
        
/* Wrapping of 'TYP_CONT_KEY' define */
TYP_CONT_KEY = int (140);
        
/* Wrapping of 'TYP_USER_KEY' define */
TYP_USER_KEY = int (150);
        
/* Wrapping of 'BYTE_IMG' define */
BYTE_IMG = int (8);
        
/* Wrapping of 'SHORT_IMG' define */
SHORT_IMG = int (16);
        
/* Wrapping of 'LONG_IMG' define */
LONG_IMG = int (32);
        
/* Wrapping of 'LONGLONG_IMG' define */
LONGLONG_IMG = int (64);
        
/* Wrapping of 'FLOAT_IMG' define */
FLOAT_IMG = int (-32);
        
/* Wrapping of 'DOUBLE_IMG' define */
DOUBLE_IMG = int (-64);
        
/* Wrapping of 'SBYTE_IMG' define */
SBYTE_IMG = int (10);
        
/* Wrapping of 'USHORT_IMG' define */
USHORT_IMG = int (20);
        
/* Wrapping of 'ULONG_IMG' define */
ULONG_IMG = int (40);
        
/* Wrapping of 'IMAGE_HDU' define */
IMAGE_HDU = int (0);
        
/* Wrapping of 'ASCII_TBL' define */
ASCII_TBL = int (1);
        
/* Wrapping of 'BINARY_TBL' define */
BINARY_TBL = int (2);
        
/* Wrapping of 'ANY_HDU' define */
ANY_HDU = int (-1);
        
/* Wrapping of 'READONLY' define */
READONLY = int (0);
        
/* Wrapping of 'READWRITE' define */
READWRITE = int (1);
        
/* Wrapping of 'MAX_COMPRESS_DIM' define */
MAX_COMPRESS_DIM = int (6);
        
/* Wrapping of 'RICE_1' define */
RICE_1 = int (11);
        
/* Wrapping of 'GZIP_1' define */
GZIP_1 = int (21);
        
/* Wrapping of 'PLIO_1' define */
PLIO_1 = int (31);
        
/* Wrapping of 'HCOMPRESS_1' define */
HCOMPRESS_1 = int (41);
        
/* Wrapping of 'TRUE' define */
TRUE = int (1);
        
/* Wrapping of 'FALSE' define */
FALSE = int (0);
        
/* Wrapping of 'CASESEN' define */
CASESEN = int (1);
        
/* Wrapping of 'CASEINSEN' define */
CASEINSEN = int (0);
        
/* Wrapping of 'GT_ID_ALL_URI' define */
GT_ID_ALL_URI = int (0);
        
/* Wrapping of 'GT_ID_REF' define */
GT_ID_REF = int (1);
        
/* Wrapping of 'GT_ID_POS' define */
GT_ID_POS = int (2);
        
/* Wrapping of 'GT_ID_ALL' define */
GT_ID_ALL = int (3);
        
/* Wrapping of 'GT_ID_REF_URI' define */
GT_ID_REF_URI = int (11);
        
/* Wrapping of 'GT_ID_POS_URI' define */
GT_ID_POS_URI = int (12);
        
/* Wrapping of 'OPT_RM_GPT' define */
OPT_RM_GPT = int (0);
        
/* Wrapping of 'OPT_RM_ENTRY' define */
OPT_RM_ENTRY = int (1);
        
/* Wrapping of 'OPT_RM_MBR' define */
OPT_RM_MBR = int (2);
        
/* Wrapping of 'OPT_RM_ALL' define */
OPT_RM_ALL = int (3);
        
/* Wrapping of 'OPT_GCP_GPT' define */
OPT_GCP_GPT = int (0);
        
/* Wrapping of 'OPT_GCP_MBR' define */
OPT_GCP_MBR = int (1);
        
/* Wrapping of 'OPT_GCP_ALL' define */
OPT_GCP_ALL = int (2);
        
/* Wrapping of 'OPT_MCP_ADD' define */
OPT_MCP_ADD = int (0);
        
/* Wrapping of 'OPT_MCP_NADD' define */
OPT_MCP_NADD = int (1);
        
/* Wrapping of 'OPT_MCP_REPL' define */
OPT_MCP_REPL = int (2);
        
/* Wrapping of 'OPT_MCP_MOV' define */
OPT_MCP_MOV = int (3);
        
/* Wrapping of 'OPT_MRG_COPY' define */
OPT_MRG_COPY = int (0);
        
/* Wrapping of 'OPT_MRG_MOV' define */
OPT_MRG_MOV = int (1);
        
/* Wrapping of 'OPT_CMT_MBR' define */
OPT_CMT_MBR = int (1);
        
/* Wrapping of 'OPT_CMT_MBR_DEL' define */
OPT_CMT_MBR_DEL = int (11);
        
/* Wrapping of 'InputCol' define */
InputCol = int (0);
        
/* Wrapping of 'InputOutputCol' define */
InputOutputCol = int (1);
        
/* Wrapping of 'OutputCol' define */
OutputCol = int (2);
        
/* Wrapping of 'CREATE_DISK_FILE' define */
CREATE_DISK_FILE = int (-106);
        
/* Wrapping of 'OPEN_DISK_FILE' define */
OPEN_DISK_FILE = int (-105);
        
/* Wrapping of 'SKIP_TABLE' define */
SKIP_TABLE = int (-104);
        
/* Wrapping of 'SKIP_IMAGE' define */
SKIP_IMAGE = int (-103);
        
/* Wrapping of 'SKIP_NULL_PRIMARY' define */
SKIP_NULL_PRIMARY = int (-102);
        
/* Wrapping of 'USE_MEM_BUFF' define */
USE_MEM_BUFF = int (-101);
        
/* Wrapping of 'OVERFLOW_ERR' define */
OVERFLOW_ERR = int (-11);
        
/* Wrapping of 'PREPEND_PRIMARY' define */
PREPEND_PRIMARY = int (-9);
        
/* Wrapping of 'SAME_FILE' define */
SAME_FILE = int (101);
        
/* Wrapping of 'TOO_MANY_FILES' define */
TOO_MANY_FILES = int (103);
        
/* Wrapping of 'FILE_NOT_OPENED' define */
FILE_NOT_OPENED = int (104);
        
/* Wrapping of 'FILE_NOT_CREATED' define */
FILE_NOT_CREATED = int (105);
        
/* Wrapping of 'WRITE_ERROR' define */
WRITE_ERROR = int (106);
        
/* Wrapping of 'END_OF_FILE' define */
END_OF_FILE = int (107);
        
/* Wrapping of 'READ_ERROR' define */
READ_ERROR = int (108);
        
/* Wrapping of 'FILE_NOT_CLOSED' define */
FILE_NOT_CLOSED = int (110);
        
/* Wrapping of 'ARRAY_TOO_BIG' define */
ARRAY_TOO_BIG = int (111);
        
/* Wrapping of 'READONLY_FILE' define */
READONLY_FILE = int (112);
        
/* Wrapping of 'MEMORY_ALLOCATION' define */
MEMORY_ALLOCATION = int (113);
        
/* Wrapping of 'BAD_FILEPTR' define */
BAD_FILEPTR = int (114);
        
/* Wrapping of 'NULL_INPUT_PTR' define */
NULL_INPUT_PTR = int (115);
        
/* Wrapping of 'SEEK_ERROR' define */
SEEK_ERROR = int (116);
        
/* Wrapping of 'BAD_URL_PREFIX' define */
BAD_URL_PREFIX = int (121);
        
/* Wrapping of 'TOO_MANY_DRIVERS' define */
TOO_MANY_DRIVERS = int (122);
        
/* Wrapping of 'DRIVER_INIT_FAILED' define */
DRIVER_INIT_FAILED = int (123);
        
/* Wrapping of 'NO_MATCHING_DRIVER' define */
NO_MATCHING_DRIVER = int (124);
        
/* Wrapping of 'URL_PARSE_ERROR' define */
URL_PARSE_ERROR = int (125);
        
/* Wrapping of 'RANGE_PARSE_ERROR' define */
RANGE_PARSE_ERROR = int (126);
        
/* Wrapping of 'SHARED_ERRBASE' define */
SHARED_ERRBASE = int ((150));
        
/* Wrapping of 'SHARED_BADARG' define */
SHARED_BADARG = int (((150) +1));
        
/* Wrapping of 'SHARED_NULPTR' define */
SHARED_NULPTR = int (((150) +2));
        
/* Wrapping of 'SHARED_TABFULL' define */
SHARED_TABFULL = int (((150) +3));
        
/* Wrapping of 'SHARED_NOTINIT' define */
SHARED_NOTINIT = int (((150) +4));
        
/* Wrapping of 'SHARED_IPCERR' define */
SHARED_IPCERR = int (((150) +5));
        
/* Wrapping of 'SHARED_NOMEM' define */
SHARED_NOMEM = int (((150) +6));
        
/* Wrapping of 'SHARED_AGAIN' define */
SHARED_AGAIN = int (((150) +7));
        
/* Wrapping of 'SHARED_NOFILE' define */
SHARED_NOFILE = int (((150) +8));
        
/* Wrapping of 'SHARED_NORESIZE' define */
SHARED_NORESIZE = int (((150) +9));
        
/* Wrapping of 'HEADER_NOT_EMPTY' define */
HEADER_NOT_EMPTY = int (201);
        
/* Wrapping of 'KEY_NO_EXIST' define */
KEY_NO_EXIST = int (202);
        
/* Wrapping of 'KEY_OUT_BOUNDS' define */
KEY_OUT_BOUNDS = int (203);
        
/* Wrapping of 'VALUE_UNDEFINED' define */
VALUE_UNDEFINED = int (204);
        
/* Wrapping of 'NO_QUOTE' define */
NO_QUOTE = int (205);
        
/* Wrapping of 'BAD_KEYCHAR' define */
BAD_KEYCHAR = int (207);
        
/* Wrapping of 'BAD_ORDER' define */
BAD_ORDER = int (208);
        
/* Wrapping of 'NOT_POS_INT' define */
NOT_POS_INT = int (209);
        
/* Wrapping of 'NO_END' define */
NO_END = int (210);
        
/* Wrapping of 'BAD_BITPIX' define */
BAD_BITPIX = int (211);
        
/* Wrapping of 'BAD_NAXIS' define */
BAD_NAXIS = int (212);
        
/* Wrapping of 'BAD_NAXES' define */
BAD_NAXES = int (213);
        
/* Wrapping of 'BAD_PCOUNT' define */
BAD_PCOUNT = int (214);
        
/* Wrapping of 'BAD_GCOUNT' define */
BAD_GCOUNT = int (215);
        
/* Wrapping of 'BAD_TFIELDS' define */
BAD_TFIELDS = int (216);
        
/* Wrapping of 'NEG_WIDTH' define */
NEG_WIDTH = int (217);
        
/* Wrapping of 'NEG_ROWS' define */
NEG_ROWS = int (218);
        
/* Wrapping of 'COL_NOT_FOUND' define */
COL_NOT_FOUND = int (219);
        
/* Wrapping of 'BAD_SIMPLE' define */
BAD_SIMPLE = int (220);
        
/* Wrapping of 'NO_SIMPLE' define */
NO_SIMPLE = int (221);
        
/* Wrapping of 'NO_BITPIX' define */
NO_BITPIX = int (222);
        
/* Wrapping of 'NO_NAXIS' define */
NO_NAXIS = int (223);
        
/* Wrapping of 'NO_NAXES' define */
NO_NAXES = int (224);
        
/* Wrapping of 'NO_XTENSION' define */
NO_XTENSION = int (225);
        
/* Wrapping of 'NOT_ATABLE' define */
NOT_ATABLE = int (226);
        
/* Wrapping of 'NOT_BTABLE' define */
NOT_BTABLE = int (227);
        
/* Wrapping of 'NO_PCOUNT' define */
NO_PCOUNT = int (228);
        
/* Wrapping of 'NO_GCOUNT' define */
NO_GCOUNT = int (229);
        
/* Wrapping of 'NO_TFIELDS' define */
NO_TFIELDS = int (230);
        
/* Wrapping of 'NO_TBCOL' define */
NO_TBCOL = int (231);
        
/* Wrapping of 'NO_TFORM' define */
NO_TFORM = int (232);
        
/* Wrapping of 'NOT_IMAGE' define */
NOT_IMAGE = int (233);
        
/* Wrapping of 'BAD_TBCOL' define */
BAD_TBCOL = int (234);
        
/* Wrapping of 'NOT_TABLE' define */
NOT_TABLE = int (235);
        
/* Wrapping of 'COL_TOO_WIDE' define */
COL_TOO_WIDE = int (236);
        
/* Wrapping of 'COL_NOT_UNIQUE' define */
COL_NOT_UNIQUE = int (237);
        
/* Wrapping of 'BAD_ROW_WIDTH' define */
BAD_ROW_WIDTH = int (241);
        
/* Wrapping of 'UNKNOWN_EXT' define */
UNKNOWN_EXT = int (251);
        
/* Wrapping of 'UNKNOWN_REC' define */
UNKNOWN_REC = int (252);
        
/* Wrapping of 'END_JUNK' define */
END_JUNK = int (253);
        
/* Wrapping of 'BAD_HEADER_FILL' define */
BAD_HEADER_FILL = int (254);
        
/* Wrapping of 'BAD_DATA_FILL' define */
BAD_DATA_FILL = int (255);
        
/* Wrapping of 'BAD_TFORM' define */
BAD_TFORM = int (261);
        
/* Wrapping of 'BAD_TFORM_DTYPE' define */
BAD_TFORM_DTYPE = int (262);
        
/* Wrapping of 'BAD_TDIM' define */
BAD_TDIM = int (263);
        
/* Wrapping of 'BAD_HEAP_PTR' define */
BAD_HEAP_PTR = int (264);
        
/* Wrapping of 'BAD_HDU_NUM' define */
BAD_HDU_NUM = int (301);
        
/* Wrapping of 'BAD_COL_NUM' define */
BAD_COL_NUM = int (302);
        
/* Wrapping of 'NEG_FILE_POS' define */
NEG_FILE_POS = int (304);
        
/* Wrapping of 'NEG_BYTES' define */
NEG_BYTES = int (306);
        
/* Wrapping of 'BAD_ROW_NUM' define */
BAD_ROW_NUM = int (307);
        
/* Wrapping of 'BAD_ELEM_NUM' define */
BAD_ELEM_NUM = int (308);
        
/* Wrapping of 'NOT_ASCII_COL' define */
NOT_ASCII_COL = int (309);
        
/* Wrapping of 'NOT_LOGICAL_COL' define */
NOT_LOGICAL_COL = int (310);
        
/* Wrapping of 'BAD_ATABLE_FORMAT' define */
BAD_ATABLE_FORMAT = int (311);
        
/* Wrapping of 'BAD_BTABLE_FORMAT' define */
BAD_BTABLE_FORMAT = int (312);
        
/* Wrapping of 'NO_NULL' define */
NO_NULL = int (314);
        
/* Wrapping of 'NOT_VARI_LEN' define */
NOT_VARI_LEN = int (317);
        
/* Wrapping of 'BAD_DIMEN' define */
BAD_DIMEN = int (320);
        
/* Wrapping of 'BAD_PIX_NUM' define */
BAD_PIX_NUM = int (321);
        
/* Wrapping of 'ZERO_SCALE' define */
ZERO_SCALE = int (322);
        
/* Wrapping of 'NEG_AXIS' define */
NEG_AXIS = int (323);
        
/* Wrapping of 'NOT_GROUP_TABLE' define */
NOT_GROUP_TABLE = int (340);
        
/* Wrapping of 'HDU_ALREADY_MEMBER' define */
HDU_ALREADY_MEMBER = int (341);
        
/* Wrapping of 'MEMBER_NOT_FOUND' define */
MEMBER_NOT_FOUND = int (342);
        
/* Wrapping of 'GROUP_NOT_FOUND' define */
GROUP_NOT_FOUND = int (343);
        
/* Wrapping of 'BAD_GROUP_ID' define */
BAD_GROUP_ID = int (344);
        
/* Wrapping of 'TOO_MANY_HDUS_TRACKED' define */
TOO_MANY_HDUS_TRACKED = int (345);
        
/* Wrapping of 'HDU_ALREADY_TRACKED' define */
HDU_ALREADY_TRACKED = int (346);
        
/* Wrapping of 'BAD_OPTION' define */
BAD_OPTION = int (347);
        
/* Wrapping of 'IDENTICAL_POINTERS' define */
IDENTICAL_POINTERS = int (348);
        
/* Wrapping of 'BAD_GROUP_ATTACH' define */
BAD_GROUP_ATTACH = int (349);
        
/* Wrapping of 'BAD_GROUP_DETACH' define */
BAD_GROUP_DETACH = int (350);
        
/* Wrapping of 'BAD_I2C' define */
BAD_I2C = int (401);
        
/* Wrapping of 'BAD_F2C' define */
BAD_F2C = int (402);
        
/* Wrapping of 'BAD_INTKEY' define */
BAD_INTKEY = int (403);
        
/* Wrapping of 'BAD_LOGICALKEY' define */
BAD_LOGICALKEY = int (404);
        
/* Wrapping of 'BAD_FLOATKEY' define */
BAD_FLOATKEY = int (405);
        
/* Wrapping of 'BAD_DOUBLEKEY' define */
BAD_DOUBLEKEY = int (406);
        
/* Wrapping of 'BAD_C2I' define */
BAD_C2I = int (407);
        
/* Wrapping of 'BAD_C2F' define */
BAD_C2F = int (408);
        
/* Wrapping of 'BAD_C2D' define */
BAD_C2D = int (409);
        
/* Wrapping of 'BAD_DATATYPE' define */
BAD_DATATYPE = int (410);
        
/* Wrapping of 'BAD_DECIM' define */
BAD_DECIM = int (411);
        
/* Wrapping of 'NUM_OVERFLOW' define */
NUM_OVERFLOW = int (412);
        
/* Wrapping of 'DATA_COMPRESSION_ERR' define */
DATA_COMPRESSION_ERR = int (413);
        
/* Wrapping of 'DATA_DECOMPRESSION_ERR' define */
DATA_DECOMPRESSION_ERR = int (414);
        
/* Wrapping of 'NO_COMPRESSED_TILE' define */
NO_COMPRESSED_TILE = int (415);
        
/* Wrapping of 'BAD_DATE' define */
BAD_DATE = int (420);
        
/* Wrapping of 'PARSE_SYNTAX_ERR' define */
PARSE_SYNTAX_ERR = int (431);
        
/* Wrapping of 'PARSE_BAD_TYPE' define */
PARSE_BAD_TYPE = int (432);
        
/* Wrapping of 'PARSE_LRG_VECTOR' define */
PARSE_LRG_VECTOR = int (433);
        
/* Wrapping of 'PARSE_NO_OUTPUT' define */
PARSE_NO_OUTPUT = int (434);
        
/* Wrapping of 'PARSE_BAD_COL' define */
PARSE_BAD_COL = int (435);
        
/* Wrapping of 'PARSE_BAD_OUTPUT' define */
PARSE_BAD_OUTPUT = int (436);
        
/* Wrapping of 'ANGLE_TOO_BIG' define */
ANGLE_TOO_BIG = int (501);
        
/* Wrapping of 'BAD_WCS_VAL' define */
BAD_WCS_VAL = int (502);
        
/* Wrapping of 'WCS_ERROR' define */
WCS_ERROR = int (503);
        
/* Wrapping of 'BAD_WCS_PROJ' define */
BAD_WCS_PROJ = int (504);
        
/* Wrapping of 'NO_WCS_KEY' define */
NO_WCS_KEY = int (505);
        
/* Wrapping of 'APPROX_WCS_KEY' define */
APPROX_WCS_KEY = int (506);
        
/* Wrapping of 'NO_CLOSE_ERROR' define */
NO_CLOSE_ERROR = int (999);
        
/* Wrapping of 'NGP_ERRBASE' define */
NGP_ERRBASE = int ((360));
        
/* Wrapping of 'NGP_OK' define */
NGP_OK = int ((0));
        
/* Wrapping of 'NGP_NO_MEMORY' define */
NGP_NO_MEMORY = int (((360) +0));
        
/* Wrapping of 'NGP_READ_ERR' define */
NGP_READ_ERR = int (((360) +1));
        
/* Wrapping of 'NGP_NUL_PTR' define */
NGP_NUL_PTR = int (((360) +2));
        
/* Wrapping of 'NGP_EMPTY_CURLINE' define */
NGP_EMPTY_CURLINE = int (((360) +3));
        
/* Wrapping of 'NGP_UNREAD_QUEUE_FULL' define */
NGP_UNREAD_QUEUE_FULL = int (((360) +4));
        
/* Wrapping of 'NGP_INC_NESTING' define */
NGP_INC_NESTING = int (((360) +5));
        
/* Wrapping of 'NGP_ERR_FOPEN' define */
NGP_ERR_FOPEN = int (((360) +6));
        
/* Wrapping of 'NGP_EOF' define */
NGP_EOF = int (((360) +7));
        
/* Wrapping of 'NGP_BAD_ARG' define */
NGP_BAD_ARG = int (((360) +8));
        
/* Wrapping of 'NGP_TOKEN_NOT_EXPECT' define */
NGP_TOKEN_NOT_EXPECT = int (((360) +9));
        
/****** ENUM CONSTANTS ******/

/****** STRUCTURES ******/

/****** FUNCTIONS ******/
  
extern __ffexist;
cfitsio_file_exists = __ffexist;
/* DOCUMENT exist = cfitsio_file_exists(filename);
   
   Test if the input file or a compressed version of the file (with 
   a .gz, .Z, .z, or .zip extension) exists on disk. The returned value
   of the 'exists' parameter will have 1 of the 4 following values:

   2: the file does not exist, but a compressed version does exist 
   1: the disk file does exist 
   0: neither the file nor a compressed version of the file exist 
   -1: the input file name is not a disk file (could be a ftp, http, 
   smem, or mem file, or a file piped in on the STDIN stream)
   
   C-prototype:
   ------------
   int ffexist  (const char *infile ,int *exists ,int *status)
*/
  
extern __ffurlt;
cfitsio_url_type = __ffurlt;
/* DOCUMENT urlt = cfitsio_url_type(fh)

   Return the file type (e.g. "file://", "ftp://" ...)
   of the opened fh FITS file.

   * C-prototype:
   ------------
   int ffurlt  (fitsfile *fptr ,char *urlType ,int *status)
*/
  
extern __ffopen;
/* DOCUMENT  __ffopen( filename, iomode )
  * C-prototype:
    ------------
    int ffopen  (fitsfile **fptr ,const char *filename ,int iomode ,int *status)
*/

extern __ffinit;
cfitsio_create_file = __ffinit;
/* DOCUMENT fh = cfitsio_create_file(filename)

   Create and open a new empty output FITS file.
   
   * C-prototype:
   ------------
   int ffinit  (fitsfile **fptr ,const char *filename ,int *status)
*/
  
extern __ffclos;
cfitsio_close_file = __ffclos;
/* DOCUMENT cfitsio_close_file(fh)
            cfitsio_delete_file(fh)

   Close previouly opened FITS file. The first routine simply close the
   file, whereas the second one also DELETE THE FILE.
   
   * C-prototype:
   ------------
   int ffclos  (fitsfile *fptr ,int *status)
*/

extern __ffdelt;
cfitsio_delete_file = __ffdelt;
/* DOCUMENT cfitsio_close_file(fh)
            cfitsio_delete_file(fh)

   Close previouly opened FITS file. The first routine simply close the
   file, whereas the second one also DELETE THE FILE.
   
   * C-prototype:
   ------------
   int ffdelt  (fitsfile *fptr ,int *status)
*/

extern __ffflnm;
cfitsio_file_name = __ffflnm;
/* DOCUMENT filename = cfitsio_file_name(fh)
   
   Return the name of the opened fh FITS file.
   
   * C-prototype:
   ------------
   int ffflnm  (fitsfile *fptr ,char *filename ,int *status)
*/

extern __ffflmd;
cfitsio_file_mode = __ffflmd;
/* DOCUMENT filemode = cfitsio_file_name(fh)
   
   Return the name, I/O mode (READONLY or READWRITE).
   
   * C-prototype:
   ------------
   int ffflmd  (fitsfile *fptr ,int *filemode ,int *status)
*/

extern __ffvers;
cfitsio_get_version = __ffvers;
/* DOCUMENT version = cfitsio_get_version();
            
   Return the current version of the CFITSIO lib used.
   
   * C-prototype:
   ------------
   float ffvers  (float *version)
*/

extern __ffgerr;
cfitsio_get_errstatus = __ffgerr;
/* DOCUMENT errmsg = cfitsio_get_errstatus(status)

   Return a string ERROR_MSG containing a human
   error message corresponding to STATUS.

   * C-prototype:
   ------------
   void ffgerr  (int status ,char *errtext)
*/

extern __ffgmsg;
cfitsio_read_errmsg = __ffgmsg;
/* DOCUMENT errmsg = cfitsio_read_errmsg();
            
   Return the top (oldest) 80-character error message from the internal
   CFITSIO stack of error messages and shift any remaining messages on
   the stack up one level. Call this routine repeatedly to get each message
   in sequence. The function returns a null error message when the error
   stack is empty.
 
   * C-prototype:
   ------------
   int ffgmsg  (char *err_message)
*/

extern __ffpky;
/* DOCUMENT  __ffpky( fh, datatype, keyname, pointer value, comm)
  * C-prototype:
    ------------
    int ffpky  (fitsfile *fptr ,int datatype ,char *keyname ,void *value ,char *comm ,int *status)
*/

extern __ffpcom;
cfitsio_write_comment = __ffpcom;
/* DOCUMENT cfitsio_write_comment(&fh,comment)
            cfitsio_write_history(&fh,history)

   Write (append) a COMMENT or HISTORY keyword to the CHU. The
   comment or history string will be continued over multiple
   keywords if it is longer than 70 characters.
   
   * C-prototype:
   ------------
   int ffpcom  (fitsfile *fptr ,const char *comm ,int *status)
*/

extern __ffpunt;
cfitsio_write_key_unit = __ffpunt;
/* DOCUMENT unit = cfitsio_read_key_unit(&fh,keyname)
            cfitsio_write_key_unit(&fh,keyname,unit)

   Read/Write the physical units string from an existing keyword. This
   routine uses a local convention, shown in the following example,
   in which the keyword units are enclosed in square brackets in the
   beginning of the keyword comment field. A null string is returned
   if no units are defined for the keyword.

   VELOCITY=	12.3 / [km/s] orbital speed

   * C-prototype:
   ------------
   int ffpunt  (fitsfile *fptr ,char *keyname ,char *unit ,int *status)
*/

extern __ffphis;
cfitsio_write_history = __ffphis;
/* DOCUMENT cfitsio_write_comment(&fh,comment)
            cfitsio_write_history(&fh,history)

   Write (append) a COMMENT or HISTORY keyword to the CHU. The
   comment or history string will be continued over multiple
   keywords if it is longer than 70 characters.

   * C-prototype:
   ------------
   int ffphis  (fitsfile *fptr ,const char *history ,int *status)
*/

extern __ffpdat;
cfitsio_write_date = __ffpdat;
/* DOCUMENT cfitsio_write_date(&fh)

   Write the DATE keyword to the CHU. The keyword value will contain
   the current system date as a character string in 
   yyyy-mm-ddThh:mm:ss format. If a DATE keyword already existsi
   n the header, then this routine will simply update the keyword
   value with the current date.
   
   * C-prototype:
   ------------
   int ffpdat  (fitsfile *fptr ,int *status)
*/

extern __ffpcks;
cfitsio_write_chksum = __ffpcks;
/* DOCUMENT cfitsio_write_chksum(&fh)

   Compute and write the DATASUM and CHECKSUM keyword values for the
   CHDU into the current header. If the keywords already exist, their
   values will be updated only if necessary (i.e., if the file has been
   modified since the original keyword values were computed).
   
   * C-prototype:
   ------------
   int ffpcks (fitsfile *fptr, > int *status)
*/

extern __ffptdm;
/* DOCUMENT  __ffptdm( &fh, colnum , naxis , naxes )
  * C-prototype:
    ------------
    int ffptdm  (fitsfile *fptr ,int colnum ,int naxis ,long naxes ,int *status)
*/

extern __ffghsp;
/* DOCUMENT  nexist = __ffghsp( fh, &nmore)
  * C-prototype:
    ------------
    int ffghsp  (fitsfile *fptr ,int *nexist ,int *nmore ,int *status)
*/

extern __ffgnxk;
/* DOCUMENT  __ffgnxk( fh, inclist, ninc, exclist, nexc )
  * C-prototype:
    ------------
    int ffgnxk  (fitsfile *fptr ,char **inclist ,int ninc ,char **exclist ,int nexc ,char *card ,int *status)
*/

extern __ffgrec;
cfitsio_read_record = __ffgrec;
/* DOCUMENT card = cfitsio_read_record(&fh,keynum)

   Return the nth header record in the CHU. The first keyword in the
   header is at keynum = 1; if keynum = 0 then these routines simply
   reset the internal CFITSIO pointer to the beginning of the header so
   that subsequent keyword operations will start at the top of the header
   (e.g., prior to searching for keywords using wild cards in the
   keyword name). The routine returns the entire 80-character header
   record (with trailing blanks truncated).
   
   * C-prototype:
   ------------
   int ffgrec  (fitsfile *fptr ,int nrec ,char *card ,int *status)
*/

extern __ffgcrd;
cfitsio_read_card = __ffgcrd;
/* DOCUMENT card = cfitsio_read_card(&fh,keyname)

   Return the specified keyword. The routine returns the entire
   80-character header record of the keyword, with any trailing blank
   characters stripped off.

   * C-prototype:
   ------------
   int ffgcrd  (fitsfile *fptr ,char *keyname ,char *card ,int *status)
*/

extern __ffgunt;
cfitsio_read_key_unit = __ffgunt;
/* DOCUMENT unit = cfitsio_read_key_unit(&fh, keyname)
            cfitsio_write_key_unit(&fh, keyname, unit)

   Read/Write the physical units string from an existing keyword. This
   routine uses a local convention, shown in the following example,
   in which the keyword units are enclosed in square brackets in the
   beginning of the keyword comment field. A null string is returned
   if no units are defined for the keyword.

   VELOCITY=	12.3 / [km/s] orbital speed

   * C-prototype:
   ------------
   int ffgunt  (fitsfile *fptr ,char *keyname ,char *unit ,int *status)
*/

extern __ffgky;
/* DOCUMENT  __ffgky( fh, keytype, keyname, *value (pointer), *comment )
  * C-prototype:
    ------------
    int ffgky  (fitsfile *fptr ,int datatype ,char *keyname ,void *value ,char *comm ,int *status)
*/

extern __ffgtdm;
/* DOCUMENT  ffgtdm( fh, colnum, maxdim, &naxis, &naxes )
  * C-prototype:
    ------------
    int ffgtdm  (fitsfile *fptr ,int colnum ,int maxdim ,int *naxis ,long naxes ,int *status)
*/

extern __ffuky;
/* DOCUMENT  __ffuky( fh, datatype, keyname, value (pointer), comm )
  * C-prototype:
    ------------
    int ffuky  (fitsfile *fptr ,int datatype ,char *keyname ,void *value ,char *comm ,int *status)
*/

extern __ffukyu;
/* DOCUMENT  __ffuky( fh, keyname, comm )
  * C-prototype:
    ------------
    int ffukyu (fitsfile *fptr, char *keyname, char *comment, int *status)
*/

extern __ffmnam;
cfitsio_modify_name = __ffmnam;
/* DOCUMENT cfitsio_modify_name(&fh, keyname, keynewname)

   Rename an existing keyword, preserving the current value
   and comment fields.
   
   * C-prototype:
   ------------
   int ffmnam  (fitsfile *fptr ,char *oldname ,char *newname ,int *status)
*/

extern __ffmcom;
cfitsio_modify_comment = __ffmcom;
/* DOCUMENT cfitsio_modify_comment(&fh, keyname, comment)

   Modify (overwrite) the comment field of an existing keyword.

   * C-prototype:
   ------------
   int ffmcom  (fitsfile *fptr ,char *keyname ,char *comm ,int *status)
*/

extern __ffdkey;
cfitsio_delete_key = __ffdkey;
/* DOCUMENT cfitsio_delete_record(&fh, keynum)
            cfitsio_delete_key(&fh, keyname)

   Delete a keyword record. The space occupied by the keyword is
   reclaimed by moving all the following header records up one row
   in the header. The first routine deletes a keyword at a specified
   position in the header (the first keyword is at position 1),
   whereas the second routine deletes a specifically named keyword.
   Wild card characters may be used when specifying the name of the
   keyword to be deleted.

   * C-prototype:
   ------------
   int ffdkey  (fitsfile *fptr ,char *keyname ,int *status)
*/

extern __ffdrec;
cfitsio_delete_record = __ffdrec;
/* DOCUMENT cfitsio_delete_record(&fh, keynum)
            cfitsio_delete_key(&fh, keyname)

   Delete a keyword record. The space occupied by the keyword is
   reclaimed by moving all the following header records up one row
   in the header. The first routine deletes a keyword at a specified
   position in the header (the first keyword is at position 1),
   whereas the second routine deletes a specifically named keyword.
   Wild card characters may be used when specifying the name of the
   keyword to be deleted.

   * C-prototype:
   ------------
   int ffdrec  (fitsfile *fptr ,int keypos ,int *status)
*/

extern __ffghdn;
cfitsio_get_hdu_num = __ffghdn;
/* DOCUMENT num = cfitsio_get_hdu_num(fh)
   
   Return the number of the current HDU of FH.
   (where the primary array=1)

   * C-prototype:
   ------------
   int ffghdn  (fitsfile *fptr ,int *chdunum)
*/

extern __ffghdt;
cfitsio_get_hdu_type = __ffghdt;
/* DOCUMENT type = cfitsio_get_hdu_type(&fh)
   
   Return the type of the current HDU of FH.
   The possible value for HDUTYPE are the integer
   IMAGE_HDU, ASCII_TBL or BINARY_TBL.

   * C-prototype:
   ------------
   int ffghdt  (fitsfile *fptr ,int *exttype ,int *status)
*/

extern __ffdhdu;
cfitsio_delete_hdu = __ffdhdu;
/* DOCUMENT cfitsio_delete_hdu(&fh)

   Delete the CHDU in the FITS file. Any following HDUs will be shifted forward
   in the file, to fill in the gap created by the deleted HDU. In the case of
   deleting the primary array (the first HDU in the file) then the current primary
   array will be replace by a null primary array containing the minimum set of
   required keywords and no data. If there are more extensions in the file following
   the one that is deleted, then the the CHDU will be redefined to point to the
   following extension.

   * C-prototype:
   ------------
   int ffdhdu   (fitsfile *fptr, int *hdutype, int *status)
*/

extern __ffgidt;
cfitsio_get_img_type = __ffgidt;
/* DOCUMENT bitpix = cfitsio_get_img_type(&fh)
       
   Return the parameter BITPIX of the image in the current HDU.
    
   * C-prototype:
   ------------
   int ffgidt  (fitsfile *fptr ,int *imgtype ,int *status)
*/

extern __ffgidm;
cfitsio_get_img_dim = __ffgidm;
/* DOCUMENT naxis = cfitsio_get_img_dim(fh)
       
   Return the parameter NAXIS of the image in the current HDU.
    
   * C-prototype:
   ------------
   int ffgidm  (fitsfile *fptr ,int *naxis ,int *status)
*/

extern __ffgisz;
cfitsio_get_img_size = __ffgisz;
/* DOCUMENT daxes = cfitsio_get_img_size(fh)
       
   Return the parameter DAXES of the image in the current HDU.
   DAXES replace the parameters NAXIS and NAXES.
   DAXES is an array of the form :
   [naxis, naxes(1), naxes(2), ... naxes(naxis)]
   i.e a standart yorick dimension arrray. 

   * C-prototype:
   ------------
   int ffgisz  (fitsfile *fptr ,int nlen ,long *naxes ,int *status)
*/

extern __ffmahd;
cfitsio_movabs_hdu = __ffmahd;
/* DOCUMENT cfitsio_movabs_hdu(fh,hdunum)
       
   Move to the specified absolute HDU number (starting for
   1 for the first HDU).
   
   If no HDU are found, an explicit error occure.
   
   * C-prototype:
   ------------
   int ffmahd  (fitsfile *fptr ,int hdunum ,int *exttype ,int *status)
*/

extern __ffmrhd;
cfitsio_movrel_hdu = __ffmrhd;
/* DOCUMENT cfitsio_movrel_hdu(fh,hdumov)

   Move a relative HDU number forward or backward (starting for
   1 for the first HDU).
   
   If no HDU are found, an explicit error occure.

   * C-prototype:
   ------------
   int ffmrhd  (fitsfile *fptr ,int hdumov ,int *exttype ,int *status)
*/

extern __ffmnhd;
cfitsio_movnam_hdu = __ffmnhd;
/* DOCUMENT cfitsio_movnam_hdu(fh,hdutype,extname)
       
   Move to the first HDU which has the specified EXTNAME
   (or HDUNAME keyword value).
   The HDUTYPE parameter may have a value of IMAGE_HDU,
   ASCII_TBL,BINARY_TBL or ANY_HDU where ANY_HDU means that only
   the extname value will be used.
   
   If no HDU are found, an explicit error occure.

   * C-prototype:
   ------------
   int ffmnhd  (fitsfile *fptr ,int exttype ,char *hduname ,int hduvers ,int *status)
*/

extern __ffthdu;
cfitsio_get_num_hdus = __ffthdu;
/* DOCUMENT cfitsio_get_num_hdus(fh)
       
   Return the total number of HDUs in the FITS file fh.
   The current HDU remain unchanged.

   * C-prototype:
   ------------
   int ffthdu  (fitsfile *fptr ,int *nhdu ,int *status)
*/

extern __ffcrim;
/* DOCUMENT  __ffcrim( fh, bitpix, naxis, naxes )
  * C-prototype:
    ------------
    int ffcrim  (fitsfile *fptr ,int bitpix ,int naxis ,long *naxes ,int *status)
*/

extern __ffcrtb;
/* DOCUMENT  __ffcrtb( fh, tbltype, naxis2, tfield, ttype, tform, unit, extname )
  * C-prototype:
    ------------
    int ffcrtb  (fitsfile *fptr ,int tbltype ,long naxis2 ,int tfields ,char **ttype ,char **tform ,char **tunit ,char *extname ,int *status)
*/

extern __ffgcno;
/* DOCUMENT  __ffgcno( fh, casesen, templt, &colnum )
  * C-prototype:
    ------------
    int ffgcno  (fitsfile *fptr ,int casesen ,char *templt ,int *colnum ,int *status)
*/

extern __ffgcnn;
/* DOCUMENT  __ffgcnn( fh, casesen, templt, &colname, &colnum )
  * C-prototype:
    ------------
    int ffgcnn  (fitsfile *fptr ,int casesen ,char *templt ,char *colname ,int *colnum ,int *status)
*/

extern __ffgtcl;
/* DOCUMENT  __ffgtcl( fh, colnum, &coltype, &repeat, &width )
  * C-prototype:
    ------------
    int ffgtcl  (fitsfile *fptr ,int colnum ,int *typecode ,long *repeat ,long *width ,int *status)
*/

extern __ffgncl;
cfitsio_get_num_cols = __ffgncl;
/* DOCUMENT ncols = cfitsio_get_num_cols(fh)

   cfitsio_get_num_cols, fh, ncols
       
   Get the number of rows or columns in the current FITS table. The number
   of rows is given by the NAXIS2 keyword and the number of columns is given
   by the TFIELDS keyword in the header of the table. 

   * C-prototype:
   ------------
   int ffgncl  (fitsfile *fptr ,int *ncols ,int *status)
*/

extern __ffgnrw;
cfitsio_get_num_rows = __ffgnrw;
/* DOCUMENT nrows = cfitsio_get_num_rows(fh)
   
   Get the number of rows or columns in the current FITS table. The number
   of rows is given by the NAXIS2 keyword and the number of columns is given
   by the TFIELDS keyword in the header of the table. 

   * C-prototype:
   ------------
   int ffgnrw  (fitsfile *fptr ,long *nrows ,int *status)
*/

extern __ffgpxv;
/* DOCUMENT  __ffgpxv( fh, datatype, fpixel, nelem, nulval (pointer), &array (pointer), &anynul )
  * C-prototype:
    ------------
    int ffgpxv  (fitsfile *fptr ,int datatype ,long *firstpix ,long nelem ,void *nulval ,void *array ,int *anynul ,int *status)
*/

extern __ffgsv;
/* DOCUMENT  __ffgsv( fh, datatype, fpixel, lpixel, inc, nulval (pointer), &array (pointer), &anynul )
  * C-prototype:
    ------------
    int ffgsv  (fitsfile *fptr ,int datatype ,long *blc ,long *trc ,long *inc ,void *nulval ,void *array ,int *anynul ,int *status)
*/

extern __ffgpv;
/* DOCUMENT  __ffgpv( fh, datatype, felem, nelem, nulval (pointer), &array (pointer), &anynul )
  * C-prototype:
    ------------
    int ffgpv  (fitsfile *fptr ,int datatype ,long felem ,long nelem ,void *nulval ,void *array ,int *anynul ,int *status)
*/

extern __ffgcv;
/* DOCUMENT  __ffgcv( fh, coltype, colnum, firstrow, firstelem, nelem, nulval (pointer), &array (pointer), &anynul )
  * C-prototype:
    ------------
    int ffgcv  (fitsfile *fptr ,int datatype ,int colnum ,long firstrow ,long firstelem ,long nelem ,void *nulval ,void *array ,int *anynul ,int *status)
*/

extern __ffppx;
/* DOCUMENT  __ffppx( fh, datatype, fpixels, nelements, arrayc (pointer) )
  * C-prototype:
    ------------
    int ffppx  (fitsfile *fptr ,int datatype ,long *firstpix ,long nelem ,void *array ,int *status)
*/

extern __ffpcl;
/* DOCUMENT  __ffpcl( fh, datatype, colnum, firstrow, firstelem, nelem, arrayc (pointer) )
  * C-prototype:
    ------------
    int ffpcl  (fitsfile *fptr ,int datatype ,int colnum ,long firstrow ,long firstelem ,long nelem ,void *array ,int *status)
*/

extern __ffirow;
cfitsio_insert_rows = __ffirow;
/* DOCUMENT cfitsio_insert_rows(&fh,firstrow,nrows)

   Insert rows in an ASCII or binary table. When inserting rows
   all the rows following row FROW are shifted down by NROWS rows. 

   * C-prototype:
   ------------
   int ffirow  (fitsfile *fptr ,long firstrow ,long nrows ,int *status)
*/

extern __ffdrow;
cfitsio_delete_rows = __ffdrow;
/* DOCUMENT cfitsio_delete_rows(&fh,firstrow,nrows)

   Delete rows in an ASCII or binary table. When deleting rows
   all the rows following row FROW are shifted down by NROWS rows.

   * C-prototype:
   ------------
   int ffdrow  (fitsfile *fptr ,long firstrow ,long nrows ,int *status)
*/

extern __ffdrws;
cfitsio_delete_rowlist = __ffdrws;
/* DOCUMENT cfitsio_delete_rowlist(fh,rowlist)
   
   Delete a list of row in an ASCII or binary table.
   The input list of rows to delete must be sorted in ascending order.

   * C-prototype:
   ------------
   int ffdrws  (fitsfile *fptr ,long *rownum ,long nrows ,int *status)
*/

extern __fficol;
cfitsio_insert_col = __fficol;
/* DOCUMENT cfitsio_insert_col(&fh,colnum,ttype,tform)
            cfitsio_insert_cols(&fh,colnum,ttype,tform)
            cfitsio_delete_col(&fh,colnum)

   Insert or delete column(s) in an ASCII or binary table.
   When inserting, COLNUM specifies the column number that the
   (first) new column should occupy in the table. NCOLS
   specifies how many columns are to be inserted. Any existing
   columns from this position and higher are shifted over to
   allow room for the new column(s).

   * C-prototype:
   ------------
   int fficol  (fitsfile *fptr ,int numcol ,char *ttype ,char *tform ,int *status)
*/

extern __fficls;
/* DOCUMENT  __fficls( fh, colnum, ncols, ttype, tform )
  * C-prototype:
    ------------
    int fficls  (fitsfile *fptr ,int firstcol ,int ncols ,char **ttype ,char **tform ,int *status)
*/

extern __ffmvec;
cfitsio_modify_vector_len = __ffmvec;
/* DOCUMENT cfitsio_modify_vector_len(&fh, colnum, newveclen)

   Modify the vector length of a binary table column (e.g., change
   a column from TFORMn = '1E' to '20E'). The vector length may be
   increased or decreased from the current value.

   * C-prototype:
   ------------
   int ffmvec  (fitsfile *fptr ,int colnum ,long newveclen ,int *status)
*/
  
extern __ffdcol;
cfitsio_delete_col = __ffdcol;
/* DOCUMENT cfitsio_insert_col(&fh,colnum,ttype,tform)
            cfitsio_insert_cols(&fh,colnum,ttype,tform)
            cfitsio_delete_col(&fh,colnum)

   Insert or delete column(s) in an ASCII or binary table.
   When inserting, COLNUM specifies the column number that the
   (first) new column should occupy in the table. NCOLS
   specifies how many columns are to be inserted. Any existing
   columns from this position and higher are shifted over to
   allow room for the new column(s).
   
   * C-prototype:
   ------------
   int ffdcol  (fitsfile *fptr ,int numcol ,int *status)
*/
