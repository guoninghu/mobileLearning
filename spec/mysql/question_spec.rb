require 'spec_helper'

describe MySqlDB::QuestionDAO do
  def verifyQuestion(question, id, questionSet, target, competitor, order, answer)
    question.should be_an_instance_of MySqlDB::Question
    question.id.should be id
    question.questionSet.should be questionSet
    question.target.should be target
    question.competitor.should eq competitor
    question.order.should eq order
    question.answer.should eq answer
  end

  before do
    @questionDao = MySqlDB::QuestionDAO.new
		@questionDao.write("delete from question where question_set = 1")  
  end

  it "Insert a question to question table" do
    id = @questionDao.addQuestion(1, 1, [2, 3, 4], [3, 1, 2, 0], 1)
    verifyQuestion(@questionDao.getItemById(id), id, 1, 1, [2, 3, 4], [3, 1, 2, 0], 0)
    
    @questionDao.setAnswer(id, 2)
    verifyQuestion(@questionDao.getItemById(id), id, 1, 1, [2, 3, 4], [3, 1, 2, 0], 2)
    
    @questionDao.getQuestionsBySet(1).length.should be 1
  end
  
  after do
    @questionDao.write("delete from question where question_set = 1")
    @questionDao.write("alter table question auto_increment=1")
  end
end
