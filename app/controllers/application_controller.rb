class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_menu
  
  def set_menu
  end
end
