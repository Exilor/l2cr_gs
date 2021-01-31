class EffectHandler::RestorationRandom < AbstractEffect
  def on_start(info : BuffInfo)
    return unless info.effector.player? && info.effected.player?

    unless ex_skill = info.skill.extractable_skill
      raise "No extractable_skill for #{info.skill}"
    end

    if ex_skill.product_items.empty?
      raise "Extractable skill with an empty skill list: #{info.skill}"
    end

    rnd = Rnd.rand * 100
    chance_from = 0
    creation_list = [] of ItemHolder

    ex_skill.product_items.each do |expi|
      chance = expi.chance
      if rnd >= chance_from && rnd <= chance + chance_from
        creation_list.concat(expi.items)
        break
      end
      chance_from += chance
    end

    pc = info.effected.acting_player.not_nil!

    if creation_list.empty?
      pc.send_packet(SystemMessageId::NOTHING_INSIDE_THAT)
      return
    end

    creation_list.each do |item|
      next if item.id <= 0 || item.count <= 0
      count = (item.count * Config.rate_extractable).to_i64
      pc.add_item("Extract", item.id, count, info.effector, true)
    end
  end

  def instant? : Bool
    true
  end
end
