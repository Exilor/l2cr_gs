class Packets::Outgoing::SetupGauge < GameServerPacket
  private BLUE = 0u8
  private RED  = 1u8
  private CYAN = 2u8

  @char_id = 0

  initializer color: UInt8, cur_time: Int32, max_time: Int32

  def initialize(@color : UInt8, time : Int32)
    @max_time = @cur_time = time
  end

  def self.blue(cur : Int32, max : Int32 = cur)
    new(BLUE, cur, max)
  end

  def self.red(cur : Int32, max : Int32 = cur)
    new(RED, cur, max)
  end

  def self.cyan(cur : Int32, max : Int32 = cur)
    new(CYAN, cur, max)
  end

  def run_impl
    @char_id = active_char.not_nil!.l2id
  end

  def write_impl
    c 0x6b

    d @char_id
    d @color
    d @cur_time
    d @max_time
  end
end
