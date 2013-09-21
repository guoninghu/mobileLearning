require_relative './word'
require_relative './wordResult'
require 'set'
require 'json'

module MySqlDB
  class WordSelector
    def initialize
      @words = WordDAO.new
      @wordResult = WordResultDAO.new
    end

    def getRandomWords(user, grade, type, numTargets, numComps)
      numComps = 1 if numComps < 1
      numComps = 3 if numComps > 3

      words = getTargetWords(user, grade, type, numTargets)
      @words.getRandomCompetitor(words, numComps)
    end

    def getTargetWords(user, grade, type, numTargets)
      priorities = {}
      @wordResult.readUser(user, grade).each { |word| priorities[word.id] = word }
      @wordResult.readUser(0, grade).each do |word| 
        priorities[word.id] = word if priorities[word.id].nil?
      end

      @words.getWords(grade, type).each do |word|
        priorities[word] = WordResult.new([word, rand() * 0.2]) if priorities[word].nil?
      end

      pq = SimplePQueue.new(numTargets)
      priorities.values.each do |word|
        pq.add(word)
      end

      retVal = []
      pq.q.each { |word| retVal << word.id }
      return retVal
    end
  end
end

