#*******************************************************************************
#
# "@(#) $Id: Makefile,v 1.1 2007-02-07 07:51:16 gzins Exp $"
#
# Makefile to install/clean :
#	- cfitsio and fftw library
# 	- rlterm and readline utilities
#   - yorick program
#
# History
# -------
# $Log: not supported by cvs2svn $
#

# Public targets
# --------------
all:	do_all
	@echo " . . . 'all' done" 

clean : clean_all 
	@echo " . . . clean done"

install : install_all
	@echo " . . . installation done"

#
# Private targets 
# ---------------
INTROOT_SUBDIRS = lib

create_introot:
	@if [ -z $(INTROOT) ];\
	then \
		echo "INTROOT environment variable must be set"; \
		exit 1;\
	fi
	@if [ -f $(INTROOT) ]; \
	then \
	echo -e "\n ERROR: Cannot create the installation directory because a file"; \
	echo "             called >>$(INTROOT)<< already exists."; \
	echo "             Use another name or remove the existing file"; \
	echo ""; \
	exit 1; \
	fi
	@if [ ! -d $(INTROOT) ];\
	then \
		echo "Creating $(INTROOT) directory" ; \
		mkdir $(INTROOT) ; \
	else \
		echo "Checking INTROOT directory structure";\
	fi
	@for dir in $(INTROOT_SUBDIRS) ; do \
		if [ ! -d $(INTROOT)/$${dir} ]; \
		then \
			echo "	Creating $${dir} ...";\
			mkdir -p $(INTROOT)/$${dir}; \
		fi; \
    done

do_all:
	@chmod +x install.sh clean.sh

clean_all:
	@./clean.sh

install_all: create_introot
	@./install.sh

#___oOo___
