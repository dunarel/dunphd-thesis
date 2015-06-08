#include "win_q.h"
#include <limits>
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
//#include <xmmintrin.h>


using namespace std;
using namespace uqam_doc;

using uqam_doc::WinQ;

//structure construction

//WinQ::WinQ(int nx, int ny, float (*dist_func)(string, string)) {
WinQ::WinQ(int nx, int ny, DistSeqInterface* dist_calc) {

    //set window capacity
    nx_ = nx;
    ny_ = ny;

    //clear alignments and reserve predicted capacity
    align_mult_x_.clear();
    align_mult_x_.reserve(nx_);

    align_mult_y_.clear();
    align_mult_y_.reserve(ny_);

    //take pointer to calculator function
    dist_calc_ = dist_calc;

    NB_FUNC_ = 5;
    //initialize to zero results

    v_x_ = 0.0;
    v_x_nb_inv_ = 0;

    v_y_ = 0.0;
    v_y_nb_inv_ = 0;

    d_xy_ = 0.0;
    d_xy_nb_inv_ = 0;


    for (int i = 0; i < NB_FUNC_; i++) {
        q_func_.push_back(0.0);
        q_p_val_inf_.push_back(0.0);
        q_p_val_sup_.push_back(0.0);
    }

}

WinQ::~WinQ() {


}

/* calculate q-results */
void WinQ::calcQRes() {

    int nx = align_mult_x_.size();
    int ny = align_mult_y_.size();


    //cout << "nx: " << nx << endl;
    //cout << "ny: " << ny << endl;

    //vX
    v_x_ = 0.0;
    v_x_nb_inv_ = 0;
    int v_x_nb = 0;

    for (int i = 0; i < (nx - 1); i++) {
        for (int j = (i + 1); j < nx; j++) {
            float v_x_elem = dist_calc_->dist_2seq(align_mult_x_.at(i), align_mult_x_.at(j)).real_dist_;

            if (v_x_elem != numeric_limits<float>::max()) {
                //count it
                v_x_nb++;
                //add value
                //v_x_ += pow(v_x_elem, 2.0);
                v_x_ += v_x_elem * v_x_elem;
            } else {
                //count invalid
                v_x_nb_inv_++;
            }


        }
    }

    //cout << "v_x: " << v_x_nb << "v_x formula: " << (nx * (nx - 1) / 2.0) << endl;

    //scale
    v_x_ /=  v_x_nb;
    v_x_nb_inv_ /= v_x_nb;

    //vY
    v_y_ = 0.0;
    v_y_nb_inv_ = 0;
    int v_y_nb = 0;

    for (int i = 0; i < (ny - 1); i++) {
        for (int j = (i + 1); j < ny; j++) {
            float v_y_elem = dist_calc_->dist_2seq(align_mult_y_.at(i), align_mult_y_.at(j)).real_dist_;
             if (v_y_elem != numeric_limits<float>::max()) {
                //count it
                v_y_nb++;
                //add value
                //v_y_ += pow(v_y_elem, 2.0);
                v_y_ += v_y_elem *v_y_elem;
            } else {
                //count invalid
                v_y_nb_inv_++;
            }


        }
    }

    //cout << "v_y: " << v_y_nb << "v_y formula: " << (ny * (ny - 1) / 2.0) << endl;
    //scale v_y_, v_y_nb_inv_
    v_y_ /= v_y_nb;
    v_y_nb_inv_ /= v_y_nb;


    //dXY
    d_xy_ = 0.0;
    d_xy_nb_inv_ = 0;
    int d_xy_nb = 0;

    for (int i = 0; i < nx; i++) {
        for (int j = 0; j < ny; j++) {
           float d_xy_elem = dist_calc_->dist_2seq(align_mult_x_.at(i), align_mult_y_.at(j)).real_dist_;
           if (d_xy_elem != numeric_limits<float>::max()) {
                //count it
                d_xy_nb++;
                //add value
                //d_xy_ += pow(d_xy_elem, 2.0);
                d_xy_ += d_xy_elem *d_xy_elem;
            } else {
                //count invalid
                d_xy_nb_inv_++;
            }

        }
    }

    //cout << "d_xy: " << d_xy_nb << "d_xy formula: " << (nx * ny) << endl;
    //scale
    d_xy_ /= d_xy_nb;
    d_xy_nb_inv_ /= d_xy_nb;


    q_func_[0] = log(1 + d_xy_ - v_x_);
    q_func_[1] = d_xy_ - v_x_;
    q_func_[2] = d_xy_ - v_y_;
    q_func_[3] = 2 * d_xy_ - v_x_ - v_y_;
    q_func_[4] = d_xy_;

}

/* Init empty alignments
 */
void WinQ::initEmptyAlign() {
    //initialise aligns
        for (int i = 0; i < nx_; i++) {
            align_mult_x_.push_back("");
        }

        //initialise
        for (int j = 0; j < ny_; j++) {
            align_mult_y_.push_back("");
        }
}
