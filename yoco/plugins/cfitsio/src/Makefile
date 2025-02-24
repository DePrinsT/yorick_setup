#*******************************************************************************
#
# "@(#) $Id: Makefile,v 1.7 2008-01-25 10:08:41 gzins Exp $"
#
# Makefile of cfitsioPlugin yorick plugin library
#
# History
# -------
# $Log: not supported by cvs2svn $
# Revision 1.6  2007/08/08 18:55:31  gzins
# Minor correction
#
# Revision 1.5  2007/03/09 08:51:01  gzins
# Used new EXTRA_INC_PATH and EXTRA_LIB_PATH variables
#
# Revision 1.4  2007/02/16 20:28:26  gzins
# Added clean_plugin target
#
# Revision 1.3  2007/02/16 14:21:47  jblebou
# Add the call to yorick/'make clean' into the clean_all.
# Add the 'make test'
#
# Revision 1.2  2007/02/16 10:34:45  gzins
# Fixed install target
#
# Revision 1.1  2007/02/16 10:07:36  gzins
# Added
#
#

# Configuration file
include Make.cfg

# User definable C-compilation flags
USER_CFLAGS   = -O -fPIC
# List of additional include file paths (formated as  -I<dir> ... )
USER_INC = $(EXTRA_INC_PATH)
# List of additional library paths      (formated as  -L<dir> ...)
USER_LIB = $(EXTRA_LIB_PATH)

# Name of the library to be created
LIBRARY           = 
# List of object files (without extension)
LIBRARY_OBJECTS   = 

#
# Public targets
# --------------
all:	do_all do_plugin
	@echo " . . . 'all' done" 

clean : clean_all clean_plugin
	@echo " . . . clean done"

install : install_all install_plugin
	@echo " . . . installation done"

test :	test_all
	@echo " . . . test done"

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

YORICK := $(shell which yorick 2> /dev/null)
do_plugin:
	@if [ "$(YORICK)" == "" ]; then \
	    echo "ERROR - yorick program not found in your PATH"; \
	    echo "Please check your installation"; \
	    exit 1; \
	fi
	@(cd ../yorick; yorick -batch make.i; make all)

clean_plugin:
	@if [ "$(YORICK)" == "" ]; then \
	    echo "ERROR - yorick program not found in your PATH"; \
	    echo "Please check your installation"; \
	    exit 1; \
	fi
	@(cd ../yorick; yorick -batch make.i; make clean)

install_plugin:
	@if [ "$(YORICK)" == "" ]; then \
	    echo "ERROR - yorick program not found in your PATH"; \
	    echo "Please check your installation"; \
	    exit 1; \
	fi
	@(cd ../yorick; yorick -batch make.i; make install)


do_all:
	@for file in $(LIBRARY_OBJECTS) ; do \
		echo "Compiling $${file} ...";\
		$(CC) $(COPTS) $(USER_CFLAGS) -c -o ../object/$${file}.o $${file}.c \
			-I../include $(USER_INC); \
	done
	@for file in $(LIBRARY_OBJECTS) ; do \
		echo "Adding $${file} to archive ...";\
		ar -q ../lib/lib$(LIBRARY).a ../object/$${file}.o ;\
	done
	@if [ -f ../lib/lib$(LIBRARY).a ]; then \
		ar -s ../lib/lib$(LIBRARY).a; \
	fi

clean_all:
	@-for file in $(LIBRARY_OBJECTS) ; do \
		echo "Removing object $${file}.o ...";\
		rm -f ../object/$${file}.o; \
	done
	@echo "Removing library $${file} ...";
	@rm -f ../lib/lib$(LIBRARY).a;
	@echo "Entering ../yorick and 'make clean'"
	@(cd ../yorick; make clean; cd ../src;)

install_all: create_introot
	@echo "Installing into target: $(INTROOT)"
	@if [ "$(LIBRARY)" != "" ]; then \
		echo -e "\n.....library:"	 \
		echo "           $(LIBRARY)" \
		cp -f ../lib/lib$(LIBRARY).a $(INTROOT)/lib; \
	fi

test_all:
	@(cd ../yorick; yorick -batch ../test/cfitsioTest.i; rm -rf test.fits;)


#___oOo___
