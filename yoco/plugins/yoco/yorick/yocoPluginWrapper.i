
/**** MODULE   'yocoPlugin' ****/
/****                 contains :                         ****/
/****    o DEFINE CONSTANTS                                ****/
/****    o ENUM CONSTANTS                                ****/
/****    o STRUCTURES                                    ****/
/****    o FUNCTIONS                                     ****/


if (!is_void(plug_in)) plug_in, "yocoPlugin";
write,"yocoPlugin plugin loaded";


/****** DEFINE CONSTANTS (numerical ones only) ******/

/****** ENUM CONSTANTS ******/

/****** STRUCTURES ******/

/****** FUNCTIONS ******/

/* 
 * Wrapping of 'yocoSystem' function */   
  
extern __yocoSystem;
/* PROTOTYPE
    int  yocoSystem( string )
*/
/* DOCUMENT  yocoSystem( string )
  * C-prototype:
    ------------
    int yocoSystem  (char *command)
*/
