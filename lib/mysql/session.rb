require_relative './connection'

module MySqlDB

  class Session
    attr_reader :id, :token, :user, :amateur, :status, :start_time, :end_time, :timestamp

    def initialize(session)
      @id, @token, @user, @amateur, @status, @start_time, @end_time, @timestamp = 
        session[0], session[1], session[2].to_i, session[3].to_i, session[4], session[5].to_i, session[6].to_i, session[7].to_i
    end

    def to_json
      {id: @id, token: @token, user: @user, amateur: @amateur, status: @status, start_time: @start_time, end_time: @end_time, timestamp: @timestamp}.to_json
    end
  end

  class SessionDAO < ItemDAO
    # Excluded: [ '",;\]
    @@characters = ([33] | (35..38).to_a | (40..43).to_a | (45..58).to_a | (60..91).to_a | (93..126).to_a).map{|i| i.chr}

    def self.randomString(num)
      (0...num).map{ @@characters[rand(@@characters.length)] }.join
    end

    def initialize
      super("select id, token, user, amateur, status, UNIX_TIMESTAMP(start_time), UNIX_TIMESTAMP(end_time), UNIX_TIMESTAMP(timestamp) from session where ")
    end

    def createItem(session)
      Session.new(session)
    end

    def getSessionByToken(token)
      return nil if (token =~ /['" ;,]/)
      getItem("token='#{token}'")
    end

    def newSession(user, persistent)
      days = (persistent) ? 365 : 1
      id = SessionDAO.randomString(32)
      while (true) do
        token = SessionDAO.randomString(64)
        return getSessionByToken(token) if write("INSERT IGNORE into session (id, token, user, start_time, end_time) 
                                                 VALUE ('#{id}', '#{token}', #{user}, NOW(), ADDDATE(NOW(), INTERVAL #{days} DAY))") > 0
      end
    end

    def verifyToken(token, id, user)
      return false if token.nil? || id.nil? || user.nil?
      session = getSessionByToken(token)
      return false if session.nil?
    end

    def updateSession(token)
      id = SessionDAO.randomString(32)
      write("update session set id = '#{id}' where token = '#{token}'")
      return id
    end

    def closeSession(token)
      write("update session set status='closed', end_time=now() where token='#{token}'")
    end

    def expireSession(token)
      write("update session set status='expired', end_time=now() where token='#{token}'") 
    end

    def invalidSession(token)
      write("update session set status='invalid', end_time=now() where token='#{token}'") 
    end

    def setSessionAmateur(token, amateur)
      write("update session set amateur=#{amateur} where token='#{token}'")
    end
  end
end
