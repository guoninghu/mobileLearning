require_relative './connection'
require_relative './user'
require 'bcrypt'

module MySqlDB

  class Amateur
	  attr_reader :id, :name, :user, :timestamp

		def initialize(user)
			@id, @name, @user, @timestamp = user[0].to_i, user[1], user[2].to_i, user[3].to_i
		end

		def to_json
			{id: @id, name: @name, user: @user, timestamp: @timestamp}.to_json
		end
  end

  class AmateurDAO < ItemDAO
    def initialize
      super("select id, name, user, timestamp from amateur where ")
    end

    def createItem(amateur)
      Amateur.new(amateur)
    end

    def addAmateur(name, user)
       insert("insert ignore into amateur (name, user) value ('#{name.gsub("'", "\\\\\'")}', #{user})")
    end
		
    def getAmateurByName(name, user)
			getItem("user = #{user} and name='#{name.gsub("'", "\\\\\'")}'")
		end

    def deleteAmateur(name, user)
      write("delete from amateur where user = #{user} and name='#{name.gsub("'", "\\\\\'")}'")
    end
 	end
  
  class UserAmateur
    attr_reader :user, :names, :ids
    @@amateurDao = AmateurDAO.new
    @@userDao = UserDAO.new

    def initialize(user)
      @user = user
      getAmateurs
    end
    
    def getAmateurs
      @names = {}
      @ids = {}
      @defaultAmateur = nil

      amateurs = @@amateurDao.read("select a.id, a.name, b.username from amateur a join user b on a.user = b.id where b.id = #{@user}")
      if amateurs.size > 0
        @username = amateurs[0][2]
      else
        user = @@userDao.getItemById(@user)
        @username = (user.nil?) ? nil : user.name
      end
      amateurs.each do |amateur|
        @defaultAmateur = amateur[0].to_i if @username == amateur[1]
        @ids[amateur[0].to_i] = amateur[1]
        @names[amateur[1]] = amateur[0].to_i
      end
    end

    def hasAmateur(name)
      @names.include?(name)
    end

    def addAmateur(name)
      if (!name.nil?) && (!hasAmateur(name))
        @@amateurDao.addAmateur(name, @user)
        getAmateurs
      end
    end

    def deleteAmateur(name)
      if hasAmateur(name)
        @@amateurDao.deleteAmateur(name, @user)
        getAmateurs
      end
    end

    def getCurrentAmateur(current)
      return nil if @username.nil?
      return @ids[current] if @ids.has_key?(current)
      addAmateur(@username)
      getAmateurs
      return @username
    end
  end
end
