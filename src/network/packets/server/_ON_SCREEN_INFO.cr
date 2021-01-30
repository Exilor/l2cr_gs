require "../game_server_packet"

abstract class Packets::Outgoing::OnScreenInfo < GameServerPacket
  TOP_LEFT = 0x01
  TOP_CENTER = 0x02
  TOP_RIGHT = 0x03
  MIDDLE_LEFT = 0x04
  MIDDLE_CENTER = 0x05
  MIDDLE_RIGHT = 0x06
  BOTTOM_CENTER = 0x07
  BOTTOM_RIGHT = 0x08

  abstract def text
  abstract def pos

  private def write_impl
    c 0xfe
    h 0x39

    d 2
    d -1
    d pos
    d 0
    d 1
    d 0
    d 0
    d 0
    d 1000
    d 0
    d -1
    s text
  end

  private def pr(io : IO, *args)
    io.print(*args, "\n")
  end
end

class Packets::Outgoing::PcInfo < Packets::Outgoing::OnScreenInfo
  getter text

  def initialize(pc : L2PcInstance)
    @text = String.build(500) do |io|
      pr(io, "At: ", pc.x, ' ', pc.y, ' ', pc.z)
      pr(io, "To: ", pc.x_destination, ' ', pc.y_destination, ' ', pc.z_destination)
      pr(io, "Heading: ", pc.heading)
      if pc.instance_id != 0
        pr(io, "Instance: ", pc.instance_id)
      end
      pr(io, "Regenerating: ", !!pc.status.@reg_task)
      pr(io, "Attacking: ", pc.attacking_now?)
      # pr(io, "Attack end time: #{pc.@attack_end_time}")
      # pr(io, "AI: #{pc.ai.intention}")
      pr(io, "CP reg: ", Formulas.cp_regen(pc).round(2))
      pr(io, "HP reg: ", Formulas.hp_regen(pc).round(2))
      pr(io, "MP reg: ", Formulas.mp_regen(pc).round(2))

      # if wpn = pc.active_weapon_instance
      #   mask = wpn.@shots_mask
      #   pr(io, "Shots mask: #{mask}")
      # end

      if target = pc.target
        pr(io, "Facing target: ", pc.facing?(target, 60))
        pr(io, "In front of target: ", pc.in_front_of_target?)
        pr(io, "Behind target: ", pc.behind_target?)
      end

      mp1 = pc.calc_stat(Stats::MAGICAL_MP_CONSUME_RATE, 100).to_i
      if mp1 != 100
        pr(io, "Spell cost: ", mp1, '%')
      end

      mp2 = pc.calc_stat(Stats::PHYSICAL_MP_CONSUME_RATE, 100).to_i
      if mp2 != 100
        pr(io, "Skill cost: ", mp2, '%')
      end

      case pc.class_id
      when .equals_or_child_of?(ClassId::SWORD_SINGER), .equals_or_child_of?(ClassId::BLADEDANCER)
        mp3 = pc.calc_stat(Stats::DANCE_MP_CONSUME_RATE, 100).to_i
        if mp3 != 100
          pr(io, "Song/dance cost: ", mp3, '%')
        end
      end

      if weapon = pc.active_weapon_item
        weapon_delay = pc.calculate_reuse_time(weapon)
        if weapon_delay > 0
          pr(io, "Weapon delay: ", weapon_delay)
        end
      end

      reuse = pc.calc_stat(Stats::P_REUSE)
      if reuse != 1
        pr(io, "Physical reuse: ", (reuse * 100).round(2), '%')
      end

      reuse = pc.calc_stat(Stats::MAGIC_REUSE_RATE)
      if reuse != 1
        pr(io, "Magic reuse: ", (reuse * 100).round(2), '%')
      end

      absorb = pc.calc_stat(Stats::ABSORB_DAMAGE_PERCENT, 0)
      if absorb != 0
        pr(io, "Absorb HP: ", absorb.round(2), '%')
      end

      absorb = pc.calc_stat(Stats::ABSORB_MANA_DAMAGE_PERCENT, 0)
      if absorb != 0
        pr(io, "Absorb MP: ", absorb.round(2), '%')
      end

      reflect = pc.calc_stat(Stats::REFLECT_DAMAGE_PERCENT, 0)
      if reflect != 0
        pr(io, "Reflect damage: ", reflect.round(2), '%')
      end

      inc_heal = pc.calc_stat(Stats::HEAL_EFFECT, 100)
      if inc_heal != 100
        pr(io, "Heal: ", inc_heal.round(2), '%')
      end

      if shld = pc.secondary_weapon_instance
        if shld.template.type_1 == ItemType1::SHIELD_ARMOR
          shld = pc.calc_stat(Stats::SHIELD_DEFENCE)
          if shld > 1
            pr(io, "Shield def: ", shld.round(2))
          end

          shld = pc.calc_stat(Stats::SHIELD_RATE)
          if shld > 0
            pr(io, "Block rate: ", shld.round(2), '%')
          end
        end
      end

      if wep = pc.active_weapon_instance
        if wep.item_type == WeaponType::POLE
          if pc.affected?(EffectFlag::SINGLE_TARGET)
            targets = 1
          else
            targets = pc.calc_stat(Stats::ATTACK_COUNT_MAX).to_i
          end
          pr(io, "Max targets: ", targets)
        elsif wep.item_type.in?(WeaponType::BOW, WeaponType::CROSSBOW)
          range = pc.physical_attack_range
          pr(io, "Attack range: ", range)
        end
      end

      if pc.get_known_skill(330) # STR
        chance = pc.calc_stat(Stats::SKILL_CRITICAL_PROBABILITY)
        chance *= BaseStats::STR.calc_bonus(pc)
        pr(io, "Skill Mastery: ", chance.round(2), '%')
      end

      if pc.get_known_skill(331) # INT
        chance = pc.calc_stat(Stats::SKILL_CRITICAL_PROBABILITY)
        chance *= BaseStats::INT.calc_bonus(pc)
        pr(io, "Skill Mastery: ", chance.round(2), '%')
      end

      mana_gain = pc.calc_stat(Stats::MANA_CHARGE, 100)
      if mana_gain != 100
        pr(io, "Mana gain: ", mana_gain.round(2), '%')
      end

      pc.skills.each_value do |skill|
        if skill.magic?
          mcrit = pc.get_m_critical_hit(pc.target.as?(L2Character), nil).fdiv(10)
          pr(io, "Magical crit: ", mcrit.round(2), '%')
          break
        end
      end

      if target = pc.target.as?(L2Character)
        evade = ((80 + (2 * (target.accuracy - pc.get_evasion_rate(target)))) * 10).to_i / 10
        pr(io, "Evasion: ", 100 - evade, '%')
        acc = ((80 + (2 * (pc.accuracy - target.get_evasion_rate(pc)))) * 10).to_i / 10
        pr(io, "Accuracy: ", acc, '%')
      end


    end
  end

  def pos
    MIDDLE_LEFT
  end
end

class Packets::Outgoing::ZoneInfo < Packets::Outgoing::OnScreenInfo
  getter text

  def initialize(pc : L2PcInstance)
    @text = String.build do |io|
      ZoneId.each do |zone|
        if pc.inside_zone?(zone)
          pr(io, zone, " (", pc.@zones[zone.to_i], ')')
        end
      end
    end
  end

  def pos
    TOP_LEFT
  end
end

class Packets::Outgoing::TargetInfo < Packets::Outgoing::OnScreenInfo
  getter text = ""

  def initialize(pc : L2PcInstance, target : L2Object)
    @text = String.build do |io|
      if target.is_a?(L2Object)
        loc = target.location
        pr(io, "At: ", loc.x, ' ', loc.y, ' ', loc.z)
      end
      if target.is_a?(L2Character)
        known_list = target.known_list
        known_players = known_list.known_players.size
        known_objects = known_list.known_objects.size &- known_players

        pr(io, "To: ", target.x_destination, ' ', target.y_destination, ' ', target.z_destination)
        # pr(io, "Heading: ", target.heading)
        pr(io, "Moving: ", target.moving?)
        pr(io, "Running: ", target.running?)
        pr(io, "HP: ", target.current_hp.to_i, '/', target.max_hp)
        pr(io, "MP: ", target.current_mp.to_i, '/', target.max_mp)
        pr(io, "Regenerating: #{!!target.status.@reg_task}")
        if t = target.target
          dst = target.calculate_distance(*t.xyz, true, false)
          pr(io, "Target: ", t.name, " (", dst.to_i, ')')
        else
          pr(io, "Target: ", "nil")
        end

        pr(io, "AI: ", target.@ai.try &.intention || "No AI")
        pr(io, "Knows you: ", known_list.known_players.has_key?(pc.l2id))
        pr(io, "Known players: ", known_players)
        pr(io, "Known objects: ", known_objects)
      end
      if target.is_a?(L2Attackable)
        in_aggro = target.aggro_range >= pc.calculate_distance(target, true, false)
        in_aggro = "n/a" unless target.aggressive?
        pr(io, "In aggro range: ", in_aggro)
        pr(io, "Aggro targets: ", target.aggro_list.size)
        pr(io, "Most hated: ", target.most_hated.try &.name)
        if info = target.aggro_list.to_h.find { |ch, _| ch.l2id == pc.l2id}
          pr(io, "Hates you: ", "true\n  hate: ", info[1].hate, "\n  damage: ", info[1].damage)
        else
          pr(io, "Hates you: ", "false")
        end


        if target.dead?
          pr(io, "Old corpse: ",
            target.old_corpse?(pc, Config.corpse_consume_skill_allowed_time_before_decay, false)
          )
        end

        pr(io, "SS chance: ", target.soulshot_chance)
        pr(io, "SS amount: ", target.@soulshot_amount, '/', target.template.soulshot)
        pr(io, "SPS chance: ", target.spiritshot_chance)
        pr(io, "SPS amount: ", target.@spiritshot_amount, '/', target.template.spiritshot)
      end
    end
  end

  def pos
    MIDDLE_RIGHT
  end


end



class Packets::Outgoing::ServerInfo < Packets::Outgoing::OnScreenInfo
  getter text

  def initialize
    @text = String.build do |io|
      # io.puts "IO Buffers: #{GameServer.listener.@writer.@buffers.size}"
      pr(io, "ID ranges: ", IdFactory::IDS.ranges.size)
    end
  end

  def pos
    MIDDLE_LEFT
  end
end
