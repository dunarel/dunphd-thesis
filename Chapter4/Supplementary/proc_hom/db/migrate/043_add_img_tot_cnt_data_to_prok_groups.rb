class AddImgTotCntDataToProkGroups < ActiveRecord::Migration
  def up
    update_img_tot_cnt()
  end
  
  def down
    pgs = ProkGroup.find(:all)
    pgs.each {|pg|
      pg.img_tot_cnt = nil
      pg.save
    }
    
  end
  
  def update_img_tot_cnt()
    
    img_tot_cnt_a = [6,306,278,13,172,206,59,18,41,64,13,53,89,78,919,27,682,1,1,85,9,48,13]
    
    (0..img_tot_cnt_a.length-1).each {|i|
      pg = ProkGroup.find(i)
      pg.img_tot_cnt = img_tot_cnt_a[i]
      pg.save
      
    }
    
  end
  
end
