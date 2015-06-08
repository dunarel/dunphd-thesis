class CreateGenes < ActiveRecord::Migration
  def change
    create_table :genes do |t|
      t.string :name
      t.integer :seqs_orig_nb
      t.integer :oa_orig_nb

      t.timestamps
    end
  end
end
