require "../stat/controllable_airship_stat"

class L2ControllableAirshipInstance < L2AirshipInstance
  private HELM = 13556
  private LOW_FUEL = 40

  getter owner_id
  getter fuel = 0
  property max_fuel : Int32 = 0

  def initialize(template : L2CharTemplate, @owner_id : Int32)
    super(template)
    @helm_id = IdFactory.next
  end

  def instance_type : InstanceType
    InstanceType::L2ControllableAirShipInstance
  end

  def stat : ControllableAirshipStat
    super.as(ControllableAirshipStat)
  end

  private def init_char_stat
    @stat = ControllableAirshipStat.new(self)
  end

  def can_be_controlled? : Bool
    super && !in_dock?
  end

  def owner?(pc : L2PcInstance) : Bool
    if @owner_id == 0
      return false
    end

    pc.clan_id == @owner_id || pc.l2id == @owner_id
  end

  def captain?(pc : L2PcInstance) : Bool
    !!@captain && pc == @captain
  end

  def captain_id : Int32
    @captain.try &.l2id || 0
  end

  def helm_l2id : Int32
    @helm_id
  end

  def helm_item_id : Int32
    HELM
  end

  def set_captain(pc : L2PcInstance?) : Bool
    if pc.nil?
      @captain = nil
    else
      if @captain.nil? && pc.airship == self
        pos = pc.in_vehicle_position.not_nil!
        x = pos.x - 0x16e
        y = pos.y
        z = pos.z - 0x6b

        if x.abs2 + y.abs2 + z.abs2 > 2500
          pc.send_packet(SystemMessageId::CANT_CONTROL_TOO_FAR)
          return false
        elsif pc.in_combat?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_IN_A_BATTLE)
          return false
        elsif pc.sitting?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_IN_A_SITTING_POSITION)
          return false
        elsif pc.paralyzed?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_YOU_ARE_PETRIFIED)
          return false
        elsif pc.cursed_weapon_equipped?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_A_CURSED_WEAPON_IS_EQUIPPED)
          return false
        elsif pc.fishing?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_FISHING)
          return false
        elsif pc.dead? || pc.fake_death?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHEN_YOU_ARE_DEAD)
          return false
        elsif pc.casting_now?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_USING_A_SKILL)
          return false
        elsif pc.transformed?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_TRANSFORMED)
          return false
        elsif pc.combat_flag_equipped?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_HOLDING_A_FLAG)
          return false
        elsif pc.in_duel?
          pc.send_packet(SystemMessageId::YOU_CANNOT_CONTROL_THE_HELM_WHILE_IN_A_DUEL)
          return false
        end

        @captain = pc
        pc.broadcast_user_info
      else
        return false
      end
    end

    update_abnormal_effect

    true
  end

  def fuel=(f : Int32)
    old = @fuel
    if f < 0
      @fuel = 0
    elsif f > @max_fuel
      f = @max_fuel
    else
      @fuel = f
    end

    if @fuel == 0 && old > 0
      broadcast_to_passengers(SystemMessage.the_airship_fuel_run_out)
    elsif @fuel < LOW_FUEL
      broadcast_to_passengers(SystemMessage.the_airship_fuel_soon_run_out)
    end
  end

  def oust_player(pc : L2PcInstance)
    if pc == @captain
      set_captain(nil)
    end

    super
  end

  def on_spawn
    super

    t1 = CheckTask.new(self)
    @check_task = ThreadPoolManager.schedule_general_at_fixed_rate(t1, 60000, 10000)
    t2 = ConsumeFuelTask.new(self)
    @consume_fuel_task = ThreadPoolManager.schedule_general_at_fixed_rate(t2, 60000, 60000)
  end

  def delete_me : Bool
    unless super
      return false
    end

    if task = @check_task
      task.cancel
      @check_task = nil
    end

    if task = @consume_fuel_task
      task.cancel
      @consume_fuel_task = nil
    end

    broadcast_packet(DeleteObject.new(@helm_id))

    true
  end

  def refresh_id
    super
    IdFactory.release_id(@helm_id)
    @helm_id = IdFactory.next
  end

  def send_info(pc : L2PcInstance)
    super

    if captain = @captain
      captain.send_info(pc)
    end
  end

  private struct CheckTask
    initializer airship : L2ControllableAirshipInstance

    def call
      if @airship.visible? && @airship.empty? && !@airship.in_dock?
        ThreadPoolManager.execute_general(DecayTask.new(@airship))
      end
    end
  end

  private struct ConsumeFuelTask
    initializer airship : L2ControllableAirshipInstance

    def call
      fuel = @airship.fuel
      if fuel > 0
        fuel -= 10
        if fuel < 0
          fuel = 0
        end

        @airship.fuel = fuel
        @airship.update_abnormal_effect
      end
    end
  end

  private struct DecayTask
    initializer airship : L2ControllableAirshipInstance

    def call
      @airship.delete_me
    end
  end
end
