require "../../models/actor/l2_character"

class BaseStats < EnumClass
  extend XMLReader

  private STR_BONUS = Slice.new(100, 0.0)
  private DEX_BONUS = Slice.new(100, 0.0)
  private CON_BONUS = Slice.new(100, 0.0)
  private INT_BONUS = Slice.new(100, 0.0)
  private WIT_BONUS = Slice.new(100, 0.0)
  private MEN_BONUS = Slice.new(100, 0.0)

  protected def initialize(&@block : L2Character -> Float64)
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
    find_element(doc, "list") do |list|
      each_element(list) do |stat, stat_name|
        find_element(stat, "stat") do |value|
          index = parse_int(value, "value")
          bonus = parse_double(value, "bonus")

          case stat_name.casecmp
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
            raise "Wrong stat name " + stat_name
          end
        end
      end
    end
  end
end
