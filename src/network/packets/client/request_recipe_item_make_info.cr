class Packets::Incoming::RequestRecipeItemMakeInfo < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    return unless pc = active_char
    info = RecipeItemMakeInfo.new(@id, pc)
    send_packet(info)
  end
end
