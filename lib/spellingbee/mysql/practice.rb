require_relative './connection'
require 'set'

module MySqlDB

  class SPracticeRecord
    attr_reader :amateur, :word, :correct, :wrong, :status

    def initialize(word)
      @amateur, @word, @correct, @wrong, @status = word[0].to_i, word[1].to_i, word[2].to_i, word[3].to_i, word[4]
    end

    def to_json
      {amateur: @amateur, word: @word, correct: @correct, wrong: @wrong, status: @status}.to_json
    end

    def update(correct)
      if correct
        @correct += 1
        if status == 'R1'
          @status = 'R2'
        elsif status == 'R2' || status == 'R3'
          @status = 'R3'
        else
          @status = 'R1'
        end
      else
        @wrong += 1
        @status = 'WRONG'
      end
    end
  end

  class SPracticeRecordDAO < SItemDAO   
    def initialize
      super("select amateur, word, correct, wrong, status from practice_record where ")
    end

    def createItem(word)
      SPracticeRecord.new(word)
    end
		
		def getWordByAmateur(amateur)
      getItems("amateur=#{amateur}")
		end

    def getWord(amateur, word)
      getItem("amateur=#{amateur} and word = #{word}")
    end

    def update(amateur, word, correct)
      pr = getWord(amateur, word)
      pr = SPracticeRecord.new([amateur, word, 0, 0, 'WRONG']) if pr.nil?
      pr.update(correct)

      query = "insert into practice_record (amateur, word, correct, wrong, status) " +
        "value(#{pr.amateur}, #{pr.word}, #{pr.correct}, #{pr.wrong}, '#{pr.status}') " +
        "on duplicate key update correct = #{pr.correct}, wrong = #{pr.wrong}, " +
        "status = '#{pr.status}'"
      insert(query)
    end
  end

  class SPracticeQueue
    attr_reader :amateur, :word

    def initialize(word)
      @amateur, @word = word[0].to_i, word[1].to_i
    end

    def to_json
      {amateur: @amateur, word: @word}.to_json
    end
  end

  class SPracticeQueueDAO < SItemDAO
    def initialize
      super("select amateur, word from practice_queue where ")
    end

    def createItem(word)
      SPracticeQueue.new(word)
    end

    def save(amateur, word)
      query = "delete from practice_queue where amateur = #{amateur} and word = '#{word}'"
      write(query)
    end

    def addRandom(amateur, status, limit)
      if status == "NEW"
        query = "insert ignore into practice_queue select #{amateur} as amateur, a.id " +
          "from word a left join practice_record b on a.id = b.word and b.amateur = #{amateur} " +
          "where b.amateur is null limit #{limit}"
        write(query)
      else
        query = "insert ignore into practice_queue select amateur, id from practice_record " +
          "where amateur = #{amateur} and status = '#{status}' order by rand() limit #{limit}"
        write(query)
      end
    end

    def addMany(amateur)
      addRandom(amateur, "WRONG", 30)
      addRandom(amateur, "NEW", 20)
      addRandom(amateur, "R1", 20)
      addRandom(amateur, "R2", 10)
      addRandom(amateur, "R3", 5)
    end

    def getOne(amateur)
      getItem("amateur = #{amateur} order by rand() limit 1")
    end
      
    def get(amateur)
      retVal = getOne(amateur)
      if retVal.nil?
        addMany(amateur)
        retVal = getOne(amateur)
      end
      return retVal
    end
  end
end
