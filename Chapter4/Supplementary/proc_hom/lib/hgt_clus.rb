

module HgtClusConfig

  def init
    puts "in HgtClusConfig.init"
    super

  end


  #calculation active working folder
  #floc = :work, :res
  def section_d
     
   case @stage
    when "hgt-com"
     raise "not yet implemented"
     #"#{AppConfig.hgt_com_dir}/#{calc_section.to_s}"
    when "hgt-par"
      "#{AppConfig.hgt_par_dir}/#{calc_section.to_s}"
    end
    
  end

  def section_phylo_prog_d

    case @stage
    when "hgt-com"
     raise ""
    when "hgt-par"
      case self.calc_section
      when :hgt,:phylo
        "#{section_d}/#{@phylo_prog}"
      when :timing
        "#{section_d}/#{self.timing_prog.to_s}/#{@phylo_prog}"
      else
        raise "not implemented !"
      end
    end

  end

  def remote_section_phylo_prog_d

    case @stage
    when "hgt-com"
     raise ""
    when "hgt-par"

      case self.calc_section
      when :hgt,:phylo
        "#{AppConfig.remote_hgt_par_dir}/#{calc_section.to_s}/#{@phylo_prog}"
      when :timing
        "#{AppConfig.remote_hgt_par_dir}/#{calc_section.to_s}/#{self.timing_prog.to_s}/#{@phylo_prog}"
      else
        raise "not implemented !"
      end
    end

  end




  #remote MP2
  #floc = :exec, :jobs, :work, :res
  def remote_compart_d(floc)

    case floc
    when :exec
      "#{remote_section_phylo_prog_d}/exec"
    when :jobs
      "#{remote_section_phylo_prog_d}/jobs"
    when :work
      "#{remote_section_phylo_prog_d}/work"
    when :res
      "#{remote_section_phylo_prog_d}/results"
    end

  end


  #floc = :exec, :jobs, :work, :res, :templ
  def compart_d(floc)

    case floc
    when :exec
      "#{section_phylo_prog_d}/exec"
    when :jobs
      "#{section_phylo_prog_d}/jobs"
    when :work
      "#{section_phylo_prog_d}/work"
    when :res
      "#{section_phylo_prog_d}/results"
    when :templ
      "#{section_phylo_prog_d}/templ"
    else
      raise "Please review compart_d options !"

    end

  end

  #floc = :work, :res
  def gene_d(floc)
    "#{compart_d(floc)}/#{@gene.name}"
  end

  #floc = :work, :res
  def size_d(floc)
    "#{gene_d(floc)}/#{@win_size}"

  end

  #calculation active working folder
  #floc = :work, :res
  def fen_d(floc)

    case @stage
    when "hgt-com"
      #working dir is same as gene dir
      #there are no sizes and windows
     Pathname.new gene_d(floc)
    when "hgt-par"
     Pathname.new "#{size_d(floc)}/#{@win_dir}"
    end


  end


  #floc = :work
  def fen_phy_align_f(floc)

   case floc
    when :work
      #! local files should not have gene identifier
      #  should be anonymous, identification elements outside filename
      "#{fen_d(floc)}/fen_align.phy"

    else
      raise "Please review phy_align_f options !"
    end

  end


  def fen_nwk_re(floc)

      #! local files should not have gene identifier
      #  should be anonymous, identification elements outside filename
      Pathname.new "#{fen_d(floc)}/RAxML_bipartitions.fen_align.re"

  end

  def fen_hgt_output(floc)

      #! local files should not have gene identifier
      #  should be anonymous, identification elements outside filename
      Pathname.new "#{fen_d(floc)}/output.txt"

  end


  def alix_gene_hgt_par_raxml

   case @stage
    when "hgt-com"
     raise "not yet implemented"
    when "hgt-par"
      Pathname.new "#{AppConfig.hgt_par_dir}/hgt-par-raxml-#{@win_size}/#{@gene.name}"
    end

  end


  def alix_output_fen_hgt_par_raxml

   case @stage
    when "hgt-com"
     raise "not yet implemented"
    when "hgt-par"
      Pathname.new "#{AppConfig.hgt_par_dir}/hgt-par-raxml-#{@win_size}/#{@gene.name}/#{@fen_no}-#{@fen_idx_min}-#{@fen_idx_max}/output.txt"
   end

  end



end



module HgtClus


  attr_accessor :calc_section # [:phylo,:hgt,:timing]
  attr_accessor :fen_stage,:prev_fen_stage


  def calc_section=(calc_section)
    @calc_section = calc_section

  end

  
  #default fen_stage=0 for complete transfers
  def iterate_over_exec_elem(fen_stage=0, win_status=nil, &aproc)
    cnt = 0

    #@genes[81..109].each { |gn|
    @genes.each { |gn|
      @gene = gn
      
      #skip project 3 gene rbcL
      next if @gene.name == "rbcL"
      #debugging
      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.id != 152
      #puts "cnt: #{cnt}, gn.id: #{@gene.id}, gn.name: #{@gene.name}, @genes[cnt]: #{@genes[cnt].id}"

      if @stage=="hgt-par"
        iterate_over_win(fen_stage,win_status){ |win|
          aproc.call "gn: #{@gene.id}, win: #{win}"
        }
      else
        aproc.call "gn: #{@gene.id}"
      end

      #index starts at 0, so incremented at the end
      cnt += 1
    }



  end

 
end