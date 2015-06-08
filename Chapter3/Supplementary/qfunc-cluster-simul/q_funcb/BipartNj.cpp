/* 
 * File:   BipartNj.cpp
 * Author: root
 * 
 * Created on January 25, 2011, 4:03 PM
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include <signal.h>

#include <iostream>
#include <map>
#include <string>
#include <cmath>

#include "BipartNj.h"


using namespace std;
using namespace uqam_doc;

using uqam_doc::BipartNj;

BipartNj::BipartNj(map< string, map<string, DistAtom > > &dm) {

    epsilon = 0.00001;

    n = dm.size();
    //allocate identifiers
    ident_of_matrix_.clear();
    ident_of_matrix_.reserve(dm.size());

    //allocate C objects

    second_dim_double_.resize(n + 1, 0.0);
    DISS.resize(n + 1, second_dim_double_);

    second_dim_double_.resize(n + 1, 0.0);
    D.resize(n + 1, second_dim_double_);

    second_dim_double_.resize(n + 1, 0.0);
    ADD.resize(n + 1, second_dim_double_);


    PLACE.resize((2 * n - 2), 0);


    second_dim_int_.resize(n + 1, 0);
    B.resize((2 * n - 2), second_dim_int_);

    MaxCol.resize((2 * n), 0);
    X.resize((2 * n + 1), 0);
    Path.resize((2 * n), 0);
    LengthPath.resize((2 * n), 0.0);





    //load DISS distance matrix and extract identifiers
    //C matrix 1 based
    map< string, map<string, DistAtom > >::iterator it1 = dm.begin();
    int i = 1;

    while (it1 != dm.end()) {
        //take matrix identifiers into a vector for bipartitions name reconstruction
        ident_of_matrix_.push_back(it1->first);
        //iterate over second dimension
        map<string, DistAtom >::iterator it2 = it1->second.begin();
        int j = 1;

        while (it2 != it1->second.end()) {

            //charge la matrice de distance C
            DISS[i][j] = dm[it1->first][it2->first].real_dist_;

            ++it2;
            ++j;

        }

        ++it1;
        ++i;
    }





}

BipartNj::BipartNj(const BipartNj& orig) {

}

BipartNj::~BipartNj() {


    B.clear();
    //delete(DISS);
    DISS.clear();
    //delete(ADD);
    ADD.clear();
    //D.clear();
    PLACE.clear();

    res_.clear();

    cout << "~BipartNj()" << endl;

}

void BipartNj::allocMem() {



}

//load DISS from file

void BipartNj::lectureFichier() {
    double val;
    char * nom = (char*) malloc(100);

    FILE * in = fopen("input.txt", "r");

    //fscanf(in, "%d", &n);

    //== lecture des donnees dans le fichier
    for (int i = 1; i <= n; i++) {
        fscanf(in, "%s", nom);
        for (int j = 1; j <= n; j++) {
            fscanf(in, "%lf", &val);
            DISS[i][j] = val;
        }
    }
    fclose(in);
}

void BipartNj::calculateBipartVector() {

    res_.clear();
    res_.reserve(2 * n - 3);

    //vd_.clear();
    //ident_grouped_.clear();
    //ident_grouped_.resize(2, vd_);
    //res_.resize((2 * n - 3),ident_grouped_);

    //this->res_.reserve(2 * n - 3);

    //vector<float> vd(NB_GROUPS_, 0.0);
    //d_2g_cumul_.resize(NB_GROUPS_, vd);



    //ident_grouped.resize(2, NULL);

    //extract bipartitions
    //input parameters B,n
    printf("Matrice de bipartition");
    for (int i = 1; i <= (2 * n - 3); i++) {
        //printf("\n%d\t", i);

        for (int j = 1; j <= n; j++) {
            //printf("%d", B[i][j]);
        }

        //new collection
        vd_.clear();
        ident_grouped_.clear();
        ident_grouped_.resize(2, vd_);

        //== construction de chaque ensemble
        //printf("-> ");
        for (int j = 1; j <= n; j++) {
            if (B[i][j] == 0) {
                //printf("%d ", j);
                //add to 0 group
                ident_grouped_[0].insert(ident_of_matrix_[j - 1]);
            }
        }
        //printf("- ");
        for (int j = 1; j <= n; j++) {
            if (B[i][j] == 1) {
                //printf("%d ", j);
                //add to 1 group
                ident_grouped_[1].insert(ident_of_matrix_[j - 1]);
            }

        }
        this->res_.push_back(ident_grouped_);

    }
    printf("\n");
    cout << "res_.size(): " << res_.size() << endl;



}

void BipartNj::getBipartVector(vector < vector <set< string > > > * bv) {

    //vector< vector <set<string> > > bv;

    set<string> elems;
    vector <set<string> > groups;

    bv->clear();
    for (int i = 0; i < res_.size(); i++) {
        //cout << "bipartition: " << i << endl;

        groups.clear();
        for (int j = 0; j < res_[i].size(); j++) {
            // cout << "group: " << j << endl;

            elems.clear();

            set<string> elems = res_[i][j];
            set<string>::iterator it1 = elems.begin();
            while (it1 != elems.end()) {
                //cout << "        element: " << *it1 << endl;
                elems.insert(*it1);
                ++it1;
            }



            groups.push_back(elems);
        }
        //cout << "group size: " << groups.size() << endl;
        bv->push_back(groups);
    }


    //cout << "--------------bv size: " << bv->size() << endl;

    //copy(res_.begin(), res_.end(), bv.begin());

}


//extract bipartitions from B

void BipartNj::outputBipartitions() {
    //extract bipartitions
    //input parameters B,n
    printf("Matrice de bipartition");
    for (int i = 1; i <= 2 * n - 3; i++) {
        printf("\n%d\t", i);
        for (int j = 1; j <= n; j++) {
            printf("%d", B[i][j]);
        }
        //== affichage de chaque ensemble
        printf("-> ");
        for (int j = 1; j <= n; j++) {
            if (B[i][j] == 0) printf("%d ", j);
        }
        printf("- ");
        for (int j = 1; j <= n; j++) {
            if (B[i][j] == 1) printf("%d ", j);
        }
    }
    printf("\n");

}

void BipartNj::outputBipartVector() {
    for (int i = 0; i < res_.size(); i++) {
        cout << "bipartition: " << i << endl;
        for (int j = 0; j < res_[i].size(); j++) {
            cout << "group: " << j << endl;
            set<string> elems = res_[i][j];
            set<string>::iterator it1 = elems.begin();
            while (it1 != elems.end()) {
                cout << "        element: " << *it1 << endl;
                ++it1;
            }

        }
    }
}

int BipartNj::recherche_bipartition() {

    //

    //input parameters DISS,n
    //output ADD
    NJ();

    //input parameters ADD,n
    //output: B,PLACE
    //Bipartition_Table(ADD, B, PLACE, n); //== B : matrice de bipartitions

    Bipartition_Table(); //== B : matrice de bipartitions


}

//void BipartNj::odp1(double** D, int* X, int* i1, int* j1, int n) {
//void BipartNj::odp1(int* X, int* i1, int* j1) {

void BipartNj::odp1(vector <int> & X, int* i1, int* j1) {

    double S1, S;
    int i, j, k, a;

    vector<int> Y1;

    //Y1 = (int *) malloc((n + 1) * sizeof (int));
    Y1.resize((n + 1), 0);


    for (i = 1; i <= n; i++) {
        Y1[i] = 1;
    }


    X[1] = *i1;
    X[n] = *j1;

    //if (n == 2) {
    //free(Y1);

    //  return;
    //}

    if (n != 2) {

        Y1[*i1] = 0;
        Y1[*j1] = 0;
        for (i = 0; i <= n - 3; i++) {
            a = 2;
            S = 0;
            for (j = 1; j <= n; j++) {
                if (Y1[j] > 0) {
                    S1 = ADD[X[n - i]][X[1]] - ADD[j][X[1]] + ADD[X[n - i]][j];
                    if ((a == 2) || (S1 <= S)) {
                        S = S1;
                        a = 1;
                        X[n - i - 1] = j;
                        k = j;
                    }
                }
            }
            Y1[k] = 0;
        }
    }



    // free(Y1);
    Y1.clear();
}



// application de la methode NJ pour construire
// une matrice additive
//void BipartNj::NJ(double **D1, double **DA, int n) {

void BipartNj::NJ() {

    //double **D;
    //D = new double*[n + 1];
    //for (int i = 0; i <= n; ++i) {
    //    D[i] = new double[n + 1];
    //}

    vector <double> T1;
    vector <double> S;
    vector <double> LP;
    vector <int> T;



    //double *T1, *S, *LP;
    //int *T;

    double Som, Smin, Sij, L, Lii, Ljj, l1, l2, l3;
    int i, j, ii, jj, n1;

    //D= (double **) malloc((n+1)*sizeof(double*));



    //T1 = (double *) malloc((n + 1) * sizeof (double));
    //S = (double *) malloc((n + 1) * sizeof (double));
    //LP = (double *) malloc((n + 1) * sizeof (double));
    //T = (int *) malloc((n + 1) * sizeof (int));

    /* Memory allocation */

    //MaxCol = (int *) malloc((2 * n) * sizeof (int));
    T1.resize((n + 1), 0.0);
    S.resize((n + 1), 0.0);
    LP.resize((n + 1), 0.0);
    T.resize((n + 1), 0);


    /*
    for (i=0;i<=n;i++)
    {
            D[i]=(double*)malloc((n+1)*sizeof(double));

            if (D[i]==NULL)
            {
                    { printf("Data matrix is too large"); return;}
            }
    }
     */


    L = 0;
    Som = 0;
    for (i = 1; i <= n; i++) {
        S[i] = 0;
        LP[i] = 0;
        for (j = 1; j <= n; j++) {
            D[i][j] = DISS[i][j]; //only place to read DISS
            S[i] = S[i] + D[i][j];
        }
        Som = Som + S[i] / 2;
        T[i] = i;
        T1[i] = 0;
    }

    /* Procedure principale */
    for (n1 = n; n1 > 3; n1--) {

        /* Recherche des plus proches voisins */
        Smin = 2 * Som;
        for (i = 1; i <= n1 - 1; i++) {
            for (j = i + 1; j <= n1; j++) {
                Sij = 2 * Som - S[i] - S[j] + D[i][j]*(n1 - 2);

                // diff <=
                //all could be equal for all 0 distance matrices
                if (Sij <= Smin) {
                    Smin = Sij;
                    ii = i;
                    jj = j;
                }
            }
        }
        /* Nouveau groupement */


        Lii = (D.at(ii).at(jj) + (S.at(ii) - S.at(jj)) / (n1 - 2)) / 2 - LP.at(ii);
        Ljj = (D.at(ii).at(jj) + (S.at(jj) - S.at(ii)) / (n1 - 2)) / 2 - LP.at(jj);

        /* Mise a jour de D */

        if (Lii < 2 * epsilon) Lii = 2 * epsilon;
        if (Ljj < 2 * epsilon) Ljj = 2 * epsilon;
        L = L + Lii + Ljj;
        LP[ii] = 0.5 * D[ii][jj];

        Som = Som - (S[ii] + S[jj]) / 2;
        for (i = 1; i <= n1; i++) {
            if ((i != ii) && (i != jj)) {
                S[i] = S[i] - 0.5 * (D[i][ii] + D[i][jj]);
                D[i][ii] = (D[i][ii] + D[i][jj]) / 2;
                D[ii][i] = D[i][ii];
            }
        }
        D[ii][ii] = 0;
        S[ii] = 0.5 * (S[ii] + S[jj]) - D[ii][jj];

        if (jj != n1) {
            for (i = 1; i <= n1 - 1; i++) {
                D[i][jj] = D[i][n1];
                D[jj][i] = D[n1][i];
            }
            D[jj][jj] = 0;
            S[jj] = S[n1];
            LP[jj] = LP[n1];
        }
        /* Mise a jour de ADD */
        for (i = 1; i <= n; i++) {
            if (T[i] == ii) T1[i] = T1[i] + Lii;
            if (T[i] == jj) T1[i] = T1[i] + Ljj;
        }


        for (j = 1; j <= n; j++) {
            if (T[j] == jj) {
                for (i = 1; i <= n; i++) {
                    if (T[i] == ii) {
                        ADD[i][j] = T1[i] + T1[j];
                        ADD[j][i] = ADD[i][j];
                    }
                }
            }
        }

        for (j = 1; j <= n; j++)
            if (T[j] == jj) T[j] = ii;

        if (jj != n1) {
            for (j = 1; j <= n; j++)
                if (T[j] == n1) T[j] = jj;
        }
    }

    /*Il reste 3 sommets */

    l1 = (D[1][2] + D[1][3] - D[2][3]) / 2 - LP[1];
    l2 = (D[1][2] + D[2][3] - D[1][3]) / 2 - LP[2];
    l3 = (D[1][3] + D[2][3] - D[1][2]) / 2 - LP[3];
    if (l1 < 2 * epsilon) l1 = 2 * epsilon;
    if (l2 < 2 * epsilon) l2 = 2 * epsilon;
    if (l3 < 2 * epsilon) l3 = 2 * epsilon;
    L = L + l1 + l2 + l3;

    for (j = 1; j <= n; j++) {
        for (i = 1; i <= n; i++) {
            if ((T[j] == 1) && (T[i] == 2)) {
                ADD[i][j] = T1[i] + T1[j] + l1 + l2;
                ADD[j][i] = ADD[i][j];
            }
            if ((T[j] == 1) && (T[i] == 3)) {
                ADD[i][j] = T1[i] + T1[j] + l1 + l3;
                ADD[j][i] = ADD[i][j];
            }
            if ((T[j] == 2) && (T[i] == 3)) {
                ADD[i][j] = T1[i] + T1[j] + l2 + l3;
                ADD[j][i] = ADD[i][j];
            }
        }
        ADD[j][j] = 0;
    }


    //free(T);
    //free(T1);
    //free(S);
    //free(LP);

    //delete D
    //for (i = 0; i <= n; i++) {
    //   delete(D[i]);
    //}
    //delete(D);
    //D.clear();

}

//int BipartNj::Bipartition_Table(double **ADD, int **B, int *PLACE, int n) {

int BipartNj::Bipartition_Table() {

    int m;

    int i, j, k, l, l1, EdgeNumberPath, uv, PlaceNumber, edge, F;
    int M;

    //int *MaxCol;
    //int *X;
    //int *Path;
    //double *LengthPath;

    MaxCol.clear();
    X.clear();
    LengthPath.clear();
    Path.clear();

    double S, DIS, DIS1;


    double EPS = 1.e-5;
    double EPS1 = 1.e-2;

    /* Memory allocation */

    //MaxCol = (int *) malloc((2 * n) * sizeof (int));
    //X = (int *) malloc((2 * n + 1) * sizeof (int));
    //Path = (int *) malloc((2 * n) * sizeof (int));
    //LengthPath = (double *) malloc((2 * n) * sizeof (double));


    /* Computation of a circular order X for ADD */

    i = 1;
    j = n;

    //    cout << "ADD: size " << ADD.size() << endl;
    //odp1(ADD, X, &i, &j, n);

    odp1(X, &i, &j);

    /* Initialization */
    for (i = 1; i <= 2 * n - 3; i++) {
        MaxCol[i] = 0;
        PLACE[i] = 0;
        for (j = 1; j <= n; j++) {
            B.at(i).at(j) = 0;
        }

    }

    B[1][X[2]] = 1;
    MaxCol[1] = X[2];
    Path[1] = 1;
    PlaceNumber = 1;
    PLACE[1] = 1;
    LengthPath[1] = ADD[X[1]][X[2]];
    EdgeNumberPath = 1;
    m = 1;

    /* The main loop */

    for (k = 2; k <= n - 1; k++) {
        /* Point 2.1 of the algorithm (see the referenced article by Makarenkov and Leclerc) */

        DIS = (ADD[X[1]][X[k]] + ADD[X[k]][X[k + 1]] - ADD[X[1]][X[k + 1]]) / 2;
        DIS1 = (ADD[X[1]][X[k + 1]] + ADD[X[k]][X[k + 1]] - ADD[X[1]][X[k]]) / 2;

        //printf("\n\n%d,%d,%d\n\n",X[1],X[k],X[k+1]);
        if ((DIS <= -EPS1) || (DIS1 <= -EPS1)) {
            printf("\n This is not an additive distance \n");
            MaxCol.clear();
            X.clear();
            LengthPath.clear();
            Path.clear();
            exit(1);
            return 0;
        }
        if (DIS <= EPS) DIS = 0.0;
        if (DIS1 <= EPS) DIS1 = 0.0;

        S = 0.0;
        i = EdgeNumberPath;
        if (LengthPath[i] == 0.0) i--;
        while (S <= DIS - EPS) {
            if (i == 0) {
                S = DIS;
                break;
            } /* checking the limit */
            S = S + LengthPath[i];
            i--;
        }

        /* Point 2.2 of the algorithm */

        if (fabs(S - DIS) <= EPS) {
            M = m + 2;
            DIS = S;
            if (i == 0) F = 1;
            else if (i == EdgeNumberPath) F = 2;
            else {
                M--;
                F = 3;
            }
        } else {
            M = m + 2;
            F = 0;
        }


        if (M == m + 2) {
            if (F == 0) {
                uv = Path[i + 1];
                EdgeNumberPath = i + 2;
                LengthPath[i + 1] = S - DIS;
                LengthPath[i + 2] = DIS1;
                Path[i + 1] = m + 2;
                Path[i + 2] = m + 1;
            } else if (F == 1) {
                uv = Path[1];
                EdgeNumberPath = 2;
                LengthPath[1] = 0.0;
                LengthPath[2] = DIS1;
                Path[1] = m + 2;
                Path[2] = m + 1;
            } else if (F == 2) {
                uv = Path[EdgeNumberPath];
                EdgeNumberPath = EdgeNumberPath + 1;
                LengthPath[EdgeNumberPath] = DIS1;
                Path[EdgeNumberPath - 1] = m + 2;
                Path[EdgeNumberPath] = m + 1;
            }

            for (j = 1; j <= n; j++) {
                B[m + 2][j] = B[uv][j];
            }

            MaxCol[m + 2] = MaxCol[uv];
        } else {
            EdgeNumberPath = i + 1;
            LengthPath[i + 1] = DIS1;
            Path[i + 1] = m + 1;
        }

        /* Point 2.3 of the algorithm */

        for (j = 1; j <= EdgeNumberPath; j++)
            B[Path[j]][X[k + 1]] = 1;

        /* Point 2.4 of the algorithm */

        for (j = 1; j <= EdgeNumberPath; j++)
            if (MaxCol[Path[j]] < X[k + 1]) MaxCol[Path[j]] = X[k + 1];

        /* Point 2.5 of the algorithm */

        for (j = PlaceNumber; j >= 1; j--)
            PLACE[j + 1] = PLACE[j];
        PLACE[1] = m + 1;
        PlaceNumber++;

        if (M == m + 2) {
            i = 2;
            while (PLACE[i] != uv)
                i++;
            for (j = PlaceNumber; j >= i + 1; j--)
                PLACE[j + 1] = PLACE[j];
            PLACE[i + 1] = m + 2;
            PlaceNumber++;
        }

        i = M - 1;
        edge = 2;
        do {
            if (PLACE[i] == Path[edge]) {
                edge++;
                j = i + 1;
                while (X[k + 1] > MaxCol[PLACE[j]])
                    j++;
                if (j > i + 1) {
                    l1 = PLACE[i];
                    for (l = i + 1; l <= j - 1; l++)
                        PLACE[l - 1] = PLACE[l];
                    PLACE[j - 1] = l1;

                }
            }
            i--;
        } while (i != 0);

        m = M;
    }


    /* memeory liberation */

    //free(MaxCol);
    //free(X);
    //free(LengthPath);
    //free(Path);

    //MaxCol.clear();
    //X.clear();
    //LengthPath.clear();
    //Path.clear();


    return m;

}




