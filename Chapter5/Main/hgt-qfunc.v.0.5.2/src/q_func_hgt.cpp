/*
 * File:   q_func_calc.cpp
 * Author: mihaela
 *
 * Created on December 28, 2008, 9:21 PM
 */
//#define arraysize(ar)  (sizeof(ar) / sizeof(ar[0]))
//#define HEX(x) setw(2) << setfill('0') << hex << (int)( x )


//#include "q_func_calc.h"
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <vector>
#include <set>
#include <map>
#include <iterator>
#include <cmath>
#include <ctime>
#include <algorithm>
#include <cfloat>


#include <stdio.h>

//#include <seqan/basic.h>
//#include <seqan/sequence.h>
//#include <seqan/file.h>
//#include <seqan/seq_io.h>

//#include <yannisun/fasta.h>
#include <yannisun/fasta2.c>

#include <omp.h>


#include <stdlib.h>

#include <simdpp/simd.h>
//#define SIMDPP_ARCH_X86_SSE3=1
#include <xmmintrin.h>  // Need this for SSE compiler intrinsics
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <emmintrin.h>
#include <pmmintrin.h>

#include "boost/random.hpp"

#include <assoc_vector/AssocVector.hpp>

#include "csv_v3.h"


#include "application_data.hpp"
#include "q_func_hgt.hpp"
#include "aligned_storage.hpp"



using namespace std;
using namespace uqam_doc;
//using namespace seqan;


//using namespace simdpp;
using namespace ::io;
using namespace simdpp;

using uqam_doc::QFuncHgt;

//http://lists.apple.com/archives/scitech/2008/Jul/msg00005.html
typedef union {
	__m128 v;
	float f[4];
} uf;

//http://stackoverflow.com/questions/4965784/g-sse-memory-alignment-on-the-stack
//union vector {
//    __m128 simd;
//    float raw[4];
//};

//i.e. no additional __attribute__ ((aligned (16))) required for the union itself.
//If you need an array of N of these objects, allocate vector raw[N+1],
// and use vector* const array = reinterpret_cast<vector*>(reinterpret_cast<intptr_t>(raw+1) & ~15)
//as the base address of your array. This will always be aligned.


typedef union {
	__m128i v;
	uint32_t i[4];
} ui;
//uf.v = v5;
//printf("v5= (%f,%f,%f,%f)\n", uf.f[0], uf.f[1], uf.f[2], uf.f[3]);


void print128_num(__m128i var)
{
	uint16_t *val = (uint16_t*) &var;
	printf("Numerical: %i %i %i %i %i %i %i %i \n",
	       val[0], val[1], val[2], val[3], val[4], val[5],
	       val[6], val[7]);
}

// reference implementation
int fast_compare_ref(const char *s, const char *t, int length)
{
	int result = 0;
	int i;

	for (i = 0; i < length; ++i) {
		if (s[i] != t[i])
			result++;
	}
	return result;
}

// optimised implementation
int fast_compare(const char *s, const char *t, int length)
{
	int result = 0;
	int i;

	__m128i vsum = _mm_set1_epi32(0);
	for (i = 0; i < length - 15; i += 16) {
		__m128i vs, vt, v, vh, vl, vtemp;

		vs = _mm_loadu_si128((__m128i *)&s[i]); // load 16 chars from input
		vt = _mm_loadu_si128((__m128i *)&t[i]);
		v = _mm_cmpeq_epi8(vs, vt);             // compare
		vh = _mm_unpackhi_epi8(v, v);           // unpack compare result into 2 x 8 x 16 bit vectors
		vl = _mm_unpacklo_epi8(v, v);
		vtemp = _mm_madd_epi16(vh, vh);         // accumulate 16 bit vectors into 4 x 32 bit partial sums
		vsum = _mm_add_epi32(vsum, vtemp);
		vtemp = _mm_madd_epi16(vl, vl);
		vsum = _mm_add_epi32(vsum, vtemp);
	}

	// get sum of 4 x 32 bit partial sums
	vsum = _mm_add_epi32(vsum, _mm_srli_si128(vsum, 8));
	vsum = _mm_add_epi32(vsum, _mm_srli_si128(vsum, 4));
	result = _mm_cvtsi128_si32(vsum);

	// handle any residual bytes ( < 16)
	if (i < length) {
		result += fast_compare_ref(&s[i], &t[i], length - i);
	}

	return result;
}


// test harness
void main_test()
{
	const int n = 320000000;
	//char* new_;
	//posix_memalign((void**) &new_, 16, n);

	//char* new2_;
	//posix_memalign((void**) &new2_, 16, n);

	char *s = (char*) malloc(n);
	//char *s = new_;

	char *t = (char*) malloc(n);
	//char *t = new2_;

	int i, result_ref, result;

	srand(time(NULL));

	for (i = 0; i < n; ++i) {
		s[i] = rand();
		t[i] = rand();
	}

	result_ref = fast_compare_ref(s, t, n);
	//result = fast_compare(s, t, n);

	printf("result_ref = %d, result = %d\n", result_ref, result);

}

//custom constructor

QFuncHgt::QFuncHgt(ApplicationData* appl_data)
{

	printf("in QFuncHgt::QFuncHgt(ApplicationData* appl_data) \n");

	//take application data pointer
	appl_data_ = appl_data;

	//align_len = 695;
	align_len = appl_data_->win_l_;
	cout << "align_len: " << align_len << endl;

	align_len_reciprocal = 1.0f/align_len;

	nb_mutations = floor(align_len * 0.15);
	nb_repl_ = 1000;

	nb_seqs = 0;



}

bool my_sort_function (int i,int j)
{
	return (i<j);
}

QFuncHgt::~QFuncHgt()
{

	printf("in QFuncHgt::~QFuncHgt() \n");
	//free alignement buffer
	//free(align_buff);
	//msa_al_st;

	//multi_array<AlignedStorage<float>*, 2> cell_2d = *pcell_2d;

	//do not forget to deallocate components of this pointer matrices
	//boost::multi_array< double, 3 > ma(boost::extents[3][4][2]);

	/*
		for(auto i = (*work_groups_).origin(); i < ((*work_groups_).origin() + (*work_groups_).num_elements()); ++i) {
			(*i)->dealloc();
		}
		delete work_groups_;

		for(auto i = (*rest_groups_).origin(); i < ((*rest_groups_).origin() + (*rest_groups_).num_elements()); ++i) {
			(*i)->dealloc();
		}
		delete rest_groups_;
	*/


	//std::fill( boo.data(), boo.data() + boo.num_elements(), 0 );






}

void QFuncHgt::allocBuffers()
{

	const int rangeMin = 0;
	const int rangeMax = 1;
	boost::uniform_int<int>* distribution_ =  new boost::uniform_int<>( 0, align_len );
	//RandomNumberGenerator generator = RandomNumberGenerator();
	//Generator numberGenerator = Generator(generator_, distribution_);
	//generator_.seed( 0 ); // seed with some initial value


	////////////////////////////////////////// MSA
	//read only - no false sharing
	msa_st_ = new AlignedStorage<char>(nb_seqs,align_len, eSIMD);
	msa_st_->alloc_align_internal();
	msa_st_->init_pad('\0','\0');

	msa_rp_ = new AlignedStorage<char>(nb_seqs,align_len, eSIMD);
	msa_rp_->alloc_align_internal();
	msa_rp_->init_pad('\0','\0');



	///////////////////////////////////////// WORK
	//common to all groups
	work_groups_ = new multi_array<AlignedStorage<float>*, 2>(extents[nb_groups][nb_groups]);
	//REST groups
	rest_groups_ = new multi_array<AlignedStorage<float>*, 2>(extents[nb_groups][nb_groups]);
	//
	ig_dist_ = new multi_array<float, 2>(extents[nb_groups][nb_groups]);

	/////////////////////////////////////////// Allocate grouped buffers
	for(int i = 0; i < nb_groups; ++i) {
		for(int j = 0; j < nb_groups; ++j) {
			//degugging

			int i_size = grpidx_seqidx_[i].size();
			int j_size = grpidx_seqidx_[j].size();

			//each work group has its pointer
			AlignedStorage<float>* wg_st;
			//each work group has its local pointer
			wg_st = new AlignedStorage<float>(i_size,j_size, eSIMD);
			wg_st->alloc_align_internal();
			//wg_st->init_pad(0.0,0.0);
			//link to property container
			(*work_groups_)[i][j] = wg_st;

			//wg_st->print_buff_scal();


			AlignedStorage<float>* wg_rg;
			//same for rest groups, multithreaded on WRITE -> padded to cacheline
			//allocate for i_size (column vector initially then stored as a line)
			wg_rg = new AlignedStorage<float>(1,i_size, eCACHE);
			wg_rg->alloc_align_internal();
			//wg_rg->init_pad(0.0,0.0);
			//wg_rg->print_buff_scal();

			//link to property container
			(*rest_groups_)[i][j] = wg_rg;

			//
			(*ig_dist_)[i][j] = 0.0;
		}
	}

	///////////////////////////// linear distance matrix
	dist_mtx_ = new multi_array<float, 2>(extents[nb_seqs][nb_seqs]);


	/////////////////////////// TRSF
	trsfs_ = new AlignedStorage<float>(nb_seqs,nb_seqs, eCACHE);
	trsfs_->alloc_align_internal();

	repls_ = new AlignedStorage<float>(nb_seqs,nb_seqs, eCACHE);
	repls_->alloc_align_internal();

	pvals_ = new AlignedStorage<float>(nb_seqs,nb_seqs, eCACHE);
	pvals_->alloc_align_internal();


	//
	// create an instance of the functor class
	align_rand_int_ = new rand_int(time(NULL), align_len);





}

void QFuncHgt::initBuffers()
{

	////////////////////////////////////////// MSA
	//read only - no false sharing
	msa_st_->init_pad('\0','\0');
	msa_rp_->init_pad('\0','\0');

	/////////////////////////////////////////// Allocate grouped buffers
	for(int i = 0; i < nb_groups; ++i) {
		for(int j = 0; j < nb_groups; ++j) {
			(*work_groups_)[i][j]->init_pad(0.0,0.0);
			(*rest_groups_)[i][j]->init_pad(0.0,0.0);
			//wg_st->print_buff_scal();
			//wg_rg->print_buff_scal();
			//
			(*ig_dist_)[i][j] = 0.0;

		}
	}

	////////////////////////////// linear distance matrix
	for(int i = 0; i < nb_seqs; ++i) {
		for(int j = 0; j < nb_seqs; ++j) {
			(*dist_mtx_)[i][j] = 0.0;

		}
	}

	////////////////////////////////TRSF
	trsfs_->init_pad(0.0,0.0);
	repls_->init_pad(0.0,0.0);

	//pvals have neutral value at 1
	//but they will be updated
	pvals_->init_pad(0.0,0.0);

}

void QFuncHgt::deallocBuffers()
{

	//MSA is regular not pointer, it will be deleted out of scope later.
	delete msa_st_;
	delete msa_rp_;
	/////////////////////////////////////////// Deallocate grouped buffers

	for(auto i = (*work_groups_).origin(); i < ((*work_groups_).origin() + (*work_groups_).num_elements()); ++i) {
		delete (*i);
	}
	delete work_groups_;

	for(auto i = (*rest_groups_).origin(); i < ((*rest_groups_).origin() + (*rest_groups_).num_elements()); ++i) {
		delete (*i);
	}
	delete rest_groups_;

	//simple structure, no pointers inside
	delete ig_dist_;







	//for(int i = 0; i < nb_groups; ++i) {
	//	for(int j = 0; j < nb_groups; ++j) {
	//		delete (*work_groups_)[i][j];
	//		delete (*rest_groups_)[i][j];
	//	}
	//}
	//delete work_groups_;


	//delete rest_groups_;

	delete dist_mtx_;
	//////////////////////////////////
	delete trsfs_;
	delete repls_;
	delete pvals_;


	//
	delete align_rand_int_;


}




void QFuncHgt::readGrSeqsCsv()
{
	cout << "in QfuncHgt::readGroupsCsv() \n";

	//////////////////////////////////// read file
	// name - hardcoded
	///string nameGrSeqsCsv = "/root/devel/PROJ_CPP/hgt-qfunc5/r-proj/gr-seq-df.csv";
	//string nameGrSeqsCsv = "gr-seq-df.csv";
	string nameGrSeqsCsv = appl_data_->gr_seqs_csv_;


	//for ordering by group-seqs - lexicographic ////////////////////////////
	//local
	AssocVector<pair<int, string>, int> gr_seqs;
	AssocVector<pair<int, string>, int>::iterator itr;


	//read csv file
	int rownb = 0;
	::io::CSVReader<2, trim_chars<' '>, double_quote_escape<',','\"'> > in(nameGrSeqsCsv);
	//hardcoded column names
	in.read_header(::io::ignore_extra_column, "PROK_GROUP_ID", "NCBI_SEQ_ID");


	string rowid;
	int grpid;
	string seqid;
	while(in.read_row(grpid, seqid)) {

		// do stuff with the data
		//cout << "grpid: " << grpid << " seqid " << seqid << "\n";

		//order by insert - rownb is just insertion order i.e. file order
		gr_seqs[make_pair(grpid,seqid)]= rownb;
		rownb++;
	}
	//finished ordering - now we know nb of sequences
	nb_seqs = gr_seqs.size();

	//////////////////////////////////// lay out data

	//one row per group
	grpidx_seqidx_.reserve(32);
	grpidx_seqidx_.clear();
	//one row per group
	grpidx_grpid_.reserve(32);
	grpidx_grpid_.clear();
	//many sequences
	seqid_seqidx_.reserve(nb_seqs);
	seqid_seqidx_.clear();
	//many sequences
	seqidx_seqid_.reserve(nb_seqs);
	seqidx_seqid_.clear();

	//cout << "1" << endl;
	int key1_tmp=-1;
	//iterate groups and sorted sequences
	int grpidx = -1;
	//seqidx is a global index in this final double sorted order, by grpid and seqid
	int seqidx = -1;
	for(itr = gr_seqs.begin(); itr != gr_seqs.end(); ++itr) {
		//new seq
		seqidx++;
		//grpid
		int key1 = (*itr).first.first;
		//seqid
		string key2 = (*itr).first.second;
		//file order
		int val = (*itr).second;
		//check if group is changing
		if (key1_tmp != key1) {
			//new group
			grpidx++;
			//index is grpidx itself (ordered insert)
			grpidx_grpid_.push_back(key1);
			//new container for sequences belonging to this grpidx
			vector<int> locseq(128);
			grpidx_seqidx_.push_back(locseq);
			grpidx_seqidx_[grpidx].clear();


		}

		//index is locseqidx (ordered insert)
		grpidx_seqidx_[grpidx].push_back(seqidx);
		//for sequences lookup in msa
		seqid_seqidx_[key2] = seqidx;
		//index is seqidx itself (ordered insert)
		//value is seqid
		seqidx_seqid_.push_back(key2);


		key1_tmp=key1;

		//cout << "grpid: " << key1 << " seqid: " << key2 << " insert_order: " << val << "\n";

	}

	//we know now the number of groups
	nb_groups = grpidx_grpid_.size();
	//they will not change - reduce size
	grpidx_seqidx_.shrink_to_fit();
	grpidx_grpid_.shrink_to_fit();
	//
	seqid_seqidx_.shrink_to_fit();
	seqidx_seqid_.shrink_to_fit();



}





void QFuncHgt::readMsaFasta()
{
	cout << "in QFuncHgt::readMsaFasta() \n";



	//align_buff = align_store.alloc_align();
	//align_store.assign(align_buff);


	// name - hardcoded
	//char* nameMsaFasta = "/root/devel/PROJ_CPP/hgt-qfunc5/files/thrC.fasta";
	//char* nameMsaFasta = "msa_fasta.fa";
	const char* nameMsaFasta = appl_data_->msa_fasta_.c_str();

  FASTAFILE *ffp;
  char *seq;
  char *name;
  int   L;

  ffp = OpenFASTA(nameMsaFasta);
  while (ReadFASTA(ffp, &seq, &name, &L))
    {
      //printf(">%s\n", name);
      //printf("%s\n",  seq);
	//find right position
		int row_pos = seqid_seqidx_.at(name);
		msa_st_->strcpy_row(seq,row_pos);

      free(seq);
      free(name);
    }
  CloseFASTA(ffp);


}

void QFuncHgt::calcWorkDistMatrix(AlignedStorage<char>* msa_st,
                                  multi_array<AlignedStorage<float>*, 2>* work_groups,
                                  multi_array<AlignedStorage<float>*, 2>* rest_groups)
{
	//cout << "in QFuncHgt::calcWorkDistMatrix() \n";

	//cout << "nb_groups: " << nb_groups << " nb_seqs: " << nb_seqs << "\n";


	int thr = omp_get_max_threads();
	omp_set_num_threads(6);
	//cout << "using threads: " << thr << endl;


//sleep(1);

	#pragma omp parallel for schedule(dynamic,1) collapse(2)
	for(int i = 0; i < nb_groups; ++i) {
		for(int j = 0; j < nb_groups; ++j) {
			//degugging
			if ( !(i==7 && j == 10)) {
				//continue;
			}

			int i_size = grpidx_seqidx_[i].size();
			int j_size = grpidx_seqidx_[j].size();

			if (i_size < 2 || j_size <2 ) {
				continue;
			}

			//cout << "i" << i << "->" << j << " i_size " << i_size << " j_size " << j_size << endl;
//printf("Hello, world! This is thread %d of %d\n", omp_get_thread_num(), omp_get_num_threads());

			//each work group has its pointer
			AlignedStorage<float>* wg_st = (*work_groups)[i][j];
			//each work group has its local pointer

			//wg_st->print_buff_scal();
			AlignedStorage<float>* wg_rg = (*rest_groups)[i][j];


			//inside group matrix
			for (int locseqidx_i=0; locseqidx_i<i_size; locseqidx_i++) {
				//get stringdx and pointer
				int seqidx_i = grpidx_seqidx_[i][locseqidx_i];
				//char* seq_ch_i = msa_st_.store_ + msa_st_.pos_scal(seqidx_i,0);
				char* seq_ch_i = msa_st->pointer_row(seqidx_i) + 0;

				for (int locseqidx_j=0; locseqidx_j<j_size; locseqidx_j++) {

					int seqidx_j = grpidx_seqidx_[j][locseqidx_j];
					//char* seq_ch_j = msa_st_.store_ + msa_st_.pos_scal(seqidx_j,0);
					char* seq_ch_j = msa_st->pointer_row(seqidx_j) + 0;

					//inside aligned storage offset calculation
					int ham_dist = fast_compare_ref(seq_ch_i, seq_ch_j, align_len);
					float ham_dist_norm = ham_dist * align_len_reciprocal;


					//debug
					//get seqid (name)
					//string seqid_i = seqidx_seqid_[seqidx_i];
					//string seqid_j = seqidx_seqid_[seqidx_j];
					//cout << "i: " << i << " locseqidx_i: " << locseqidx_i << " seqidx_i: " << seqidx_i << " seqid_i: " << seqid_i << endl;
					//cout << "j: " << j << " locseqidx_j: " << locseqidx_j << " seqidx_j: " << seqidx_j << " seqid_j: " << seqid_j << endl;
					//cout << "ham_dist_norm: " << ham_dist_norm << endl;
					//get strings and put them
					//string seq_i = string(seq_ch_i,align_len);
					//string seq_j = string(seq_ch_j,align_len);
					//cout << "seq_i: " << seq_i << endl;
					//cout << "seq_j: " << seq_j << endl;

					//store
					//float* tst1 = wg_st->store_ + wg_st->pos_scal(locseqidx_i,locseqidx_j);
					//float* tst2 = wg_st->pointer_row(locseqidx_i) + locseqidx_j;
					//cout << "tst1: " << tst1 << " tst2: " << tst2 << endl;
					//*(wg_st->store_ + wg_st->pos_scal(locseqidx_i,locseqidx_j)) = ham_dist_norm;
					*(wg_st->pointer_row(locseqidx_i) + locseqidx_j) = ham_dist_norm;
					//store also in flat structure for display
					(*dist_mtx_)[seqidx_i][seqidx_j] = ham_dist_norm;

				} //end row

				//row is now available
				float* a = wg_st->store_ + wg_st->pos_scal(locseqidx_i,0);
				//SIMD sum it up SSE2 + SSE3
				__m128 sum4 = _mm_set1_ps(0.0f);
				int i4 = 0;
				int N = ROUND_UP(j_size, 4);
				//cout << "j_size: " << j_size << " N: " << N << endl;
				for(; i4 < ROUND_UP(j_size, 4); i4+=4) {
					__m128 a4 = _mm_load_ps(a + i4);

					/*
					uf ufa;
					uf ufb;
					uf ufc;

					ufa.v = a4;
					ufb.f[0] = 10;
					ufb.f[1] = 20;
					ufb.f[2] = 30;
					ufb.f[3] = 10000;
					ufc.v = _mm_add_ps(ufa.v,ufb.v);

					printf("ufa= (%f,%f,%f,%f)\n", ufa.f[0], ufa.f[1], ufa.f[2], ufa.f[3]);
					printf("ufb= (%f,%f,%f,%f)\n", ufb.f[0], ufb.f[1], ufb.f[2], ufb.f[3]);
					printf("ufc= (%f,%f,%f,%f)\n", ufc.f[0], ufc.f[1], ufc.f[2], ufc.f[3]);
					*/

					sum4 = _mm_add_ps(sum4, a4);
				}
				//final reduction
				__m128 t1 = _mm_hadd_ps(sum4,sum4);
				__m128 t2 = _mm_hadd_ps(t1,t1);
				float sum = _mm_cvtss_f32(t2);
				//cout << "sum: " << sum << endl;
				//store value
				//*(wg_rg + locseqidx_i) = sum;

				//*(wg_rg->pointer_row(0) + locseqidx_i) = sum / (j_size -1);
				*(wg_rg->pointer_row(0) + locseqidx_i) = sum;
				//intergroup matrix
				//float pre_id_dist = (*ig_dist_)[i][j];
				//cout <<" i: " << i << " j: " << j <<  " pre_id_dist: " << pre_id_dist << endl;

				(*ig_dist_)[i][j] += sum;

			} //end buffer

			wg_st = NULL;
			wg_rg = NULL;

			//arithmetic average sum / nb_elem
			(*ig_dist_)[i][j] /= (i_size * j_size);

			//wg_st->print_buff_scal();
			//displayRestVector(i,j);




		}
//IMPORTANT: no code in here
	} //end omp


}


//TRSF flat aligned array of nb_seqs x nb_seqs
void QFuncHgt::calcTrsfs(multi_array<AlignedStorage<float>*, 2>* work_groups,
                         multi_array<AlignedStorage<float>*, 2>* rest_groups,
                         AlignedStorage<float>* trsfs)
{
	//cout << "in QFuncHgt::calcTrsfs()" << endl;

	//calculations are done on upper half of the groups triangle
	//TRSF are results in a flat array of nb_seqs x nb_seqs

	//need an anchor
	//AlignedStorage<float>* wg_tr;
	//wg_tr = new AlignedStorage<float>();
	//wg_tr <float>(nb_seqs,nb_seqs, eCACHE);
	//link to container
	//trsfs_ = wg_tr;

	//trsfs_->print_buff_scal();



//grpidx_seqidx_.size() == nb_groups

	#pragma omp parallel for schedule(dynamic,1) collapse(2)
	for (int grpidx_i=0; grpidx_i< nb_groups; grpidx_i++) {
		for (int grpidx_j=grpidx_i + 1; grpidx_j< nb_groups; grpidx_j++) {

			//degugging
			//if ( !(grpidx_i==7 && grpidx_j == 10)) {
				//continue;
			//}

			int i_size = grpidx_seqidx_[grpidx_i].size();
			int j_size = grpidx_seqidx_[grpidx_j].size();
			//for group dimension calculations
			float n_size = (float) i_size;
			float m_size = (float) j_size;


			//cout << "grpidx_i " << grpidx_i << "->" << grpidx_j << " i_size " << i_size << " j_size " << j_size << endl;

			if (i_size == 1 || j_size == 1) {
				continue;
			}

			for (int locseqidx_i=0; locseqidx_i< i_size; locseqidx_i++) {
				for (int locseqidx_j=0; locseqidx_j< j_size; locseqidx_j++) {


//printf("Hello, world! This is thread %d of %d\n", omp_get_thread_num(), omp_get_num_threads());

					AlignedStorage<float>* grA = (*rest_groups)[grpidx_i][grpidx_i]; //x1GrX <AlignedStorage<float>*, 2>
					float xGrX = *(grA->pointer_row(0) + locseqidx_i);

					AlignedStorage<float>* grB = (*rest_groups)[grpidx_j][grpidx_i];
					float yGrX = *(grB->pointer_row(0) + locseqidx_j);


					AlignedStorage<float>* grC = (*rest_groups)[grpidx_i][grpidx_j];
					float xGrY = *(grC->pointer_row(0) + locseqidx_i);


					AlignedStorage<float>* grD = (*rest_groups)[grpidx_j][grpidx_j];
					float yGrY = *(grD->pointer_row(0) + locseqidx_j);

					AlignedStorage<float>* grE = (*work_groups)[grpidx_i][grpidx_j];
					float flE = *(grE->pointer_row(locseqidx_i) + locseqidx_j);

					float dXX = (*ig_dist_)[grpidx_i][grpidx_i];
					float dYY = (*ig_dist_)[grpidx_j][grpidx_j];
					float dXY = (*ig_dist_)[grpidx_i][grpidx_j];

					float xXrest= xGrX;
					float yYrest= yGrY;

					float xYrest= xGrY -flE;
					float yXrest= yGrX -flE;


					//cout << "xGrX: " << xGrX << " yGrX: " << yGrX << " xGrY: " << xGrY << " yGrY: " << yGrY << " flE: " << flE << endl;
					//sequences for each group
					/*
					for (int grpidx=0; grpidx< grpidx_seqidx_.size(); grpidx++) {
						for (int locseqidx=0; locseqidx< grpidx_seqidx_[grpidx].size(); locseqidx++) {

							int seqidx = grpidx_seqidx_[grpidx][locseqidx];
							//get seqname and put it
							string seqid = seqidx_seqid_[seqidx];

							cout << "grpidx: " << grpidx << " locseqidx: " << locseqidx << " seqidx: " << seqidx << " seqid: " << seqid << endl;
							//get string and put it
							string seq = string( (char*) (msa_st_.store_ + msa_st_.pos_scal(seqidx,0)),align_len);
							cout << "seq: " << seq << endl;

						}
					}
					*/
					int seqidx_i = grpidx_seqidx_[grpidx_i][locseqidx_i];
					int seqidx_j = grpidx_seqidx_[grpidx_j][locseqidx_j];

					float val_x,val_y;

					float valXY;
					float valYX;

					float sqew1 = 0;
					float sqew2 = 0;


					switch (appl_data_->q_func_opt_max_idx_) {
						
					//Q7a (eq 5.21) -> Q7
					case 1:
						//corrected
						valXY = 2 + (xXrest + yXrest)/(2*(n_size-1)) - flE;
						valYX = 2 + (xYrest + yYrest)/(2*(m_size-1)) - flE;
						break;
						
					//Q8a (eq 5.22)
					case 2:
						//corrected
						valXY = (FLT_EPSILON + xXrest + yXrest + xYrest + yYrest) / ((FLT_EPSILON + flE) * 2 * (n_size + m_size - 2));
						valYX = valXY;
						break;
						
					//Q8b (eq 5.23)
					case 3:
						//first article test - former 8
						valXY = (FLT_EPSILON + (xGrX + yGrX)/(n_size-1) + (xGrY + yGrY)/(m_size-1))  / ((FLT_EPSILON + flE) * 2 );
						valYX = valXY; //(FLT_EPSILON + xGrY * yGrY) / (FLT_EPSILON + flE);
						break;
					
					
					//Q9a (eq 5.24) -> Q9
					case 4:
						valXY = 2 - flE;
						valYX = valXY;
						break;
						
					default:
						cout << "unknown function";
						exit(1);
					}


					float fle_coef = 0;


					int dir_level = 0;

					if (valXY > valYX) {
						dir_level = 1;
						//fle_coef = sqew1;

					} else {
						dir_level = -1;
						//fle_coef = (1/sqew1);
					}

					//if (dir_level == 1 && valXY >= 1.0) {
					if (dir_level == 1 && *(trsfs_->pointer_row(seqidx_j)+seqidx_i)== 0.0) {

						*(trsfs->pointer_row(seqidx_i)+seqidx_j)= valXY;
						//*(trsfs_->pointer_row(seqidx_j)+seqidx_i)= 0.0;
					}

					if (dir_level == -1 && *(trsfs_->pointer_row(seqidx_i)+seqidx_j)== 0.0) {

						*(trsfs->pointer_row(seqidx_j)+seqidx_i)= valYX;
						//*(trsfs_->pointer_row(seqidx_i)+seqidx_j)= 0.0;
					}

					// = ;

					//if (valXY >= 3.0 || valYX >= 3.0) {
					//}




					//cout << "seqidx_i: " << seqidx_i << " seqidx_j: " << seqidx_j
					//	 << "xGrX: " << xGrX << " yGrX: " << yGrX << " xGrY: " << xGrY << " yGrY: " << yGrY << " flE: " << flE
					//     << " valXY: " <<valXY << " valYX: "<< valYX << endl;



				}

			}
		}


	}
}

void QFuncHgt::calcScore()
{

	
	//calculate grouped distance matrix
	calcWorkDistMatrix( msa_st_, work_groups_, rest_groups_);

	//displayWorkDistMatrix(work_groups_,10,6);
	//displayRestVector(rest_groups_, 10, 6);

	//displayWorkDistMatrix(10,6);
	//displayWorkDistMatrix(work_groups_,10,6);



	//calculate transfers
	calcTrsfs(work_groups_,rest_groups_,trsfs_);



}

void QFuncHgt::calcRepl()
{


	for (auto i=0; i<nb_repl_; i++ ) {
		mutateMsa();

		//displayMsaData(msa_rp_);
		/////////////////////////////////////////// Init work buffers
		for(int i = 0; i < nb_groups; ++i) {
			for(int j = 0; j < nb_groups; ++j) {
				(*work_groups_)[i][j]->init_pad(0.0,0.0);
				(*rest_groups_)[i][j]->init_pad(0.0,0.0);
				//wg_st->print_buff_scal();
				//wg_rg->print_buff_scal();

			}
		}
		////////////////////////////////TRSF
		repls_->init_pad(0.0,0.0);

		//do work with replicates on work buffers
		//calculate grouped distance matrix
		calcWorkDistMatrix( msa_rp_, work_groups_, rest_groups_);

		//displayWorkDistMatrix(work_groups_,10,6);
		//displayRestVector(rest_groups_, 10, 6);


		//calculate transfers
		calcTrsfs(work_groups_,rest_groups_,repls_);
		//displayTrsfs(repls_);


		int diffs = 0;
		int miss = 0;
		///////////////////////////// Update pvals matrix
		for(int i = 0; i < nb_seqs; ++i) {
			for(int j = 0; j < nb_seqs; ++j) {

				float trsf_val = *(trsfs_->pointer_row(i)+j);
				float repl_val = *(repls_->pointer_row(i)+j);
				if (repl_val >= trsf_val) {
					(*(pvals_->pointer_row(i)+j))++;
					diffs++;
					//cout << "i: " << i << " j: " << j << " trsf_val: " << trsf_val << "repl_val: " << repl_val << endl;

				} else {
					miss++;
					//cout << "i: " << i << " j: " << j << " trsf_val: " << trsf_val << "repl_val: " << repl_val << endl;
				}
			}


		}
		//cout << "diffs: " << diffs << " miss: " << miss << endl;

	}





}

void QFuncHgt::mutateMsa()
{
	//cout << "in QFuncHgt::mutateMsa()" << endl;


	//msa_rp_->init_pad('\0','\0');

	//copy container
	*msa_rp_ = *msa_st_;


	//msa_rp_->print_buff_scal();




	//int N(100);
	//for (int i(0); i < N; ++i) {
	//	std::cout << align_rand_int() << std::endl; // each time the the operator()
	//}

	for (auto i = 0; i< msa_rp_->rows_; i++) {

		char* seq_ch_i = msa_rp_->pointer_row(i) + 0;

		//cout << "i: " << i << "before: " << " seq_ch_i: " << string (seq_ch_i, 10 ) << endl;
		for (auto j = 0; j< nb_mutations; j++) {

			int a = align_rand_int_->next();
			int b = align_rand_int_->next();
			swap(seq_ch_i[a], seq_ch_i[b]);
		}
		//cout << "i: " << i << "after: " << " seq_ch_i: " << string (seq_ch_i, 10 ) << endl;

	}


}

void QFuncHgt::calcVals()
{
	cout << "in QFuncHgt::calcVals()" << endl;





	//if there is a filter on identifiers, load those
	//if (appl_data_->ids_work_csv_.size() != 0) {
	//    q_func->readIdsWork();
	//    q_func->filterIdsWork();
	//} else {
	//    q_func->readXIdentCsv();
	// q_func->eliminateNonUsed();
	//}


	//rewrite with random sequences
	//m.genRandNuclMsaFasta();



	//m.show_align_mult_types();

	//q_func_hgt->calculate();


}

void QFuncHgt::calcPvals()
{

}


void QFuncHgt::calculate()
{
	cout << "in QFuncHgt::calculate() \n";

//read groups and allocate memory structures
	readGrSeqsCsv();

	allocBuffers();
	initBuffers();

	//read and lay out sequences
	readMsaFasta();

	calcScore();

	//for debugging
	//displayData();
	//fileDistMatrix();

	calcRepl();



	fileTrsfs();

	deallocBuffers();






	//p_float p_fl3;
	//p_fl3 = (*pcell_2d)[3][2];

	//float a = *(p_fl3);
	//float b = *(p_fl3+1);
	//cout << "a: " << a << endl;
	//cout << "b: " << b << endl;



	//displayData();
	//displayMsaData();

	//displayRestVector(10,6);

	//displayRestVector(7,10);
	//displayTrsfs();

	/*
	char *foo;

	posix_memalign((void**) &foo, alignment, 20);

	char* pnt = foo;

	for(size_t i = 0; i< 20; i++) {
	   pnt = foo+i;
	  *pnt = 'a';
	}
	 *(foo+19) = '\0';

	printf("-------------- \n");
	for(size_t i = 0; i< 20; i++) {
	    char ch = *(foo+i);
	    printf ("Characters: %i %c %c \n", i, ch, 65);

	}




	char* from_str = "bbb";

	pnt = foo + 10;
	strcpy(pnt,from_str);

	 printf("-------------- \n");
	 for(size_t i = 0; i< 20; i++) {
	    char ch = *(foo+i);
	    printf ("Characters: %c %c \n", ch, 65);

	}

	//foo += 100;
	//strcpy(foo,from_str);


	cout << "one: " << (foo+5) << "\n";
	cout << "two: " << (foo+15) << "\n";

	free(foo);

	*/

}


void QFuncHgt::displayData()
{
	cout << "in QFuncHgt::displayData() \n";

	cout << "nb_groups: " << nb_groups << " nb_seqs: " << nb_seqs << "\n";


	//display groups
	vector<int>::iterator it;

	for(it =  grpidx_grpid_.begin(); it != grpidx_grpid_.end(); ++it) {

		int key0 = (*it);
		cout << "key0: " << key0 << "\n";
	}


	/*
	vector<int> loc;
	for(int i =0; i<grpidx_grpid_.size(); i++) {
		loc = grpidx_seqidx_[i];
		for(it = loc.begin(); it != loc.end(); ++it) {

			int seqidx = (*it);
			string seqid = seqidx_seqid_[seqidx];

			cout << "group: " << i << " seqidx: " << seqidx << " seqid: " << seqid << " \n";
		}

	}
	*/


	//sequences for each group
	for (int grpidx=0; grpidx< grpidx_seqidx_.size(); grpidx++) {
		for (int locseqidx=0; locseqidx< grpidx_seqidx_[grpidx].size(); locseqidx++) {

			int seqidx = grpidx_seqidx_[grpidx][locseqidx];
			//get seqname and put it
			string seqid = seqidx_seqid_[seqidx];

			cout << "grpidx: " << grpidx << " locseqidx: " << locseqidx << " seqidx: " << seqidx << " seqid: " << seqid << endl;
			//get string and put it
			string seq = string( (char*) (msa_st_->pointer_row(seqidx) + 0),align_len);
			cout << "seq: " << seq << endl;

		}
	}




}

void QFuncHgt::displayMsaData(AlignedStorage<char>* msa)
{
	cout << "in QFuncHgt::displayMsaData() \n";

	//AlignedStorage<char> align_store = AlignedStorage<char>(nb_seqs,align_len,eSIMD);
	//msa_al_st.align_store.assign(align_buff);

	msa->print_buff_scal();

}

void QFuncHgt::displayWorkDistMatrix(multi_array<AlignedStorage<float>*, 2>* work_groups, int rowGroup, int colGroup)
{
	cout << "in QFuncHgt::displayWorkDistMatrix(" <<rowGroup << "," << colGroup << ") \n";

	//int i_size = grpidx_seqidx_[rowGroup].size();
	//int j_size = grpidx_seqidx_[colGroup].size();

	AlignedStorage<float>* al_st = (*work_groups)[rowGroup][colGroup];

	al_st->print_buff_scal();



}

void QFuncHgt::displayRestVector(multi_array<AlignedStorage<float>*, 2>* rest_groups,int rowGroup, int colGroup)
{
	cout << "in QFuncHgt::displayRestVector(" <<rowGroup << "," << colGroup << ") \n";

	int i_size = grpidx_seqidx_[rowGroup].size();
	//int j_size = grpidx_seqidx_[colGroup].size();

	//float* wg_rg = (*rest_groups)[rowGroup][colGroup];
	AlignedStorage<float>* wg_rg = (*rest_groups)[rowGroup][colGroup];

	//int init_size = i_size * sizeof(*wg_rg);
	//int buff_size = ROUND_UP(init_size ,  CACHE_LINE);
	//cout << "wg_rg init_size: " << init_size << " buff_size: " << buff_size << endl;

	//for (int i=0; i< buff_size / sizeof(*wg_rg); i++) {
	//	cout << *(wg_rg + i) << " ";
	//}
	//cout << endl;
	wg_rg->print_buff_scal();




}

void QFuncHgt::displayTrsfs(AlignedStorage<float>* trsfs)
{

	ofstream trsf_csv_f;
	trsf_csv_f.open ("q-func-hgt-trsfs.csv");
	trsf_csv_f << "grpidx_i" << "," << "grpidx_j" << "," << "i_size" << "," << "j_size" << ","
	           << "locseqidx_i" << "," << "locseqidx_j" << ","
	           << "grpid_i" << "," << "grpid_j" << "," << "seqid_i" << "," << "seqid_j" << "," << "val" << endl;


	cout << "in QFuncHgt::displayTrsfs() " << endl;

	for (int grpidx_i=0; grpidx_i< nb_groups; grpidx_i++) {
		for (int grpidx_j=0; grpidx_j< nb_groups; grpidx_j++) {

			//degugging
			if  (grpidx_i==grpidx_j) {
				continue;
			}

			int i_size = grpidx_seqidx_[grpidx_i].size();
			int j_size = grpidx_seqidx_[grpidx_j].size();

			if (i_size == 1 || j_size == 1) {
				continue;
			}

			for (int locseqidx_i=0; locseqidx_i< i_size; locseqidx_i++) {
				for (int locseqidx_j=0; locseqidx_j< j_size; locseqidx_j++) {

					/*
					for (int grpidx=0; grpidx< grpidx_seqidx_.size(); grpidx++) {
						for (int locseqidx=0; locseqidx< grpidx_seqidx_[grpidx].size(); locseqidx++) {

							int seqidx = grpidx_seqidx_[grpidx][locseqidx];
							//get seqname and put it
							string seqid = seqidx_seqid_[seqidx];

							cout << "grpidx: " << grpidx << " locseqidx: " << locseqidx << " seqidx: " << seqidx << " seqid: " << seqid << endl;
							//get string and put it
							string seq = string( (char*) (msa_st_.store_ + msa_st_.pos_scal(seqidx,0)),align_len);
							cout << "seq: " << seq << endl;

						}
					}
					*/

					int seqidx_i = grpidx_seqidx_[grpidx_i][locseqidx_i];
					int seqidx_j = grpidx_seqidx_[grpidx_j][locseqidx_j];

					float val = *(trsfs->pointer_row(seqidx_i)+seqidx_j);

					//cout << "grpidx_i " << grpidx_i << "->" << grpidx_j << " i_size " << i_size << " j_size " << j_size << endl;
					//cout << "locseqidx_i: " << locseqidx_i << " locseqidx_j: " << locseqidx_j << " seqidx_i: " << seqidx_i << " seqidx_j: " << seqidx_j << endl;

					int grpid_i = grpidx_grpid_[grpidx_i];
					int grpid_j = grpidx_grpid_[grpidx_j];

					string seqid_i = seqidx_seqid_[seqidx_i];
					string seqid_j = seqidx_seqid_[seqidx_j];

					//cout << "grpid_i: " << "," << grpid_i << " grpid_j: " << grpid_j << " val: " << val << endl;

					if (val != 0) {
						//if (true) {
						trsf_csv_f << fixed << showpoint << setprecision(5)
						           << grpidx_i << "," << grpidx_j << "," << i_size << "," << j_size << ","
						           << locseqidx_i << "," << locseqidx_j << ","
						           << grpid_i << "," << grpid_j << "," << seqid_i << "," << seqid_j << "," << val << endl;
					}

				}


			}

		}
	}

	trsf_csv_f.close();


}

void QFuncHgt::fileTrsfs()
{

	ofstream trsf_csv_f;
	//trsf_csv_f.open ("q-func-hgt-trsfs.csv");
	trsf_csv_f.open (appl_data_->q_func_hgts_csv_);
	trsf_csv_f << "grpidx_i" << "," << "grpidx_j" << "," << "i_size" << "," << "j_size" << ","
	           << "locseqidx_i" << "," << "locseqidx_j" << ","
	           << "grpid_i" << "," << "grpid_j" << "," << "seqid_i" << "," << "seqid_j" << "," << "val" << "," << "pval" << ","
	           << "dXX" << "," << "dYY" << "," << "dXY" << ","
	           << "flE"
	           << endl;


	cout << "in QFuncHgt::displayTrsfs() " << endl;

	for (int grpidx_i=0; grpidx_i< nb_groups; grpidx_i++) {
		for (int grpidx_j=0; grpidx_j< nb_groups; grpidx_j++) {

			//degugging
			if  (grpidx_i==grpidx_j) {
				//continue;
			}

			int i_size = grpidx_seqidx_[grpidx_i].size();
			int j_size = grpidx_seqidx_[grpidx_j].size();

			if (i_size == 1 || j_size == 1) {
				//continue;
			}

			for (int locseqidx_i=0; locseqidx_i< i_size; locseqidx_i++) {
				for (int locseqidx_j=0; locseqidx_j< j_size; locseqidx_j++) {

					/*
					for (int grpidx=0; grpidx< grpidx_seqidx_.size(); grpidx++) {
						for (int locseqidx=0; locseqidx< grpidx_seqidx_[grpidx].size(); locseqidx++) {

							int seqidx = grpidx_seqidx_[grpidx][locseqidx];
							//get seqname and put it
							string seqid = seqidx_seqid_[seqidx];

							cout << "grpidx: " << grpidx << " locseqidx: " << locseqidx << " seqidx: " << seqidx << " seqid: " << seqid << endl;
							//get string and put it
							string seq = string( (char*) (msa_st_.store_ + msa_st_.pos_scal(seqidx,0)),align_len);
							cout << "seq: " << seq << endl;

						}
					}
					*/

					int seqidx_i = grpidx_seqidx_[grpidx_i][locseqidx_i];
					int seqidx_j = grpidx_seqidx_[grpidx_j][locseqidx_j];

					float val;
					float pval;



					int grpid_i = grpidx_grpid_[grpidx_i];
					int grpid_j = grpidx_grpid_[grpidx_j];

					string seqid_i = seqidx_seqid_[seqidx_i];
					string seqid_j = seqidx_seqid_[seqidx_j];


					float dXX = (*ig_dist_)[grpidx_i][grpidx_i];
					float dYY = (*ig_dist_)[grpidx_j][grpidx_j];
					float dXY = (*ig_dist_)[grpidx_i][grpidx_j];

					//cout << "grpid_i: " << "," << grpid_i << " grpid_j: " << grpid_j << " val: " << val << endl;



					AlignedStorage<float>* grE = (*work_groups_)[grpidx_i][grpidx_j];
					float flE = *(grE->pointer_row(locseqidx_i) + locseqidx_j);





					if (i_size >= 2 && j_size >= 2 && grpidx_i != grpidx_j) {
						val = *(trsfs_->pointer_row(seqidx_i)+seqidx_j);
						pval = (*(pvals_->pointer_row(seqidx_i)+seqidx_j) + 1) / (nb_repl_ + 1);

					} else {
						val = 0.0;
						pval = 1.0;
					}

					//cout << "grpidx_i " << grpidx_i << "->" << grpidx_j << " i_size " << i_size << " j_size " << j_size << endl;
					//cout << "locseqidx_i: " << locseqidx_i << " locseqidx_j: " << locseqidx_j << " seqidx_i: " << seqidx_i << " seqidx_j: " << seqidx_j << endl;


					//if (val != 0) {
					trsf_csv_f << fixed << showpoint << setprecision(5)
					           << grpidx_i << "," << grpidx_j << "," << i_size << "," << j_size << ","
					           << locseqidx_i << "," << locseqidx_j << ","
					           << grpid_i << "," << grpid_j << "," << seqid_i << "," << seqid_j << "," << val << "," << pval << ","
					           << dXX << "," << dYY << "," << dXY << ","
					           << flE
					           << endl;

				}


			}

		}
	}

	trsf_csv_f.close();


}


void QFuncHgt::fileDistMatrix()
{

	cout << "in QFuncHgt::fileDistMatrix() " << endl;

	ofstream dist_mtx_f;
	//trsf_csv_f.open ("q-func-hgt-trsfs.csv");
	dist_mtx_f.open ("dist_mtx.phylip");

	dist_mtx_f << nb_seqs << endl;


	//trsf_csv_f << "grpidx_i" << "," << "grpidx_j" << "," << "i_size" << "," << "j_size" << ","
	//          << "locseqidx_i" << "," << "locseqidx_j" << ","
	//          << "grpid_i" << "," << "grpid_j" << "," << "seqid_i" << "," << "seqid_j" << "," << "val" << "," << "pval" << ","
	//          << "dXX" << "," << "dYY" << "," << "dXY" << ","
	//		   << "flE"
	//           << endl;




	for (int seqidx_i=0; seqidx_i< nb_seqs; seqidx_i++) {

		string seqid_i = seqidx_seqid_[seqidx_i];

		dist_mtx_f.setf(ios::left);
		dist_mtx_f.width(10);

		//cout << setw(10);         // does the same thing!
		dist_mtx_f << seqid_i;            // also sets left justification for cout
		dist_mtx_f << " ";

		for (int seqidx_j=0; seqidx_j< nb_seqs; seqidx_j++) {

			/*
				for (int grpidx=0; grpidx< grpidx_seqidx_.size(); grpidx++) {
					for (int locseqidx=0; locseqidx< grpidx_seqidx_[grpidx].size(); locseqidx++) {

						int seqidx = grpidx_seqidx_[grpidx][locseqidx];
						//get seqname and put it
						string seqid = seqidx_seqid_[seqidx];

						cout << "grpidx: " << grpidx << " locseqidx: " << locseqidx << " seqidx: " << seqidx << " seqid: " << seqid << endl;
						//get string and put it
						string seq = string( (char*) (msa_st_.store_ + msa_st_.pos_scal(seqidx,0)),align_len);
						cout << "seq: " << seq << endl;

					}
				}
				*/


			string seqid_j = seqidx_seqid_[seqidx_j];




			dist_mtx_f << fixed << showpoint << setprecision(5)
			           <<  (*dist_mtx_)[seqidx_i][seqidx_j]
			           << " ";

		}

		dist_mtx_f << endl;



	}
	dist_mtx_f.close();
}
