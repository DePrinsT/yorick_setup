#*******************************************************************************
# PIONIER Data Reduction Software
#
# "@(#) $Id: Makefile,v 1.3 2010-11-23 12:31:35 lebouquj Exp $"
#
# Makefile of the PIONIER Data Reduction Software
#
# History
# -------
# $Log: not supported by cvs2svn $
# Revision 1.2  2010/10/27 00:29:02  lebouquj
# Add pndrsCalibrate
#
# Revision 1.1  2010/09/03 07:58:59  lebouquj
# Created.
#
#
#

# non-pkg.i include files for this package, if any
PKG_I = pndrs.i            \
        pndrsBatch.i       \
        pndrsBrowser.i     \
        pndrsConfig.i      \
        pndrsFiles.i       \
        pndrsImage.i       \
        pndrsOiData.i      \
        pndrsPlot.i        \
        pndrsProcess.i     \
        pndrsSignal.i      \
        pndrsCalibrate.i   \
        pndrsInteractive.i \
        pndrsSim.i         \
        pndrsArchive.i     \
        pndrsTest.i

PKG_B = pndrsCalibrate \
        pndrsReduce    \
        pndrsPipeline  \
        pndrsBrowser   \
        pndrsInspectRawData   \
        pndrsCheckAllObject   \
        pndrsRenameAllRawData \
        pndrsInspectRawData   \
        pndrsDownload   \
        pndrsSummary   \
        pndrsShowPixel \
        pndrsValidateProduct \
        pioni_dark_calibration \
        pioni_kappa_matrix \
        pioni_oidata_raw \
        pioni_spectral_calibration \
        pndrs

Y_SITE := $(shell echo "Y_SITE" > ysite.i; yorick -batch ysite.i 2> /dev/null; rm -f ysite.i)
Y_EXEC := $(shell which yorick 2> /dev/null;)
READLINE := $(shell if eval "rlterm echo" &> /dev/null; then echo rlterm; elif eval "rlwrap echo" &> /dev/null; then echo rlwrap; fi;)
READLINE = rlwrap

#
# Public targets
# --------------
all:	do_all
	@echo " . . . 'all' done" 

clean : clean_all
	@echo " . . . clean done"

install : install_all
	@echo " . . . installation done"

uninstall : uninstall_all
	@echo " . . . uninstallation done"


#
# Private targets 
# ---------------
do_all:

clean_all:

install_all:
	@echo "Installing into target: $(Y_SITE)i"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -f $(PKG_I)  $(Y_SITE)/i
	@echo "           sclguiVOTableToTSV.xsl"
	@cp -f ../include/sclguiVOTableToTSV.xsl  $(INTROOT)/include/
	@echo "Installing into target: $(INTROOT)"
	@echo "Use yorick executable:  $(Y_EXEC)"
	@echo "Use readline command:   $(READLINE)"
	@echo ".....bin:"
	@echo "           $(PKG_B)"
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsCalibrate > $(INTROOT)/bin/pndrsCalibrate
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsReduce    > $(INTROOT)/bin/pndrsReduce
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsPipeline  > $(INTROOT)/bin/pndrsPipeline
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsInspectAllRawData > $(INTROOT)/bin/pndrsInspectAllRawData
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsInspectRawData   > $(INTROOT)/bin/pndrsInspectRawData
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsBrowser          > $(INTROOT)/bin/pndrsBrowser
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsCheckAllObject   > $(INTROOT)/bin/pndrsCheckAllObject
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsRenameAllRawData > $(INTROOT)/bin/pndrsRenameAllRawData
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsDownload    > $(INTROOT)/bin/pndrsDownload
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsSummary    > $(INTROOT)/bin/pndrsSummary
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsShowPixel  > $(INTROOT)/bin/pndrsShowPixel
	@echo "#! $(Y_EXEC) -batch" | cat - pndrsValidateProduct  > $(INTROOT)/bin/pndrsValidateProduct
	@echo "#! $(Y_EXEC) -batch" | cat - pioni_dark_calibration.i  > $(INTROOT)/bin/pioni_dark_calibration
	@echo "#! $(Y_EXEC) -batch" | cat - pioni_spectral_calibration.i  > $(INTROOT)/bin/pioni_spectral_calibration
	@echo "#! $(Y_EXEC) -batch" | cat - pioni_kappa_matrix.i  > $(INTROOT)/bin/pioni_kappa_matrix
	@echo "#! $(Y_EXEC) -batch" | cat - pioni_oidata_raw.i  > $(INTROOT)/bin/pioni_oidata_raw
	@echo "#! $(Y_EXEC) -batch" | cat - pioni_oidata_tf.i  > $(INTROOT)/bin/pioni_oidata_tf
	@echo "#! $(Y_EXEC) -batch" | cat - pioni_oidata_calibrated.i  > $(INTROOT)/bin/pioni_oidata_calibrated
	@chmod a+x $(INTROOT)/bin/pioni_*
	@echo "$(READLINE) $(Y_EXEC) -i pndrs.i" > $(INTROOT)/bin/pndrs
	@chmod a+x $(INTROOT)/bin/pndr*

uninstall_all:
	@echo "Uninstalling from target: $(Y_SITE)i"
	@echo ".....remove include:"
	@echo "           $(PKG_I)"
	@cd $(Y_SITE)/i; rm -f $(PKG_I);
	@echo "Uninstalling from target: $(INTROOT)/bin"
	@echo ".....remove bin:"
	@echo "           $(PKG_B)"
	@cd $(INTROOT)/bin; rm $(PKG_B);

install_target:
	@echo "Installing into target: $(INTROOT)"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -f $(PKG_I) $(INTROOT)/include

uninstall_target:
	@echo "Uninstalling from target: $(INTROOT)"
	@echo ".....remove include:"
	@-for file in $(PKG_I) ; do \
		echo "Removing include $${file} ...";\
		rm -f $(INTROOT)/include/$${file}; \
	done

#___oOo___


