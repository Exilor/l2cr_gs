struct L2ContactList
  include Loggable

  private QUERY_ADD = "INSERT INTO character_contacts (charId, contactId) VALUES (?, ?)"
  private QUERY_REMOVE = "DELETE FROM character_contacts WHERE charId = ? and contactId = ?"
  private QUERY_LOAD = "SELECT contactId FROM character_contacts WHERE charId = ?"

  getter contacts = Concurrent::Array(String).new

  def initialize(pc : L2PcInstance)
    @pc = pc
    restore
  end

  def restore
    GameDB.query_each(QUERY_LOAD, @pc.l2id) do |rs|
      id = rs.read(Int32)
      name = CharNameTable.get_name_by_id(id)
      if name.nil? || (name == @pc.name || id == @pc.l2id)
        next
      end

      @contacts << name
    end
  rescue e
    error e
  end

  def add(name : String) : Bool
    id = CharNameTable.get_id_by_name(name)

    case
    when @contacts.includes?(name)
      @pc.send_packet(SystemMessageId::NAME_ALREADY_EXIST_ON_CONTACT_LIST)
      return false
    when @pc.name == name
      @pc.send_packet(SystemMessageId::CANNOT_ADD_YOUR_NAME_ON_CONTACT_LIST)
      return false
    when @contacts.size >= 100
      @pc.send_packet(SystemMessageId::CONTACT_LIST_LIMIT_REACHED)
      return false
    when id < 1
      sm = Packets::Outgoing::SystemMessage.name_s1_not_exist_try_another_name
      sm.add_string(name)
      @pc.send_packet(sm)
      return false
    else
      @contacts.each do |contact_name|
        if contact_name.casecmp?(name)
          @pc.send_packet(SystemMessageId::NAME_ALREADY_EXIST_ON_CONTACT_LIST)
          return false
        end
      end
    end

    begin
      GameDB.exec(QUERY_ADD, @pc.l2id, id)
      @contacts << name

      sm = Packets::Outgoing::SystemMessage.s1_successfully_added_to_contact_list
      sm.add_string(name)
      @pc.send_packet(sm)
    rescue e
      error e
    end

    true
  end

  def remove(name : String)
    id = CharNameTable.get_id_by_name(name)

    if !@contacts.includes?(name)
      @pc.send_packet(SystemMessageId::NAME_NOT_REGISTERED_ON_CONTACT_LIST)
      return
    elsif id < 1
      return
    end

    @contacts.delete_first(name)

    begin
      GameDB.exec(QUERY_REMOVE, @pc.l2id, id)

      sm = Packets::Outgoing::SystemMessage.s1_succesfully_deleted_from_contact_list
      sm.add_string(name)
      @pc.send_packet(sm)
    rescue e
      error e
    end
  end
end
