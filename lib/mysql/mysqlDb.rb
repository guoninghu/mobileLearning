require 'mysql'
require 'json'

module MySqlDB
  
  class Connection

		def initialize
			@config = JSON.parse(IO.read("../assets/mysql/mysql.js"))
		end

		def getConnection
			Mysql.real_connect(@config["host"], @config["user"], @config["passwd"], @config["dbName"], @config["port"])
		end

		def read(query)
			begin
				ret_val = []
				conn = getConnection
				conn.query(query).each { |row| ret_val << row }
				
				return ret_val

			rescue Mysql::Error => e
			  puts e
        puts e.backtrace
				return nil
			ensure
			  conn.close if conn
			end
		end

    def write(query)
      begin
        conn = getConnection
        conn.query(query)
        return conn.affected_rows

			rescue Mysql::Error => e
			  puts e
        puts e.backtrace
				return nil
			ensure
			  conn.close if conn
			end
		end
      
	end

  class User
	  attr_reader :id, :username, :email, :password, :timestamp
		@@connection = Connection.new

		def initialize(user)
			@id, @username, @email, @password, @timestamp =
				user[0], user[1], user[2], user[3], user[4]
		end

		def to_json
			return {id: @id, username: @username, email: @email, password: @password, timestamp: @timestamp}.to_json
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

  class Word
    attr_reader :id, :word, :picture, :timestamp
	  @@connection = Connection.new

    def initialize(word)
      @id, @word, @picture, @timestamp = word[0], word[1], word[2], word[3]
    end

    def to_json
      return {id: @id, word: @word, picture: @picture, timestamp: @timestamp}.to_json
    end

    def self.getWord(condition)
			words = @@connection.read("select id, word, picture, timestamp from word where " + condition)
			return nil if words.nil?
			return nil if words.length == 0 
			return Word.new(words[0])
		end

		def self.getWordById(id)
			return getWord("id = " + id.to_s)
		end

		def self.getWordByText(word)
			return getWord("word = '#{word}'")
		end

    def self.addWord(word, picture)
      return true if getWordByText(word)
      return @@connection.write("insert into word (word, picture) value('#{word}', '#{picture}')")
    end

    def self.addWords(words)
      values = []
      words.each {|word| values << "('#{word.downcase}', '#{word.downcase}.jpg')" }
      return @@connection.write("insert ignore into word (word, picture) values #{values.join(",")}")
    end

    def self.initialWords
			addWords(JSON.parse(IO.read("../../app/assets/wordList.js")))
    end
  end

end

puts MySqlDB::Word.initialWords
