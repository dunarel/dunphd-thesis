/* 
 * File:   distance_measures.h
 * Author: root
 *
 * Created on February 1, 2010, 4:53 PM
 */

#ifndef _DISTANCE_MEASURES_H
#define	_DISTANCE_MEASURES_H

#include <iostream>
#include <string>
#include "dist_atom.h"
#include "ProteinMatrix.h"
//#include <boost/array.hpp>
#include "application_data.hpp"

using namespace std;


namespace uqam_doc {

    /*
    class DistSeqFuncStatic {
    public:
        static float hamming_2seq(string seq_a, string seq_b);
        static float kimprot_2seq(string seq_a, string seq_b);
    };
     */

    //////////////// Interface - Classe abstraite

    class DistSeqInterface {
    public:
        virtual DistAtom dist_2seq(string seq_a, string seq_b) = 0; //Denotes pure virtual Function Definition
    };

    /////////////////// calculateurs de distances //////////////////////////////////

    class Hamming : public DistSeqInterface {
    public:

        DistAtom dist_2seq(string seq_a, string seq_b);
        void testIntrin();
    };

    class Hamming2 : public DistSeqInterface {
    public:

        DistAtom dist_2seq(string seq_a, string seq_b);
    };

    class JukesKantorNucl : public DistSeqInterface {
    public:
        float penalty_;

        //constructors
        JukesKantorNucl(float penality);
        virtual ~JukesKantorNucl();

        void set_penality(float penality);
        DistAtom dist_2seq(string seq_a, string seq_b);
    };

    class JukesKantorProt : public DistSeqInterface {
    public:
        float penality_;
        //constructors
        JukesKantorProt(float penality);
        virtual ~JukesKantorProt();

        void set_penality(float penality);
        DistAtom dist_2seq(string seq_a, string seq_b);
    };

    class KimProt : public DistSeqInterface {
    public:

        DistAtom dist_2seq(string seq_a, string seq_b);
    };

    class Blosum80 : public ProteinMatrix {
    public:

        Blosum80();

    };

    class Blosum62 : public ProteinMatrix {
        public:

            Blosum62();

        };



    class ScoreDist : public DistSeqInterface {
    public:

        ScoreDist(ApplicationData* appl_data);

        DistAtom dist_2seq(string seq_a, string seq_b);
        float simple_dist_2seq(string seq_a, string seq_b);
        float dist_2car(string car_a, string car_b);
        //


        ProteinMatrix *matrix_;







    };


}




#endif	/* _DISTANCE_MEASURES_H */


/*
void main() {
    Exforsys * arra[2];
    Exf1 e1;
    Exf2 e2;
    arra[0] = &e1;
    arra[1] = &e2;
    arra[0]->example();
    arra[1]->example();
}
 */

