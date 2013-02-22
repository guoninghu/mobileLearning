require_relative './connection'
require 'json'

module MySqlDB

  class ItemType
    attr_reader :id, :class, :property

    def initialize(item)
      @id, @class, @property = item[0].to_i, item[1], item[2]
    end

    def to_json
      {id: @id, class: @class, property: @property}.to_json
    end
  end

  class ItemTypeDAO < ItemDAO
    def initialize
      super("select id, class, property from item_type where ")
		end

    def createItem(item)
			ItemType.new(item)
		end
  end
end
