 
5) Later, we were able to simplify the aggregating step, from our original Relational Algebra solution, transforming it to a Linear Algebra one. We implemented this solution only for the Complete Horizontal Gene Transfer, given in the folder chap4-linalgebra_impl.

It contains one R script for extracting the initial data from the database: 
proc-hom-v.0.2.R

Another Python script exemplify the whole approach:
proc-hom-v.0.2.py
The final value is the one from Table 4.1a. Mean HGT rates Complete HGT 75% bootstrap.

chap4-linalgebra_impl/files2 contains the data files.
chap4-linalgebra_impl/sql contains some sql queries transitively used to query the database.

We also provide another script file, able to also directly work with the core genes:
chap4-linalgebra_impl/core-files.R

