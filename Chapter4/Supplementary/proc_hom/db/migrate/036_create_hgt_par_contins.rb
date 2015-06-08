class CreateHgtParContins < ActiveRecord::Migration
  def change
    create_table :hgt_par_contins do |t|
      t.references :gene
      t.integer :fen_idx_min
      t.integer :fen_idx_max
      t.integer :length
      t.float :bs_val
      t.float :bs_direct
      t.float :bs_inverse

      t.timestamps
    end
    add_index :hgt_par_contins, :gene_id
  end
end
