class CreateGeneSeqs < ActiveRecord::Migration
  def change
    create_table :gene_seqs do |t|
      t.string :accession
      t.string :vers_access
      t.string :vers_gi
      t.references :gene
      #t.text :aaseq 
      #t.text :naseq
      t.integer :cds_nb
      t.integer :loc_nb      

      t.timestamps
    end

    add_index :gene_seqs, :gene_id
    add_index :gene_seqs, :vers_access, :unique => true 

  end
end
