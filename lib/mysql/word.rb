require_relative './connection'

module MySqlDB

  class Word
    attr_reader :id, :word, :grade, :picture, :audio, :timestamp

    def initialize(word)
      @id, @word, @grade, @picture, @audio, @timestamp = word[0].to_i, word[1], word[2].to_i, word[3], word[4], word[5].to_i
      @picture = @picture[0].downcase + "/" + @picture
      @audio = @audio[0].downcase + "/" + @audio if !@audio.nil?
    end

    def to_json
      {id: @id, word: @word, grade: @grade, picture: @picture, audio: @audio, timestamp: @timestamp}.to_json
    end
  end
  
  class WordDAO < ItemDAO
    @@words = []
    @@indices = {}

    def initialize
      super("select id, word, grade, picture, audio, timestamp from word where ")
      if @@words.length == 0
        puts "Load words"
        getItems("id > 0").each do |word|
          grade = word.grade
          @@indices[grade] = [] if @@indices[grade].nil?
          @@indices[grade] << @@words.length
          @@words << word
        end
      end
    end

    def createItem(word)
      Word.new(word)
    end
		
		def getWordByText(word)
			getItem("word='#{word}'")
		end
    
    # retrun a list of indices of target words
    def getRandomTarget(grade, type, num)
      indices = @@indices[grade].shuffle
      
      retVal = []
      indices.each do |index|
        break retVal if retVal.length >= num
        next if (type == 2) && @@words[index].audio.nil?
        retVal << index
      end

      return retVal
    end
    
    def getRandomCompetitor(targets, numComps)
      retVal = []
      targets.each do |target|
        retVal << target
        count = 0
        (0..@@words.length-1).to_a.shuffle[0, numComps+1].each do |index|
          next if index == target
          retVal << index
          count += 1
          break if count >= numComps
        end
      end

      return retVal
    end

    def getRandomWords(grade, type, numTargets, numComps)
      numTargets = @@indices[grade].length if (numTargets > @@indices[grade].length)
      numComps = 1 if numComps < 1
      numComps = 3 if numComps > 3

      targets = getRandomTarget(grade, type, numTargets)
      ret_val = []
      getRandomCompetitor(targets, numComps).each do |val|
        ret_val << @@words[val]
      end

      return ret_val
    end
  end
end
