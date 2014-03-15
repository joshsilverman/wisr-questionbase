class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, :except => [:home]

  def after_sign_up_path_for resource
    books_path
  end

  def after_sign_in_path_for resource
    books_path
  end
end
