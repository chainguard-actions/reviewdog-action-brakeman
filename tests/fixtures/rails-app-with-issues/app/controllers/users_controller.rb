class UsersController < ApplicationController
  def index
    # SQL injection vulnerability - brakeman should detect this
    @users = User.where("name = '#{params[:name]}'")
    render plain: @users.to_s
  end
end
