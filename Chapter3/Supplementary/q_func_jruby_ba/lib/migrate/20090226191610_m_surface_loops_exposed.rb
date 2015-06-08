class MSurfaceLoopsExposed < ActiveRecord::Migration
  def self.up


    create_table :surface_loops_exposed do |t|
      t.integer :position
      t.integer :idx_begin
      t.integer :idx_end


    end

  end

  def self.down
   drop_table :surface_loops_exposed
  end

end