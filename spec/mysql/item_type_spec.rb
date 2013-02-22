require 'spec_helper'

describe MySqlDB::ItemTypeDAO do
  def verifyItemType(itemType)
    itemType.should be_an_instance_of MySqlDB::ItemType
    itemType.id.should be 1
    itemType.class.should eq 'word'
    itemType.property.should eq 'picture'
  end

	it "Read an item type from item table by id" do
    verifyItemType(MySqlDB::ItemTypeDAO.new().getItemById(1))
	end
end
