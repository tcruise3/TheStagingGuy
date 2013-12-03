class MainController < ActionController::Base
  def View
    Facebook.GetPosts
  end
end