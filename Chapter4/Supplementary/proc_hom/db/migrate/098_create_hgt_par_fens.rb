class CreateHgtParFens < ActiveRecord::Migration
  def change
    create_table :hgt_par_fens do |t|
      t.references :gene
      t.integer :win_size
      t.integer :fen_no
      t.integer :fen_idx_min
      t.integer :fen_idx_max
      t.integer :win_wide
      t.integer :win_step
      t.string :win_status
      t.string :win_sel


      t.timestamps
    end
    add_index :hgt_par_fens, :gene_id
    add_index :hgt_par_fens, :win_status
    add_index :hgt_par_fens, :win_sel
  end
end
