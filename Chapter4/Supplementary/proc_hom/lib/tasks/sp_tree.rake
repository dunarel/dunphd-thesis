require 'species_tree_cin'

namespace :sp_tree  do
   

 
  desc "default job"
  task :default => :environment do
 
   st = SpeciesTreeCin.new
   st.load_initial_tree()
   #change the yellow
   #st.reload_colors()
   
   st.load_group_colors()
   st.load_hgts_itol()

   st.adjust_nodes()
  
   #st.save_mod_tree()
   #st.reload_mod_tree()
   
     
   #st.bfs()
   #st.adjust_branch_length_unit()
   
    
  st.relabel_leafs()
  st.save_mod_tree()
    
  st.export_strips()
  st.export_group_colors()
  st.export_legend_tex()
  st.export_hgts_itol()
  st.export_font_styles()
   
    puts "ok.default"
   
   
  end
  
  desc "fix label names"
  task :reload_tree_names => :environment do
    
    
    st = SpeciesTreeCin.new
    #st.reload_tree_names
    st.reload_tree_names_csv()
    st.export_tree_order()
    
  
   
  end  
 
  desc "export strips"
  task :export_strips => :environment do
    
    
    st = SpeciesTreeCin.new
    st.export_strips
   
    
    
  
   
  end  
  
  desc "export font styles"
  task :export_font_styles => :environment do
    
    
    st = SpeciesTreeCin.new
    st.export_font_styles
   
    
    
  
   
  end 
 

end
