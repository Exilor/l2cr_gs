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

  private def parse_document(doc, file)
    recipe_part_list = [] of L2RecipeInstance
    recipe_stat_use_list = [] of L2RecipeStatInstance
    recipe_alt_stat_change_list = [] of L2RecipeStatInstance
    doc.find_element("list") do |n|
      n.find_element("item") do |d|
        recipe_part_list.clear
        recipe_stat_use_list.clear
        recipe_alt_stat_change_list.clear

        has_rare = false
        set = StatsSet.new

        set["id"] = d["id"].to_i
        set["recipeId"] = d["recipeId"].to_i
        set["recipeName"] = d["name"]
        set["craftLevel"] = d["craftLevel"].to_i
        set["isDwarvenRecipe"] = d["type"].casecmp?("dwarven")
        set["successRate"] = d["successRate"].to_i
        d.each_element do |c|
          case c.name.casecmp
          when "statUse"
            stat_name = c["name"]
            value = c["value"].to_i
            recipe_stat_use_list << L2RecipeStatInstance.new(stat_name, value)
          when "altStatChange"
            stat_name = c["name"]
            value = c["value"].to_i
            recipe_alt_stat_change_list << L2RecipeStatInstance.new(stat_name, value)
          when "ingredient"
            id = c["id"].to_i
            count = c["count"].to_i
            recipe_part_list << L2RecipeInstance.new(id, count)
          when "production"
            set["itemId"] = c["id"].to_i
            set["count"] = c["count"].to_i
          when "productionRare"
            set["rareItemId"] = c["id"].to_i
            set["rareCount"] = c["count"].to_i
            set["rarity"] = c["rarity"].to_i
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
      pc.send_message("No recipe for ID #{id}")
      pc.in_craft_mode = false
      return
    end
    list
  end
end
