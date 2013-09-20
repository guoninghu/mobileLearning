require 'mysql/question'
require 'mysql/word'
require 'mysql/wordResult'

class QuestionController < ApplicationController
  def answer
    questionDao = MySqlDB::QuestionDAO.new
    wordDao = MySqlDB::WordResultDAO.new
    question = questionDao.getItemById(params[:id])
    @answer = params[:answer].to_i
    @answerIndex = question.order.index(0)
    
    questionDao.setAnswer(params[:id], @answer)
    wordDao.update(question.target, @amateur, (@answerIndex==(@answer-1)))
    
    render json: { answer: @answerIndex+1, correct: (@answerIndex==(@answer-1)) }, formats: [:json]
  end
end
