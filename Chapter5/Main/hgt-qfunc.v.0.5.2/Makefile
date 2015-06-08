
ifeq ($(TARGET),debug)
# CXXFLAGS=-g -march=native -O1 -fopenmp --std=c++11 -mfpmath=sse -msse3  -ffast-math -DSIMDPP_ARCH_X86_SSE3 -DPLATFORM_GCC=1 -DSEQAN_ENABLE_TESTING=0 -DSEQAN_ENABLE_DEBUG=1 -W -Wno-unused-variable -Wno-sign-compare -Wno-long-long -Wno-unused-parameter -Wno-variadic-macros -funsigned-char 
 CXXFLAGS=-g -march=native -O1 -fopenmp --std=c++11 -mfpmath=sse -msse3  -ffast-math -DSIMDPP_ARCH_X86_SSE3 -DPLATFORM_GCC=1 -w -funsigned-char -fpermissive


 #LDFLAGS=-g -Wl,-Bstatic -lVc -Wl,-Bdynamic -lgomp -lrt -Wl,--as-needed  -flax-vector-conversions

 LDFLAGS=-g -march=native -Wl,-Bdynamic -lgomp -lrt -Wl,--as-needed  
 #LDFLAGS=-g -fopenmp  
 EXEC=hgt-qfunc-deb
else
ifeq ($(TARGET),release)
 CXXFLAGS=-O2 -std=c++11
 LDFLAGS=-lgomp
 EXEC=hgt-qfunc-rel
endif
endif

CC=g++

IDIR =src
_DEPS = q_func_hgt_appl.hpp q_func_hgt.hpp aligned_storage.hpp cache_line_size.h application_data.hpp

DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

#-I/usr/include/c++/4.7
INC=-I$(IDIR) -Ideps -Ideps/tclap/include -I/usr/include -Ideps/AssocVector -Ideps/fast-cpp-csv-parser 
 

#CFLAGS=-W -Wall -ansi -pedantic -MMD -MP -MF -O2 -MMD -MP -MF



ODIR=obj
#_OBJ = dist_atom.o application_data.o main.o auto_win_q.o q_func_calc.o ProteinMatrix.o distance_measures.o data_access.o BipartNj.o QFuncCalcAppl.o
_OBJ = q_func_hgt_appl.o q_func_hgt.o application_data.o main.o

OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

CDIR=src


FOO = newdir


$(EXEC): $(OBJ) $(DEPS)
	$(CC) $(LDFLAGS) -o $@ $^

$(ODIR)/%.o: $(CDIR)/%.cpp 
	$(CC) $(CXXFLAGS) $(INC) -c $< -o $@


help:
	echo $(DEPS)  

all: $(EXEC)



#echo "$(CC) $(CFLAGS) $(INC) -c $< -o $@"
#.PHONY: clean

clean:
	rm -f $(OBJ)
	rm -fr $(EXEC)
	rm -f ./*~

mrproper: clean
	rm -rf $(EXEC)







