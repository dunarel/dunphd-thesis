class CreateMsaRuns < ActiveRecord::Migration
  def change
    create_table :msa_runs do |t|
      t.string :name
      t.string :params

      t.timestamps
    end
  end
end
