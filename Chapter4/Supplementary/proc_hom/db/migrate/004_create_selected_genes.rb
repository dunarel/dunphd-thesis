class CreateSelectedGenes < ActiveRecord::Migration
=begin
  def up
    sql = "create view selected_genes as select * from all_genes where seqs_orig_nb >=100;"
    ActiveRecord::Base.connection.execute(sql)
    
  end

  def down
    sql = "drop view selected_genes;"
    ActiveRecord::Base.connection.execute(sql)
 
  end
=end
end
