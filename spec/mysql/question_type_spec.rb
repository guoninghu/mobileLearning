require 'spec_helper'

describe MySqlDB::QuestionTypeDAO do
  def verifyQuestionType(type, id, name, question, answer)
    type.should be_an_instance_of MySqlDB::QuestionType
    type.id.should be id
    type.name.should eq name
    type.question.should eq question
    type.answer.should eq answer
  end

  before do
    @qTypeDao = MySqlDB::QuestionTypeDAO.new
  end

	it "Read a question type from question_type table by id" do
    verifyQuestionType(@qTypeDao.getItemById(1), 1, "WORD_PICTURE", 2, 1)
	end

	it "Read a question type from question_type table by name" do
    verifyQuestionType(@qTypeDao.getItemByName('WORD_PICTURE'), 1, "WORD_PICTURE", 2, 1)
	end
end
