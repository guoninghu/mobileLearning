require 'spec_helper'

describe MySqlDB::AmateurDAO do
  def verifyAmateur(amateur, user, name)
    amateur.should be_an_instance_of MySqlDB::Amateur
    amateur.user.should eq user
    amateur.name.should eq name
	end

  before do
    @amateurDao = MySqlDB::AmateurDAO.new
  end

	it "Add an amateur" do
	  @amateurDao.addAmateur("test2", 1)
		amateur = @amateurDao.getAmateurByName("test2", 1)
		verifyAmateur(amateur, 1, "test2")
		amateur = @amateurDao.getItemById(amateur.id)
		verifyAmateur(amateur, 1, "test2")
	end

	it "Delete an amateur" do
	  amateur = @amateurDao.getAmateurByName("test2", 1)
		verifyAmateur(amateur, 1, "test2")
		@amateurDao.deleteAmateur("test2", 1)
		@amateurDao.getAmateurByName("test2", 1).should be nil
	end

  it "Add an amateur to a user" do
    amateurs = MySqlDB::UserAmateur.new(1)
    amateurs.addAmateur("test2")
    amateurs.hasAmateur("test2").should be_true
    amateur = @amateurDao.getAmateurByName("test2", 1)
		verifyAmateur(amateur, 1, "test2")
  end

  it "Delete an amateur from a user" do
    amateurs = MySqlDB::UserAmateur.new(1)
    amateurs.deleteAmateur("test2")
    amateurs.hasAmateur("test2").should be_false
    amateur = @amateurDao.getAmateurByName("test2", 1).should be nil
  end
end
