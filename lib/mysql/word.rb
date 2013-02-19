require_relative './connection'
require 'json'

module MySqlDB

  class Word
    attr_reader :id, :word, :picture, :timestamp
	  @@connection = Connection.new

    def initialize(word)
      @id, @word, @picture, @timestamp = word[0].to_i, word[1], word[2], word[3]
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
      return @@connection.write("insert ignore into word (word, picture) value('#{word}', '#{picture}')")
    end

    def self.addWords(words)
      values = []
      words.each {|word| values << "('#{word.downcase}', '#{word.downcase}.jpg')" }
      return @@connection.write("insert ignore into word (word, picture) values #{values.join(",")}")
    end

    def self.initialWords
			addWords(JSON.parse(IO.read(File.dirname(__FILE__) + "/../../app/assets/wordList.js")))
    end
  end
end
