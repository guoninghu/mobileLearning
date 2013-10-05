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

  class WordExclude < ItemDAO
    def initialize
      super("select word, `group` from word_group where ")
      read_group
    end

    def read_group
      groups, words = {}, {}
      read("select word, `group` from word_group").each do |entity|
        gid, wid = entity[1].to_i, entity[0].to_i
        groups[gid] = Set.new if groups[gid].nil?
        groups[gid] << wid

        words[wid] = Set.new if words[wid].nil?
        words[wid] << gid
      end

      eGroups = {}
      read("select group1, group2 from group_exclude").each do |entity|
        gid1, gid2 = entity[0].to_i, entity[1].to_i
        eGroups[gid1] = gid2
      end

      @excludedWords = {}
      words.each do |wid, gid|
        @excludedWords[wid] = Set.new
        @excludedWords[wid] != groups[gid]
        if !eGroups[gid].nil?
          eGroups[gid].each |gid2|
          @excludedWords[wid] != groups[gid2]
        end

        @excludedWords[wid].delete(wid)
      end
    end

    def excluded?(wid1, wid2)
      return false if @excludedWords[wid1].nil?
      return @excludedWords[wid1].include?(wid2)
    end
  end
  
  class WordDAO < ItemDAO
    @@words = {}
    @@indices = {
      "all" => {"all" => [], "audio" => [], "image" => [], "both" => []}
    }

    def initialize
      super("select id, word, grade, picture, audio, timestamp from word where ")
      if @@words.length == 0
        puts "Load words"
        getItems("id > 0").each { |word| @@words[word.id] = word }

        @@words.each do |id, word|
          grade = word.grade
          @@indices[grade] = {"all" => [], "audio" => [], "image" => [], "both" =>[]} if @@indices[grade].nil?

          @@indices["all"]["all"] << id
          @@indices[grade]["all"] << id

          if !word.picture.nil?
            @@indices["all"]["image"] << id
            @@indices[grade]["image"] << id
            if !word.audio.nil?
              @@indices["all"]["both"] << id
              @@indices[grade]["both"] << id
            end
          elsif !word.audio.nil?
            @@indices["all"]["audio"] << id
            @@indices[grade]["audio"] << id
          end
        end

        @@wordExclude = WordExclude.new
      end
    end

    def sameGroup?(target, competitor)
      return @@wordExclude.excluded?(target, competitor)
    end

    def createItem(word)
      Word.new(word)
    end
		
		def getWordByText(word)
			getItem("word='#{word}'")
		end
    
    def getRandomCompetitor(targets, numComps)
      indices = @@indices["all"]["image"].shuffle

      retVal, pos = [], 0
      targets.each do |target|
        retVal << @@words[target]
        count = 0
        while pos < indices.size
          index = indices[pos]
          pos += 1
          next if index == target
          next if sameGroup?(@@words[target].id, @@words[index].id)

          retVal << @@words[index]
          count += 1
          break if count >= numComps
        end
      end

      return retVal
    end

    def getWords(grade, type)
      return (type == 2) ? @@indices[grade]["both"] : @@indices[grade]["image"]
    end
  end
end
