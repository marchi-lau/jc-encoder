class DashboardController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /videos
  # GET /videos.xml
  def index
    @videos = Video.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @videos }
    end
  end
end
