require "../game_server_packet"

abstract class Packets::Outgoing::OnScreenInfo < GameServerPacket
  private enum Position : UInt8
    TOP_LEFT = 0x01
    TOP_CENTER = 0x02
    TOP_RIGHT = 0x03
    MIDDLE_LEFT = 0x04
    MIDDLE_CENTER = 0x05
    MIDDLE_RIGHT = 0x06
    BOTTOM_CENTER = 0x07
    BOTTOM_RIGHT = 0x08
  end

  abstract def text : String
  abstract def pos : Position

  def write_impl
    c 0xfe
    h 0x39

    d 2
    d -1
    d pos.to_i
    d 0
    d 1
    d 0
    d 0
    d 0
    d 10000
    d 0
    d -1
    s text
  end
end

class Packets::Outgoing::PcInfo < Packets::Outgoing::OnScreenInfo
  getter text

  def initialize(pc : L2PcInstance)
    @text = String.build(500) do |io|
      if target = pc.target
        dst = pc.calculate_distance(target, true, false)
        target_info = "#{target.name} (#{dst.to_i})"
      else
        target_info = "nil"
      end

      io.puts "At: #{pc.x} #{pc.y} #{pc.z}"
      io.puts "To: #{pc.x_destination} #{pc.y_destination} #{pc.z_destination}"
      io.puts "Heading: #{pc.heading}"
      io.puts "Instance: #{pc.instance_id}"
      io.puts "Regenerating: #{!!pc.status.@reg_task}"
      io.puts "Attacking: #{pc.attacking_now?}"
      # io.puts "Attack end time: #{pc.@attack_end_time}"
      # io.puts "Target: #{target_info}"
      # io.puts "AI: #{pc.ai.intention}"
      io.puts "CP reg: #{Formulas.cp_regen(pc).round(2)}"
      io.puts "HP reg: #{Formulas.hp_regen(pc).round(2)}"
      io.puts "MP reg: #{Formulas.mp_regen(pc).round(2)}"

      # if wpn = pc.active_weapon_instance?
      #   mask = wpn.@shots_mask
      #   io.puts "Shots mask: #{mask}"
      # end

      if target = pc.target
        io.puts "Facing target: #{pc.facing?(target, 60)}"
        io.puts "In front of target: #{pc.in_front_of_target?}"
        io.puts "Behind target: #{pc.behind_target?}"
      end

      mp1 = pc.calc_stat(Stats::MAGICAL_MP_CONSUME_RATE, 100).to_i
      if mp1 != 100
        io.puts "Magical MP cost: #{mp1}%"
      end

      mp2 = pc.calc_stat(Stats::PHYSICAL_MP_CONSUME_RATE, 100).to_i
      if mp2 != 100
        io.puts "Physical MP cost: #{mp2}%"
      end

      if pc.class_id.equals_or_child_of?(ClassId::SWORD_SINGER) || pc.class_id.equals_or_child_of?(ClassId::BLADEDANCER)
        mp3 = pc.calc_stat(Stats::DANCE_MP_CONSUME_RATE, 100).to_i
        if mp3 != 100
          io.puts "Song/dance MP cost: #{mp3}%"
        end
      end

      if weapon = pc.active_weapon_item?
        weapon_delay = pc.calculate_reuse_time(weapon)
        if weapon_delay > 0
          io.puts "Weapon delay: #{weapon_delay}"
        end
      end

      reuse = pc.calc_stat(Stats::P_REUSE)
      if reuse != 1
        io.puts "Physical reuse: #{(reuse * 100).round(2)}%"
      end

      reuse = pc.calc_stat(Stats::MAGIC_REUSE_RATE)
      if reuse != 1
        io.puts "Magic reuse: #{(reuse * 100).round(2)}%"
      end

      absorb = pc.calc_stat(Stats::ABSORB_DAMAGE_PERCENT, 0)
      if absorb > 0
        io.puts "Absorb HP: #{absorb.round(2)}%"
      end

      absorb = pc.calc_stat(Stats::ABSORB_MANA_DAMAGE_PERCENT, 0)
      if absorb > 0
        io.puts "Absorb MP: #{absorb.round(2)}%"
      end

      reflect = pc.calc_stat(Stats::REFLECT_DAMAGE_PERCENT, 0)
      if reflect > 0
        io.puts "Reflect damage: #{reflect}%"
      end

      inc_heal = pc.calc_stat(Stats::HEAL_EFFECT, 100)
      if inc_heal != 100
        io.puts "Heal: #{inc_heal.round(2)}%"
      end

      if shld = pc.secondary_weapon_instance?
        if shld.template.type_1 == ItemType1::SHIELD_ARMOR
          shld = pc.calc_stat(Stats::SHIELD_DEFENCE)
          if shld > 1
            io.puts "Shield def: #{shld.round(2)}"
          end

          shld = pc.calc_stat(Stats::SHIELD_RATE)
          if shld > 0
            io.puts "Block rate: #{shld.round(2)}%"
          end
        end
      end

      if wep = pc.active_weapon_instance?
        if wep.item_type == WeaponType::POLE
          if pc.affected?(EffectFlag::SINGLE_TARGET)
            targets = 1
          else
            targets = pc.calc_stat(Stats::ATTACK_COUNT_MAX).to_i
          end
          io.puts "Max targets: #{targets}"
        elsif wep.item_type == WeaponType::BOW || wep.item_type == WeaponType::CROSSBOW
          range = pc.physical_attack_range
          io.puts "Attack range: #{range}"
        end
      end

      if pc.get_known_skill(330) # STR
        chance = pc.calc_stat(Stats::SKILL_CRITICAL_PROBABILITY)
        chance *= BaseStats::STR.calc_bonus(pc)
        io.puts("Skill Mastery: #{chance.round(2)}%")
      end

      if pc.get_known_skill(331) # INT
        chance = pc.calc_stat(Stats::SKILL_CRITICAL_PROBABILITY)
        chance *= BaseStats::INT.calc_bonus(pc)
        io.puts("Skill Mastery: #{chance.round(2)}%")
      end

      mana_gain = pc.calc_stat(Stats::MANA_CHARGE, 100)
      if mana_gain != 100
        io.puts("Mana gain: #{mana_gain.round(2)}%")
      end

      pc.skills.each_value do |skill|
        if skill.magic?
          mcrit = pc.get_m_critical_hit(pc.target.as?(L2Character), nil).fdiv(10)
          io.puts("Magical crit: #{mcrit.round(4)}%")
          break
        end
      end

      if target = pc.target.as?(L2Character)
        evade = ((80 + (2 * (target.accuracy - pc.get_evasion_rate(target)))) * 10).to_i / 10
        io.puts("Evasion: #{100 - evade}%")
        acc = ((80 + (2 * (pc.accuracy - target.get_evasion_rate(pc)))) * 10).to_i / 10
        io.puts("Accuracy: #{acc}%")
      end


    end
  end

  def pos
    Position::MIDDLE_LEFT
  end
end

class Packets::Outgoing::ZoneInfo < Packets::Outgoing::OnScreenInfo
  getter text

  def initialize(pc : L2PcInstance)
    @text = String.build do |io|
      ZoneId.each do |zone|
        if pc.inside_zone?(zone)
          io << zone << " (" << pc.@zones[zone.to_i] << ")\n"
        end
      end
    end
  end

  def pos
    Position::TOP_LEFT
  end
end

class Packets::Outgoing::TargetInfo < Packets::Outgoing::OnScreenInfo
  getter text = ""

  def initialize(pc : L2PcInstance, target : L2Object)
    @text = String.build do |io|
      if target.is_a?(L2Object)
        loc = target.location
        io.puts "At: #{loc.x} #{loc.y} #{loc.z}"
      end
      if target.is_a?(L2Character)
        known_list = target.known_list
        known_players = known_list.known_players.size
        known_objects = known_list.known_objects.size - known_players
        target_info = target.target.try do |t|
          dst = target.calculate_distance(*t.xyz, true, false)
          "#{t.name} (#{dst.to_i})"
        end
        target_info ||= "nil"

        io.puts "To: #{target.x_destination} #{target.y_destination} #{target.z_destination}"
        # io.puts "Heading: #{target.heading}"
        io.puts "Moving: #{target.moving?}"
        io.puts "Running: #{target.running?}"
        io.puts "HP: #{target.current_hp.to_i}/#{target.max_hp}"
        io.puts "MP: #{target.current_mp.to_i}/#{target.max_mp}"
        io.puts "Regenerating: #{!!target.status.@reg_task}"
        io.puts "Target: #{target_info}"
        no_ai = "No AI"
        io.puts "AI: #{target.@ai.try &.intention || no_ai}"
        io.puts "Knows you: #{known_list.known_players.has_key?(pc.l2id)}"
        io.puts "Known players: #{known_players}"
        io.puts "Known objects: #{known_objects}"
      end
      if target.is_a?(L2Attackable)
        in_aggro = target.aggro_range >= pc.calculate_distance(target, true, false)
        in_aggro = "n/a" unless target.aggressive?
        hates_you_info = if info = target.aggro_list.to_h.find { |ch, _| ch.l2id == pc.l2id}
          "true\n  hate: #{info[1].hate}\n  damage: #{info[1].damage}"
        else
          "false"
        end
        io.puts "In aggro range: #{in_aggro}"
        io.puts "Aggro targets: #{target.aggro_list.size}"
        io.puts "Most hated: #{target.most_hated.try &.name}"
        io.puts "Hates you: #{hates_you_info}"
        if target.dead?
          io.puts "Old corpse: #{target.old_corpse?(pc, Config.corpse_consume_skill_allowed_time_before_decay, false)}"
        end

        io.puts "SS chance: #{target.soulshot_chance}"
        io.puts "SS amount: #{target.@soulshot_amount}/#{target.template.soulshot}"
        io.puts "SPS chance: #{target.spiritshot_chance}"
        io.puts "SPS amount: #{target.@spiritshot_amount}/#{target.template.spiritshot}"
      end
    end
  end

  def pos
    Position::MIDDLE_RIGHT
  end
end



class Packets::Outgoing::ServerInfo < Packets::Outgoing::OnScreenInfo
  getter text

  def initialize
    @text = String.build do |io|
      io.puts "IO Buffers: #{GameServer.listener.@writer.@buffers.size}"
      io.puts "ID ranges: #{IdFactory::IDS.ranges.size}"
    end
  end

  def pos
    Position::MIDDLE_LEFT
  end
end
