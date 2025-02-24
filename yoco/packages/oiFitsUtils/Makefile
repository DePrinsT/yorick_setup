#*******************************************************************************
# LAOG project - Yorick Contribution package
#
# "@(#) $Id: Makefile,v 1.1 2010-05-21 10:32:27 lebouquj Exp $"
#
# Makefile of Yorick Contribution packages
#
# History
# -------
# $Log: not supported by cvs2svn $


# non-pkg.i include files for this package, if any
PKG_I = oiFitsUtils.i  \
        imgFitsUtils.i 

 
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
	@cp -f $(PKG_I)  $(Y_SITE)/i

install_target:
	@echo "Installing into target: $(INTROOT)"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -vf $(PKG_I)  $(INTROOT)/include

uninstall_target:
	@echo "Uninstall from target: $(INTROOT)"
	@echo ".....remove include:"
	@-for file in $(PKG_I) ; do \
		echo "Removing include $${file} ...";\
		rm -f $(INTROOT)/include/$${file}; \
	done

#___oOo___
