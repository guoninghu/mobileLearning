require_relative './connection'
require 'bcrypt'

module MySqlDB

  class User
	  attr_reader :id, :name, :email, :timestamp

		def initialize(user)
			@id, @name, @email, @password, @timestamp =
				user[0].to_i, user[1], user[2], user[3], user[4]
		end

		def to_json
			{id: @id, name: @name, email: @email, timestamp: @timestamp}.to_json
		end

    def passwordMatch(password)
      BCrypt::Password.new(@password) == password
    end
  end

  class UserDAO < ItemDAO
    def initialize
      super("select id, username, email, password, timestamp from user where ")
    end

    def createItem(user)
      User.new(user)
    end

    def addUser(name, email, password)
      my_password = BCrypt::Password.create(password)
      insert("insert ignore into user (username, email, password) value ('#{name}', '#{email}', '#{my_password}')")
    end
		
    def getUserByName(name)
			getItem("username='#{name}'")
		end
    
    def getUserByEmail(email)
			getItem("email='#{email}'")
		end
	end

end
