class CreateTaxons < ActiveRecord::Migration
  def change
    create_table :taxons do |t|
      t.references :parent
      t.string :rank
      t.references :division

      t.timestamps
    end
    add_index :taxons, :parent_id
    add_index :taxons, :division_id
  end
end
