/* 
 * File:   parsers.h
 * Author: root
 *
 * Created on January 18, 2010, 5:31 PM
 */

#ifndef _PARSERS_H
#define	_PARSERS_H

#include <string>
#include <set>

using namespace std;

namespace uqam_doc {

   class Parsers {
    public:
        //constructors
        Parsers();
        virtual ~Parsers();

        //functions

        static void readSet(set<string>& st, string filename);
        static string genRandDnaSeq(int len);

    };






    
}



#endif	/* _PARSERS_H */

