require 'mysql/wordResult'
require 'json'

class AchievementController < ApplicationController
  def list
    @grades = ["Kindergarten", "1st Grade", "2nd Grade", "3rd Grade", "4th Grade"]
    wr = MySqlDB::WordResultDAO.new
    @results = wr.getPoints(@amateur)

    puts @results.to_json
    0.upto(4) do |n|
      if @results[3][n].nil?
        @results[3][n] = "You have achieved the highest level"
      elsif @results[3][n] == 1
        @results[3][n] = "You need 1 more point to reach the next level"
      else
        @results[3][n] = "You need #{@results[3][n]} more points to reach the next level"
      end
    end
  end
end
