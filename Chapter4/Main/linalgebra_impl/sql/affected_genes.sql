select 'com-all','com-core','par-all','par-core'

select sum(com_all) as com_all,
       sum(com_core) as com_core,
       sum(par_all) as par_all,
       sum(par_core) as par_core
from 
(
select count(distinct fr.GENE_ID)/1.1 as com_all,
       0 as com_core, 
       0 as par_all,
       0 as par_core
from HGT_COM_INT_FRAGMS fr
 join genes gn on gn.id = fr.gene_id
where gn.id <> 220
 union all
select 0 as com_all,
       count(distinct fr.GENE_ID)/0.36 com_core,
       0 as par_all,
       0 as par_core
from HGT_COM_INT_FRAGMS fr
 join genes gn on gn.id = fr.gene_id
 join GENES_CORE_INTER gci on gci.ID = gn.id
where gn.id <> 220
 union all
select 0 as com_all,
       0 as com_core,
       count(distinct fr.GENE_ID)/1.1 as par_all, 
       0 as par_core
from HGT_PAR_FRAGMS fr
 join genes gn on gn.id = fr.gene_id
where gn.id <> 220
 union all
select 0 as com_all, 
       0 as com_core,
       0 as par_all,
       count(distinct fr.GENE_ID)/0.36 as par_core
from HGT_PAR_FRAGMS fr
 join genes gn on gn.id = fr.gene_id
 join GENES_CORE_INTER gci on gci.ID = gn.id
where gn.id <> 220
)

 
select *
from GENES_CORE_INTER gci



select *
from genes gn
where gn.id <> 220