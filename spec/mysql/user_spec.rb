require 'spec_helper'

describe MySqlDB::User do
  def verifyUser(user)
    user.should be_an_instance_of MySqlDB::User
    user.id.should be 1
    user.name.should eq 'test'
    user.email.should eq 'test@gmail.com'
    user.password.should eq 'test'
  end

	it "Read a user from user table by id" do
    verifyUser(MySqlDB::User.getUserById(1))
	end

	it "Read a user from user table by name" do
    verifyUser(MySqlDB::User.getUserByName('test'))
	end

	it "Read a user from user table by email" do
    verifyUser(MySqlDB::User.getUserByEmail('test@gmail.com'))
	end
end
