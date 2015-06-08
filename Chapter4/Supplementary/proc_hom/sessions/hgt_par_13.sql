select gbs.GENE_ID,
       g.NAME,
       count(gbs.NCBI_SEQ_ID)
from GENE_BLO_SEQS gbs
 join genes g on g.ID = gbs.GENE_ID
group by gbs.GENE_ID,
       g.NAME


select tg.PROK_GROUP_ID,
       pg.NAME,
       count(*) as cnt
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.ID = ns.TAXON_ID
 join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
 group by tg.PROK_GROUP_ID,
          pg.NAME
order by tg.PROK_GROUP_ID


--size_of_gene
create table hgt_par_gene_group_cnt (
gene_id integer,
prok_group_id integer,
name varchar(255),
cnt integer)

insert into hgt_par_gene_group_cnts
(gene_id,PROK_GROUP_ID,name,cnt)
select gbs.GENE_ID,
         tg.PROK_GROUP_ID,
         pg.NAME,
         count(*) as CNT
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.ID = ns.TAXON_ID
 join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
group by gbs.GENE_ID,
         tg.PROK_GROUP_ID,
         pg.NAME
order by gbs.GENE_ID,
         tg.PROK_GROUP_ID

)
       
select *
from HGT_PAR_TRANSFERS

create table  hgt_par_gene_group_val (
gene_id integer,
source_id integer,
dest_id integer,
val float)

delete from HGT_PAR_GENE_GROUP_VAL

create index hpt_source_id_idx on HGT_PAR_TRANSFERS(source_id);

create index hpt_dest_id_idx on HGT_PAR_TRANSFERS(dest_id);

--val_for_gene
insert into hgt_par_gene_group_val 
(gene_id,source_id,dest_id,val)
select hpf.GENE_ID,
       tg_src.PROK_GROUP_ID,
       tg_dest.PROK_GROUP_ID,
       sum(ht.weight) as weight
from hgt_par_transfers ht
 join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
 join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
 join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID
 join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
 join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
group by tg_src.PROK_GROUP_ID,
         tg_dest.PROK_GROUP_ID,
         hpf.GENE_ID
order by tg_src.PROK_GROUP_ID,
         tg_dest.PROK_GROUP_ID,
         hpf.GENE_ID
       
--where tg_src.PROK_GROUP_ID = 14 and
--      tg_dest.PROK_GROUP_ID = 14 

DROP TABLE "PUBLIC"."HGT_PAR_GENE_GROUP_VAL";
DROP TABLE "PUBLIC"."HGT_PAR_GENE_GROUP_CNT";

DROP TABLE "PUBLIC"."HGT_PAR_GENE_GROUP_CNT";

{call FunPROC1(1,2)}

{call FUNC1(1, 2)}



select sum(ht.weight)
                   from hgt_par_transfers ht
                    left join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
                    left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID
                    left join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
                    left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                   where tg_src.PROK_GROUP_ID = 14 and
                         tg_dest.PROK_GROUP_ID = 14 
                   group by tg_src.PROK_GROUP_ID,
                            tg_dest.PROK_GROUP_ID


select *
from HGT_PAR_TRANSFER_GROUPS
where cnt is null
