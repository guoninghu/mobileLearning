require_relative './connection'
require 'set'

module MySqlDB

  class WordSession
    attr_reader :amateur, :game, :grade, :difficulty

    def initialize(word)
      @amateur, @game, @grade, @difficulty = word[0].to_i, word[1].to_i, word[2].to_i, word[3].to_i
    end
  end

  class WordSessionDAO < ItemDAO
    def initialize
      super("select amateur, game, grade, difficulty from word_session where ")
    end

    def createItem(word)
      WordSession.new(word)
    end

    def getWordSession(amateur)
			getItem("amateur='#{amateur}'")
		end

    def setWordSession(amateur, game, grade, difficulty)
      query = "insert into word_session (amateur, game, grade, difficulty) " +
        "value (#{amateur}, #{game}, #{grade}, #{difficulty}) " +
        "on duplicate key update game = #{game}, grade = #{grade}, difficulty = #{difficulty} "
      write(query)
		end
  end
end

