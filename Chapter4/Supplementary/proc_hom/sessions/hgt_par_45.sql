
select g.id,g.name,count(*),id-110
from genes g
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = g.id
group by g.id
order by count(*) asc

select m.id,
                  m.abrev,
                  m.time_min,
                  m.time_max
           from mrcas m
           order by (m.time_max - m.time_min) asc