require_relative './connection'

conn = MySqlDB::Connection.new

tables = [
  "CREATE TABLE `item_type` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `class` enum('word') NOT NULL DEFAULT 'word',
    `property` varchar(32) NOT NULL DEFAULT 'picture',
    PRIMARY KEY (`id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;",

  "CREATE TABLE `question` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `question_set` int(11) NOT NULL,
    `target` int(11) NOT NULL,
    `competitor` varchar(255) NOT NULL,
    `order` varchar(255) NOT NULL,
    `answer` int(11) DEFAULT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `type` int(11) NOT NULL DEFAULT '1',
    PRIMARY KEY (`id`),
    KEY `question_set` (`question_set`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;",

  "CREATE TABLE `question_set` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `session` varchar(32) NOT NULL,
    `type` int(11) NOT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;",

  "CREATE TABLE `question_set_type` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(32) DEFAULT NULL,
    `questions` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
  ) ENGINE=InnoDBDEFAULT CHARSET=utf8;",

  "CREATE TABLE `question_type` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(32) DEFAULT NULL,
    `target` varchar(255) NOT NULL,
    `competitor` varchar(255) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;",

  "CREATE TABLE `session` (
    `id` varchar(32) NOT NULL,
    `user` int(11) DEFAULT NULL,
    `start_time` datetime DEFAULT NULL,
    `status` enum('active','closed','expired') NOT NULL DEFAULT 'active',
    `end_time` datetime DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `user` (`user`,`start_time`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;",

  "CREATE TABLE `user` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `username` varchar(64) NOT NULL,
    `email` varchar(255) NOT NULL,
    `password` varchar(255) NOT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`),
    UNIQUE KEY `email` (`email`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;",

  "CREATE TABLE `word` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `word` varchar(64) NOT NULL,
    `picture` varchar(255) DEFAULT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `word` (`word`)
  ) ENGINE=InnoDB AUTO_INCREMENT=307 DEFAULT CHARSET=utf8;"
]

tables.each {|table| conn.write(table)}

commands = [
  "insert ignore into item_type (id, class, property) values (1, 'word', 'picture'), (2, 'word', 'word')",

  "insert ignore into question_set_type (id, name, questions) value (1, 'WORD_PICTURE_4_1',
    '{\"WORD_PICTURE_4_1\":10}'), (2, 'WORD_PICTURE_2_1', '{\"WORD_PICTURE_2_1\":10}')",

  "insert ignore into question_type (id, name, target, competitor) values (1, 'WORD_PICTURE_4_1',
    '{\"Question\":2,\"Answer\":1}', '[1,1,1]'), (2, 'WORD_PICTURE_2_1',
    '{\"Question\":2,\"Answer\":1}', '[1]')",

  "insert into user (id, username, email, password) value(1, 'test', 'test@gmail.com', 'test')"
]

commands.each {|command| conn.write(command)}
    def addWords(words)
      values = []
      words.each {|word| values << "('#{word.downcase}', '#{word.downcase}.jpg')" }
      write("insert ignore into word (word, picture) values #{values.join(",")}")
    end

values = []
id = 1
JSON.parse(IO.read(File.dirname(__FILE__) + "/../../app/assets/wordList.js")).each do |word|
  values << "(#{id}, '#{word.downcase}', '#{word.downcase}.jpg')"
  id += 1
end

conn.write("insert ignore into word(id, word, picture) values #{values.join(",")}")
