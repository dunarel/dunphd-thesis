
#include <stdlib.h>
#include <iostream>
#include "q_func_calc.h"
#include <time.h>

#include "application_data.h"
#include "data_access.h"
#include "QFuncCalcAppl.h"

using namespace std;
using namespace uqam_doc;


using uqam_doc::Parsers;

int main(int argc, char** argv) {



   
    srand(0);
    time_t t, t0;
    t = time(NULL);

    cout << "modif5" << endl;
    //sleep(5);


    QFuncCalcAppl *app = new QFuncCalcAppl(argc, argv);
    app->run();
    delete(app);
    

    t0 = time(NULL) - t;
    cout << "temps total: " << t0 << endl;
   
    return (EXIT_SUCCESS);
}

