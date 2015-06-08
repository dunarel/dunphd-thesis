CREATE FUNCTION size_by_group_gene(IN P1 INT) 
RETURNS TABLE(C1 INT) 
SPECIFIC F1 LANGUAGE JAVA DETERMINISTIC 
EXTERNAL NAME 'CLASSPATH:proc_hom_sp.HgtPar.sizeByGroupGene'

select *
from SIZE_BY_GROUP_GENE(1,'test')

call SIZE_BY_GROUP_GENE(1, 'x')

drop function size_by_group_gene
