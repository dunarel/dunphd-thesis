class CreateTaxonGroups < ActiveRecord::Migration
  def up
    create_table :taxon_groups do |t|
      #t.references :taxon
      t.references :prok_group

      t.timestamps
    end
    #add_index :taxon_groups, :taxon_id, :unique => true
    add_index :taxon_groups, :prok_group_id
    
    
    #import data
    #take taxon_id from NCBI Taxonomy ftp for project
    execute "insert into taxon_groups(id,prok_group_id)
             select sg.taxid,
                    pg.id 
             from (select distinct taxid,SIMPLE_GROUP
                   from LPROKS lp) sg
              join PROK_GROUPS pg on pg.name=sg.simple_group
              order by pg.id"
    #add parent group for a sequence that is under species
    # sequence taxid is of sub-species level but project is on species level
    #find these sequences with SQL:
        #select *
        #from VERS_ACCESSES
        #where taxon_id not in (select taxon_id
        #           from taxon_groups)
    #remedy with:
    execute "insert into TAXON_GROUPS 
              (ID,PROK_GROUP_ID)
             select 1048245,PROK_GROUP_ID 
             from TAXON_GROUPS tg
             where ID=78331"
  end
  
  def down
    drop_table :taxon_groups
  end
end
