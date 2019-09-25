module AntiFeedManager
  extend self
  extend Loggable

  GAME_ID = 0
  OLYMPIAD_ID = 1
  TVT_ID = 2
  L2EVENT_ID = 3

  private LAST_DEATH_TIMES = Hash(Int32, Int64).new
  private EVENT_IPS = Hash(Int32, Hash(UInt64, Int32)).new

  def set_last_death_time(l2id : Int32)
    LAST_DEATH_TIMES[l2id] = Time.ms
  end

  def check(attacker : L2Character?, target : L2Character?) : Bool
    unless Config.antifeed_enable
      return true
    end

    unless target_player = target.acting_player?
      return false
    end

    if Config.antifeed_interval > 0 && LAST_DEATH_TIMES.has_key?(target_player.l2id)
      if Time.ms - LAST_DEATH_TIMES[target_player.l2id] < Config.antifeed_interval
        return false
      end
    end

    if Config.antifeed_dualbox && attacker
      unless attacker_player = attacker.acting_player?
        return false
      end

      target_client = target_player.client?
      attacker_client = attacker_player.client?
      if target_client.nil? || attacker_client.nil?
        return !Config.antifeed_disconnected_as_dualbox
      end

      if target_client.detached? || attacker_client.detached?
        return !Config.antifeed_disconnected_as_dualbox
      end

      return target_client.connection.ip != attacker_client.connection.ip
    end

    true
  end

  def clear
    LAST_DEATH_TIMES.clear
  end

  def register_event(event_id : Int32)
    EVENT_IPS[event_id] ||= {} of UInt64 => Int32
  end

  def try_add_player(event_id : Int32, pc : L2PcInstance, max : Int32) : Bool
    try_add_client(event_id, pc.client?, max)
  end

  def try_add_client(event_id : Int32, client : GameClient?, max : Int32) : Bool
    unless client
      return false
    end

    unless event = EVENT_IPS[event_id]?
      return false
    end

    addr_hash = client.connection.ip.hash

    connection_count = event.fetch(addr_hash, 0)
    white_list_count = Config.dualbox_check_whitelist.fetch(addr_hash, 0)
    if white_list_count < 0 || connection_count + 1 <= max + white_list_count
      event[addr_hash] = connection_count + 1
      return true
    end

    false
  end

  def remove_player(event_id : Int32, pc : L2PcInstance) : Bool
    remove_client(event_id, pc.client?)
  end

  def remove_client(event_id : Int32, client : GameClient?) : Bool
    unless client
      return false
    end

    unless event = EVENT_IPS[event_id]?
      return false
    end

    addr_hash = client.connection.ip.hash

    if temp = event[addr_hash]?
      if temp > 0
        event[addr_hash] = temp - 1
      end

      return true
    end

    false
  end

  def on_disconnect(client : GameClient?)
    unless client
      return
    end

    EVENT_IPS.each_key { |k| remove_client(k, client) }
  end

  def clear(event_id : Int32)
    EVENT_IPS[event_id]?.try &.clear
  end

  def get_limit(pc : L2PcInstance, max : Int32) : Int32
    get_limit(pc.client?, max)
  end

  def get_limit(client : GameClient?, max : Int32) : Int32
    unless client
      return max
    end

    addr_hash = client.connection.ip.hash.to_i32

    limit = max

    if temp = Config.dualbox_check_whitelist[addr_hash]?
      limit += temp
    end

    limit
  end
end
