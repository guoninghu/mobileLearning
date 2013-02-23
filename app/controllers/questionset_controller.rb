require "mysql/questionSet"
require "mysql/questionSetType"
require "mysql/question"
require 'mysql/word'

class QuestionsetController < ApplicationController
  def start
    qSetId = MySqlDB::QuestionSetDAO.new.addQuestionSet(@session.id, params[:id].to_i)
    qSetType = MySqlDB::QuestionSetTypeDAO.new.getItemById(params[:id].to_i)
    qIds = MySqlDB::QuestionDAO.new.createQuestions(qSetType, qSetId)

    redirect_to controller: "question", id: qIds[0], action: "answer"
  end

  def summary
    questions = MySqlDB::QuestionDAO.new.getQuestionsBySet(params[:id].to_i)
    @totalQuestions = questions.length
    @totalPoints = 0

    wordIds = []
    @scores = []
    questions.each do |question|
      wordIds << question.target
      if (question.order.index(0) + 1) == question.answer
        @scores << "correct"
        @totalPoints += 1
      else
        @scores << "wrong"
      end
    end

    @words = []
    MySqlDB::WordDAO.new.read("select word from word where id in(#{wordIds.join(",")})").each do |val| 
      val[0][0] = val[0][0].upcase
      @words << val[0]
    end
  end
end
