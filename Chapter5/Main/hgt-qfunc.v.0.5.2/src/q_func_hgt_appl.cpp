/* 
 * File:   QFuncHgtAppl.cpp
 * Author: Dunarel Badescu

 */

#include "q_func_hgt_appl.hpp"
#include "q_func_hgt.hpp"

using uqam_doc::QFuncHgtAppl;
using uqam_doc::QFuncHgt;

QFuncHgtAppl::QFuncHgtAppl() {
}


//custom constructor
QFuncHgtAppl::QFuncHgtAppl(int argc, char** argv) {
	
   appl_data_ = new ApplicationData();
   appl_data_->process_cmd_line(argc, argv);
   q_func_hgt = new QFuncHgt(appl_data_);


}

//QFuncHgtAppl::QFuncHgtAppl(const QFuncHgtAppl& orig) {
//}

//destructor
QFuncHgtAppl::~QFuncHgtAppl() {
    delete q_func_hgt;
    //delete(appl_data_);
    
}

void QFuncHgtAppl::run() {
     
	//main application
	
	q_func_hgt->calculate();
	
	
	
	
}

