require "mysql/user"
require "mysql/amateur"

class AmateurController < ApplicationController
  def getNames
    @names = @user.names.keys.sort
    @nameHash = @user.names
  end

  def select
    getNames
  end

  def edit
    getNames
  end

  def delete
    puts params["amateur"]
    params[:amateur].each do |name|
      @user.deleteAmateur(name)
    end

    redirect_to "/amateur/edit"
  end

  def add
    name = params[:new_amateur]
    @user.addAmateur(name.strip) if name.strip.size > 0
    redirect_to "/amateur/edit"
  end
end
