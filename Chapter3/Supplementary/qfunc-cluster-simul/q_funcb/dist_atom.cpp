#include "dist_atom.h"

using namespace std;
using namespace uqam_doc;

using uqam_doc::DistAtom;

DistAtom::DistAtom() {
    
}
//structure construction


//WinQ::WinQ(int nx, int ny, float (*dist_func)(string, string)) {
DistAtom::DistAtom(float int_dif, float pos_comp, float pos_incomp, float real_dist) {

    int_dif_ = int_dif;
    pos_comp_ = pos_comp;
    pos_incomp_ = pos_incomp;
    real_dist_ = real_dist;
}

DistAtom::~DistAtom() {


}
