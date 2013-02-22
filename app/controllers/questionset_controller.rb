require "mysql/questionSet"
require "mysql/questionSetType"
require "mysql/question"

class QuestionsetController < ApplicationController
  def start
    qSetId = MySqlDB::QuestionSetDAO.new.addQuestionSet(@session.id, params[:id].to_i)
    qSetType = MySqlDB::QuestionSetTypeDAO.new.getItemById(params[:id].to_i)
    qIds = MySqlDB::QuestionDAO.new.createQuestions(qSetType, qSetId)

    redirect_to controller: "question", id: qIds[0], action: "answer"
  end
end
