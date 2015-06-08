class AddNaseqOrigNbtoGenes < ActiveRecord::Migration
  def change
    add_column :genes, :naseq_orig_nb, :integer   

  end
end
