class CreateAssocTaxidAccess < ActiveRecord::Migration
  def up
   sql="CREATE TEXT TABLE assoc_taxid_access (
      id integer,
      taxid integer,
      vers_access varchar(255),
      scientif_name varchar(255),
      group_name varchar(255)
     );"
    ActiveRecord::Base.connection.execute(sql)
    
    sql="set table assoc_taxid_access source 'assoc_taxid_access.csv';"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql="drop table assoc_taxid_access;"
    ActiveRecord::Base.connection.execute(sql)
  end
end
