require 'spec_helper'

describe MySqlDB::Connection do
	before :each do
		@connection = MySqlDB::Connection.new
	end

	it "Read a user from user table" do
    @connection.read("select * from user limit 1").length.should be 1
	end

  it "Write test user to user table" do
    @connection.write("insert ignore into user (username, email, password) value('test', 'test@gmail.com', 'test')").should be 0
  end
end
