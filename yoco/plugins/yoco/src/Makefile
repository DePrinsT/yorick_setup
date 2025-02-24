#*******************************************************************************
#
# "@(#) $Id: Makefile,v 1.3 2007-11-22 06:40:38 gzins Exp $"
#
# Makefile of yoco yorick plugin library
#
# History
# -------
# $Log: not supported by cvs2svn $
# Revision 1.1  2007/09/11 10:03:54  gzins
# Added
#
#

# User definable C-compilation flags
USER_CFLAGS   = -O -fPIC
# List of additional include file paths (formated as  -I<dir> ... )
#USER_INC = 
# List of additional library paths      (formated as  -L<dir> ...)
#USER_LIB = 

# Name of the library to be created
LIBRARY           = yocoPlugin
# List of object files (without extension)
LIBRARY_OBJECTS   = yocoSystem

#
# Public targets
# --------------
all:	do_all do_plugin
	@echo " . . . 'all' done" 

clean : clean_all clean_plugin
	@echo " . . . clean done"

install : install_all install_plugin
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
	@ar -s ../lib/lib$(LIBRARY).a

clean_all:
	@-for file in $(LIBRARY_OBJECTS) ; do \
		echo "Removing object $${file}.o ...";\
		rm -f ../object/$${file}.o; \
	done
	@echo "Removing library $${file} ...";
	@rm -f ../lib/lib$(LIBRARY).a;

install_all: create_introot
	@echo "Installing into target: $(INTROOT)"
	@echo -e "\n.....library:"
	@echo "           $(LIBRARY)"
	@cp -f ../lib/lib$(LIBRARY).a $(INTROOT)/lib;


#___oOo___
