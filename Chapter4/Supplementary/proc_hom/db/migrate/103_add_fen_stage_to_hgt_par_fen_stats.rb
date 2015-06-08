class AddFenStageToHgtParFenStats < ActiveRecord::Migration

  def up
    add_column :hgt_par_fen_stats, :fen_stage_id, :INTEGER

  end

  def down
    remove_column :hgt_par_fen_stats, :fen_stage_id

  end
end
