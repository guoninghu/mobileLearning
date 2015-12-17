require "spellingbee/mysql/word"
require 'spellingbee/crawl/wordCrawler'
require 'spellingbee/mysql/practice'
require 'json'

class SpellingbeeController < ApplicationController
  def show
    wd = MySqlDB::SWordDAO.new
    @word = wd.getWordByText(params[:w])
    @meaning = JSON.parse(@word.meaning)
  end

  def add
    @source = ["Latin", "Arabic", "Asian", "French", "Eponyms",
      "German", "Slavic", "Dutch", "Old English", "New World",
      "Japanese", "Greek", "Italian", "Spanish"]
  end

  def crawl
    wc = WordCrawler.new
    wc.crawl(params[:word], params[:source], params[:level])
    redirect_to "/spellingbee/show?w=#{params[:word]}"
  end

  def practice
    pq = MySqlDB::SPracticeQueueDAO.new
    wd = MySqlDB::SWordDAO.new
    tw = pq.get(@amateur)
    @word = wd.getItemById(tw.word)
    @meaning = JSON.parse(@word.meaning)
  end

  def result
    @spell = params[:spell].downcase
    @cspell = params[:cspell].downcase
    @correct = (@spell == @cspell)
    @id = params[:word].to_i

    pq = MySqlDB::SPracticeQueueDAO.new
    pq.save(@amateur, @id)

    pr = MySqlDB::SPracticeRecordDAO.new
    pr.update(@amateur, @id, @correct)

    wd = MySqlDB::SWordDAO.new
    @word = wd.getItemById(@id)
    @meaning = JSON.parse(@word.meaning)
    @result = "Correct"
    @result = "Wrong (You spell " + @spell + ")" if !@correct
  end
end
