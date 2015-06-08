
select *
from hgt_par_fragms hpf
where hpf.gene_id = 172



where id in  (13099960,13099978)

select *
from HGT_PAR_FRAGMS hpf
where hpf.GENE_ID = 172

select count(*)
from HGT_PAR_CONTINS hpc
where hpc.gene_id= 172

delete from hgt_par_contins


select HGT_PAR_CONTIN_ID,count(*)
from HGT_PAR_FRAGMS hpf
group by HGT_PAR_CONTIN_ID
order by count(*) desc
limit 1

select hpf.CONTIN_REALIGN_STATUS,
       hpf.FROM_SUBTREE,
       hpf.TO_SUBTREE,
       hpf.BS_DIRECT,
       hpf.BS_INVERSE
from HGT_PAR_FRAGMS hpf 
where hpf.HGT_PAR_CONTIN_ID = (select HGT_PAR_CONTIN_ID
                               from HGT_PAR_FRAGMS hpf
                               group by HGT_PAR_CONTIN_ID
                               order by count(*) desc 
                               limit 1)

select *
from HGT_PAR_CONTINS hpc
where hpc.id = 2732111

select distinct CONTIN_REALIGN_STATUS
from HGT_PAR_FRAGMS hpf


select hpf.HGT_PAR_CONTIN_ID,
       min(hpf.FEN_IDX_MIN) as idx_min
from hgt_par_fragms hpf
group by hpf.HGT_PAR_CONTIN_ID

update HGT_PAR_CONTINS hpc
set (hpc.FEN_IDX_MIN,
     hpc.FEN_IDX_MAX,
     hpc.LENGTH,
     hpc.BS_DIRECT,
     hpc.BS_INVERSE,
     hpc.BS_VAL) = (select min(hpf.FEN_IDX_MIN),
                           max(hpf.FEN_IDX_MAX),
                           max(hpf.FEN_IDX_MAX)-min(hpf.FEN_IDX_MIN),
                           max(hpf.BS_DIRECT),
                           max(hpf.BS_INVERSE),
                           max(hpf.BS_DIRECT)+max(hpf.BS_INVERSE)
                         from HGT_PAR_FRAGMS hpf
                         where hpf.HGT_PAR_CONTIN_ID=hpc.ID)
where hpc.GENE_ID = 190
                       




select hpc.id,
       hpc.BS_VAL,
       hpc.BS_DIRECT > hpc.BS_INVERSE as normal_order,
       sum (hpf.FROM_CNT * hpf.TO_CNT) as comb_nb
from hgt_par_contins hpc
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.id
where gene_id =172
group by hpc.id
order by hpc.id

select *
from HGT_PAR_CONTINS
where id = 2738379



            
select hpf.id,
       hpf.HGT_PAR_CONTIN_ID,
       hpf.FROM_SUBTREE,
       hpf.TO_SUBTREE
from HGT_PAR_FRAGMS hpf
where hpf.GENE_ID = 172
order by hpf.HGT_PAR_CONTIN_ID,
         hpf.id

select count(*)
from HGT_PAR_TRANSFERS

delete from 
hgt_par_transfers

insert into HGT_PAR_TRANSFERS hpt
(hgt_par_fragm_id,hgt_par_contin_id,ncbi_seq_source_id,ncbi_seq_dest_id,weight)
values 
(?,?,?,?,?)

select sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt


select sum(hct.WEIGHT)
from HGT_COM_INT_TRANSFERS hct

select count(*)
from HGT_PAR_CONTINS hpc 
where hpc.BS_VAL > 75

select count(*)
from TAXON_GROUPS
where WEIGHT_PG is not null


update HGT_PAR_TRANSFERS hpt
set hpt.AGE_MD_WG = 1


checkpoint defrag;

drop index INDEX_HGT_PAR_TRSF_PRKGRS ON HGT_PAR_TRSF_PRKGRS

alter table HGT_COM_TRSF_PRKGRS drop column HGT_COM_TRSF_TAXON_ID

checkpoint defrag

select count(*)
from HGT_PAR_CONTINS hpc
where hpc.BS_VAL >=75

select sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt

select count(*)
from HGT_PAR_CONTINS hpc
where hpc.BS_VAL >= 75

select *
from genes

select *
from hgt_par_fragms hpf
where hpf.CONTIN_REALIGN_STATUS = 'Realigned'

where HGT_TYPE = 'Reference'



select sum(hpt.WEIGHT)
from hgt_par_transfers hpt
