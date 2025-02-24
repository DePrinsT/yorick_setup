#*******************************************************************************
# LAOG project - Yorick Contribution package
#
# "@(#) $Id: Makefile,v 1.11 2010-05-21 11:21:56 lebouquj Exp $"
#
# Makefile of Yorick Contribution packages
#

# non-pkg.i include files for this package, if any
PKG_I = yoco.i        \
        yocoAstro.i   \
        yocoCds.i     \
        yocoDoc.i     \
        yocoError.i   \
        yocoFile.i    \
        yocoGui.i     \
        yocoList.i    \
        yocoLog.i     \
        yocoMath.i    \
        yocoNm.i      \
        yocoPlot.i    \
        yocoStr.i     \
        yocoType.i    

 
#
# Public targets
# --------------
all:	do_all
	@echo " . . . 'all' done" 

clean : clean_all
	@echo " . . . clean done"

install : install_all
	@echo " . . . installation done"

Y_SITE := $(shell echo "Y_SITE" > ysite.i; yorick -batch ysite.i 2> /dev/null; rm -f ysite.i)
#
# Private targets 
# ---------------
do_all:

clean_all:

install_all:
	@echo "Installing into target: $(Y_SITE)i"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -vf $(PKG_I)  $(Y_SITE)/i

install_target:
	@echo "Installing into target: $(INTROOT)"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -vf $(PKG_I)  $(INTROOT)/include

clean_target:
	@echo "Cleaning target: $(INTROOT)"
	@echo ".....include:"
	@-for file in $(PKG_I) ; do \
		echo "Removing include $${file} ...";\
		rm -f $(INTROOT)/include/$${file}; \
	done

#___oOo___
