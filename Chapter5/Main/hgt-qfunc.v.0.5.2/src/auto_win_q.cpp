/* 
 * File:   auto_win_q.cpp
 * Author: root
 * 
 * Created on February 10, 2010, 4:36 PM
 */

#include <limits>
#include <iostream>
#include <map>
#include <string>
#include <cmath>



//for random number generator
#include <boost/random/uniform_int.hpp>
#include <boost/random/variate_generator.hpp>

#include "auto_win_q.h"
#include "q_func_calc.h"
#include "distance_measures.h"
#include "BipartNj.h"


using namespace std;
using namespace uqam_doc;

using uqam_doc::AutoWinQ;
using uqam_doc::qFuncCalc;
using uqam_doc::BipartNj;

//give context msa and position to extract data himself
//AutoWinQ::AutoWinQ(qFuncCalc& ctx, int win_pos) : ctx_(ctx) {

AutoWinQ::AutoWinQ(qFuncCalc& ctx, int win_pos) {

    ctx_ = &ctx;

    win_pos_ = win_pos;

    //

    //a window has exactly the same types that its context
    //not all sequences, could be filtered with ids_work
    //using copy constructor
    ident_all_ = ctx_->all_types_;

    /*
    ident_all_.clear();
    //ident_all_.reserve(ctx_.align_mult_types_.size());


    //extract all identifiers
    
    map<string, string>::iterator it;
    set::iterator its;


    for (it = ctx_->align_mult_types_.begin(); it != ctx_->align_mult_types_.end(); ++it) {
        //load all identifiers
        //ident_all_.push_back((*it).first);
        ident_all_.insert((*it).first);
        //cout << (*it).first << endl;
        //cout << " whole  sequence: => " << (*it).second.substr(win_pos, ctx_.win_l_) << endl;

    }
     * */

    NB_GROUPS_ = 2;
    //empty before.
    //initialize group containers
    //we are in constructor
    v_1g_cumul_.resize(NB_GROUPS_, 0.0);
    v_1g_nb_.resize(NB_GROUPS_, 0.0);
    v_1g_inv_nb_.resize(NB_GROUPS_, 0.0);
    v_1g_inv_prop_.resize(NB_GROUPS_, 0.0);
    v_1g_.resize(NB_GROUPS_, 0.0);

    //initialize group containers
    vector<float> vd(NB_GROUPS_, 0.0);
    d_2g_cumul_.resize(NB_GROUPS_, vd);
    d_2g_nb_.resize(NB_GROUPS_, vd);
    d_2g_inv_nb_.resize(NB_GROUPS_, vd);
    d_2g_inv_prop_.resize(NB_GROUPS_, vd);
    d_2g_.resize(NB_GROUPS_, vd);

    //differences
    new_v_1g_cumul_.resize(NB_GROUPS_, 0.0);
    new_v_1g_nb_.resize(NB_GROUPS_, 0.0);
    new_v_1g_inv_nb_.resize(NB_GROUPS_, 0.0);
    new_v_1g_inv_prop_.resize(NB_GROUPS_, 0.0);
    new_v_1g_.resize(NB_GROUPS_, 0.0);

    new_d_2g_cumul_.resize(NB_GROUPS_, vd);
    new_d_2g_nb_.resize(NB_GROUPS_, vd);
    new_d_2g_inv_nb_.resize(NB_GROUPS_, vd);
    new_d_2g_inv_prop_.resize(NB_GROUPS_, vd);
    new_d_2g_.resize(NB_GROUPS_, vd);

    //and by functions
    NB_FUNC_ = 8;
    //initialize functions
    q_func_.resize(NB_FUNC_, 0.0);
    q_p_val_inf_.resize(NB_FUNC_, 0.0);
    q_p_val_sup_.resize(NB_FUNC_, 0.0);
    //differences
    new_q_func_.resize(NB_FUNC_, 0.0);
    //
    NB_RANDOM_SEEDS_ = 100;

    //optimize context function
    q_func_opt_max_idx_ = ctx_->appl_data_->q_func_opt_max_idx_;
    q_func_opt_max_val_ = -numeric_limits<float>::max();
    //
    simple_window_ = NULL;
    best_window_ = NULL;
    //results
    uncalculable_ = false;

    //calculate gap proportion
    MAX_GAP_PROPORTION_ = 1;
    //gap_proportion_ = 0;
    gap_proportion_ = calculateGapProportion();
    //cout << "gap proporiton: " << gap_proportion_ << endl;



    if (gap_proportion_ >= MAX_GAP_PROPORTION_) {
        uncalculable_ = true;
    }

}

//copy constructor
//AutoWinQ::AutoWinQ(qFuncCalc& ctx, AutoWinQ& orig): ctx_(ctx) {

AutoWinQ::AutoWinQ(qFuncCalc& ctx, AutoWinQ& orig) {
    //cout << "=====================: copy constructor " << endl;

    //cout << "ident_grouped : size " << orig.ident_grouped_.size() << endl;

    ctx_ = orig.ctx_;

    win_pos_ = orig.win_pos_;

    ident_all_ = orig.ident_all_;
    ident_grouped_ = orig.ident_grouped_;

    NB_GROUPS_ = orig.NB_GROUPS_;

    //nb positions valides
    v_1g_nb_ = orig.v_1g_nb_;
    d_2g_nb_ = orig.d_2g_nb_;
    v_all_nb_ = orig.v_all_nb_;

    //nb positions invalides
    v_1g_inv_nb_ = orig.v_1g_inv_nb_;
    d_2g_inv_nb_ = orig.d_2g_inv_nb_;
    v_all_inv_nb_ = orig.v_all_nb_;

    //proportion invalides
    v_1g_inv_prop_ = orig.v_1g_inv_prop_;
    d_2g_inv_prop_ = orig.d_2g_inv_prop_;
    v_all_inv_prop_ = orig.v_all_inv_prop_;

    //valeurs finales à transformer en fonctions qui scalent
    v_1g_ = orig.v_1g_;
    d_2g_ = orig.d_2g_;
    v_all_ = orig.v_all_;

    NB_FUNC_ = orig.NB_FUNC_;

    //
    q_func_ = orig.q_func_;
    //cout << "q_func4: " << q_func_[4] << endl;


    q_p_val_inf_ = orig.q_p_val_inf_;
    q_p_val_sup_ = orig.q_p_val_sup_;

    //
    //q_func_opt_max_val_;
    //q_func_opt_max_idx_;


    //copy(orig.ident_grouped_.begin(), orig.ident_grouped_.end(), this->ident_grouped_.begin());
    //
    simple_window_ = NULL;
    best_window_ = NULL;

    MAX_GAP_PROPORTION_ = orig.MAX_GAP_PROPORTION_;
    gap_proportion_ = orig.gap_proportion_;

    //cout << "ident_grouped : size " << ident_grouped_.size() << endl;


}

//virtual destructor

AutoWinQ::~AutoWinQ() {
    ident_all_.clear();

    if (simple_window_ != NULL) {
        delete simple_window_;
    }

    if (best_window_ != NULL) {
       delete best_window_;
        
    }


}

float AutoWinQ::calculateGapProportion() {

    float gap_proportion = 0;

    set<string>::iterator it1 = ident_all_.begin();
    while (it1 != ident_all_.end()) {

        //cout << "*it1: " << *it1 << endl;
        //cout << "ctx_->win_l_: " << ctx_->win_l_ << endl;


        string seq = ctx_->align_mult_types_[*it1].substr(win_pos_, ctx_->win_l_);
        for (int i = 0; i < seq.length(); i++) {
            if (seq[i] == '-') {
                gap_proportion++;
            }
        }

        ++it1;
    }

    gap_proportion /= (ctx_->win_l_ * ctx_->align_mult_types_.size());

    return gap_proportion;
}

//calculate distance matrix

void AutoWinQ::calculateDistMatrix() {

    //map< string, map <string, DistAtom > >  dmap;
    //DistAtom da = DistAtom(0,0,0,0.0);
    //dmap["a"]["b"]=da;

    set<string>::iterator it1 = ident_all_.begin();
    while (it1 != ident_all_.end()) {
        set<string>::iterator it2 = ident_all_.begin();
        while (it2 != ident_all_.end()) {

            if (it2 != it1) {
              //verify dist matrix
            //string seq_a_test = ctx_.align_mult_types_[*it1].substr(win_pos_, ctx_.win_l_);
            //string seq_b_test = ctx_.align_mult_types_[*it2].substr(win_pos_, ctx_.win_l_);
            //cout << "seq_a_test: " << seq_a_test << endl;
            DistAtom dist = ctx_->dist_calc_->dist_2seq(ctx_->align_mult_types_[*it1].substr(win_pos_, ctx_->win_l_), ctx_->align_mult_types_[*it2].substr(win_pos_, ctx_->win_l_));
            //symetric matrix
            dist_matrix_[*it1][*it2] = dist;
            dist_matrix_[*it2][*it1] = dist_matrix_[*it1][*it2];  
            } else {
               dist_matrix_[*it1][*it2] = DistAtom(0,0,0,0);
            }
            

            ++it2;
        }
        ++it1;
    }


}

//Alix bipartitions of the distance matrix
void AutoWinQ::calculateNjBipartitions() {

    BipartNj *rb = new BipartNj(dist_matrix_);
    cout << "dist_matrix_.size(): " << dist_matrix_.size() << endl;


    //rb.lectureFichier();
    //outputDistanceMatrix();

    rb->recherche_bipartition();
    rb->calculateBipartVector();

    //rb->outputBipartVector();

     cout << "----------------calculateDistMatrix size 1: " << bipart_matrix_.size() << endl;
     bipart_matrix_.clear();

     rb->getBipartVector(&bipart_matrix_);

     cout << "---------------calculateDistMatrix size 2: " << bipart_matrix_.size() << endl;

     //cout << "--bla: " << endl;

    delete(rb);
    //cout << "--blaxxx: " << endl;


}


//update distance matrix one step

void AutoWinQ::updateDistMatrixOneStep() {

    //map< string, map <string, DistAtom > >  dmap;
    //DistAtom da = DistAtom(0,0,0,0.0);
    //dmap["a"]["b"]=da;

    //advance position
    win_pos_ += ctx_->appl_data_->win_step_;
    calculateDistMatrix();
}

void AutoWinQ::outputDistanceMatrix() {

    //output distance matrix
    cout << "outputDistanceMatrix(): " << endl;
    set<string>::iterator it1 = ident_all_.begin();
    while (it1 != ident_all_.end()) {
        set<string>::iterator it2 = ident_all_.begin();
        while (it2 != ident_all_.end()) {
            DistAtom da = dist_matrix_[*it1][*it2];
            cout << *it1 << "-" << *it2 << "= " << da.real_dist_
                    << " seq_a: " << ctx_->align_mult_types_[*it1].substr(win_pos_, ctx_->win_l_)
                    << " seq_b: " << ctx_->align_mult_types_[*it2].substr(win_pos_, ctx_->win_l_)
                    << endl;
            ++it2;
        }
        ++it1;
    }


}

void AutoWinQ::outputBipartMatrix() {

    //vector< vector <set<string> > >

    cout << "outputBipartMatrix(): " << endl;
    for (int i = 0; i < bipart_matrix_.size(); i++) {
        cout << "outputBipartMatrix size: " << bipart_matrix_.size() << endl;
        cout << "bipartition: " << i << endl;
        vector <set<string> > one_bipart = bipart_matrix_[i];
        for (int j = 0; j < one_bipart.size(); j++) {
            cout << "  group: " << j << endl;

            set<string> one_group = one_bipart[j];
            set<string>::iterator it1 = one_group.begin();
            while (it1 != one_group.end()) {
                cout << "    ident: " << *it1 << endl;
                ++it1;
            }

        }

    }


}

void AutoWinQ::outputGroupings(ostream & os) {

    //output groupings
    string type_ident = "*";

    os << "outputGroupings():" << endl;
    for (int i = 0; i < NB_GROUPS_; i++) {
        os << "group: " << i << endl;
        for (set<string>::iterator it = ident_grouped_[i].begin();
                it != ident_grouped_[i].end();
                ++it) {

            if (ctx_->x_ident_.find(*it) != ctx_->x_ident_.end()) {
                type_ident = "*";
            } else {
                type_ident = " ";
            }

            os << type_ident << " " << *it
                    << " " << ctx_->align_mult_types_[*it].substr(win_pos_, ctx_->win_l_)
                    << endl;



        }

    }

}

void AutoWinQ::outputGroupingsToFiles(ostream& os_a, ostream & os_b) {



    //output groupings
    string type_ident = "*";


    for (int i = 0; i < NB_GROUPS_; i++) {


        if (i == 1) {

        }

        for (set<string>::iterator it = ident_grouped_[i].begin();
                it != ident_grouped_[i].end();
                ++it) {

            if (ctx_->x_ident_.find(*it) != ctx_->x_ident_.end()) {
                type_ident = "*";
            } else {
                type_ident = " ";
            }

            if (i == 0) {
                os_a << type_ident << " " << *it
                        //<< " " << ctx_->align_mult_types_[*it].substr(win_pos_, ctx_->win_l_)
                        << endl;

            } else if (i == 1) {
                os_b << type_ident << " " << *it
                        //<< " " << ctx_->align_mult_types_[*it].substr(win_pos_, ctx_->win_l_)
                        << endl;

            }




        }

    }

}

float AutoWinQ::randIndex() {

    float rand_index;
    //calculated each time, no need to reinitialize
    int calc_set[2];
    int file_set[2];

    int a, b, c, d;
    //swap one group
    int g0;

    //swap groups
    //for (g0 = 0; g0 < 2; g0++) {
    g0 = 1;
    rand_index = 0;
    a = 0;
    b = 0;
    c = 0;
    d = 0;


    //for every pair of identifiers
    set<string>::iterator it1, it2;
    it1 = ident_all_.begin();
    while (it1 != --(ident_all_.end())) {
        it2 = it1;
        it2++;

        while (it2 != ident_all_.end()) {

            // cout << " " << *it1
            //         << " " << *it2;


            //find calculated set
            // *it1 in group 0
            if (ident_grouped_[g0].find(*it1) != ident_grouped_[g0].end()) {
                calc_set[0] = 0;
            } else { // *it1 in group 1
                calc_set[0] = 1;
            }

            // *it2 in group 0
            if (ident_grouped_[g0].find(*it2) != ident_grouped_[g0].end()) {
                calc_set[1] = 0;
            } else { // *it1 in group 1
                calc_set[1] = 1;
            }

            //find file set
            // *it1 in group 0 (X)
            if (ctx_-> x_ident_.find(*it1) != ctx_->x_ident_.end()) {
                file_set[0] = 0;
            } else { // *it1 in group 1
                file_set[0] = 1;
            }

            // *it2 in group 0 (X)
            if (ctx_->x_ident_.find(*it2) != ctx_->x_ident_.end()) {
                file_set[1] = 0;
            } else { // *it2 in group 1
                file_set[1] = 1;
            }


            if (calc_set[0] == calc_set[1]) {
                //same set in X (Rand wikipedia)
                if (file_set[0] == file_set[1]) {
                    //same set in Y (Rand wikipedia)
                    //cout << " a: same X, same Y";
                    a++;
                } else {
                    //different set in Y (Rand wikipedia)
                    //cout << " c: same X, different Y";
                    c++;
                }
            } else {
                //different sets in X (Rand wikipedia)
                if (file_set[0] == file_set[1]) {
                    //same set in Y (Rand wikipedia)
                    //cout << " d: different X, same Y";
                    d++;
                } else {
                    //different set in Y (Rand wikipedia)
                    //cout << " b: different X, different Y";
                    b++;
                }

            }
            //cout << endl;

            ++it2;
        }
        ++it1;
    }

    rand_index = max(rand_index, (float(a + b) / float(a + b + c + d)));


    /*
    cout << "a: " << a
            << ",b: " << b
            << ",c: " << c
            << ",d: " << d
            << ",float(a + b): " << float(a + b)
            << ",float(a + b + c + d): " << float(a + b + c + d)
            << ",rand_index: " << rand_index
            << endl;
  */

    //}

    return rand_index;

}

float AutoWinQ::adjustedRandIndex() {

    float adjusted_rand_index;
    //calculated each time, no need to reinitialize
    int calc_set[2];
    int file_set[2];

    int a, b, c, d;
    //swap one group
    int g0;

    //swap groups
    //for (g0 = 0; g0 < 2; g0++) {
    g0 = 1;
    adjusted_rand_index = 0;

    a = 0;
    b = 0;
    c = 0;
    d = 0;


    //for every pair of identifiers
    set<string>::iterator it1, it2;
    it1 = ident_all_.begin();
    while (it1 != --(ident_all_.end())) {
        it2 = it1;
        it2++;

        while (it2 != ident_all_.end()) {

            //cout << " " << *it1
            //        << " " << *it2;


            //find calculated set
            // *it1 in group 0
            if (ident_grouped_[g0].find(*it1) != ident_grouped_[g0].end()) {
                calc_set[0] = 0;
            } else { // *it1 in group 1
                calc_set[0] = 1;
            }

            // *it2 in group 0
            if (ident_grouped_[g0].find(*it2) != ident_grouped_[g0].end()) {
                calc_set[1] = 0;
            } else { // *it1 in group 1
                calc_set[1] = 1;
            }

            //find file set
            // *it1 in group 0 (X)
            if (ctx_-> x_ident_.find(*it1) != ctx_->x_ident_.end()) {
                file_set[0] = 0;
            } else { // *it1 in group 1
                file_set[0] = 1;
            }

            // *it2 in group 0 (X)
            if (ctx_->x_ident_.find(*it2) != ctx_->x_ident_.end()) {
                file_set[1] = 0;
            } else { // *it2 in group 1
                file_set[1] = 1;
            }


            if (calc_set[0] == calc_set[1]) {
                //same group in U
                if (file_set[0] == file_set[1]) {
                    //same group in V
                    //cout << " a: same U, same V";
                    a++;
                } else {
                    //different set in V
                    //cout << " b: same U, different V";
                    b++;
                }
            } else {
                //different sets in U
                if (file_set[0] == file_set[1]) {
                    //same set in V
                    //cout << " c: different U, same V";
                    c++;
                } else {
                    //different set in V
                    //cout << " d: different U, different V";
                    d++;
                }

            }
            //cout << endl;

            ++it2;
        }
        ++it1;
    }

    //n_2 = binom(n,2)
    float n_2 = a + b + c + d;
    float cor = ((a + b) * (a + c) + (c + d) * (b + d));

    float num = n_2 * (a + d) - cor;
    float den = (n_2 * n_2) - cor;
    float ari_val = num / den;

    adjusted_rand_index = ari_val;


    /*
    cout << "a: " << a
            << ",b: " << b
            << ",c: " << c
            << ",d: " << d
            << ",cor: " << cor
            << ",num: " << num
            << ",den: " << den
            << ",adjusted_rand_index: " << adjusted_rand_index
            << endl;
    */

    //}

    return adjusted_rand_index;

}

float AutoWinQ::groupHamIndex() {

    float group_ham_idx;
    string g_local;
    string g_context;



    group_ham_idx = 0;

    //for every pair of identifiers
    set<string>::iterator it, it1, it2;

    it = ident_all_.begin();
    while (it != ident_all_.end()) {

        //local in group 0
        if (ident_grouped_[0].find(*it) != ident_grouped_[0].end()) {
            g_local.push_back('0');
        } else { // local in group 1
            g_local.push_back('1');
        }

        //context group
        //local in group 0
        if (ctx_-> x_ident_.find(*it) != ctx_->x_ident_.end()) {
            g_context.push_back('0');
        } else { // local in group 1
            g_context.push_back('1');
        }


        ++it;
    }


    Hamming hm;

    group_ham_idx = hm.dist_2seq(g_local, g_context).real_dist_;

    //invert characters
    for (int i = 0; i < g_local.length(); i++) {
        if (g_local[i] == '0') {
            g_local[i] = '1';

        } else {
            g_local[i] = '0';
        }

    }

    group_ham_idx = min(group_ham_idx, hm.dist_2seq(g_local, g_context).real_dist_);

    //cout << "group_ham_idx, dist: " << group_ham_idx << "g_local: " << g_local << ", context: " << g_context << endl;

    return group_ham_idx;

}

void AutoWinQ::test() {

    outputDistanceMatrix();
    outputGroupings(cout);
    /*
    for (int i = 0; i < ident_all_.size(); i++) {
        for (int j = 0; j < ident_all_.size(); j++) {
            DistAtom da = dist_matrix_[ident_all_[i]][ident_all_[j]];
            cout << ident_all_[i] << "-" << ident_all_[j] << "= " << da.real_dist_ << endl;
        }
    }
     */

    //output groupings
    /*
    for (int i = 0; i < NB_GROUPS_; i++) {
        cout << "group: " << i << endl;
        for (int j = 0; j < ident_grouped_[i].size(); j++) {
            cout << "ident: " << ident_grouped_[i][j] << endl;
        }

    }
     */
}

//verify that each group contains more than one element

void AutoWinQ::generateRandomInitGrouping() {

    //initialize
    ident_grouped_.clear();
    ident_grouped_.reserve(NB_GROUPS_);

    set<string> ss;
    //vs.clear();
    for (int i = 0; i < NB_GROUPS_; i++) {
        ident_grouped_.push_back(ss);
    }
    //randomly distribute identifiers
    set<string>::iterator it1 = ident_all_.begin();
    while (it1 != ident_all_.end()) {
        //random_integer = (rand()%10)+1;  1-10;
        //random_integer = lowest+int(range*rand()/(RAND_MAX + 1.0));


    	///int rand_group_id = (int) ((float) rand() / ((float) RAND_MAX + 1) * 2);

    	//distribution, numbers between 0 and 1
    	boost::uniform_int<> dist(0, 1);
    	//use global generator with this distribution
  	    boost::variate_generator<boost::mt19937&, boost::uniform_int<> > die(ctx_->appl_data_->random_number_gen_, dist);

  	    int rand_group_id = die() ;


        ident_grouped_[rand_group_id].insert(*it1);
        ++it1;
    }

    //not-empty groups
    bool empty_groups = false;
    for (int i = 0; i < NB_GROUPS_; i++) {
        if (ident_grouped_[i].size() < 2) {
            empty_groups = true;
            //cout << "emptyes groups" << endl;
        }
    }

    //terminal recursion to verify non-emptyness
    //always possible
    if (empty_groups) {
        generateRandomInitGrouping();
    }
    //outputGroupings();
}

void AutoWinQ::getContextGrouping() {

    //initialize
    ident_grouped_.clear();
    ident_grouped_.reserve(NB_GROUPS_);

    set<string> ss;
    //vs.clear();
    for (int i = 0; i < NB_GROUPS_; i++) {
        ident_grouped_.push_back(ss);
    }


    //same distribution of identifiers as in context
    // X -> group 0
    set<string>::iterator it0 = ctx_->x_ident_.begin();
    while (it0 != ctx_->x_ident_.end()) {
        ident_grouped_[0].insert(*it0);
        ++it0;
    }

    // Y -> group 1
    set<string>::iterator it1 = ctx_->y_ident_.begin();
    while (it1 != ctx_->y_ident_.end()) {
        ident_grouped_[1].insert(*it1);
        ++it1;
    }

   // outputGroupings(cout);

}

void AutoWinQ::calcQRes() {

    //cout << "nx: " << ident_grouped_[0].size() << endl;
    //cout << "ny: " << ident_grouped_[1].size() << endl;

    //vX, vY
    //update running totals
    for (int g = 0; g < NB_GROUPS_; g++) {


        //    for (int i = 0; i < (ident_grouped_[g].size() - 1); i++) {
        //       for (int j = (i + 1); j < ident_grouped_[g].size(); j++) {

        //initialize group elements
        v_1g_inv_nb_[g] = 0.0; //cumulative
        v_1g_cumul_[g] = 0.0; //cumulative
        v_1g_nb_[g] = 0.0; //cumulative
        //non cumulative elements
        //initialization optional (they will be overriten)
        v_1g_[g] = 0.0;
        v_1g_inv_prop_[g] = 0.0;

        set<string>::iterator it1, it2;
        it1 = ident_grouped_[g].begin();
        while (it1 != --(ident_grouped_[g].end())) {
            it2 = it1;
            it2++;

            while (it2 != ident_grouped_[g].end()) {

                //skip same elements
                if (it2 == it1) {
                    // cout << "it2 == it1" << *it2 << "-" << *it1 << endl;
                }
                //float v_1g_elem = dist_matrix_[ident_grouped_[g][i]][ident_grouped_[g][j]].real_dist_;
                float v_1g_elem = dist_matrix_[*it1][*it2].real_dist_;

                if (v_1g_elem != numeric_limits<float>::max()) {
                    //count it
                    v_1g_nb_[g]++;
                    //add value
                    //v_1g_cumul_[g] += pow(v_1g_elem, 2.0);
                    v_1g_cumul_[g] += v_1g_elem *v_1g_elem;
                } else {
                    //count invalid
                    v_1g_inv_nb_[g]++;
                }

                ++it2;
            }
            ++it1;
        }




        //scale to valid number of elements
        v_1g_[g] = v_1g_cumul_[g] / v_1g_nb_[g];
        //proportion of invalid positions
        v_1g_inv_prop_[g] = v_1g_inv_nb_[g] / (v_1g_nb_[g] + v_1g_inv_nb_[g]);

        //cout << "v_x: " << v_1g_nb_[g] << "v_x formula: " << (ident_grouped_[g].size() * (ident_grouped_[g].size() - 1) / 2.0) << endl;
    }





    //dXY

    //update running totals
    for (int g1 = 0; g1 < (NB_GROUPS_ - 1); g1++) {
        for (int g2 = (g1 + 1); g2 < NB_GROUPS_; g2++) {
            //initialize group elements
            d_2g_inv_nb_[g1][g2] = 0.0; //cumulative
            d_2g_cumul_[g1][g2] = 0.0; //cumulative
            d_2g_nb_[g1][g2] = 0.0; //cumulative
            //non cumulative elements
            //initialization optional (they will be overriten)
            d_2g_[g1][g2] = 0.0;
            d_2g_inv_prop_[g1][g2] = 0.0;

            // for (int i = 0; i < ident_grouped_[g1].size(); i++) {
            //    for (int j = 0; j < ident_grouped_[g2].size(); j++) {

            for (set<string>::iterator it1 = ident_grouped_[g1].begin();
                    it1 != ident_grouped_[g1].end();
                    ++it1) {
                for (set<string>::iterator it2 = ident_grouped_[g2].begin();
                        it2 != ident_grouped_[g2].end();
                        ++it2) {

                    //      float d_2g_elem = dist_matrix_[ident_grouped_[g1][i]][ident_grouped_[g2][j]].real_dist_;
                    float d_2g_elem = dist_matrix_[*it1][*it2].real_dist_;

                    if (d_2g_elem != numeric_limits<float>::max()) {
                        //count it
                        d_2g_nb_[g1][g2]++;
                        //add value
                        //d_2g_cumul_[g1][g2] += pow(d_2g_elem, 2.0);
                        d_2g_cumul_[g1][g2] += d_2g_elem * d_2g_elem;
                    } else {
                        //count invalid
                        d_2g_inv_nb_[g1][g2]++;
                    }



                }
            }


            //scale to valid number of elements
            d_2g_[g1][g2] = d_2g_cumul_[g1][g2] / d_2g_nb_[g1][g2];
            //proportion of invalid positions
            d_2g_inv_prop_[g1][g2] = d_2g_inv_nb_[g1][g2] / (d_2g_nb_[g1][g2] + d_2g_inv_nb_[g1][g2]);

            // cout << "d_xy: " << d_2g_nb_[g1][g2] << "d_xy formula: " << (ident_grouped_[g1].size() * ident_grouped_[g2].size()) << endl;

            //symetric results
            d_2g_inv_nb_[g2][g1] = d_2g_inv_nb_[g1][g2]; //cumulative
            d_2g_cumul_[g2][g1] = d_2g_cumul_[g1][g2]; //cumulative
            d_2g_nb_[g2][g1] = d_2g_nb_[g1][g2]; //cumulative
            //non cumulative elements
            //initialization optional (they will be overriten)
            d_2g_[g2][g1] = d_2g_[g1][g2];
            d_2g_inv_prop_[g2][g1] = d_2g_inv_prop_[g1][g2];

        }

    }

    //debug
    //cout << "d_2d_[0][1] " << d_2g_[0][1] << endl;
    //cout << "v_1g_[0] " << v_1g_[0] << endl;
    //cout << "v_1g_[1] " << v_1g_[1] << endl;




    //vAll
    //initialize group elements
     v_all_inv_nb_ = 0.0; //cumulative
     v_all_cumul_ = 0.0; //cumulative
     v_all_nb_ = 0.0; //cumulative
     //non cumulative elements
     //initialization optional (they will be overriten)
     v_all_ = 0.0;
     v_all_inv_prop_ = 0.0;


     set<string>::iterator it1, it2;
     it1 = ident_all_.begin();
      while (it1 != --(ident_all_.end())) {
                it2 = it1;
                it2++;

                while (it2 != ident_all_.end()) {

                    //skip same elements
                    if (it2 == it1) {
                        // cout << "it2 == it1" << *it2 << "-" << *it1 << endl;
                    }

                    float v_all_elem = dist_matrix_[*it1][*it2].real_dist_;

                    if (v_all_elem != numeric_limits<float>::max()) {
                        //count it
                        v_all_nb_++;
                        //add value
                        v_all_cumul_ += v_all_elem * v_all_elem;
                    } else {
                        //count invalid
                        v_all_inv_nb_++;
                    }

                    ++it2;
                }
                ++it1;
            }
            //scale to valid number of elements
            v_all_ = v_all_cumul_ / v_all_nb_;
            //proportion of invalid positions
            v_all_inv_prop_ = v_all_inv_nb_ / (v_all_nb_ + v_all_inv_nb_);





    //recalculate all functions
    //no need to reinitialize

    //reinitialize functions
    q_func_.resize(NB_FUNC_, 0.0);

    q_func_[0] = log(1 + d_2g_[0][1] - v_1g_[0]);
    q_func_[1] = d_2g_[0][1] - v_1g_[0];
    q_func_[2] = d_2g_[0][1] - v_1g_[1];
    q_func_[3] = 2 * d_2g_[0][1] - v_1g_[0] - v_1g_[1];
    q_func_[4] = d_2g_[0][1];
    q_func_[5] = abs(v_1g_[0] - v_1g_[1]); ///// d_2g_[0][1]
    
    
    if (v_1g_[1] == 0) {
        cout << "------------------------------------------------------error-------------up" <<endl;
                //q_func_[6] = abs(v_1g_[0] / v_1g_[1]); ///// d_2g_[0][1]
                q_func_[6] = numeric_limits<float>::max();
            } else {
                q_func_[6] = abs(v_1g_[0] / v_1g_[1]);
            }
            
    
    q_func_[7] = 222; //v_all_;
    //q_func_[6] = fabs(v_1g_[0] - v_1g_[1]);
    //q_func_[6] = abs ( log(v_1g_[0]) - log(v_1g_[1]))  ; ///// d_2g_[0][1]
     
    


}

void AutoWinQ::testOneCycleTransfers() {

    string cand_ident;
    //transfer identifiers group 0 -> 1

    float dist_cand_new_source_cumul;
    float dist_cand_new_source_cumul_inv_nb;

    float dist_cand_old_dest_cumul;
    float dist_cand_old_dest_cumul_inv_nb;

    int g0 = 1;
    int g1 = 0;
    int cycle_transfered = 0;
    int nb_null_cycles = 0;

    do {
        cycle_transfered = 0;
        int tmp = g0;
        g0 = g1;
        g1 = tmp;

        set<string>::iterator it1, it2;
        it1 = ident_grouped_[g0].begin();
        while (it1 != ident_grouped_[g0].end()) {
            cand_ident = *it1;

            //cout << "candidate: " << cand_ident << endl;

            //calculate candidate -> new_source
            dist_cand_new_source_cumul = 0;
            dist_cand_new_source_cumul_inv_nb = 0;
            it2 = ident_grouped_[g0].begin();
            while (it2 != ident_grouped_[g0].end()) {
                if (it2 != it1) {
                    //cout << "               " << "---------->" << *it2 << endl;
                    float v_1g_elem = dist_matrix_[*it1][*it2].real_dist_;

                    if (v_1g_elem != numeric_limits<float>::max()) {
                        //add value
                        dist_cand_new_source_cumul += pow(v_1g_elem, 2);
                    } else {
                        //count invalid
                        dist_cand_new_source_cumul_inv_nb++;
                    }

                }
                ++it2;
            }

            //calculate candidate -> old_dest
            dist_cand_old_dest_cumul = 0;
            dist_cand_old_dest_cumul_inv_nb = 0;
            it2 = ident_grouped_[g1].begin();
            while (it2 != ident_grouped_[g1].end()) {
                // cout << "               " << "---------->" << *it2 << endl;
                float d_2g_elem = dist_matrix_[*it1][*it2].real_dist_;

                if (d_2g_elem != numeric_limits<float>::max()) {
                    //dist_cand_old_dest_cumul += pow(d_2g_elem, 2.0);
                    dist_cand_old_dest_cumul += d_2g_elem*d_2g_elem;
                } else {
                    //count invalid
                    dist_cand_old_dest_cumul_inv_nb++;
                }

                ++it2;
            }



            //calculate differences
            new_v_1g_cumul_[g0] = v_1g_cumul_[g0] - dist_cand_new_source_cumul;
            //we do not substract invalid positions (they do not move)
            new_v_1g_nb_[g0] = v_1g_nb_[g0] - (ident_grouped_[g0].size() - 1 - dist_cand_new_source_cumul_inv_nb);
            //invalid positions move
            new_v_1g_inv_nb_[g0] = v_1g_inv_nb_[g0] - dist_cand_new_source_cumul_inv_nb;
            //update
            new_v_1g_[g0] = new_v_1g_cumul_[g0] / new_v_1g_nb_[g0];
            new_v_1g_inv_prop_[g0] = new_v_1g_inv_nb_[g0] / (new_v_1g_nb_[g0] + new_v_1g_inv_nb_[g0]);

            //
            new_v_1g_cumul_[g1] = v_1g_cumul_[g1] + dist_cand_old_dest_cumul;
            //we do not add invalid positions (they do not move)
            new_v_1g_nb_[g1] = v_1g_nb_[g1] + (ident_grouped_[g1].size() - dist_cand_old_dest_cumul_inv_nb);
            //invalid positions move
            new_v_1g_inv_nb_[g1] = v_1g_inv_nb_[g1] + dist_cand_old_dest_cumul_inv_nb;
            //update
            new_v_1g_[g1] = new_v_1g_cumul_[g1] / new_v_1g_nb_[g1];
            new_v_1g_inv_prop_[g1] = new_v_1g_inv_nb_[g1] / (new_v_1g_nb_[g1] + new_v_1g_inv_nb_[g1]);



            //
            new_d_2g_cumul_[g0][g1] = d_2g_cumul_[g0][g1] - dist_cand_old_dest_cumul + dist_cand_new_source_cumul;
            //we do not add invalid positions (they do not move)
            new_d_2g_nb_[g0][g1] = d_2g_nb_[g0][g1] -(ident_grouped_[g1].size() - dist_cand_old_dest_cumul_inv_nb)
                    + (ident_grouped_[g0].size() - 1 - dist_cand_new_source_cumul_inv_nb);
            //invalid positions move
            new_d_2g_inv_nb_[g0][g1] = d_2g_inv_nb_[g0][g1] - dist_cand_old_dest_cumul_inv_nb + dist_cand_new_source_cumul_inv_nb;
            //update
            new_d_2g_[g0][g1] = new_d_2g_cumul_[g0][g1] / new_d_2g_nb_[g0][g1];
            new_d_2g_inv_prop_[g0][g1] = new_d_2g_inv_nb_[g0][g1] / (new_d_2g_nb_[g0][g1] + new_d_2g_inv_nb_[g0][g1]);
            //symetric results
            new_d_2g_cumul_[g1][g0] = new_d_2g_cumul_[g0][g1];
            new_d_2g_nb_[g1][g0] = new_d_2g_nb_[g0][g1];
            new_d_2g_inv_nb_[g1][g0] = new_d_2g_inv_nb_[g0][g1];
            new_d_2g_[g1][g0] = new_d_2g_[g0][g1];
            new_d_2g_inv_prop_[g1][g0] = new_d_2g_inv_prop_[g0][g1];

            //
            //q_func_[0] = log(1 + d_2g_[0][1] - v_1g_[0]);

            //reinitialize functions
            new_q_func_.resize(NB_FUNC_, 0.0);


            new_q_func_[0] = log(1 + new_d_2g_[0][1] - new_v_1g_[0]);
            new_q_func_[1] = new_d_2g_[0][1] - new_v_1g_[0];
            new_q_func_[2] = new_d_2g_[0][1] - new_v_1g_[1];
            new_q_func_[3] = 2 * new_d_2g_[0][1] - new_v_1g_[0] - new_v_1g_[1];
            new_q_func_[4] = new_d_2g_[0][1];
            new_q_func_[5] =  abs(new_v_1g_[0] - new_v_1g_[1]);
            if (new_v_1g_[1] == 0) {
                cout << "------------------------------------------------------error" <<endl;
                //new_q_func_[6] =  abs(new_v_1g_[0] / new_v_1g_[1]);
                new_q_func_[6] = numeric_limits<float>::max();
            } else {
                 new_q_func_[6] = abs(new_v_1g_[0] / new_v_1g_[1]);
            }
                
           
            new_q_func_[7] =  222;
            
            //q_func[5]   is invariable
            //new_q_func_[6] = abs ( log (new_v_1g_[0]) - log( new_v_1g_[1])) ;  //// new_d_2g_[0][1]
            //new_q_func_[7] = new_d_2g_[0][1] * (new_v_1g_[1] * new_v_1g_[0]);


            //cout << "q_func_[1]: " << q_func_[1] << " new_q_func_[1]: " << new_q_func_[1] << "diff: " << (new_q_func_[1] - q_func_[1]) << endl;





            //move the element if usefull
            if (new_q_func_[q_func_opt_max_idx_] > q_func_[q_func_opt_max_idx_]
                    && ident_grouped_[g0].size() > 0
                    && new_v_1g_nb_[g0] > 0
                    && new_v_1g_nb_[g1] > 0
                    && new_d_2g_nb_[g0][g1] > 0
                    ) {
                cycle_transfered++;
                //update sets
                ident_grouped_[g1].insert(*it1);
                //workaround for
                //iterator toDelete = itr2;
                //++itr2;   // increment before erasing!
                //container.erase(toDelete);
                ident_grouped_[g0].erase(it1++);

                //debug
                //calcQRes();
                //cout << "after calcQRes(): q_func_[1]: " << q_func_[4] << " new_q_func_[1]: " << new_q_func_[4] << "diff: " << (new_q_func_[4] - q_func_[4]) << endl;
                //cout << "q_func_[q_func_opt_max_idx_]: " << q_func_[q_func_opt_max_idx_] << " new_q_func_[q_func_opt_max_idx_]: " << new_q_func_[q_func_opt_max_idx_] << "diff: " << (new_q_func_[q_func_opt_max_idx_] - q_func_[q_func_opt_max_idx_]) << endl;


                //cout << " go : " << ident_grouped_[g0].size() << " g1 : " << ident_grouped_[g1].size() << endl;
                //update group information
                v_1g_cumul_[g0] = new_v_1g_cumul_[g0];
                v_1g_nb_[g0] = new_v_1g_nb_[g0];
                v_1g_inv_nb_[g0] = new_v_1g_inv_nb_[g0];
                v_1g_[g0] = new_v_1g_[g0];
                v_1g_inv_prop_[g0] = new_v_1g_inv_prop_[g0];

                v_1g_cumul_[g1] = new_v_1g_cumul_[g1];
                v_1g_nb_[g1] = new_v_1g_nb_[g1];
                v_1g_inv_nb_[g1] = new_v_1g_inv_nb_[g1];
                v_1g_[g1] = new_v_1g_[g1];
                v_1g_inv_prop_[g1] = new_v_1g_inv_prop_[g1];


                d_2g_cumul_[g0][g1] = new_d_2g_cumul_[g0][g1];
                d_2g_nb_[g0][g1] = new_d_2g_nb_[g0][g1];
                d_2g_inv_nb_[g0][g1] = new_d_2g_inv_nb_[g0][g1];
                d_2g_[g0][g1] = new_d_2g_[g0][g1];
                d_2g_inv_prop_[g0][g1] = new_d_2g_inv_prop_[g0][g1];
                //
                //symetric results
                d_2g_cumul_[g1][g0] = d_2g_cumul_[g0][g1];
                d_2g_nb_[g1][g0] = d_2g_nb_[g0][g1];
                d_2g_inv_nb_[g1][g0] = d_2g_inv_nb_[g0][g1];
                d_2g_[g1][g0] = d_2g_[g0][g1];
                d_2g_inv_prop_[g1][g0] = new_d_2g_inv_prop_[g0][g1];
                //functions 0-4 change with groupings
                q_func_[0] = new_q_func_[0];
                q_func_[1] = new_q_func_[1];
                q_func_[2] = new_q_func_[2];
                q_func_[3] = new_q_func_[3];
                q_func_[4] = new_q_func_[4];
                q_func_[5] = new_q_func_[5];
                q_func_[6] = new_q_func_[6];
                q_func_[7] = new_q_func_[7];
                //function 5 is invariable of groupings




            } else {
                ++it1;
            }


        }
        //cout << "cycle tranfered: " << cycle_transfered << " direction: " << g0 << ":" << g1 << " end q_func_[1] : " << q_func_[1]
        //       << " nx: " << ident_grouped_[0].size()
        //       << " ny: " << ident_grouped_[1].size()
        //      << endl;
        if (cycle_transfered == 0) {
            nb_null_cycles++;
        }
        //cout << "nb_null_cycles: " << nb_null_cycles << endl;
    } while (nb_null_cycles != 2);






    /*

      set<string>::iterator it = ident_all_.begin();
      while (it != ident_all_.end()) {
          if (*it == 2)
              it = ident_all_.erase(it);
          else
              ++it;
      }
     */

    //float d_2g_elem = dist_matrix_[ident_grouped_[0][i]][ident_grouped_[1][j]].real_dist_;


    //for (int j = 0; j < ident_grouped_[1].size(); j++) {

    //}




}


// with nj optimisation

void AutoWinQ::testNjBipartitions() {

	//calculate NJ bipartitions
    calculateNjBipartitions();

    float q_cycle = 0;
    
   cout << "q_func_opt_max_val_: " << q_func_opt_max_val_ << endl;

    //outputBipartMatrix();


    //all bipartitions are in bipart_matrix_ member variable


    //iterate over all bipartitions and CalcQRes()

    // vector < set<string> >

    cout << "outputBipartMatrix(): " << endl;
    for (int i = 0; i < bipart_matrix_.size(); i++) {


        cout << "bipartition: " << i << endl;

        //activate this bipartition
        //like generateRandomInitGrouping();
        ident_grouped_.clear();
        ident_grouped_ = bipart_matrix_[i];

        //reject trivial partitions
        if (ident_grouped_[0].size() < 2 || ident_grouped_[1].size() < 2) {
            continue;
        }

        //calculate
        calcQRes();

        q_cycle = q_func_[q_func_opt_max_idx_];
        cout << "q_cycle: " << q_cycle << endl;

        if (q_cycle > q_func_opt_max_val_) {
            //save decision position
            q_func_opt_max_val_ = q_cycle;
            //save all associated data

            if (best_window_ != NULL) {
                delete best_window_;
            }
            best_window_ = new AutoWinQ(*ctx_, *this);

        }


    }

    

}


//with k-means optimisation

void AutoWinQ::testManyRandomSeeds() {


    //advance position
    // win_pos_ += ctx_->win_step_;



    float q_init = 0;
    float q_cycle = 0;

    for (int i = 0; i < NB_RANDOM_SEEDS_ && !uncalculable_; i++) {
        //for (int i = 0; i < 1; i++) {

        int initial_wait = 0;
        //wait for decent values
        do {
            initial_wait++;
            //wait for decent grouping dimensions
            //at least two per group
            generateRandomInitGrouping();

            calcQRes();
            if (initial_wait >= NB_RANDOM_SEEDS_) {
                uncalculable_ = true;
                break;
            }
        } while (v_1g_nb_[0] < 1
                || v_1g_nb_[1] < 1
                || d_2g_nb_[0][1] < 1);



        /*
                q_init = q_func_[q_func_opt_max_idx_];
                if ( win_pos_ == 29 && i == 0) {
                    cout << "win_pos_: " << win_pos_ << "i: " << i << "q_init: " << q_init << endl;
            
                    if (q_init == numeric_limits<float>::signaling_NaN()) {
                       cout << "signaling nan: " << i << endl;
                      }

                    if (q_init == numeric_limits<float>::quiet_NaN()) {
                       cout << "QUIET nan: " << i << endl;
                      }


                }
         */

        testOneCycleTransfers();
        q_cycle = q_func_[q_func_opt_max_idx_];

        if (q_cycle > q_func_opt_max_val_) {
            //save decision position
            q_func_opt_max_val_ = q_cycle;
            //save all associated data

            if (best_window_ != NULL) {
                delete best_window_;
            }
            best_window_ = new AutoWinQ(*ctx_, *this);

        }

        if (!uncalculable_) {

            //cout << "i: " << i << " q_init: " << q_init << " q_cycle: " << q_cycle
            //       << " q_func_opt_max_val_: " << q_func_opt_max_val_
            //       << " go : " << ident_grouped_[0].size() << " g1 : " << ident_grouped_[1].size()
            //       << endl;
            /*
            cout << "best_window_: size " << best_window_->ident_grouped_.size()
                    << " go : " << best_window_->ident_grouped_[0].size() << " g1 : " << best_window_->ident_grouped_[1].size()
                    << endl;
             */

        }

    }

    cout << "--------------------------------> "; //<< best_window.q_func_[1] << endl;


    //outputGroupings(cout);

    //test();

}

void AutoWinQ::calcSimple() {

    getContextGrouping();
    calcQRes();

    simple_window_ = new AutoWinQ(*ctx_, *this);


}

