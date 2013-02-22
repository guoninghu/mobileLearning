require_relative './connection'
require 'json'

module MySqlDB

  class QuestionType
    attr_reader :id, :name, :target, :competitor

    def initialize(type)
      @id, @name = type[0].to_i, type[1]
      @target, @competitor = JSON.parse(type[2]), JSON.parse(type[3])
    end

    def to_json
      {id: @id, type: @type, target: @target, competitor: @competitor}.to_json
    end
  end

  class QuestionTypeDAO < ItemDAO
    def initialize
      super("select id, name, target, competitor from question_type where ")
    end

    def createItem(qType)
      QuestionType.new(qType)
    end
  end
end
