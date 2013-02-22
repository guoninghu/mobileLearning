require 'spec_helper'

describe MySqlDB::QuestionSetDAO do
  def verifyQuestionSet(qSet, id, session, type)
    qSet.should be_an_instance_of MySqlDB::QuestionSet
    qSet.id.should be id
    qSet.session.should eq session
    qSet.type.should be type
  end

  before do
    @qSetDao = MySqlDB::QuestionSetDAO.new
  end

  it "Insert a question set to question_set table" do 
    id = @qSetDao.addQuestionSet("1", 1)
    verifyQuestionSet(@qSetDao.getItemById(id), id, "1", 1)
    @qSetDao.getQuestionSetsBySession("1").length > 0
  end

  after do
    @qSetDao.write("delete from question_set where session = 1 and id > 1")
    @qSetDao.write("alter table question_set auto_increment=1")
  end
end
