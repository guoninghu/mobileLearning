require 'spec_helper'

describe MySqlDB::QuestionSetTypeDAO do
  def verifyQuestionSetType(type, id, name, questions)
    type.should be_an_instance_of MySqlDB::QuestionSetType
    type.id.should be id
    type.name.should eq name
    type.questions.should eq questions
  end

  before do
    @qSetTypeDao = MySqlDB::QuestionSetTypeDAO.new
  end

	it "Read a question type from question_type table by id" do
    verifyQuestionSetType(@qSetTypeDao.getItemById(1), 1, "WORD_PICTURE_4_1", {"WORD_PICTURE_4_1" => 10})
	end

	it "Read a question type from question_type table by name" do
    verifyQuestionSetType(@qSetTypeDao.getItemByName('WORD_PICTURE_4_1'),  1, "WORD_PICTURE_4_1", {"WORD_PICTURE_4_1" => 10})
	end
end
