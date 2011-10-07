class DashboardController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /videos
  # GET /videos.xml
  def index
    @title = "Recent Videos"
    @videos = Video.paginate(:per_page => 25, :page => params[:page], :limit => 100).order(:created_at.desc)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
