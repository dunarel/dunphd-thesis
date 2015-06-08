class AddDataToFenStages < ActiveRecord::Migration
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
   [[0,nil, "alix_design",nil,nil],
    [1,0, "phylo","raxml",nil],
    [2,1, "hgt","raxml",nil],
    [3,2, "timing","raxml","treepl"],
    [4,2, "timing","raxml","beast"]
   ].each { |cr|
     #escape for nil to null values
      cr[1] = cr[1].nil? ? "null" : "#{cr[1]}"
      cr[3] = cr[3].nil? ? "null" : "'#{cr[3]}'"
      cr[4] = cr[4].nil? ? "null" : "'#{cr[4]}'"
     

     sql= "insert into fen_stages
            (id,prev_fen_stage_id,calc_section,phylo_prog,timing_prog,created_at,updated_at)
           values (#{cr[0]},#{cr[1]},'#{cr[2]}',#{cr[3]},#{cr[4]}),current_timestamp,current_timestamp"
     puts sql
     execute sql
    }
  end

  def self.delete_data()
    execute "delete from fen_stages"


  end
end
