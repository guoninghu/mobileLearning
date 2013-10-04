require_relative './connection'
require 'set'

module MySqlDB
  class WordResult
    attr_reader :id, :priority

    def initialize(word)
      if word.size >= 4
        @id, right_count, wrong_count, current_count = word[0].to_i, word[1].to_i, word[2].to_i, word[3].to_i
        @priority = (right_count + wrong_count + current_count * 2) * 0.1 + rand() * 0.2;
      else
        @id, @priority = word[0].to_i, word[1].to_f
      end
    end

    def to_json
      {id: @id, priority: @priority}
    end
  end
  
  class WordResultDAO < ItemDAO
    @@words = [430, 720, 360, 320, 500]
    @@levels = [0, 50, 100, 200, 300, 500, 1000]
    @@names = ["Basic", "Pawn", "Knight", "Bishop", "Rook", "Queen", "King"]
    @@thumbs = [nil, "P", "N", "B", "R", "Q", "K"]

    def initialize
      super("select a.word, a.right_count, a.wrong_count, a.current from word_result a " +
        " join word b on a.word = b.id where ")
    end

    def createItem(word)
      WordResult.new(word)
    end

    def readUser(userId, grade)
      getItems(" a.user = #{userId} and b.grade = #{grade}")
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

    def getPoints(userId)
      query = "select sum(right_count + wrong_count), grade from word_result a " +
        "join word b on a.word = b.id where user = #{userId} group by grade"
      val1 = [0, 0, 0, 0, 0]
      read(query).each do |entity| 
        grade = entity[1].to_i
        tv = entity[0].to_i
        tv = 500 if tv > 500
        val1[grade] = tv
      end

      query =  "select count(*), grade from word_result a join word b on a.word = b.id " +
        "where user = #{userId} and current > 0 group by grade"
      val2 = [0, 0, 0, 0, 0]
      read(query).each do |entity|
        grade = entity[1].to_i
        tv = (500.0 * entity[0].to_f / @@words[grade].to_f).to_i
        tv = 500 if tv > 500
        val2[grade] = tv
      end

      val3 = ["Basic", "Basic", "Basic", "Basic", "Basic"]
      val4 = [nil, nil, nil, nil, nil]
      val5 = [nil, nil, nil, nil, nil]
      0.upto(4) do |grade|
        score = val1[grade] + val2[grade]
        if score >= @@levels[6]
          val3[grade] = @@names[6]
          val5[grade] = "/assets/achievements/#{@@thumbs[6]}.jpg"
        else
          0.upto(5) do |n|
            if @@levels[n] <= score
              val3[grade] = @@names[n]
              val4[grade] = @@levels[n+1] - score
              val5[grade] = (@@thumbs[n].nil?) ? nil :  "/assets/achievements/#{@@thumbs[n]}.jpg"
            else
              break
            end
          end
        end
      end

      return [val1, val2, val3, val4, val5]
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
