/* 
 * File:   QFuncCalcAppl.cpp
 * Author: root
 * 
 * Created on February 4, 2011, 3:15 PM
 */

#include "QFuncCalcAppl.h"

using uqam_doc::QFuncCalcAppl;

QFuncCalcAppl::QFuncCalcAppl() {
}


//custom constructor
QFuncCalcAppl::QFuncCalcAppl(int argc, char** argv) {

     appl_data_ = new ApplicationData();

     appl_data_->process_cmd_line(argc, argv);

     q_func = new qFuncCalc(appl_data_);


}

QFuncCalcAppl::QFuncCalcAppl(const QFuncCalcAppl& orig) {
}

//destructor
QFuncCalcAppl::~QFuncCalcAppl() {
    delete(q_func);
    delete(appl_data_);
    
}

void QFuncCalcAppl::run() {
       q_func->readMsaFasta();


    //if there is a filter on identifiers, load those
    if (appl_data_->ids_work_csv_.size() != 0) {
        q_func->readIdsWork();
        q_func->filterIdsWork();
    } else {

        q_func->readXIdentCsv();
        q_func->eliminateNonUsed();
    }


    //rewrite with random sequences
    //m.genRandNuclMsaFasta();



    //m.show_align_mult_types();

    q_func->calculate();
}

