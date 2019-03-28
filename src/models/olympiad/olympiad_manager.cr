module OlympiadManager
  extend self

  private NON_CLASS_BASED_REGISTERS = [] of Int32
  private CLASS_BASED_REGISTERS = {} of Hash(Int32, Array(Int32))
  private TEAMS_BASED_REGISTERS = [] of Array(Int32)

  def registered_non_class_based : Array(Int32)
    NON_CLASS_BASED_REGISTERS
  end

  def registered_class_based : Hash(Int32, Array(Int32))
    CLASS_BASED_REGISTERS
  end

  def registered_teams_based : Array(Array(Int32))
    TEAMS_BASED_REGISTERS
  end

  def enough_registered_classed : Array(Array(Int32))?
    ret = nil
    CLASS_BASED_REGISTERS.each_value do |class_list|
      if class_list.size >= Config.alt_oly_classed
        (ret ||= [] of Array(Int32)).concat(class_list)
      end
    end
    ret
  end

  def enough_registered_non_classed? : Bool
    NON_CLASS_BASED_REGISTERS.size >= Config.alt_oly_classed
  end

  def enough_registered_teams? : Bool
    TEAMS_BASED_REGISTERS.size >= Config.alt_oly_teams
  end
end
