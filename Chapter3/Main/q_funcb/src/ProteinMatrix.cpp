/* 
 * File:   ProteinMatrix.cpp
 * Author: root
 * 
 * Created on February 3, 2011, 2:24 PM
 */
#include "ProteinMatrix.h"

using namespace std;
using namespace uqam_doc;

using uqam_doc::ProteinMatrix;

ProteinMatrix::ProteinMatrix() {
}

ProteinMatrix::ProteinMatrix(const ProteinMatrix& orig) {
}

ProteinMatrix::~ProteinMatrix() {
}

vector <string>& ProteinMatrix::getMatProtIdent() {

    return mat_prot_ident_;
}

vector < vector <float> >& ProteinMatrix::getMatProt() {
    return mat_prot_;
}

float ProteinMatrix::getMatProtExpect() {
    return mat_prot_expect_;
}
