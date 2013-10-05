require 'mysql/session'
require 'mysql/wordSession'

class LearningController < ApplicationController
  def list
    wordSession = MySqlDB::WordSessionDAO.new
    ws = wordSession.getWordSession(@amateur)
    @game = ["", ""]
    @grade = ["", "", "", "", ""]
    @difficulty = ["", "", ""]
    if !ws.nil?
      @game[ws.game - 1] = " selected"
      @grade[ws.grade] = " selected"
      @difficulty[ws.difficulty] = " selected"
    end
  end
end
