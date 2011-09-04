class DashboardController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /videos
  # GET /videos.xml
  def index
    @title = "Recent Videos"
    
    @videos = Video.paginate(:per_page => 25, :page => params[:page]).where(:created_at.gt => 2.weeks.ago)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @videos }
    end
  end
end
