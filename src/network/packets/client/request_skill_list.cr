class Packets::Incoming::RequestSkillList < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    active_char.try &.send_skill_list
  end
end
