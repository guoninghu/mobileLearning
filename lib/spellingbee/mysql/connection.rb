require 'mysql'
require 'json'

module MySqlDB

  class SConnection
    def initialize
      @config = {"host" => "localhost", "port" => 3306, "user" => "root", "dbName" => "spellingbee"}
		end

		def getConnection
			Mysql.real_connect(@config["host"], @config["user"], @config["passwd"], @config["dbName"], @config["port"])
		end

		def read(query)
			begin
				ret_val = []
				conn = getConnection
        conn.query(query).each { |row| ret_val << row }
				
				return ret_val

			rescue Mysql::Error => e
			  puts e
        puts e.backtrace
				return nil
			ensure
			  conn.close if conn
			end
		end

    def write(query)
      begin
        conn = getConnection
        conn.query(query)
        return conn.affected_rows

			rescue Mysql::Error => e
			  puts e
        puts e.backtrace
				return nil
			ensure
			  conn.close if conn
			end
		end

    def insert(query)
      begin
        conn = getConnection
        conn.query(query)
        return conn.insert_id

			rescue Mysql::Error => e
			  puts e
        puts e.backtrace
				return nil
			ensure
			  conn.close if conn
			end
		end
  end

  class SItemDAO
    @@connection = SConnection.new

    def initialize(query)
      @query = query
    end

    def createItem(item)
      return {id: item[0].to_i}
    end

    def getItems(condition)
			items = @@connection.read(@query + condition)
			return nil if items.nil?

      ret_val = []
      items.each{|item| ret_val << createItem(item) }
		  return ret_val
    end

    def getItem(condition)
		  items = getItems(condition)
      return nil if items.nil? || items.length == 0
      return items[0]
    end
		
    def getItemById(id)
			getItem("id=#{id}")
		end

		def getItemByName(name)
			getItem("name='#{name}'")
		end

    def write(query)
      @@connection.write(query)
    end

    def insert(query)
      @@connection.insert(query)
    end

    def read(query)
      @@connection.read(query)
    end
  end
end
