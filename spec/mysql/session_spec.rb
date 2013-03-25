require 'spec_helper'

describe MySqlDB::SessionDAO do
  def verifySession(session, id, token, user, status, persistent)
    session.should be_an_instance_of MySqlDB::Session
    session.token.should eq token
    session.id.should eq id
		session.user.should be user
    session.status.should eq status
		if persistent
			session.end_time.should be > session.start_time + 86400 * 300
		else
			session.end_time.should be < session.start_time + 100000
  	end
	end

  before do
    @sessionDao = MySqlDB::SessionDAO.new
		session = @sessionDao.newSession(1, false)
		@token, @id = session.token, session.id
  end

	it "Create a persistent session" do
	  session = @sessionDao.newSession(1, true)
		verifySession(session, session.id, session.token, 1, 'active', true)
	end

  it "Get an existing sessin" do
	  session = @sessionDao.getSessionByToken(@token)
		verifySession(session, @id, @token, 1, 'active', false) 
	end

	it "Update an existing session" do
	  id = @sessionDao.updateSession(@token)
		id.should_not eq @id
		@id = id
		session = @sessionDao.getSessionByToken(@token)
		verifySession(session, @id, @token, 1, 'active', false)
	end

  it "Close a session" do
    @sessionDao.closeSession(@token).should be 1
    
    session = @sessionDao.getSessionByToken(@token)
    verifySession(session, @id, @token, 1, 'closed', false)
	end

	it "Expire a session" do
    @sessionDao.expireSession(@token).should be 1
    
    session = @sessionDao.getSessionByToken(@token)
    verifySession(session, @id, @token, 1, 'expired', false)
	end
end
