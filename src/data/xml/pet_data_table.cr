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
    find_element(doc, "pets") do |n|
      find_element(n, "pet") do |d|
        npc_id = parse_int(d, "id")
        item_id = parse_int(d, "itemId")
        data = L2PetData.new(npc_id, item_id)
        each_element(d) do |p, p_name|
          case p_name
          when "set"
            case parse_string(p, "name")
            when "food"
              parse_string(p, "val").split(';') do |food_id|
                data.add_food(food_id.to_i)
              end
            when "hungry_limit"
              data.hungry_limit = parse_int(p, "val")
            when "sync_level"
              data.sync_level = parse_int(p, "val") == 1
            end
          when "skills"
            find_element(p, "skill") do |s|
              id = parse_int(s, "skillId")
              lvl = parse_int(s, "skillLvl")
              min_lvl = parse_int(s, "minLvl")
              data.add_new_skill(id, lvl, min_lvl)
            end
          when "stats"
            find_element(p, "stat") do |s|
              set = StatsSet.new
              level = parse_int(s, "level")

              each_element(s) do |b|
                if parse_string(b, "name") == "speed_on_ride"
                  add_from_node(b, set, "walkSpeedOnRide", "walk")
                  add_from_node(b, set, "runSpeedOnRide", "run")
                  add_from_node(b, set, "slowSwimSpeedOnRide", "slowSwim")
                  add_from_node(b, set, "fastSwimSpeedOnRide", "fastSwim")
                  add_from_node(b, set, "slowFlySpeedOnRide", "slowFly")
                  add_from_node(b, set, "fastFlySpeedOnRide", "fastFly")
                else
                  set[parse_string(b, "name")] = parse_string(b, "val")
                end
              end

              data.add_new_stat(level, L2PetLevelData.new(set))
            end
          end
        end

        PETS[npc_id] = data
      end
    end
  end

  def get_pet_data_by_item_id(id : Int) : L2PetData?
    PETS.find_value { |data| data.item_id == id }
  end

  def get_pet_level_data(pet_id : Int, pet_level : Int) : L2PetLevelData?
    get_pet_data(pet_id).get_pet_level_data(pet_level)
  end

  def get_pet_data(pet_id : Int) : L2PetData
    PETS.fetch(pet_id) { raise "Missing pet data for id #{pet_id}" }
  end

  def get_pet_min_level(pet_id : Int) : Int32
    get_pet_data(pet_id).min_level.to_i32
  end

  def get_pet_items_by_npc(npc_id : Int) : Int32
    get_pet_data(npc_id).item_id
  end

  def mountable?(npc_id : Int32) : Bool
    !MountType.find_by_npc_id(npc_id).none?
  end
end
