require "../../models/actor/l2_character"

class BaseStats < EnumClass
  extend XMLReader

  private STR_BONUS = Slice.new(100, 0.0)
  private DEX_BONUS = Slice.new(100, 0.0)
  private CON_BONUS = Slice.new(100, 0.0)
  private INT_BONUS = Slice.new(100, 0.0)
  private WIT_BONUS = Slice.new(100, 0.0)
  private MEN_BONUS = Slice.new(100, 0.0)

  def initialize(&@block : L2Character -> Float64)
  end

  def calc_bonus(char)
    @block.call(char)
  end

  add(STR) { |char| STR_BONUS[char.str] }
  add(DEX) { |char| DEX_BONUS[char.dex] }
  add(CON) { |char| CON_BONUS[char.con] }
  add(INT) { |char| INT_BONUS[char.int] }
  add(WIT) { |char| WIT_BONUS[char.wit] }
  add(MEN) { |char| MEN_BONUS[char.men] }
  add(NONE) { |char| 1.0 }

  def self.load
    parse_datapack_file("stats/statBonus.xml")
  end

  private def self.parse_document(doc, file)
    doc.find_element("list") do |list|
      list.each_element do |stat|
        stat.find_element("stat") do |value|
          index = value["value"].to_i
          bonus = value["bonus"].to_f

          case stat.name.casecmp
          when "STR"
            STR_BONUS[index] = bonus
          when "DEX"
            DEX_BONUS[index] = bonus
          when "CON"
            CON_BONUS[index] = bonus
          when "INT"
            INT_BONUS[index] = bonus
          when "WIT"
            WIT_BONUS[index] = bonus
          when "MEN"
            MEN_BONUS[index] = bonus
          else
            raise "Wrong stat name #{stat.name}"
          end
        end
      end
    end
  end
end
