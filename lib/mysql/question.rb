require_relative './connection'
require_relative './word'

module MySqlDB

  class Question
    attr_reader :id, :questionSet, :target, :competitor, :order, :answer, :type, :timestamp
    
    def initialize(question)
      @id, @questionSet, @target, @answer, @timestamp, @type = question[0].to_i, question[1].to_i,
        question[2].to_i, question[5].to_i, question[6], question[7].to_i
      
      @competitor, @order = JSON.parse(question[3]), JSON.parse(question[4])
    end

    def getNextQuestionId
      return nil if (item = QuestionDAO.new.getItem("question_set = #{@questionSet} and id > #{@id} order by id limit 1")).nil?
      item.id
    end

    def to_json
      {id: @id, questionSet: @questionSet, target: @target, competitor: @competitor, 
        order: @order, answer: @answer, type: @type}.to_json
    end
  end

  class QuestionDAO < ItemDAO
    def initialize
      super("select id, question_set, target, competitor, `order`, answer, timestamp, type from question where ")
    end

    def createItem(question)
      Question.new(question)
    end

		def getQuestionsBySet(questionSet)
			getItems("question_set=#{questionSet}")
		end

    def addQuestion(questionSet, target, competitor, order, type)
      @@connection.insert("insert into question (question_set, target, competitor, `order`, type) 
                          value(#{questionSet}, #{target}, '#{competitor.to_json}', '#{order.to_json}', #{type})")
    end

    def setAnswer(id, answer)
      @@connection.write("update question set answer = #{answer} where id = #{id}")
    end

    def createQuestions(qSetType, qSetId)
      wordDao = WordDAO.new
      wordIds = wordDao.getRandomWordIds(50)
      ret_val = []
      0.upto(9) do |n|
        ret_val << addQuestion(qSetId, wordIds[n*4], wordIds[n*4+1, 3], (0..3).to_a.shuffle, 1)
      end

      ret_val
    end
  end
end
