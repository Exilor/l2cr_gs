class EffectHandler::OpenChest < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    return unless chest = info.effector.as?(L2ChestInstance)
    return unless pc = info.effector.acting_player
    return if chest.dead? || pc.instance_id != chest.instance_id

    if pc.level <= 77 && (chest.level - pc.level).abs <= 6 || pc.level >= 78 && (chest.level - pc.level).abs <= 5
      pc.broadcast_social_action(3)
      chest.set_special_drop
      chest.must_reward_exp_sp = false
      chest.reduce_current_hp(chest.max_hp.to_f64, pc, info.skill)
    else
      pc.broadcast_social_action(13)
      chest.add_damage_hate(pc, 0, 1)
      chest.set_intention(AI::ATTACK, pc)
    end
  end
end
