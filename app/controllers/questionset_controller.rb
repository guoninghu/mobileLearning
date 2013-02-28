require "mysql/questionSet"
require "mysql/questionSetType"
require "mysql/question"
require 'mysql/word'

class QuestionsetController < ApplicationController
  def ask
    @image = ["smiley", "sad"]
  end

  def start
    qSetId = MySqlDB::QuestionSetDAO.new.addQuestionSet(@session.id, params[:id].to_i)
    qSetType = MySqlDB::QuestionSetTypeDAO.new.getItemById(params[:id].to_i)
    questionSet = MySqlDB::QuestionDAO.new.createQuestions(qSetType, qSetId)

    render json: questionSet, formats: [:json]
  end

  def summary
    questions = MySqlDB::QuestionDAO.new.getQuestionsBySet(params[:id].to_i)
    @totalQuestions = questions.length
    @totalPoints = 0

    wordIds = []
    questions.each {|question| wordIds << question.target }

		words = {}
    MySqlDB::WordDAO.new.read("select word, id from word where id in(#{wordIds.join(",")})").each do |val| 
      val[0][0] = val[0][0].upcase
      words[val[1].to_i] = val[0]
    end

    @scores = []
		@words = []
    questions.each do |question|
      @words << words[question.target]
			if (question.order.index(0) + 1) == question.answer
        @scores << "correct"
        @totalPoints += 1
      else
        @scores << "wrong"
      end
    end
  end
end
