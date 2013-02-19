require 'spec_helper'

describe MySqlDB::QuestionType do
  def verifyQuestionType(type)
    type.should be_an_instance_of MySqlDB::QuestionType
    type.id.should be 1
    type.type.should eq 'WORD_PICTURE_4_1'
  end

	it "Read a question type from question_type table by id" do
    verifyQuestionType(MySqlDB::QuestionType.getQuestionTypeById(1))
	end

	it "Read a question type from question_type table by type" do
    verifyQuestionType(MySqlDB::QuestionType.getQuestionTypeByType('WORD_PICTURE_4_1'))
	end
end
