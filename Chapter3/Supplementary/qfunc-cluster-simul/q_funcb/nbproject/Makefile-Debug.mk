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
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc44
CCC=g++44
CXX=g++44
FC=gfortran
AS=as

# Macros
CND_PLATFORM=GNU-Linux-x86
CND_CONF=Debug
CND_DISTDIR=dist
CND_BUILDDIR=build

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=${CND_BUILDDIR}/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/dist_atom.o \
	${OBJECTDIR}/application_data.o \
	${OBJECTDIR}/main.o \
	${OBJECTDIR}/auto_win_q.o \
	${OBJECTDIR}/q_func_calc.o \
	${OBJECTDIR}/ProteinMatrix.o \
	${OBJECTDIR}/distance_measures.o \
	${OBJECTDIR}/data_access.o \
	${OBJECTDIR}/BipartNj.o \
	${OBJECTDIR}/QFuncCalcAppl.o


# C Compiler Flags
CFLAGS=-fopenmp

# CC Compiler Flags
CCFLAGS=-fopenmp
CXXFLAGS=-fopenmp

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=/usr/lib/gcc/i386-redhat-linux6E/4.4.4/libgomp.a

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-${CND_CONF}.mk ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/q_funcb

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/q_funcb: /usr/lib/gcc/i386-redhat-linux6E/4.4.4/libgomp.a

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/q_funcb: ${OBJECTFILES}
	${MKDIR} -p ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}
	${LINK.cc} -static -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/q_funcb ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/dist_atom.o: dist_atom.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/dist_atom.o dist_atom.cpp

${OBJECTDIR}/application_data.o: application_data.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/application_data.o application_data.cpp

${OBJECTDIR}/main.o: main.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/main.o main.cpp

${OBJECTDIR}/auto_win_q.o: auto_win_q.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/auto_win_q.o auto_win_q.cpp

${OBJECTDIR}/q_func_calc.o: q_func_calc.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/q_func_calc.o q_func_calc.cpp

${OBJECTDIR}/ProteinMatrix.o: ProteinMatrix.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/ProteinMatrix.o ProteinMatrix.cpp

${OBJECTDIR}/distance_measures.o: distance_measures.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/distance_measures.o distance_measures.cpp

${OBJECTDIR}/data_access.o: data_access.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/data_access.o data_access.cpp

${OBJECTDIR}/BipartNj.o: BipartNj.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/BipartNj.o BipartNj.cpp

${OBJECTDIR}/QFuncCalcAppl.o: QFuncCalcAppl.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O3 -I/usr/local/boost_1_46_1 -I/usr/local/tclap-1.2.1/include -I/usr/include/c++/4.4.4 -MMD -MP -MF $@.d -o ${OBJECTDIR}/QFuncCalcAppl.o QFuncCalcAppl.cpp

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${CND_BUILDDIR}/${CND_CONF}
	${RM} ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/q_funcb

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
