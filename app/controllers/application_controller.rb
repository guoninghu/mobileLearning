require 'mysql/session'
require 'mysql/amateur'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :loadSession

  @@sessions = {}
  @@users = {}

  def loadSession
    token = cookies[:u_token]
    session, msg = nil, nil
    sessionDao = MySqlDB::SessionDAO.new

    if !token.nil?
      session = @@sessions[token]
      session = sessionDao.getSessionByToken(token) if session.nil?

      if !session.nil?
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
      end

      if session.nil?
        @@sessions.delete(token)
      else
        @@sessions[token] = session
      end
    end

    if !session.nil?
      @user = @@users[session.user]
      @user = MySqlDB::UserAmateur.new(session.user) if @user.nil?

      if @user.nil?
        sessionDao.expireSession(token)
        session = nil
        @@session.delete(token)
      else
        if !params[:amateur].nil?
          sessionDao.setSessionAmateur(token, params[:amateur])
           session = sessionDao.getSessionByToken(token)
           @@sessions[token] = session
        end
        @@users[session.user] = @user
        @name = @user.getCurrentAmateur(session.amateur)
        if @name.nil?
          sessionDao.expireSession(token)
          session = nil
          @@session.delete(token)
        end
      end
    end

    if session.nil?
      redirect_to "/user/login" unless params[:controller] == "user" if session.nil?
    end
  end
end
