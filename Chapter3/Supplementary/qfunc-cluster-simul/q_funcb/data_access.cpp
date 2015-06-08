
#include "data_access.h"
#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
#include <iomanip>

using namespace std;

using uqam_doc::Parsers;

Parsers::Parsers() {
}

Parsers::~Parsers() {
}




//read a csv file into a set

void Parsers::readSet(set<string>& st, string filename) {

    st.clear();

    string str,str1,str2;

    cout << "c_str= " << filename.c_str() << endl;
    ifstream file(filename.c_str());

    while (getline(file, str)) {
        //debugging first part

        bool pure = false;
        while (!pure) {
            int pos = str.find('\10', 0);
            if (pos == -1) {
                pure = true;
            } else {
              //extract character
               str1 = str.substr(0, pos); //--Enlever artefact \10
            str2 = str.substr(pos, str.size() - pos +1); //--Enlever artefact \10
            cout << "str1: " <<str1 << endl;
            cout << "str2: " <<str2 << endl;
            str = str1 + str2;

            }
            
        }

        cout << "added str : " << ">" << str << "<" << endl;
        st.insert(str);


    }





};

string Parsers::genRandDnaSeq(int len) {
    string dna_alphabet("ACGT-");
    int nucl_idx;

    string rand_dna_seq("");

    for (int i = 0; i < len; i++) {
        nucl_idx = (int) ((float) rand() / ((float) RAND_MAX + 1) * dna_alphabet.length());
        rand_dna_seq.push_back(dna_alphabet[nucl_idx]);
    }
    //cout << "rand_dna_seq: " << rand_dna_seq << endl;
    return rand_dna_seq;
};


