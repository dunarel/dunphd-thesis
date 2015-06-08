class AddTaxonIdDataToTaxonGroups < ActiveRecord::Migration


  def up
    self.class.insert_data()
  end

  def down
    execute "update taxon_groups
             set taxon_id = null
             where prok_group_id  <= 22"
  end

  def self.insert_data()

    execute "update taxon_groups
             set taxon_id = id
             where prok_group_id <= 22"
   

  end


end
