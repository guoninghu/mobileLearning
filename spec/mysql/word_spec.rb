require 'spec_helper'

describe MySqlDB::Word do
  def verifyWord(word)
    word.should be_an_instance_of MySqlDB::Word
    word.id.should be 1
    word.word.should eq 'absent'
    word.picture.should eq 'absent.jpg'
  end

	it "Read a word from word table by id" do
    verifyWord(MySqlDB::Word.getWordById(1))
	end

	it "Read a word from word table by name" do
    verifyWord(MySqlDB::Word.getWordByText('absent'))
	end

  it "Add a word to word table" do
    MySqlDB::Word.addWord('absent', 'absent.jpg').should be true
  end

  it "Initialize word table" do
    MySqlDB::Word.initialWords.should >= 0
  end
end
