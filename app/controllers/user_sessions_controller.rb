class UserSessionsController < ApplicationController
  before_filter :authenticate_user!, :only => :destroy

  respond_to :html

  # Omniauth callback method
  def create
    session[:user] = User.from_omniauth(request.env['omniauth.auth'])

    flash[:notice] = "Successfully logged in"
    redirect_to root_path
  end

  # Omniauth failure callback
  def failure
    flash[:notice] = params[:message]
    redirect_to root_path
  end

  # logout - Clear our rack session BUT essentially redirect to the provider
  # to clean up the Devise session from there too !
end
