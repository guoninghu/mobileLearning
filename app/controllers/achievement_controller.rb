require 'mysql/wordResult'
require 'json'

class AchievementController < ApplicationController
  def list
    @grades = ["Kindergarten", "1st Grade", "2nd Grade", "3rd Grade"]
    wr = MySqlDB::WordResultDAO.new
    @results = wr.getPoints(@amateur)

    0.upto(3) do |n|
      @results[3][n] = (@results[3][n].nil?) ? "You have achieved the highest level" :
        "You need #{@results[3][n]} more points to reach the next level"
    end
  end
end
