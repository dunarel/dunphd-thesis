

#include "distance_measures.h"
#include "ProteinMatrix.h"
#include <cmath>
#include <string>

// #include <xmmintrin.h>
// #include <emmintrin.h>
// #include <pmmintrin.h>

#include <boost/assign/std/vector.hpp>
#include <boost/assign/list_of.hpp> // for 'list_of()'

using namespace boost::assign; // bring 'list_of()' into scope
//using namespace boost::assign; // bring 'operator+()' into scope

using namespace std;
using namespace uqam_doc;

//static function pointer calculators
//using uqam_doc::DistSeqFuncStatic;

//abstract class - interface
//dist_2seq(string seq_a, string seq_b)
using uqam_doc::DistSeqInterface;
// virtual functions implementations
using uqam_doc::Hamming;
using uqam_doc::Hamming2;

using uqam_doc::JukesKantorNucl;
using uqam_doc::JukesKantorProt;
using uqam_doc::KimProt;
using uqam_doc::ScoreDist;
using uqam_doc::Blosum80;
using uqam_doc::Blosum62;



/*
float DistSeqFuncStatic::hamming_2seq(string seq_a, string seq_b) {

    float d = 0.0;

    for (int i = 0; i < seq_a.length(); i++) {
        d += (seq_a.at(i) == seq_b.at(i)) ? 0.0 : 1.0;

    }
    d /= seq_a.length();

    return d;

}
 */

/*************************************************************************************
/*	Nom			:	p_Kimura2Parameter
/*	Parametres	:	pmatSites       (in) : Matrice de sites
/*					pmatDistances   (in) : Matrice de distances
/*					pintNbreEspeces (in) : Nombre d'esp�ces
/*					pintNbreSites   (in) : Nombre de sites
/*	Retour		:	-
/*	Objectif	:	Comparer les s�quences deux par deux, en utilisant la m�thode
/*					Kimura 2-Parameter, et stoker les distances entre elles dans la
/*					matrice des distances.
 **************************************************************************************/

/*
float DistSeqFuncStatic::kimprot_2seq(string seq_a, string seq_b) {

    //cout << "------------------k2p_2seq" << endl;
    int nb_sites = seq_a.length();
    float dist;

    int k; // Compteur
    float dblCorrespandance; // Nombre de correspondances entre les sites
    int intPosComparable; // Nombre de positions comparables, l� o� il n'y a pas de gaps
    int intGaps; // Les lacunes contenues dans les s�quences
    float dblD; // Uncorrected distance


    dblCorrespandance = 0;
    intPosComparable = 0;
    intGaps = 0;

    for (k = 1; k <= nb_sites; k++) {
        if ((seq_a[k] == seq_b[k]) && (seq_a[k] != '-') && (seq_a[k] != '?'))
            dblCorrespandance++;
        else if ((seq_a[k] == '-') || (seq_a[k] == '?') ||
                (seq_b[k] == '-') || (seq_b[k] == '?'))
            intGaps++;
    }
    intPosComparable = nb_sites - intGaps;

    if (intPosComparable != 0) {
        dblD = 1 - dblCorrespandance / intPosComparable;
        dblD = 1 - dblD - 0.2 * dblD * dblD;
        if (dblD <= 0) {
            //non comparable
            dist = INFINITY;
        } else {
            dist = -log(dblD);
        }
    } else {
        //non comparable
        dist = INFINITY;
    }

    return dist;

}
 */

DistAtom Hamming::dist_2seq(string seq_a, string seq_b) {

    float intDist = 0.0;
    float realDist = 0.0;

    for (int i = 0; i < seq_a.length(); i++) {

        intDist += (seq_a[i] == seq_b[i] ? 0 : 1);

    }

    realDist = intDist / seq_a.length();

    return DistAtom(intDist, seq_a.length(), 0, realDist);
}

void Hamming::testIntrin() {
    /**
    int i;

    __m128d a, b, c;
    float x0[2] __attribute__((aligned(16))) = {1.2, 3.5};
    float x1[2] __attribute__((aligned(16))) = {0.7, 2.6};
    a = _mm_load_pd(x0);
    b = _mm_load_pd(x1);
    c = _mm_add_pd(a, b);
    _mm_store_pd(x0, c);
    for (i = 0; i < 2; i++) {
       cout << x0[i] << endl;
    }
     **/

}

DistAtom Hamming2::dist_2seq(string seq_a, string seq_b) {

    float pos_comparable = 0;
    float prop_gaps = 0;

    float two_gap = 0;
    float one_gap = 0;
    float ident = 0;
    float subst = 0;

    float intDist = 0.0;
    float realDist = 0.0;

    for (int i = 0; i < seq_a.length(); i++) {

        //if no gaps
        if (seq_a[i] != '-' && seq_b[i] != '-') {

            if (seq_a[i] == seq_b[i]) { // identities
                ident++;

            } else { //substitutions
                subst++;

            }


        } else if (seq_a[i] == '-' && seq_b[i] == '-') {
            two_gap++;

        } else {
            one_gap++;
        }

        if (seq_a[i] != seq_b[i]) {
            intDist++;
        }


        /*
        //identities
        if ((seq_a[i] == seq_b[i]) && (seq_a[i] != '-') && (seq_a[i] != '?')) {
            intCorrespandance++;
        //gaps
        } else if ((seq_a[i] == '-') || (seq_a[i] == '?') ||
                (seq_b[i] == '-') || (seq_b[i] == '?')) {
            intGaps++;
        //substitutions
        } else {
            intDist++;
        }
         */

    }

    intDist = subst + one_gap;
    pos_comparable = ident + subst + one_gap;

    prop_gaps = (one_gap + two_gap) / float(seq_a.length());

    if (prop_gaps <= 0.5) {
        realDist = intDist /= pos_comparable;
        //realDist = intDist /= seq_a.length();
    } else {
        intDist = numeric_limits<float>::max();
        realDist = numeric_limits<float>::max();
    }


    /*

   intPosComparable = seq_a.length() - intGaps;
   //si trop de gaps, incomparables
   if (intGaps >= seq_a.length() * 0.9) {
       intDist = numeric_limits<float>::max();
       realDist = numeric_limits<float>::max();
   } else {
       realDist = intDist /= seq_a.length();
   }
     */
    return DistAtom(intDist, seq_a.length(), 0, realDist);
    //debug
    //return DistAtom(prop_gaps, seq_a.length(), 0, prop_gaps);
}

void JukesKantorNucl::set_penality(float penality) {
    penalty_ = penality;
}

JukesKantorNucl::JukesKantorNucl(float penality) {
    cout << "================JUKES CANTOR NUCL" << endl;
    penalty_ = penality;
}

JukesKantorNucl::~JukesKantorNucl() {

}

/*************************************************************************************
/*	Nom			:	p_JukesCantorNucleo
/*	Param�tres	:	pmatSites       (in) : Matrice de sites
/*					pmatDistances   (in) : Matrice de distances
/*					pintNbreEspeces (in) : Nombre d'esp�ces
/*					pintNbreSites   (in) : Nombre de sites
/*					pdblPenalite    (in) : P�nalit� donn�e par l'utilisateur
/*	Retour		:	-
/*	Objectif	:	Comparer les s�quences deux par deux, en utilisant la m�thode
/*					Jukes-Cantor pour nucl�otides, et stoker les distances entre elles
/*					dans la matrice des distances.
 **************************************************************************************/
DistAtom JukesKantorNucl::dist_2seq(string seq_a, string seq_b) {

    int nb_sites = seq_a.length();
    float dist;
    int k; // Compteurs
    int intCorrespandance; // Nombre de correspondances entre les sites
    int intPosComparable; // Nombre de positions comparables, la o� il n'y a pas de gaps
    int intGaps; // Les lacunes contenues dans les sequences
    float dblD; // Uncorrected distance
    float dblb; // Param�tre b

    dblb = 3. / 4;

    intCorrespandance = 0;
    intGaps = 0;

    for (k = 1; k <= nb_sites; k++) {
        if ((seq_a[k] == seq_b[k]) && (seq_a[k] != '-') && (seq_a[k] != '?'))
            intCorrespandance++;
        else if ((seq_a[k] == '-') || (seq_a[k] == '?') ||
                (seq_b[k] == '-') || (seq_b[k] == '?'))
            intGaps++;
    }
    intPosComparable = nb_sites - intGaps;

    if (intPosComparable != 0) {
        dblD = 1 - intCorrespandance / (intPosComparable + penalty_ * intGaps);
        dblD = dblD / dblb;
        if (1 - dblD <= 0) dist = numeric_limits<float>::max();
        else dist = -dblb * log(1 - dblD);
    } else {
        dist = numeric_limits<float>::max();
    }
    return DistAtom(numeric_limits<float>::max(), intPosComparable, intGaps, dist);

}

void JukesKantorProt::set_penality(float penality) {
    penality_ = penality;
}

JukesKantorProt::JukesKantorProt(float penality) {
    penality_ = penality;
}

JukesKantorProt::~JukesKantorProt() {

}

/*************************************************************************************
/*	Nom			:	p_JukesCantorProt
/*	Param�tres	:	pmatSites       (in) : Matrice de sites
/*					pmatDistances   (in) : Matrice de distances
/*					pintNbreEspeces (in) : Nombre d'esp�ces
/*					pintNbreSites   (in) : Nombre de sites
/*					pdblPenalite    (in) : P�nalit� donn�e par l'utilisateur
/*	Retour		:	-
/*	Objectif	:	Comparer les s�quences deux par deux, en utilisant la m�thode
/*					Jukes-Cantor pour prot�ines, et stoker les distances entre elles
/*					dans la matrice des distances.
 **************************************************************************************/
DistAtom JukesKantorProt::dist_2seq(string seq_a, string seq_b) {

    int nb_sites = seq_a.length();
    float dist;

    int k; // Compteurs
    int intCorrespandance; // Nombre de correspondances entre les sites
    int intPosComparable; // Nombre de positions comparables, l� o� il n'y a pas de gaps
    int intGaps; // Les lacunes contenues dans les s�quences
    float dblD; // Uncorrected distance
    float dblb; // Param�tre b

    dblb = 19. / 20;


    intCorrespandance = 0;
    intGaps = 0;

    for (k = 1; k <= nb_sites; k++) {
        if ((seq_a[k] == seq_b[k]) && (seq_a[k] != '-') && (seq_a[k] != '?'))
            intCorrespandance++;
        else if ((seq_a[k] == '-') || (seq_a[k] == '?') ||
                (seq_b[k] == '-') || (seq_b[k] == '?'))
            intGaps++;
    }
    intPosComparable = nb_sites - intGaps;

    if (intPosComparable != 0) {
        dblD = 1.0 - intCorrespandance / (intPosComparable + penality_ * intGaps);
        dblD = dblD / dblb;
        if (1 - dblD <= 0)
            dist = numeric_limits<float>::max();
        else
            dist = -dblb * log(1 - dblD);
    } else
        dist = numeric_limits<float>::max();

    return DistAtom(numeric_limits<float>::max(), intPosComparable, intGaps, dist);
    //if(pmatDistances[j][i] < 0 || pmatDistances[j][i] > 10)
    //			printf("\n%d %d %lf",i,j,dist);


}

/*************************************************************************************
/*	Nom			:	p_KimuraProtein
/*	Param�tres	:	pmatSites       (in) : Matrice de sites
/*					pmatDistances   (in) : Matrice de distances
/*					pintNbreEspeces (in) : Nombre d'esp�ces
/*					pintNbreSites   (in) : Nombre de sites
/*	Retour		:	-
/*	Objectif	:	Comparer les s�quences deux par deux, en utilisant la m�thode
/*					Kimura Protein, et stoker les distances entre elles dans la matrice
/*					des distances.
 **************************************************************************************/
DistAtom KimProt::dist_2seq(string seq_a, string seq_b) {
    //cout << "------------------k2p_2seq" << endl;
    int nb_sites = seq_a.length();
    float dist;

    int k; // Compteur
    float dblCorrespandance; // Nombre de correspondances entre les sites
    int intPosComparable; // Nombre de positions comparables, l� o� il n'y a pas de gaps
    int intGaps; // Les lacunes contenues dans les s�quences
    float dblD; // Uncorrected distance


    dblCorrespandance = 0;
    intPosComparable = 0;
    intGaps = 0;

    for (k = 1; k <= nb_sites; k++) {
        if ((seq_a[k] == seq_b[k]) && (seq_a[k] != '-') && (seq_a[k] != '?'))
            dblCorrespandance++;
        else if ((seq_a[k] == '-') || (seq_a[k] == '?') ||
                (seq_b[k] == '-') || (seq_b[k] == '?'))
            intGaps++;
    }
    intPosComparable = nb_sites - intGaps;

    if (intPosComparable != 0) {
        dblD = 1 - dblCorrespandance / intPosComparable;
        dblD = 1 - dblD - 0.2 * dblD * dblD;
        if (dblD <= 0) {
            //non comparable
            dist = numeric_limits<float>::max();
        } else {
            dist = -log(dblD);
        }
    } else {
        //non comparable
        dist = numeric_limits<float>::max();
    }

    return DistAtom(numeric_limits<float>::max(), intPosComparable, intGaps, dist);

}


//load inherited fields

Blosum80::Blosum80() {
    //ftp://ftp.ncbi.nih.gov/blast/matrices/BLOSUM80
    //matrices
    //mat_prot_ident_ += "A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V", "B", "Z", "X", "_";
    mat_prot_ident_ = list_of("A") ("R") ("N") ("D") ("C") ("Q") ("E") ("G") ("H") ("I") ("L") ("K") ("M") ("F") ("P") ("S") ("T") ("W") ("Y") ("V") ("B") ("Z") ("X") ("*");

    mat_prot_ += list_of(7)(-3)(-3)(-3)(-1)(-2)(-2)(0)(-3)(-3)(-3)(-1)(-2)(-4)(-1)(2)(0)(-5)(-4)(-1)(-3)(-2)(-1)(-8);
    mat_prot_ += list_of(-3)(9)(-1)(-3)(-6)(1)(-1)(-4)(0)(-5)(-4)(3)(-3)(-5)(-3)(-2)(-2)(-5)(-4)(-4)(-2)(0)(-2)(-8);
    mat_prot_ += list_of(-3)(-1)(9)(2)(-5)(0)(-1)(-1)(1)(-6)(-6)(0)(-4)(-6)(-4)(1)(0)(-7)(-4)(-5)(5)(-1)(-2)(-8);
    mat_prot_ += list_of(-3)(-3)(2)(10)(-7)(-1)(2)(-3)(-2)(-7)(-7)(-2)(-6)(-6)(-3)(-1)(-2)(-8)(-6)(-6)(6)(1)(-3)(-8);
    mat_prot_ += list_of(-1)(-6)(-5)(-7)(13)(-5)(-7)(-6)(-7)(-2)(-3)(-6)(-3)(-4)(-6)(-2)(-2)(-5)(-5)(-2)(-6)(-7)(-4)(-8);
    mat_prot_ += list_of(-2)(1)(0)(-1)(-5)(9)(3)(-4)(1)(-5)(-4)(2)(-1)(-5)(-3)(-1)(-1)(-4)(-3)(-4)(-1)(5)(-2)(-8);
    mat_prot_ += list_of(-2)(-1)(-1)(2)(-7)(3)(8)(-4)(0)(-6)(-6)(1)(-4)(-6)(-2)(-1)(-2)(-6)(-5)(-4)(1)(6)(-2)(-8);
    mat_prot_ += list_of(0)(-4)(-1)(-3)(-6)(-4)(-4)(9)(-4)(-7)(-7)(-3)(-5)(-6)(-5)(-1)(-3)(-6)(-6)(-6)(-2)(-4)(-3)(-8);
    mat_prot_ += list_of(-3)(0)(1)(-2)(-7)(1)(0)(-4)(12)(-6)(-5)(-1)(-4)(-2)(-4)(-2)(-3)(-4)(3)(-5)(-1)(0)(-2)(-8);
    mat_prot_ += list_of(-3)(-5)(-6)(-7)(-2)(-5)(-6)(-7)(-6)(7)(2)(-5)(2)(-1)(-5)(-4)(-2)(-5)(-3)(4)(-6)(-6)(-2)(-8);
    mat_prot_ += list_of(-3)(-4)(-6)(-7)(-3)(-4)(-6)(-7)(-5)(2)(6)(-4)(3)(0)(-5)(-4)(-3)(-4)(-2)(1)(-7)(-5)(-2)(-8);
    mat_prot_ += list_of(-1)(3)(0)(-2)(-6)(2)(1)(-3)(-1)(-5)(-4)(8)(-3)(-5)(-2)(-1)(-1)(-6)(-4)(-4)(-1)(1)(-2)(-8);
    mat_prot_ += list_of(-2)(-3)(-4)(-6)(-3)(-1)(-4)(-5)(-4)(2)(3)(-3)(9)(0)(-4)(-3)(-1)(-3)(-3)(1)(-5)(-3)(-2)(-8);
    mat_prot_ += list_of(-4)(-5)(-6)(-6)(-4)(-5)(-6)(-6)(-2)(-1)(0)(-5)(0)(10)(-6)(-4)(-4)(0)(4)(-2)(-6)(-6)(-3)(-8);
    mat_prot_ += list_of(-1)(-3)(-4)(-3)(-6)(-3)(-2)(-5)(-4)(-5)(-5)(-2)(-4)(-6)(12)(-2)(-3)(-7)(-6)(-4)(-4)(-2)(-3)(-8);
    mat_prot_ += list_of(2)(-2)(1)(-1)(-2)(-1)(-1)(-1)(-2)(-4)(-4)(-1)(-3)(-4)(-2)(7)(2)(-6)(-3)(-3)(0)(-1)(-1)(-8);
    mat_prot_ += list_of(0)(-2)(0)(-2)(-2)(-1)(-2)(-3)(-3)(-2)(-3)(-1)(-1)(-4)(-3)(2)(8)(-5)(-3)(0)(-1)(-2)(-1)(-8);
    mat_prot_ += list_of(-5)(-5)(-7)(-8)(-5)(-4)(-6)(-6)(-4)(-5)(-4)(-6)(-3)(0)(-7)(-6)(-5)(16)(3)(-5)(-8)(-5)(-5)(-8);
    mat_prot_ += list_of(-4)(-4)(-4)(-6)(-5)(-3)(-5)(-6)(3)(-3)(-2)(-4)(-3)(4)(-6)(-3)(-3)(3)(11)(-3)(-5)(-4)(-3)(-8);
    mat_prot_ += list_of(-1)(-4)(-5)(-6)(-2)(-4)(-4)(-6)(-5)(4)(1)(-4)(1)(-2)(-4)(-3)(0)(-5)(-3)(7)(-6)(-4)(-2)(-8);
    mat_prot_ += list_of(-3)(-2)(5)(6)(-6)(-1)(1)(-2)(-1)(-6)(-7)(-1)(-5)(-6)(-4)(0)(-1)(-8)(-5)(-6)(6)(0)(-3)(-8);
    mat_prot_ += list_of(-2)(0)(-1)(1)(-7)(5)(6)(-4)(0)(-6)(-5)(1)(-3)(-6)(-2)(-1)(-2)(-5)(-4)(-4)(0)(6)(-1)(-8);
    mat_prot_ += list_of(-1)(-2)(-2)(-3)(-4)(-2)(-2)(-3)(-2)(-2)(-2)(-2)(-2)(-3)(-3)(-1)(-1)(-5)(-3)(-2)(-3)(-1)(-2)(-8);
    mat_prot_ += list_of(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(-8)(1);


    //cout << mat_prot_ident_.at(22) << endl;
    //cout << mat_prot_ident_.at(17) << endl;

    //ftp://ftp.ncbi.nih.gov/blast/matrices/BLOSUM80


    //cout << mat_prot_.at(22).at(17) << endl;

    mat_prot_expect_ = -0.7442;


}

//load inherited fields

Blosum62::Blosum62() {
    //ftp://ftp.ncbi.nih.gov/blast/matrices/BLOSUM80
    //matrices
    //mat_prot_ident_ += "A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V", "B", "Z", "X", "_";
    mat_prot_ident_ = list_of("A") ("R") ("N") ("D") ("C") ("Q") ("E") ("G") ("H") ("I") ("L") ("K") ("M") ("F") ("P") ("S") ("T") ("W") ("Y") ("V") ("B") ("Z") ("X") ("*");

    mat_prot_ += list_of (4)(-1)(-2)(-2)(0)(-1)(-1)(0)(-2)(-1)(-1)(-1)(-1)(-2)(-1)(1)(0)(-3)(-2)(0)(-2)(-1)(0)(-4);
    mat_prot_ += list_of (-1)(5)(0)(-2)(-3)(1)(0)(-2)(0)(-3)(-2)(2)(-1)(-3)(-2)(-1)(-1)(-3)(-2)(-3)(-1)(0)(-1)(-4);
    mat_prot_ += list_of (-2)(0)(6)(1)(-3)(0)(0)(0)(1)(-3)(-3)(0)(-2)(-3)(-2)(1)(0)(-4)(-2)(-3)(3)(0)(-1)(-4);
    mat_prot_ += list_of (-2)(-2)(1)(6)(-3)(0)(2)(-1)(-1)(-3)(-4)(-1)(-3)(-3)(-1)(0)(-1)(-4)(-3)(-3)(4)(1)(-1)(-4);
    mat_prot_ += list_of (0)(-3)(-3)(-3)(9)(-3)(-4)(-3)(-3)(-1)(-1)(-3)(-1)(-2)(-3)(-1)(-1)(-2)(-2)(-1)(-3)(-3)(-2)(-4);
    mat_prot_ += list_of (-1)(1)(0)(0)(-3)(5)(2)(-2)(0)(-3)(-2)(1)(0)(-3)(-1)(0)(-1)(-2)(-1)(-2)(0)(3)(-1)(-4);
    mat_prot_ += list_of (-1)(0)(0)(2)(-4)(2)(5)(-2)(0)(-3)(-3)(1)(-2)(-3)(-1)(0)(-1)(-3)(-2)(-2)(1)(4)(-1)(-4);
    mat_prot_ += list_of (0)(-2)(0)(-1)(-3)(-2)(-2)(6)(-2)(-4)(-4)(-2)(-3)(-3)(-2)(0)(-2)(-2)(-3)(-3)(-1)(-2)(-1)(-4);
    mat_prot_  += list_of (-2)(0)(1)(-1)(-3)(0)(0)(-2)(8)(-3)(-3)(-1)(-2)(-1)(-2)(-1)(-2)(-2)(2)(-3)(0)(0)(-1)(-4);
    mat_prot_ += list_of (-1)(-3)(-3)(-3)(-1)(-3)(-3)(-4)(-3)(4)(2)(-3)(1)(0)(-3)(-2)(-1)(-3)(-1)(3)(-3)(-3)(-1)(-4);
    mat_prot_ += list_of (-1)(-2)(-3)(-4)(-1)(-2)(-3)(-4)(-3)(2)(4)(-2)(2)(0)(-3)(-2)(-1)(-2)(-1)(1)(-4)(-3)(-1)(-4);
    mat_prot_ += list_of (-1)(2)(0)(-1)(-3)(1)(1)(-2)(-1)(-3)(-2)(5)(-1)(-3)(-1)(0)(-1)(-3)(-2)(-2)(0)(1)(-1)(-4);
    mat_prot_ += list_of (-1)(-1)(-2)(-3)(-1)(0)(-2)(-3)(-2)(1)(2)(-1)(5)(0)(-2)(-1)(-1)(-1)(-1)(1)(-3)(-1)(-1)(-4);
    mat_prot_ += list_of (-2)(-3)(-3)(-3)(-2)(-3)(-3)(-3)(-1)(0)(0)(-3)(0)(6)(-4)(-2)(-2)(1)(3)(-1)(-3)(-3)(-1)(-4);
    mat_prot_ += list_of (-1)(-2)(-2)(-1)(-3)(-1)(-1)(-2)(-2)(-3)(-3)(-1)(-2)(-4)(7)(-1)(-1)(-4)(-3)(-2)(-2)(-1)(-2)(-4);
    mat_prot_ += list_of (1)(-1)(1)(0)(-1)(0)(0)(0)(-1)(-2)(-2)(0)(-1)(-2)(-1)(4)(1)(-3)(-2)(-2)(0)(0)(0)(-4);
    mat_prot_ += list_of (0)(-1)(0)(-1)(-1)(-1)(-1)(-2)(-2)(-1)(-1)(-1)(-1)(-2)(-1)(1)(5)(-2)(-2)(0)(-1)(-1)(0)(-4);
    mat_prot_ += list_of (-3)(-3)(-4)(-4)(-2)(-2)(-3)(-2)(-2)(-3)(-2)(-3)(-1)(1)(-4)(-3)(-2)(11)(2)(-3)(-4)(-3)(-2)(-4);
    mat_prot_ += list_of (-2)(-2)(-2)(-3)(-2)(-1)(-2)(-3)(2)(-1)(-1)(-2)(-1)(3)(-3)(-2)(-2)(2)(7)(-1)(-3)(-2)(-1)(-4);
    mat_prot_ += list_of (0)(-3)(-3)(-3)(-1)(-2)(-2)(-3)(-3)(3)(1)(-2)(1)(-1)(-2)(-2)(0)(-3)(-1)(4)(-3)(-2)(-1)(-4);
    mat_prot_ += list_of (-2)(-1)(3)(4)(-3)(0)(1)(-1)(0)(-3)(-4)(0)(-3)(-3)(-2)(0)(-1)(-4)(-3)(-3)(4)(1)(-1)(-4);
    mat_prot_ += list_of (-1)(0)(0)(1)(-3)(3)(4)(-2)(0)(-3)(-3)(1)(-1)(-3)(-1)(0)(-1)(-3)(-2)(-2)(1)(4)(-1)(-4);
    mat_prot_ += list_of (0)(-1)(-1)(-1)(-2)(-1)(-1)(-1)(-1)(-1)(-1)(-1)(-1)(-1)(-2)(0)(0)(-2)(-1)(-1)(-1)(-1)(-1)(-4);
    mat_prot_ += list_of (-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(-4)(1);


    //cout << mat_prot_ident_.at(22) << endl;
    //cout << mat_prot_ident_.at(17) << endl;

    //ftp://ftp.ncbi.nih.gov/blast/matrices/BLOSUM62


    //cout << mat_prot_.at(22).at(17) << endl;

    mat_prot_expect_ = -0.5209;


}

//constructor

ScoreDist::ScoreDist(ApplicationData* appl_data) {

    // mat_prot_ = BLOSUM80_E;

    if (appl_data->protmatrix_ == eBLOSUM80) {
        matrix_ = new Blosum80();
    } else if (appl_data->protmatrix_ == eBLOSUM62) {
        matrix_ = new Blosum62();

    //cout << " mat_prot_ident_[1]: " << matrix_->getMatProtIdent().at(1) << endl;
    //cout << " mat_prot_[1][5]: " << matrix_->getMatProt().at(22).at(17) << endl;
    }

}




DistAtom ScoreDist::dist_2seq(string seq_a, string seq_b) {
    //cout << "------------------k2p_2seq" << endl;
    //cout << "seq_a: " << seq_a << endl;
    //cout << "seq_b: " << seq_b << endl;


    int len = seq_a.length();

    float sigma_s1_s2 = simple_dist_2seq(seq_a, seq_b);
    float sigma_s1_s1 = simple_dist_2seq(seq_a, seq_a);
    float sigma_s2_s2 = simple_dist_2seq(seq_b, seq_b);
    float sigma_r_l = matrix_->getMatProtExpect() * len;

    //correct lower_bound
    if (sigma_s1_s2 < sigma_r_l) {
        sigma_s1_s2 = sigma_r_l;
    }


    float sigma_n = sigma_s1_s2 - sigma_r_l;
    float sigma_u_s1_s2 = (sigma_s1_s1 + sigma_s2_s2) / 2;
    float sigma_un = sigma_u_s1_s2 - sigma_r_l;
    float dist_01 = sigma_n /sigma_un;

    //poisson process correction
    float d_r = - log (dist_01) * 100 ;
    //calibration constant
    float c = 1.3370;

    float d_s = c * d_r;

    /*Evolutionary distances of 250–300 PAM units are commonly considered as the maximum
     * for reasonable distance estimation and, therefore,
     * the Scoredist estimate ds is restricted to the interval [0, 300] PAM.
     */
    float dist = 0;

    float MAX_PAM = 1000;


    //dist = c * dist_01;

    if (d_s > MAX_PAM) {
       dist  = MAX_PAM;
    }



    // cout << "dist: " << dist << endl;
    //wrap d_s
    return DistAtom(floor(dist*seq_a.length()), seq_a.length(), 0, dist);

}

float ScoreDist::simple_dist_2seq(string seq_a, string seq_b) {
    //cout << "------------------k2p_2seq" << endl;
    int nb_sites = seq_a.length();
    float s = 0.0;


    //sum
    for (int k = 0; k < nb_sites; k++) {
        s += dist_2car(seq_a.substr(k, 1), seq_b.substr(k, 1));

    }

    return s;

}

float ScoreDist::dist_2car(string car_a, string car_b) {

    float one_dist = 0.0;


    //cout << "car_a: " << car_a << endl;
    //cout << "car_b: " << car_b << endl;

    int idx_a = std::find(matrix_->getMatProtIdent().begin(), matrix_->getMatProtIdent().end(), car_a) - matrix_->getMatProtIdent().begin();
    int idx_b = std::find(matrix_->getMatProtIdent().begin(), matrix_->getMatProtIdent().end(), car_b) - matrix_->getMatProtIdent().begin();


    //underscore or other defaults to *
    if (idx_a == matrix_->getMatProtIdent().size()) {
        car_a = "*";
        //and refind
        idx_a = std::find(matrix_->getMatProtIdent().begin(), matrix_->getMatProtIdent().end(), car_a) - matrix_->getMatProtIdent().begin();
    }

    if (idx_b == matrix_->getMatProtIdent().size()) {
        car_b = "*";
        //and refind
        idx_b = std::find(matrix_->getMatProtIdent().begin(), matrix_->getMatProtIdent().end(), car_b) - matrix_->getMatProtIdent().begin();
    }

    one_dist = matrix_->getMatProt().at(idx_a).at(idx_b);

    //cout << "one_dist: " << one_dist << endl;

    return one_dist;


}

