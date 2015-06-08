class AddDataToTimingCriters < ActiveRecord::Migration
 def up
    self.class.update_data()
  end

  def down
    self.class.delete_data()

  end

  def self.update_data()
    self.delete_data()
    self.insert_data()
  end


  def self.insert_data()

    #less restrictive conditions first
   [[0,:beast.to_s,"B.E.A.S.T."],
    [1,:treepl.to_s,"TreePL"]
   ].each { |cr|

     execute "insert into timing_criters
               (id,abrev,name)
              values (#{cr[0]},'#{cr[1]}','#{cr[2]}')"
    }


  end

  def self.delete_data()
    execute "delete from timing_criters"

  end
end
