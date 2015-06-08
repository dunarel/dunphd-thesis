
ifeq ($(TARGET),debug)
 CXXFLAGS=-g -fopenmp
 
 LDFLAGS=-g -lgomp 
 EXEC=q_funcp
else
ifeq ($(TARGET),release)
 CXXFLAGS=-O2 -fopenmp
 LDFLAGS=-lgomp
 EXEC=q_funcp
endif
endif


CC=g++

IDIR =src
_DEPS = dist_atom.h application_data.h auto_win_q.h q_func_calc.h ProteinMatrix.h distance_measures.h data_access.h BipartNj.h QFuncCalcAppl.h

DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

#-I/usr/include/c++/4.7
INC=-I$(IDIR) -Ideps/tclap/include -I/usr/include -I/usr/include/boost 
 

#CFLAGS=-W -Wall -ansi -pedantic -MMD -MP -MF -O2 -MMD -MP -MF



ODIR=obj

_OBJ = dist_atom.o application_data.o main.o auto_win_q.o q_func_calc.o ProteinMatrix.o distance_measures.o data_access.o BipartNj.o QFuncCalcAppl.o

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







