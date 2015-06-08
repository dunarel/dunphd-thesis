
--insert into fen stats distinct windows to calculate
-- for minimal subset of windows to calculate 
insert into HGT_PAR_FEN_STATS
(HGT_PAR_FEN_ID,WIN_STATUS,FEN_STAGE_ID,created_at,updated_at)
select hpf.id,'reg75',2,current_timestamp,current_timestamp
from HGT_PAR_FENS hpf 
where (hpf.GENE_ID,
       hpf.WIN_SIZE,
       hpf.FEN_NO,
       hpf.FEN_IDX_MIN,
       hpf.FEN_IDX_MAX) 
 in (select distinct 
       hpf2.GENE_ID,
       hpf2.WIN_SIZE,
       hpf2.FEN_NO,
       hpf2.FEN_IDX_MIN,
       hpf2.FEN_IDX_MAX
from HGT_PAR_FRAGMS hpf2)



--all hgt windows of 75 bootstrap regular
select *
from HGT_PAR_FEN_STATS hpfs
where FEN_STAGE_ID = 2 and
      WIN_STATUS = 'reg75'

--reset win_sel
update HGT_PAR_FENS hpf
set hpf.WIN_SEL = null

--select same from fens
select *
from HGT_PAR_FENS hpf
where hpf.WIN_SEL = 'reg75'

--load transfers 
select distinct hpf.id
from HGT_PAR_FRAGMS hpf
where hpf.GENE_ID = 111

--
select distinct hpt.NCBI_SEQ_DEST_ID as dest_id
from HGT_PAR_FRAGMS hpf
 join HGT_PAR_TRANSFERS hpt on hpt.HGT_PAR_FRAGM_ID = hpf.ID 
where hpf.GENE_ID = 111 and 
      hpf.ID = 31503598

select count(*)
from hgt_par_contins hpc
where hpc.BS_VAL >= 75

select sum(hpt.WEIGHT)
from hgt_par_transfers hpt

select sum(hcit.WEIGHT)
from HGT_COM_INT_TRANSFERS hcit

