/* 
 * File:   QFuncHgtAppl.hpp
 * Author: Dunarel Badescu
 *
 */

#ifndef _QFUNCHGTAPPL_H
#define	_QFUNCHGTAPPL_H

#include "application_data.hpp"
#include "q_func_hgt.hpp"

namespace uqam_doc {

    class QFuncHgtAppl {
    public:
        QFuncHgtAppl();

        //custom constructor
        QFuncHgtAppl(int argc, char** argv);

        //QFuncHgtAppl(const QFuncHgtAppl& orig);
        virtual ~QFuncHgtAppl();

        //main procedure
        void run();

        ApplicationData* appl_data_;
        QFuncHgt* q_func_hgt;



    private:

    };

}

#endif	/* _QFUNCHGTAPPL_H */

