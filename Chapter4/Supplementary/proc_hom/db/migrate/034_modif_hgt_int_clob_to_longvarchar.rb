class ModifHgtIntClobToLongvarchar < ActiveRecord::Migration
  
  def up
    
  
    #assure longvarchar
    sql = "alter table HGT_COM_INT_FRAGMS alter column from_subtree set data type longvarchar;"
    ActiveRecord::Base.connection.execute(sql)
    
    #
    sql = "alter table HGT_COM_INT_FRAGMS alter column to_subtree set data type longvarchar;"
    ActiveRecord::Base.connection.execute(sql)
    
    #
    sql = "alter table HGT_COM_INT_CONTINS alter column from_subtree set data type longvarchar;"
    ActiveRecord::Base.connection.execute(sql)
    
    #
    sql = "alter table HGT_COM_INT_CONTINS alter column to_subtree set data type longvarchar;"
    ActiveRecord::Base.connection.execute(sql)
    
      
  end
  
  #there is no turning back to clobs :)
  def down
        
    #just to verify if there are more clobs
    #select count(*)
    #from system_lobs.lob_ids 
      
    #and their dimension
    #SELECT sum(lob_length)/(1024.0*1024.0) FROM system_lobs.lob_ids
    
  end
  
  
=begin  

   

  def up
    sql = "CREATE TABLE hgt_par_fragms (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY(START WITH 0) PRIMARY KEY,
    gene_id integer,
    fen_no integer,
    fen_idx_min integer,
    fen_idx_max integer,
    iter_no integer,
    hgt_no integer,
    hgt_type varchar(255),
    from_subtree longvarchar,
    from_cnt integer,
    to_subtree longvarchar,
    to_cnt integer,
    bs_val float,
    bs_direct float,
    bs_inverse float,
    created_at DATETIME,
    updated_at DATETIME
    );"
    ActiveRecord::Base.connection.execute(sql)
    
    sql = "CREATE INDEX index_hgt_par_fragms_on_gene_id ON hgt_par_fragms (gene_id);"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = "drop table hgt_par_fragms;"
    ActiveRecord::Base.connection.execute(sql)
  end

=end

  

   
  
  
=begin  
    sql = "CREATE TABLE hgt_par_fragms (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY(START WITH 0) PRIMARY KEY,
    gene_id integer,
    fen_no integer,
    fen_idx_min integer,
    fen_idx_max integer,
    iter_no integer,
    hgt_no integer,
    hgt_type varchar(255),
    from_subtree clob,
    from_cnt integer,
    to_subtree clob,
    to_cnt integer,
    bs_val float,
    bs_direct float,
    bs_inverse float,
    created_at DATETIME,
    updated_at DATETIME
    );"
    ActiveRecord::Base.connection.execute(sql)
  
=end
end
