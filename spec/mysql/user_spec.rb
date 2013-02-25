require 'spec_helper'

describe MySqlDB::UserDAO do
  def verifyUser(user)
    user.should be_an_instance_of MySqlDB::User
    user.id.should be 1
    user.name.should eq 'test'
    user.email.should eq 'test@gmail.com'
    user.passwordMatch('test').should be true
  end

  before do
    @userDao = MySqlDB::UserDAO.new
  end

  it "Add a user to user table" do
    @userDao.addUser("test", "test@gmail.com", "test").should be 0
  end

	it "Read a user from user table by id" do
    verifyUser(@userDao.getItemById(1))
	end

	it "Read a user from user table by name" do
    verifyUser(@userDao.getUserByName('test'))
	end

	it "Read a user from user table by email" do
    verifyUser(@userDao.getUserByEmail('test@gmail.com'))
	end
end
