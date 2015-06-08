
drop table la_alleles;

create table la_alleles as (
select rownum() as id,
	  gbs.NCBI_SEQ_ID,
       ns.VERS_ACCESS
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
order by gbs.NCBI_SEQ_ID
) WITH DATA;

CREATE UNIQUE INDEX la_alleles_id ON la_alleles (id asc);

CREATE UNIQUE INDEX la_alleles_ncbi_seq_id ON la_alleles (ncbi_seq_id asc);

select *
from LA_ALLELES;

--S taxons from tree S
drop table la_taxons;

create table la_taxons as (
select tx.TREE_ORDER as id,
       tx.ID as taxon_id,
       tx.TREE_NAME,
       tx.SCI_NAME
from taxons tx
order by tx.TREE_ORDER
) WITH DATA ;

CREATE UNIQUE INDEX la_taxons_id ON la_taxons (id asc);

CREATE UNIQUE INDEX la_taxons_taxon_id ON la_taxons (taxon_id asc);


select *
from LA_TAXONS;


select *
from GENE_BLO_RUNS

-- A all alleles 
create table la_aleles as (
select rownum(),
	  gbs.NCBI_SEQ_ID,
       ns.VERS_ACCESS
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
order by gbs.NCBI_SEQ_ID )

-- G genes
select rownum(),
       gn.id as gene_id,
       gn.name
from GENES gn
where gn.name not in ('rbcL')
order by gn.id 
      

-- A x G
select gbs.gene_id,
       gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
order by gbs.GENE_ID







--S taxons from tree S
select tx.TREE_ORDER,
       tx.ID,
       tx.TREE_NAME,
       tx.SCI_NAME
from taxons tx
order by tx.TREE_ORDER





-- Z = S x A
select gbs.NCBI_SEQ_ID,
       ns.TAXON_ID,
       count(*)
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
group by gbs.NCBI_SEQ_ID,
       ns.TAXON_ID

create table la_missing_alleles as (
select distinct gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
 minus
-- Z = S x A
select distinct NCBI_SEQ_id from 
(
select gbs.NCBI_SEQ_ID,
       ns.TAXON_ID,
       la.ID,
       lt.id
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join LA_ALLELES la on la.NCBI_SEQ_ID = gbs.NCBI_SEQ_ID
 join LA_TAXONS lt on lt.TAXON_ID = ns.TAXON_ID
) t
) with data;

select DISTINCT lt.TAXON_ID
from LA_TAXONS lt

select *
from LA_MISSING_ALLELES lma
 join NCBI_SEQS ns on ns.ID = lma.NCBI_SEQ_ID

-- W weights (P x S)
select tg.id,
       tg.PROK_GROUP_ID,
       tg.WEIGHT_PG,
       tg.TAXON_ID
from TAXON_GROUPS tg
where tg.WEIGHT_PG is not null
and tg.PROK_GROUP_ID between 23 and 100




-- allele per gene
select gbs.gene_id, count(*)
from GENE_BLO_SEQS gbs
group by gbs.GENE_ID
order by gbs.GENE_ID

select tg.PROK_GROUP_ID,count(*)
from TAXON_GROUPS tg
where tg.PROK_GROUP_ID between 0 and 22
group by tg.PROK_GROUP_ID

select *
from TAXON_GROUPS tg
where tg.PROK_GROUP_ID between 0 and 22 and
      tg.WEIGHT_PG is not null

select count(*)
from 
(




)

select *
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID


select distinct gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
 






