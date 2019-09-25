class Packets::Outgoing::StatusUpdate < GameServerPacket
  LEVEL = 0x01

  EXP = 0x02
  STR = 0x03
  DEX = 0x04
  CON = 0x05
  INT = 0x06
  WIT = 0x07
  MEN = 0x08

  CUR_HP = 0x09
  MAX_HP = 0x0a
  CUR_MP = 0x0b
  MAX_MP = 0x0c

  SP       = 0x0d
  CUR_LOAD = 0x0e
  MAX_LOAD = 0x0f

  P_ATK    = 0x11
  ATK_SPD  = 0x12
  P_DEF    = 0x13
  EVASION  = 0x14
  ACCURACY = 0x15
  CRITICAL = 0x16
  M_ATK    = 0x17
  CAST_SPD = 0x18
  M_DEF    = 0x19
  PVP_FLAG = 0x1a
  KARMA    = 0x1b

  CUR_CP = 0x21
  MAX_CP = 0x22

  private record Attribute, id : UInt8, value : Int32

  @attributes = [] of Attribute

  initializer l2id : Int32

  def initialize(obj : L2Object)
    @l2id = obj.l2id
  end

  def add_attribute(id : Int, value : Int32)
    @attributes << Attribute.new(id.to_u8, value)
  end

  def has_attributes?
    !@attributes.empty?
  end

  def write_impl
    c 0x18

    d @l2id
    d @attributes.size
    @attributes.each do |attr|
      d attr.id
      d attr.value
    end
  end

  #########################      custom      ###################################

  {% for stat in %w[LEVEL EXP STR DEX CON INT WIT MEN CUR_HP MAX_HP CUR_MP MAX_MP SP CAST_SPD CUR_LOAD MAX_LOAD P_ATK ATK_SPD P_DEF EVASION ACCURACY CRITICAL M_ATK M_DEF PVP_FLAG KARMA CUR_CP MAX_CP] %}
    def add_{{stat.downcase.id}}(value)
      @attributes << Attribute.new({{stat.id}}.to_u8, value.to_i32)
    end
  {% end %}

  def self.hp(char)
    HPUpdate.new(char.l2id, char.max_hp.to_i, char.current_hp.to_i)
  end

  private class HPUpdate < StatusUpdate
    initializer l2id : Int32, max_hp : Int32, current_hp : Int32

    def write
      c 0x18

      d @l2id
      d 2
      d MAX_HP
      d @max_hp
      d CUR_HP
      d @current_hp
    end
  end

  def self.current_mp(char)
    MPUpdate.new(char.l2id, char.current_mp.to_i)
  end

  private class MPUpdate < StatusUpdate
    initializer l2id : Int32, current_mp : Int32

    def write
      c 0x18

      d @l2id
      d 1
      d CUR_MP
      d @current_mp
    end
  end

  def self.current_cp_hp_mp(char)
    cp, hp, mp = char.current_cp.to_i, char.current_hp.to_i, char.current_mp.to_i
    CpHpMpUpdate.new(char.l2id, cp, hp, mp)
  end

  private class CpHpMpUpdate < StatusUpdate
    initializer l2id : Int32, cp : Int32, hp : Int32, mp : Int32

    def write
      c 0x18

      d @l2id
      d 3
      d CUR_CP
      d @cp
      d CUR_HP
      d @hp
      d CUR_MP
      d @mp
    end
  end

  def self.current_load(char)
    CurrentLoadUpdate.new(char.l2id, char.current_load)
  end

  private class CurrentLoadUpdate < StatusUpdate
    initializer l2id : Int32, load : Int32

    def write
      c 0x18

      d @l2id
      d 1
      d CUR_LOAD
      d @load
    end
  end

  def self.sp(char)
    SPUpdate.new(char.l2id, char.sp)
  end

  private class SPUpdate < StatusUpdate
    initializer l2id : Int32, sp : Int32

    def write
      c 0x18

      d @l2id
      d 1
      d SP
      d @sp
    end
  end

  def self.karma(char)
    KarmaUpdate.new(char.l2id, char.karma)
  end

  private class KarmaUpdate < StatusUpdate
    initializer l2id : Int32, karma : Int32

    def write
      c 0x18

      d @l2id
      d 1
      d KARMA
      d @karma
    end
  end
end
