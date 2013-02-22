require_relative './word'

wordDao = MySqlDB::WordDAO.new

wordDao.read("select word, picture from word").each do |word|
  if !File.exists?(File.dirname(__FILE__) + "/../../app/assets/images/vocabPics/" + word[1])
    puts word.join(", ")
    break
  end
end

Dir.glob(File.dirname(__FILE__) + "/../../app/assets/images/vocabPics/*.jpg").each do |file|
  file =~ /.*\/(.*)\.jpg/
  if wordDao.getWordByText($1).nil?
    puts $1
    break
  end
end
