/* 
 * File:   BipartNj.h
 * Author: root
 *
 * Created on January 25, 2011, 4:03 PM
 */

#ifndef _BIPARTNJ_H
#define	_BIPARTNJ_H

#include <string>
#include <map>
#include <vector>
#include <set>
#include "distance_measures.h"

using namespace std;

namespace uqam_doc {

    class BipartNj {
    public:

        //
        BipartNj(map< string, map<string, DistAtom > > &dm);

        BipartNj(const BipartNj& orig);
        virtual ~BipartNj();
        //
        void allocMem();

        void lectureFichier();

        void calculateBipartVector();

        void getBipartVector(vector < vector <set< string > > > * bv);

        //

        void outputBipartitions();
        void outputBipartVector();

        int recherche_bipartition();


        //
        vector<string> ident_of_matrix_;

        //
        float epsilon;

        //
        int n;
        //== allocation de la memoire apres avoir lu la taille n dans le fichier
        //double ** DISS;

        vector <vector <double> > DISS;
        vector <vector <double> > D;
        vector <double> second_dim_double_;
        vector <int> second_dim_int_;


        //double ** ADD;
        vector <vector <double> > ADD;
        //int ** B;
        vector <vector <int> > B;
        //int * PLACE;
        vector <int> PLACE;

        //

        //
        set<string> vd_;
        vector <set<string> > ident_grouped_;
        vector< vector <set<string> > > res_;


    private:
        void odp1(vector <int> & X, int *i1, int *j1);
        void NJ();
        //int Bipartition_Table(double **D, int **B, int *PLACE, int n);
        int Bipartition_Table();
        //in Bipartition_Table()
        vector <int> MaxCol;
        vector <int> X;
        vector <int> Path;
        vector <double> LengthPath;

    };

}


#endif	/* _BIPARTNJ_H */

