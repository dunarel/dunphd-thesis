class CreateHgtParFenStats < ActiveRecord::Migration
  def change
    create_table :hgt_par_fen_stats do |t|
      t.references :hgt_par_fen
      t.string :win_status

      t.timestamps
    end
    add_index :hgt_par_fen_stats, :hgt_par_fen_id
    add_index :hgt_par_fen_stats, :win_status
  end
end
