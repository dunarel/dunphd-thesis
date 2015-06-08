class CreateHgtSimPerms < ActiveRecord::Migration
  def change
    create_table :hgt_sim_perms do |t|
      t.references :hgt_sim_cond
      t.float :nb_trsfs
      t.string :perm_list_id, :limit => 8192
      t.string :perm_list_gi, :limit => 8192
      

      #t.timestamps
    end
    add_index :hgt_sim_perms, :hgt_sim_cond_id
  end
end
