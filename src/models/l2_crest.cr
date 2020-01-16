struct L2Crest
  enum Type : UInt8
    PLEDGE, PLEDGE_LARGE, ALLY

    def self.get_by_id(id : Int) : self?
      case id
      when 1 then PLEDGE
      when 2 then PLEDGE_LARGE
      when 3 then ALLY
      end
    end

    def id : Int32
      to_i + 1
    end
  end

  PLEDGE = Type::PLEDGE
  PLEDGE_LARGE = Type::PLEDGE_LARGE
  ALLY = Type::ALLY

  getter_initializer id : Int32, data : Bytes, type : Type
end
