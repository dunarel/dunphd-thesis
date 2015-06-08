
select distinct hcif.GENE_ID,
               gn.name,
               gbr.BLOCKS_LENGTH  as align_len
        from HGT_COM_INT_FRAGMS hcif
         join GENES gn on hcif.GENE_ID = gn.ID
         join GENE_BLO_RUNS gbr on gbr.GENE_ID = hcif.GENE_ID
         