update prok_groups
set order_id=
where id=23

update PROK_GROUPS
set order_id = order_id - 1

select *
from PROK_GROUPS
order by order_id

select *
from HGT_COM_INT_TRANSFER_GROUPS
where source_id=dest_id
order by source_id

commit
checkpoint;

delete from HGT_COM_INT_TRANSFERS htx
where htx.id in (select ht.id
                 from hgt_com_int_transfers ht
  left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
  left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
  left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID
  left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
  left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
  where tg_src.PROK_GROUP_ID = tg_dest.PROK_GROUP_ID and
        hf.HGT_TYPE = 'Trivial'
        and ht.CONFIDENCE >= 75)
                   