class Packets::Incoming::RequestRecipeShopMessageSet < GameClientPacket
  no_action_request

  private MAX_MSG_LENGTH = 29

  @msg = ""

  private def read_impl
    @msg = s
  end

  private def run_impl
    return unless pc = active_char

    if @msg.size > MAX_MSG_LENGTH
      Util.punish(pc, "tried to overflow recipe shop message")
      return
    end

    debug "if the shop name doesn't show up check this"
    if pc.has_manufacture_shop?
      pc.store_name = @msg
    end
  end
end
