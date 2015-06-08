class AddWinSizeToHgtParFragms < ActiveRecord::Migration
  def up
    add_column :hgt_par_fragms, :win_size, :integer

  end
  
  def down
    remove_column :hgt_par_fragms, :win_size

  end
end
