class MMsaDna < ActiveRecord::Migration
  def self.up
    create_table :msa_dna do |t|
      t.integer :length
      t.text :seq
    end

    
  end

  def self.down
    drop_table :msa_dna
  
  end
  
end
