require 'mysql'

module MySqlDB

  class Connection
		def initialize
			@config = JSON.parse(IO.read(File.dirname(__FILE__) + "/../assets/mysql/mysql.js"))
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
      
	end
end
