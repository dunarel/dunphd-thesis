class CreateOrthoRuns < ActiveRecord::Migration
  def change
    create_table :ortho_runs do |t|
      t.string :name
      t.string :params

      t.timestamps
    end
    add_index :ortho_runs, :name , :unique => true

  end
end
