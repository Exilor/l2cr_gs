struct CubicHeal
  initializer cubic : L2CubicInstance

  def call
    if @cubic.owner.dead? || !@cubic.owner.online?
      @cubic.stop_action
      @cubic.owner.cubics.delete(@cubic.id)
      @cubic.owner.broadcast_user_info
      @cubic.cancel_disappear
      return
    end

    skill = @cubic.skills.find { |s| s.id == L2CubicInstance::SKILL_CUBIC_HEAL }
    return unless skill

    @cubic.cubic_target_for_heal
    return unless target = @cubic.target

    if target.alive?
      skill.activate_skill(@cubic, target)
      msu = Packets::Outgoing::MagicSkillUse.new(@cubic.owner, target, skill.id, skill.level, 0, 0)
      @cubic.owner.broadcast_packet(msu)
    end
  end
end
