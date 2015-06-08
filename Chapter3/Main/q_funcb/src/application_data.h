/* 
 * File:   ApplicationData.h
 * Author: root
 *
 * Created on January 14, 2010, 4:43 PM
 */

#ifndef _APPLICATIONDATA_H
#define	_APPLICATIONDATA_H


//for random number generator
#include <boost/random/mersenne_twister.hpp>


#include <string>

using namespace std;

namespace uqam_doc {

  enum DistOpt {
	eHAM,
        eJUKES_CANTOR_NUCL,
        eJUKES_KANTOR_PROT,
        eKIM_PROT,
        eSCOREDIST
  };

  enum CalcType {
	eAuto,
        eSimple,
        eSingle
  };

  enum OptimType {
	eNj,
        eKm
  };

  enum ProtMatrix {
      eBLOSUM80,
      eBLOSUM62
  };

    class ApplicationData {
    public:
        //members
        string x_ident_csv_;
        string y_ident_csv_;
        string a_group_csv_;
        string b_group_csv_;

        string msa_fasta_;
        string ids_work_csv_;
        string q_func_csv_;
        string align_type_;
        DistOpt dist_;
        ProtMatrix protmatrix_;
        string mat_;
        string pval_;
        int win_l_;
        int q_func_opt_max_idx_;
        int win_step_;
        CalcType calc_type_;
        OptimType optim_type_;
    
        //boost random number generator
        boost::mt19937 random_number_gen_;

        //constructors
        ApplicationData();
        virtual ~ApplicationData();

        //functions
        void process_cmd_line(int argc, char** argv);

    private:
        void parse_dist_opt();
        void parse_protmatrix_opt(string dist_opt);
    };
};

#endif	/* _APPLICATIONDATA_H */

