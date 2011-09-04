class VideosController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /videos
  # GET /videos.xml
  def index
    @videos = Video.page(params[:page]).order('created_at DESC')

  end
  
  def category
    @title = @category = params[:category]
    case @category.downcase
    when "all" then
      @title = "All Videos"
      @videos = Video.page(params[:page]).order('created_at DESC')
    when "online" then
      @title = "Online Videos"
      @videos = Video.where(:state => "online").order(:created_at.desc).paginate(:per_page => 25, :page => params[:page])
    when "offline" then
      @title = "Offline Videos"
      @videos = Video.where(:state => "offline").order(:created_at.desc).paginate(:per_page => 25, :page => params[:page])
    when "expired" then
      @videos = Video.where(:state => "expire").order(:created_at.desc).paginate(:per_page => 25, :page => params[:page])
    else
      @videos = Video.where(:filename.matches => "%#{@category}%").order(:created_at.desc).paginate(:per_page => 25, :page => params[:page])
    end
    
    render :template => 'videos/index'
    
  end
  
  def search
    @videos = Video.where(:filename.matches => "%#{params[:q]}%").order(:created_at.desc).paginate(:per_page => 25, :page => params[:page])
    @title  = "Search Results :: " + params[:q]
    
    render :template => 'videos/index'
    
  end
  
  # GET /videos/1
  # GET /videos/1.xml
  def show
    @video = Video.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @video }
    end
  end

  # GET /videos/new
  # GET /videos/new.xml
  def new
    @video = Video.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @video }
    end
  end

  # GET /videos/1/edit
  def edit
    @video = Video.find(params[:id])
  end

  # POST /videos
  # POST /videos.xml
  def create
    @video = Video.new(params[:video])

    respond_to do |format|
      if @video.save
        format.html { redirect_to(@video, :notice => 'Video was successfully created.') }
        format.xml  { render :xml => @video, :status => :created, :location => @video }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /videos/1
  # PUT /videos/1.xml
  def update
    @video = Video.find(params[:id])

    respond_to do |format|
      if @video.update_attributes(params[:video])
        format.html { redirect_to(@video, :notice => 'Video was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.xml
  def destroy
    @video = Video.find(params[:id])
    @video.destroy

    respond_to do |format|
      format.html { redirect_to(videos_url) }
      format.xml  { head :ok }
    end
  end
  
  def unpublish
        domain  = AKAMAI_CONFIG['netstorage_domain']
        cp_code = 115935
        ssh_key = AKAMAI_CONFIG['ssh_key']
         @video = Video.find(params[:id])
    netstorage_hdflash_dir     = File.join("/#{cp_code}/hdflash", @video.path)
    
    Publisher::SSH.rm_rf(ssh_key, domain, netstorage_hdflash_dir)
    
    @video.unpublish!
    redirect_to :back 
  end
end
