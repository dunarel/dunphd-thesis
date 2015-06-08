class ModifyGeneSeqsClobDims < ActiveRecord::Migration
=begin
  def up
    sql = "alter table gene_seqs alter column naseq clob(32m);"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = "alter table gene_seqs alter column naseq clob;"
    ActiveRecord::Base.connection.execute(sql)
  end
=end
end
