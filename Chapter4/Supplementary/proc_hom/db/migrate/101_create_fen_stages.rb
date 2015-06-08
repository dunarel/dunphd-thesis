class CreateFenStages < ActiveRecord::Migration
  def change
    create_table :fen_stages do |t|
      t.references :prev_fen_stage
      t.string :calc_section
      t.string :phylo_prog
      t.string :timing_prog

      t.timestamps
    end
    add_index :fen_stages, :prev_fen_stage_id
    add_index :fen_stages, :phylo_prog
    add_index :fen_stages, :timing_prog
  end
end
