class GeneBloRunsController < ApplicationController
  # GET /gene_blo_runs
  # GET /gene_blo_runs.json
  def index
    @gene_blo_runs = GeneBloRun.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @gene_blo_runs }
    end
  end

  # GET /gene_blo_runs/1
  # GET /gene_blo_runs/1.json
  def show
    @gene_blo_run = GeneBloRun.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @gene_blo_run }
    end
  end

  # GET /gene_blo_runs/new
  # GET /gene_blo_runs/new.json
  def new
    @gene_blo_run = GeneBloRun.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @gene_blo_run }
    end
  end

  # GET /gene_blo_runs/1/edit
  def edit
    @gene_blo_run = GeneBloRun.find(params[:id])
  end

  # POST /gene_blo_runs
  # POST /gene_blo_runs.json
  def create
    @gene_blo_run = GeneBloRun.new(params[:gene_blo_run])

    respond_to do |format|
      if @gene_blo_run.save
        format.html { redirect_to @gene_blo_run, :notice => 'Gene blo run was successfully created.' }
        format.json { render :json => @gene_blo_run, :status => :created, :location => @gene_blo_run }
      else
        format.html { render :action => "new" }
        format.json { render :json => @gene_blo_run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /gene_blo_runs/1
  # PUT /gene_blo_runs/1.json
  def update
    @gene_blo_run = GeneBloRun.find(params[:id])

    respond_to do |format|
      if @gene_blo_run.update_attributes(params[:gene_blo_run])
        format.html { redirect_to @gene_blo_run, :notice => 'Gene blo run was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @gene_blo_run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /gene_blo_runs/1
  # DELETE /gene_blo_runs/1.json
  def destroy
    @gene_blo_run = GeneBloRun.find(params[:id])
    @gene_blo_run.destroy

    respond_to do |format|
      format.html { redirect_to gene_blo_runs_url }
      format.json { head :ok }
    end
  end
end
