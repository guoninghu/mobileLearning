require "mysql/user"
require "mysql/session"

class UserController < ApplicationController
  def login
    @msg = flash[:msg]
    if request.method == 'POST'
      retVal = {}
      user = MySqlDB::UserDAO.new().getUserByName(params[:name])
      if user.nil?
        retVal = {errorMsg: "User does not exist"}
      else
        if !user.passwordMatch(params[:password])
          retVal = {errorMsg: "Invalid password"}
        else
          MySqlDB::SessionDAO.new().newSession(@sessionId, user.id)
        end
      end
      render json: retVal, formats: [:json]
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
