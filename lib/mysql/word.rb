require_relative './connection'

module MySqlDB

  class Word
    attr_reader :id, :word, :picture, :timestamp

    def initialize(word)
      @id, @word, @picture, @timestamp = word[0].to_i, word[1], word[2], word[3]
    end

    def to_json
      {id: @id, word: @word, picture: @picture, timestamp: @timestamp}.to_json
    end
  end
  
  class WordDAO < ItemDAO
    @@words = nil 

    def initialize
      super("select id, word, picture, timestamp from word where ")
      if @@words.nil?
        puts "Load words"
        @@words = getItems("id > 0")
      end
    end

    def createItem(word)
      Word.new(word)
    end
		
		def getWordByText(word)
			getItem("word='#{word}'")
		end

    def addWord(word, picture)
      return true if getWordByText(word)
      write("insert ignore into word (word, picture) value('#{word}', '#{picture}')")
    end

    def addWords(words)
      values = []
      words.each {|word| values << "('#{word.downcase}', '#{word.downcase}.jpg')" }
      write("insert ignore into word (word, picture) values #{values.join(",")}")
    end

    def initialWords
			addWords(JSON.parse(IO.read(File.dirname(__FILE__) + "/../../app/assets/wordList.js")))
    end

    def getRandomWords(num)
      return @@words.shuffle[0, num]
    end
  end
end
