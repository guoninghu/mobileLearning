require "mysql/questionSet"
require "mysql/questionSetType"
require "mysql/question"
require 'mysql/word'

class QuestionsetController < ApplicationController
  def ask
    @image = ["smiley", "sad"]
    @colClass = ["a", "b", "c"]
    qSetType = MySqlDB::QuestionSetTypeDAO.new.getItemById(params[:id].to_i)
    
    if qSetType.numCompetitors == 3
      @rows, @cols = 2, 2
      @rowClass = "b"
    elsif qSetType.numCompetitors == 1
      @rows, @cols = 2, 1
      @rowClass = "b"
    elsif qSetType.numCompetitors == 2
      @rows, @cols = 3, 1
      @rowClass = "c"
    end
  end

  def start
    qSetDao = MySqlDB::QuestionSetDAO.new
    typeId = params[:id].to_i
    grade = params[:grade].to_i

    qSetId = qSetDao.addQuestionSet(@session.id, @user.id, grade, typeId)
    questionSet = qSetDao.createQuestions(typeId, grade, qSetId)

    render json: questionSet, formats: [:json]
  end

  def summary
    questionSet = MySqlDB::QuestionSetDAO.new.getItemById(params[:id].to_i)
    @qSetType = questionSet.type
    @grade = questionSet.grade
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
