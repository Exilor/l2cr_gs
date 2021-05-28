module TargetHandler::CommandChannel
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    unless pc = char.acting_player
      return EMPTY_TARGET_LIST
    end

    target_list = [pc] of L2Object

    radius = skill.affect_range
    party = pc.party

    if smn = add_summon(char, pc, radius, false)
      target_list << smn
    end

    unless party
      return target_list
    end

    max_targets = skill.affect_limit
    members = party.command_channel.try &.members || party.members

    members.each do |m|
      if pc == m
        next
      end

      if add_character(char, m, radius, false)
        target_list << m
        if target_list.size >= max_targets
          break
        end
      end
    end

    target_list
  end

  def target_type : TargetType
    TargetType::COMMAND_CHANNEL
  end
end
