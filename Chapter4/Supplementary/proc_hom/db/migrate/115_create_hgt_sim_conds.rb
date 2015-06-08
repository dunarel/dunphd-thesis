class CreateHgtSimConds < ActiveRecord::Migration
  def change
    create_table :hgt_sim_conds do |t|
      t.references :gene
      t.integer :max_trsfs
      t.integer :nb_perms
      #t.timestamps
    end
    add_index :hgt_sim_conds, :gene_id
  end
end
