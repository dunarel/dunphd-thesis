class CreateMrcaStdevs < ActiveRecord::Migration
  def change
    create_table :mrca_stdevs do |t|
      t.references :mrca
      t.float :stdev

      #t.timestamps
    end
    add_index :mrca_stdevs, :mrca_id
  end
end
