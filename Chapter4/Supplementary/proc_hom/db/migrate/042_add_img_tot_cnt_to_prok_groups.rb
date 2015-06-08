class AddImgTotCntToProkGroups < ActiveRecord::Migration
  def change
     add_column :prok_groups, :img_tot_cnt, :integer
  end
end
