require "mysql/user"
require "mysql/amateur"
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
          setUserCookie(user)
        end
      end
      render json: retVal, formats: [:json]
    end
  end

  def register
    @msg = flash[:msg]

    if request.method == 'POST'
      retVal = {}
      userDao = MySqlDB::UserDAO.new

      name, email, password, password2 = params[:name], params[:email], params[:password], params[:password2]

      if name.nil? || name.length < 3
        retVal = {errorMsg: "User name too short"}
      elsif email.nil? || email.length < 3
        retVal = {errorMsg: "Email too short"}
      elsif password != password2
        retVal = {errorMsg: "Password do not match"}
      else
        user = userDao.getUserByName(name)

        if !user.nil?
          retVal = {errorMsg: "User already exists"}
        else
          user = userDao.getUserByEmail(email)
          if !user.nil?
            retVal = {errorMsg: "Email address has been used"}
          else
            userDao.addUser(name, email, password)
            user = userDao.getUserByName(params[:name])
            setUserCookie(user)
          end
        end
      end 
      
      render json: retVal, formats: [:json]
    end
  end

  def setUserCookie(user)
     session = MySqlDB::SessionDAO.new().newSession(user.id, true)
     cookies[:u_token] = { :value => session.token, :expires => 1.year.from_now }
     cookies[:u_series] = { :value => session.id, :expires => 1.year.from_now }
     cookies[:user] = { :value => session.user, :expires => 1.year.from_now }

     @@sessions[session.token] = session
     amateur = MySqlDB::UserAmateur.new(session.user)
     @@users[session.user] = amateur
  end

  def logout
    token, user = cookies[:u_token], cookies[:user]
    MySqlDB::SessionDAO.new.closeSession(token)
    @@sessions.delete(token)
    @@users.delete(user)
		redirect_to "/user/login", flash: {msg: "You have been logged out"}
  end
end
