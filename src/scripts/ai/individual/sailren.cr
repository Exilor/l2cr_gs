class Scripts::Sailren < AbstractNpcAI
  # NPCs
  private STATUE = 32109 # Shilen's Stone Statue
  private MOVIE_NPC = 32110 # Invisible NPC for movie
  private SAILREN = 29065 # Sailren
  private VELOCIRAPTOR = 22218 # Velociraptor
  private PTEROSAUR = 22199 # Pterosaur
  private TREX = 22217 # Tyrannosaurus
  private CUBIC = 32107 # Teleportation Cubic
  # Item
  private GAZKH = 8784 # Gazkh
  # Skill
  private ANIMATION = SkillHolder.new(5090)
  # Misc
  private RESPAWN = 1 # Respawn time (in hours)
  private MAX_TIME = 3200 # Max time for Sailren fight (in minutes)

  @status = Status::ALIVE
  @kill_count = 0
  @last_attack = 0i64
  @zone : L2NoRestartZone

  enum Status : UInt8
    ALIVE
    IN_COMBAT
    DEAD
  end

  def initialize
    super(self.class.simple_name, "ai/individual")

    @zone = ZoneManager.get_zone_by_id(70049, L2NoRestartZone).not_nil!

    add_start_npc(STATUE, CUBIC)
    add_talk_id(STATUE, CUBIC)
    add_first_talk_id(STATUE)
    add_kill_id(VELOCIRAPTOR, PTEROSAUR, TREX, SAILREN)
    add_attack_id(VELOCIRAPTOR, PTEROSAUR, TREX, SAILREN)

    remain = GlobalVariablesManager.get_i64("SailrenRespawn", 0) - Time.ms
    if remain > 0
      @status = Status::DEAD
      start_quest_timer("CLEAR_STATUS", remain, nil, nil)
    end
  end

  def on_adv_event(event, npc, pc)
    case event
    when "32109-01.html", "32109-01a.html", "32109-02a.html", "32109-03a.html"
      return event
    when "enter"
      pc = pc.not_nil!
      party = pc.party
      if party.nil?
        html = "32109-01.html"
      elsif @status.dead?
        html = "32109-04.html"
      elsif @status.in_combat?
        html = "32109-05.html"
      elsif !party.leader?(pc)
        html = "32109-03.html"
      elsif !has_quest_items?(pc, GAZKH)
        html = "32109-02.html"
      else
        npc = npc.not_nil!
        take_items(pc, GAZKH, 1)
        @status = Status::IN_COMBAT
        @last_attack = Time.ms
        party.members.each do |member|
          if member.inside_radius?(npc, 1000, true, false)
            member.tele_to_location(27549, -6638, -2008)
          end
        end
        start_quest_timer("SPAWN_VELOCIRAPTOR", 60000, nil, nil)
        start_quest_timer("TIME_OUT", MAX_TIME * 1000, nil, nil)
        start_quest_timer("CHECK_ATTACK", 120000, nil, nil)
      end

      return html
    when "teleportOut"
      pc.not_nil!.tele_to_location(TeleportWhereType::TOWN)
    when "SPAWN_VELOCIRAPTOR"
      3.times do |i|
        add_spawn(VELOCIRAPTOR, 27313 + Rnd.rand(150), -6766 + Rnd.rand(150), -1975, 0, false, 0)
      end
    when "SPAWN_SAILREN"
      sailren = add_spawn(SAILREN, 27549, -6638, -2008, 0, false, 0).as(L2RaidBossInstance)
      movie_npc = add_spawn(MOVIE_NPC, sailren.x, sailren.y, sailren.z + 30, 0, false, 26000)
      sailren.invul = true
      sailren.immobilized = true
      @zone.broadcast_packet(SpecialCamera.new(movie_npc, 60, 110, 30, 4000, 1500, 20000, 0, 65, 1, 0, 0))

      start_quest_timer("ATTACK", 24600, sailren, nil)
      start_quest_timer("ANIMATION", 2000, movie_npc, nil)
      start_quest_timer("CAMERA_1", 4100, movie_npc, nil)
    when "ANIMATION"
      if npc
        npc.target = npc
        npc.do_cast(ANIMATION)
        start_quest_timer("ANIMATION", 2000, npc, nil)
      end
    when "CAMERA_1"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 100, 180, 30, 3000, 1500, 20000, 0, 50, 1, 0, 0))
      start_quest_timer("CAMERA_2", 3000, npc, nil)
    when "CAMERA_2"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 150, 270, 25, 3000, 1500, 20000, 0, 30, 1, 0, 0))
      start_quest_timer("CAMERA_3", 3000, npc, nil)
    when "CAMERA_3"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 160, 360, 20, 3000, 1500, 20000, 10, 15, 1, 0, 0))
      start_quest_timer("CAMERA_4", 3000, npc, nil)
    when "CAMERA_4"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 160, 450, 10, 3000, 1500, 20000, 0, 10, 1, 0, 0))
      start_quest_timer("CAMERA_5", 3000, npc, nil)
    when "CAMERA_5"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 160, 560, 0, 3000, 1500, 20000, 0, 10, 1, 0, 0))
      start_quest_timer("CAMERA_6", 7000, npc, nil)
    when "CAMERA_6"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 70, 560, 0, 500, 1500, 7000, -15, 20, 1, 0, 0))
    when "ATTACK"
      npc = npc.not_nil!
      npc.invul = false
      npc.immobilized = false
    when "CLEAR_STATUS"
      @status = Status::ALIVE
    when "TIME_OUT"
      if @status.in_combat?
        @status = Status::ALIVE
      end
      @zone.characters_inside.each do |char|
        if char.player?
          char.tele_to_location(TeleportWhereType::TOWN)
        elsif char.npc?
          char.delete_me
        end
      end
    when "CHECK_ATTACK"
      if @zone.players_inside.any? && @last_attack + 600000 < Time.ms
        cancel_quest_timer("TIME_OUT", nil, nil)
        notify_event("TIME_OUT", nil, nil)
      else
        start_quest_timer("CHECK_ATTACK", 120000, nil, nil)
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if @zone.character_in_zone?(attacker)
      @last_attack = Time.ms
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if @zone.character_in_zone?(killer)
      case npc.id
      when SAILREN
        @status = Status::DEAD
        add_spawn(CUBIC, 27644, -6638, -2008, 0, false, 300000)
        respawn_time = RESPAWN * 3600000
        GlobalVariablesManager["SailrenRespawn"] = Time.ms + respawn_time
        cancel_quest_timer("CHECK_ATTACK", nil, nil)
        cancel_quest_timer("TIME_OUT", nil, nil)
        start_quest_timer("CLEAR_STATUS", respawn_time, nil, nil)
        start_quest_timer("TIME_OUT", 300000, nil, nil)
      when VELOCIRAPTOR
        @kill_count += 1
        if @kill_count == 3
          pterosaur = add_spawn(PTEROSAUR, 27313, -6766, -1975, 0, false, 0)
          add_attack_desire(pterosaur, killer)
          @kill_count = 0
        end
      when PTEROSAUR
        trex = add_spawn(TREX, 27313, -6766, -1975, 0, false, 0)
        add_attack_desire(trex, killer)
      when TREX
        start_quest_timer("SPAWN_SAILREN", 180000, nil, nil)
      end
    end

    super
  end

  def unload(remove_from_list)
    if @status.in_combat?
      warn "Script is being unloaded while Sailren is active, clearing zone."
      notify_event("TIME_OUT", nil, nil)
    end

    super
  end
end
