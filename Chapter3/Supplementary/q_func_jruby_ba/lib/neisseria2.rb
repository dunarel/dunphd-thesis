require 'rubygems'
require 'active_record'
#require '/usr/share/java/postgresql-jdbc-8.3.604.jar'


#require 'active_record/connection_adapters/postgresql_adapter'
#require 'active_record/connection_adapters/jdbc_adapter'
#require 'jdbc-postgres'

require 'ar_utils'

au = ArUtils.new
au.connect(true)

#au.migrate(nil)
#au.migrate(20090226191610)
#au.migrate(20090226175601)



require 'ar_neisseria'

#m_init = ArNeisseria::Initialize.new
#m_init.init_msa_dna
#m_init.init_seq_dna
#m_init.init_seq_aa
#m_init.init_surface_loops_exposed
#m_init.init_periplasmic_loops_exposed




#m_calc = ArNeisseria::Calculate.new

#m_calc.assign_msa_to_dna
#min_max = m_calc.min_max_msa_from_aa(183)
#m_calc.assign_surface_loops_exposed_limits
#m_calc.assign_periplasmic_loops_exposed_limits

#puts min_max[:min]
#puts min_max[:max]



#details
#del_msa_dna_pos = MsaDnaPos.find :all
#del_msa_dna_pos.each { |x| x.destroy }


#my_msa_dna = MsaDna.find(3)
#seq2 = my_msa_dna.seq
#puts seq
#puts seq.length

#insert q_func 

#q_func = QFunction.new
#q_func.index = 100
#q_func.q_val = 17.98
#q_func.save




