require 'spec_helper'

describe MySqlDB::QuestionTypeDAO do
  def verifyQuestionType(type, id, name, targetQ, targetA, competitors)
    type.should be_an_instance_of MySqlDB::QuestionType
    type.id.should be id
    type.name.should eq name
    type.target["Answer"].should eq targetA
    type.target["Question"].should eq targetQ
    type.competitor.should =~ competitors
  end

  before do
    @qTypeDao = MySqlDB::QuestionTypeDAO.new
  end

	it "Read a question type from question_type table by id" do
    verifyQuestionType(@qTypeDao.getItemById(1), 1, "WORD_PICTURE_4_1", 2, 1, [1, 1, 1])
    verifyQuestionType(@qTypeDao.getItemById(2), 2, "WORD_PICTURE_2_1", 2, 1, [1])
	end

	it "Read a question type from question_type table by name" do
    verifyQuestionType(@qTypeDao.getItemByName('WORD_PICTURE_4_1'),  1, "WORD_PICTURE_4_1", 2, 1, [1, 1, 1] )
	end
end
