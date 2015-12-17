require 'net/http'
require 'uri'
require 'json'
require 'hpricot'
require_relative '../mysql/word'

class WordMeaning
  attr :meaning, :audio
  def initialize(content)
    doc = Hpricot(content)
    @meaning = []
    doc.search("//div[@class='def-list']/section[@class='def-pbk ce-spot']").each do |elem|
      @meaning << getSection(elem)
    end

    @audio = nil
    doc.search("//audio/source[@type='audio/ogg']").each do |elem|
      @audio = elem.attributes['src']
    end
  end

  def getSection(elem)
    type, meaning = nil, []
    elem.search("//header/span/").each do |elem2|
      type = elem2.inner_text.gsub('\n', ' ').gsub('\r', ' ').strip
    end
    elem.search("//div[@class='def-content']").each do |elem2|
      meaning << elem2.inner_text.gsub('\n', ' ').gsub('\r', ' ').strip
    end

    return [type, meaning]
  end
end

class WordCrawler
  @@head = "/mnt/spellingbee/"
  def initialize
    @dao = MySqlDB::SWordDAO.new
	end

  def crawl(word, source, level)
    word = word.downcase
		content = getContent(word)
    wm = WordMeaning.new(content)
    audio = downloadAudio(wm, word)
    save(word, source, level, audio, wm.meaning.to_json)
  end

  def getContent(word)
    url = "http://dictionary.reference.com/browse/#{word.gsub(" ", "+")}?s=t"
		uri = URI(url)

		res = Net::HTTP.get_response(uri)
		return res.body
	end

  def downloadAudio(wm, word)
    fname = nil

    if !wm.audio.nil?
      path = "audio/#{word[0]}"
      `mkdir -p #{@@head + path}`
      fname = path + "/" + word + ".ogg"
      `wget #{wm.audio} -O #{@@head + fname}`
    end

    return fname
  end

  def save(word, source, level, audio, meaning)
    query = "insert into word (word, source, lvl, audio, meaning) values " +
      "(\"#{word}\", \"#{source}\", \"#{level}\", \"#{audio}\", " +
      "\"" + meaning.gsub('"', '\\\"') + "\") on duplicate key update " +
      "source = \"#{source}\", lvl = \"#{level}\", audio =  \"#{audio}\", " +
      "meaning = \"" + meaning.gsub('"', '\\\"') + "\""
    @dao.insert(query)

  end
end

=begin
f = File.open('/tmp/test.html')
body = f.read
f.close
wm = WordMeaning.new(body)
puts wm.meaning.to_json
puts wm.audio
=end

#meaning = '[["adjective",["lacking sense, significance, or ideas; silly: inane questions.","empty; void."]],["noun",["something that is empty or void, especially the void of infinite space."]]]'
#wc = WordCrawler.new
#wc.crawl('inane', 'Latin', 'basic')
#wc.save('inane', 'Latin', 'basic', 'http://static.sfdict.com/staticrep/dictaudio/lunawav/I00/I0093400.ogg', meaning)
#puts wc.crawl('inane').join("\n")

