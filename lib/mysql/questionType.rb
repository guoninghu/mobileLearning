require_relative './connection'
require 'json'

module MySqlDB

  class QuestionType
    attr_reader :id, :type
	  @@connection = Connection.new

    def initialize(word)
      @id, @type = word[0].to_i, word[1]
    end

    def to_json
      return {id: @id, type: @type}.to_json
    end

    def self.getQuestionType(condition)
			types = @@connection.read("select id, type from question_type where " + condition)
			return nil if types.nil?
			return nil if types.length == 0 
			return QuestionType.new(types[0])
		end

		def self.getQuestionTypeById(id)
			return getQuestionType("id = " + id.to_s)
		end

		def self.getQuestionTypeByType(type)
			return getQuestionType("type = '#{type}'")
		end

  end
end
