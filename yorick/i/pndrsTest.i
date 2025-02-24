
include,"pndrs.i";
pndrsBatchMakeSilentGraphics,2;
yocoPlotDefaultDpi,50;

file = "/Volumes/pionier/2011-08-04/PIONIER.2011-08-05T00p17p52.527.fits";

/* Remove the simulation */
pndrsVersion= "1.9";

pndrsReadRawFiles, file, imgData, imgLog;
pndrsSimImgData, imgData, imgLog;

pndrsProcessDetector, imgData, imgLog;
pndrsReformData, imgData, imgLog;
pndrsGetData, imgData, imgLog, data, opd, map;


