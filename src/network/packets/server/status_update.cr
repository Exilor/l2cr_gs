class Packets::Outgoing::StatusUpdate < GameServerPacket
  private LEVEL = 0x01

  private EXP = 0x02
  private STR = 0x03
  private DEX = 0x04
  private CON = 0x05
  private INT = 0x06
  private WIT = 0x07
  private MEN = 0x08

  private CUR_HP = 0x09
  private MAX_HP = 0x0a
  private CUR_MP = 0x0b
  private MAX_MP = 0x0c

  private SP       = 0x0d
  private CUR_LOAD = 0x0e
  private MAX_LOAD = 0x0f

  private P_ATK    = 0x11
  private ATK_SPD  = 0x12
  private P_DEF    = 0x13
  private EVASION  = 0x14
  private ACCURACY = 0x15
  private CRITICAL = 0x16
  private M_ATK    = 0x17
  private CAST_SPD = 0x18
  private M_DEF    = 0x19
  private PVP_FLAG = 0x1a
  private KARMA    = 0x1b

  private CUR_CP = 0x21
  private MAX_CP = 0x22

  private record Attribute, id : UInt8, value : Int32

  @attributes = [] of Attribute

  initializer l2id : Int32

  def initialize(obj : L2Object)
    @l2id = obj.l2id
  end

  def has_attributes?
    !@attributes.empty?
  end

  private def write_impl
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
      @attributes << Attribute.new({{stat.id}}.to_u8, value.to_i)
    end
  {% end %}

  def self.hp(char)
    HPUpdate.new(char.l2id, char.max_hp.to_i, char.current_hp.to_i)
  end

  private class HPUpdate < GameServerPacket
    initializer l2id : Int32, max_hp : Int32, current_hp : Int32

    def write_impl
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

  private class MPUpdate < GameServerPacket
    initializer l2id : Int32, current_mp : Int32

    def write_impl
      c 0x18

      d @l2id
      d 1
      d CUR_MP
      d @current_mp
    end
  end

  def self.cp_hp_mp(char)
    cp, hp, mp = char.current_cp.to_i, char.current_hp.to_i, char.current_mp.to_i
    max_cp, max_hp, max_mp = char.max_cp, char.max_hp, char.max_mp
    CpHpMpUpdate.new(char.l2id, cp, hp, mp, max_cp, max_hp, max_mp)
  end

  private class CpHpMpUpdate < GameServerPacket
    initializer l2id : Int32, cp : Int32, hp : Int32, mp : Int32,
      max_cp : Int32, max_hp : Int32, max_mp : Int32

    def write_impl
      c 0x18

      d @l2id
      d 6
      d CUR_CP
      d @cp
      d CUR_HP
      d @hp
      d CUR_MP
      d @mp
      d MAX_CP
      d @max_cp
      d MAX_HP
      d @max_hp
      d MAX_MP
      d @max_mp
    end
  end

  def self.current_load(char)
    CurrentLoadUpdate.new(char.l2id, char.current_load)
  end

  private class CurrentLoadUpdate < GameServerPacket
    initializer l2id : Int32, load : Int32

    def write_impl
      c 0x18

      d @l2id
      d 1
      d CUR_LOAD
      d @load
    end
  end

  def self.sp(char)
    SpUpdate.new(char.l2id, char.sp)
  end

  private class SpUpdate < GameServerPacket
    initializer l2id : Int32, sp : Int32

    def write_impl
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

  private class KarmaUpdate < GameServerPacket
    initializer l2id : Int32, karma : Int32

    def write_impl
      c 0x18

      d @l2id
      d 1
      d KARMA
      d @karma
    end
  end

  def self.level_max_hp_mp(char, level, hp, mp)
    LevelMaxHpMpUpdate.new(char.l2id, level, hp, mp)
  end

  private class LevelMaxHpMpUpdate < GameServerPacket
    initializer l2id : Int32, level : Int32, hp : Int32, mp : Int32

    def write_impl
      c 0x18

      d @l2id
      d 3
      d LEVEL
      d @level
      d MAX_HP
      d @hp
      d MAX_MP
      d @mp
    end
  end

  def self.level_max_cp_hp_mp(char, level, cp, hp, mp)
    LevelMaxCpHpMpUpdate.new(char.l2id, level, cp, hp, mp)
  end

  private class LevelMaxCpHpMpUpdate < GameServerPacket
    initializer l2id : Int32, level : Int32, cp : Int32, hp : Int32, mp : Int32

    def write_impl
      c 0x18

      d @l2id
      d 4
      d LEVEL
      d @level
      d MAX_CP
      d @cp
      d MAX_HP
      d @hp
      d MAX_MP
      d @mp
    end
  end
end
