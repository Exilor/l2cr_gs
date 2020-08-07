require "../../../models/actor/l2_npc"

class Packets::Outgoing::NpcInfo < Packets::Outgoing::AbstractNpcInfo
  @clan_crest = 0
  @ally_crest = 0
  @ally_id = 0
  @clan_id = 0
  @id_template : Int32
  @r_hand : Int32
  @l_hand : Int32
  @enchant_effect : Int32
  @attackable = false
  @name : String
  @title : String?
  @display_effect : Int32

  def initialize(@npc : L2Npc, attacker : L2Character?)
    super(npc)

    @id_template = npc.template.display_id
    @r_hand = npc.right_hand_item
    @l_hand = npc.left_hand_item
    @enchant_effect = npc.enchant_effect
    @collision_height = npc.collision_height
    @collision_radius = npc.collision_radius
    if attacker
      @attackable = npc.auto_attackable?(attacker)
    end
    if npc.template.using_server_side_name?
      @name = npc.name
    end

    if npc.invisible?
      @title = "Invisible"
    elsif npc.champion?
      @title = "Champion"
    elsif npc.template.using_server_side_title?
      @title = npc.template.title
    else
      if title = npc.title
        @title = title
      end
    end

    if Config.show_npc_lvl && @npc.monster?
      if @title
        @title = "Lv #{npc.level}#{'*' if npc.aggressive?} #{@title}"
      else
        @title = "Lv #{npc.level}#{'*' if npc.aggressive?}"
      end
    end

    if npc.is_a?(L2NpcInstance) && npc.inside_town_zone? && (Config.show_crest_without_quest || (npc.castle? && npc.castle.show_npc_crest?)) && npc.castle.owner_id != 0
      town_id = TownManager.get_town(@x, @y, @z).not_nil!.town_id
      if town_id != 33 && town_id != 22
        clan = ClanTable.get_clan(npc.castle.owner_id).not_nil!
        @clan_crest = clan.crest_id
        @clan_id = clan.id
        @ally_crest = clan.ally_crest_id
        @ally_id = clan.ally_id
      end
    end

    @display_effect = npc.display_effect
  end

  private def write_impl
    c 0x0c

    d @npc.l2id
    d @id_template + 1_000_000
    d @attackable ? 1 : 0
    d @x
    d @y
    d @z
    q @heading
    d @m_atk_spd
    d @p_atk_spd
    d @run_spd
    d @walk_spd
    d @swim_run_spd
    d @swim_walk_spd
    d @fly_run_spd
    d @fly_walk_spd
    d @fly_run_spd
    d @fly_walk_spd

    f @move_multiplier
    f @npc.attack_speed_multiplier
    f @collision_radius
    f @collision_height

    d @r_hand
    d @chest
    d @l_hand

    c 1 # name above char: 1 = true
    c @npc.running? ? 1 : 0
    c @npc.in_combat? ? 1 : 0
    c @npc.looks_dead? ? 1 : 0
    c @summoned ? 2 : 0

    d -1
    s @name
    d -1
    s @title

    d 0x00 # Title color 0=client default
    d 0x00 # pvp flag
    d 0x00 # karma

    ave = @npc.abnormal_visual_effects
    ave |= AbnormalVisualEffect::STEALTH.mask if @npc.invisible?
    d ave

    d @clan_id
    d @clan_crest
    d @ally_id
    d @ally_crest

    c @npc.inside_water_zone? ? 1 : @npc.flying? ? 2 : 0
    c @npc.team.to_i

    f @collision_radius
    f @collision_height

    d @enchant_effect
    d @npc.flying? ? 1 : 0
    d 0x00
    d @npc.color_effect

    c @npc.targetable? ? 1 : 0
    c @npc.show_name? ? 1 : 0
    d @npc.abnormal_visual_effects_special
    d @display_effect
  end
end
