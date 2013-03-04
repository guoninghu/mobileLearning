require_relative './connection'

module MySqlDB

  class QuestionType
    attr_reader :id, :name, :question, :answer

    def initialize(type)
      @id, @name, @question, @answer = type[0].to_i, type[1], type[2].to_i, type[3].to_i
    end

    def to_json
      {id: @id, name: @name, question: @question, answer: @answer}.to_json
    end
  end

  class QuestionTypeDAO < ItemDAO
    def initialize
      super("select id, name, question, answer from question_type where ")
    end

    def createItem(qType)
      QuestionType.new(qType)
    end
  end
end
