class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

    def login_required
      authenticate_user!
    end
end
