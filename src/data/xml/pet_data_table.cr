require "../../models/l2_pet_data"

module PetDataTable
  extend self
  extend XMLReader

  private PETS = {} of Int32 => L2PetData

  def load
    timer = Timer.new
    PETS.clear
    parse_datapack_directory("stats/pets")
    info { "Loaded #{PETS.size} pet data in #{timer}." }
  end

  private def parse_document(doc, file)
    child = doc.children.find { |c| c.element? }.not_nil!
    child.find_element("pet") do |d|
      npc_id = d["id"].to_i
      item_id = d["itemId"].to_i
      data = L2PetData.new(npc_id, item_id)
      d.each_element do |p|
        case p.name
        when "set"
          case p["name"]
          when "food"
            p["val"].split(';') do |food_id|
              data.add_food(food_id.to_i)
            end
          when "hungry_limit"
            data.hungry_limit = p["val"].to_i
          when "sync_level"
            data.sync_level = p["val"].to_i == 1
          else
            # automatically added
          end

        when "skills"
          p.find_element("skill") do |s|
            id = s["skillId"].to_i
            lvl = s["skillLvl"].to_i
            min_lvl = s["minLvl"].to_i
            data.add_new_skill(id, lvl, min_lvl)
          end
        when "stats"
          p.find_element("stat") do |s|
            set = StatsSet.new
            level = s["level"].to_i
            s.each_element do |b|
              if b["name"] == "speed_on_ride"
                set["walkSpeedOnRide"] = b["walk"]
                set["runSpeedOnRide"] = b["run"]
                if temp = b["slowSwim"]?
                  set["slowSwimSpeedOnRide"] = temp
                end
                if temp = b["fastSwim"]?
                  set["fastSwimSpeedOnRide"] = temp
                end
                if fly = b["slowFly"]?
                  set["slowFlySpeedOnRide"] = fly
                end
                if fly = b["fastFly"]?
                  set["fastFlySpeedOnRide"] = fly
                end
              else
                set[b["name"]] = b["val"]
              end
            end
            data.add_new_stat(level, L2PetLevelData.new(set))
          end
        else
          # automatically added
        end

      end

      PETS[npc_id] = data
    end
  end

  def get_pet_data_by_item_id(id : Int) : L2PetData?
    PETS.find_value { |data| data.item_id == id }
  end

  def get_pet_level_data(pet_id : Int, pet_level : Int) : L2PetLevelData?
    get_pet_data(pet_id).try &.get_pet_level_data(pet_level)
  end

  def get_pet_data(pet_id : Int) : L2PetData
    data = PETS.fetch(pet_id) do
      raise "Missing pet data for NPC id #{pet_id}."
    end

    data
  end

  def get_pet_min_level(pet_id : Int) : Int32
    tmp = PETS.fetch(pet_id) do
      raise "No L2PetData for pet id #{pet_id}"
    end

    tmp.min_level.to_i32
  end

  def get_pet_items_by_npc(npc_id : Int) : Int32
    tmp = PETS.fetch(npc_id) do
      raise "No L2PetData for npc id #{npc_id}"
    end

    tmp.item_id
  end

  def mountable?(npc_id : Int32) : Bool
    !MountType.find_by_npc_id(npc_id).none?
  end
end