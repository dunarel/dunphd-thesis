class BloRunsController < ApplicationController
  # GET /blo_runs
  # GET /blo_runs.json
  def index
    @blo_runs = BloRun.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @blo_runs }
    end
  end


 #send_file "/root/devel/proc_hom/files/proc/gene_blo_runs/#{@blo_run.name}.fasta", :type => 'text/html'

  # GET /blo_runs/1
  # GET /blo_runs/1.json
  def show
    @blo_run = BloRun.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :text => @blo_run.id }
      format.fasta { render :text => "fasta ok"  }
    end
  end

 
  # GET /blo_runs/new
  # GET /blo_runs/new.json
  def new
    @blo_run = BloRun.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @blo_run }
    end
  end

  # GET /blo_runs/1/edit
  def edit
    @blo_run = BloRun.find(params[:id])
  end

  # POST /blo_runs
  # POST /blo_runs.json
  def create
    @blo_run = BloRun.new(params[:blo_run])

    respond_to do |format|
      if @blo_run.save
        format.html { redirect_to @blo_run, :notice => 'Blo run was successfully created.' }
        format.json { render :json => @blo_run, :status => :created, :location => @blo_run }
      else
        format.html { render :action => "new" }
        format.json { render :json => @blo_run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blo_runs/1
  # PUT /blo_runs/1.json
  def update
    @blo_run = BloRun.find(params[:id])

    respond_to do |format|
      if @blo_run.update_attributes(params[:blo_run])
        format.html { redirect_to @blo_run, :notice => 'Blo run was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @blo_run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blo_runs/1
  # DELETE /blo_runs/1.json
  def destroy
    @blo_run = BloRun.find(params[:id])
    @blo_run.destroy

    respond_to do |format|
      format.html { redirect_to blo_runs_url }
      format.json { head :ok }
    end
  end
end
