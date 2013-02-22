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
    def initialize
      super("select id, word, picture, timestamp from word where ")
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

    def getMaxId
      read("select max(id) from word")[0][0].to_i
    end

    def getMinId
      read("select min(id) from word")[0][0].to_i
    end

    def getRandomWordIds(num)
      ret_val = []
      while (ret_val.length < num)
        diff = num - ret_val.length
        ids = (getMinId..getMaxId).to_a.shuffle[0,diff+10]

        read("select id from word where id in (#{ids.join(",")})").each do |val|
          id = val[0].to_i
          ret_val << id if !ret_val.include?(id)
          return ret_val if ret_val.length == num
        end
      end
    end
  end
end
