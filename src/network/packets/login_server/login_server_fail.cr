require "../login_server_packet"

class Packets::Incoming::LoginServerFail < LoginServerPacket
  private REASONS = {
    "None",
    "Reason: ip banned",
    "Reason: ip reserved",
    "Reason: wrong hexid",
    "Reason: id reserved",
    "Reason: no free ID",
    "Not authed",
    "Reason: already logged in"
  }

  @reason_id = 0

  private def read_impl
    @reason_id = c
  end

  private def run_impl
    error { "Rejected by LoginServer (rason: '#{REASONS[@reason_id]?}')." }
  end
end
