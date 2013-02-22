require_relative './connection'

module MySqlDB

  class QuestionSet
    attr_reader :id, :session, :type, :timestamp

    def initialize(set)
      @id, @session, @type, @timestamp = set[0].to_i, set[1], set[2].to_i, set[3]
    end

    def to_json
      {id: @id, session: @session, type: @type, timestamp: @timestamp}.to_json
    end
  end

  class QuestionSetDAO < ItemDAO
    def initialize
      super("select id, session, type, timestamp from question_set where ")
    end

    def createItem(questionSet)
      QuestionSet.new(questionSet)
    end

		def getQuestionSetsBySession(session)
			getItems("session = '#{session}'")
		end

    def addQuestionSet(session, type)
      insert("insert into question_set (session, type) value('#{session}', #{type})")
    end
  end
end
