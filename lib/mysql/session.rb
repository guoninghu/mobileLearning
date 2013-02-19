require_relative './connection'
require 'json'

module MySqlDB

  class Session
    attr_reader :id, :user, :status, :start_time, :end_time
	  @@connection = Connection.new

    def initialize(word)
      @id, @user, @status, @start_time, @end_time = word[0], word[1].to_i, word[2], word[3].to_i, word[4].to_i
    end

    def to_json
      return {id: @id, user: @user, status: @status, start_time: @start_time, end_time: @end_time}.to_json
    end

    def self.newSession(sessionId, user)
      @@connection.write("insert into session(id, user, start_time) value('#{sessionId}', #{user}, now()) 
                         on duplicate key update user=#{user}, start_time=now(), status='active', end_time=NULL")
    end

    def self.getSession(condition)
      sessions = getSessions(condition)
      return nil if sessions.nil?
      return sessions[0] if sessions.length > 0
      return nil
    end

    def self.getSessions(condition)
      sessions = @@connection.read("select id, user, status, UNIX_TIMESTAMP(start_time), 
                                   UNIX_TIMESTAMP(end_time) from session where " + condition)
			return nil if sessions.nil?

      ret_val = []
			sessions.each { |session| ret_val << Session.new(session) }
      return ret_val
		end

		def self.getSessionById(id)
			return getSession("id='#{id}'")
		end

		def self.getUserSessions(user, skip, limit)
			return getQuestions("user='#{user}' order by start_time limit #{skip}, #{limit}")
		end

    def self.closeSession(sessionId)
      @@connection.write("update session set status='closed', end_time=now() where id='#{sessionId}'")
    end

    def self.expireSession(sessionId)
      @@connection.write("update session set status='expired', end_time=now() where id='#{sessionId}'") 
    end
  end
end
