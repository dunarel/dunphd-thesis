class CreateLproks < ActiveRecord::Migration

  def change
      create_table :lproks do |t|
      t.integer :ref_seq_proj_id
      t.integer :project_id
      t.integer :taxid
      t.string :organism_name
      t.string :super_kingdom
      t.string :simple_group
      t.string :sequence_status
      t.float :genome_size
      t.float :gc_content
      t.string :gram_stain
      t.string :shape
      t.string :arrangment
      t.string :endospores
      t.string :mobility
      t.string :salinity
      t.string :oxygen_req
      t.string :habitat
      t.string :temp_range
      t.string :optimal_temp
      t.string :pathogenic_in
      t.string :disease
      t.string :genbank_acc
      
      t.timestamps
    end
    #add_index :gene_blo_runs, :blo_run_id
    
  end
end
