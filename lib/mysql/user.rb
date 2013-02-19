require_relative './connection'
require 'json'

module MySqlDB

  class User
	  attr_reader :id, :name, :email, :password, :timestamp
		@@connection = Connection.new

		def initialize(user)
			@id, @name, @email, @password, @timestamp =
				user[0].to_i, user[1], user[2], user[3], user[4]
		end

		def to_json
			return {id: @id, name: @name, email: @email, password: @password, timestamp: @timestamp}.to_json
		end
		
		def self.getUser(condition)
			users = @@connection.read("select id, username, email, password, timestamp from user where " + condition)
			return nil if users.nil?
			return nil if users.length == 0 
			return User.new(users[0])
		end
		
		def self.getUserById(id)
			return getUser("id = " + id.to_s)
		end

		def self.getUserByName(username)
			return getUser("username = '#{username}'")
		end
		
    def self.getUserByEmail(email)
			return getUser("email = '#{email}'")
		end
	end

end
