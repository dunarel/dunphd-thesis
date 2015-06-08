/* 
 * File:   auto_win_q.h
 * Author: root
 *
 * Created on January 25, 2011, 5:05 PM
 */

#ifndef _AUTO_WIN_Q_H
#define	_AUTO_WIN_Q_H

#include <string>
#include <map>
#include <vector>
#include <set>
#include "dist_atom.h"
#include "q_func_calc.h"
#include "BipartNj.h"
#include "direction.h"

//using namespace std;
//using namespace uqam_doc;

//using uqam_doc::qFuncCalc;
//using uqam_doc::Direction;

namespace uqam_doc {
    class AutoWinQ {
    public:

        //msa sequences,
        // initial window position and size
        AutoWinQ(qFuncCalc& ctx, int win_pos);
        //copy constructor
        AutoWinQ(qFuncCalc& ctx, AutoWinQ& orig);
        virtual ~AutoWinQ();

        float calculateGapProportion();


        //update distance matrix one step
        void updateDistMatrixOneStep();

        void outputDistanceMatrix();

        void outputBipartMatrix();

        void outputGroupings(ostream& os);
        //write a_group_csv,b_group_csv
        void outputGroupingsToFiles(ostream& os_a,ostream& os_b);
        //rand index
        float randIndex();
        //adjusted rand index
        float adjustedRandIndex();

        //adjusted rand index
        float groupHamIndex();

        void test();
        //generate init grouping
        void generateRandomInitGrouping();
        //get context grouping
        void getContextGrouping();

        //calculate distance matrix
        void calculateDistMatrix();
        //calculate NJ bipartitions
        void calculateNjBipartitions();

        //test all NJ Tree bipartitions
        void testNjBipartitions();

        //transfer identifier between groups
        //which updates results
        //void transferIdent(string ident, int source_group, int dest_group);
        //
        void testManyRandomSeeds();

        //
        void calcSimple();


        //window position in context
        int win_pos_;

        //local copy of window sequences
        map<string, string> seqs_;


        //all identifiers
        set<string> ident_all_;
        //grouped identifiers
        vector <set<string> > ident_grouped_;

        //working distance matrix
        //all ident against all
        map< string, map<string, DistAtom > > dist_matrix_;

        //all nj bipartitions vector
       vector< vector <set<string> > > bipart_matrix_;

        //depending on nb of groups 0 = X, 1 = Y
        int NB_GROUPS_;
        //
        vector<float> v_1g_cumul_;
        vector<vector<float> > d_2g_cumul_;
        float v_all_cumul_;

        //nb positions valides
        vector<float> v_1g_nb_;
        vector<vector<float> > d_2g_nb_;
        float v_all_nb_;

        //nb positions invalides
        vector<float> v_1g_inv_nb_;
        vector<vector<float> > d_2g_inv_nb_;
        float v_all_inv_nb_;

        //proportion invalides
        vector<float> v_1g_inv_prop_;
        vector<vector<float> > d_2g_inv_prop_;
        float v_all_inv_prop_;


        //valeurs finales à transformer en fonctions qui scalent
        vector<float> v_1g_;
        vector<vector<float> > d_2g_;
        float v_all_;

        //depending of number of functions (5) 0 -> 5
        int NB_FUNC_;
        //
        vector<float> q_func_,
        q_p_val_inf_,
        q_p_val_sup_;

        //dynamic differences by components
        //new elements
        vector<float> new_v_1g_cumul_;
        vector<vector<float> > new_d_2g_cumul_;
        //
        vector<float> new_v_1g_nb_;
        vector<vector<float> > new_d_2g_nb_;
        //nb positions invalides
        vector<float> new_v_1g_inv_nb_;
        vector<vector<float> > new_d_2g_inv_nb_;
        //proportion invalides
        vector<float> new_v_1g_inv_prop_;
        vector<vector<float> > new_d_2g_inv_prop_;
        //
        vector<float> new_v_1g_;
        vector<vector<float> > new_d_2g_;
        //and by functions
        vector<float> new_q_func_;
        //
        int NB_RANDOM_SEEDS_;
        float q_func_opt_max_val_;
        int q_func_opt_max_idx_;
        //
        AutoWinQ* simple_window_;
        AutoWinQ* best_window_;

        //results
        bool uncalculable_;

        float MAX_GAP_PROPORTION_;
        float gap_proportion_;


        //context
        //reference
        //qFuncCalc& ctx_;
        //pointer
        qFuncCalc *ctx_;

    protected:


        //calculate init q_res
        void calcQRes();

        //test one cycle transfers
        void testOneCycleTransfers();



    private:

    };
}


#endif	/* _AUTO_WIN_Q_H */

