class CreateBloRuns < ActiveRecord::Migration
  def change
    create_table :blo_runs do |t|
      t.string :name
      t.string :params

      t.timestamps
    end
  end
end
