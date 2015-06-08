

select sum(weight)
from HGT_PAR_TRANSFERS hpt

select count(*)
from HGT_PAR_CONTINS hpc

where hpc.BS_VAL >= 50

select *
from HGT_PAR_FRAGMS hpf

select hpc.id,
       hpc.BS_VAL,
       hpc.BS_DIRECT > hpc.BS_INVERSE as normal_order,
       sum (hpf.FROM_CNT * hpf.TO_CNT) as comb_nb
from hgt_par_contins hpc
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.id
where hpf.BS_VAL >= 50
group by hpc.id
order by hpc.id 

where gene_id = 110


select *
from GENE_GROUP_CNTS ggc
where ggc.PROK_GROUP_ID = 4


select sum(hptp.WEIGHT_TR_PG)
from HGT_PAR_TRSF_PRKGRS hptp 
where hptp.PGSRC_ID between 0 and 22 and
      hptp.PGDST_ID between 0 and 22



select *
from HGT_PAR_TRSF_TAXONS hptt
where 

select *
from HGT_PAR_TRSF_PRKGRS hptp 
 join HGT_PAR_TRSF_TAXONS hptt on hptt.ID = hptp.TRSF_TAXON_ID
where hptp.PGDST_ID = 18


select *
from HGT_PAR_TRANSFERS hpt
where hpt.NCBI_SEQ_DEST_ID = 



select hpf.gene_id,
       ns_src.TAXON_ID,
       ns_dest.TAXON_ID,
       sum(ht.WEIGHT)       
     from HGT_PAR_TRANSFERS ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
     where ns_dest.TAXON_ID = 374847
     group by hpf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID
     order by hpf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID

select hpf.*,
       ns_src.TAXON_ID,
       ns_dest.TAXON_ID
     from HGT_PAR_TRANSFERS ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
     where ns_dest.TAXON_ID = 374847
     order by hpf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID              

--question vladimir
--
select tr.gene_id,
       tr.fen_no,
       count(tr.hgt_par_contin_id) as nb_contins
from (select hpf.*,
       ns_src.TAXON_ID,
       ns_dest.TAXON_ID
     from HGT_PAR_TRANSFERS ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
     where ns_dest.TAXON_ID = 374847
     order by hpf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID
) tr
group by tr.gene_id,
         tr.fen_no
order by tr.gene_id,
         tr.fen_no

--question vladimir 2
select hpf2.gene_id,
       hpf2.WIN_SIZE,
       hpf2.FEN_NO,
       hpf2.HGT_TYPE,
       hpf2.FROM_SUBTREE,
       hpf2.TO_SUBTREE
from HGT_PAR_FRAGMS hpf2
where hpf2.ID in 
(select ht.HGT_PAR_FRAGM_ID
     from HGT_PAR_TRANSFERS ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
     where ns_dest.TAXON_ID = 374847)
order by hpf2.gene_id,
       hpf2.WIN_SIZE,
       hpf2.FEN_NO,
       hpf2.HGT_TYPE,
       hpf2.FROM_SUBTREE,
       hpf2.TO_SUBTREE,
       hpf2.BS_VAL,
       hpf2.BS_DIRECT,
       hpf2.BS_INVERSE     







select ns.ID,
       ns.VERS_ACCESS,
       ns.TAXON_ID as txid
from ncbi_seqs ns
where ns.TAXON_ID = 374847

select hpggv.*
from HGT_PAR_GENE_GROUPS_VALS hpggv
where hpggv.PROK_GROUP_DEST_ID = 18


select distinct gene_id
from HGT_PAR_TRSF_PRKGRS hptp 
where hptp.PGDST_ID = 18


select *
from HGT_PAR_TRANSFERS hpt


select *
from GENE_GROUP_CNTS ggc
where ggc.PROK_GROUP_ID = 18

update HGT_PAR_TRANSFER_GROUPS hptg
set cnt=0,
    cnt_rel = 0


select *
from gene_blo_seqs
where gene_id = 172

--
select gbs.GENE_ID,
             tg.PROK_GROUP_ID,
             pg.NAME,
             sum(tg.weight_pg) as CNT
      from GENE_BLO_SEQS gbs
       join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
       join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
       join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
      group by gbs.GENE_ID,
               tg.PROK_GROUP_ID,
               pg.NAME
      order by gbs.GENE_ID,
               tg.PROK_GROUP_ID

