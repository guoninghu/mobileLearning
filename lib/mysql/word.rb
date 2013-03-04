require_relative './connection'

module MySqlDB

  class Word
    attr_reader :id, :word, :grade, :picture, :timestamp

    def initialize(word)
      @id, @word, @grade, @picture, @timestamp = word[0].to_i, word[1], word[2].to_i, word[3], word[4]
    end

    def to_json
      {id: @id, word: @word, grade: @grade, picture: @picture, timestamp: @timestamp}.to_json
    end
  end
  
  class WordDAO < ItemDAO
    @@words = [[], [], [], [], [], [], [], []]

    def initialize
      super("select id, word, grade, picture, timestamp from word where ")
      if @@words[0].length == 0
        puts "Load words"
        getItems("id > 0").each {|word| @@words[word.grade-1] << word}
      end
    end

    def createItem(word)
      Word.new(word)
    end
		
		def getWordByText(word)
			getItem("word='#{word}'")
		end
=begin
    def addWord(word, grade, picture)
      return true if getWordByText(word)
      write("insert ignore into word (word, grade, picture) value('#{word}', #{grade}, '#{picture}')")
    end

    def addWords(words, grade)
      values = []
      words.each {|word| values << "('#{word.downcase}', #{grade}, '#{word.downcase}.jpg')" }
      write("insert ignore into word (word, grade, picture) values #{values.join(",")}")
    end

    def initialWords
			addWords(JSON.parse(IO.read(File.dirname(__FILE__) + "/../../app/assets/wordList.js")))
    end
=end
    def randomIndex(len, numTargets, numComps)
      ret_val = []
      targets = []
      indices = (0..len-1).to_a
      while (true)
        values = indices.shuffle[0, numComps+1]
        next if targets.include?(values[0])
        targets << values[0]
        ret_val = ret_val.concat(values)
        return ret_val if targets.length == numTargets
      end
    end

    def getRandomWords(grade, numTargets, numComps)
      words = @@words[grade-1]
      return [] if words.length < 2
      
      numTargets = words.length if (numTargets > words.length)
      numComps = 1 if numComps < 1
      numComps = 3 if numComps > 3
      numComps = words.length - 1 if numComps >= words.length

      ret_val = []
      randomIndex(words.length, numTargets, numComps).each do |val|
        ret_val << words[val]
      end

      return ret_val
    end
  end
end
