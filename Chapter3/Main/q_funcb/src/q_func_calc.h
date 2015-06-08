/* 
 * File:   q_func_calc.h
 * Author: mihaela
 *
 * Created on December 28, 2008, 9:21 PM
 */

#ifndef _Q_FUNC_CALC_H
#define	_Q_FUNC_CALC_H

#include <string>
#include <map>
//#include <ext/hash_map>
#include <vector>
#include <set>
#include "application_data.h"
#include "distance_measures.h"
#include "win_q.h"

using namespace std;
using namespace uqam_doc;

namespace uqam_doc {

    //typedef map< string, float > Dist1D;

    //typedef map< string, map< string, string > >  data;
    //data[ "hey" ][ "yo" ] = "whassup";

    typedef vector<int> Int1D;
    typedef std::vector<Int1D> Int2D;

    class qFuncCalc {
    public:

        //aplication data
        ApplicationData* appl_data_;

        //members
        //string msa_fasta_;
        //string ids_work_csv_;

        //string x_ident_csv_;
        //string a_group_csv_;
        //string b_group_csv_;

        //string q_func_csv_;
        //string align_type_;
        //DistOpt dist_;
        //string mat_;
        //string pval_;
        int win_l_;
        //int q_func_opt_max_idx_;
        //int win_step_;
        //CalcType calc_type_;
        //OptimType optim_type_;

        //default constructors

        virtual ~qFuncCalc();
        //custom constructors
       qFuncCalc(ApplicationData* appl_data);

        //methods
        void readXIdentCsv();
        void readIdsWork();

        void readMsaFasta();
        void genRandNuclMsaFasta();
        void calcMsaLength();

        void eliminateNonUsed();
        //if filtered eliminate non specified
        void filterIdsWork();
        //for debugging purposes
        void show_align_mult_types();
        //calculate window replicates
        //same identifier, same colons
        void calcReplSameIdentSameCol(int win_l);
        //same identifier, different colons
        void calcReplSameIdentDifCol(int win_l);
        //update individual p-value based on window replicates
        void calcPVal(WinQ& q_res);
        //WinQ calcQRes(vector<string>& amX, vector<string>& amY);
        void calculate();


        //members

        int NB_REPL_;

        //virtual calculator
        //DistSeq* dist_seq_;
        //function pointer calculator
        //float (*dist_func_)(string, string);

        //polymorphic function
        DistSeqInterface* dist_calc_;


        //all replicates
        vector< WinQ > all_repl_;

        int nx_,
        ny_,
        align_length_;

        map<string, string> align_mult_types_;

        set<string> x_ident_;
        set<string> y_ident_;
        set<string> ids_work_;

        set<string> all_types_;
        //simpler storage for sequences indexed by x_ident_, y_ident_
        //used in WinQ
        //vector<string> x_seqs_,
        //y_seqs_;

    private:
    };





};


#endif	/* _Q_FUNC_CALC_H */

