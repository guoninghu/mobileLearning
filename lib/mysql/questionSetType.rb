require_relative './connection'
require 'json'

module MySqlDB

  class QuestionSetType
    attr_reader :id, :questionType, :numTargets, :numCompetitors

    def initialize(qSet)
      @id, @questionType, @numTargets, @numCompetitors = qSet[0].to_i, qSet[1].to_i, qSet[2].to_i, qSet[3].to_i
    end

    def to_json
      {id: @id, questionType: @questionType, numTargets: @numTargets, numCompetitors: @numCompetitors}.to_json
    end
  end

  class QuestionSetTypeDAO < ItemDAO
    def initialize
      super("select id, question_type, num_targets, num_competitors from question_set_type where ")
    end

    def createItem(qSetType)
      QuestionSetType.new(qSetType)
    end
  end
end
