require 'spec_helper'

describe MySqlDB::Session do
  def verifySession(session, id, user, status, start_time, end_time)
    session.should be_an_instance_of MySqlDB::Session
    session.id.should eq id
    session.user.should be user
    session.status.should eq status
    session.start_time.should >= start_time
    session.end_time.should <= end_time
  end

  it "Create a new session" do
    MySqlDB::Session.newSession("1", 1).should > 0
    timeNow = Date.new().to_time.to_i
    verifySession(MySqlDB::Session.getSessionById("1"), "1", 1, 'active', timeNow, 0) 
  end
	
  it "Close a session" do
    MySqlDB::Session.newSession("1", 1)
    timeNow = Time.now.to_i
    MySqlDB::Session.closeSession("1").should be 1
    
    session = MySqlDB::Session.getSessionById("1")
    verifySession(session, "1", 1, 'closed', session.start_time, timeNow) 
	end

	it "Expire a session" do
    MySqlDB::Session.newSession("1", 1)
    timeNow = Time.now.to_i
    MySqlDB::Session.expireSession("1").should be 1
    
    session = MySqlDB::Session.getSessionById("1")
    verifySession(session, "1", 1, 'expired', session.start_time, timeNow) 
	end

end
