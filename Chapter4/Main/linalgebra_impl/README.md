### HGT-QFCLUST v.0.2

This software implements the HGT custom weighted clustering described in:

##### CHAPTER IV of Dunarel Badescu Ph.D. Thesis - UQAM 
##### Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution


###### Copyright (C) 2015 Dunarel Badescu, Abdoulaye Banire Diallo and Vladimir Makarenkov

### Licence 
   This software is distributed according to the BSD license (3-clause version).

   Our most recent implementation is available at the following URL address:
   http://www.info2.uqam.ca/~makarenkov_v/HgtQClust.zip.

### Authors pages:
  * Dunarel Badescu:         https://ca.linkedin.com/pub/dunarel-badescu/26/107/887
  * Vladimir Makarenkov:     http://accueil.labunix.uqam.ca/~makarenkov_v
  * Abdoulaye Banire Diallo: http://ancestors.bioinfo.uqam.ca/BioinfoLab/index.php
  
### Requirements
   * Python 2.7, numpy and scipy numerical calculation packages

 
### HGT-QFCLUST contents:

  * README  - This file 
  * [license](license) - Full text of the BSD license (3-clause)
  
  * [proc-hom-v.0.2.R](proc-hom-v.0.2.R) - R script for extracting the initial data from the database.
  * [proc-hom-v.0.2.py](proc-hom-v.0.2.py) - Main program  
  * [files2](files2) - Input data files
  * [sql](sql) - Helper SQL snippets 
  * [core-files.R](core-files.R) - R script used to work with the core genes
  * []() - 
  * []() - 
      
 
### Example Usage:

  We exemplify the Complete HGT case, using Ecological Habitats.
  The Input files are extracted from the transfer database using proc-hom-v.0.2.R.
  
  Please note that decomposition of transfers was already performed in a previous database step.
  See section 4.3.3. Computation of HGT statistics, and Figure 1 for decomposition details.
  
  la_transfers.csv contains these fragments having the following structure:
  GN: gene,
  ALS: allele source,
  ALD: allele destination,
  WEIGHT: fragment weight,
  FRAGM_ID: fragment id,
  GENE_ID: gene id,
  SOURCE_ID: source id (ncbi gi),
  DEST_ID: destination id (ncbi gi)
  
  
  Then they are loaded into an numpy array or a scipy sparse matrix.
  
  See APPENDIX B for all clustering details including aggregation and weighting details.
  
  The final value is the one from Table 4.1a. Mean HGT rates Complete HGT 75% bootstrap.
  
  Matrices could be easily exported to csv if need be.
  Example code is commented for this purpose.
  

### Feedback and bug reports:
   Feedback is welcomed: dunarel(at)gmail(dot)com.

