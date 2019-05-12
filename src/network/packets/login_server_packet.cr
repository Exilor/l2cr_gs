require "../../login_server_client"

abstract class LoginServerPacket < MMO::IncomingPacket(LoginServerClient)
  include Loggable

  def read : Bool
    read_impl
    true
  rescue e
    error e
    false
  end

  abstract def read_impl

  def run
    run_impl
  rescue e
    error e
  end

  abstract def run_impl
end
