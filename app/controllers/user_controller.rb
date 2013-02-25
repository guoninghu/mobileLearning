require "mysql/user"
require "mysql/session"

class UserController < ApplicationController
  def login
    @msg = flash[:msg]
    if request.method == 'POST'
      user = MySqlDB::UserDAO.new().getUserByName(params[:name])
      if user.nil?
        @msg = "User does not exist"
      else
        if !user.passwordMatch(params[:password])
          @msg = "Invalid password"
        else
          MySqlDB::SessionDAO.new().newSession(@sessionId, user.id)
          redirect_to controller: "learning", action: "list"
        end
      end
    end
  end

  def register
  end

  def logout
    MySqlDB::SessionDAO.new().closeSession(@sessionId)
    @@sessions.delete(@sessionId)
    reset_session
		redirect_to "/user/login", flash: {msg: "You have been logged out"}
  end
end
