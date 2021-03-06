require 'spec_helper'

describe MySqlDB::WordDAO do
  def verifyWord(word)
    word.should be_an_instance_of MySqlDB::Word
    word.id.should be 1
    word.grade.should be 5
    word.word.should eq 'absent'
    word.picture.should eq 'absent.jpg'
  end

  before do
    @wordDao = MySqlDB::WordDAO.new
  end

	it "Read a word from word table by id" do
    verifyWord(@wordDao.getItemById(1))
	end

	it "Read a word from word table by name" do
    verifyWord(@wordDao.getWordByText('absent'))
	end
=begin
  it "Add a word to word table" do
    @wordDao.addWord('absent', 'absent.jpg').should be true
  end

  it "Initialize word table" do
    @wordDao.initialWords.should >= 0
  end
=end
  it "Get random word" do
    words = @wordDao.getRandomWords(5, 10, 3)
    words.length.should be 40
    words = @wordDao.getRandomWords(1, 10, 2)
    words.length.should be 30
  end

  after do
    @wordDao.write("alter table word auto_increment=1")
  end
end
