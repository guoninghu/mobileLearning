require 'spec_helper'

describe MySqlDB::QuestionSetTypeDAO do
  def verifyQuestionSetType(type, id, questionType, numTargets, numCompetitors)
    type.should be_an_instance_of MySqlDB::QuestionSetType
    type.id.should be id
    type.questionType.should be questionType
    type.numTargets.should be numTargets
    type.numCompetitors.should be numCompetitors
  end

  before do
    @qSetTypeDao = MySqlDB::QuestionSetTypeDAO.new
  end

	it "Read a question type from question_type table by id" do
    verifyQuestionSetType(@qSetTypeDao.getItemById(1), 1, 1, 10, 3)
    verifyQuestionSetType(@qSetTypeDao.getItemById(3), 3, 1, 10, 1)
  end
end
