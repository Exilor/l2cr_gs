require "../../holders/range_chance_holder"

struct EnchantItemGroup
  include Loggable

  @chances = [] of RangeChanceHolder

  getter_initializer name : String

  def add_chance(holder : RangeChanceHolder)
    @chances << holder
  end

  def get_chance(index : Int) : Float64
    unless @chances.empty?
      @chances.each do |holder|
        if index.between?(holder.min, holder.max)
          return holder.chance
        end
      end
      warn { "Couldn't match chance for item group '#{@name}'." }
      return @chances.last.chance
    end
    warn { "Item group '#{@name}' doesn't have any @chances." }
    -1f64
  end
end
