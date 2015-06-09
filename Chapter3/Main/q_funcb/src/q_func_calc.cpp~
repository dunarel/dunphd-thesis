/* 
 * File:   q_func_calc.cpp
 * Author: Dunarel Badescu
 * 
 * Created on December 28, 2008, 9:21 PM
 */
#define arraysize(ar)  (sizeof(ar) / sizeof(ar[0]))

#include "q_func_calc.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <set>
#include <iterator>
#include <cmath>
#include <ctime>
#include "application_data.h"
#include "data_access.h"
#include "distance_measures.h"
#include "auto_win_q.h"
// #include "stl_algo.h"
//#include <xmmintrin.h>

#include <omp.h>
#include <stdio.h>
#include <algorithm>


using namespace std;
using namespace uqam_doc;

using uqam_doc::WinQ;


using uqam_doc::qFuncCalc;
using uqam_doc::Parsers;


//custom constructor

qFuncCalc::qFuncCalc(ApplicationData* appl_data) {

    //take application data pointer
    appl_data_ = appl_data;

    //take parameters for just member functions
    //msa_fasta_ = appl_data.msa_fasta_;
    //ids_work_csv_ = appl_data.ids_work_csv_;

    //x_ident_csv_ = appl_data.x_ident_csv_;
    //a_group_csv_ = appl_data.a_group_csv_;
    //b_group_csv_ = appl_data.b_group_csv_;

    //q_func_csv_ = appl_data.q_func_csv_;
    //align_type_ = appl_data.align_type_;
    //dist_ = appl_data.dist_;
    //mat_ = appl_data.mat_;

    cout << "qFuncCalc.dist_:" << appl_data_->dist_ << endl;

    //calculateur virtuel fonction du parametre align_type_
    if (appl_data_->dist_ == eHAM) {
        cout << "qFuncCalc.dist_: Hamming" << endl;
        //      dist_seq_ = new DistSeqDna;
        //initialisation fonction distance
        //dist_func_ = &DistSeqFuncStatic::hamming_2seq;
        //initialize calculator
        dist_calc_ = new Hamming();


    } else if (appl_data_->dist_ == eJUKES_CANTOR_NUCL) {
        cout << "qFuncCalc.dist_: Jukes Cantor nucl" << endl;
        //default gap penality 0.1
        dist_calc_ = new JukesKantorNucl(0.001);

    } else if (appl_data_->dist_ == eKIM_PROT) {
        cout << "qFuncCalc.dist_: Kimprot" << endl;
        //   dist_seq_ = new DistSeqProt;
        //initialisation fonction distance
        //dist_func_ = &DistSeqFuncStatic::kimprot_2seq;
        //initialize calculator
        dist_calc_ = new KimProt();

    } else if (appl_data_->dist_ == eSCOREDIST) {
        cout << "qFuncCalc.dist_: ScoreDist" << endl;
        //   dist_seq_ = new DistSeqProt;
        //initialisation fonction distance
        //dist_func_ = &DistSeqFuncStatic::kimprot_2seq;
        //initialize calculator
        dist_calc_ = new ScoreDist(appl_data_);

    }




    //pval_ = appl_data.pval_;

    //nombre de replicats
    NB_REPL_ = 100000;


    //locally modifiable fields
    //window length
    win_l_ = appl_data_->win_l_;
    //
    //q_func_opt_max_idx_ = appl_data.q_func_opt_max_idx_;

    //window step
    //win_step_ = appl_data.win_step_;

    //type of calculation simple/auto/single
    //calc_type_ = appl_data.calc_type_;

    //type of partition optimization
    //optim_type_ = appl_data.optim_type_;



}

qFuncCalc::~qFuncCalc() {
    // delete polymorphic calculator
    delete dist_calc_;

}

void qFuncCalc::readXIdentCsv() {

    // string a("files//x_ident.csv");

    x_ident_.clear();
    Parsers::readSet(x_ident_, appl_data_->x_ident_csv_);


    //verify result
    cout << "readXIdentCsv, x_ident_ size: " << x_ident_.size() << endl;

    for (set<string>::iterator iter = x_ident_.begin(); iter != x_ident_.end(); iter++) {
        cout << "readXIdentCsv, elem :" << *iter << endl;

    }
}

void qFuncCalc::readIdsWork() {

    // string a("files//x_ident.csv");

    ids_work_.clear();
    Parsers::readSet(ids_work_, appl_data_->ids_work_csv_);


    //verify result
    cout << "readIdsWork, ids_work_ size: " << ids_work_.size() << endl;

    for (set<string>::iterator iter = ids_work_.begin(); iter != ids_work_.end(); iter++) {
        cout << "readIdsWork, elem :>" << *iter << "<" << endl;

    }
}


//read MSA, into align_mult_types_ hash then,
//collect all identifiers into all_types_ set
void qFuncCalc::readMsaFasta() {

    align_mult_types_.clear();

    /*
    ifstream inp;
    ofstream out;
    string myFileName;


    myFileName = "mydata.txt";
    inp.open(myFileName.c_str(), ifstream::in);
    inp.close();
    if(inp.fail())
    {
    inp.clear(ios::failbit);
    cout << "Writing to file..." << myFileName.c_str() << endl;
    out.open(myFileName.c_str(), ofstream::out);
    out << "Hello World" << endl;
    out.close();
    }
    else
    {
    cout << "Error...file """ << myFileName.c_str() << """ exists" << endl;
    }

     */

    //ifstream file("files//gene_align_seqs_E1.tfa");
    cout << "c_str= " << appl_data_->msa_fasta_.c_str() << endl;
    ifstream file(appl_data_->msa_fasta_.c_str());

    ofstream outf("files//gene_align_seqs_E1_res.tfa");

    string str;
    int counter = 0;

    string desc = "";
    string seq_line = "";
    string seq = "";

    //Desc = D / Seq = S

    string first_car = "";

    const int DES = 0;
    const int SEQ = 1;

    int state = DES;

    while (getline(file, str) /* && counter < 10 */) {
        //debugging first part


        if (str.length() >= 1) {
            first_car = str.substr(0, 1);
        } else {
            first_car = "";
        }


        switch (state) {

            case DES:
                if (first_car == ">") {
                    desc = str.substr(1, str.length() - 1);
                    cout << "state" << state << "desc: [" << desc << "]" << endl;
                    seq = "";
                    //go on to sequence
                    state = SEQ;

                } else {
                }

                break;

            case SEQ:
                if (first_car == ">") {
                    //Final version for desc & seq
                    outf << "desc: [" << desc << "]" << endl;
                    outf << "seq: [" << seq << "]" << endl;
                    //align_mult_types_.insert(pair<string, string > (desc, seq));
                    align_mult_types_[desc] = seq;
                    //begin with description
                    state = DES;
                    //load description
                    desc = str.substr(1, str.length() - 1);
                    cout << "state" << state << "desc: [" << desc << "]" << endl;
                    seq = "";
                    //go on to sequence
                    state = SEQ;

                } else {
                    //int nl = seq.find("\n");
                    //cout << "nl_pos: " << nl << endl;
                    //seq_line = str.substr(0,str.length()-1);
                    seq_line = str;
                    seq += seq_line;

                }



        }

        //        cout << "first_car: [" << first_car << "]" << str << endl;

        /*
         vector<string> tokenList;
         split(tokenList, str, is_any_of(": "), token_compress_on);

        // BOOST_FOREACH(string &t, tokenList)
        // {
        //   t+="!";
        // }


        align_mult_types.insert ( pair<string,string>(tokenList.at(0),tokenList.at(1)) );
        cout << tokenList.at(0) << endl;
        cout << "##################################" << endl;
         */

        counter += 1;


    }
    file.close();

    //recuperate last unfinished sequence
    outf << "desc: [" << desc << "]" << endl;
    outf << "seq: [" << seq << "]" << endl;
    //align_mult_types_.insert(pair<string, string > (desc, seq));
    align_mult_types_[desc] = seq;


    outf.close();

    //show sequences
    map<string, string>::iterator it;
    for (it = align_mult_types_.begin(); it != align_mult_types_.end(); it++) {
        //cout << (*it).first << " => " << (*it).second << endl;
    }

    //charge all_types
    for (it = align_mult_types_.begin(); it != align_mult_types_.end(); it++) {
        //cout << (*it).first << " => " << (*it).second << endl;
        all_types_.insert((*it).first);
        cout << "readMsaFasta: ["<<(*it).first <<"]"<< " ---> " << (*it).second << endl;
        //cout << p.first << endl;
    }

    cout << "readMsaFasta, all_types size: " << all_types_.size() << endl;

    calcMsaLength();

}

void qFuncCalc::genRandNuclMsaFasta() {


    //rewrite sequences
    map<string, string>::iterator it;
    for (it = align_mult_types_.begin(); it != align_mult_types_.end(); it++) {
        //title
        cout << (*it).first << endl;

        cout << " orig: => " << (*it).second << endl;
        //replace
        (*it).second = Parsers::genRandDnaSeq(align_length_);

        cout << " random: => " << (*it).second << endl;

    }

}

void qFuncCalc::calcMsaLength() {

    align_length_ = 0;
    //determine align length
    //maximum of all individual lenghth
    map<string, string>::iterator it;
    for (it = align_mult_types_.begin(); it != align_mult_types_.end(); it++) {
        align_length_ = max(align_length_, (int) (*it).second.length());
    }

}

void qFuncCalc::eliminateNonUsed() {

    //vectors need sorting
    //sort(all_types_.begin(), all_types_.end());
    //sort(x_ident_.begin(), x_ident_.end());
    y_ident_.clear();
    set_difference(all_types_.begin(), all_types_.end(),
            x_ident_.begin(), x_ident_.end(),
            inserter(y_ident_, y_ident_.begin()));


    //reformulate x_ident_ as just those identifiers used
    //sort(y_ident_.begin(), y_ident_.end());

    x_ident_.clear();
    set_difference(all_types_.begin(), all_types_.end(),
            y_ident_.begin(), y_ident_.end(),
            inserter(x_ident_, x_ident_.begin()));

    //identifiers are final and ordered (set containers)
    //load simpler containers(vectors) x_seqs_, y_seqs_
    //for (vector<string>::iterator iter = x_ident_.begin(); iter != x_ident_.end(); iter++) {
    //    x_seqs_.push_back(align_mult_types_[*iter]);
    //}
    //
    //for (vector<string>::iterator iter = y_ident_.begin(); iter != y_ident_.end(); iter++) {
    //    y_seqs_.push_back(align_mult_types_[*iter]);
    //}

    //set nx_, ny_ final dimensions
    nx_ = x_ident_.size();
    ny_ = y_ident_.size();

    cout << "eliminateNonUsed, nx_ " << nx_ << endl;
    cout << "eliminateNonUsed, ny_ " << ny_ << endl;

    //free align_mult_types_
    //needed by calcReplSameIdentDifCol
    //align_mult_types_.clear();

}

//need to have no header and no quotes
void qFuncCalc::filterIdsWork() {

    //temp
    set<string> tmp;


    //only intersection
    tmp.clear();
    set_intersection(all_types_.begin(), all_types_.end(),
            ids_work_.begin(), ids_work_.end(),
            inserter(tmp, tmp.begin()));

    cout << "filterIdsWork, all_types_ size: " << all_types_.size() << endl;
    cout << "filterIdsWork, ids_work_ size: " << ids_work_.size() << endl;
    cout << "filterIdsWork, tmp size: " << tmp.size() << endl;

    //copy constructor
    all_types_=tmp;

    //verify result
    /*
    cout << "filterIdsWork, all_types_ size: " << all_types_.size() << endl;

    for (set<string>::iterator iter = all_types_.begin(); iter != all_types_.end(); iter++) {
        cout << "filterIdsWork, all_types :" << *iter << endl;

    }

    for (set<string>::iterator iter = ids_work_.begin(); iter != ids_work_.end(); iter++) {
        cout << "filterIdsWork, ids_work_ :" << *iter << endl;

    }
     */


}

//just to verify the containers

void qFuncCalc::show_align_mult_types() {


    //show sequences

    /*
    cout << "align_mult_types: " << align_mult_types.size() << endl;
float
    map<string, string>::iterator it;
    for (it = align_mult_types.begin(); it != align_mult_types.end(); it++) {
        cout << (*it).first << " => " << (*it).second << endl;
    }
    
    cout << "nx_ size: " << nx_ << endl;
    cout << "ny_ size: " << ny_ << endl;


    vector<string>::iterator iter;
    for (iter = x_ident_.begin(); iter != x_ident_.end(); iter++) {
        cout << "show_align_mult_types,x_ident_ :" << *iter << endl;

    }

    for (iter = y_ident_.begin(); iter != y_ident_.end(); iter++) {
        cout << "show_align_mult_types,y_ident :" << *iter << endl;

    }
     */
}

/*
 * Calculate NB_REPL for a window dimension
 */
/* q_min: -0.0251251         q_max: 0.19446 */

/* q_min: -0.0312749         q_max: 0.194465 */

/* q_min: -0.0251251         q_max: 0.194465 */
void qFuncCalc::calcReplSameIdentSameCol(int win_l) {
    /*

      cout << "win_l: " << win_l << endl;

      int col;


      //vector<string> repl_X, repl_Y;
      //string seq_sub;

      //for all replicates
      //all_repl_X_.clear();
      //all_repl_Y_.clear();

      all_repl_.clear();
      //we know in advance the number of replicates
      all_repl_.reserve(NB_REPL_);

      for (int r = 0; r < NB_REPL_; r++) {
          //build individual replicates
          WinQ q_res = WinQ(nx_, ny_, dist_calc_);
          q_res.initEmptyAlign();

          //costruct a replicate by adding columns till window size
          for (int w = 0; w < win_l; w++) {
              //choose a random column till MSA length
              col = (int) ((float) rand() / ((float) RAND_MAX + 1) * align_length_);
              //cout << "col: " << col << endl;
              //add the caracter to the corresponding X sequence
              for (int i = 0; i < nx_; i++) {
                  //cout << "x_seqs_[i]: " << x_seqs_[i][col]  << endl;
                  q_res.align_mult_x_[i].insert(x_seqs_[i][col]);
                  //cout << "after i: " << i << "\t size: " << repl_X.size() << "\t repl_X[i]: " << repl_X[i] << endl;
                  //repl_X[0].push_back(car);
                  //repl_X[i].push_back(x_seqs_[i][col]);
              }

              //add the caracter to the corresponding X sequence
              for (int j = 0; j < ny_; j++) {
                  //repl_Y[j].push_back(y_seqs_[j][col]);
                  q_res.align_mult_y_[j].insert(y_seqs_[j][col]);
                  //cout << "after j: " << j << "\t size: " << repl_Y.size() << "\t repl_Y[j]: " << repl_Y[j] << endl;

              }



          }

          //calculate replicate results
          q_res.calcQRes();
          //cout << "Replicate q0: " << qRes.q0 << endl;

          //add results to the list of replicates results
          all_repl_.push_back(q_res);

      }

      //dump p-values
   
      for (vector< qResStruct >::iterator it = all_repl_res_.begin(); it != all_repl_res_.end(); it++) {
          cout << "p-val :" << (*it).q0 << endl;

      }


      cout << "all_repl_X: " << all_repl_X_.size() << endl;
      cout << "all_repl_Y: " << all_repl_Y_.size() << endl;
    

      float q_min = numeric_limits<float>::max();
      float q_max = 0;

      //float q_min_fn = * (vector<float>::iterator) min_element(all_repl_res_.begin(), all_repl_res_.end() );
      //float q_max_fn = max_element( all_repl_res_.begin(), all_repl_res_.end() );

      for (int i = 0; i < NB_REPL_; i++) {
          if (all_repl_[i].q_func_[0] < q_min) {
              q_min = all_repl_[i].q_func_[0];
          }
      }

      for (int i = 0; i < NB_REPL_; i++) {
          if (all_repl_[i].q_func_[0] > q_max) {
              q_max = all_repl_[i].q_func_[0];
          }

      }

      // cout << "q_min_fn: " << q_min_fn << "\t q_max_fn: " << q_max_fn;
      cout << "q_min: " << q_min << "\t q_max: " << q_max;




     */
}

/* q_min: -0.0456299         q_max: 0.0770964
 * q_min: -0.0456299         q_max: 0.0832992
 */
void qFuncCalc::calcReplSameIdentDifCol(int win_l) {
    /*
        qRes qRes;

        cout << "win_l: " << win_l << endl;

        int col;


        vector<string> repl_X, repl_Y;
        string seq_sub;

        //for all replicates
        all_repl_X_.clear();
        all_repl_Y_.clear();
        all_repl_res_.clear();

        for (int r = 0; r < NB_REPL; r++) {
            //build individual replicates
            repl_X.clear();
            for (vector<string>::iterator iter = x_ident_.begin(); iter != x_ident_.end(); iter++) {
                seq_sub = "";
                for (int i = 0; i < win_l; i++) {
                    col = (int) ((float) rand() / ((float) RAND_MAX + 1) * align_length_);
                    seq_sub += align_mult_types_[*iter].substr(col, 1);
                }
                //cout << seq_brut.length() << endl;
                repl_X.push_back(seq_sub);
                // cout << "seq_brut: " << seq_brut << endl;
            }
            //cout << " ------------------------------"<< endl;
            //cout << "repl_X: " << endl;

            repl_Y.clear();
            for (vector<string>::iterator iter = y_ident_.begin(); iter != y_ident_.end(); iter++) {
                seq_sub = "";
                for (int i = 0; i < win_l; i++) {
                    col = (int) ((float) rand() / ((float) RAND_MAX + 1) * align_length_);
                    seq_sub += align_mult_types_[*iter].substr(col, 1);
                }
                //cout << seq_brut.length() << endl;
                repl_Y.push_back(seq_sub);
                // cout << "seq_brut: " << seq_brut << endl;
            }
            //add replicate to list
            //all_repl_X_.push_back(repl_X);
            //all_repl_Y_.push_back(repl_Y);
            qRes = calcQRes(repl_X, repl_Y);
            //cout << "Replicate q0: " << qRes.q0 << endl;
            all_repl_res_.push_back(qRes);

        }

        //dump p-values
           for (vector< qRes >::iterator it = all_repl_res_.begin(); it != all_repl_res_.end(); it++) {
            //cout << "p-val :" << (*it).q0 << endl;

        }
    
        for (int i=0; i<all_repl_res_.size(); i++) {
        
        }



        //cout << "all_repl_X: " << all_repl_X_.size() << endl;
        //cout << "all_repl_Y: " << all_repl_Y_.size() << endl;

        float q_min = INFINITY;
        float q_max = 0;

        for (vector< qRes >::iterator it = all_repl_res_.begin(); it != all_repl_res_.end(); it++) {
           if ( (*it).qFunc[0] < q_min) {
               q_min = (*it).qFunc[0];
           }

           if ( (*it).qFunc[0] > q_max) {
               q_max = (*it).qFunc[0];
           }

        }

     for (int i=0; i<all_repl_res_.size(); i++) {
         for (int j = 0; j<qRes)
            if ( all_repl_res_[i].qFunc[j] < q_min) {
               q_min = (*it).qFunc[0];
           }

           if ( (*it).qFunc[0] > q_max) {
               q_max = (*it).qFunc[0];
           }
        }



        cout << "q_min: " << q_min << "\t q_max: " << q_max;



     */
}

/*
 * Calculate p-values based on (window) replicates for current q-result
 */
void qFuncCalc::calcPVal(WinQ& q_res) {

    //nombre de valeurs minimum et maximum par fonction
    //vector<int> p_val_inf, p_val_sup;
    //initialisation
    for (int j = 0; j < q_res.NB_FUNC_; j++) {
        q_res.q_p_val_inf_[j] = 0.0;
        q_res.q_p_val_sup_[j] = 0.0;

    }

    //for all replicates
    for (int i = 0; i < all_repl_.size(); i++) {
        //and all functions
        for (int j = 0; j < q_res.NB_FUNC_; j++) {
            //if replicate is less then our value
            if (all_repl_[i].q_func_[j] <= q_res.q_func_[j]) {
                //we count it as p-value inf
                q_res.q_p_val_inf_[j] += 1.0;

            }
            //if replicate is more then our value
            if (all_repl_[i].q_func_[j] >= q_res.q_func_[j]) {
                //we count it as p-value sup
                q_res.q_p_val_sup_[j] += 1.0;

            }

        }

    }

    //for all functions
    //scale p-values by sample size (nb replicates)
    for (int j = 0; j < q_res.NB_FUNC_; j++) {

        if (all_repl_.size() != 0) {
            q_res.q_p_val_inf_[j] /= (float) all_repl_.size();
            q_res.q_p_val_sup_[j] /= (float) all_repl_.size();
        }

    }


}

void qFuncCalc::calculate() {

    cout << "pval: " << appl_data_->pval_ << endl;

     cout << "pval: " << appl_data_->calc_type_ << endl;

    //cout << "-----------------0----------" << endl;
    time_t t, t0;
    t = time(NULL);

    ofstream pr(appl_data_->q_func_csv_.c_str());
    ofstream *pr_a;
    ofstream *pr_b;

    if (appl_data_->calc_type_ == eSingle) {

        pr_a = new ofstream(appl_data_->a_group_csv_.c_str());
        pr_b = new ofstream(appl_data_->b_group_csv_.c_str());

    }

    //print header

    //Simple include just simple
    if (appl_data_->calc_type_ == eSimple || appl_data_->calc_type_ == eAuto) {
        pr << "win_length"
                << ",x"
                << ",dXY"
                << ",dXY_inv"
                << ",vX"
                << ",vX_inv"
                << ",vY"
                << ",vY_inv"
                << ",Q0"
                << ",Q1"
                << ",Q2"
                << ",Q3"
                << ",Q4"
                << ",Q5"
                << ",Q6"
                << ",Q7"
                << ",nx"
                << ",ny"
                << ",gap_prop";

    }
    //Auto include both simple and auto fields
    if (appl_data_->calc_type_ == eAuto) {
        pr << ",A_dXY"
                << ",A_dXY_inv"
                << ",A_vX"
                << ",A_vX_inv"
                << ",A_vY"
                << ",A_vY_inv"
                << ",A_Q0"  //<< appl_data_->q_func_opt_max_idx_
                << ",A_Q1"
                << ",A_Q2"
                << ",A_Q3"
                << ",A_Q4"
                << ",A_Q5"
                << ",A_Q6"
                << ",A_Q7"
                << ",A_nx"
                << ",A_ny"
                << ",A_rand_idx"
                << ",A_adj_rand_idx"
                << ",A_ham_idx";

    }

    //Single include both auto fields
    if (appl_data_->calc_type_ == eSingle) {
        pr << ",A_dXY"
                << ",A_dXY_inv"
                << ",A_vX"
                << ",A_vX_inv"
                << ",A_vY"
                << ",A_vY_inv"
                << ",A_Q" << appl_data_->q_func_opt_max_idx_
                << ",A_nx"
                << ",A_ny";

    }

    pr << endl;





    std::pair<string, string> p;


    cout << "align_length: " << align_length_ << endl;


    // for (int win_length = 20; win_length >= 20; win_length--) {
    //int win_length = win_l_;

    //for each window size calculate its replicates
    if (appl_data_->pval_ == "repl") {
        calcReplSameIdentSameCol(appl_data_->win_l_);
    }

    //calcReplSameIdentDifCol(win_length);


    t0 = time(NULL) - t;
    t = time(NULL);

    //Single defines align length and win_step for one single iteration
    if (appl_data_->calc_type_ == eSingle) {
        win_l_= align_length_;

    }

    cout << "win_length: " << win_l_ << " t0: " << t0 << endl;
    cout << "align_length: " << align_length_ << endl;


    //#pragma omp parallel
//printf("Hello, world! This is thread %d of %d\n", omp_get_thread_num(), omp_get_num_threads());

//sleep(5);

int num_th = omp_get_num_procs();

#pragma omp parallel num_threads(num_th)
{

  #pragma omp for ordered schedule(dynamic)
  for (int x = 0; x <= (align_length_ - win_l_); x += appl_data_->win_step_) {

        //for (int x = 1; x < 2; x++) {
        cout << "x: " << x << ", thread:" << omp_get_thread_num() << " of "<< num_th << endl;
        //cout << " <= " << (align_length_ - win_l_) << "align_length_: " << align_length_
        //        << "****************************************************************************************"
        //        << endl;
        //Hamming intrin_test = Hamming();
        //intrin_test.testIntrin();


        //int x = 509;
        //cout << x << endl;
        //create a window
        //WinQ q_res = WinQ(nx_,ny_,dist_calc_);

        AutoWinQ q_res = AutoWinQ(*this, x);
        q_res.calculateDistMatrix();
        //q_res.outputDistanceMatrix();

        // Additive calculations
        if (appl_data_->calc_type_ == eSimple || appl_data_->calc_type_ == eAuto) {
            q_res.calcSimple();

        }

        //optimisation k-means
        if ((appl_data_->calc_type_ == eAuto || appl_data_->calc_type_ == eSingle) && appl_data_->optim_type_ == eKm) {
            q_res.testManyRandomSeeds();

        }

        //optimisation Neighbor-Joining
        if ((appl_data_->calc_type_ == eAuto || appl_data_->calc_type_ == eSingle) && appl_data_->optim_type_ == eNj) {
            q_res.testNjBipartitions();

        }


        #pragma omp ordered
        {
        //uncalculable should be common, cumulative
        //each calculation can make the window uncalculable
        if (!q_res.uncalculable_) {
            pr.precision(6);
            pr << win_l_
                    << "," << x;

            //common columns
            if (appl_data_->calc_type_ == eSimple || appl_data_->calc_type_ == eAuto ) {

                pr << "," << q_res.simple_window_->d_2g_[0][1] << "," << q_res.simple_window_->d_2g_inv_prop_[0][1]
                        << "," << q_res.simple_window_->v_1g_[0] << "," << q_res.simple_window_->v_1g_inv_prop_[0]
                        << "," << q_res.simple_window_->v_1g_[1] << "," << q_res.simple_window_->v_1g_inv_prop_[1]
                        << "," << q_res.simple_window_->q_func_[0]
                        << "," << q_res.simple_window_->q_func_[1]
                        << "," << q_res.simple_window_->q_func_[2]
                        << "," << q_res.simple_window_->q_func_[3]
                        << "," << q_res.simple_window_->q_func_[4]
                        << "," << q_res.simple_window_->q_func_[5]
                        << "," << q_res.simple_window_->q_func_[6]
                        << "," << q_res.simple_window_->q_func_[7]
                        << "," << q_res.simple_window_->ident_grouped_[0].size()
                        << "," << q_res.simple_window_->ident_grouped_[1].size()
                        << "," << q_res.simple_window_->gap_proportion_;

                //q_res.best_window_->outputGroupings(cout);

            }
            //columns only for auto
            if (appl_data_->calc_type_ == eAuto) {
                pr << "," << q_res.best_window_->d_2g_[0][1] << "," << q_res.best_window_->d_2g_inv_prop_[0][1]
                        << "," << q_res.best_window_->v_1g_[0] << "," << q_res.best_window_->v_1g_inv_prop_[0]
                        << "," << q_res.best_window_->v_1g_[1] << "," << q_res.best_window_->v_1g_inv_prop_[1]
                        //<< "," << q_res.best_window_->q_func_[q_res.q_func_opt_max_idx_]
                        << "," << q_res.best_window_->q_func_[0]
                        << "," << q_res.best_window_->q_func_[1]
                        << "," << q_res.best_window_->q_func_[2]
                        << "," << q_res.best_window_->q_func_[3]
                        << "," << q_res.best_window_->q_func_[4]
                        << "," << q_res.best_window_->q_func_[5]
                        << "," << q_res.best_window_->q_func_[6]
                        << "," << q_res.best_window_->q_func_[7]
                        //     << "," << q_res.best_window_->q_func_opt_max_val_
                        << "," << q_res.best_window_->ident_grouped_[0].size()
                        << "," << q_res.best_window_->ident_grouped_[1].size()
                        << "," << q_res.best_window_->randIndex()
                        << "," << q_res.best_window_->adjustedRandIndex()
                        << "," << q_res.best_window_->groupHamIndex();
                        

                //q_res.best_window_->outputGroupings(cout);

            }

            //columns for eSingle
            if (appl_data_->calc_type_ == eSingle) {
                pr << "," << q_res.best_window_->d_2g_[0][1] << "," << q_res.best_window_->d_2g_inv_prop_[0][1]
                        << "," << q_res.best_window_->v_1g_[0] << "," << q_res.best_window_->v_1g_inv_prop_[0]
                        << "," << q_res.best_window_->v_1g_[1] << "," << q_res.best_window_->v_1g_inv_prop_[1]
                        << "," << q_res.best_window_->q_func_[q_res.q_func_opt_max_idx_]
                        //     << "," << q_res.best_window_->q_func_opt_max_val_
                        << "," << q_res.best_window_->ident_grouped_[0].size()
                        << "," << q_res.best_window_->ident_grouped_[1].size();
                        
                //write a_group_csv, b_group_csv
                q_res.best_window_->outputGroupingsToFiles(*pr_a,*pr_b);
                //for reference
                //q_res.best_window_->outputGroupings(cout);

            }

            //end line
            pr << endl;
        }

        } //end pragma ordered
        /*

        //for each qRes calculate p-values
        //based on window replicates
        if (pval_ != "no") {
            calcPVal(q_res);
        }
         */



    } //end for x
}




    //} //end for win_length

    pr.close();

    if (appl_data_->calc_type_ == eSingle) {

        pr_a->close();
        pr_b->close();

    }

}


