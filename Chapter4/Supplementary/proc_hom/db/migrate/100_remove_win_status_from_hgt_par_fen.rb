class RemoveWinStatusFromHgtParFen < ActiveRecord::Migration
  def up
    remove_index :hgt_par_fens, :win_status
    remove_column :hgt_par_fens, :win_status
  end

  def down
    add_column :hgt_par_fens, :win_status, :string
    add_index :hgt_par_fens, :win_status
  end

end
