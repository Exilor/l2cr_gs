class Packets::Incoming::LoginServerFail < MMO::IncomingPacket(LoginServerClient)
  include Loggable

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

  def read
    @reason_id = c
  end

  def run
    debug "Rejected by LoginServer (#{REASONS[@reason_id]?.inspect})."
  end
end
