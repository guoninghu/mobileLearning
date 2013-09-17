require "mysql/questionSet"
require "mysql/questionSetType"
require "mysql/question"
require 'mysql/word'

class QuestionsetController < ApplicationController
  def ask
    @image = ["congratulate2.gif", "sad.jpg"]
    @colClass = ["a", "b", "c"]

    if request.method == 'POST'
      if params[:game] == "1"
        if params[:difficulty] == "2"
          @id = 1
        elsif params[:difficulty] == "0"
          @id = 2
        else
          @id = 3
        end
      else
        if params[:difficulty] == "2"
          @id = 4
        elsif params[:difficulty] == "0"
          @id = 5
        else
          @id = 6
        end
      end
    else
      @id = params[:id]
    end
    
    qSetType = MySqlDB::QuestionSetTypeDAO.new.getItemById(@id)
    
    if qSetType.numCompetitors == 3
      @rows, @cols, @items = 2, 2, 4
      @rowClass = "b"
    elsif qSetType.numCompetitors == 1
      @rows, @cols, @items = 2, 1, 2
      @rowClass = "b"
    elsif qSetType.numCompetitors == 2
      @rows, @cols, @items = 2, 2, 3
      @rowClass = "b"
    end
  end

  def start
    qSetDao = MySqlDB::QuestionSetDAO.new
    typeId = params[:id].to_i
    grade = params[:grade].to_i

    qSetId = qSetDao.addQuestionSet(@session.id, @amateur, grade, typeId)
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
