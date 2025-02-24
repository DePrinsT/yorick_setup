
/* Location of scripts *.i and plugin *.so files */
SCRIPT_PATH = get_env("PNDRS_DIR");
PLUGIN_PATH = get_env("PIONI_PLUGIN_PATH");

/* Add these paths to the searched directories */
if ( SCRIPT_PATH ) set_path,SCRIPT_PATH+":"+get_path();
if ( PLUGIN_PATH ) plug_dir,grow(PLUGIN_PATH,plug_dir());

/* Load pndrs and make it silent and batch */
include,"pndrs.i";
pndrsBatchMakeSilentGraphics, 0;
yocoErrorSet,0;
batch,1;

/* Process arguments */
argv = get_argv();

/* Define loglevel */
pndrsArgvSetLogLevel, argv;

/* Run computation */
pndrsComputeSingleTf,
    inputOiDataFiles = pndrsGetArgument(argv,"--inputOiDataFiles="),
    inputCatalogFile = pndrsGetArgument(argv,"--inputCatalogFile="),
    outputOiDataTfFile = pndrsGetArgument(argv,"--outputOiDataTfFile="),
    averageFiles = tonum(pndrsGetArgument(argv,"--averageFiles=", default="1"));

/* Exit Yorick */
quit;
