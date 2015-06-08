/* 
 * File:   ApplicationData.cpp
 * Author: root
 * 
 * Created on January 14, 2010, 4:43 PM
 */

#include "application_data.h"



#include <stdexcept>

#include <string>
#include <iostream>
#include <algorithm>
#include <tclap/CmdLine.h>


//for random seed
#include <ctime>


using namespace std;
using namespace uqam_doc;
using uqam_doc::ApplicationData;
using namespace TCLAP;

ApplicationData::ApplicationData() {
}

ApplicationData::~ApplicationData() {

    //activate random number generator
    //for repeatable per application numbers
	//random_number_gen_ = boost::mt19937();

	//for completely different values
    random_number_gen_ = boost::mt19937(time(0));

}

/*
 * //http://www.hackorama.com/anyoption/
 */
void ApplicationData::process_cmd_line(int argc, char** argv) {


    // Wrap everything in a try block.  Do this every time,
    // because exceptions will be thrown for problems.
    try {

        // Define the command line object, and insert a message
        // that describes the program. The "Command description message"
        // is printed last in the help text. The second argument is the
        // delimiter (usually space) and the last one is the version number.
        // The CmdLine object parses the argv array based on the Arg objects
        // that it contains.
        CmdLine cmd("Q Functions calculation., UQAM, 2010", ' ', "0.9");



        /**
         * \param flag - The one character flag that identifies this
         * argument on the command line.
         * \param name - A one word name for the argument.  Can be
         * used as a long flag on the command line.
         * \param desc - A description of what the argument is for or
         * does.
         * \param req - Whether the argument is required on the command
         * line.
         * \param value - The default value assigned to this argument if it
         * is not present on the command line.
         * \param typeDesc - A short, human readable description of the
         * type that this object expects.  This is used in the generation
         * of the USAGE statement.  The goal is to be helpful to the end user
         * of the program.
         * \param parser - A CmdLine parser object to add this Arg to
         * \param v - An optional visitor.  You probably should not
         * use this unless you have a very good reason.
         */
        ValueArg<string> msa_fastaArg("", "msa_fasta", "Multiple sequence alignment", true, "msa_fasta.fa", "Input MSA Fasta file", cmd);
        ValueArg<string> q_func_csvArg("", "q_func_csv", "Output CSV results file", true, "results.csv.fa", "Output CSV results file", cmd);
        ValueArg<string> x_ident_csvArg("", "x_ident_csv", "X set CSV input file", true, "x_ident.csv", "X set CSV input file", cmd);
        //this file is used in recursive algoritms implementations using R-language
        //by default you don't bother
        ValueArg<string> ids_work_csvArg("", "ids_work_csv", "Filter on active identifiers", false, "", "Filter on active identifiers", cmd);


        ValueArg<string> a_group_csvArg("", "a_group_csv", "A set CSV output file", false, "a_group.csv", "A set CSV output file", cmd);
        ValueArg<string> b_group_csvArg("", "b_group_csv", "B set CSV output file", false, "b_group.csv", "B set CSV output file", cmd);

        ValueArg<string> align_typeArg("", "align_type", "Align type option ", true, "dna", "Options are : dna,protein", cmd);
        ValueArg<string> distArg("", "dist", "Distance function option ", true, "ham", "Options are : ham, kprot, scoredist", cmd);
        ValueArg<string> protmatrixArg("", "protmatrix", "Protein matrix option ", false, "blosum80", "Options are : blosum80,blosum62", cmd);
        ValueArg<string> pvalArg("", "pval", "P-values option ", false, "no", "Options are : no, repl, perm", cmd);
        ValueArg<int> winlArg("", "winl", "Window length option ", true, 20, "Options are : integer 0 to MSA length", cmd);

        ValueArg<int> f_opt_maxArg("", "f_opt_max", "Function to optimize option ", true, 4, "Options are 0-5", cmd);
        ValueArg<int> win_stepArg("", "win_step", "Window advancing step ", true, 1, "Options are 1-MSA length", cmd);
        ValueArg<string> calc_typeArg("", "calc_type", "Calculation type ", true, "simple", "Options are: auto,simple,single", cmd);
        ValueArg<string> optimArg("", "optim", "Partition optimization algorithm ", true, "km", "Options are: nj,km", cmd);






        // Define a switch and add it to the command line.
        // A switch arg is a boolean argument and only defines a flag that
        // indicates true or false.  In this example the SwitchArg adds itself
        // to the CmdLine object as part of the constructor.  This eliminates
        // the need to call the cmd.add() method.  All args have support in
        // their constructors to add themselves directly to the CmdLine object.
        // It doesn't matter which idiom you choose, they accomplish the same thing.

        //SwitchArg reverseSwitch("r","reverse","Print name backwards", cmd, false);

        // Parse the argv array.
        cmd.parse(argc, argv);

        //bool reverseName = reverseSwitch.getValue();

                //WORKOUT

         msa_fasta_ = msa_fastaArg.getValue();
        cout << "msa_fasta = " << msa_fasta_ << endl;

        ids_work_csv_ = ids_work_csvArg.getValue();
        cout << "ids_work_csv = " << ids_work_csv_ << endl;

        x_ident_csv_ = x_ident_csvArg.getValue();
        cout << "x_ident_csv = " << x_ident_csv_ << endl;

        a_group_csv_ = a_group_csvArg.getValue();
        cout << "a_group_csv = " << a_group_csv_ << endl;

        b_group_csv_ = b_group_csvArg.getValue();
        cout << "b_group_csv = " << b_group_csv_ << endl;


        q_func_csv_ = q_func_csvArg.getValue();
        cout << "q_func_csv = " << q_func_csv_ << endl;


        align_type_ = align_typeArg.getValue();
        cout << "align_type = " << align_type_ << endl;

     

        if (align_type_ == "dna") {
            dist_ = eHAM;
        } else if (align_type_ == "prot") {
            dist_ = eKIM_PROT;
        }

        string dist = distArg.getValue();
        cout << "dist >" << dist << "<" << endl;

        if (dist == "ham") {
            cout << "dist = " << "Hamming" << endl;
            dist_ = eHAM;

        } else if (dist == "jknucl") {
            dist_ = eJUKES_CANTOR_NUCL;
            cout << "dist = " << "Jukes Cantor Nucl" << endl;

        } else if (dist == "kimprot") {
            cout << "dist = " << "Kimura Protein" << endl;
            dist_ = eKIM_PROT;
        } else if (dist == "scoredist") {
            cout << "dist = " << "Scoredist" << endl;
            dist_ = eSCOREDIST;
        } else {
            cout << "dist = " << ">" << dist_ << "<" << endl;
        }



        string protmatrix = protmatrixArg.getValue();
        cout << "protmatrix >" << protmatrix << "<" << endl;


        if (protmatrix == "blosum80") {
            cout << "protmatrix = " << "Blosum80" << endl;
            protmatrix_ = eBLOSUM80;

        } else if (protmatrix == "blosum62") {
            cout << "protmatrix = " << "Blosum62" << endl;
            protmatrix_ = eBLOSUM62;

        } else {

            cout << "default protmatrix to : " << "Blosum62" << endl;
            protmatrix_ = eBLOSUM62;
        }



        win_l_ = winlArg.getValue();
        cout << "win_l >" << win_l_ << "<" << endl;

        pval_ = pvalArg.getValue();
        cout << "pval >" << pval_ << "<" << endl;


        q_func_opt_max_idx_ = f_opt_maxArg.getValue();
        cout << "q_func_opt_max_idx_ = " << q_func_opt_max_idx_ << endl;



        win_step_ = win_stepArg.getValue();
        cout << "win_step = " << win_step_ << endl;

        string calc_type = calc_typeArg.getValue();
        cout << "calc_type => " << "[" << calc_type << "]" << endl;

        if (calc_type == "simple") {
            calc_type_ = eSimple;
        } else if (calc_type == "auto") {
            calc_type_ = eAuto;
        } else if (calc_type == "single") {
            calc_type_ = eSingle;
        } else {
            calc_type_ = eSimple;
        }

     string optim = optimArg.getValue();
    cout << "optim => " << "[" << optim << "]" << endl;

    //defaults to kmeans optimization
    if (optim == "nj") {
        optim_type_ = eNj;
    } else if (optim == "km") {
        optim_type_ = eKm;
    } else {
        optim_type_ = eKm;
    }



    } catch (TCLAP::ArgException &e) // catch any exceptions
    {
        std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
    }

    
}





