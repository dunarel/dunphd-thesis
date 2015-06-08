/*
 * File:   q_func_calc.h
 * Author: Dunarel Badescu
 *
 */

#ifndef _Q_FUNC_HGT_H
#define	_Q_FUNC_HGT_H

#include <string>
#include <map>
//#include <ext/hash_map>
#include <vector>
#include <set>

//#include "distance_measures.h"
//#include "win_q.h"
#include <boost/interprocess/containers/flat_map.hpp>
#include <boost/multi_array.hpp>
#include "boost/random.hpp"

#include "application_data.hpp"
#include "aligned_storage.hpp"

using namespace std;
using namespace uqam_doc;
using namespace boost;

// see http://www.cplusplus.com/forum/general/69135/
//using namespace boost::numeric::ublas;
//typedef vector<double>* p_vec;
//typedef AlignedStorage<float>* p_work_gr;

//typedef multi_array<p_float, 2> array_type2d;
//typedef multi_array<AlignedStorage<float>*, 2> array_type2d;
//typedef array_type2d::index index2;

// this is a functor
struct rand_float {
  rand_float(float x) : x(x) {}
  float operator()(float y) { return x + y; }

private:
  float x;
};

struct rand_int {
  //initializer
  rand_int(int init, int max_val) : x(max_val),
                    rng(boost::mt19937(init)),
				    uniform_normal(boost::uniform_int<int>(0,max_val-1)),
                    rand_normal(boost::variate_generator<boost::mt19937, boost::uniform_int<int> >(rng,uniform_normal)) { }
  
  //int operator()(int y) { 
	  //return rand_normal(); 
  //	  return 1; 
  //}

  int operator()() { 
	  return rand_normal(); 
    }
	
  int next() {
	  return rand_normal();
  }
  
private:
  //max length
  int x;
  boost::mt19937 rng;
  boost::uniform_int<int> uniform_normal;
  boost::variate_generator<boost::mt19937, boost::uniform_int<int> > rand_normal;

  
};



namespace uqam_doc
{

//typedef map< string, float > Dist1D;

//typedef map< string, map< string, string > >  data;
//data[ "hey" ][ "yo" ] = "whassup";

//typedef vector<int> Int1D;
//typedef std::vector<Int1D> Int2D;

class QFuncHgt
{
public:

	//aplication data
	ApplicationData* appl_data_;

	//configurations should be made elswere
	//int MEM_ALIGN = 16;
	//int MEM_PAD = 16;
	//int CACHE_LINE = 64;

	//members
	size_t align_len;
	float align_len_reciprocal;
	
	int nb_mutations;
	int nb_repl_;
	
	
	int nb_seqs;
	int nb_groups;
	
	//column number generator
	// Initialise Boost random numbers, uniform integers from min to max
	
	//groups to sequences in global space
	//internal vector order by locseqidx
	vector< vector<int> > grpidx_seqidx_;
	//groups and info
	vector<int> grpidx_grpid_;

	//like AssocVector
	container::flat_map<string,int> seqid_seqidx_;

	//ordered by seqidx
	//search it for msa layout
	vector<string> seqidx_seqid_;


	////read only - no false sharing
	AlignedStorage<char>* msa_st_;
		
	//replicate MSA
    AlignedStorage<char>* msa_rp_;


    //Grouped Work Dist Matrix
	//array_type2d* pcell_2d;
	multi_array<AlignedStorage<float>*, 2>* work_groups_;
    //linear distance matrix
	multi_array<float, 2>* dist_mtx_;
 
	
	//Group (REST) values
	//array_type2d* rest_groups_;
	multi_array<AlignedStorage<float>*, 2>* rest_groups_;
	
	//inter/intra group average distance
	//simple implementation
	multi_array<float, 2>* ig_dist_;
	
	//TRSF flat aligned array of nb_seqs x nb_seqs
	AlignedStorage<float>* trsfs_;
	
	//Replicate transfers
	AlignedStorage<float>* repls_;
	
	//PVALS
	AlignedStorage<float>* pvals_;
	
	//
	rand_int* align_rand_int_;
	

	//default destructor

	virtual ~QFuncHgt();

	//custom constructors
	QFuncHgt(ApplicationData* appl_data);

	//methods
	
	void allocBuffers();
	
	void initBuffers();
	
	void deallocBuffers();
	
	void readGrSeqsCsv();

	void readMsaFasta();

	void calcWorkDistMatrix(AlignedStorage<char>* msa_st,
             multi_array<AlignedStorage<float>*, 2>* work_groups,
             multi_array<AlignedStorage<float>*, 2>* rest_groups);
			 
	
	void calcTrsfs(multi_array<AlignedStorage<float>*, 2>* work_groups,
	               multi_array<AlignedStorage<float>*, 2>* rest_groups,
						AlignedStorage<float>* trsfs);
	
	void calcScore();
	
	void calcRepl();
	
	
	void mutateMsa();
	
	void calcVals();
	
	void calcPvals();
	
	void calcHgts();
	
	void calculate();

	void displayData();

	void displayMsaData(AlignedStorage<char>* msa);

	void displayWorkDistMatrix(multi_array<AlignedStorage<float>*, 2>* work_groups, int rowGroup, int colGroup);
	
	void displayRestVector(multi_array<AlignedStorage<float>*, 2>* rest_groups,int rowGroup, int colGroup);

    void displayTrsfs(AlignedStorage<float>* trsfs);
	
	void fileTrsfs();
	
	void fileDistMatrix();
	
	

	//members


private:
};





}


#endif	/* _Q_FUNC_HGT_H */
