struct BlockList
  include Loggable
  extend Loggable

  private OFFLINE_LIST = Concurrent::Map(Int32, Array(Int32)).new

  private alias SystemMessage = Packets::Outgoing::SystemMessage

  getter block_list : Array(Int32)

  def initialize(@owner : L2PcInstance)
    @block_list = OFFLINE_LIST[owner.l2id]? || BlockList.load_list(@owner.l2id)
  end

  protected def add_to_block_list(target : Int32)
    @block_list << target
    persist_in_db(target)
  end

  protected def remove_from_block_list(target : Int32)
    @block_list.delete(target)
    remove_from_db(target)
  end

  def player_logout
    OFFLINE_LIST[@owner.l2id] = @block_list
  end

  def self.load_list(obj_id : Int32) : Array(Int32)
    list = [] of Int32
    begin
      sql = "SELECT friendId FROM character_friends WHERE charId=? AND relation=1"
      GameDB.each(sql, obj_id) do |rs|
        friend_id = rs.get_i32("friendId")
        list << friend_id
      end
    rescue e
      error e
    end
    list
  end

  protected def remove_from_db(target_id : Int32)
    sql = "DELETE FROM character_friends WHERE charId=? AND friendId=? AND relation=1"
    GameDB.exec(sql, @owner.l2id, target_id)
  rescue e
    error e
  end

  protected def persist_in_db(target_id : Int32)
    sql = "INSERT INTO character_friends (charId, friendId, relation) VALUES (?, ?, 1)"
    GameDB.exec(sql, @owner.l2id, target_id)
  rescue e
    error e
  end

  def in_block_list?(target : L2PcInstance) : Bool
    @block_list.includes?(target.l2id)
  end

  def in_block_list?(id : Int32) : Bool
    @block_list.includes?(id)
  end

  def self.blocked?(owner : L2PcInstance, target : L2PcInstance) : Bool
    block_list = owner.block_list
    block_list.block_all? || block_list.in_block_list?(target)
  end

  def self.blocked?(owner : L2PcInstance, id : Int32) : Bool
    block_list = owner.block_list
    block_list.block_all? || block_list.in_block_list?(id)
  end

  protected def block_all=(state : Bool)
    @owner.message_refusal = state
  end

  def self.add_to_block_list(list_owner : L2PcInstance, target_id : Int32)
    return unless list_owner

    unless char_name = CharNameTable.get_name_by_id(target_id)
      warn "#{char_name.inspect} not found in CharNameTable."
      return
    end

    if list_owner.block_list.block_list.includes?(target_id)
      sm = SystemMessage.s1_already_in_friends_list
      sm.add_string(char_name)
      list_owner.send_packet(sm)
      return
    end

    if list_owner.block_list.block_list.includes?(target_id)
      list_owner.send_message("Already in ignore list.")
      return
    end

    list_owner.block_list.add_to_block_list(target_id)

    sm = SystemMessage.s1_was_added_to_your_ignore_list
    sm.add_string(char_name)
    list_owner.send_packet(sm)

    if player = L2World.get_player(target_id)
      sm = SystemMessage.s1_has_added_you_to_ignore_list
      sm.add_string(list_owner.name)
      player.send_packet(sm)
    end
  end

  def self.remove_from_block_list(list_owner : L2PcInstance, target_id : Int32)
    return unless list_owner

    unless char_name = CharNameTable.get_name_by_id(target_id)
      warn "No name found for player with id #{target_id}."
      char_name = "??"
    end

    unless list_owner.block_list.block_list.includes?(target_id)
      list_owner.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return
    end

    list_owner.block_list.remove_from_block_list(target_id)

    sm = SystemMessage.s1_was_removed_from_your_ignore_list
    sm.add_string(char_name)
    list_owner.send_packet(sm)
  end

  def block_all? : Bool
    @owner.message_refusal?
  end

  def self.block_all?(list_owner : L2PcInstance) : Bool
    list_owner.block_list.block_all?
  end

  def self.set_block_all(list_owner : L2PcInstance, value : Bool)
    list_owner.block_list.block_all = value
  end

  def self.send_list_to_owner(list_owner : L2PcInstance)
    list_owner.send_packet(SystemMessageId::BLOCK_LIST_HEADER)
    list_owner.block_list.block_list.each_with_index do |id, i|
      list_owner.send_message("#{i + 1}. #{CharNameTable.get_name_by_id(id)}")
    end
    list_owner.send_packet(SystemMessageId::FRIEND_LIST_FOOTER)
  end

  def self.in_block_list?(list_owner : L2PcInstance, target : L2PcInstance) : Bool
    list_owner.block_list.in_block_list?(target)
  end

  def self.in_block_list?(owner_id : Int32, target_id : Int32) : Bool
    if pc = L2World.get_player(owner_id)
      return BlockList.blocked?(pc, target_id)
    end

    (OFFLINE_LIST[owner_id] ||= BlockList.load_list(owner_id)).includes?(target_id)
  end
end
