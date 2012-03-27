require 'authorization.rb'

class ApplicationController < ActionController::Base
  include Authorization::ControllerMixin
  protect_from_forgery
  before_filter CASClient::Frameworks::Rails::Filter
  helper_method :current_user, :logged_in?, :admin_panel_auth
  
  # Stores a location to return to later (especially after login via CAS).
  # If not given a parameter, it defaults to the current request URI.
  def store_location(return_to = nil)
    session[:return_to] = return_to || request.fullpath #request.request_uri
  end

  # Redirects the user to the previously-stored location, or, if none
  # can be found, some fallback URL.
  def redirect_back_or_default(default)
    redirect_to session[:return_to] || default
    session[:return_to] = nil
  end

  # Returns the currently logged in User.
  def current_user
      if session[:cas_user]
		@current_user = User.where(:userid => session[:cas_user]).first
		if !@current_user
			false
		end
		@current_user
	  end
  end

  # Returns the roles of the current user
  def current_user_roles
    if !current_user.roles.empty?
      true
    else
      false
    end
  end

  # Checks to see if the current user has authorization to use the admin panel.
  # Basically, if they're not a student and have another role the user has permission.
  def admin_panel_auth
    cu = current_user
    cu && (cu.roles.include?(Role.find_by_name('Admin')) || cu.roles.include?(Role.find_by_name('Manager')) || authorization_denied) ? true : access_denied
  end

  # Returns a boolean indicating whether the client is an authenticated user.
  def logged_in?
	if session[:cas_user]
		return false unless User.where(:userid => session[:cas_user]).count > 0
		return true
	end
  end

  # Redirects the user to log in or register an account unless the user is
  # already logged in.
  def login_required
    logged_in? || access_denied
  end

  # Stores the current location and redirects the user to either a login
  # page or an account creation page, as appropriate.
  def access_denied
    store_location
    if session[:cas_user]
      redirect_to new_user_path
    else
      redirect_to :login
    end
  end
  
  # Makes the search method to be used when searching a model
  def make_search_method
  	dates = ["date","created_at","updated_at"]
  	matches = ["name","id","trip_id","destination_id"]

  	method = ""
  	
  	dates.each do |d|
  		if params[d]
  			date1 = Date.new(params[d]["1(1i)"].to_i,params[d]["1(2i)"].to_i,params[d]["1(3i)"].to_i)
  			date2 = Date.new(params[d]["2(1i)"].to_i,params[d]["2(2i)"].to_i,params[d]["2(3i)"].to_i)
  		
  			method << d + ' >= date(\'' + date1.to_s + '\') and ' + d + ' <= date(\'' + date2.to_s + '\')'
  		end
  	end

    matches.each do |m|
      if params[m]
        method << m + ' = \'' + params[m] + '\''
      end
    end
  	
  	method
    end
end
