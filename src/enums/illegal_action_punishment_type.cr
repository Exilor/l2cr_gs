enum IllegalActionPunishmentType : UInt8
  NONE, BROADCAST, KICK, KICKBAN, JAIL

  def self.parse(str : String)
    parse?(str) || NONE
  end
end
