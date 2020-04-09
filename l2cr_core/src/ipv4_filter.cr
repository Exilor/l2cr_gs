require "./synchronizable"
require "./mmo/i_accept_filter"
require "./loggable"

struct IPv4Filter
  include MMO::IAcceptFilter
  include Synchronizable
  include Loggable

  private SLEEP_TIME = 5000.milliseconds

  private class Flood
    property last_access : Int64 = Time.ms
    property tries : Int32 = 0
  end

  @ip_flood_map = {} of String => Flood

  def initialize
    run
  end

  def accept?(sc : TCPSocket) : Bool
    addr = sc.remote_address.address
    return true if addr == "127.0.0.1"
    current = Time.ms

    f = nil
    sync do
      f = @ip_flood_map[addr]?
    end

    if f
      if f.tries == -1
        f.last_access = current
        return false
      end

      if f.last_access + 1000 > current
        f.last_access = current
        if f.tries >= 3
          f.tries = -1
          return false
        end
        f.tries += 1
      else
        f.last_access = current
      end
    else
      sync { @ip_flood_map[addr] ||= Flood.new }
    end

    true
  end

  private def run
    spawn do
      loop do
        reference = Time.ms - (1000 * 300)
        sync do
          @ip_flood_map.reject! do |_, v|
            v.last_access < reference
          end
        end
        sleep(SLEEP_TIME)
      end
    end
  end
end
