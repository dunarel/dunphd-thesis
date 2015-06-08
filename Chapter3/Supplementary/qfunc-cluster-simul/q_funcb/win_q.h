/* 
 * File:   win_q.h
 * Author: root
 *
 * Created on February 10, 2010, 2:42 PM
 */

#ifndef _WIN_Q_H
#define	_WIN_Q_H

#include <string>
#include <map>
//#include <ext/hash_map>
#include <vector>
#include <set>
#include "application_data.h"
#include "distance_measures.h"

using namespace std;
using namespace uqam_doc;

namespace uqam_doc {

    /* one window includes data, processing and results
     * with pluggable distance mesure function
     */
    class WinQ {
    public:
        /* constructor takes predicted dimensions nx, ny and
         * pluggable distance function
         */
        //WinQ(int nx, int ny, float (*dist_func_)(string, string));
        WinQ(int nx, int ny, DistSeqInterface* dist_calc);
        virtual ~WinQ();
        // supposed capacity
        int nx_;
        int ny_;

        vector<string> align_mult_x_,
                       align_mult_y_;
        //
        int NB_FUNC_;
        //
        float v_x_;
        float v_y_;
        float d_xy_;
        //nb positions invalides
        float v_x_nb_inv_;
        float v_y_nb_inv_;
        float d_xy_nb_inv_;

        vector<float> q_func_,
        q_p_val_inf_,
        q_p_val_sup_;
        //functions
        void calcQRes();
        void initEmptyAlign();
    private:
        //function pointer calculator
        //float (*dist_func_)(string, string);

        //polymorphic function
        DistSeqInterface* dist_calc_;
    };
}

#endif	/* _WIN_Q_H */

