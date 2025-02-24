curdir = get_cwd();
include,curdir+"../packages/yocoStr.i";
include,curdir+"../packages/yocoLog.i";
include,curdir+"../packages/yocoType.i";
include,curdir+"../packages/yocoMath.i";
include,curdir+"../packages/yocoDoc.i";

// Generate functions documentation from yorick packages
remove,curdir+"../packages/packages_functions.txt";
remove,curdir+"../packages/packages_functions.tex";

yocoDocListFunctions,tex=1,dir=curdir+"../packages/";
yocoDocListFunctions,tex=0,dir=curdir+"../packages/";

rename,curdir+"../packages/packages_functions.tex",
    curdir+"packages_functions.tex";
rename,curdir+"../packages/packages_functions.txt",
    curdir+"packages_functions.txt";


// Generate functions documentation from cfitsio plugin
remove,curdir+"../plugins/cfitsio/yorick/yorick_functions.txt";
remove,curdir+"../plugins/cfitsio/yorick/yorick_functions.tex";

yocoDocListFunctions,tex=1,dir=curdir+"../plugins/cfitsio/yorick/";
yocoDocListFunctions,tex=0,dir=curdir+"../plugins/cfitsio/yorick/";

rename,curdir+"../plugins/cfitsio/yorick/yorick_functions.tex",
    curdir+"cfitsio_functions.tex";
rename,curdir+"../plugins/cfitsio/yorick/yorick_functions.txt",
    curdir+"cfitsio_functions.txt";


// Generate functions documentation from yoco plugin
remove,curdir+"../plugins/yoco/yorick/yorick_functions.txt";
remove,curdir+"../plugins/yoco/yorick/yorick_functions.tex";

yocoDocListFunctions,tex=1,dir=curdir+"../plugins/yoco/yorick/";
yocoDocListFunctions,tex=0,dir=curdir+"../plugins/yoco/yorick/";

rename,curdir+"../plugins/yoco/yorick/yorick_functions.tex",
    curdir+"yoco_functions.tex";
rename,curdir+"../plugins/yoco/yorick/yorick_functions.txt",
    curdir+"yoco_functions.txt";
