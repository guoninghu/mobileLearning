require 'mysql/session'
require 'mysql/user'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :loadSession

  def loadSession
    @session = MySqlDB::Session.getSessionById(request.session_options[:id])
    if @session.nil? || @session.status != "active"
      redirect_to "/user/login" unless params[:controller] == "user"
    else
      @user = MySqlDB::User.getUserById(@session.user)
    end
  end
end
