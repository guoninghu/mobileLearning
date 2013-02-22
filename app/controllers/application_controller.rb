require 'mysql/session'
require 'mysql/user'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :loadSession

  def loadSession
    @session = MySqlDB::SessionDAO.new.getSessionById(request.session_options[:id])
    if @session.nil? || @session.status != "active"
      redirect_to "/user/login" unless params[:controller] == "user"
    else
      @user = MySqlDB::UserDAO.new().getItemById(@session.user)
      @name = @user.name
      @name[0] = @user.name[0].upcase
    end
  end
end
