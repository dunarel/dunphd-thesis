select count(*)
from
(
select  ht.GENE_ID,
              tg_src.PROK_GROUP_ID,
              tg_dest.PROK_GROUP_ID,
              count(*) as weight
      from Recomb_TRANSFERS ht
        join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
      group by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               ht.GENE_ID
      order by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               ht.GENE_ID
)               


select  ht.GENE_ID,
              tg_src.PROK_GROUP_ID as source_id,
              tg_dest.PROK_GROUP_ID as dest_id,
              count(*) as weight
      from Recomb_TRANSFERS ht
        join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
      group by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               ht.GENE_ID
      having count(*) >= 3
      order by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               ht.GENE_ID



  select count(*)
  from RECOMB_TRANSFERS
  where confidence= 0


update RECOMB_TRANSFER_GROUPS rtg
set rtg.cnt = select count(*)
        from Recomb_TRANSFERS ht
         join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
         join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
         join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
         join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
        where  tg_src.PROK_GROUP_ID = rtg.prok_group_source_id and
               tg_dest.PROK_GROUP_ID = rtg.prok_group_dest_id
        group by tg_src.PROK_GROUP_ID,
                 tg_dest.PROK_GROUP_ID

select *
from RECOMB_TRANSFER_GROUPS
where id = 9308                


  select count(distinct gene_id)
  from hgt_par_fragms

  select *
  from gene_blo_seqs
  where gene_id = 110

select gbs.NCBI_SEQ_ID --gbs.GENE_ID,ns.TAXON_ID  --,count(*)
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
where gbs.gene_id = 152 and
      ns.TAXON_ID = 288681
--group by gbs.GENE_ID,ns.TAXON_ID
--having count(*) >10
--order by gene_id,taxon_id



select ns
from NCBI_SEQS ns
  