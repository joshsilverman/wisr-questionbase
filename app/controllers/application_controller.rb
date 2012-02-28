class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  protected

    def login_required
      authenticate_user!
    end

    # def current_user
    #   session[:user]
    # end
end
