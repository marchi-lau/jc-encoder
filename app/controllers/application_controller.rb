class ApplicationController < ActionController::Base
  protect_from_forgery
    layout :specify_layout 
    protected 
    def specify_layout 
      devise_controller? ? "devise" : "application" 
    end 
end
