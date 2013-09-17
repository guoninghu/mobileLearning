require_relative './connection'
require 'set'

module MySqlDB

  class Word
    attr_reader :id, :word, :grade, :picture, :audio, :timestamp

    def initialize(word)
      @id, @word, @grade, @picture, @audio, @timestamp = word[0].to_i, word[1], word[2].to_i, word[3], word[4], word[5].to_i
      @picture = @picture[0].downcase + "/" + @picture if !@picture.nil?
      @audio = @audio[0].downcase + "/" + @audio if !@audio.nil?
    end

    def to_json
      {id: @id, word: @word, grade: @grade, picture: @picture, audio: @audio, timestamp: @timestamp}.to_json
    end
  end
  
  class WordDAO < ItemDAO
    @@words = []
    @@indices = {
      "all" => {"all" => [], "audio" => [], "image" => [], "both" => []}
    }

    def initialize
      super("select id, word, grade, picture, audio, timestamp from word where ")
      if @@words.length == 0
        puts "Load words"
        getItems("id > 0").each { |word| @@words << word }

        0.upto(@@words.length - 1) do |n|
          word = @@words[n]
          grade = word.grade

          @@indices[grade] = {"all" => [], "audio" => [], "image" => [], "both" =>[]} if @@indices[grade].nil?

          @@indices["all"]["all"] << n
          @@indices[grade]["all"] << n

          if !word.picture.nil?
            @@indices["all"]["image"] << n
            @@indices[grade]["image"] << n
            if !word.audio.nil?
              @@indices["all"]["both"] << n
              @@indices[grade]["both"] << n
            end
          elsif !word.audio.nil?
            @@indices["all"]["audio"] << n
            @@indices[grade]["audio"] << n
          end
        end

        readGroup
      end
    end

    def readGroup
      @@groupIndices = {}
      read("select word, `group` from word_group").each do |entity|
        wid, gid = entity[0].to_i, entity[1].to_i
        @@groupIndices[wid] = Set.new if @groupIndices[wid].nil?
        @@groupIndices[wid] << gid
      end
    end

    def sameGroup?(target, competitor)
      s1 = @@groupIndices[target]
      return false if s1.nil?
      s2 = @@groupIndices[competitor]
      return false if s2.nil?

      s1.each do |gid|
        return true if s2.include?(gid)
      end

      return false
    end

    def createItem(word)
      Word.new(word)
    end
		
		def getWordByText(word)
			getItem("word='#{word}'")
		end
    
    # retrun a list of indices of target words
    def getRandomTarget(grade, type, num)
      indices = (type == 2) ? @@indices[grade]["both"].shuffle :
        @@indices[grade]["image"].shuffle
      
      retVal = []
      indices.each do |index|
        break retVal if retVal.length >= num
        retVal << index
      end

      return retVal
    end
    
    def getRandomCompetitor(targets, numComps)
      indices = @@indices["all"]["image"].shuffle

      retVal, pos = [], 0
      targets.each do |target|
        retVal << target
        count = 0
        while pos < indices.size
          index = indices[pos]
          pos += 1
          next if index == target
          next if sameGroup?(@@words[target].id, @@words[index].id)

          retVal << index
          count += 1
          break if count >= numComps
        end
      end

      return retVal
    end

    def getRandomWords(grade, type, numTargets, numComps)
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
