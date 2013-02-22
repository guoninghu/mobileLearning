require_relative './connection'
require 'json'

module MySqlDB

  class QuestionSetType
    attr_reader :id, :name, :questions

    def initialize(qSet)
      @id, @name, @questions = qSet[0].to_i, qSet[1], JSON.parse(qSet[2])
    end

    def to_json
      {id: @id, name: @name, questions: @quentions}.to_json
    end
  end

  class QuestionSetTypeDAO < ItemDAO
    def initialize
      super("select id, name, questions from question_set_type where ")
    end

    def createItem(qSetType)
      QuestionSetType.new(qSetType)
    end
  end
end
