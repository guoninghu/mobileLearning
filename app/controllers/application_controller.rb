require 'mysql/session'
require 'mysql/amateur'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :loadSession

  @@sessions = {}
  @@users = {}
  @@sessionDao = MySqlDB::SessionDAO.new

  def loadSession
    @session = verifySession

    if @session.nil?
      redirect_to "/user/login" unless params[:controller] == "user"
    else
      getAmateur
    end
  end
  
  def verifySession
    return nil if (token = cookies[:u_token]).nil?
    @msg = nil

    session = (@@sessions[token].nil?) ? @@sessionDao.getSessionByToken(token) : @@sessions[token]
    return nil if session.nil?

    if session.id != cookies[:u_series] || session.user != cookies[:user].to_i
      @msg = "Mismatch with stored authentication token"
      sessionDao.invalidSession(token)
      session = nil
    elsif session.status != 'active'
      session = nil
    elsif session.end_time < Time.now.to_i
      sessionDao.expireSession(token)
      session = nil
    end

    if !session.nil?
      @user = (@@users[session.user].nil?) ? MySqlDB::UserAmateur.new(session.user) : @@users[session.user]
      if @user.nil?
        sessionDao.expireSession(token)
        session = nil
      else
        @@users[session.user] = @user
      end
    end

    if session.nil?
      @@sessions.delete(token)
    else
      @@sessions[token] = session
    end
    
    return session
  end

  def getAmateur
    amateur = (params[:amateur].nil?) ? @session.amateur : params[:amateur].to_i
    @name = @user.getCurrentAmateur(amateur)
    @amateur = @user.names[@name]
     
    if (@amateur != @session.amateur)
      @@sessionDao.setSessionAmateur(@session.token, @amateur)
      @session = @@sessionDao.getSessionByToken(@session.token)
      @@sessions[session.token] = @session
    end
  end
end
