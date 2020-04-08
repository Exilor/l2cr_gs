module TargetHandler::PartyOther
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target && target != char && (p1 = char.party) && (p2 = target.party)
      if p1 == p2
        if target.alive?
          if target.is_a?(L2PcInstance)
            case skill.id
            when 426
              if target.mage_class?
                return EMPTY_TARGET_LIST
              end

              return [target] of L2Object
            when 427
              if target.mage_class?
                return [target] of L2Object
              end

              return EMPTY_TARGET_LIST
            else
              # automatically added
            end

          end

          return [target] of L2Object
        else
          return EMPTY_TARGET_LIST
        end
      end
    end

    char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::PARTY_OTHER
  end
end