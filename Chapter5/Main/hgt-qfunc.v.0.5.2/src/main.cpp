#include <iostream>

#include <stdlib.h>
#include <iostream>
#include <time.h>

#include "q_func_hgt_appl.hpp"

#include <omp.h>



using namespace std;
using namespace uqam_doc;


int main(int argc, char** argv) {
  

  srand(0);
	time_t t, t0;
	t = time(NULL);


	cout << "HGT-QFUNC v.0.5.2" << endl;
	cout << "" << endl;
	cout << "A New Fast Algorithm For Detecting and Validating Horizontal Gene Transfer Events" << endl;
	cout << "Using Phylogenetic Trees And Aggregation Functions" << endl;
	cout << "" << endl;
	cout << "Copyright (c) Dunarel Badescu, Abdoulaye Banire Diallo and Vladimir Makarenkov" << endl;
	cout << "@ UQAM Jan 2015" << endl;
	cout << "Parallelized using OpenMP and vectorized using SSE3" << endl;
	cout << "" << endl;
	cout << "1 Q7a (eq 5.21) -> Q7 in graphics" << endl;
	cout << "2 Q8a (eq 5.22)" << endl;
	cout << "3 Q8b (eq 5.23)" << endl;
	cout << "4 Q9a (eq 5.24) -> Q9 in graphics" << endl;
	cout << "" << endl;
	   	
	//sleep(5);


	QFuncHgtAppl *app = new QFuncHgtAppl(argc, argv);
	app->run();
	delete(app);

	t0 = time(NULL) - t;
	cout << "total time (seconds): " << t0  << endl;
	
  
    
    return 0;
}

