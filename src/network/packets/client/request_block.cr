class Packets::Incoming::RequestBlock < GameClientPacket
  private BLOCK = 0
  private UNBLOCK = 1
  private BLOCKLIST = 2
  private ALLBLOCK = 3
  private ALLUNBLOCK = 4

  @type = 0
  @name = ""

  private def read_impl
    @type = d
    if @type == BLOCK || @type == UNBLOCK
      @name = s
    end
  end

  private def run_impl
    return unless pc = active_char

    target_id = CharNameTable.get_id_by_name(@name)
    target_al = CharNameTable.get_access_level_by_id(target_id)

    case @type
    when BLOCK, UNBLOCK
      if target_id <= 0
        pc.send_packet(SystemMessageId::FAILED_TO_REGISTER_TO_IGNORE_LIST)
        return
      end

      if target_al > 0
        pc.send_packet(SystemMessageId::YOU_MAY_NOT_IMPOSE_A_BLOCK_ON_GM)
        return
      end

      if pc.l2id == target_id
        return
      end

      if @type == BLOCK
        BlockList.add_to_block_list(pc, target_id)
      else
        BlockList.remove_from_block_list(pc, target_id)
      end
    when BLOCKLIST
      BlockList.send_list_to_owner(pc)
    when ALLBLOCK
      pc.send_packet(SystemMessageId::MESSAGE_REFUSAL_MODE)
      BlockList.set_block_all(pc, true)
    when ALLUNBLOCK
      pc.send_packet(SystemMessageId::MESSAGE_ACCEPTANCE_MODE)
      BlockList.set_block_all(pc, false)
    else
      warn { "Unknown block type #{@type}." }
    end
  end
end
