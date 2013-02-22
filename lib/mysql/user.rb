require_relative './connection'
require 'json'

module MySqlDB

  class User
	  attr_reader :id, :name, :email, :password, :timestamp

		def initialize(user)
			@id, @name, @email, @password, @timestamp =
				user[0].to_i, user[1], user[2], user[3], user[4]
		end

		def to_json
			{id: @id, name: @name, email: @email, password: @password, timestamp: @timestamp}.to_json
		end
  end

  class UserDAO < ItemDAO
    def initialize
      super("select id, username, email, password, timestamp from user where ")
    end

    def createItem(user)
      User.new(user)
    end
		
    def getUserByName(name)
			getItem("username='#{name}'")
		end
    
    def getUserByEmail(email)
			getItem("email='#{email}'")
		end
	end

end
