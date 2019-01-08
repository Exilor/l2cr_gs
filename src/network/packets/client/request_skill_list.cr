class Packets::Incoming::RequestSkillList < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    active_char.try &.send_skill_list
  end
end
