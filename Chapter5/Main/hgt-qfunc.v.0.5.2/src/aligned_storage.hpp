#ifndef ALIGNEDSTORAGE_HPP
#define ALIGNEDSTORAGE_HPP

#include <iostream>
#include <iomanip>
#include <cstdlib>

#include <boost/type_traits/is_same.hpp>

#include <x86intrin.h>
#include <pmmintrin.h> //SSE3

#include <time.h>

#include "cache_line_size.h"



//http://stackoverflow.com/questions/15430069/reduction-with-openmp-with-sse-avx
//there limits are inclusive 32 -> [32,32]
#define ROUND_DOWN(x, s) ((x) & ~((s)-1))
#define ROUND_UP(n, f) (((n + f - 1) / f) * f)




//http://stackoverflow.com/questions/3407012/c-rounding-up-to-the-nearest-multiple-of-a-number
//power of two
//return (numToRound + multiple - 1) & ~(multiple - 1);
//short sweet answer
//#define ROUND_DOWN(n, r) (n - (n % r))
//#define ROUND_UP(n,r) ((n + r) - (n % r))




inline float sum_vector4(const float a[], const size_t N)
{
	__m128 sum4 = _mm_set1_ps(0.0f);
	int i = 0;
	for(; i < ROUND_DOWN(N, 4); i+=4) {
		__m128 a4 = _mm_load_ps(a + i);
		sum4 = _mm_add_ps(sum4, a4);
	}
	__m128 t1 = _mm_hadd_ps(sum4,sum4);
	__m128 t2 = _mm_hadd_ps(t1,t1);
	float sum = _mm_cvtss_f32(t2);
	for(; i < N; i++) {
		sum += a[i];
	}
	return sum;

}

#include <stdio.h>

/*
size_t cache_line_size() {
	FILE * p = 0;
	p = fopen("/sys/devices/system/cpu/cpu0/cache/index0/coherency_line_size", "r");
	unsigned int i = 0;
	if (p) {
		fscanf(p, "%d", &i);
		fclose(p);
	}
	return i;
}
*/


using namespace std;

namespace uqam_doc
{



/*
class calc
{
public:
	int multiply(int x, int y);
	int add(int x, int y);
};
int calc::multiply(int x, int y)
{
	return x*y;
}
int calc::add(int x, int y)
{
	return x+y;
}

template <class A_Type> class calc
{
public:
	A_Type multiply(A_Type x, A_Type y);
	A_Type add(A_Type x, A_Type y);
};
template <class A_Type> A_Type calc<A_Type>::multiply(A_Type x,A_Type y)
{
	return x*y;
}
template <class A_Type> A_Type calc<A_Type>::add(A_Type x, A_Type y)
{
	return x+y;
}
*/

enum AlignUnit {
    eSIMD,
    eCACHE
};

//size_t round_up(size_t num, size_t mult) {
//	return ((num + mult - 1) / mult) * mult;
//}

template <class A_Type> class AlignedStorage
{
public:

    AlignedStorage(){};
	
	
	AlignedStorage(size_t rows, size_t cols, AlignUnit align_unit) {
	   
		cache_line_size_ = stackoverflow::cache_line_size();
		//cache_line_size_ = 64;
		align_unit_ = align_unit;
		mem_align_ = 16;
		mem_pad_ = 16;
		rows_ = rows;
		cols_ = cols;

		size_t line_bytes_init = cols * sizeof(A_Type);
		//cout << "cols: " << cols << " line_bytes_init: " << line_bytes_init << endl;

		if (align_unit == eSIMD) {
			line_bytes_ = ROUND_UP(line_bytes_init, mem_pad_);
		} else if (align_unit == eCACHE) {
			line_bytes_ = ROUND_UP(line_bytes_init, cache_line_size_);
		}

		//cout << fixed << dec << " line_bytes_:  " << dec << line_bytes_ << endl;
		//cout <<  " ROUND_DOWN: " << ROUND_DOWN(line_bytes_init, mem_pad_) << " ROUND_UP: " << ROUND_UP(line_bytes_init, mem_pad_) << endl;




		//resized line total scalar elements
		line_scal_ = line_bytes_/sizeof(A_Type);

		//line_bytes_ = cols * sizeof(A_Type) +mem_pad_;

		//line already aligned
		buff_bytes_ = line_bytes_ * rows;

		//resized line total scalar elements
		buff_scal_ = line_scal_ * rows;

	}
	
	// Copy constructor
	AlignedStorage(AlignedStorage const& m){
		/*
		cache_line_size_ = m.cache_line_size();
		align_unit_ = m.align_unit;
		mem_align_ = m.mem_align_;
		mem_pad_ = m.mem_pad_;
		rows_ = m.rows_;
		cols_ = m.cols_;

		size_t line_bytes_init = m.line_bytes_init;
		//cout << "cols: " << cols << " line_bytes_init: " << line_bytes_init << endl;

		if (align_unit == eSIMD) {
			line_bytes_ = ROUND_UP(line_bytes_init, mem_pad_);
		} else if (align_unit == eCACHE) {
			line_bytes_ = ROUND_UP(line_bytes_init, cache_line_size_);
		}

		//cout << fixed << dec << " line_bytes_:  " << dec << line_bytes_ << endl;
		//cout <<  " ROUND_DOWN: " << ROUND_DOWN(line_bytes_init, mem_pad_) << " ROUND_UP: " << ROUND_UP(line_bytes_init, mem_pad_) << endl;




		//resized line total scalar elements
		line_scal_ = line_bytes_/sizeof(A_Type);

		//line_bytes_ = cols * sizeof(A_Type) +mem_pad_;

		//line already aligned
		buff_bytes_ = line_bytes_ * rows;

		//resized line total scalar elements
		buff_scal_ = line_scal_ * rows;
	  	*/
	}   
	
	// Assignment operator
	// byte copy storage
	AlignedStorage& operator= (AlignedStorage const& m) {
		memcpy ( store_, m.store_, buff_bytes_ );
		return *this;
	}
	
	~AlignedStorage() {
		dealloc();
	}

	size_t pos_scal(size_t row, size_t col) {
		return line_scal_ * row + col;
	}

	size_t pos_byte(size_t row, size_t col) {
		return line_bytes_ * row + col;
	}
	
	A_Type* pointer_row(size_t row) {
		//A_Type* new_;
		
		return store_ +  line_scal_ * row;
	}
	
	

	void info() {
		cout << "line_scal_: " << line_scal_ << " buff_scal_:: " << buff_scal_ << endl;
		cout << "sizeof(" << "A_Type" << "): " << sizeof(A_Type) << endl;
	}

	void print_buff_scal() {
		for (size_t pos = 0; pos <buff_scal_; pos++) {
			//
			if ( pos % line_scal_ == 0) {
				cout << dec <<(pos / line_scal_) << "-";
			}

			//printf("%x ", *(p_fl4 +pos));
			bool isFloat = boost::is_same<A_Type, float>::value;

			if (isFloat) {
				cout << fixed << showpoint << setprecision(2);
				cout << *(store_ + pos) << " ";
			}

			bool isChar = boost::is_same<A_Type, char>::value;
			if (isChar) {
				//hex
				//int value = *(store_ + pos);
				//cout << fixed << hex << value << " ";

				//char
				A_Type value = *(store_ + pos);
				cout << fixed << value << " ";
			}

			if ( (pos+1) % line_scal_ == 0) {
				cout << "\n ";
			}
		}

	}

	void  strcpy_row (char* src, size_t row) {
		//copy to column 0;
		strncpy((store_ + pos_byte(row, 0)), src, cols_);
	}



	//storage pointer
	A_Type* store_;
	//allocate new pointer


    void alloc_align_internal() {
		A_Type* new_;
		posix_memalign((void**) &new_, mem_align_, buff_bytes_);
		store_ =  new_;
		
	}


	A_Type* alloc_align() {
		A_Type* new_;
		posix_memalign((void**) &new_, mem_align_, buff_bytes_);
		return new_;
	}

	void assign(A_Type* store) {
		store_ = store;
	}

	void dealloc() {
		//cout << "dealloc called for : " << store_ << endl;
		delete store_;
	}


	void init_pad(A_Type initVal,A_Type padVal) {
		//inside group matrix
		//same ii but past j_size index until end of line
		for (size_t ii=0; ii<rows_; ii++) {
			for (size_t jj=0; jj< line_scal_; jj++) {
				//inside aligned storage offset calculation
				size_t pos = line_scal_ * ii + jj;
				if (jj<cols_) {
				*(store_ + pos) = initVal;					
				} else {
				*(store_ + pos) = padVal;					
				}
					

			}
		}
		//fill with \0
		//memset(seq_ptr+ align_len, 0, (1 +MEM_PAD) );

	}




	size_t cache_line_size_;
	AlignUnit align_unit_;
	size_t mem_align_;
	size_t mem_pad_;
	size_t rows_;
	size_t cols_;
	size_t line_bytes_;
	size_t buff_bytes_;
	size_t line_scal_;
	size_t buff_scal_;


};

}

#endif // ALIGNEDSTORAGEFLOAT_HPP
