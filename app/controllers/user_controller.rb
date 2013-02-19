require "mysql/user"
require "mysql/session"

class UserController < ApplicationController
  def login
    @msg = flash[:msg]
    if request.method == 'POST'
      user = MySqlDB::User.getUserByName(params[:name])
      if user.nil?
        @msg = "User does not exist"
      else
        if user.password != params[:password]
          @msg = "Invalid password"
        else
          MySqlDB::Session.newSession(request.session_options[:id], user.id)
          redirect_to controller: "learning", action: "list"
        end
      end
    end
  end

  def register
  end

  def logout
    MySqlDB::Session.expireSession(request.session_options[:id])
    redirect_to "/user/login", flash: {msg: "You have been logged out"}
  end
end
