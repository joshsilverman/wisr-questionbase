class StaticController < ApplicationController
  before_filter :login_required
  
  def home
    puts current_user.to_json
    if current_user
        redirect_to :action => "index", :controller => "books"
    end
  end
end
