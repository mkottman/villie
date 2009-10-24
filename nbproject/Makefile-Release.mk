#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc.exe
CCC=g++.exe
CXX=g++.exe
FC=
AS=as.exe

# Macros
CND_PLATFORM=MinGW-Windows
CND_CONF=Release
CND_DISTDIR=dist

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES=

# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=

nbproject/qt-${CONF}.mk: nbproject/qt-${CONF}.pro FORCE
	qmake VPATH=. -o qttmp-${CONF}.mk nbproject/qt-${CONF}.pro
	mv -f qttmp-${CONF}.mk nbproject/qt-${CONF}.mk
	@sed -e 's:\\\(.\):/\1:g' nbproject/qt-${CONF}.mk >nbproject/qt-${CONF}.tmp
	@mv -f nbproject/qt-${CONF}.tmp nbproject/qt-${CONF}.mk

FORCE:

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS} nbproject/qt-${CONF}.mk
	${MAKE} -f nbproject/qt-${CONF}.mk dist/Release/MinGW-Windows/villie.exe

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: nbproject/qt-Release.mk
	$(MAKE) -f nbproject/qt-Release.mk distclean

# Subprojects
.clean-subprojects:
