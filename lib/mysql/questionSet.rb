require_relative './connection'
require_relative './questionSetType'
require_relative './wordSelector'

module MySqlDB

  class QuestionSet
    attr_reader :id, :session, :user, :grade, :type, :timestamp

    def initialize(set)
      @id, @session, @user, @grade, @type, @timestamp = set[0].to_i, set[1], set[2].to_i, set[3].to_i, set[4].to_i, set[5]
    end

    def to_json
      {id: @id, session: @session, user: @user, grade: @grade, type: @type, timestamp: @timestamp}.to_json
    end
  end

  class QuestionSetDAO < ItemDAO
    def initialize
      super("select id, session, user, grade, type, timestamp from question_set where ")
    end

    def createItem(questionSet)
      QuestionSet.new(questionSet)
    end

		def getQuestionSetsBySession(session)
			getItems("session = '#{session}'")
		end

    def addQuestionSet(session, user, grade, type)
      insert("insert into question_set (session, user, grade, type) value('#{session}', #{user}, #{grade}, #{type})")
    end

    def createQuestions(userId, typeId, grade, setId)
      qSetType = QuestionSetTypeDAO.new.getItemById(typeId)
      questionDao = QuestionDAO.new

      words = {}
      wordIds = []
      WordSelector.new.getRandomWords(userId, grade, qSetType.questionType, qSetType.numTargets, qSetType.numCompetitors).each{|word|
        wordIds << word.id
        words[word.id] = word
      }

      questions = {}
      qIds = []
      0.upto(qSetType.numTargets-1) do |n|
        order =  (0..(qSetType.numCompetitors)).to_a.shuffle
        qId = questionDao.addQuestion(setId, wordIds[n*order.length], wordIds[n*order.length+1, order.length-1], order, 1)
        qIds << qId
        questions[qId] = {words: wordIds[n*order.length, order.length], order: order }
      end

      return {words: words, questions: questions, questionIds: qIds, questionSetId: setId, qType: qSetType.questionType}
    end
  end
end
