class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :login_required

  protected

    def login_required
      authenticate_user!
    end
end
