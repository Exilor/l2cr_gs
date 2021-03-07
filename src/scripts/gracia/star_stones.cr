class Scripts::StarStones < AbstractNpcAI
  private MOBS = {
    18684, 18685, 18686, 18687, 18688, 18689, 18690, 18691, 18692
  }
  private COLLECTION_RATE = 1i64

  def initialize
    super(self.class.simple_name, "gracia/AI")
    add_skill_see_id(MOBS)
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if skill.id == 932
      case npc.id
      when 18684..18686
        # give Red item
        item_id = 14009
      when 18687..18689
        # give Blue item
        item_id = 14010
      when 18690..18692
        # give Green item
        item_id = 14011
      else
        return super
      end

      if Rnd.rand(100) < 33
        caster.send_packet(SystemMessageId::THE_COLLECTION_HAS_SUCCEEDED)
        caster.add_item("StarStone", item_id, Rnd.rand(COLLECTION_RATE + 1..2i64 * COLLECTION_RATE), nil, true)
      elsif (skill.level == 1 && Rnd.rand(100) < 15) || (skill.level == 2 && Rnd.bool) || (skill.level == 3 && Rnd.rand(100) < 75)
        caster.send_packet(SystemMessageId::THE_COLLECTION_HAS_SUCCEEDED)
        caster.add_item("StarStone", item_id, Rnd.rand(1i64..COLLECTION_RATE), nil, true)
      else
        caster.send_packet(SystemMessageId::THE_COLLECTION_HAS_FAILED)
      end

      npc.delete_me
    end

    super
  end
end
