require 'mysql/session'
require 'mysql/user'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :loadSession

  @@sessions = {}
  @@users = {}

  def loadSession
    @sessionId = request.session_options[:id]

    if (@session = @@sessions[@sessionId]).nil?
		  puts "Load session"
      @session = MySqlDB::SessionDAO.new.getSessionById(@sessionId)
      if !@session.nil?
        puts "Load user"
        @@sessions[@sessionId] = @session
        @@users[@sessionId] =  MySqlDB::UserDAO.new().getItemById(@session.user)
      end
    end

    if !@session.nil? && @session.status != "active"
      @@sessions.delete(@sessionId)
      @session = nil?
    end
    
    if @session.nil?
      redirect_to "/user/login" unless params[:controller] == "user" if @session.nil? 
    else
      @user = @@users[@sessionId]
      @name = @user.name
      @name[0] = @user.name[0].upcase
    end
  end
end
