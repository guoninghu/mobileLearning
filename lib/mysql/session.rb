require_relative './connection'

module MySqlDB

  class Session
    attr_reader :id, :user, :status, :start_time, :end_time

    def initialize(session)
      @id, @user, @status, @start_time, @end_time = session[0], session[1].to_i, session[2], session[3].to_i, session[4].to_i
    end

    def to_json
      {id: @id, user: @user, status: @status, start_time: @start_time, end_time: @end_time}.to_json
    end
  end

  class SessionDAO < ItemDAO
    def initialize
      super("select id, user, status, UNIX_TIMESTAMP(start_time), UNIX_TIMESTAMP(end_time) from session where ")
    end

    def createItem(session)
      Session.new(session)
    end

    def getSessionById(id)
      getItem("id='#{id}'")
    end

    def newSession(sessionId, user)
      write("insert into session(id, user, start_time) value('#{sessionId}', #{user}, now()) 
            on duplicate key update user=#{user}, start_time=now(), status='active', end_time=NULL")
    end

		def getUserSessions(user, skip, limit)
			getItems("user='#{user}' order by start_time limit #{skip}, #{limit}")
		end

    def closeSession(sessionId)
      write("update session set status='closed', end_time=now() where id='#{sessionId}'")
    end

    def expireSession(sessionId)
      write("update session set status='expired', end_time=now() where id='#{sessionId}'") 
    end
  end
end
