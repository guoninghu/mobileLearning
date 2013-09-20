require_relative './connection'
require 'set'

module MySqlDB
  class WordResult
    attr_reader :id, :priority

    def initialize(word)
      if word.size >= 4
        @id, right_count, wrong_count, current_count = word[0].to_i, word[1].to_i, word[2].to_i, word[3].to_i
        sum = right_count + wrong_count
        @priority = (sum == 0) ? 0 : right_count.to_f / sum
        @priority += rand()/100.0 + current_count
      else
        @id, @priority = word[0].to_i, word[1].to_f
      end
    end

    def to_json
      {id: @id, priority: @priority}
    end
  end
  
  class WordResultDAO < ItemDAO
    def initialize
      super("select a.word, a.right_count, a.wrong_count, a.current from word_result a " +
        " join word b on a.word = b.id where ")
    end

    def createItem(word)
      WordResult.new(word)
    end

    def readUser(userId, grade)
      getItems(" user = #{userId}")
    end

    def update(word, user, correct)
      if correct
        query = "insert into word_result (word, user, right_count) " +
          "value (#{word}, 0, 1) on duplicate key update " +
          "right_count = right_count + 1"
        write(query)
        query = "insert into word_result (word, user, right_count, current) " +
          "value (#{word}, #{user}, 1, 1) on duplicate key update " +
          "right_count = right_count + 1, current = current + 1"
        write(query)
      else
        query = "insert into word_result (word, user, wrong_count) " +
          "value (#{word}, 0, 1) on duplicate key update " +
          "wrong_count = wrong_count + 1"
        write(query)
        query = "insert into word_result (word, user, wrong_count) " +
          "value (#{word}, #{user}, 1) on duplicate key update " +
          "wrong_count = wrong_count + 1, current = 0"
        write(query)
      end
    end
  end

  class SimplePQueue
    attr_reader :q

    def initialize(qs)
      @q, @qs = [], qs
    end

    def add(word)
      s = @q.size
      while ((s > 0) && (@q[s-1].priority > word.priority))
        s -= 1
      end

      @q.insert(s, word)
      @q = @q[0, @qs] if @q.size > @qs
    end
  end
end
