require "../../enums/stat_type"
require "../../models/l2_recipe_instance"
require "../../models/l2_recipe_list"
require "../../models/l2_recipe_stat_instance"

module RecipeData
  extend self
  extend XMLReader

  private RECIPES = {} of Int32 => L2RecipeList

  def load
    RECIPES.clear
    parse_datapack_file("recipes.xml")
    info { "Loaded #{RECIPES.size} recipes." }
  end

  private def parse_document(doc : XML::Node, file : File)
    recipe_part_list = [] of L2RecipeInstance
    recipe_stat_use_list = [] of L2RecipeStatInstance
    recipe_alt_stat_change_list = [] of L2RecipeStatInstance

    find_element(doc, "list") do |n|
      find_element(n, "item") do |d|
        recipe_part_list.clear
        recipe_stat_use_list.clear
        recipe_alt_stat_change_list.clear

        has_rare = false
        set = StatsSet.new

        set["id"] = parse_int(d, "id")
        set["recipeId"] = parse_int(d, "recipeId")
        set["recipeName"] = parse_string(d, "name")
        set["craftLevel"] = parse_int(d, "craftLevel")
        set["isDwarvenRecipe"] = parse_string(d, "type").casecmp?("dwarven")
        set["successRate"] = parse_int(d, "successRate")
        each_element(d) do |c, c_name|
          case c_name.casecmp
          when "statUse"
            stat_name = parse_string(c, "name")
            value = parse_int(c, "value")
            recipe_stat_use_list << L2RecipeStatInstance.new(stat_name, value)
          when "altStatChange"
            stat_name = parse_string(c, "name")
            value = parse_int(c, "value")
            recipe_alt_stat_change_list << L2RecipeStatInstance.new(stat_name, value)
          when "ingredient"
            id = parse_int(c, "id")
            count = parse_int(c, "count")
            recipe_part_list << L2RecipeInstance.new(id, count)
          when "production"
            set["itemId"] = parse_int(c, "id")
            set["count"] = parse_int(c, "count")
          when "productionRare"
            set["rareItemId"] = parse_int(c, "id")
            set["rareCount"] = parse_int(c, "count")
            set["rarity"] = parse_int(c, "rarity")
            has_rare = true
          end
        end

        recipe_list = L2RecipeList.new(set, has_rare)
        recipe_part_list.each { |x| recipe_list.add_recipe(x) }
        recipe_stat_use_list.each { |x| recipe_list.add_stat_use(x) }
        recipe_alt_stat_change_list.each do |x|
          recipe_list.add_alt_stat_change(x)
        end

        RECIPES[recipe_list.id] = recipe_list
      end
    end
  end

  def get_recipe_list(id : Int32) : L2RecipeList
    RECIPES[id]
  end

  def get_recipe_by_item_id(item_id : Int32) : L2RecipeList?
    RECIPES.find_value { |rcp| rcp.recipe_id == item_id }
  end

  def get_valid_recipe_list(pc : L2PcInstance?, id : Int32) : L2RecipeList?
    list = RECIPES[id]?
    if list.nil? || list.recipes.empty?
      pc.send_message("No recipe for id #{id}")
      pc.in_craft_mode = false
      return
    end
    list
  end
end
