require 'mysql/question'
require 'mysql/word'

class QuestionController < ApplicationController
  def answer
    questionDao = MySqlDB::QuestionDAO.new
    question = questionDao.getItemById(params[:id])
    words = MySqlDB::WordDAO.new.getItems("id in (#{(question.competitor | [question.target]).join(",")})")

    @options = ["", "", "", ""]
    @answer = params[:answer].to_i

    if @answer > 0
      @answerIndex = question.order.index(0)
      @image = (@answerIndex == (@answer-1)) ? "smiley" : "sad"
      @nextQuestionId = question.getNextQuestionId
      @questionSet = question.questionSet
      questionDao.setAnswer(params[:id], @answer) 
    end
   
    words.each do |word|
      if word.id == question.target
        @target = word.word
        @target[0] = @target[0].upcase
        @options[question.order.index(0)] = word.picture
      else
        index2 = question.competitor.index(word.id)
        @options[question.order.index(index2+1)] = word.picture
      end
    end
  end
end
