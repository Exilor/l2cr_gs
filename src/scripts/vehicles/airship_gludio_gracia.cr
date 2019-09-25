require "../../instance_managers/airship_manager"
require "./boat_engine"

class Scripts::AirShipGludioGracia < AbstractNpcAI
  include Loggable

  private CONTROLLERS = {32607, 32609}
  private GLUDIO_DOCK_ID = 10
  private GRACIA_DOCK_ID = 11

  private OUST_GLUDIO = Location.new(-149379, 255246, -80)
  private OUST_GRACIA = Location.new(-186563, 243590, 2608)

  private GLUDIO_TO_WARPGATE = [
    VehiclePathPoint.new(-151202, 252556, 231),
    VehiclePathPoint.new(-160403, 256144, 222),
    VehiclePathPoint.new(-167874, 256731, -509, 0, 41035)
  ]

  private WARPGATE_TO_GRACIA = [
    VehiclePathPoint.new(-169763, 254815, 282),
    VehiclePathPoint.new(-171822, 250061, 425),
    VehiclePathPoint.new(-172595, 247737, 398),
    VehiclePathPoint.new(-174538, 246185, 39),
    VehiclePathPoint.new(-179440, 243651, 1337),
    VehiclePathPoint.new(-182601, 243957, 2739),
    VehiclePathPoint.new(-184952, 245122, 2694),
    VehiclePathPoint.new(-186936, 244563, 2617)
  ]

  private GRACIA_TO_WARPGATE = [
    VehiclePathPoint.new(-187801, 244997, 2672),
    VehiclePathPoint.new(-188520, 245932, 2465),
    VehiclePathPoint.new(-189932, 245243, 1682),
    VehiclePathPoint.new(-191192, 242969, 1523),
    VehiclePathPoint.new(-190408, 239088, 1706),
    VehiclePathPoint.new(-187475, 237113, 2768),
    VehiclePathPoint.new(-184673, 238433, 2802),
    VehiclePathPoint.new(-184524, 241119, 2816),
    VehiclePathPoint.new(-182129, 243385, 2733),
    VehiclePathPoint.new(-179440, 243651, 1337),
    VehiclePathPoint.new(-174538, 246185, 39),
    VehiclePathPoint.new(-172595, 247737, 398),
    VehiclePathPoint.new(-171822, 250061, 425),
    VehiclePathPoint.new(-169763, 254815, 282),
    VehiclePathPoint.new(-168067, 256626, 343),
    VehiclePathPoint.new(-157261, 255664, 221, 0, 64781)
  ]

  private WARPGATE_TO_GLUDIO = [
    VehiclePathPoint.new(-153414, 255385, 221),
    VehiclePathPoint.new(-149548, 258172, 221),
    VehiclePathPoint.new(-146884, 257097, 221),
    VehiclePathPoint.new(-146672, 254239, 221),
    VehiclePathPoint.new(-147855, 252712, 206),
    VehiclePathPoint.new(-149378, 252552, 198)
  ]

  private alias NpcSay = Packets::Outgoing::NpcSay

  @cycle = 0
  @found_atc_gracia = false
  @atc_gracia : L2Npc?
  @found_atc_gludio = false
  @atc_gludio : L2Npc?
  @ship : L2AirshipInstance

  def initialize
    super(self.class.simple_name, "gracia/vehicles")

    @ship = AirshipManager.get_new_airship(-149378, 252552, 198, 33837)
    @ship.oust_loc = OUST_GLUDIO
    @ship.dock_id = GLUDIO_DOCK_ID
    @ship.register_engine(BoatEngineDelegator.new(self))
    @ship.run_engine(60_000)

    add_start_npc(CONTROLLERS)
    add_first_talk_id(CONTROLLERS)
    add_talk_id(CONTROLLERS)
  end

  private struct BoatEngineDelegator
    include BoatEngine

    @boat = uninitialized L2BoatInstance

    # def initialize(@airship : AirShipGludioGracia, @boat : L2Vehicle)
    # end
    initializer airship : AirShipGludioGracia

    delegate call, to: @airship
  end

  private def broadcast_in_gludio(npc_string)
    unless @found_atc_gludio
      @found_atc_gludio = true
      @atc_gludio = find_controller
    end

    if atc = @atc_gludio
      say = NpcSay.new(atc.l2id, Say2::NPC_SHOUT, atc.id, npc_string)
      atc.broadcast_packet(say)
    end
  end

  private def broadcast_in_gracia(npc_string)
    unless @found_atc_gracia
      @found_atc_gracia = true
      @atc_gracia = find_controller
    end

    if atc = @atc_gracia
      say = NpcSay.new(atc.l2id, Say2::NPC_SHOUT, atc.id, npc_string)
      atc.broadcast_packet(say)
    end
  end

  private def find_controller
    L2World.get_visible_objects(@ship, 600) do |obj|
      if obj.is_a?(L2Npc) && CONTROLLERS.includes?(obj.id)
        return obj
      end
    end
    # warn "Controller not found."
    nil
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case
    when pc.transformed?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_TRANSFORMED)
    when pc.paralyzed?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_PETRIFIED)
    when pc.looks_dead?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_DEAD)
    when pc.fishing?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_FISHING)
    when pc.in_combat?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_IN_BATTLE)
    when pc.in_duel?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_IN_A_DUEL)
    when pc.sitting?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_SITTING)
    when pc.casting_now?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_CASTING)
    when pc.cursed_weapon_equipped?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_A_CURSED_WEAPON_IS_EQUIPPED)
    when pc.combat_flag_equipped?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_HOLDING_A_FLAG)
    when pc.has_summon? || pc.mounted?
      pc.send_packet(SystemMessageId::YOU_CANNOT_BOARD_AN_AIRSHIP_WHILE_A_PET_OR_A_SERVITOR_IS_SUMMONED)
    when @ship.in_dock? && @ship.inside_radius?(pc, 600, true, false)
      @ship.add_passenger(pc)
    else
      if !@ship.in_dock?
        pc.send_html <<-HTML
          <html>
            <body>
              Custom message:<br>
              The airship is not docked.
            </body>
          </html>
        HTML
      elsif !@ship.inside_radius?(pc, 600, true, false)
        pc.send_html <<-HTML
          <html>
            <body>
              Custom message:<br>
              The airship is too far away (#{pc.calculate_distance(@ship, true, false).round}/600).
            </body>
          </html>
        HTML
      end
    end

    nil
  end

  def on_first_talk(npc, pc)
    "#{npc.id}.htm"
  end

  def call
    case @cycle
    when 0
      # debug "Leaving the Gludio dock."
      broadcast_in_gludio(NpcString::THE_REGULARLY_SCHEDULED_AIRSHIP_THAT_FLIES_TO_THE_GRACIA_CONTINENT_HAS_DEPARTED)
      @ship.dock_id = 0
      @ship.execute_path(GLUDIO_TO_WARPGATE)
    when 1
      # @ship.tele_to_location -167874, 256731, -509, 41035, false
      # debug "Setting oust location to Gracia."
      @ship.oust_loc = OUST_GRACIA
      ThreadPoolManager.schedule_general(self, 5000)
    when 2
      # debug "Heading to the Warpgate to Gracia."
      @ship.execute_path(WARPGATE_TO_GRACIA)
    when 3
      # debug "Arrived in Gracia. Leaving for Gludio in 1 minute."
      broadcast_in_gracia(NpcString::THE_REGULARLY_SCHEDULED_AIRSHIP_HAS_ARRIVED_IT_WILL_DEPART_FOR_THE_ADEN_CONTINENT_IN_1_MINUTE)
      @ship.dock_id = GRACIA_DOCK_ID
      @ship.oust_players
      ThreadPoolManager.schedule_general(self, 60000)
    when 4
      # debug "Leaving the Gracia dock."
      broadcast_in_gracia(NpcString::THE_REGULARLY_SCHEDULED_AIRSHIP_THAT_FLIES_TO_THE_ADEN_CONTINENT_HAS_DEPARTED)
      @ship.dock_id = 0
      @ship.execute_path(GRACIA_TO_WARPGATE)
    when 5
      # @ship.tele_to_location -157261, 255664, 221, 64781, false
      # debug "Setting oust location to Gludio."
      @ship.oust_loc = OUST_GLUDIO
      ThreadPoolManager.schedule_general(self, 5000)
    when 6
      # debug "Heading to the Warpgate to Gludio."
      @ship.execute_path(WARPGATE_TO_GLUDIO)
    when 7
      # debug "Arrived in Gludio. Leaving for Gracia in 1 minute."
      broadcast_in_gludio(NpcString::THE_REGULARLY_SCHEDULED_AIRSHIP_HAS_ARRIVED_IT_WILL_DEPART_FOR_THE_GRACIA_CONTINENT_IN_1_MINUTE)
      @ship.dock_id = GLUDIO_DOCK_ID
      @ship.oust_players
      ThreadPoolManager.schedule_general(self, 60000)
    end

    @cycle += 1
    if @cycle > 7
      @cycle = 0
    end
  end

  def to_log(io : IO)
    io << "Airship (Gludio - Gracia)"
  end
end
