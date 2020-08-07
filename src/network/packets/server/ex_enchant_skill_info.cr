class Packets::Outgoing::ExEnchantSkillInfo < GameServerPacket
  @routes = [] of Int32
  @max_enchanted = false

  def initialize(id : Int32, lvl : Int32)
    @id = id
    @lvl = lvl

    if esl = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@id)
      if @lvl > 100
        @max_enchanted = esl.max_enchant?(@lvl)

        if esd = esl.get_enchant_skill_holder(@lvl)
          @routes << @lvl
        end

        skill_lvl = @lvl % 100

        esl.each_route do |route|
          tmp = (route &* 100) &+ skill_lvl
          if tmp == @lvl
            next
          end
          @routes << tmp
        end
      else
        esl.each_route do |route|
          @routes << (route &* 100) &+ 1
        end
      end
    end
  end

  private def write_impl
    c 0xfe
    h 0x2a

    d @id
    d @lvl
    d @max_enchanted ? 0 : 1
    d @lvl > 100 ? 1 : 0
    d @routes.size
    @routes.each { |level| d level }
  end
end
