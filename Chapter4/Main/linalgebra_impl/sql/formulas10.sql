
--all indexes are 0 based
--so expect adjustments on the rownum() -1
--------------------------------------------------------- species (taxons)
--S taxons from tree S
drop table la_species;

create table la_species as (
select tx.TREE_ORDER - 1 as sp,
       tx.ID as taxon_id,
       tx.TREE_NAME,
       tx.SCI_NAME
from taxons tx
order by tx.TREE_ORDER
) WITH DATA ;

CREATE UNIQUE INDEX la_species_sp ON la_species (sp asc);

CREATE UNIQUE INDEX la_species_taxon_id ON la_species (taxon_id asc);

select *
from LA_SPECIES;

-------------------------------------------------------genes
-- G genes
drop table la_genes;

create table la_genes as (
select rownum()-1 gn,
       gn.id as gene_id,
       gn.name
from GENES gn
where gn.name not in ('rbcL')
order by gn.id 
) WITH DATA;

CREATE UNIQUE INDEX la_genes_gn ON la_genes (gn asc);

CREATE UNIQUE INDEX la_genes_gene_id ON la_genes (gene_id asc);

CREATE UNIQUE INDEX la_genes_name ON la_genes (name asc);

select *
from la_genes;


-----------------------------------------------------alleles
--only alleles that have an associated taxon in the tree
--the rest was droped by TRIBE MCL

drop table la_alleles;

create table la_alleles as (
select rownum() -1 as al,
       gbs.NCBI_SEQ_ID, 
       ns.VERS_ACCESS
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 --only alleles that have an associated taxon in the tree
 join lA_species ls on ls.TAXON_ID = ns.TAXON_ID
 --only alleles that are in regular genes not rcbL
 join LA_GENES lg on lg.GENE_ID = gbs.GENE_ID
order by gbs.NCBI_SEQ_ID
) WITH DATA;

CREATE UNIQUE INDEX la_alleles_al ON la_alleles (al asc);

CREATE UNIQUE INDEX la_alleles_ncbi_seq_id ON la_alleles (ncbi_seq_id asc);

select *
from LA_ALLELES;


----------------------------------------------------------------alleles-species
drop table la_alleles_species;

create table la_alleles_species as (
select la.AL,
       ls.SP,
       gbs.NCBI_SEQ_ID, 
       ns.VERS_ACCESS       
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join LA_ALLELES la on la.NCBI_SEQ_ID = gbs.NCBI_SEQ_ID
 join lA_species ls on ls.TAXON_ID = ns.TAXON_ID
order by la.AL
) WITH DATA;

CREATE UNIQUE INDEX la_alleles_species_al ON la_alleles_species (al asc);

CREATE INDEX la_alleles_species_sp ON la_alleles_species (sp asc);

CREATE INDEX la_alleles_species_ncbi_seq_id ON la_alleles_species (ncbi_seq_id asc);

CREATE INDEX la_alleles_species_vers_access ON la_alleles_species (vers_access asc);

select *
from la_alleles_species;


---------------------------------------------prokaryotic groups
drop table la_prok_groups;

create table la_prok_groups as (
select pg.ORDER_ID as PG,
       pg.id as PROK_GROUP_ID,
       pg.name
from PROK_GROUPS pg
where --pg.ID between 0 and 22
      pg.ID between 23 and 100
order by pg.ORDER_id
) WITH DATA;

CREATE UNIQUE INDEX la_prok_groups_pg ON la_prok_groups (pg asc);

CREATE UNIQUE INDEX la_prok_groups_ncbi_seq_id ON la_prok_groups (PROK_GROUP_ID asc);

select *
from la_prok_groups;

---------------------------------------------species prokaryotes
-- W weights (P x S)

drop table la_species_prok_groups;

create table la_species_prok_groups as (
select ls.SP,
       lpg.PG,
       tg.PROK_GROUP_ID,
       tg.WEIGHT_PG,
       tg.TAXON_ID
from TAXON_GROUPS tg
 join LA_PROK_GROUPS lpg on lpg.PROK_GROUP_ID = tg.PROK_GROUP_ID
 join LA_SPECIES ls on ls.TAXON_ID = tg.TAXON_ID
where tg.WEIGHT_PG is not null
      --and tg.PROK_GROUP_ID between 0 and 22
      and tg.PROK_GROUP_ID between 23 and 100
order by ls.SP,
       lpg.PG
) WITH DATA;

CREATE INDEX la_species_prok_groups_sp ON la_species_prok_groups (sp asc);

CREATE INDEX la_species_prok_groups_pg ON la_species_prok_groups (pg asc);

CREATE INDEX la_species_prok_groups_prok_group_id ON la_species_prok_groups (prok_group_id asc);

CREATE INDEX la_species_prok_groups_taxon_id ON la_species_prok_groups (taxon_id asc);

select *
from la_species_prok_groups;

select t0.taxon_id,
       t0.tree_name,
       case 
        when sum(t0.c0) > 0 then 1
        else 0
       end as "Human Respiratory",
       case 
        when sum(t0.c1) > 0 then 1
        else 0
       end as "Human Others",
       case 
        when sum(t0.c2) > 0 then 1
        else 0
       end as "Plant",
       case 
        when sum(t0.c3) > 0 then 1
        else 0
       end as"Animal",
       case 
        when sum(t0.c4) > 0 then 1
        else 0
       end as "Soil",
       case 
        when sum(t0.c5) > 0 then 1
        else 0
       end as "Marine",
       case 
        when sum(t0.c6) > 0 then 1
        else 0
       end as "Fresh water",
       case 
        when sum(t0.c7) > 0 then 1
        else 0
       end as "Extreme"
from 
(
select spg.TAXON_ID,
	  sp.tree_name,
	  case spg.PG
	   when 0 then spg.WEIGHT_PG
	   else 0
	  end as c0,
	  case spg.PG
	   when 1 then spg.WEIGHT_PG
	   else 0
	  end as c1,
	  case spg.PG
	   when 2 then spg.WEIGHT_PG
	   else 0
	  end as c2,
	  case spg.PG
	   when 3 then spg.WEIGHT_PG
	   else 0
	  end as c3,
	  case spg.PG
	   when 4 then spg.WEIGHT_PG
	   else 0
	  end as c4,
	  case spg.PG
	   when 5 then spg.WEIGHT_PG
	   else 0
	  end as c5,
	  case spg.PG
	   when 6 then spg.WEIGHT_PG
	   else 0
	  end as c6,
	  case spg.PG
	   when 7 then spg.WEIGHT_PG
	   else 0
	  end as c7
from LA_SPECIES_PROK_GROUPS spg
 join la_species sp on sp.taxon_id = spg.TAXON_ID
) t0 
group by t0.taxon_id,
         t0.tree_name
         







--------------------------------------------allele genes
--only considered alleles
-- A x G

drop table la_alleles_genes;

create table la_alleles_genes as (
select la.AL,
       lg.GN,
       gbs.gene_id,
       gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
 join LA_ALLELES la on la.NCBI_SEQ_ID = gbs.NCBI_SEQ_ID
 join LA_GENES lg on lg.GENE_ID = gbs.GENE_ID
order by gbs.GENE_ID
) WITH DATA;

CREATE INDEX la_alleles_genes_al ON la_alleles_genes (al asc);

CREATE INDEX la_alleles_genes_gn ON la_alleles_genes (gn asc);

CREATE INDEX la_alleles_genes_gene_id ON la_alleles_genes (gene_id asc);

CREATE INDEX la_alleles_genes_ncbi_seq_id ON la_alleles_genes (ncbi_seq_id asc);

select *
from la_alleles_genes;



select rownum()-1 as tr,
       hcif.id as fragm_id,
       hcif.GENE_ID,
       hcif.FROM_SUBTREE,
       hcif.TO_SUBTREE
from HGT_COM_INT_FRAGMS hcif

------------------------------------------------- transfers
drop table la_transfers;

create table la_transfers as (
select lg.GN,
       la_als.AL as als,
       la_ald.AL as ald,
       hcit.WEIGHT,
       hcif.ID as fragm_id,
       hcif.GENE_ID,
       hcit.SOURCE_ID,
       hcit.DEST_ID       
from HGT_COM_INT_TRANSFERS hcit
 join HGT_COM_INT_FRAGMS hcif on hcif.ID = hcit.HGT_COM_INT_FRAGM_ID
 join LA_ALLELES la_als on la_als.NCBI_SEQ_ID = hcit.SOURCE_ID
 join LA_ALLELES la_ald on la_ald.NCBI_SEQ_ID = hcit.DEST_ID
 join LA_GENES lg on lg.GENE_ID = hcif.GENE_ID
 order by lg.GN,
          hcif.ID 
) WITH DATA;

--CREATE INDEX la_alleles_genes_al ON la_alleles_genes (al asc);

--CREATE INDEX la_alleles_genes_gn ON la_alleles_genes (gn asc);

--CREATE INDEX la_alleles_genes_gene_id ON la_alleles_genes (gene_id asc);

--CREATE INDEX la_alleles_genes_ncbi_seq_id ON la_alleles_genes (ncbi_seq_id asc);

select *
from ;

select distinct (lat.GN)
from la_transfers lat;




select *
from HGT_COM_INT_FRAGMS







select sum(hcit.WEIGHT)
from HGT_COM_INT_TRANSFERS hcit

      




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



select *
from LA_MISSING_ALLELES lma
 join NCBI_SEQS ns on ns.ID = lma.NCBI_SEQ_ID





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
 






