class CreateNcbiSeqs < ActiveRecord::Migration
  def up
    create_table :ncbi_seqs do |t|

      t.string :vers_access
      t.integer :taxon_id

      t.timestamps
    end
    add_index :ncbi_seqs, :vers_access, :unique => true
    
  end
  
  def down
    drop_table :ncbi_seqs
    
  end
end
