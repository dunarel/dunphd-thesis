/* 
 * File:   dist_atom.h
 * Author: root
 *
 * Created on February 10, 2010, 3:55 PM
 */

#ifndef _DIST_ATOM_H
#define	_DIST_ATOM_H

//using namespace std;
//using namespace uqam_doc;

namespace uqam_doc {

    /* one window includes data, processing and results
     * with pluggable distance mesure function
     */
    class DistAtom {
    public:
        /* constructor takes predicted dimensions nx, ny and
         * pluggable distance function
         */
        //WinQ(int nx, int ny, float (*dist_func_)(string, string));
        DistAtom();
        DistAtom(float int_dif, float pos_comp, float pos_incomp, float real_dist);

        virtual ~DistAtom();
        // supposed capacity
        float int_dif_;
        float pos_comp_;
        float pos_incomp_;
        float real_dist_;


    private:

    };
}


#endif	/* _DIST_ATOM_H */

