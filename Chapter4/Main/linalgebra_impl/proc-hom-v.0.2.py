#!/usr/bin/env python

# -*- coding: utf-8 -*-

"""
Created on Sun Sep 21 12:37:33 2014

@author: Dunarel Badescu
"""

import csv
import numpy as np

    
from numpy import array, dot
from scipy import sparse

#

#PG,PROK_GROUP_ID,NAME
la_prok_groups= np.genfromtxt("files2/la_prok_groups.csv", dtype="i8,i8,|S35",  delimiter=',', names=True) 
prok_groups =  la_prok_groups['PG']
print "prok_groups.size: ",prok_groups.size

#SP,TAXON_ID,TREE_NAME,SCI_NAME
la_species= np.genfromtxt("files2/la_species.csv", dtype="i8,i8,|S35,|S35",  delimiter=',', names=True) 
species =  la_species['SP']
print "species.size: ",species.size


#AL,NCBI_SEQ_ID,VERS_ACCESS
la_alleles= np.genfromtxt("files2/la_alleles.csv", dtype="i8,i8,|S35",  delimiter=',', names=True) 

alleles =  la_alleles['AL']

print "alleles.size: ",alleles.size

#print data['NCBI_SEQ_ID']
#print data['VERS_ACCESS'][0]


#GN,GENE_ID,NAME
la_genes= np.genfromtxt("files2/la_genes.csv", dtype="i8,i8,|S35",  delimiter=',', names=True) 
genes =  la_genes['GN']

print "genes.size: ",genes.size

#AL,GN,GENE_ID,NCBI_SEQ_ID
la_alleles_genes = np.genfromtxt("files2/la_alleles_genes.csv", dtype="i8,i8,i8,i8",  delimiter=',', names=True) 

L = sparse.csr_matrix((alleles.size,genes.size), dtype="f8")

for row in la_alleles_genes:
    al = row[0]
    gn = row[1]
    #print "sp, al: ",sp,al
    L[al,gn]=1.0

#AL,SP,NCBI_SEQ_ID,VERS_ACCESS
la_alleles_species = np.genfromtxt("files2/la_alleles_species.csv", dtype="i8,i8,i8,|S35",  delimiter=',', names=True) 

Z = sparse.csr_matrix((species.size,alleles.size), dtype="f8")
print Z[1,1]

for row in la_alleles_species:
    sp = row[1]
    al = row[0]
    #print "sp, al: ",sp,al
    Z[sp,al]=1.0

#print "Z: ",Z

#SP,PG,PROK_GROUP_ID,WEIGHT_PG,TAXON_ID
la_species_prok_groups = np.genfromtxt("files2/la_species_prok_groups.csv", dtype="i8,i8,i8,f8,i8",  delimiter=',', names=True) 

W = sparse.csr_matrix((prok_groups.size,species.size), dtype="f8")
#print Z[1,1]

for row in la_species_prok_groups:
    sp = row[0]    
    pg = row[1]
    wt = row[3]
    #print "pg, sp, wt: ",pg,sp,wt
    W[pg,sp]=wt
    
    
#print "W: ",W

#PxG
PG = W.dot(Z).dot(L)

for i in range(0,prok_groups.size):
    pgsn = PG.sum(axis=1)[i]
    #print "i,pgsn: ",i,pgsn
    
#GN,ALS,ALD,WEIGHT,FRAGM_ID,GENE_ID,SOURCE_ID,DEST_ID
la_transfers = np.genfromtxt("files2/la_transfers.csv", dtype="i8,i8,i8,f8,i8,i8,i8,i8",  delimiter=',', names=True) 

#R dense numpy 3d matrix gene x proc x proc
R = np.zeros((genes.size,prok_groups.size,prok_groups.size), dtype="f8")

# dictionnary of sparse matrices
KK=[]
for i in range(0, genes.size):
    #print "We're on time %d" % (i)
    KK.append(sparse.csr_matrix((alleles.size,alleles.size), dtype="f8"))
    
#process transfers into KK
for row in la_transfers:
    gn = row[0]
    als = row[1]
    ald = row[2]
    wt = row[3]
    #print "sp, al: ",sp,al
    KK[gn][als,ald]+=wt

#collect results in R
for i in range(0, genes.size):
    #R.append(W.dot(Z).dot(KK[i]).dot(Z.T).dot(W.T))
    R[i] = W.dot(Z).dot(KK[i]).dot(Z.T).dot(W.T).todense()
    
    #rshape = R.shape
    #print rshape[0],rshape[1]
#print "R: ",R,R.__len__()

def k_div_nm(psrc, pdst):
    
    cor_perc = 100.0
    
    absol = 0.0
    rel = 0.0
    nb_genes = 0.0

    abs_sum = 0.0
    rel_sum = 0.0


    for gn in range(0, genes.size):
        #R.append(W.dot(Z).dot(KK[i]).dot(Z.T).dot(W.T))
        #init case values
        #val_elem = 0.0
        #value for gene
        vfg = R[gn][psrc, pdst]
        #size of gene source
        sgs = PG[psrc,gn]
        #size of gene dest
        sgd = PG[pdst,gn]
        den = (sgs*(sgd-1))/2 if (psrc == pdst) else (sgs * sgd)
  
  
        if den != 0:
            nb_genes +=1 
            #local variables
            abs_elem =  vfg
            rel_elem = (vfg / den)
            #cummulative
            abs_sum += abs_elem 
            rel_sum += rel_elem

    #normalization
    absol = abs_sum
    if nb_genes != 0:
        rel = (rel_sum * cor_perc ) /  nb_genes 
    
    
    return [absol, rel, nb_genes]


#
abso = np.zeros((prok_groups.size,prok_groups.size), dtype="f8")
rel =  np.zeros((prok_groups.size,prok_groups.size), dtype="f8")
ngenes =  np.zeros((prok_groups.size,prok_groups.size), dtype="f8")
#
for psrc in range (0,prok_groups.size):
    for pdst in range (0,prok_groups.size):
        abso[psrc,pdst], rel[psrc,pdst], ngenes[psrc,pdst] = k_div_nm(psrc, pdst)
        #pass

#print "abso",abso
#np.savetxt('exports/abso.csv', abso, delimiter=',', fmt='%20.10f')   # use exponential notation
#np.savetxt('exports/rel.csv', rel, delimiter=',', fmt='%20.10f')   # use exponential notation
#np.savetxt('exports/ngenes.csv', ngenes, delimiter=',', fmt='%20.10f')   # use exponential notation        
        
tt_xsums = np.zeros((prok_groups.size), dtype="f8")
 
def calc_transf_gr_total_one_dim():
    tt_xsums = []
    #row by row
    for s in range(0,prok_groups.size):
         
      row_abs = abso[s,]
      row_gn  = ngenes[s,]
      #print "row_abs: ",row_abs
      
      row_sum = 0.0
      #for d in range(0,prok_groups.size):
      #    row_sum += row_abs[d]
      
      pgsn = PG.sum(axis=1)[s]
      print np.squeeze(pgsn).shape
      row_tt = row_sum / pgsn * 100 / 1.1 #correct to 110 genes
      print np.squeeze(row_tt).shape
      print "row_tt: ", row_tt,row_tt.shape
    
#calc_transf_gr_total_one_dim()
PGSN = PG.sum(axis=1).T
#WTS = abso.sum(axis=0) / PGSN * 100 / 1.1
#WTD = abso.sum(axis=1) / PGSN * 100 / 1.1

WTS = abso.sum(axis=0) / PGSN * 100 
WTD = abso.sum(axis=1) / PGSN * 100 


PGSN = PGSN.A1
WTS = WTS.A1
WTD = WTD.A1


MEAN_HGT_SRC = (WTS*PGSN).sum()/PGSN.sum()
MEAN_HGT_DST = (WTD*PGSN).sum()/PGSN.sum()

print "MEAN_HGT_SRC: ", MEAN_HGT_SRC
print "MEAN_HGT_DST: ", MEAN_HGT_DST


