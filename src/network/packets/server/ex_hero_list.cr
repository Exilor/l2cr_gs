class Packets::Outgoing::ExHeroList < GameServerPacket
  def initialize
    @hero_list = Hero.heroes
  end

  private def write_impl
    c 0xfe
    h 0x79

    d @hero_list.size
    @hero_list.each_value do |hero|
      s hero.get_string(Olympiad::CHAR_NAME)
      d hero.get_i32(Olympiad::CLASS_ID)
      s hero.get_string(Hero::CLAN_NAME, "")
      d hero.get_i32(Hero::CLAN_CREST, 0)
      s hero.get_string(Hero::ALLY_NAME, "")
      d hero.get_i32(Hero::ALLY_CREST, 0)
      d hero.get_i32(Hero::COUNT)
    end
  end
end
