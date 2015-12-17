require_relative './connection'
require 'set'

module MySqlDB

  class SWord
    attr_reader :id, :word, :source, :lvl, :audio, :meaning

    def initialize(word)
      @id, @word, @source, @lvl, @audio, @meaning = word[0].to_i, word[1], word[2], word[3], word[4], word[5]
    end

    def to_json
      {id: @id, word: @word, source: @source, lvl: @lvl, audio: @audio, meaning: @meaning}.to_json
    end
  end

  class SWordDAO < SItemDAO   
    def initialize
      super("select id, word, source, lvl, audio, meaning from word where ")
    end

    def createItem(word)
      SWord.new(word)
    end
		
		def getWordByText(word)
      getItem("word='#{word}'")
		end
  end
end
