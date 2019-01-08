module GameDB
  module ItemDAOMySQLImpl
    extend self
    extend ItemDAO

    private SELECT = "SELECT object_id FROM `items` WHERE `owner_id`=? AND (`loc`='PET' OR `loc`='PET_EQUIP') LIMIT 1;"

    def load_pet_inventory(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id) do |rs|
        pc.has_pet_items = rs.get_i32("object_id") > 0
        return
      end

      pc.has_pet_items = false
    rescue e
      error e
    end
  end
end
