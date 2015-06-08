/* 
 * File:   ProteinMatrix.h
 * Author: root
 *
 * Created on February 3, 2011, 2:24 PM
 */

#ifndef _PROTEINMATRIX_H
#define	_PROTEINMATRIX_H

#include <string>
#include <vector>

using namespace std;

namespace uqam_doc {

    class ProteinMatrix {
    public:
        ProteinMatrix();
        ProteinMatrix(const ProteinMatrix& orig);
        virtual ~ProteinMatrix();

        //accessors
        vector <string>& getMatProtIdent();
        vector < vector <float> >& getMatProt();
        float getMatProtExpect();

    protected:
        //members
        vector <string> mat_prot_ident_;
        vector < vector <float> > mat_prot_;
        float mat_prot_expect_;

    private:

    };
}

#endif	/* _PROTEINMATRIX_H */

