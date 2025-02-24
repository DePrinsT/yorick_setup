# These values filled in by    yorick -batch make.i
Y_MAKEDIR=/home/toond/software/yorick/yorick
Y_EXE=/home/toond/software/yorick/yorick/bin/yorick
Y_EXE_PKGS=
Y_EXE_HOME=/home/toond/software/yorick/yorick
Y_EXE_SITE=/home/toond/software/yorick/yorick
Y_HOME_PKG=

#  --------------------------------------------------- configuration file
include ../src/Make.cfg

# ----------------------------------------------------- optimization flags

# options for make command line, e.g.-   make COPT=-g TGT=exe
COPT=$(COPT_DEFAULT)
TGT=$(DEFAULT_TGT)

# ------------------------------------------------ macros for this package

PKG_NAME=cfitsioPlugin
PKG_INCLUDES=../include/$(PKG_NAME).h
PKG_I=$(PKG_NAME).i $(PKG_NAME)Wrapper.i

OBJS=$(PKG_NAME)Wrapper.o

# change to give the executable a name other than yorick
PKG_EXENAME=yorick

# PKG_DEPLIBS=-Lsomedir -lsomelib   for dependencies of this package
PKG_DEPLIBS=-L../lib -lcfitsio 

# set compiler (or rarely loader) flags specific to this package
PKG_CFLAGS=$(EXTRA_INC_PATH)
PKG_LDFLAGS=$(EXTRA_LIB_PATH)

# list of additional package names you want in PKG_EXENAME
# (typically Y_EXE_PKGS should be first here)
EXTRA_PKGS=$(Y_EXE_PKGS)

# list of additional files for clean
PKG_CLEAN=../object/$(PKG_NAME)Wrapper.h ../object/$(PKG_NAME)Yorick_wrap.xml

# autoload file for this package, if any
PKG_I_START=
# non-pkg.i include files for this package, if any
PKG_I_EXTRA=

# -------------------------------- standard targets and rules (in Makepkg)

# set macros Makepkg uses in target and dependency names
# DLL_TARGETS, LIB_TARGETS, EXE_TARGETS
# are any additional targets (defined below) prerequisite to
# the plugin library, archive library, and executable, respectively
PKG_I_DEPS=$(PKG_I)
Y_DISTMAKE=distmake

include $(Y_MAKEDIR)/Make.cfg
include $(Y_MAKEDIR)/Makepkg
include $(Y_MAKEDIR)/Make$(TGT)

# override macros Makepkg sets for rules and other macros
# Y_HOME and Y_SITE in Make.cfg may not be correct (e.g.- relocatable)
Y_HOME=$(Y_EXE_HOME)
Y_SITE=$(Y_EXE_SITE)

# reduce chance of yorick-1.5 corrupting this Makefile
MAKE_TEMPLATE = protect-against-1.5

# ------------------------------------- targets and rules for this package

# simple example:
#myfunc.o: myapi.h
# more complex example (also consider using PKG_CFLAGS above):
#myfunc.o: myapi.h myfunc.c
#	$(CC) $(CPPFLAGS) $(CFLAGS) -DMY_SWITCH -o $@ -c myfunc.c

#
# Generation of Yorick wrapper
#
C2YORICK_XSL = ../../../tools/config/yocoYorickWrapperForC.xsl

../object/$(PKG_NAME)Wrapper.h: $(PKG_INCLUDES)
	cat $(PKG_INCLUDES) > ../object/$(PKG_NAME)Wrapper.h

../object/$(PKG_NAME)Wrapper.xml: ../object/$(PKG_NAME)Wrapper.h
	swig -DEXPORT -xml -module $(PKG_NAME) -o  ../object/$(PKG_NAME)Wrapper.xml ../object/$(PKG_NAME)Wrapper.h 

update: ../object/$(PKG_NAME)Wrapper.xml
	xsltproc --path ../config -o $(PKG_NAME)Wrapper.i $(C2YORICK_XSL) ../object/$(PKG_NAME)Wrapper.xml

install::
	@echo "Installing into target: $(Y_SITE)"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -f $(PKG_I) $(Y_SITE)/i
	@echo "Installing into target: $(INTROOT)"
	@echo ".....library:"
	@echo "           $(PKG_NAME).so"
	@cp -f $(PKG_NAME).so $(INTROOT)/lib

install_target:
	@echo "Installing into target: $(INTROOT)"
	@echo ".....include:"
	@echo "           $(PKG_I)"
	@cp -f $(PKG_I) $(INTROOT)/include
	@echo ".....library:"
	@echo "           $(PKG_NAME).so"
	@cp -f $(PKG_NAME).so $(INTROOT)/lib

uninstall_target:
	@echo "Uninstall from target: $(INTROOT)"
	@echo ".....remove include:"
	@-for file in $(PKG_I) ; do \
		echo "Removing include $${file} ...";\
		rm -f $(INTROOT)/include/$${file}; \
	done
	@echo ".....remove library:"
	@-for file in $(PKG_NAME) ; do \
		echo "Removing library $${file}.so ...";\
		rm -f $(INTROOT)/lib/$${file}.so; \
	done

# -------------------------------------------------------- end of Makefile
